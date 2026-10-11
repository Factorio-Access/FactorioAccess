//! GitHub releases of the repo: the tagged semver versions (what the picker lists, newest first) and the rolling
//! `ci-latest` pre-release that CI republishes (offered last, on purpose). Only releases carrying both halves (the
//! mod zip and the native zip) are offered: the old launcher-era releases have neither and are skipped.
use serde::Deserialize;

use super::paths::{CI_TAG, GITHUB_RELEASES_URL, MOD_NAME, NATIVE_ZIP};

#[derive(Debug, Deserialize, Clone)]
pub struct ReleaseInfo {
    pub tag_name: String,
    #[serde(default)]
    pub body: Option<String>,
    #[serde(default)]
    pub prerelease: bool,
    #[serde(default)]
    pub published_at: Option<String>,
    /// The commit the release was created against: the workflow passes `--target $GITHUB_SHA` for `ci-latest`,
    /// so this is the exact commit the CI build came from (a tagged release reports its branch name).
    #[serde(default)]
    pub target_commitish: String,
    #[serde(default)]
    pub assets: Vec<Asset>,
}

impl ReleaseInfo {
    pub fn notes(&self) -> &str {
        self.body.as_deref().unwrap_or("").trim()
    }
}

/// "2026-09-20T18:17:16Z" -> "2026-09-20 18:17 UTC" (GitHub timestamps are always UTC); anything else verbatim.
pub fn format_timestamp(iso: &str) -> String {
    let t = iso.trim_end_matches('Z');
    match (t.get(..10), t.get(11..16)) {
        (Some(d), Some(hm)) if t.as_bytes().get(10) == Some(&b'T') => format!("{} {} UTC", d, hm),
        _ => iso.to_string(),
    }
}

/// What identifies a CI build to a tester: "03c9462, 2026-09-20 18:17 UTC" (short commit, publish time).
/// The DLL's version is "ci-03c9462", so the two can be matched by eye.
pub fn ci_build_label(r: &ReleaseInfo) -> String {
    let sha = r.target_commitish.get(..7).unwrap_or(&r.target_commitish);
    let when = format_timestamp(r.published_at.as_deref().unwrap_or(""));
    match (sha.is_empty(), when.is_empty()) {
        (false, false) => format!("{}, {}", sha, when),
        (false, true) => sha.to_string(),
        (true, false) => when,
        (true, true) => "unknown build".to_string(),
    }
}

#[derive(Debug, Deserialize, Clone)]
pub struct Asset {
    pub name: String,
    pub browser_download_url: String,
}

/// What the picker offers.
#[derive(Debug, Default, Clone)]
pub struct Catalog {
    /// Semver-tagged releases, newest first.
    pub versions: Vec<ReleaseInfo>,
    /// The rolling CI build, if CI has published one.
    pub ci: Option<ReleaseInfo>,
}

impl Catalog {
    pub fn latest(&self) -> Option<&ReleaseInfo> {
        self.versions.first()
    }
}

pub fn parse_version(tag: &str) -> Option<semver::Version> {
    let t = tag.strip_prefix('v').or_else(|| tag.strip_prefix('V')).unwrap_or(tag);
    semver::Version::parse(t).ok()
}

/// The mod zip: FactorioAccess_<version>.zip.
pub fn mod_asset(r: &ReleaseInfo) -> Option<&Asset> {
    r.assets.iter().find(|a| a.name.starts_with(&format!("{}_", MOD_NAME)) && a.name.ends_with(".zip"))
}

/// The native DLLs: fa-native.zip.
pub fn native_asset(r: &ReleaseInfo) -> Option<&Asset> {
    r.assets.iter().find(|a| a.name == NATIVE_ZIP)
}

fn installable(r: &ReleaseInfo) -> bool {
    mod_asset(r).is_some() && native_asset(r).is_some()
}

pub fn catalog_from(releases: Vec<ReleaseInfo>) -> Catalog {
    let mut cat = Catalog::default();
    for r in releases.into_iter().filter(installable) {
        if r.tag_name == CI_TAG {
            cat.ci = Some(r);
        } else if parse_version(&r.tag_name).is_some() {
            cat.versions.push(r);
        }
    }
    cat.versions.sort_by(|a, b| parse_version(&b.tag_name).cmp(&parse_version(&a.tag_name)));
    cat
}

pub fn fetch_catalog() -> Result<Catalog, String> {
    let client = reqwest::blocking::Client::builder()
        .user_agent("FactorioAccessInstaller")
        .timeout(std::time::Duration::from_secs(15))
        .build()
        .map_err(|e| format!("Failed to create the HTTP client: {}", e))?;
    let resp = client
        .get(format!("{}?per_page=100", GITHUB_RELEASES_URL))
        .send()
        .map_err(|e| format!("Failed to reach GitHub: {}", e))?;
    if !resp.status().is_success() {
        return Err(format!("GitHub returned status {}", resp.status()));
    }
    let releases: Vec<ReleaseInfo> = resp.json().map_err(|e| format!("Failed to parse the release list: {}", e))?;
    Ok(catalog_from(releases))
}

/// "v0.16.57" or "ci-latest" vs the installed version: is the installed one at least as new?
pub fn is_up_to_date(installed: Option<&str>, latest: &str) -> bool {
    let Some(installed) = installed else { return false };
    match (parse_version(installed), parse_version(latest)) {
        (Some(i), Some(l)) => i >= l,
        _ => installed == latest,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn rel(tag: &str) -> ReleaseInfo {
        ReleaseInfo {
            tag_name: tag.into(),
            body: None,
            prerelease: false,
            published_at: None,
            target_commitish: String::new(),
            assets: vec![
                Asset { name: "FactorioAccess_0.16.57.zip".into(), browser_download_url: "m".into() },
                Asset { name: NATIVE_ZIP.into(), browser_download_url: "n".into() },
                Asset { name: "FactorioAccessInstaller.exe".into(), browser_download_url: "i".into() },
            ],
        }
    }

    #[test]
    fn ci_label_shows_sha_and_time() {
        let mut r = rel("ci-latest");
        r.target_commitish = "03c9462098a5670e736f1d7f14b7b247b2eb45d4".into();
        r.published_at = Some("2026-09-20T18:17:16Z".into());
        assert_eq!(ci_build_label(&r), "03c9462, 2026-09-20 18:17 UTC");
        r.published_at = None;
        assert_eq!(ci_build_label(&r), "03c9462");
        assert_eq!(ci_build_label(&rel("ci-latest")), "unknown build");
        assert_eq!(format_timestamp("garbage"), "garbage");
    }

    #[test]
    fn catalog_sorts_splits_and_skips_launcher_era_releases() {
        let mut old = rel("v0.15.3");
        old.assets = vec![Asset { name: "launcher.zip".into(), browser_download_url: "x".into() }];
        let c = catalog_from(vec![rel("v0.16.1"), rel("ci-latest"), rel("v0.16.10"), old, rel("v0.16.2"), rel("junk")]);
        let tags: Vec<_> = c.versions.iter().map(|r| r.tag_name.as_str()).collect();
        assert_eq!(tags, vec!["v0.16.10", "v0.16.2", "v0.16.1"]);
        assert_eq!(c.ci.unwrap().tag_name, "ci-latest");
        assert_eq!(mod_asset(&rel("v1.0.0")).unwrap().browser_download_url, "m");
        assert_eq!(native_asset(&rel("v1.0.0")).unwrap().browser_download_url, "n");
    }

    #[test]
    fn up_to_date_rules() {
        assert!(is_up_to_date(Some("v0.16.57"), "v0.16.57"));
        assert!(!is_up_to_date(Some("v0.16.9"), "v0.16.10"));
        assert!(!is_up_to_date(None, "v0.16.57"));
        assert!(!is_up_to_date(Some("ci-abc1234"), "v0.16.57"));
    }
}
