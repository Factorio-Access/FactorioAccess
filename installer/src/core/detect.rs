//! What is on this machine: the Factorio installs worth offering (the remembered one first, then Steam's, then the
//! usual folders and the installer's own neighbourhood) and what Factorio Access version an install has.
use std::path::{Path, PathBuf};

use super::factorio::{normalize, Factorio};
use super::paths::{DLLS, VERSION_FILE};
use super::state;

const STEAM_APP_ID: &str = "427520";

/// Every `"key"  "value"` occurrence in a Valve KeyValues text file, with `\\` unescaped.
pub fn vdf_values(text: &str, key: &str) -> Vec<String> {
    let needle = format!("\"{}\"", key);
    let mut out = Vec::new();
    let mut rest = text;
    while let Some(i) = rest.find(&needle) {
        rest = &rest[i + needle.len()..];
        let Some(q1) = rest.find('"') else { break };
        let Some(q2) = rest[q1 + 1..].find('"') else { break };
        out.push(rest[q1 + 1..q1 + 1 + q2].replace("\\\\", "\\"));
        rest = &rest[q1 + 1 + q2 + 1..];
    }
    out
}

fn steam_path() -> Option<PathBuf> {
    use winreg::enums::HKEY_CURRENT_USER;
    use winreg::RegKey;
    let key = RegKey::predef(HKEY_CURRENT_USER).open_subkey("Software\\Valve\\Steam").ok()?;
    let s: String = key.get_value("SteamPath").ok()?;
    Some(PathBuf::from(s.replace('/', "\\")))
}

/// Factorio's root in the Steam library whose steamapps\ holds the app's manifest.
fn steam_root() -> Option<PathBuf> {
    let steam = steam_path()?;
    let mut libs = vec![steam.clone()];
    if let Ok(text) = std::fs::read_to_string(steam.join("steamapps").join("libraryfolders.vdf")) {
        libs.extend(vdf_values(&text, "path").into_iter().map(PathBuf::from));
    }
    for lib in libs {
        let manifest = lib.join("steamapps").join(format!("appmanifest_{}.acf", STEAM_APP_ID));
        let Ok(text) = std::fs::read_to_string(&manifest) else { continue };
        let Some(dir) = vdf_values(&text, "installdir").into_iter().next() else { continue };
        return Some(lib.join("steamapps").join("common").join(dir));
    }
    None
}

/// Installs to offer, best first, without duplicates: the remembered one, Steam's, the standalone installer's and
/// GOG's default folders, and the folder this installer was started from or its parent (a portable install).
pub fn candidates() -> Vec<Factorio> {
    let mut roots: Vec<PathBuf> = Vec::new();
    if let Some(r) = state::load().factorio_root {
        roots.push(r);
    }
    if let Some(r) = steam_root() {
        roots.push(r);
    }
    for var in ["ProgramFiles", "ProgramFiles(x86)"] {
        if let Ok(pf) = std::env::var(var) {
            roots.push(Path::new(&pf).join("Factorio"));
            roots.push(Path::new(&pf).join("Steam").join("steamapps").join("common").join("Factorio"));
            roots.push(Path::new(&pf).join("GOG Galaxy").join("Games").join("Factorio"));
        }
    }
    if let Some(dir) = std::env::current_exe().ok().and_then(|e| e.parent().map(Path::to_path_buf)) {
        roots.push(dir.clone());
        if let Some(parent) = dir.parent() {
            roots.push(parent.to_path_buf());
        }
    }
    let mut out: Vec<Factorio> = Vec::new();
    for r in roots {
        if let Ok(f) = Factorio::locate(&r) {
            if !out.iter().any(|o| same_path(&o.root, &f.root)) {
                out.push(f);
            }
        }
    }
    out
}

pub fn same_path(a: &Path, b: &Path) -> bool {
    normalize(a).to_string_lossy().eq_ignore_ascii_case(&normalize(b).to_string_lossy())
}

/// Whether this install has the native code (the DLLs next to factorio.exe).
pub fn is_installed(f: &Factorio) -> bool {
    DLLS.iter().any(|d| f.bin_dir.join(d).exists()) && f.bin_dir.join(VERSION_FILE).exists()
}

/// The installed version: what the installer wrote next to the DLLs ("v0.16.57" or "ci-<sha>").
pub fn installed_version(f: &Factorio) -> Option<String> {
    let text = std::fs::read_to_string(f.bin_dir.join(VERSION_FILE)).ok()?;
    let v = text.lines().next()?.trim();
    (!v.is_empty()).then(|| v.to_string())
}

/// The mod zips (FactorioAccess_<version>.zip) and mod folders in the install's mods folder.
pub fn installed_mods(f: &Factorio) -> (Vec<PathBuf>, Vec<PathBuf>) {
    let mut zips = Vec::new();
    let mut dirs = Vec::new();
    if let Ok(rd) = std::fs::read_dir(f.mods_dir()) {
        for e in rd.flatten() {
            let name = e.file_name().to_string_lossy().to_string();
            let p = e.path();
            if p.is_dir() && (name == super::paths::MOD_NAME || name.starts_with(&format!("{}_", super::paths::MOD_NAME))) {
                dirs.push(p);
            } else if p.is_file() && name.starts_with(&format!("{}_", super::paths::MOD_NAME)) && name.to_ascii_lowercase().ends_with(".zip") {
                zips.push(p);
            }
        }
    }
    zips.sort();
    dirs.sort();
    (zips, dirs)
}

/// Whether a factorio.exe is running (any install: they share nothing we write, but one running from this install
/// holds the DLLs open and rewrites config.ini on exit, and telling them apart is not worth the risk).
pub fn factorio_running() -> bool {
    #[cfg(windows)]
    unsafe {
        use windows::Win32::Foundation::CloseHandle;
        use windows::Win32::System::Diagnostics::ToolHelp::{CreateToolhelp32Snapshot, Process32FirstW, Process32NextW, PROCESSENTRY32W, TH32CS_SNAPPROCESS};
        let Ok(snap) = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0) else { return false };
        let mut entry = PROCESSENTRY32W { dwSize: std::mem::size_of::<PROCESSENTRY32W>() as u32, ..Default::default() };
        let mut found = false;
        let mut ok = Process32FirstW(snap, &mut entry).is_ok();
        while ok {
            let len = entry.szExeFile.iter().position(|&c| c == 0).unwrap_or(entry.szExeFile.len());
            if String::from_utf16_lossy(&entry.szExeFile[..len]).eq_ignore_ascii_case("factorio.exe") {
                found = true;
                break;
            }
            ok = Process32NextW(snap, &mut entry).is_ok();
        }
        let _ = CloseHandle(snap);
        found
    }
    #[cfg(not(windows))]
    false
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn vdf_paths_unescape() {
        let text = "\"0\" { \"path\"\t\t\"C:\\\\Program Files (x86)\\\\Steam\" }\n\"1\" { \"path\"\t\t\"D:\\\\SteamLibrary\" }";
        let v = vdf_values(text, "path");
        assert_eq!(v, vec!["C:\\Program Files (x86)\\Steam", "D:\\SteamLibrary"]);
        assert!(vdf_values(text, "installdir").is_empty());
    }

    #[test]
    fn same_path_ignores_case_and_dots() {
        assert!(same_path(Path::new("D:\\Games\\Factorio"), Path::new("d:/games/factorio/bin/..")));
        assert!(!same_path(Path::new("D:\\Games\\Factorio"), Path::new("D:\\Games\\Factorio2")));
    }
}
