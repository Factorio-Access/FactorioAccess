//! FactorioAccessInstaller.exe: installs one release of Factorio Access (the mod zip and the native DLLs, which
//! must always match) into a Factorio install, applies the recommended config changes, uninstalls.
//!
//!   FactorioAccessInstaller.exe          the window
//!   FactorioAccessInstaller.exe --cli    the same on the console
#![windows_subsystem = "windows"]

mod cli;
mod core;
mod gui;

fn main() {
    if std::env::args().any(|a| a == "--cli") {
        attach_console();
        cli::run();
    } else {
        gui::run();
    }
}

/// Attach to the parent console so --cli can use stdin/stdout from a windows-subsystem exe.
fn attach_console() {
    #[cfg(windows)]
    unsafe {
        use windows::Win32::System::Console::{AttachConsole, ATTACH_PARENT_PROCESS};
        let _ = AttachConsole(ATTACH_PARENT_PROCESS);
    }
}
