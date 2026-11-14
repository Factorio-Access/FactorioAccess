//! Names and the installer's own folder.
//!
//! On Windows everything the installer installs goes into the chosen Factorio install (the mod zip into its mods
//! folder, the DLLs next to factorio.exe); the only thing it keeps for itself is
//! `%LOCALAPPDATA%\FactorioAccess\installer.json` (the last Factorio install used), beside the native code's log.
//!
//! On the Mac the mod zip goes into the mods folder too, but nothing is written inside factorio.app (that would break
//! its code signature, and Steam would undo it): the libraries and the launcher go into
//! `~/Library/Application Support/FactorioAccess`, beside installer.json, and Steam's launch option starts the game
//! through them. The native code logs to `~/Library/Logs/FactorioAccess`.
use std::path::PathBuf;

pub const GITHUB_RELEASES_URL: &str = "https://api.github.com/repos/Factorio-Access/FactorioAccess/releases";
/// The rolling pre-release CI republishes (the "latest successful CI build" choice).
pub const CI_TAG: &str = "ci-latest";
/// The spoken name.
pub const APP_NAME: &str = "Factorio Access";
/// The mod's internal name: info.json `name`, the `FactorioAccess_<version>.zip` file and its top folder.
pub const MOD_NAME: &str = "FactorioAccess";
/// The release asset holding the native DLLs and version.txt (native/tools/package_native.py).
#[cfg(windows)]
pub const NATIVE_ZIP: &str = "fa-native.zip";
/// The release asset holding the Mac libraries, the launcher and version.txt (native/tools/package_native.py --mac).
#[cfg(not(windows))]
pub const NATIVE_ZIP: &str = "fa-native-macos.zip";
/// What goes next to factorio.exe. version.dll is the proxy the game loads; it starts fa_native.dll.
#[cfg(windows)]
pub const DLLS: [&str; 3] = ["version.dll", "fa_native.dll", "prism.dll"];
/// The native zip's files that are installed, as paths relative to the native folder.
#[cfg(windows)]
pub const NATIVE_FILES: &[&str] = &DLLS;
/// launch.sh starts the game with libfa_native.dylib inserted; FactorioAccess.app is what Steam's launch option
/// names, because Steam opens a bundle natively but would run a script under Rosetta (launch.sh's header).
#[cfg(not(windows))]
pub const NATIVE_FILES: &[&str] =
    &["libfa_native.dylib", "libprism.dylib", "launch.sh", "FactorioAccess.app/Contents/Info.plist", "FactorioAccess.app/Contents/MacOS/launch"];
/// Written next to the native files: the release they came from ("v0.16.57" or "ci-<sha>").
pub const VERSION_FILE: &str = "factorio-access-version.txt";

#[cfg(windows)]
fn local_app_data() -> PathBuf {
    dirs::data_local_dir().unwrap_or_else(|| PathBuf::from("C:\\Users\\Default\\AppData\\Local"))
}

/// %LOCALAPPDATA%\FactorioAccess (the native code's log lives here too).
#[cfg(windows)]
pub fn data_dir() -> PathBuf {
    local_app_data().join("FactorioAccess")
}

/// %APPDATA%\Factorio: Factorio's `__PATH__system-write-data__`.
#[cfg(windows)]
pub fn system_write_data() -> PathBuf {
    dirs::config_dir().unwrap_or_else(|| PathBuf::from("C:\\Users\\Default\\AppData\\Roaming")).join("Factorio")
}

/// $HOME (which dirs reads first), so a test run can point the whole installer at a fake home.
#[cfg(not(windows))]
pub fn home() -> PathBuf {
    dirs::home_dir().unwrap_or_else(|| PathBuf::from("/"))
}

#[cfg(not(windows))]
fn application_support() -> PathBuf {
    home().join("Library").join("Application Support")
}

/// ~/Library/Application Support/FactorioAccess: the native files, the launcher and installer.json.
#[cfg(not(windows))]
pub fn data_dir() -> PathBuf {
    application_support().join("FactorioAccess")
}

/// ~/Library/Application Support/factorio: Factorio's `__PATH__system-write-data__`.
#[cfg(not(windows))]
pub fn system_write_data() -> PathBuf {
    application_support().join("factorio")
}

/// Steam's own folder, which is also its default library.
#[cfg(not(windows))]
pub fn steam_dir() -> PathBuf {
    application_support().join("Steam")
}

/// Where the native code writes native.log.
#[cfg(not(windows))]
pub fn log_dir() -> PathBuf {
    home().join("Library").join("Logs").join("FactorioAccess")
}

pub fn state_file() -> PathBuf {
    data_dir().join("installer.json")
}

#[cfg(all(test, not(windows)))]
mod tests {
    use super::*;

    #[test]
    fn mac_folders_are_under_home() {
        let lib = home().join("Library");
        assert_eq!(data_dir(), lib.join("Application Support/FactorioAccess"));
        assert_eq!(state_file(), lib.join("Application Support/FactorioAccess/installer.json"));
        assert_eq!(system_write_data(), lib.join("Application Support/factorio"));
        assert_eq!(steam_dir(), lib.join("Application Support/Steam"));
        assert_eq!(log_dir(), lib.join("Logs/FactorioAccess"));
    }

    #[test]
    fn mac_native_files_are_the_zips_minus_version_txt() {
        assert!(NATIVE_FILES.contains(&"libfa_native.dylib"));
        assert!(NATIVE_FILES.contains(&"FactorioAccess.app/Contents/MacOS/launch"));
        assert!(!NATIVE_FILES.contains(&"version.txt"));
    }
}
