//! Install = one release's two halves into one Factorio install, so the mod and the native code always match:
//!
//! - the mod zip (`FactorioAccess_<version>.zip`, exactly as CI built and verified it) into the mods folder, older
//!   `FactorioAccess_*.zip` files removed, the mod enabled in mod-list.json;
//! - `fa-native.zip`'s three DLLs next to factorio.exe (bin\x64), plus a version file recording the release.
//!
//! The recommended config.ini changes are read from the mod zip being installed; applying them is the caller's
//! question to ask (`config_changes`). Nothing is touched while a factorio.exe is running.
use std::fs;
use std::io::{Cursor, Read};
use std::path::{Path, PathBuf};

use super::detect::{factorio_running, installed_mods};
use super::factorio::Factorio;
use super::paths::{DLLS, MOD_NAME, VERSION_FILE};

/// Progress as the worker sees it; the GUI shows it, the CLI prints it.
#[derive(Debug, Clone)]
pub enum Progress {
    Status(String),
    Percent(u32),
}

pub fn download_bytes(url: &str, progress: &dyn Fn(Progress)) -> Result<Vec<u8>, String> {
    let client = reqwest::blocking::Client::builder()
        .user_agent("FactorioAccessInstaller")
        .timeout(std::time::Duration::from_secs(300))
        .build()
        .map_err(|e| format!("Failed to create the HTTP client: {}", e))?;
    let mut resp = client.get(url).send().map_err(|e| format!("Download failed: {}", e))?;
    if !resp.status().is_success() {
        return Err(format!("Download returned status {}", resp.status()));
    }
    let total = resp.content_length().unwrap_or(0);
    let mut out = Vec::with_capacity(total as usize);
    let mut buf = [0u8; 64 * 1024];
    let mut last_pct = u32::MAX;
    loop {
        let n = resp.read(&mut buf).map_err(|e| format!("Download read error: {}", e))?;
        if n == 0 {
            break;
        }
        out.extend_from_slice(&buf[..n]);
        if total > 0 {
            let pct = (out.len() as u64 * 100 / total) as u32;
            if pct != last_pct {
                last_pct = pct;
                progress(Progress::Percent(pct));
            }
        }
    }
    Ok(out)
}

/// The mod zip, checked: its top folder is FactorioAccess_<version>/ and its info.json agrees.
pub struct ModZip {
    pub bytes: Vec<u8>,
    pub version: String,
    /// (file name, contents) of config_changes/*.ini.
    pub change_sets: Vec<(String, String)>,
}

impl ModZip {
    pub fn file_name(&self) -> String {
        format!("{}_{}.zip", MOD_NAME, self.version)
    }
}

pub fn read_mod_zip(bytes: Vec<u8>) -> Result<ModZip, String> {
    let mut archive = zip::ZipArchive::new(Cursor::new(&bytes)).map_err(|e| format!("The mod zip is not a valid zip: {}", e))?;
    let names: Vec<String> = archive.file_names().map(str::to_string).collect();
    let info_name = names
        .iter()
        .find(|n| n.starts_with(&format!("{}_", MOD_NAME)) && n.matches('/').count() == 1 && n.ends_with("/info.json"))
        .ok_or("The mod zip has no FactorioAccess_<version>/info.json -- is this a Factorio Access mod zip?")?
        .clone();
    let top = info_name.trim_end_matches("/info.json").to_string();
    let mut text = String::new();
    archive
        .by_name(&info_name)
        .map_err(|e| e.to_string())?
        .read_to_string(&mut text)
        .map_err(|e| format!("Failed to read info.json: {}", e))?;
    let info: serde_json::Value = serde_json::from_str(&text).map_err(|e| format!("info.json is not valid JSON: {}", e))?;
    let version = info["version"].as_str().unwrap_or("").to_string();
    if info["name"].as_str() != Some(MOD_NAME) || top != format!("{}_{}", MOD_NAME, version) {
        return Err(format!("The mod zip's info.json ({} {}) does not match its folder {}", info["name"], version, top));
    }
    let prefix = format!("{}/config_changes/", top);
    let mut change_sets = Vec::new();
    for n in &names {
        let Some(file) = n.strip_prefix(&prefix) else { continue };
        if file.contains('/') || !file.ends_with(".ini") {
            continue;
        }
        let mut s = String::new();
        archive.by_name(n).map_err(|e| e.to_string())?.read_to_string(&mut s).map_err(|e| format!("Failed to read {}: {}", n, e))?;
        change_sets.push((file.to_string(), s));
    }
    change_sets.sort();
    Ok(ModZip { bytes, version, change_sets })
}

/// The native zip, checked: the three DLLs and version.txt at its top level.
pub struct NativeZip {
    pub files: Vec<(String, Vec<u8>)>,
    pub version: String,
}

pub fn read_native_zip(bytes: &[u8]) -> Result<NativeZip, String> {
    let mut archive = zip::ZipArchive::new(Cursor::new(bytes)).map_err(|e| format!("The native zip is not a valid zip: {}", e))?;
    let mut read = |name: &str| -> Result<Vec<u8>, String> {
        let mut f = archive.by_name(name).map_err(|_| format!("The native zip has no {} -- is this a Factorio Access fa-native.zip?", name))?;
        let mut v = Vec::new();
        f.read_to_end(&mut v).map_err(|e| format!("Failed to read {}: {}", name, e))?;
        Ok(v)
    };
    let mut files = Vec::new();
    for d in DLLS {
        files.push((d.to_string(), read(d)?));
    }
    let version = String::from_utf8_lossy(&read("version.txt")?).lines().next().unwrap_or("").trim().to_string();
    if version.is_empty() {
        return Err("The native zip's version.txt is empty".into());
    }
    Ok(NativeZip { files, version })
}

/// Both halves of a GitHub release, downloaded and checked.
pub fn download_release(r: &super::github::ReleaseInfo, progress: &dyn Fn(Progress)) -> Result<(ModZip, NativeZip), String> {
    let mod_asset = super::github::mod_asset(r).ok_or("That release has no mod zip.")?;
    let native_asset = super::github::native_asset(r).ok_or("That release has no fa-native.zip.")?;
    progress(Progress::Status(format!("Downloading {}...", mod_asset.name)));
    let m = read_mod_zip(download_bytes(&mod_asset.browser_download_url, progress)?)?;
    progress(Progress::Status(format!("Downloading {}...", native_asset.name)));
    let n = read_native_zip(&download_bytes(&native_asset.browser_download_url, progress)?)?;
    Ok((m, n))
}

/// Both halves from local files (testers, offline).
pub fn load_files(mod_zip: &Path, native_zip: &Path) -> Result<(ModZip, NativeZip), String> {
    let m = read_mod_zip(fs::read(mod_zip).map_err(|e| format!("Failed to read {}: {}", mod_zip.display(), e))?)?;
    let n = read_native_zip(&fs::read(native_zip).map_err(|e| format!("Failed to read {}: {}", native_zip.display(), e))?)?;
    Ok((m, n))
}

/// Whether a version.dll is our proxy (it names fa_native.dll, as UTF-16, to load it), so that another tool's
/// version.dll is never overwritten or deleted.
pub fn is_our_proxy(path: &Path) -> bool {
    let Ok(bytes) = fs::read(path) else { return false };
    let needle: Vec<u8> = "fa_native.dll".encode_utf16().flat_map(|u| u.to_le_bytes()).collect();
    bytes.windows(needle.len()).any(|w| w == needle.as_slice())
}

/// Write via a temporary file beside the target, then move it into place.
fn replace_file(target: &Path, data: &[u8]) -> Result<(), String> {
    let tmp = target.with_extension("fa-new");
    fs::write(&tmp, data).map_err(|e| format!("Failed to write {}: {}", tmp.display(), e))?;
    if target.exists() {
        if let Err(e) = fs::remove_file(target) {
            let _ = fs::remove_file(&tmp);
            return Err(format!("Could not replace {} -- close Factorio and try again ({})", target.display(), e));
        }
    }
    fs::rename(&tmp, target).map_err(|e| format!("Failed to move {} into place: {}", target.display(), e))
}

/// mod-list.json: FactorioAccess enabled, without a version pin (which would keep an older zip loaded).
pub fn enable_in_mod_list(mods_dir: &Path) -> Result<(), String> {
    let path = mods_dir.join("mod-list.json");
    let mut doc: serde_json::Value = match fs::read_to_string(&path) {
        Ok(t) => serde_json::from_str(&t).map_err(|e| format!("{} is not valid JSON: {}", path.display(), e))?,
        Err(_) => serde_json::json!({ "mods": [ { "name": "base", "enabled": true } ] }),
    };
    let mods = doc["mods"].as_array_mut().ok_or_else(|| format!("{} has no mods list", path.display()))?;
    match mods.iter_mut().find(|m| m["name"] == MOD_NAME) {
        Some(m) => {
            m["enabled"] = serde_json::Value::Bool(true);
            if let Some(o) = m.as_object_mut() {
                o.remove("version");
            }
        }
        None => mods.push(serde_json::json!({ "name": MOD_NAME, "enabled": true })),
    }
    let text = serde_json::to_string_pretty(&doc).map_err(|e| e.to_string())?;
    fs::write(&path, text).map_err(|e| format!("Failed to write {}: {}", path.display(), e))
}

#[derive(Debug)]
pub struct Installed {
    pub mod_version: String,
    pub native_version: String,
    pub mod_path: PathBuf,
    pub removed: Vec<PathBuf>,
}

pub fn install(f: &Factorio, m: &ModZip, n: &NativeZip, progress: &dyn Fn(Progress)) -> Result<Installed, String> {
    if factorio_running() {
        return Err("Factorio is running. Close it and try again.".into());
    }
    // Everything that could refuse is checked before anything is written.
    let proxy = f.bin_dir.join("version.dll");
    if proxy.exists() && !is_our_proxy(&proxy) {
        return Err(format!("{} belongs to another program; Factorio Access needs that file name. Remove it yourself if you no longer need it.", proxy.display()));
    }
    let mods = f.mods_dir();
    let (old_zips, dirs) = installed_mods(f);
    if let Some(d) = dirs.first() {
        return Err(format!(
            "{} is an unpacked copy of the mod (a developer checkout?). Factorio would load it instead of the zip; move or remove it, then install again.",
            d.display()
        ));
    }

    progress(Progress::Status(format!("Installing the native code ({}) into {}...", n.version, f.bin_dir.display())));
    for (name, data) in &n.files {
        replace_file(&f.bin_dir.join(name), data)?;
    }
    fs::write(f.bin_dir.join(VERSION_FILE), format!("{}\n", n.version)).map_err(|e| format!("Failed to write the version file: {}", e))?;

    progress(Progress::Status(format!("Installing the mod {} into {}...", m.version, mods.display())));
    fs::create_dir_all(&mods).map_err(|e| format!("Failed to create {}: {}", mods.display(), e))?;
    let mod_path = mods.join(m.file_name());
    replace_file(&mod_path, &m.bytes)?;
    let mut removed = Vec::new();
    for z in old_zips {
        if z != mod_path {
            fs::remove_file(&z).map_err(|e| format!("Failed to remove the old {}: {}", z.display(), e))?;
            removed.push(z);
        }
    }
    enable_in_mod_list(&mods)?;
    Ok(Installed { mod_version: m.version.clone(), native_version: n.version.clone(), mod_path, removed })
}

/// The change sets of the mod zip installed in this Factorio, for "recommended settings" outside an install.
pub fn installed_change_sets(f: &Factorio) -> Result<(String, Vec<(String, String)>), String> {
    let (zips, dirs) = installed_mods(f);
    if let Some(d) = dirs.first() {
        let cc = d.join("config_changes");
        let mut v = Vec::new();
        for e in fs::read_dir(&cc).map_err(|e| format!("Failed to read {}: {}", cc.display(), e))?.flatten() {
            let name = e.file_name().to_string_lossy().to_string();
            if name.ends_with(".ini") {
                v.push((name, fs::read_to_string(e.path()).map_err(|e| e.to_string())?));
            }
        }
        v.sort();
        return Ok((d.display().to_string(), v));
    }
    let newest = zips
        .iter()
        .max_by_key(|z| z.file_name().and_then(|n| n.to_str()).and_then(|n| super::github::parse_version(n.trim_start_matches(&format!("{}_", MOD_NAME)).trim_end_matches(".zip"))))
        .ok_or_else(|| format!("Factorio Access is not installed in {}", f.mods_dir().display()))?;
    let m = read_mod_zip(fs::read(newest).map_err(|e| format!("Failed to read {}: {}", newest.display(), e))?)?;
    Ok((newest.display().to_string(), m.change_sets))
}

#[cfg(test)]
pub mod tests {
    use super::*;
    use std::io::Write;

    pub fn make_zip(entries: &[(&str, &[u8])]) -> Vec<u8> {
        let mut buf = Cursor::new(Vec::new());
        {
            let mut z = zip::ZipWriter::new(&mut buf);
            for (name, data) in entries {
                z.start_file(*name, zip::write::SimpleFileOptions::default()).unwrap();
                z.write_all(data).unwrap();
            }
            z.finish().unwrap();
        }
        buf.into_inner()
    }

    pub fn mod_zip(version: &str) -> Vec<u8> {
        let top = format!("FactorioAccess_{}", version);
        let info = format!("{{\"name\": \"FactorioAccess\", \"version\": \"{}\"}}", version);
        make_zip(&[
            (&format!("{}/info.json", top), info.as_bytes()),
            (&format!("{}/control.lua", top), b"-- x"),
            (&format!("{}/config_changes/AB_initial.ini", top), b"[controls]\n; why\nmove-up=UP\n"),
        ])
    }

    pub fn native_zip(version: &str) -> Vec<u8> {
        let proxy: Vec<u8> = b"MZ".iter().copied().chain("fa_native.dll".encode_utf16().flat_map(|u| u.to_le_bytes())).collect();
        make_zip(&[("version.dll", &proxy), ("fa_native.dll", b"MZ native"), ("prism.dll", b"MZ prism"), ("version.txt", format!("{}\n", version).as_bytes())])
    }

    #[test]
    fn reads_and_checks_zips() {
        let m = read_mod_zip(mod_zip("0.16.57")).unwrap();
        assert_eq!(m.version, "0.16.57");
        assert_eq!(m.file_name(), "FactorioAccess_0.16.57.zip");
        assert_eq!(m.change_sets.len(), 1);
        assert!(read_mod_zip(make_zip(&[("FactorioAccess_1.0.0/info.json", b"{\"name\":\"FactorioAccess\",\"version\":\"2.0.0\"}")])).is_err());
        assert!(read_mod_zip(make_zip(&[("other/info.json", b"{}")])).is_err());
        let n = read_native_zip(&native_zip("ci-abc1234")).unwrap();
        assert_eq!(n.version, "ci-abc1234");
        assert_eq!(n.files.len(), 3);
        assert!(read_native_zip(&make_zip(&[("version.dll", b"x")])).is_err());
    }

    #[test]
    fn installs_into_a_portable_layout() {
        let root = super::super::factorio::tests::fake_install(
            "install",
            Some("config-path=__PATH__executable__/../../config\nuse-system-read-write-data-directories=false\n"),
            Some(("config/config.ini", "[path]\nwrite-data=__PATH__executable__\\..\\..\n[controls]\nmove-up=W\n")),
        );
        let f = Factorio::locate_with(&root, Path::new("C:\\unused")).unwrap();
        fs::create_dir_all(f.mods_dir()).unwrap();
        fs::write(f.mods_dir().join("FactorioAccess_0.16.50.zip"), b"old").unwrap();
        fs::write(f.mods_dir().join("mod-list.json"), r#"{"mods":[{"name":"base","enabled":true},{"name":"FactorioAccess","enabled":false,"version":"0.16.50"}]}"#).unwrap();
        let m = read_mod_zip(mod_zip("0.16.57")).unwrap();
        let n = read_native_zip(&native_zip("v0.16.57")).unwrap();
        // Skip the running-game check's effect: the test only runs when no factorio.exe is up.
        if factorio_running() {
            return;
        }
        let r = install(&f, &m, &n, &|_| {}).unwrap();
        assert_eq!(r.removed, vec![f.mods_dir().join("FactorioAccess_0.16.50.zip")]);
        assert!(f.mods_dir().join("FactorioAccess_0.16.57.zip").is_file());
        for d in DLLS {
            assert!(f.bin_dir.join(d).is_file());
        }
        assert!(is_our_proxy(&f.bin_dir.join("version.dll")));
        assert_eq!(super::super::detect::installed_version(&f).as_deref(), Some("v0.16.57"));
        let list: serde_json::Value = serde_json::from_str(&fs::read_to_string(f.mods_dir().join("mod-list.json")).unwrap()).unwrap();
        let fa = list["mods"].as_array().unwrap().iter().find(|m| m["name"] == "FactorioAccess").unwrap();
        assert_eq!(fa["enabled"], true);
        assert!(fa.get("version").is_none());
        let (_, sets) = installed_change_sets(&f).unwrap();
        assert_eq!(sets.len(), 1);

        // A foreign version.dll refuses before anything is written; so does an unpacked mod folder.
        fs::write(f.bin_dir.join("version.dll"), b"MZ someone else").unwrap();
        assert!(install(&f, &m, &n, &|_| {}).is_err());
        fs::remove_file(f.bin_dir.join("version.dll")).unwrap();
        fs::create_dir_all(f.mods_dir().join("FactorioAccess")).unwrap();
        assert!(install(&f, &m, &n, &|_| {}).unwrap_err().contains("unpacked"));
        let _ = fs::remove_dir_all(root);
    }
}
