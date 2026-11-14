//! Factorio's Steam launch option on the Mac, which starts the game through FactorioAccess.app (launch.sh's header
//! says why a bundle). Steam keeps it per account, in `userdata/<id>/config/localconfig.vdf` under
//! UserLocalConfigStore > Software > Valve > Steam > apps > 427520 > LaunchOptions, and rewrites that file from
//! memory when it quits. So the file is edited only while Steam is not running; otherwise the user pastes the line
//! into Steam.
use std::fs;
use std::path::{Path, PathBuf};

use super::detect::STEAM_APP_ID;
use super::vdf;

const BUNDLE: &str = "FactorioAccess.app";

const OPTION_PATH: [&str; 7] = ["UserLocalConfigStore", "Software", "Valve", "Steam", "apps", STEAM_APP_ID, "LaunchOptions"];

/// `"<native dir>/FactorioAccess.app" %command%`: quoted, as the folder name has a space.
pub fn line(native_dir: &Path) -> String {
    format!("\"{}\" %command%", native_dir.join(BUNDLE).display())
}

/// Whether a launch option is one this installer wrote (for this home or another), so it may be replaced or cleared
/// without asking.
pub fn is_ours(option: &str) -> bool {
    option.trim().ends_with(&format!("/FactorioAccess/{}\" %command%", BUNDLE))
}

pub fn steam_running() -> bool {
    super::process::named("steam_osx")
}

/// One Steam account on this Mac and Factorio's launch option there ("" when it has none).
#[derive(Debug, PartialEq)]
pub struct Account {
    pub id: String,
    pub file: PathBuf,
    pub current: String,
}

/// Every account under `<steam>/userdata` that has a localconfig.vdf, by id.
pub fn accounts(steam_dir: &Path) -> Result<Vec<Account>, String> {
    let mut out = Vec::new();
    let Ok(rd) = fs::read_dir(steam_dir.join("userdata")) else { return Ok(out) };
    for e in rd.flatten() {
        let file = e.path().join("config").join("localconfig.vdf");
        if !file.is_file() {
            continue;
        }
        let text = fs::read_to_string(&file).map_err(|err| format!("Failed to read {}: {}", file.display(), err))?;
        let current = vdf::get(&text, &OPTION_PATH).map_err(|err| format!("{} is not a file Steam wrote: {}", file.display(), err))?.unwrap_or_default();
        out.push(Account { id: e.file_name().to_string_lossy().into_owned(), file, current });
    }
    out.sort_by(|a, b| a.id.cmp(&b.id));
    Ok(out)
}

/// Sets Factorio's launch option in one localconfig.vdf, after a backup beside it (localconfig.vdf.fa-backup).
/// Call only while Steam is not running.
pub fn set(file: &Path, option: &str) -> Result<(), String> {
    let text = fs::read_to_string(file).map_err(|e| format!("Failed to read {}: {}", file.display(), e))?;
    let new = vdf::set(&text, &OPTION_PATH, option).map_err(|e| format!("{} is not a file Steam wrote: {}", file.display(), e))?;
    if new == text {
        return Ok(());
    }
    let backup = file.with_extension("vdf.fa-backup");
    fs::write(&backup, &text).map_err(|e| format!("Failed to back up {} to {}: {}", file.display(), backup.display(), e))?;
    fs::write(file, new).map_err(|e| format!("Failed to write {}: {}", file.display(), e))
}

/// Puts the text on the clipboard; false if pbcopy could not.
pub fn copy_to_clipboard(text: &str) -> bool {
    use std::io::Write;
    use std::process::{Command, Stdio};
    let Ok(mut child) = Command::new("pbcopy").stdin(Stdio::piped()).spawn() else { return false };
    let wrote = child.stdin.take().is_some_and(|mut stdin| stdin.write_all(text.as_bytes()).is_ok());
    child.wait().is_ok_and(|s| s.success()) && wrote
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn line_names_the_bundle_quoted() {
        let line = line(Path::new("/Users/x/Library/Application Support/FactorioAccess"));
        assert_eq!(line, "\"/Users/x/Library/Application Support/FactorioAccess/FactorioAccess.app\" %command%");
        assert!(is_ours(&line));
        assert!(is_ours("\"/Users/old/Library/Application Support/FactorioAccess/FactorioAccess.app\" %command% "));
        assert!(!is_ours(""));
        assert!(!is_ours("-novid %command%"));
        assert!(!is_ours("\"/Users/x/Other.app\" %command%"));
    }

    #[test]
    fn accounts_and_set_with_backup() {
        let steam = std::env::temp_dir().join(format!("fa-installer-test-steam-{}", std::process::id()));
        let _ = fs::remove_dir_all(&steam);
        let with_option = "\"UserLocalConfigStore\"\n{\n\t\"Software\"\n\t{\n\t\t\"Valve\"\n\t\t{\n\t\t\t\"Steam\"\n\t\t\t{\n\t\t\t\t\"apps\"\n\t\t\t\t{\n\t\t\t\t\t\"427520\"\n\t\t\t\t\t{\n\t\t\t\t\t\t\"LaunchOptions\"\t\t\"-old\"\n\t\t\t\t\t}\n\t\t\t\t}\n\t\t\t}\n\t\t}\n\t}\n}\n";
        let without = "\"UserLocalConfigStore\"\n{\n\t\"Software\"\n\t{\n\t\t\"Valve\"\n\t\t{\n\t\t\t\"Steam\"\n\t\t\t{\n\t\t\t}\n\t\t}\n\t}\n}\n";
        for (id, text) in [("222", Some(with_option)), ("111", Some(without)), ("333", None)] {
            let dir = steam.join("userdata").join(id).join("config");
            fs::create_dir_all(&dir).unwrap();
            if let Some(t) = text {
                fs::write(dir.join("localconfig.vdf"), t).unwrap();
            }
        }
        let found = accounts(&steam).unwrap();
        assert_eq!(found.iter().map(|a| (a.id.as_str(), a.current.as_str())).collect::<Vec<_>>(), vec![("111", ""), ("222", "-old")]);

        let ours = line(&steam.join("FactorioAccess"));
        for a in &found {
            set(&a.file, &ours).unwrap();
        }
        assert!(accounts(&steam).unwrap().iter().all(|a| a.current == ours));
        let backup = found[1].file.with_file_name("localconfig.vdf.fa-backup");
        assert_eq!(fs::read_to_string(backup).unwrap(), with_option);

        set(&found[1].file, "").unwrap();
        assert_eq!(accounts(&steam).unwrap()[1].current, "");
        assert!(accounts(&steam.join("nothing")).unwrap().is_empty());
        fs::write(&found[0].file, "\"UserLocalConfigStore\" {").unwrap();
        assert!(accounts(&steam).is_err());
        let _ = fs::remove_dir_all(steam);
    }
}
