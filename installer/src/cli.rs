//! `--cli`: the same flow on the console (a fully keyboard path that needs no GUI at all).
use std::io::{self, Write};
use std::path::PathBuf;

use crate::core::config_changes;
use crate::core::factorio::Factorio;
use crate::core::install::{self, ModZip, NativeZip, Progress};
use crate::core::paths::APP_NAME;
use crate::core::{detect, github, state, uninstall};

pub fn run() {
    println!("=== {} installer ===", APP_NAME);
    println!();
    let mut factorio = detect::candidates().into_iter().next();
    show_status(&factorio);
    println!();
    loop {
        println!("Options:");
        println!("  1. Install / Update from GitHub");
        println!("  2. Install from local files (the mod zip and fa-native.zip)");
        println!("  3. Recommended Factorio settings");
        println!("  4. Choose the Factorio install");
        println!("  5. Uninstall");
        println!("  6. Exit");
        let choice = prompt("Choose an option (1-6): ");
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
            "6" | "" => return,
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
    let answer = prompt("Choose a number, or type the path of a Factorio folder or factorio.exe: ");
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
        println!("  {}. {}{}", i + 1, r.tag_name, if r.prerelease { " (pre-release)" } else { "" });
    }
    let n = cat.versions.len();
    if let Some(ci) = &cat.ci {
        println!("  {}. latest successful CI build ({}) -- untested, may be broken", n + 1, github::ci_build_label(ci));
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

fn install_from_files(f: &Factorio) {
    let m = PathBuf::from(prompt("Path to FactorioAccess_<version>.zip: ").trim_matches('"'));
    let n = PathBuf::from(prompt("Path to fa-native.zip: ").trim_matches('"'));
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
    if !prompt(&format!("Remove {}'s native code from {}? (y/N): ", APP_NAME, f.bin_dir.display())).eq_ignore_ascii_case("y") {
        return;
    }
    let remove_mod = prompt("Also remove the mod from the mods folder? (y/N): ").eq_ignore_ascii_case("y");
    match uninstall::uninstall(f, remove_mod) {
        Ok(removed) => {
            for p in &removed {
                println!("Removed {}", p.display());
            }
            println!("{} uninstalled.", APP_NAME);
        }
        Err(e) => println!("Error: {}", e),
    }
}
