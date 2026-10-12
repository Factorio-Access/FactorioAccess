//! The mod's recommended config.ini changes, understood exactly as the Python launcher does
//! (factorio-access-launcher: modify_config.py `get_changes_from_fp` / `get_all_changes` / `do_config_check`, and
//! config.py's `Conf_Editor`), so the launcher and the installer never re-apply each other's sets.
//!
//! - A change set is `config_changes/XX_name.ini` in the mod, XX two capital letters; sets apply in XX order.
//! - In a set, `;` lines are a comment that attaches to the next `key=value` line; any other line (blank, a
//!   `[section]` header) drops a pending comment. Settings before any header belong to the "" section.
//! - The level already applied is `[controls]` `access-config-version1-DO-NOT-EDIT` + `...version2...` (one letter
//!   each); either missing means "AA" (nothing applied), and the legacy value "Ch" means "AE".
//! - config.ini is edited in place, as text: a setting's line is replaced, else its commented-out default
//!   (`; key=value`, which Factorio writes for settings left at their default), else it is appended to its section.
//!   Everything else in the file (comments, order, other settings) is kept byte for byte.
use std::collections::BTreeMap;
use std::path::Path;

pub const MARKER_1: &str = "access-config-version1-DO-NOT-EDIT";
pub const MARKER_2: &str = "access-config-version2-DO-NOT-EDIT";

#[derive(Debug, Clone, PartialEq)]
pub struct Setting {
    pub section: String,
    pub key: String,
    pub value: String,
    /// The `;` lines above it, verbatim (each without its `;`, newline-terminated), as the launcher keeps them.
    pub comment: String,
}

#[derive(Debug, Clone, PartialEq)]
pub struct ChangeSet {
    /// "AB", "AC", ...
    pub version: String,
    pub settings: Vec<Setting>,
}

fn is_key_char(c: char) -> bool {
    c.is_alphanumeric() || c == '_' || c == '-'
}

/// `get_changes_from_fp`: settings in first-seen order per section, sections in first-seen order. A key repeated in
/// one section keeps its first position and takes the last value and comment (Python dict assignment).
pub fn parse_change_set(text: &str) -> Vec<Setting> {
    let mut sections: Vec<(String, Vec<Setting>)> = vec![(String::new(), Vec::new())];
    let mut current = 0usize;
    let mut comment = String::new();
    for raw in text.split_inclusive('\n') {
        // Python reads the file in text mode: "\r\n" arrives as "\n".
        let line = raw.strip_suffix("\r\n").map(|l| format!("{}\n", l)).unwrap_or_else(|| raw.to_string());
        if line.is_empty() {
            continue;
        }
        if let Some(rest) = line.strip_prefix(';') {
            comment.push_str(rest);
            continue;
        }
        if line.starts_with('[') {
            let name = line.trim_matches(|c| matches!(c, '[' | ']' | ' ' | '\t' | '\r' | '\n')).to_string();
            current = match sections.iter().position(|(n, _)| *n == name) {
                Some(i) => i,
                None => {
                    sections.push((name, Vec::new()));
                    sections.len() - 1
                }
            };
        }
        // config_re = ^([\w-]+)=(.*)  ('.' stops at the newline)
        let body = line.strip_suffix('\n').unwrap_or(&line);
        if let Some(eq) = body.find('=') {
            let key = &body[..eq];
            if !key.is_empty() && key.chars().all(is_key_char) {
                let (section_name, list) = &mut sections[current];
                let s = Setting { section: section_name.clone(), key: key.to_string(), value: body[eq + 1..].to_string(), comment: comment.clone() };
                match list.iter_mut().find(|e| e.key == key) {
                    Some(existing) => *existing = s,
                    None => list.push(s),
                }
            }
        }
        comment.clear();
    }
    sections.into_iter().flat_map(|(_, l)| l).collect()
}

/// `get_all_changes(after)`: the sets newer than `after`, in order. `files` are (file name, contents) of the mod's
/// `config_changes/*.ini`. A newer set whose name does not start with two capital letters is an error, as in the
/// launcher.
pub fn change_sets_after(files: &[(String, String)], after: &str) -> Result<Vec<ChangeSet>, String> {
    let mut sets: BTreeMap<String, ChangeSet> = BTreeMap::new();
    for (name, text) in files {
        let version: String = name.chars().take(2).collect();
        if version.as_str() <= after {
            continue;
        }
        if !(version.len() == 2 && version.chars().all(|c| c.is_ascii_uppercase())) {
            return Err(format!("configuration change set {} must begin with two capital letters", name));
        }
        sets.insert(version.clone(), ChangeSet { version, settings: parse_change_set(text) });
    }
    Ok(sets.into_values().collect())
}

/// config.ini as the launcher's Conf_Editor holds it: the preamble ("" section), then each section's text from its
/// header line to the next header.
#[derive(Debug, Clone, PartialEq)]
pub struct ConfigIni {
    sections: Vec<(String, String)>,
}

/// `^[ \t]*\[([^\r\n\]]+)\]`
fn header_name(line: &str) -> Option<&str> {
    let rest = line.trim_start_matches([' ', '\t']).strip_prefix('[')?;
    let end = rest.find([']', '\r', '\n'])?;
    (end > 0 && rest[end..].starts_with(']')).then(|| &rest[..end])
}

/// The value part of `^[ \t]*(;[ \t]*)?key[ \t]*=(.*)$` on one line (without its line ending).
fn match_setting<'a>(line: &'a str, key: &str, commented: bool) -> Option<&'a str> {
    let mut rest = line.trim_start_matches([' ', '\t']);
    if commented {
        rest = rest.strip_prefix(';')?.trim_start_matches([' ', '\t']);
    }
    let rest = rest.strip_prefix(key)?.trim_start_matches([' ', '\t']);
    rest.strip_prefix('=')
}

fn split_ending(line: &str) -> (&str, &str) {
    if let Some(b) = line.strip_suffix("\r\n") {
        (b, "\r\n")
    } else if let Some(b) = line.strip_suffix('\n') {
        (b, "\n")
    } else {
        (line, "")
    }
}

impl ConfigIni {
    pub fn parse(text: &str) -> ConfigIni {
        let mut sections = vec![(String::new(), String::new())];
        for line in text.split_inclusive('\n') {
            if let Some(name) = header_name(line) {
                sections.push((name.to_string(), String::new()));
            }
            sections.last_mut().unwrap().1.push_str(line);
        }
        ConfigIni { sections }
    }

    pub fn text(&self) -> String {
        self.sections.iter().map(|(_, t)| t.as_str()).collect()
    }

    /// The section's text, the last one if the name repeats (Python's dict keeps the last assignment).
    fn section(&self, name: &str) -> Option<usize> {
        self.sections.iter().rposition(|(n, _)| n == name)
    }

    /// `get_setting`: the setting's value, else its commented-out default's, trimmed.
    pub fn get(&self, section: &str, key: &str) -> Option<String> {
        let text = &self.sections[self.section(section)?].1;
        for commented in [false, true] {
            for line in text.split_inclusive('\n') {
                if let Some(v) = match_setting(split_ending(line).0, key, commented) {
                    return Some(v.trim().to_string());
                }
            }
        }
        None
    }

    /// `set_setting(..., force=True)`.
    pub fn set(&mut self, section: &str, key: &str, value: &str) -> Result<(), String> {
        let idx = match self.section(section) {
            Some(i) => i,
            None => {
                self.sections.push((section.to_string(), format!("[{}]\n", section)));
                self.sections.len() - 1
            }
        };
        let replacement = format!("{}={}", key, value.trim());
        let text = &mut self.sections[idx].1;
        let lines: Vec<&str> = text.split_inclusive('\n').collect();
        let plain: Vec<usize> = (0..lines.len()).filter(|&i| match_setting(split_ending(lines[i]).0, key, false).is_some()).collect();
        if plain.len() > 1 {
            return Err(format!("Duplicate setting [{}] found in section [{}]", key, section));
        }
        let target = plain.first().copied().or_else(|| (0..lines.len()).find(|&i| match_setting(split_ending(lines[i]).0, key, true).is_some()));
        let new_text = match target {
            Some(t) => lines
                .iter()
                .enumerate()
                .map(|(i, l)| if i == t { format!("{}{}", replacement, split_ending(l).1) } else { l.to_string() })
                .collect(),
            None => {
                let mut s = text.clone();
                if !s.is_empty() && !s.ends_with('\n') {
                    s.push('\n');
                }
                s.push_str(&replacement);
                s.push('\n');
                s
            }
        };
        *text = new_text;
        Ok(())
    }
}

/// `do_config_check`'s reading of the applied level.
pub fn current_level(ini: &ConfigIni) -> String {
    let level = match (ini.get("controls", MARKER_1), ini.get("controls", MARKER_2)) {
        (Some(a), Some(b)) => a + &b,
        _ => "AA".to_string(),
    };
    if level == "Ch" {
        "AE".to_string()
    } else {
        level
    }
}

/// One setting the player is asked about.
#[derive(Debug, Clone, PartialEq)]
pub struct Pending {
    pub set: String,
    pub section: String,
    pub key: String,
    /// "unknown" when config.ini does not have it at all, as the launcher says.
    pub current: String,
    pub suggested: String,
}

/// Applies the sets in order (each set's settings, then its level marker), as "Approve all" does. Returns what
/// changed, with the value each had just before.
pub fn apply(ini: &mut ConfigIni, sets: &[ChangeSet]) -> Result<Vec<Pending>, String> {
    let mut changed = Vec::new();
    for set in sets {
        for s in &set.settings {
            let current = ini.get(&s.section, &s.key).unwrap_or_else(|| "unknown".to_string());
            if current == s.value {
                continue;
            }
            changed.push(Pending {
                set: set.version.clone(),
                section: s.section.clone(),
                key: s.key.clone(),
                current,
                suggested: s.value.clone(),
            });
            ini.set(&s.section, &s.key, &s.value)?;
        }
        let mut letters = set.version.chars();
        ini.set("controls", MARKER_1, &letters.next().unwrap().to_string())?;
        ini.set("controls", MARKER_2, &letters.next().unwrap().to_string())?;
    }
    Ok(changed)
}

/// What a config.ini needs from a mod's change sets.
#[derive(Debug, Clone)]
pub struct Check {
    pub level: String,
    pub sets: Vec<ChangeSet>,
    /// The settings that would change (on a copy: a later set seeing an earlier one's value, as when applying).
    pub pending: Vec<Pending>,
}

pub fn check_text(config_text: &str, files: &[(String, String)]) -> Result<Check, String> {
    let ini = ConfigIni::parse(config_text);
    let level = current_level(&ini);
    let sets = change_sets_after(files, &level)?;
    let pending = apply(&mut ini.clone(), &sets)?;
    Ok(Check { level, sets, pending })
}

pub fn check_file(config_ini: &Path, files: &[(String, String)]) -> Result<Check, String> {
    let text = std::fs::read_to_string(config_ini).map_err(|e| format!("Failed to read {}: {}", config_ini.display(), e))?;
    check_text(&text, files)
}

/// Applies the sets to config.ini on disk: a backup beside it first (config.ini.fa-backup), then the new text written
/// to a temporary file and moved over the original.
pub fn apply_file(config_ini: &Path, sets: &[ChangeSet]) -> Result<Vec<Pending>, String> {
    let text = std::fs::read_to_string(config_ini).map_err(|e| format!("Failed to read {}: {}", config_ini.display(), e))?;
    let mut ini = ConfigIni::parse(&text);
    let changed = apply(&mut ini, sets)?;
    let backup = config_ini.with_extension("ini.fa-backup");
    std::fs::write(&backup, &text).map_err(|e| format!("Failed to back up config.ini to {}: {}", backup.display(), e))?;
    let tmp = config_ini.with_extension("ini.fa-new");
    std::fs::write(&tmp, ini.text()).map_err(|e| format!("Failed to write {}: {}", tmp.display(), e))?;
    std::fs::rename(&tmp, config_ini).map_err(|e| format!("Failed to replace {}: {}", config_ini.display(), e))?;
    Ok(changed)
}

/// What the player is asked before the changes are applied: one yes/no for all of them, since the mod does not work
/// without them.
pub fn question() -> String {
    format!("There are pending changes to Factorio's settings that {} needs. Apply them?", crate::core::paths::APP_NAME)
}

#[cfg(test)]
mod tests {
    use super::*;

    /// The mod's real change sets (installer/../config_changes).
    fn real_sets() -> Vec<(String, String)> {
        let dir = Path::new(env!("CARGO_MANIFEST_DIR")).join("..").join("config_changes");
        let mut v: Vec<(String, String)> = std::fs::read_dir(&dir)
            .unwrap()
            .flatten()
            .filter(|e| e.file_name().to_string_lossy().ends_with(".ini"))
            .map(|e| (e.file_name().to_string_lossy().to_string(), std::fs::read_to_string(e.path()).unwrap()))
            .collect();
        v.sort();
        assert!(v.len() >= 4, "expected the AB..AE sets");
        v
    }

    fn find<'a>(sets: &'a [ChangeSet], version: &str) -> &'a ChangeSet {
        sets.iter().find(|s| s.version == version).unwrap()
    }

    #[test]
    fn parses_the_real_initial_set() {
        let sets = change_sets_after(&real_sets(), "AA").unwrap();
        let versions: Vec<_> = sets.iter().map(|s| s.version.as_str()).collect();
        assert_eq!(&versions[..4], ["AB", "AC", "AD", "AE"]);
        let ab = find(&sets, "AB");
        let check_updates = ab.settings.iter().find(|s| s.key == "check-updates").unwrap();
        assert_eq!(check_updates.section, "other");
        assert_eq!(check_updates.value, "false");
        assert_eq!(check_updates.comment, " Disable inaccessible autoupdater\n");
        // An empty value is a value (unbinding a key).
        let unbound = ab.settings.iter().find(|s| s.key == "toggle-map").unwrap();
        assert_eq!((unbound.section.as_str(), unbound.value.as_str()), ("controls", ""));
        assert_eq!(ab.settings.iter().find(|s| s.key == "toggle-menu").unwrap().value, "SHIFT + ESCAPE");
        // The [general] section has only a comment, which attaches to nothing.
        assert!(ab.settings.iter().all(|s| s.section != "general"));
        // A comment separated from its setting by a blank line is dropped.
        let tech = ab.settings.iter().find(|s| s.key == "controller-gui-logistics-tab").unwrap();
        assert_eq!(tech.comment, " F1 is used by the mod for manual saving\n");
        // AE: two sections in one file, each setting with its own comment.
        let ae = find(&sets, "AE");
        assert_eq!(ae.settings.len(), 2);
        assert!(ae.settings.iter().all(|s| s.section == "input" && s.value.is_empty()));
    }

    #[test]
    fn levels_filter_sets() {
        let files = real_sets();
        assert_eq!(change_sets_after(&files, "AE").unwrap().iter().filter(|s| s.version.as_str() <= "AE").count(), 0);
        let after_ac: Vec<_> = change_sets_after(&files, "AC").unwrap().into_iter().map(|s| s.version).collect();
        assert_eq!(&after_ac[..2], ["AD", "AE"]);
        let bad = vec![("zz_bad.ini".to_string(), String::new())];
        assert!(change_sets_after(&bad, "AE").is_err());
        assert!(change_sets_after(&[("AB_x.ini".into(), String::new())], "AE").unwrap().is_empty());
    }

    #[test]
    fn comment_rules() {
        let s = parse_change_set("; a\n; b\nk1=v1\n\n; dropped\n\nk2=v2\n[sec]\n; c\nk3= spaced \nk1=again\n[sec]\n; d\nk3=last\r\n");
        assert_eq!(s.len(), 4);
        assert_eq!((s[0].section.as_str(), s[0].key.as_str(), s[0].comment.as_str()), ("", "k1", " a\n b\n"));
        assert_eq!(s[1].comment, "");
        assert_eq!((s[2].section.as_str(), s[2].key.as_str(), s[2].value.as_str(), s[2].comment.as_str()), ("sec", "k3", "last", " d\n"));
        assert_eq!((s[3].key.as_str(), s[3].value.as_str()), ("k1", "again"));
        // Not settings: an indented key, a key with a dot.
        assert!(parse_change_set(" k=v\nk.x=v\n").is_empty());
    }

    const INI: &str = "; version=13\n; This is INI file\n[path]\nread-data=__PATH__executable__\\..\\..\\data\nwrite-data=__PATH__executable__\\..\\..\n\n[other]\n; check-updates=true\nenable-mod-settings-load-save-confirmation=true\n\n[controls]\nmove-up=W\n; toggle-map=M\n\n[sound]\n; music-volume=0.5\n";

    #[test]
    fn ini_get_set_keeps_everything_else() {
        let mut ini = ConfigIni::parse(INI);
        assert_eq!(ini.text(), INI);
        assert_eq!(ini.get("controls", "move-up").as_deref(), Some("W"));
        assert_eq!(ini.get("controls", "toggle-map").as_deref(), Some("M")); // the commented default
        assert_eq!(ini.get("controls", "move"), None); // a prefix is not a match
        assert_eq!(ini.get("nosuch", "x"), None);
        ini.set("controls", "move-up", "UP").unwrap();
        ini.set("controls", "toggle-map", "").unwrap();
        ini.set("controls", MARKER_1, "A").unwrap();
        ini.set("input", "pipette", "").unwrap();
        let text = ini.text();
        assert!(text.contains("[controls]\nmove-up=UP\ntoggle-map=\n\naccess-config-version1-DO-NOT-EDIT=A\n[sound]"));
        assert!(text.ends_with("[sound]\n; music-volume=0.5\n[input]\npipette=\n"));
        assert!(text.starts_with("; version=13\n; This is INI file\n[path]\nread-data="));
        let dup = ConfigIni::parse("[a]\nk=1\nk=2\n");
        assert!(dup.clone().set("a", "k", "3").is_err());
        // CRLF files keep their line endings.
        let mut crlf = ConfigIni::parse("[a]\r\nk=1\r\nj=2\r\n");
        crlf.set("a", "k", "3").unwrap();
        assert_eq!(crlf.text(), "[a]\r\nk=3\r\nj=2\r\n");
        assert_eq!(crlf.get("a", "j").as_deref(), Some("2"));
    }

    #[test]
    fn level_markers() {
        assert_eq!(current_level(&ConfigIni::parse(INI)), "AA");
        let only_one = "[controls]\naccess-config-version1-DO-NOT-EDIT=A\n";
        assert_eq!(current_level(&ConfigIni::parse(only_one)), "AA");
        let ae = "[controls]\naccess-config-version1-DO-NOT-EDIT=A\naccess-config-version2-DO-NOT-EDIT=E\n";
        assert_eq!(current_level(&ConfigIni::parse(ae)), "AE");
        let legacy = "[controls]\naccess-config-version1-DO-NOT-EDIT=C\naccess-config-version2-DO-NOT-EDIT=h\n";
        assert_eq!(current_level(&ConfigIni::parse(legacy)), "AE");
    }

    #[test]
    fn apply_real_sets_then_nothing_pending() {
        let files = real_sets();
        let check = check_text(INI, &files).unwrap();
        assert_eq!(check.level, "AA");
        let up = check.pending.iter().find(|p| p.key == "move-up").unwrap();
        assert_eq!((up.current.as_str(), up.suggested.as_str(), up.set.as_str()), ("W", "UP", "AB"));
        let upd = check.pending.iter().find(|p| p.key == "check-updates").unwrap();
        assert_eq!((upd.current.as_str(), upd.suggested.as_str()), ("true", "false"));
        let unknown = check.pending.iter().find(|p| p.key == "active-quick-bars").unwrap();
        assert_eq!(unknown.current, "unknown");

        let mut ini = ConfigIni::parse(INI);
        let changed = apply(&mut ini, &check.sets).unwrap();
        assert_eq!(changed, check.pending);
        let last = check.sets.last().unwrap().version.clone();
        assert_eq!(current_level(&ini), last);
        assert_eq!(ini.get("controls", "move-up").as_deref(), Some("UP"));
        assert_eq!(ini.get("input", "smart-pipette").as_deref(), Some(""));
        assert_eq!(ini.get("other", "check-updates").as_deref(), Some("false"));
        // The commented default was replaced, not duplicated.
        assert!(!ini.text().contains("; check-updates"));
        let again = check_text(&ini.text(), &files).unwrap();
        assert!(again.sets.is_empty() && again.pending.is_empty());
    }

    #[test]
    fn already_at_the_launchers_level() {
        // A config the launcher already brought to AE has nothing pending from AB..AE.
        let ini = format!("{}[controls]\n{}=A\n{}=E\n", INI, MARKER_1, MARKER_2);
        let check = check_text(&ini, &real_sets()).unwrap();
        assert_eq!(check.level, "AE");
        assert!(check.sets.iter().all(|s| s.version.as_str() > "AE"));
    }

    #[test]
    fn apply_file_backs_up_and_writes() {
        let dir = std::env::temp_dir().join(format!("fa-installer-ini-{}", std::process::id()));
        std::fs::create_dir_all(&dir).unwrap();
        let p = dir.join("config.ini");
        std::fs::write(&p, INI).unwrap();
        let check = check_file(&p, &real_sets()).unwrap();
        apply_file(&p, &check.sets).unwrap();
        assert_eq!(std::fs::read_to_string(dir.join("config.ini.fa-backup")).unwrap(), INI);
        assert!(check_file(&p, &real_sets()).unwrap().pending.is_empty());
        let _ = std::fs::remove_dir_all(dir);
    }
}
