//! FactorioAccessInstaller.exe: installs one release of Factorio Access (the mod zip and the native DLLs, which
//! must always match) into a Factorio install, applies the recommended config changes, uninstalls.
//!
//!   FactorioAccessInstaller.exe          the window
//!   FactorioAccessInstaller.exe --cli    the same on the console
//!
//! On the Mac there is no window yet: FactorioAccessInstaller always runs the console flow (`--cli` is accepted).
#![windows_subsystem = "windows"]

mod cli;
mod core;
#[cfg(windows)]
mod gui;

#[cfg(windows)]
fn main() {
    if std::env::args().any(|a| a == "--cli") {
        attach_console();
        cli::run();
    } else {
        gui::run();
    }
}

#[cfg(not(windows))]
fn main() {
    cli::run();
}

/// Attach to the parent console so --cli can use stdin/stdout from a windows-subsystem exe.
#[cfg(windows)]
fn attach_console() {
    unsafe {
        use windows::Win32::System::Console::{AttachConsole, ATTACH_PARENT_PROCESS};
        let _ = AttachConsole(ATTACH_PARENT_PROCESS);
    }
}
