//! Uninstall = the DLLs and the version file next to factorio.exe (a version.dll that is not our proxy is left
//! alone), and, if asked, the mod zips in the mods folder. config.ini keeps the recommended settings: they are the
//! player's settings now, and the launcher's level markers stay valid.
//!
//! On the Mac, the native files and the version file in the native folder, then the folders that leaves empty (not
//! the native folder while installer.json is in it). Steam's launch option is the caller's (`steam_launch`).
use std::fs;
use std::path::PathBuf;

use super::detect::{factorio_running, installed_mods};
use super::factorio::Factorio;
use super::install::is_our_proxy;
use super::paths::{NATIVE_FILES, VERSION_FILE};

pub fn uninstall(f: &Factorio, remove_mod: bool) -> Result<Vec<PathBuf>, String> {
    if factorio_running() {
        return Err("Factorio is running. Close it and try again.".into());
    }
    let mut removed = Vec::new();
    for name in NATIVE_FILES.iter().copied().chain([VERSION_FILE]) {
        let p = f.native_dir.join(name);
        if !p.exists() || (name == "version.dll" && !is_our_proxy(&p)) {
            continue;
        }
        fs::remove_file(&p).map_err(|e| format!("Could not remove {} -- close Factorio and try again ({})", p.display(), e))?;
        removed.push(p);
    }
    #[cfg(not(windows))]
    remove_empty_folders(f);
    if remove_mod {
        for z in installed_mods(f).0 {
            fs::remove_file(&z).map_err(|e| format!("Could not remove {}: {}", z.display(), e))?;
            removed.push(z);
        }
    }
    Ok(removed)
}

/// The native files' folders (FactorioAccess.app/Contents/MacOS ... the native folder itself), deepest first, each
/// only if empty.
#[cfg(not(windows))]
fn remove_empty_folders(f: &Factorio) {
    let folders: std::collections::BTreeSet<PathBuf> =
        NATIVE_FILES.iter().flat_map(|n| std::path::Path::new(n).ancestors().skip(1)).map(|a| f.native_dir.join(a)).collect();
    for d in folders.iter().rev() {
        let _ = fs::remove_dir(d);
    }
}
