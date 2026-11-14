//! `--cli`: the same flow on the console (a fully keyboard path that needs no GUI at all). On the Mac it is the
//! installer, and it also sets Factorio's Steam launch option, which is what starts the game with the native code.
use std::io::{self, Write};
use std::path::PathBuf;

use crate::core::config_changes;
use crate::core::factorio::Factorio;
use crate::core::install::{self, ModZip, NativeZip, Progress};
use crate::core::paths::{APP_NAME, NATIVE_ZIP};
#[cfg(not(windows))]
use crate::core::paths::{data_dir, log_dir, steam_dir};
#[cfg(not(windows))]
use crate::core::steam_launch;
use crate::core::{detect, github, state, uninstall};

#[cfg(windows)]
const EXIT: &str = "6";
#[cfg(not(windows))]
const EXIT: &str = "7";
#[cfg(windows)]
const PATH_PROMPT: &str = "Choose a number, or type the path of a Factorio folder or factorio.exe: ";
#[cfg(not(windows))]
const PATH_PROMPT: &str = "Choose a number, or type the path of factorio.app or the folder holding it: ";

pub fn run() {
    println!("=== {} installer ===", APP_NAME);
    println!();
    let mut factorio = detect::candidates().into_iter().next();
    show_status(&factorio);
    println!();
    loop {
        println!("Options:");
        println!("  1. Install / Update from GitHub");
        println!("  2. Install from local files (the mod zip and {})", NATIVE_ZIP);
        println!("  3. Recommended Factorio settings");
        println!("  4. Choose the Factorio install");
        println!("  5. Uninstall");
        #[cfg(not(windows))]
        println!("  6. Steam launch option");
        println!("  {}. Exit", EXIT);
        let choice = prompt(&format!("Choose an option (1-{}): ", EXIT));
        println!();
        match choice.as_str() {
            "1" => with_factorio(&factorio, install_from_github),
            "2" => with_factorio(&factorio, install_from_files),
            "3" => with_factorio(&factorio, |f| recommended_settings(f, None)),
            "4" => {
                if let Some(f) = choose_factorio() {
                    factorio = Some(f);
                }
            }
            "5" => with_factorio(&factorio, do_uninstall),
            #[cfg(not(windows))]
            "6" => set_launch_option(),
            c if c == EXIT || c.is_empty() => return,
            _ => println!("Invalid option."),
        }
        println!();
        show_status(&factorio);
        println!();
    }
}

fn with_factorio(f: &Option<Factorio>, op: impl FnOnce(&Factorio)) {
    match f {
        Some(f) => op(f),
        None => println!("Choose the Factorio install first (option 4)."),
    }
}

fn show_status(f: &Option<Factorio>) {
    let Some(f) = f else {
        println!("No Factorio install found. Choose one with option 4.");
        return;
    };
    println!("Factorio: {}", f.root.display());
    println!("Mods folder: {}", f.mods_dir().display());
    println!("Config: {}", f.config_ini.display());
    #[cfg(not(windows))]
    println!("Native code: {} (log in {})", f.native_dir.display(), log_dir().display());
    match detect::installed_version(f) {
        Some(v) if detect::is_installed(f) => println!("Installed {}: {}", APP_NAME, v),
        _ => println!("{} is not installed there.", APP_NAME),
    }
}

fn prompt(msg: &str) -> String {
    print!("{}", msg);
    io::stdout().flush().ok();
    let mut s = String::new();
    io::stdin().read_line(&mut s).ok();
    s.trim().to_string()
}

fn print_progress(p: Progress) {
    match p {
        Progress::Status(s) => println!("{}", s),
        Progress::Percent(pct) if pct % 25 == 0 => println!("  {}%", pct),
        _ => {}
    }
}

fn choose_factorio() -> Option<Factorio> {
    let found = detect::candidates();
    for (i, f) in found.iter().enumerate() {
        println!("  {}. {}", i + 1, f.root.display());
    }
    let answer = prompt(PATH_PROMPT);
    let picked = match answer.parse::<usize>() {
        Ok(n) if n >= 1 && n <= found.len() => Ok(found[n - 1].clone()),
        _ if answer.is_empty() => return None,
        _ => Factorio::locate(&PathBuf::from(answer.trim_matches('"'))),
    };
    match picked {
        Ok(f) => {
            if let Err(e) = state::remember(&f.root) {
                println!("Warning: could not remember this choice: {}", e);
            }
            Some(f)
        }
        Err(e) => {
            println!("Error: {}", e);
            None
        }
    }
}

fn install_from_github(f: &Factorio) {
    let cat = match github::fetch_catalog() {
        Ok(c) => c,
        Err(e) => {
            println!("Error: {}", e);
            return;
        }
    };
    if cat.versions.is_empty() && cat.ci.is_none() {
        println!("No releases are published yet.");
        return;
    }
    println!("Versions:");
    for (i, r) in cat.versions.iter().enumerate() {
        println!("  {}. {}{}{}", i + 1, r.tag_name, if r.prerelease { " (pre-release)" } else { "" }, unavailable(r));
    }
    let n = cat.versions.len();
    if let Some(ci) = &cat.ci {
        println!("  {}. latest successful CI build ({}) -- untested, may be broken{}", n + 1, github::ci_build_label(ci), unavailable(ci));
    }
    let choice = prompt(&format!("Choose a version (1-{}), or Enter for the newest: ", n + cat.ci.iter().count()));
    let idx = if choice.is_empty() { 0 } else { choice.parse::<usize>().unwrap_or(0).wrapping_sub(1) };
    let rel = if idx < n {
        &cat.versions[idx]
    } else if let (true, Some(ci)) = (idx == n, &cat.ci) {
        ci
    } else {
        println!("Invalid choice.");
        return;
    };
    if !rel.notes().is_empty() {
        println!("\nRelease notes for {}:\n{}\n", rel.tag_name, rel.notes());
    }
    if prompt(&format!("Install {} into {}? (Y/n): ", rel.tag_name, f.root.display())).eq_ignore_ascii_case("n") {
        return;
    }
    match install::download_release(rel, &print_progress) {
        Ok((m, nz)) => finish_install(f, m, nz),
        Err(e) => println!("Error: {}", e),
    }
}

/// What the version list adds to a release this platform cannot install (on Windows the catalog has none).
#[cfg(windows)]
fn unavailable(_: &github::ReleaseInfo) -> &'static str {
    ""
}

#[cfg(not(windows))]
fn unavailable(r: &github::ReleaseInfo) -> &'static str {
    if github::native_asset(r).is_some() {
        ""
    } else {
        " (no macOS build)"
    }
}

fn install_from_files(f: &Factorio) {
    let m = PathBuf::from(prompt("Path to FactorioAccess_<version>.zip: ").trim_matches('"'));
    let n = PathBuf::from(prompt(&format!("Path to {}: ", NATIVE_ZIP)).trim_matches('"'));
    match install::load_files(&m, &n) {
        Ok((m, n)) => finish_install(f, m, n),
        Err(e) => println!("Error: {}", e),
    }
}

fn finish_install(f: &Factorio, m: ModZip, n: NativeZip) {
    match install::install(f, &m, &n, &print_progress) {
        Ok(r) => {
            let _ = state::remember(&f.root);
            for old in &r.removed {
                println!("Removed the older {}", old.display());
            }
            println!("Installed the mod {} ({}) and the native code {}.", r.mod_version, r.mod_path.display(), r.native_version);
            #[cfg(not(windows))]
            set_launch_option();
            recommended_settings(f, Some(&m.change_sets));
        }
        Err(e) => println!("Error: {}", e),
    }
}

/// The config.ini check: from the mod just installed, or else from the one in the mods folder.
fn recommended_settings(f: &Factorio, sets: Option<&Vec<(String, String)>>) {
    let owned;
    let sets = match sets {
        Some(s) => s,
        None => match install::installed_change_sets(f) {
            Ok((_, s)) => {
                owned = s;
                &owned
            }
            Err(e) => {
                println!("Error: {}", e);
                return;
            }
        },
    };
    if !f.config_ini.exists() {
        println!("{} does not exist yet. Start Factorio once, close it, then choose Recommended settings here.", f.config_ini.display());
        return;
    }
    let check = match config_changes::check_file(&f.config_ini, sets) {
        Ok(c) => c,
        Err(e) => {
            println!("Error: {}", e);
            return;
        }
    };
    println!("config.ini has the recommended settings up to set {}.", check.level);
    if check.sets.is_empty() {
        println!("Factorio's settings already have every change {} recommends.", APP_NAME);
        return;
    }
    if !check.pending.is_empty() {
        if !prompt(&format!("{} (y/N): ", config_changes::question())).eq_ignore_ascii_case("y") {
            println!("Skipped. Choose Recommended settings later to apply them.");
            return;
        }
    }
    if detect::factorio_running() {
        println!("Factorio is running and would overwrite config.ini when it exits. Close it, then choose Recommended settings.");
        return;
    }
    match config_changes::apply_file(&f.config_ini, &check.sets) {
        Ok(changed) => println!("Applied {} changes (a backup of the old config.ini is beside it, config.ini.fa-backup).", changed.len()),
        Err(e) => println!("Error: {}", e),
    }
}

fn do_uninstall(f: &Factorio) {
    if !prompt(&format!("Remove {}'s native code from {}? (y/N): ", APP_NAME, f.native_dir.display())).eq_ignore_ascii_case("y") {
        return;
    }
    let remove_mod = prompt("Also remove the mod from the mods folder? (y/N): ").eq_ignore_ascii_case("y");
    #[cfg(not(windows))]
    if !launch_option_can_go() {
        return;
    }
    match uninstall::uninstall(f, remove_mod) {
        Ok(removed) => {
            for p in &removed {
                println!("Removed {}", p.display());
            }
            #[cfg(not(windows))]
            clear_launch_option();
            println!("{} uninstalled.", APP_NAME);
        }
        Err(e) => println!("Error: {}", e),
    }
}

/// The Steam accounts, or None after saying why they could not be read.
#[cfg(not(windows))]
fn steam_accounts() -> Option<Vec<steam_launch::Account>> {
    match steam_launch::accounts(&steam_dir()) {
        Ok(a) => Some(a),
        Err(e) => {
            println!("Error: {}", e);
            None
        }
    }
}

/// The line on the screen and the clipboard, and where it goes in Steam.
#[cfg(not(windows))]
fn tell_how_to_paste(line: &str) {
    println!("Factorio Access starts through Factorio's Steam launch option:");
    println!("{}", line);
    if steam_launch::copy_to_clipboard(line) {
        println!("That line is on the clipboard.");
    }
    println!("In Steam, right-click Factorio, choose Properties, and paste it into Launch Options on the General tab.");
    println!("Or quit Steam and choose Steam launch option here (option 6) to have it set for you.");
}

/// Sets the launch option in every Steam account, asking before replacing one that is not ours. While Steam runs it
/// would overwrite the file when it quits, so then the user is given the line to paste instead.
#[cfg(not(windows))]
fn set_launch_option() {
    let line = steam_launch::line(&data_dir());
    let Some(accounts) = steam_accounts() else { return };
    if !accounts.is_empty() && accounts.iter().all(|a| a.current == line) {
        println!("Factorio's Steam launch option is set.");
        return;
    }
    if accounts.is_empty() {
        println!("No Steam account was found in {} (has Steam been signed in on this Mac?).", steam_dir().join("userdata").display());
        tell_how_to_paste(&line);
        return;
    }
    if steam_launch::steam_running() {
        println!("Steam is running, so the installer cannot set Factorio's launch option: Steam would overwrite it when it quits.");
        tell_how_to_paste(&line);
        return;
    }
    for a in accounts.iter().filter(|a| a.current != line) {
        if !a.current.trim().is_empty() && !steam_launch::is_ours(&a.current) {
            println!("Steam account {} already has a launch option for Factorio: {}", a.id, a.current);
            if !prompt("Replace it with Factorio Access's? (y/N): ").eq_ignore_ascii_case("y") {
                println!("Left unchanged. Factorio Access will not start from Steam for that account until the launch option is:");
                println!("{}", line);
                continue;
            }
        }
        match steam_launch::set(&a.file, &line) {
            Ok(()) => println!("Set Factorio's Steam launch option for account {} (the old file is beside it, localconfig.vdf.fa-backup).", a.id),
            Err(e) => println!("Error: {}", e),
        }
    }
}

/// Before uninstalling: once FactorioAccess.app is gone, a launch option still naming it stops Steam from starting
/// Factorio at all. While Steam runs the option cannot be cleared, so the user decides.
#[cfg(not(windows))]
fn launch_option_can_go() -> bool {
    let Some(accounts) = steam_accounts() else { return false };
    if !accounts.iter().any(|a| steam_launch::is_ours(&a.current)) || !steam_launch::steam_running() {
        return true;
    }
    println!("Steam is running, so the installer cannot remove Factorio's launch option, and Steam cannot start Factorio with it once {} is removed.", APP_NAME);
    let go = prompt("Uninstall anyway and clear Launch Options in Steam yourself (right-click Factorio, Properties, General)? (y/N): ").eq_ignore_ascii_case("y");
    if !go {
        println!("Quit Steam, then uninstall again.");
    }
    go
}

#[cfg(not(windows))]
fn clear_launch_option() {
    let Some(accounts) = steam_accounts() else { return };
    let ours: Vec<_> = accounts.iter().filter(|a| steam_launch::is_ours(&a.current)).collect();
    if ours.is_empty() {
        return;
    }
    if steam_launch::steam_running() {
        println!("Now clear Factorio's Launch Options in Steam (right-click Factorio, Properties, General): Steam cannot start Factorio with it any more.");
        return;
    }
    for a in ours {
        match steam_launch::set(&a.file, "") {
            Ok(()) => println!("Cleared Factorio's Steam launch option for account {}.", a.id),
            Err(e) => println!("Error: {}", e),
        }
    }
}
