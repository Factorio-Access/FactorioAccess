//! One Factorio install and where its data lives, resolved the way the game (and the Python launcher's fa_paths.py)
//! does it:
//!
//! - `config-path.cfg` next to the install root names the config folder (`config-path=...`, with the game's
//!   `__PATH__executable__` / `__PATH__system-write-data__` / `__PATH__system-read-data__` tokens). Without that file
//!   the config is `%APPDATA%\Factorio\config` (the launcher's default).
//! - `config.ini`'s `write-data=` names the write-data folder (mods\ is inside it). Before the game has written a
//!   config.ini, `use-system-read-write-data-directories` in config-path.cfg decides: true (installer and Steam
//!   builds) is `%APPDATA%\Factorio`, false (the zip / portable build) is the install root itself.
use std::path::{Component, Path, PathBuf};

use super::paths::system_write_data;

#[derive(Debug, Clone, PartialEq)]
pub struct Factorio {
    /// The folder holding bin\, data\ and (for a portable install) config\ and mods\.
    pub root: PathBuf,
    /// bin\x64: factorio.exe, and where the DLLs go.
    pub bin_dir: PathBuf,
    pub config_ini: PathBuf,
    pub write_dir: PathBuf,
}

impl Factorio {
    pub fn mods_dir(&self) -> PathBuf {
        self.write_dir.join("mods")
    }

    /// From whatever the user pointed at: the install root, bin\x64, or factorio.exe itself.
    pub fn locate(p: &Path) -> Result<Factorio, String> {
        Self::locate_with(p, &system_write_data())
    }

    pub fn locate_with(p: &Path, system_write: &Path) -> Result<Factorio, String> {
        let p = normalize(p);
        let candidates = if p.file_name().map(|n| n.eq_ignore_ascii_case("factorio.exe")).unwrap_or(false) {
            vec![p.parent().and_then(Path::parent).and_then(Path::parent).map(Path::to_path_buf)]
        } else {
            vec![Some(p.clone()), p.parent().and_then(Path::parent).map(Path::to_path_buf)]
        };
        for root in candidates.into_iter().flatten() {
            if root.join("bin").join("x64").join("factorio.exe").is_file() {
                return Ok(resolve(&root, system_write));
            }
        }
        Err(format!("{} is not a Factorio install (no bin\\x64\\factorio.exe there)", p.display()))
    }
}

/// `..` and `.` removed lexically, both slash kinds accepted (the game's own paths mix them).
pub fn normalize(p: &Path) -> PathBuf {
    let mut out = PathBuf::new();
    let s = p.to_string_lossy().replace('/', "\\");
    for c in Path::new(&s).components() {
        match c {
            Component::ParentDir => {
                out.pop();
            }
            Component::CurDir => {}
            other => out.push(other.as_os_str()),
        }
    }
    out
}

/// A path from config-path.cfg or config.ini with the game's tokens replaced.
fn expand(value: &str, bin_dir: &Path, root: &Path, system_write: &Path) -> PathBuf {
    let v = value
        .trim()
        .replace("__PATH__executable__", &bin_dir.to_string_lossy())
        .replace("__PATH__system-write-data__", &system_write.to_string_lossy())
        .replace("__PATH__system-read-data__", &root.join("data").to_string_lossy());
    normalize(Path::new(&v))
}

/// The first `key=value` line's value (the launcher's `re.match(r"key=(.*)", line)`).
fn line_value<'a>(text: &'a str, key: &str) -> Option<&'a str> {
    text.lines().find_map(|l| l.strip_prefix(key).and_then(|r| r.strip_prefix('=')))
}

pub fn resolve(root: &Path, system_write: &Path) -> Factorio {
    let root = normalize(root);
    let bin_dir = root.join("bin").join("x64");
    let (config_dir, use_system) = match std::fs::read_to_string(root.join("config-path.cfg")) {
        Ok(text) => {
            let use_system = line_value(&text, "use-system-read-write-data-directories").map(|v| v.trim() == "true").unwrap_or(false);
            let dir = match line_value(&text, "config-path") {
                Some(v) => expand(v, &bin_dir, &root, system_write),
                None if use_system => system_write.join("config"),
                None => root.join("config"),
            };
            (dir, use_system)
        }
        Err(_) => (system_write.join("config"), true),
    };
    let config_ini = config_dir.join("config.ini");
    let write_dir = std::fs::read_to_string(&config_ini)
        .ok()
        .and_then(|text| line_value(&text, "write-data").map(|v| expand(v, &bin_dir, &root, system_write)))
        .unwrap_or_else(|| if use_system { system_write.to_path_buf() } else { root.clone() });
    Factorio { root, bin_dir, config_ini, write_dir }
}

#[cfg(test)]
pub mod tests {
    use super::*;

    /// A fake install in a fresh temp folder: bin\x64\factorio.exe plus the given config-path.cfg / config.ini.
    pub fn fake_install(name: &str, config_path_cfg: Option<&str>, config_ini: Option<(&str, &str)>) -> PathBuf {
        let root = std::env::temp_dir().join(format!("fa-installer-test-{}-{}", name, std::process::id()));
        let _ = std::fs::remove_dir_all(&root);
        std::fs::create_dir_all(root.join("bin").join("x64")).unwrap();
        std::fs::write(root.join("bin").join("x64").join("factorio.exe"), b"MZ").unwrap();
        if let Some(cfg) = config_path_cfg {
            std::fs::write(root.join("config-path.cfg"), cfg).unwrap();
        }
        if let Some((rel, text)) = config_ini {
            let p = root.join(rel);
            std::fs::create_dir_all(p.parent().unwrap()).unwrap();
            std::fs::write(p, text).unwrap();
        }
        root
    }

    const PORTABLE_CFG: &str = "config-path=__PATH__executable__/../../config\n\n#comment\nuse-system-read-write-data-directories=false\n";
    const STEAM_CFG: &str = "config-path=__PATH__system-write-data__/config\nuse-system-read-write-data-directories=true\n";

    #[test]
    fn portable_install_uses_its_own_folder() {
        let ini = "; version=13\n[path]\nread-data=__PATH__executable__\\..\\..\\data\nwrite-data=__PATH__executable__\\..\\..\n";
        let root = fake_install("portable", Some(PORTABLE_CFG), Some(("config/config.ini", ini)));
        let sys = Path::new("C:\\Users\\x\\AppData\\Roaming\\Factorio");
        for pointed in [root.clone(), root.join("bin").join("x64"), root.join("bin").join("x64").join("factorio.exe")] {
            let f = Factorio::locate_with(&pointed, sys).unwrap();
            assert_eq!(f.root, normalize(&root));
            assert_eq!(f.config_ini, normalize(&root.join("config").join("config.ini")));
            assert_eq!(f.write_dir, normalize(&root));
            assert_eq!(f.mods_dir(), normalize(&root.join("mods")));
        }
        let _ = std::fs::remove_dir_all(root);
    }

    #[test]
    fn portable_before_first_run_falls_back_to_the_flag() {
        let root = fake_install("fresh", Some(PORTABLE_CFG), None);
        let sys = Path::new("C:\\sys\\Factorio");
        let f = Factorio::locate_with(&root, sys).unwrap();
        assert_eq!(f.write_dir, normalize(&root));
        let _ = std::fs::remove_dir_all(root);
    }

    #[test]
    fn steam_install_uses_appdata() {
        let root = fake_install("steam", Some(STEAM_CFG), None);
        let sys = Path::new("C:\\Users\\x\\AppData\\Roaming\\Factorio");
        let f = Factorio::locate_with(&root, sys).unwrap();
        assert_eq!(f.config_ini, sys.join("config").join("config.ini"));
        assert_eq!(f.write_dir, sys.to_path_buf());
        assert_eq!(f.mods_dir(), sys.join("mods"));
        let _ = std::fs::remove_dir_all(root);
    }

    #[test]
    fn no_config_path_cfg_means_system_dirs() {
        let root = fake_install("nocfg", None, None);
        let sys = Path::new("C:\\sys\\Factorio");
        let f = Factorio::locate_with(&root, sys).unwrap();
        assert_eq!(f.config_ini, sys.join("config").join("config.ini"));
        assert_eq!(f.write_dir, sys.to_path_buf());
        let _ = std::fs::remove_dir_all(root);
    }

    #[test]
    fn not_an_install() {
        let dir = std::env::temp_dir().join(format!("fa-installer-test-empty-{}", std::process::id()));
        std::fs::create_dir_all(&dir).unwrap();
        assert!(Factorio::locate_with(&dir, Path::new("C:\\sys")).is_err());
        let _ = std::fs::remove_dir_all(dir);
    }

    #[test]
    fn normalize_mixed_slashes() {
        assert_eq!(normalize(Path::new("D:\\f\\bin\\x64/../..")), PathBuf::from("D:\\f"));
        assert_eq!(normalize(Path::new("D:/f/./config")), PathBuf::from("D:\\f\\config"));
    }
}
