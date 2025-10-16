# Welcome to Factorio Access BETA!

This is the BETA VERSION for an accessibility mod for the popular game Factorio. The goal of this mod is to make the game completely accessible to the blind and visually impaired. This beta version is the current main repository for the mod. This mod is an unofficial Factorio project by volunteers.

This "read me" file covers the basics of the mod, which include the installation guide, the mod controls, and links to other information sources.

# More info at the wiki

Factorio has an [official wiki](https://wiki.factorio.com/).

There is also [a Mod Wiki](https://github.com/Factorio-Access/FactorioAccess/wiki), but this has not been updated for 2.0 and (for now) is mostly historical.

# Installing Factorio
The game can be purchased from Factorio.com or from Steam. Any purchase gives access to all versions. We recommend installing it using ONLY one of the options below. The zip or standalone versions are recommended for being easy to install the mod. The Steam versions are harder to configure but they are more reliable for multiplayer, while Steam Achievements are not available for modded gameplay.

## Windows Zip Version / Standalone Version (recommended for easy mod install and troubleshooting)
1. Go to https://www.factorio.com/download
1. If needed, login using your Factorio account or Steam account.
1. Among the install options, find the stable releases at the top half of the page. 
1. Go to the section with "Other download options" and select "Download full game for Windows (ZIP package)". This will download a zip file that is about 1.5 gigabytes in size. It might also be called the manual install. Note that this is different from the regular Windows version, which downloads an exe file.
1. Create a folder where you want to keep the game. Extract the zip file into this folder.
1. If you want, create a desktop shortcut for your Factorio folder.
1. All done! You need to install the mod next.

## Steam Version (harder to configure the mod, better for multiplayer setup)
1. Install Factorio using Steam settings, like any other game on Steam.
1. That is it, pretty much. You next need to install the mod next and then configure Steam settings.

## Regular Windows Version (not recommended)
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
1. Download the latest release zip file such as "Factorio_Access_Beta_0_X_X.zip" from the releases page here: https://github.com/Factorio-Access/FactorioAccess/releases. There are other files that you can download there but you need only the one mentioned. You may get a security warning about downloading an unlicensed application, which is true for the mod launcher. For safety reasons, please do not download the mod launcher from anywhere else.
1. Put the zip file in an empty folder and extract its contents. You should find a folder named "Factorio_Access_Beta_content". You need to open it and copy everything inside of it. These contents should include the mod's own launcher called "launcher.exe" as well as a "mods" folder and a "Factorio.jkm" file.
1. Navigate to your Factorio standalone folder, with a name such as "Factorio_1.1.101". This is your Factorio game data folder.
1. Make sure you copied all of the contents in Step 2 and paste them into the Factorio game data folder you found in Step 3.
1. The mod is now installed, but you need to configure it. Note that the game is both configured and played using "launcher.exe", which is necessary for the mod to read out the game. If you want, you can create a shortcut for this launcher.
1. If you are a jaws user for screen reading, you may want to copy Factorio.jkm file into your JAWS settings folder, which is found in the AppData folder. An example file path is `C:\Users\Your_User_Name_Here\AppData\Roaming\Freedom Scientific\JAWS\2022\Settings\enu\`
1. You can run the mod launcher directly or in administrator mode if needed. Running it the first time will generate a Windows security warning because you are running an unlicensed application.
1. Follow the mod launcher instructions while the game is configured. This may involve launching the game itself temporarily.
1. The game is ready to play from the launcher when the main menu appears.

## Windows Steam version or regular Windows version: Mod release install
1. Download the latest release zip file such as "Factorio_Access_Beta_0_X_X.zip" from the releases page here: https://github.com/Factorio-Access/FactorioAccess/releases. There are other files that you can download there but you need only the one mentioned. You may get a security warning about downloading an unlicensed application, which is true for the mod launcher. For safety reasons, please do not download the mod launcher from anywhere else.
2. Put the zip file in an empty folder and extract its contents. You should find a folder named "Factorio_Access_Beta_content". You need to open it and copy everything inside of it. These contents should include the mod's own launcher called "launcher.exe" as well as a "mods" folder and a "Factorio.jkm" file.
3. Run the game `factorio.exe` at least once if you have not, and then exit it. This is necessary in order to create the folders for the next step. The exe can be found under the folder `bin`.
4. Navigate to your Factorio game data folder. This is inside a special Windows folder called "AppData". There are two ways to access the AppData folder, you either enter its short name using % signs, or you use the full path name. If you use the short name with the signs, the path is called `%AppData%/Factorio`. If you use the full path, the path depends on your windows user name and it is something like `C:/Users/Your_User_Name_Here/AppData/Roaming/Factorio`.
5. Make sure you copied all of the contents in Step 2 and paste them into the Factorio game data folder you found in Step 4.
1. The mod is now installed, but you still need to configure Steam and also the mod itself. Note that the game is both configured and played using "launcher.exe", which is necessary for the mod to read out the game. If you want, you can create a shortcut for this launcher.
1. If you are a jaws screen reader user, you may want to copy the Factorio.jkm file into your JAWS settings folder, which is found in the AppData folder. An example file path is `C:\Users\Your_User_Name_Here\AppData\Roaming\Freedom Scientific\JAWS\2022\Settings\enu\`
1. You can run the mod launcher directly or in administrator mode if needed. Running it the first time will generate a Windows security warning because you are running an unsigned application.
1. The first time you run the launcher, it will ask you to configure Steam launch settings. It will ask you to copy a setup text string. This string should include the path location of the mod launcher application in quotation marks, and also the string "%command%". For example, the setup text string in total could be ` "C:\Users\Your_User_Name_Here\AppData\Roaming\Factorio\launcher.exe" %command% `.
1. Open your Steam Library and find the Factorio page.
1. Find the Properties menu for Factorio. On the Steam Library, the Properties menu for a game can be opened by finding the game's name in the library list, and then right clicking it to open the context menu, and then selecting the last option called "Properties...". Alternatively, you can open the game's page in the Steam Library and open the "Manage" menu, which is denoted by a gear symbol that you can left click. From the "Manage" menu you can select the last option called "Properties..."
1. When the Properties menu is open, you should be immediately at the "General" section. At the bottom of this section is the part called "Launch Options" with a text field that you can type in. Here, you need to paste the mod launcher setup text string that you copied earlier.
1. Try launching the game from Steam. This should now run the mod launcher instead, and say "Hello Factorio". If not setup correctly, the game might launch directly and you will hear music.
1. Follow the mod launcher instructions while the game is configured. This may involve launching the game itself temporarily.
1. The game is ready to play from the launcher when the main menu appears.

## Linux Version: Mod install and running via Python scripts
1. Install speechd and python 3 through your distribution. Note that Instructions vary by distribution.
1. Use Git or GitHub CLI to get the launcher from the [Factorio-Access-Launcher repository](https://github.com/Factorio-Access/Factorio-Access-Launcher).
1. CD into the folder.
1. If you want to use a virtual python environment, or an executable, run build_main.py. If not, run pip to install requirements.txt by:  "pip install -r requirements.txt"
1. Run the executable or main.py
1. If it complains it can't find your Factorio installation then add the path to the Factorio executable as an argument when launching.

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

# Mod GUI and Basics

The mod has 3 major concepts:

- the cursor, "like the mouse", represents what you are "looking at".
- The hand, what you are holding/working with.
- The scanner, which represents map features.

You also have a body, the character. you need to keep the character in range of the cursor to build stuff.  Most players just teleport, `SHIFT  + T`, but if you prefer not to cheat `CTRL + ALT + RIGHT BRACKET` on a tile will walk you there if possible.

A full key list is provided below, and seems daunting but you can think of it like this.  The brackets `[]` are the "mouse".  Left bracket "clicks" and is indeed referred to that way, and right bracket is "right click".

There is a main UI opened with `e`, which contains all of the stuff you need to get started: your inventories (yes plural), crafting, research queue, etc.  Entity specific UIs are opened by clicking them with an empty hand.

To get started, what you want to do is scan `end`, then navigate through those results with `page up` and `page down`.  See the section on the scanner for more controls.  You can use this to find your initial ore patches, and yourt cursor will be moved to their center.

You are always controlling the cursor with WASD (NOTE for returning players: cursor mode is no longer a thing).  If you want to walk manually, you use the arrow keys.  You can toggle whether or not the cursor tries to stay one tile ahead of you by walking with I.

Larger summaries of areas are available ("contains 11% trees").  To get these, use `SHIFT + I` to enlarge your cursor, and `CTRL + I` to shrink it.  Larger cursors move by their size instead of by one tile, and summarize the contents of the covered region.

The two most useful features for scalable travel are the cursor bookmark (set with `SHIFT + B`, return with `B`) and the fast travel menu (open with `ALT + V`) which is like a list of favorites.

Most of the complexity of the mod is hidden away in GUIs.  As with most audiogames, we provide a dedicated spoken GUI and "screen reader".  The next section covers it conceptually.

# GUI Interaction

NOTE: unlike 1.1, the 2.0 version of the mod uses the same controls in all GUIs, and supports most controls everywhere

The mod's gui consists of two levels: tabs and controls.  Switch tabs with `CTRL + TAB` and switch controls with `TAB`.  UIs are opened in one of 3 ways.  `E` gets you to your UI with your inventory, crafting, etc. menus.  Clicking an entity in hand opens the UI relative to that entity.  And pressing `CTRL + ALT + L` with an entity selected opens the logistics GUI, a late game feature.

"controls" can be things like grids or menus.  You will mainly encounter 4 types:

- A grid like the inventory,which works how you think.
- A vertical menu, with horizontal rows of more than one item to group commands.
- Item/signal selectors, which are a tree of 2-4 levels (A/D changes category etc. and W/S moves betwqeen child and parent)
- A set of categorized rows like the crafting menu, where A/D move between items in a category and W/S move between categories.

All UIs use common controls:

- `[` "does the thing".  Picks up the entity from an inventory, turns something on, hits the button, etc.
- CTRL + WASD move "all the way" in a given direction. For example `CTRL + W` moves to the top of menus. To remember this, it's like `CTRL + HOME`.
- `CTRL + F` lets you search.  To move between results use `SHIFT + ENTER` (next) and `CTRL + ENTER` (previous).  For the curious, `F3` is taken by the game already.
- "non-dangerous delete" is backspace. For example fluid flushing. It "deletes things" when you can easily get them back.
- `CTRL + BACKSPACE` is "dangerous delete".  It deletes things like blueprints which you can't get back.

To better understand moving sideways in menus, think of it like this: moving up and down moves between items, and left/right is commands for that item.  As an example, fast travel entries expose their actions with left/right, and circuit network conditions are edited as a row of 4 items.  In these cases, the leftmost item is usually a summary or label for the row, and the rest of the row is what controls it.  This prevents horribly long menus like we had in 1.1, where you'd get 4 or 5 menu items just for one value.

When menus have one-offf keys, they usually have an instructional label telling you what you need to know. The one that doesn't and which deserves coverage is inventories.

Almost all entities have inventories.  These are things like crafting machine inputs and outputs.  This is the first tab as applicable.  These are a grid.  For a concrete example, an assembling machine 3 with a set recipe has an input, output, and modules inventory.  We also expose fluids on this tab, but that's less interesting: all you can do three is backspace to flush and read the contents.

When an entity has inventories, your inventory is open at the same time.  This can be reached with `CTRL + SHIFT + TAB` or by tabbing through all of the tabs to the last one.

You can move things between inventories the slow way, by getting them in hand or clicking a slot, or the fast way, with `SHIFT + BRACKETS`.  Left bracket moves the whjole stack (slot), right bracket moves half.  Whengoing from your inventory to the entity, it goes to the "main one" e.g. crafting machine input, car trunk, chest storage.  When moving from the entity, things always go to your main inventory.

For entities (including yourself) with weapons, this is also exposed as an inventory.  It is labeled differently however.  These are always a 3 column by 2 row grid in vanilla, where the top row is the weapon (if any) and the bottom row is the ammo for the weapon above it.

You often want to "use" an item, perform a context sensitive action.  This is always done with `CTRL + SHIFT + LEFT BRACKET`.  Some examples include equipping to the entity from a given slot or using a repair pack (which must already be in hand) on a damaged item in an inventory.

Chests, train cars, etc. can lock parts of their inventory starting from the end.  To control this use `+` and `-` with modifiers: CTRL to go "all the way" to 0 or max, or SHIFT to move by 5.

As one special exception and for historical reasons, inserter hand size is also handled with `+` and `-`.

Please also see the crafting and research controls below.  Those menus also have non-in-game controls that you need to know for the best experience.  Because they are visited so often, we do not provide in-game labels to remind you.

ADVANCED NOTE: circuit network configuration panels are available but only after the entity is in a circuit network.

# Key Reference

## General
Start playing when a new game begins: TAB

Open the main menu and close menus: E

Read the current menu name: SHIFT + E

Go back one level in a UI: alt+e

Save game: F1

Pause or unpause the game with the visual pause menu: SHIFT + ESC

Announce time of day, current research, and general save info: T

Check character health and shield level: G

Toggle Cursor Drawing: CONTROL + ALT + C. Note: This is enabled by Vanilla Mode by default, but it can be toggled separately for those who want it.

Toggle cursor hiding: CONTROL + ALT + C. This is for Vanilla Mode players who do not want to see the mod building previews.

Set standard zoom: ALT + Z

Set closest zoom: SHIFT + ALT + Z

Set furthest zoom: CONTROL + ALT + Z

Recalibrate zoom: CONTROL + END. This is rarely needed for resolving bugs related to zooming.

Console usage: Open with GRAVE, and then type the message and submit with ENTER.  Note: this is provided by vanilla and API limitations prevent us from offering good feedback.

## Tutorial

The tutorial system is unavailable and being rewritten.

## Movement

Movement: arrow keys

Nudge the character by 1 tile: CONTROL + ARROW KEY, with the corresponding key for that direction.

## Cursor and Coordinates
The cursor is like the mouse.  It is always controlled with W, A, S, and D.

Larger cursor sizes give area summaries and move by the larger size, and are also used to control placing tiles like concrete.

Move by cursor size: W, A, S, or D

Move up to 100 tiles, or until a change is detected: SHIFT + WASD

Move by the size of the building or blueprint in hand: CTRL + WASD

NOTE: For example, holding an assembler, `CTRL + D` and then `leftbracket` over and over builds a perfect line with no gaps.

Resize cursor: SHIFT + I and CONTROL + I

Move a larger cursor by 1 tile: CTRL + WASD

NOTE: moving a larger cursor by the size of the building rarely makes sense, so they use the same key.

Read cursor coordinates: K

Read cursor distance and direction from your character: SHIFT + K

Read character coordinates: CONTROL + K

Save cursor bookmark coordinates: SHIFT + B

Load cursor bookmark coordinates: B

Type in cursor coordinates to jump to: CTRL + ALT + T

Return the cursor to the character: J

Toggle whether the cursor moves in front of the character while walking: I

Teleport character to cursor: SHIFT + T

Force teleport character to cursor: CONTROL + SHIFT + T

Increase cursor size to examine a larger area: SHIFT + I

Decrease cursor size to examine a smaller area: CONTROL + I

Note: You must be in cursor mode for the size of the cursor to make any difference in area scans.

## Scanner
The scanner helps you find important things such as buildings and resource patches.  It consists of 3 levels:

- The category, "resources", "buildings", etrc.
- the subcategory, a certain kind of building, etc.
- The item you're on.

Scan for entities: END

Scan for entities in only the direction you are facing: SHIFT + END

Navigate scanner categories: PAGE UP and PAGE DOWN. Alternatively you can use ALT + UP ARROW and ALT + DOWN ARROW.

Repeat scanner list entry and move cursor to it: HOME

Switch between itemms in this subcategory: SHIFT + PAGE UP and SHIFT + PAGE DOWN.  Alternatively you can use ALT + SHIFT + UP ARROW and ALT + SHIFT + DOWN ARROW.

NOTE: when you move to a category, you are placed on the first item in it automatically, which is the closest to you as of the time of scanning.

Change scanner list filter category: CONTROL + PAGE UP and CONTROL + PAGE DOWN. Alternatively you can use ALT + CONTROL + UP ARROW and ALT + CONTROL + DOWN ARROW.

## Entity Manipulation
Entities are buildings, trees, etc.

Select an entity by moving the cursor on top of it, however you like to move the cursor.

Read other entities on the same tile, if any: SHIFT + F

Read its status: RIGHT BRACKET, for applicable buildings when your hand is empty

Open its menu: LEFT BRACKET

Remove red/green wires: ALT + N, if the entity has red/green wires.

Remove copper wires: ALT + N, if the entity only has copper wires.

E.G: on an electric pole, the first ALT + N removes red/green, the second removes copper wires.

Mine it or pick it up: X

Shoot at it: C (not recommended)

Rotate it clockwise: R. 

Rotate it counterclockwise: SHIFT + R

Rotation Note: If you have something in your hand, you will rotate that instead, and some buildings cannot be rotated after placing them down while others cannot be rotated at all. Rectangular buildings can only be flipped.

Nudge it by one tile: SHIFT + ARROW KEY, with the key for the corresponding direction.

Smart pipette/picker tool: For a selected entity, Q, with an empty hand. This brings to hand more of the selected entity's item form, if you have it in your inventory.

Copy its settings: apostrophe on the building

Paste its settings: semicolon on the building

Smart fill the entity with one stack: CTRL + LEFTBRACKET with items in hand. E>G. this will put ore in a furnace's input.

Smart fill the entity by half a stack: CTRL + RIGHTBRACKET with items in hand

Smart collect its entire output: With empty hand, CONTROL + LEFT BRACKET on the building

Smart collect half of its entire output: With empty hand, CONTROL + RIGHT BRACKET on the building

## Interactions with multiple entities on the Map
Collect nearby items from the ground or from belts: Hold F

Repair every machine within reach: CONTROL + SHIFT + LEFT BRACKET, while you have at least 2 repair packs in your hand

Area mining obstacles within 5 tiles: SHIFT + X. Affects trees, rocks, dropped items, scorch marks, remnants, all within a 5 tile radius.  NOTE: this is a cheat.

Area mining ghosts within 10 tiles: SHIFT + X, on a ghost.

Super area mining ghosts within 100 tiles: CONTROL + SHIFT + X, on a ghost.

Area mining everything marked for deconstruction within 5 tiles: SHIFT + X, with a deconstruction planner in hand (via ALT + D).  This is also a cheat.

## Audio Rulers

Place an audio ruler at the cursor: CONTROL + ALT + B

This forms a cross shape. Cursor skipping will stop at it, and you will hear a string pluck when either your cursor or character crosses it.

Clear the audio ruler: SHIFT + ALT + B

## Kruise Kontrol
Note: Kruise Kontrol is a different mod that we forked.  You can find our fork
[here](https://mods.factorio.com/mod/Kruise_Kontrol_Remote).

Initiate Kruise Kontrol at the cursor location: CONTROL + ALT + RIGHT BRACKET
Cancel Kruise Kontrol: ENTER

One of the following happens depending on where you put the cursor:
* On ground or other things Kruise Kontrol doesn't care about,move to the
  location.  This means walking or driving depending whether the character is in
  a vehicle at the time.  
* On trees or rocks: destroy the current one, then run around to the next one.
  It keeps going until it can't find anymore, which basically means forever.
* On ore patches: hand mines the ore.
* On ghosts: builds the ghosts. It will try to craft and take from chests if
  said chests are close enough.  If it seems stuck but still says it's building,
  it is probably trying to get resources off a belt by picking them up (same as
  using f yourself).  In this case, consider cancelling it and getting the
  resources yourself.
* On entities marked for upgrade or destruction: upgrade or destroy them.  When
  upgrading, the same logic as building applies for upgrades.  If it doesn't have entities it
  will try to get them one way or another.
* On hostile targets (enemies, spawners): kill things.

A few important things to consider:

* KK is faster than you if you have all needed items in your inventory.  You are
  faster than it if it can't use your inventory or a chest.  This is especially
  true if it is near belts without much on them.
* It will try to cut trees near the path of the character's walking.  This isn't
  just straight on in practice, it's also a couple tiles to the side.
* There are various range limits in it.  If it's not seeing a chest or doesn't
  build all ghosts, etc. that means it wandered too far from where you started
  it and they got out of range.  For ghosts and the like, trigger it again to
  finish.
* In combat it is terrible at healing you.  You must be able to survive at least
  a few seconds for it to decide to use fish.  It will also keep fighting
  forever until you die in most cases.  Be careful to cancel it.

## Hand Controls

Read what's in your hand: SHIFT + Q

Get hand item production info: U

Empty the hand to your inventory: Q

NOTE: when attaching wires, the first press of Q cancels connecting and the second empties your hand.

Smart pippette/picker tool: For a selected entity, Q, with an empty hand. This brings to hand more of the selected entity's item form, if you have it in your inventory.

Pick from the quickbar: NUMBER KEY, for keys 1 to 9 and 0.

Switch to a new quickbar page: SHIFT + NUMBER KEY, for keys 1 to 9 and 0.

Add hand item to quickbar: CONTROL + NUMBER KEY, for keys 1 to 9 and 0.

Drop 1 unit: Z. Drops the item onto the ground or onto a belt or inside an applicable building.

Set as entity filter, open offshore pump menu, or otherwise provide context sensitive action: ALT + LEFT BRACKET, for the item in hand.

Clear entity filter: ALT + LEFT BRACKET, with an empty hand.

## Building from the hand

Items in hand that can be placed will have their previews active

Place it: LEFT BRACKET, for items that support it

Place a ghost of it: SHIFT + LEFT BRACKET, for items that support it

Check building in hand preview dimensions: K

Check the selected part of a building on the ground: K


## Build Lock

In build lock, moving your cursor will place entities automatically.  So will walking.  For example, it places belts as if drawing the belt, places assemblers in perfect rows as you move 3 tiles, and places electric poles at their maximum wire reach.

Toggle build lock with CTRL + B.  It deactivates if you empty or change your hand's contents, run out of items, or bump into something.

## Blueprints and planner tools
Grab a new upgrade planner: ALT + U

Grab a new deconstruction planner: ALT + D

Grab a new blueprint planner: ALT + B

Grab a new blueprint book: CONTROL + SHIFT + ALT + B

Grab the copy-paste tool: CONTROL + C. Note: This creates a temporary blueprint in hand.

Grab the last copied area: CONTROL + V

Start and end planner area selection: LEFT BRACKET

Cancel selection: E

Rotate blueprint in hand: R

Flip blueprint in hand horizontal: H, if supported by all blueprint members

Flip blueprint in hand vertical: V, if supported by all blueprint members

Place blueprint in hand: LEFT BRACKET

Open options menu for blueprint in hand: RIGHT BRACKET

Add a blueprint to a book from the player inventory: RIGHT BRACKET with the book in hand

Delete the planner tool in hand: CTRL + BACKSPACE

## Circuit network interactions

Toggle a power switch or constant combinator: SHIFT + ENTER

Connect a wire in hand: LEFT BRACKET, if applicable

Open the alpha circuit navigatro: CTRL + N

## Floor pavings and thrown items

Pave the floor with bricks or concrete: With the paving item in hand, LEFT BRACKET. The brush size is the cursor size.

Pick up floor paving: With any bricks or concrete in hand: X. The brush size is the cursor size.

Place landfill over water: With landfill in hand, LEFT BRACKET.  The brush size is the cursor size.

Throw a capsule item at the cursor within range: With the item in hand, LEFT BRACKET. Warning: Throwing grenades will hurt you unless the cursor is moved far enough away.

## Guns and armor equipment

Swap gun in hand: TAB

Fire at the cursor: C. Warning: Friendly fire is allowed.

Fire at enemies with aiming assistance: SPACEBAR. Note: This only works when an enemy is within range, and only for pistols or submachine guns or rocket launchers with regular or explosive rockets. Other weapons such as shotguns, flamethrowers, and special rockets, will fire at the cursor because they do not have aiming assistance. 

Deploy a drone capsule in hand towards the cursor: LEFT BRACKET.

Throw a capsule weapon or grenade in hand towards the cursor: LEFT BRACKET. Note: Grenades use smart aiming to target enemies first and avoid you. 
Reload all ammo slots from the inventory: SHIFT + R

Return all guns and ammo to inventory: CONTROL + SHIFT + R

Read armor type and equipment stats: G

Read armor equipment list: SHIFT + G

Return all equipment and armor to inventory: CONTROL + SHIFT + G

## Fast travel

Open Fast Travel Menu: ALT + V

## Warnings

Warnings Menu: P

## Crafting menu

Check ingredients and products of a recipe: K

Check base ingredients of a recipe: SHIFT + K

Craft 1 item: LEFT BRACKET

Craft 5 items: RIGHT BRACKET

Craft as many items as possible:  CTRL + SHIFT + LEFT BRACKET

## Crafting queue menu

Navigate queue: W A S D

Unqueue 1 item: LEFT BRACKET

Unqueue 5 items: RIGHT BRACKET

Unqueue all items: CTRL + SHIFT + LEFT BRACKET

## Research Menu

Add a researchable tech to the front of the queue: LEFT BRACKET

Add a researchable tech to the back of the queue: CONTROL + LEFT BRACKET

To cancel researches, tab to the research queue and click the ones you want to cancel.

## Splitter interactions

Set input priority side: ALT + SHIFT + LEFT ARROW, or ALT + SHIFT + RIGHT ARROW. Press the same side again to reset to equal priority.

Set output priority side: ALT + CONTROL + LEFT ARROW, or ALT + CONTROL + RIGHT ARROW. Press the same side again to reset to equal priority.

Set item filter output side: ALT + CONTROL + LEFT ARROW, or ALT + CONTROL + RIGHT ARROW

Set an item filter: With the item in hand, ALT + LEFT BRACKET

Clear the item filter: With an empty hand, ALT + LEFT BRACKET
  
Copy and paste splitter settings: SHIFT + RIGHT BRACKET and then SHIFT + LEFT BRACKET


## Vehicles

Read fuel inventory: RIGHT BRACKET

Insert fuel: With the fuel stack in hand: CONTROL + LEFT BRACKET to insert all, or CONTROL + RIGHT BRACKET to insert half.

Insert ammo for any vehicle weapons: With the appropriate ammo stack in hand: CONTROL + LEFT BRACKET to insert all, or CONTROL + RIGHT BRACKET to insert half.

Enter or exit: ENTER

The following controls are for when driving:

Accelerate north/south/east/west: WASD, just like the cursor

Get heading and speed and coordinates: K

Get some vehicle info: Y

Read what is beeping due to collision threat: J

Fire selected vehicle weapon: SPACEBAR

Note: Machine guns and missiles automatically lock onto enemies and can be fired only then

Change selected vehicle weapon: TAB

## Spidertron remotes

Open remote menu: RIGHT BRACKET

Quick-set autopilot target position: LEFT BRACKET

Quick-add position autopilot target list: CONTROL + LEFT BRACKET

## Logistics requests
Open the logistics GUI: CTRL + ALT + L, with a logistics entity selected

this UI is large and exposes all logistic functionality, so you cannot get to it through the normal menus.

# Help and Support

If your question wasn't answered here or on our wiki, feel free to contact us at our [Discord server](https://discord.gg/CC4QA6KtzP).

# Changes

An updated changelog for the beta can be found [here](https://github.com/Factorio-Access/FactorioAccess/blob/main/CHANGES.md).
