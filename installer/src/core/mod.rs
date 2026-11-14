pub mod config_changes;
pub mod detect;
pub mod factorio;
pub mod github;
pub mod install;
pub mod paths;
#[cfg(not(windows))]
pub mod process;
pub mod state;
#[cfg(not(windows))]
pub mod steam_launch;
pub mod uninstall;
#[cfg(not(windows))]
pub mod vdf;
