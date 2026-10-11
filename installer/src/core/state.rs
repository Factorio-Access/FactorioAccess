//! What the installer remembers between runs: the Factorio install it last worked on, offered first next time.
use std::path::{Path, PathBuf};

use serde::{Deserialize, Serialize};

use super::paths::state_file;

#[derive(Debug, Default, Serialize, Deserialize, PartialEq)]
pub struct State {
    /// The install root last chosen (or installed into).
    #[serde(default)]
    pub factorio_root: Option<PathBuf>,
}

pub fn load_from(path: &Path) -> State {
    std::fs::read_to_string(path).ok().and_then(|t| serde_json::from_str(&t).ok()).unwrap_or_default()
}

pub fn save_to(path: &Path, state: &State) -> Result<(), String> {
    if let Some(dir) = path.parent() {
        std::fs::create_dir_all(dir).map_err(|e| format!("Failed to create {}: {}", dir.display(), e))?;
    }
    let text = serde_json::to_string_pretty(state).map_err(|e| e.to_string())?;
    std::fs::write(path, text).map_err(|e| format!("Failed to write {}: {}", path.display(), e))
}

pub fn load() -> State {
    load_from(&state_file())
}

/// Remember this install as the one to offer first.
pub fn remember(root: &Path) -> Result<(), String> {
    let mut s = load();
    s.factorio_root = Some(root.to_path_buf());
    save_to(&state_file(), &s)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn round_trip_and_garbage() {
        let p = std::env::temp_dir().join(format!("fa-installer-state-{}", std::process::id())).join("installer.json");
        assert_eq!(load_from(&p), State::default());
        let s = State { factorio_root: Some(PathBuf::from("D:\\Games\\Factorio")) };
        save_to(&p, &s).unwrap();
        assert_eq!(load_from(&p), s);
        std::fs::write(&p, "not json").unwrap();
        assert_eq!(load_from(&p), State::default());
        let _ = std::fs::remove_dir_all(p.parent().unwrap());
    }
}
