//! The window: a status line, the Factorio install (a dropdown of the ones found, the remembered one first, and a
//! Browse button for any other), a log box that narrates every step, and the buttons (Install / Update with a
//! version picker, Install from files, Recommended settings, Uninstall). Native wx controls, so a screen reader reads
//! it as an ordinary dialog. Downloads run on a worker thread; a timer drains its progress messages into the log so
//! the window never goes "not responding".
use std::cell::RefCell;
use std::path::PathBuf;
use std::rc::Rc;
use std::sync::mpsc;

use wxdragon::prelude::*;

use crate::core::config_changes;
use crate::core::factorio::Factorio;
use crate::core::install::{self, Installed, Progress};
use crate::core::paths::{data_dir, APP_NAME};
use crate::core::{detect, github, state, uninstall};

/// What the worker thread sends back.
enum Msg {
    Progress(Progress),
    /// Ok(what was installed, the installed mod's change sets) / Err(message)
    Done(Result<(Installed, Vec<(String, String)>), String>),
}

struct Ui {
    frame: Frame,
    status: StaticText,
    install_choice: Choice,
    log: TextCtrl,
    install_btn: Button,
    file_btn: Button,
    settings_btn: Button,
    uninstall_btn: Button,
    /// The installs in the dropdown, in its order.
    installs: RefCell<Vec<Factorio>>,
    catalog: RefCell<Option<github::Catalog>>,
    busy: RefCell<bool>,
}

impl Ui {
    fn log(&self, msg: &str) {
        let cur = self.log.get_value();
        if cur.is_empty() {
            self.log.set_value(msg);
        } else {
            self.log.set_value(&format!("{}\n{}", cur, msg));
        }
    }

    fn selected(&self) -> Option<Factorio> {
        let i = self.install_choice.get_selection()? as usize;
        self.installs.borrow().get(i).cloned()
    }

    fn set_busy(&self, busy: bool) {
        *self.busy.borrow_mut() = busy;
        self.refresh();
    }

    /// Fill the dropdown with `installs` and select `select` (an index into it).
    fn set_installs(&self, installs: Vec<Factorio>, select: Option<usize>) {
        self.install_choice.clear();
        for f in &installs {
            self.install_choice.append(&f.root.display().to_string());
        }
        *self.installs.borrow_mut() = installs;
        if let Some(i) = select {
            self.install_choice.set_selection(i as u32);
        }
        self.describe_selected();
        self.refresh();
    }

    /// Choose an install (from Browse or the dropdown): remembered for next time, added to the list if new.
    fn choose(&self, f: Factorio) {
        if let Err(e) = state::remember(&f.root) {
            self.log(&format!("Could not remember this choice: {}", e));
        }
        let mut list = self.installs.borrow().clone();
        let idx = match list.iter().position(|o| detect::same_path(&o.root, &f.root)) {
            Some(i) => i,
            None => {
                list.insert(0, f);
                0
            }
        };
        self.set_installs(list, Some(idx));
    }

    fn describe_selected(&self) {
        if let Some(f) = self.selected() {
            self.log(&format!("Factorio: {}", f.root.display()));
            self.log(&format!("Mods folder: {}", f.mods_dir().display()));
            self.log(&format!("Config: {}", f.config_ini.display()));
            match detect::installed_version(&f) {
                Some(v) if detect::is_installed(&f) => self.log(&format!("Installed {}: {}", APP_NAME, v)),
                _ => self.log(&format!("{} is not installed there.", APP_NAME)),
            }
        }
    }

    /// Status line, button states and the Install button's label from what is installed and what GitHub offers.
    fn refresh(&self) {
        let busy = *self.busy.borrow();
        let f = self.selected();
        let catalog = self.catalog.borrow();
        let has_any = catalog.as_ref().map(|c| !c.versions.is_empty() || c.ci.is_some()).unwrap_or(false);
        let installed = f.as_ref().map(detect::is_installed).unwrap_or(false);
        self.install_btn.enable(!busy && f.is_some() && has_any);
        self.file_btn.enable(!busy && f.is_some());
        self.settings_btn.enable(!busy && f.is_some());
        self.uninstall_btn.enable(!busy && installed);
        self.install_choice.enable(!busy);
        let Some(f) = f else {
            self.status.set_label("No Factorio install selected. Use Browse to find factorio.exe.");
            return;
        };
        let version = detect::installed_version(&f);
        let latest = catalog.as_ref().and_then(|c| c.latest().map(|r| r.tag_name.clone()));
        let line = match (installed, &latest) {
            (false, Some(l)) => format!("Ready to install {} {}.", APP_NAME, l),
            (false, None) => format!("{} is not installed in this Factorio.", APP_NAME),
            (true, Some(l)) if github::is_up_to_date(version.as_deref(), l) => {
                format!("{} {} is installed and up to date.", APP_NAME, version.as_deref().unwrap_or("?"))
            }
            (true, Some(l)) => format!("Update available: {} -> {}.", version.as_deref().unwrap_or("unknown"), l),
            (true, None) => format!("{} {} is installed.", APP_NAME, version.as_deref().unwrap_or("?")),
        };
        self.install_btn.set_label(if installed && latest.is_some() && !github::is_up_to_date(version.as_deref(), latest.as_deref().unwrap()) {
            "Update"
        } else {
            "Install"
        });
        self.status.set_label(&line);
    }

    fn message(&self, text: &str, error: bool) {
        let icon = if error { MessageDialogStyle::IconError } else { MessageDialogStyle::IconInformation };
        MessageDialog::builder(&self.frame, text, APP_NAME).with_style(MessageDialogStyle::OK | icon).build().show_modal();
    }

    fn yes_no(&self, text: &str, title: &str) -> bool {
        MessageDialog::builder(&self.frame, text, title)
            .with_style(MessageDialogStyle::YesNo | MessageDialogStyle::IconQuestion)
            .build()
            .show_modal()
            == ID_YES
    }

    /// The config.ini changes the mod needs: one yes/no for all of them.
    fn recommended_settings(&self, f: &Factorio, sets: &[(String, String)]) {
        if !f.config_ini.exists() {
            let text = format!(
                "{} does not exist yet, so the recommended settings cannot be applied. Start Factorio once, close it, then press Recommended settings here.",
                f.config_ini.display()
            );
            self.log(&text);
            self.message(&text, false);
            return;
        }
        let check = match config_changes::check_file(&f.config_ini, sets) {
            Ok(c) => c,
            Err(e) => {
                self.log(&format!("Error: {}", e));
                self.message(&e, true);
                return;
            }
        };
        self.log(&format!("config.ini has the recommended settings up to set {}.", check.level));
        if check.sets.is_empty() {
            self.log(&format!("Factorio's settings already have every change {} recommends.", APP_NAME));
            return;
        }
        if !check.pending.is_empty() && !self.yes_no(&config_changes::question(), "Factorio settings") {
            self.log("Recommended settings skipped. Press Recommended settings later to apply them.");
            return;
        }
        if detect::factorio_running() {
            let text = "Factorio is running and would overwrite config.ini when it exits. Close it, then press Recommended settings.";
            self.log(text);
            self.message(text, true);
            return;
        }
        match config_changes::apply_file(&f.config_ini, &check.sets) {
            Ok(changed) => {
                self.log(&format!("Applied {} recommended settings (the old config.ini is kept beside it as config.ini.fa-backup).", changed.len()));
            }
            Err(e) => {
                self.log(&format!("Error: {}", e));
                self.message(&e, true);
            }
        }
    }

    fn finish_install(&self, result: Result<(Installed, Vec<(String, String)>), String>) {
        match result {
            Ok((r, sets)) => {
                for old in &r.removed {
                    self.log(&format!("Removed the older {}", old.display()));
                }
                let text = format!("Installed the {} mod {} and its native code {}.", APP_NAME, r.mod_version, r.native_version);
                self.log(&format!("The mod is {}", r.mod_path.display()));
                self.log(&text);
                self.message(&text, false);
                if let Some(f) = self.selected() {
                    let _ = state::remember(&f.root);
                    self.recommended_settings(&f, &sets);
                }
            }
            Err(e) => {
                self.log(&format!("Error: {}", e));
                self.message(&e, true);
            }
        }
    }
}

pub fn run() {
    wxdragon::main(|_app| {
        let frame = Frame::builder().with_title(&format!("{} installer", APP_NAME)).with_size(Size::new(720, 560)).build();
        let panel = Panel::builder(&frame).build();
        let sizer = BoxSizer::builder(Orientation::Vertical).build();

        let status = StaticText::builder(&panel).with_label("Checking...").build();
        let install_label = StaticText::builder(&panel).with_label("Factorio install:").build();
        let install_choice = Choice::builder(&panel).build();
        let browse_btn = Button::builder(&panel).with_label("Browse for factorio.exe...").build();
        let log_label = StaticText::builder(&panel).with_label("Log:").build();
        let log = TextCtrl::builder(&panel)
            .with_style(TextCtrlStyle::MultiLine | TextCtrlStyle::ReadOnly | TextCtrlStyle::WordWrap)
            .build();
        let buttons = BoxSizer::builder(Orientation::Horizontal).build();
        let install_btn = Button::builder(&panel).with_label("Install").build();
        let file_btn = Button::builder(&panel).with_label("Install from files...").build();
        let settings_btn = Button::builder(&panel).with_label("Recommended settings").build();
        let uninstall_btn = Button::builder(&panel).with_label("Uninstall").build();
        let close_btn = Button::builder(&panel).with_label("Close").build();
        for b in [&install_btn, &file_btn, &settings_btn, &uninstall_btn, &close_btn] {
            buttons.add(b, 0, SizerFlag::All, 4);
        }
        let install_row = BoxSizer::builder(Orientation::Horizontal).build();
        install_row.add(&install_label, 0, SizerFlag::AlignCenterVertical | SizerFlag::All, 4);
        install_row.add(&install_choice, 1, SizerFlag::Expand | SizerFlag::All, 4);
        install_row.add(&browse_btn, 0, SizerFlag::All, 4);
        sizer.add(&status, 0, SizerFlag::Expand | SizerFlag::All, 8);
        sizer.add_sizer(&install_row, 0, SizerFlag::Expand | SizerFlag::Left | SizerFlag::Right, 4);
        sizer.add(&log_label, 0, SizerFlag::Left | SizerFlag::Top, 8);
        sizer.add(&log, 1, SizerFlag::Expand | SizerFlag::All, 8);
        sizer.add_sizer(&buttons, 0, SizerFlag::Expand | SizerFlag::All, 4);
        panel.set_sizer(sizer, true);

        let ui = Rc::new(Ui {
            frame: frame.clone(),
            status,
            install_choice: install_choice.clone(),
            log,
            install_btn: install_btn.clone(),
            file_btn: file_btn.clone(),
            settings_btn: settings_btn.clone(),
            uninstall_btn: uninstall_btn.clone(),
            installs: RefCell::new(Vec::new()),
            catalog: RefCell::new(None),
            busy: RefCell::new(true),
        });

        ui.log(&format!("The installer remembers the Factorio install you choose in {}.", data_dir().join("installer.json").display()));
        let found = detect::candidates();
        if found.is_empty() {
            ui.log("No Factorio install was found automatically. Press Browse and choose factorio.exe (in bin\\x64 of your Factorio folder).");
        }
        let select = (!found.is_empty()).then_some(0);
        ui.set_installs(found, select);

        // The release list, fetched before the window shows (a few hundred ms).
        match github::fetch_catalog() {
            Ok(c) => {
                match c.latest() {
                    Some(r) => ui.log(&format!("Newest release: {}", r.tag_name)),
                    None => ui.log("No tagged release with the installer's files is published yet."),
                }
                if c.ci.is_some() {
                    ui.log("A CI build is also available (last in the version list).");
                }
                *ui.catalog.borrow_mut() = Some(c);
            }
            Err(e) => {
                ui.log(&format!("Could not check GitHub for releases: {}", e));
                ui.log("Online install is unavailable; \"Install from files\" still works.");
            }
        }
        ui.set_busy(false);

        // Worker -> UI channel, drained by a timer.
        let (tx, rx) = mpsc::channel::<Msg>();
        {
            let ui = ui.clone();
            let timer = Timer::new(&frame);
            timer.on_tick(move |_| {
                while let Ok(msg) = rx.try_recv() {
                    match msg {
                        Msg::Progress(Progress::Status(s)) => {
                            ui.status.set_label(&s);
                            ui.log(&s);
                        }
                        Msg::Progress(Progress::Percent(p)) => ui.status.set_label(&format!("Downloading... {}%", p)),
                        Msg::Done(result) => {
                            ui.finish_install(result);
                            ui.set_busy(false);
                            ui.describe_selected();
                        }
                    }
                }
            });
            timer.start(100, false);
            std::mem::forget(timer); // lives as long as the window
        }

        {
            let ui = ui.clone();
            install_choice.on_selection_changed(move |_| {
                if let Some(f) = ui.selected() {
                    ui.choose(f);
                }
            });
        }

        {
            let ui = ui.clone();
            browse_btn.on_click(move |_| {
                let dialog = FileDialog::builder(&ui.frame)
                    .with_message("Choose factorio.exe (in bin\\x64 of your Factorio folder)")
                    .with_wildcard("factorio.exe|factorio.exe|Programs (*.exe)|*.exe")
                    .with_style(FileDialogStyle::Open | FileDialogStyle::FileMustExist)
                    .build();
                if dialog.show_modal() != ID_OK {
                    return;
                }
                let Some(path) = dialog.get_path() else { return };
                match Factorio::locate(&PathBuf::from(&path)) {
                    Ok(f) => ui.choose(f),
                    Err(e) => {
                        ui.log(&format!("Error: {}", e));
                        ui.message(&e, true);
                    }
                }
            });
        }

        // Install / Update: pick a version (tagged releases newest first; the CI build last, on purpose).
        {
            let ui = ui.clone();
            let tx = tx.clone();
            install_btn.on_click(move |_| {
                let Some(f) = ui.selected() else { return };
                let Some(cat) = ui.catalog.borrow().clone() else { return };
                let mut labels: Vec<String> =
                    cat.versions.iter().map(|r| if r.prerelease { format!("{} (pre-release)", r.tag_name) } else { r.tag_name.clone() }).collect();
                if let Some(ci) = &cat.ci {
                    labels.push(format!("latest successful CI build ({}) -- untested, may be broken", github::ci_build_label(ci)));
                }
                if labels.is_empty() {
                    return;
                }
                let refs: Vec<&str> = labels.iter().map(|s| s.as_str()).collect();
                let dialog = SingleChoiceDialog::builder(&ui.frame, "Select a version to install:", "Choose version", &refs).build();
                if dialog.show_modal() != ID_OK {
                    return;
                }
                let sel = dialog.get_selection();
                if sel < 0 {
                    return;
                }
                let sel = sel as usize;
                let rel = if sel < cat.versions.len() { cat.versions[sel].clone() } else { cat.ci.clone().unwrap() };
                let notes = if rel.notes().is_empty() { String::new() } else { format!("Release notes for {}:\n\n{}\n\n", rel.tag_name, rel.notes()) };
                if !ui.yes_no(&format!("{}Install {} into {}?", notes, rel.tag_name, f.root.display()), &format!("Install {}", rel.tag_name)) {
                    return;
                }
                let label = if sel < cat.versions.len() { rel.tag_name.clone() } else { format!("the latest CI build ({})", github::ci_build_label(&rel)) };
                ui.set_busy(true);
                ui.log(&format!("Installing {}...", label));
                let tx = tx.clone();
                std::thread::spawn(move || {
                    let tx2 = tx.clone();
                    let progress = move |p| {
                        let _ = tx2.send(Msg::Progress(p));
                    };
                    let result = install::download_release(&rel, &progress)
                        .and_then(|(m, n)| install::install(&f, &m, &n, &progress).map(|r| (r, m.change_sets)));
                    let _ = tx.send(Msg::Done(result));
                });
            });
        }

        // Install from local files (testers, offline): the mod zip, then fa-native.zip.
        {
            let ui = ui.clone();
            let tx = tx.clone();
            file_btn.on_click(move |_| {
                let Some(f) = ui.selected() else { return };
                let pick = |message: &str, wildcard: &str| -> Option<String> {
                    let d = FileDialog::builder(&ui.frame)
                        .with_message(message)
                        .with_wildcard(wildcard)
                        .with_style(FileDialogStyle::Open | FileDialogStyle::FileMustExist)
                        .build();
                    if d.show_modal() != ID_OK {
                        return None;
                    }
                    d.get_path()
                };
                let Some(mod_zip) = pick("Select the mod zip (FactorioAccess_<version>.zip)", "Mod zip (FactorioAccess_*.zip)|FactorioAccess_*.zip|Zip files (*.zip)|*.zip")
                else {
                    return;
                };
                let Some(native_zip) = pick("Select the native zip (fa-native.zip) from the same release", "fa-native.zip|fa-native.zip|Zip files (*.zip)|*.zip") else {
                    return;
                };
                ui.set_busy(true);
                ui.log(&format!("Installing from {} and {}...", mod_zip, native_zip));
                let tx = tx.clone();
                std::thread::spawn(move || {
                    let tx2 = tx.clone();
                    let progress = move |p| {
                        let _ = tx2.send(Msg::Progress(p));
                    };
                    let result = install::load_files(&PathBuf::from(&mod_zip), &PathBuf::from(&native_zip))
                        .and_then(|(m, n)| install::install(&f, &m, &n, &progress).map(|r| (r, m.change_sets)));
                    let _ = tx.send(Msg::Done(result));
                });
            });
        }

        // Recommended settings from the mod already in the mods folder.
        {
            let ui = ui.clone();
            settings_btn.on_click(move |_| {
                let Some(f) = ui.selected() else { return };
                match install::installed_change_sets(&f) {
                    Ok((from, sets)) => {
                        ui.log(&format!("Reading the recommended settings from {}", from));
                        ui.recommended_settings(&f, &sets);
                    }
                    Err(e) => {
                        ui.log(&format!("Error: {}", e));
                        ui.message(&e, true);
                    }
                }
            });
        }

        // Uninstall: the native code always, the mod if asked. config.ini is kept.
        {
            let ui = ui.clone();
            uninstall_btn.on_click(move |_| {
                let Some(f) = ui.selected() else { return };
                if !ui.yes_no(&format!("Remove {}'s native code from {}?", APP_NAME, f.bin_dir.display()), &format!("Uninstall {}", APP_NAME)) {
                    return;
                }
                let remove_mod = ui.yes_no(&format!("Also remove the {} mod from {}?", APP_NAME, f.mods_dir().display()), &format!("Uninstall {}", APP_NAME));
                match uninstall::uninstall(&f, remove_mod) {
                    Ok(removed) => {
                        for p in &removed {
                            ui.log(&format!("Removed {}", p.display()));
                        }
                        ui.log(&format!("{} uninstalled.", APP_NAME));
                        ui.message(&format!("{} was removed from {}.", APP_NAME, f.root.display()), false);
                    }
                    Err(e) => {
                        ui.log(&format!("Error: {}", e));
                        ui.message(&e, true);
                    }
                }
                ui.refresh();
            });
        }

        {
            let frame = frame.clone();
            close_btn.on_click(move |_| {
                frame.close(true);
            });
        }

        frame.show(true);
        install_choice.set_focus();
    })
    .expect("Failed to start the installer window");
}
