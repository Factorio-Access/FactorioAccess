//! Names and the installer's own folder. Everything the installer installs goes into the chosen Factorio install
//! (the mod zip into its mods folder, the DLLs next to factorio.exe); the only thing it keeps for itself is
//! `%LOCALAPPDATA%\FactorioAccess\installer.json` (the last Factorio install used), beside the native code's log.
use std::path::PathBuf;

pub const GITHUB_RELEASES_URL: &str = "https://api.github.com/repos/Factorio-Access/FactorioAccess/releases";
/// The rolling pre-release CI republishes (the "latest successful CI build" choice).
pub const CI_TAG: &str = "ci-latest";
/// The spoken name.
pub const APP_NAME: &str = "Factorio Access";
/// The mod's internal name: info.json `name`, the `FactorioAccess_<version>.zip` file and its top folder.
pub const MOD_NAME: &str = "FactorioAccess";
/// The release asset holding the native DLLs and version.txt (native/tools/package_native.py).
pub const NATIVE_ZIP: &str = "fa-native.zip";
/// What goes next to factorio.exe. version.dll is the proxy the game loads; it starts fa_native.dll.
pub const DLLS: [&str; 3] = ["version.dll", "fa_native.dll", "prism.dll"];
/// Written next to the DLLs: the release they came from ("v0.16.57" or "ci-<sha>").
pub const VERSION_FILE: &str = "factorio-access-version.txt";

fn local_app_data() -> PathBuf {
    dirs::data_local_dir().unwrap_or_else(|| PathBuf::from("C:\\Users\\Default\\AppData\\Local"))
}

/// %LOCALAPPDATA%\FactorioAccess (the native code's log lives here too).
pub fn data_dir() -> PathBuf {
    local_app_data().join("FactorioAccess")
}

pub fn state_file() -> PathBuf {
    data_dir().join("installer.json")
}

/// %APPDATA%\Factorio: Factorio's `__PATH__system-write-data__`.
pub fn system_write_data() -> PathBuf {
    dirs::config_dir().unwrap_or_else(|| PathBuf::from("C:\\Users\\Default\\AppData\\Roaming")).join("Factorio")
}
