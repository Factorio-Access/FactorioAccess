//! Other processes on the Mac (the game, Steam), asked of pgrep.
use std::process::{Command, Stdio};

fn pgrep(args: &[&str]) -> bool {
    Command::new("pgrep").args(args).stdout(Stdio::null()).stderr(Stdio::null()).status().is_ok_and(|s| s.success())
}

/// Whether a process's command line (its executable path, then its arguments) matches the extended regex.
pub fn command_line_matches(regex: &str) -> bool {
    pgrep(&["-f", regex])
}

/// Whether a process has exactly this name.
pub fn named(name: &str) -> bool {
    pgrep(&["-x", name])
}
