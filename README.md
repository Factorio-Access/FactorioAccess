# Welcome to Factorio Access BETA!

This is an accessibility mod for the popular game Factorio which enables blind people to play and win the game.  It supports almost all game features including advanced things such as the circuit network.
We have had players successfully build post-endgame bases with it in a reasonable amount of time.

# Important Warnings

The mod tries to support multiplayer but game limitations mean that your experience will be laggy and kind of terrible. We cannot do anything about this.  We also have limited ability to do anything about bugs, because that would require two mod developers playing at the same time.

Finally, we do not yet support space age. If you bought space age, you need to disable quality, elevated rails, and space age in the launcher's mod menu.

# Installing Factorio

The game can be purchased from Factorio.com or from Steam. Any purchase gives access to all versions. We recommend installing it using ONLY one of the options below. The zip or standalone versions are recommended, but Steam is easier to configure for multiplayer.  Note that Steam is harder to configure in the first place, and we don't recommend it.

## Windows Zip Version / Standalone Version (recommended for easy mod install and troubleshooting)

1. Go to https://www.factorio.com/download
1. If needed, login using your Factorio account or Steam account.
1. Among the install options, find the stable releases at the top half of the page. 
1. Go to the section with "Other download options" and select "Download full game for Windows (ZIP package)". This will download a zip file that is about 1.5 gigabytes in size. It might also be called the manual install. Note that this is different from the regular Windows version, which downloads an exe file.
1. If you got a .exe or are running an installer at any point in the process you got the wrong thing
1. Create a folder where you want to keep the game. Extract the zip file into this folder.
1. If you want, create a desktop shortcut for your Factorio folder.
1. All done! You need to install the mod next.

## Steam Version (harder to configure the mod, better for multiplayer setup)

1. Install Factorio using Steam settings, like any other game on Steam.
1. That is it, pretty much. You next need to install the mod next and then configure Steam settings.

## Regular Windows Version (not recommended)

1. Consider if you need to do this. It has no advantage over the standalone zip at all.
1. Go to https://www.factorio.com/download
1. If needed, login using your Factorio account or Steam account.
1. Among the install options, find the stable releases at the top half of the page.
1. Select "Download full game for Windows". This will download an "exe" file which is the setup application.
1. Run the exe file and follow the instructions.
1. All done! You need to install the mod next.

## Linux Version

1. Go to https://www.factorio.com/download
1. If needed, login using your Factorio account or Steam account.
1. Among the install options, find the stable releases at the top half of the page.
1. Go to the section with "Other download options" and select "Download full game for Linux". This will download a "tar.xz" file.
1. Move the file to the directory where you want to install the game.
1. Extract the game from the file using a program such as 7zip.
1. All done! You need to install the mod next.

## Mac Version

1. Go to https://www.factorio.com/download
1. If needed, login using your Factorio account or Steam account.
1. Among the install options, find the stable releases at the top half of the page.
1. Go to the section with "Other download options" and select "Download full game for macOS". This will download a "dmg" file.
1. Install the "dmg" file like any other.

# Installing Factorio Access

To install a mod release, follow the instructions below, depending on the version of Factorio that you have installed.

## Windows Zip version: Mod release install

1. Download the latest launcher from here: https://github.com/factorio-access/factorio-access-launcher/releases
1. Put it in the root of the factorio zip, the same folder as bin and config-path.cfg
1. Launch the launcher and follow the instructions. The launcher now downloads the mod.
1. The game is ready to play from the launcher when the main menu appears.
1. If you bought space age, go into the launcher's mod menu and disable elevated rails, quality, and space age.

## Windows Steam version or regular Windows version: Mod release install

1. Download the latest launcher from here: https://github.com/factorio-access/factorio-access-launcher/releases
1. Run the game `factorio.exe` at least once if you have not, and then exit it. This is necessary in order to create the folders for the next step. The exe can be found under the folder `bin`.
1. Navigate to your Factorio game data folder. This is inside a special Windows folder called "AppData". There are two ways to access the AppData folder, you either enter its short name using % signs, or you use the full path name. If you use the short name with the signs, the path is called `%AppData%/Factorio`. If you use the full path, the path depends on your windows user name and it is something like `C:/Users/Your_User_Name_Here/AppData/Roaming/Factorio`.
1. Put the launcher in this folder.
1. The mod is now installed, but you still need to configure Steam and also the mod itself. Note that the game is both configured and played using "launcher.exe", which is necessary for the mod to read out the game. If you want, you can create a shortcut for this launcher.
1. You can run the mod launcher directly or in administrator mode if needed. Running it the first time will generate a Windows security warning because you are running an unsigned application.
1. The first time you run the launcher, it will ask you to configure Steam launch settings. It will ask you to copy a setup text string. This string should include the path location of the mod launcher application in quotation marks, and also the string "%command%". For example, the setup text string in total could be ` "C:\Users\Your_User_Name_Here\AppData\Roaming\Factorio\launcher.exe" %command% `.
1. Open your Steam Library and find the Factorio page.
1. Find the Properties menu for Factorio. On the Steam Library, the Properties menu for a game can be opened by finding the game's name in the library list, and then right clicking it to open the context menu, and then selecting the last option called "Properties...". Alternatively, you can open the game's page in the Steam Library and open the "Manage" menu, which is denoted by a gear symbol that you can left click. From the "Manage" menu you can select the last option called "Properties..."
1. When the Properties menu is open, you should be immediately at the "General" section. At the bottom of this section is the part called "Launch Options" with a text field that you can type in. Here, you need to paste the mod launcher setup text string that you copied earlier.
1. Try launching the game from Steam. This should now run the mod launcher instead, and say "Hello Factorio". If not setup correctly, the game might launch directly and you will hear music.
1. Follow the mod launcher instructions while the game is configured. This may involve launching the game itself temporarily.
1. The game is ready to play from the launcher when the main menu appears.
1. If you bought space age, go into the launcher's mod menu and disable elevated rails, quality, and space age.

## Linux Version: Mod install and running via Python scripts

1. Install speechd and python 3 through your distribution. Note that Instructions vary by distribution.
1. Use Git or GitHub CLI to get the launcher from the [Factorio-Access-Launcher repository](https://github.com/Factorio-Access/Factorio-Access-Launcher).
1. CD into the folder.
1. If you want to use a virtual python environment, or an executable, run build_main.py. If not, run pip to install requirements.txt by:  "pip install -r requirements.txt"
1. Run the executable or main.py
1. If it complains it can't find your Factorio installation then add the path to the Factorio executable as an argument when launching.
1. If you bought space age, go into the launcher's mod menu and disable elevated rails, quality, and space age.

## MacOS: Mod install and running via Python scripts

### High level instructions

For step by step instructions continue to the next section.

1. Make sure you have python 3 installed.
1. Use Git or GitHub CLI, or extract from the release zip, to get the FactorioAccess mod into Factorio's mods folder, which is "~/Library/Application Support/factorio/mods" on Mac.
1. Use Git or GitHub CLI to get the launcher from the [Factorio-Access-Launcher repository](https://github.com/Factorio-Access/Factorio-Access-Launcher). It shouldn't matter where you put it.
1. Enter the repository folder and run the launcher builder script: `python3.11 build_main.py`
1. Run the mod launcher via python.
1. Follow the launcher instructions while the game is configured. This may involve launching the game itself temporarily.
1. The game is ready to play from the launcher when the main menu appears.
1. If you bought space age, go into the launcher's mod menu and disable elevated rails, quality, and space age.

### Step by step instructions

1. Open the terminal.
1. Run `python3` as a single word command to check which python version is installed. 
1. If you have python3, the version number will be printed. You need python 3.11, but any python3 will work. To exit python, use the command `exit()`.
1. If you do not have python3, then install it from the official website: https://www.python.org/downloads/release/python-3110/
1. In the terminal, navigate to the folder you'd like the launcher folder to be inside. For example: `cd ~/Documents`
1. Clone the launcher repository here: `git clone git@github.com:Factorio-Access/Factorio-Access-Launcher.git`
1. Go into the newly created folder: `cd Factorio-Access-Launcher`
1. Run the build script: `python3.11 build_main.py`
1. The build script might error out but it will at least set up the virtual environment and install the required python modules.
1. The mod should now be fully installed. Any time you want to run the launcher you can go to the same folder and run: `./venv/bin/python main.py`
1. Follow the launcher's setup steps as instructed by it.
1. If you bought space age, go into the launcher's mod menu and disable elevated rails, quality, and space age.

# Mod Documentation

There are a huge number of keystrokes and functions in the mod. To help keep this README reasonable, we have divided them into other documents:

- [Basics](docs/features/basics.md) explains walking, the cursor, and building.
- [Combat, Vehicles, and Military](./docs/features/combat.md)
- [Ui](docs/features/ui.md) explains how menus and other controls work
- [Blueprints and Planners](docs/features/blueprints-and-planners.md) explains how to use blueprints, blueprint books, deconstruction planners, and upgrade planners.
- [Circuit Network](docs/features/circuit-network.md) explains functionality applying specifically to the circuit network, such as how to drag wires.

Please note that the mod wiki is out of date. The above documentation is maintained by developers and is for 2.0. The wiki is by users and primarily for 1.1.

To access the in-game tutorial, press control t.

# Vanilla Mode

Vanilla Mode is for sighted people to play using mouse controls without disabling the mod. The most likely use case for
this is when you play multiplayer with sighted friends, as this requires everyone to install identical mod lists. There
may also be other reasons to use this mode such as sharing your save file and so on.

NOTE: Maintaining this mode is NOT a recommendation that you should try multiplayer, and nothing here makes multiplayer
better for mod players. Your experience will continue to lag a lot and parts of the game such as combat will continue to
be essentially unplayable in multiplayer, with vanilla mode or otherwise. We maintain this feature for the small number
of users who want to play multiplayer anyway or have different use cases.

When Vanilla Mode mode is toggled on, it disables sonifiers and speech, stops all of the mod's key handling, and closes
any open mod UIs. Mod data such as fast travel points are left untouched, and so you should be able to toggle Vanilla
Mode without any penalties. If the sighted person does not install our launcher config tweaks, then their game in
Vanilla Mode should function as if this mod is not present. If the mod's config tweaks are used and then Vanilla Mode is
enabled, the keymapping changes of the mod are still present but inactive. In this case one can play using the arrow
keys and mouse while relying on GUI buttons to open most menus.

Vanilla Mode is toggled on or off by pressing CONTROL + ALT + SHIFT + V.

NOTE: If the ESCAPE key does not work for pausing the game, please try the alternative of SHIFT + ESCAPE.

NOTE: Maintaining a bug-free Vanilla Mode relies on active sighted users and/or developers. By the nature of it, blind
developers cannot test it at all, and whether or not this project is primarily maintained by the blind varies day to
day.

# Help and Support

If your question wasn't answered here or on our wiki, feel free to contact us at our [Discord server](https://discord.gg/CC4QA6KtzP).

# Changes

An updated changelog can be found [here](https://github.com/Factorio-Access/FactorioAccess/blob/main/CHANGES.md).
