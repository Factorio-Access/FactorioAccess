//! Uninstall = the DLLs and the version file next to factorio.exe (a version.dll that is not our proxy is left
//! alone), and, if asked, the mod zips in the mods folder. config.ini keeps the recommended settings: they are the
//! player's settings now, and the launcher's level markers stay valid.
use std::fs;
use std::path::PathBuf;

use super::detect::{factorio_running, installed_mods};
use super::factorio::Factorio;
use super::install::is_our_proxy;
use super::paths::{DLLS, VERSION_FILE};

pub fn uninstall(f: &Factorio, remove_mod: bool) -> Result<Vec<PathBuf>, String> {
    if factorio_running() {
        return Err("Factorio is running. Close it and try again.".into());
    }
    let mut removed = Vec::new();
    for name in DLLS.iter().copied().chain([VERSION_FILE]) {
        let p = f.bin_dir.join(name);
        if !p.exists() || (name == "version.dll" && !is_our_proxy(&p)) {
            continue;
        }
        fs::remove_file(&p).map_err(|e| format!("Could not remove {} -- close Factorio and try again ({})", p.display(), e))?;
        removed.push(p);
    }
    if remove_mod {
        for z in installed_mods(f).0 {
            fs::remove_file(&z).map_err(|e| format!("Could not remove {}: {}", z.display(), e))?;
            removed.push(z);
        }
    }
    Ok(removed)
}
