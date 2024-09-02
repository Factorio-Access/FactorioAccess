# Welcome to Factorio Access BETA!

This is the BETA VERSION for an accessibility mod for the popular game Factorio. The goal of this mod is to make the game completely accessible to the blind and visually impaired. This beta version is the current main repository for the mod, while the original repository for the alpha version is on hold. This mod is an unofficial Factorio project by volunteers.

This "read me" file covers the basics of the mod, which include the installation guide, the mod controls, and links to other information sources.

# More info at the wiki

For information about the mod and the game, please check out our own [Factorio Access Wiki](https://github.com/Factorio-Access/FactorioAccess/wiki) being written by the developers.

Factorio also has an [official wiki](https://wiki.factorio.com/).

# Frequently Asked Questions
Please check the [Factorio Access Wiki main page](https://github.com/Factorio-Access/FactorioAccess/wiki) for frequently asked questions section.

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
1. Select "Download full game for Windows". This will download an exe file which is the setup application.
1. Run the exe file and follow the instructions.
1. All done! You need to install the mod next.

## Linux Version
1. Go to https://www.factorio.com/download
1. If needed, login using your Factorio account or Steam account.
1. Among the install options, find the stable releases at the top half of the page.
1. Go to the section with "Other download options" and select "Download full game for Linux". This will download a tar.xz file.
1. Move the file to the directory where you want to install the game.
1. Extract the game from the file using a program such as 7zip.
1. All done! You need to install the mod next.

# Installing Factorio Access (Windows)

To install a mod release, follow the instructions below:

## Mod release install for Factorio Windows Zip version
1. Download the latest release zip file such as "Factorio_Access_Beta_0_X_X.zip" from the releases page here: https://github.com/Factorio-Access/FactorioAccess/releases. There are other files that you can download there but you need only the one mentioned. You may get a security warning about downloading an unlicensed application, which is true for the mod launcher. For safety reasons, please do not download the mod launcher from anywhere else.
1. Put the zip file in an empty folder and extract its contents. You should find a folder named "Factorio_Access_Beta_content". You need to open it and copy everything inside of it. These contents should include the mod's own launcher called "launcher.exe" as well as a "mods" folder and a "Factorio.jkm" file.
1. Navigate to your Factorio standalone folder, with a name such as "Factorio_1.1.101". This is your Factorio game data folder.
1. Make sure you copied all of the contents in Step 2 and paste them into the Factorio game data folder you found in Step 3.
1. The mod is now installed, but you need to configure it. Note that the game is both configured and played using "launcher.exe", which is necessary for the mod to read out the game. If you want, you can create a shortcut for this launcher.
1. If you are a jaws user for screen reading, you may want to copy Factorio.jkm file into your JAWS settings folder, which is found in the AppData folder. An example file path is `C:\Users\Your_User_Name_Here\AppData\Roaming\Freedom Scientific\JAWS\2022\Settings\enu\`
1. You can run the mod launcher directly or in administrator mode if needed. Running it the first time will generate a Windows security warning because you are running an unlicensed application.
1. Follow the mod launcher instructions while the game is configured. This may involve launching the game itself temporarily.
1. The game is ready to play from the launcher when the main menu appears.


## Mod release install for Factorio Steam version or regular Windows version
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

# Installing Factorio Access (Linux)
1. Install speechd and python 3 through your distribution. Note that Instructions vary by distribution.
1. Clone the launcher mod from GitHub.
1. CD into the folder.
1. If you want to use a virtual python environment, or an executable, run build_main.py. If not, run pip to install requirements.txt by:  "pip install -r requirements.txt"
1. Run the executable or main.py
1. If it complains it can't find your Factorio installation then add the path to the Factorio executable as an argument when launching.

# Factorio Access Controls

## General
Start playing when a new game begins: TAB

Repeat last spoken phrase: CONTROL + TAB

Start tutorial or read tutorial step: H

Close most menus: E

Read the current menu name: SHIFT + E

Save game: F1

Pause or unpause the game with the visual pause menu: ESC

Time of day and current research and total mission time: T

Check character health and shield level: G

Toggle Vanilla Mode: CONTROL + ALT + V. Note that this will mute the narrator until you toggle back out.

Toggle Cursor Drawing: CONTROL + ALT + C. Note: This is enabled by Vanilla Mode by default, but it can be toggled separately for those who want it.

Toggle cursor hiding: CONTROL + ALT + C. This is for Vanilla Mode players who do not want to see the mod building previews.

Clear all renders: CONTROL + ALT + R. Note: This is rarely needed for clearing any mod-drawn objects that fail to disappear on their own.

Set standard zoom: ALT + Z

Set closest zoom: SHIFT + ALT + Z

Set furthest zoom: CONTROL + ALT + Z

Recalibrate zoom: CONTROL + END. This is rarely needed for resolving bugs related to zooming.

## Tutorial

Read current step: H

Read current summary and step number: ALT + H

Read next step: CONTROL + H

Read previous step: SHIFT + H

Read next chapter: ALT + CONTROL + H

Read previous chapter: ALT + SHIFT + H

Toggle summary mode: CONTROL + SHIFT + H

Read current step details in summary mode: ALT + H

Refresh the tutorial: ALT + SHIFT + H repeatedly until you reach the top

## Movement

Movement: W, A, S, D

Note: When you change direction in the default (telestep) walking mode, for the first key press, your character turns but does not take a step in that direction.

Toggle walking mode: ALT + W

Note the 3 movement types are as follows:

   1- Telestep: Press a direction to turn in that direction, then continue pressing in that direction to move.

   2- Step-By-Walk:  Temporarily removed. This mode is similar to Telestep, however the player character will physically take steps in the direction chosen.  The biggest difference is footsteps.

   3- Smooth-Walking: In this mode the character will move similarly to in a sighted game. The player will be notified if they run into something, but otherwise will not be notified of entities they are passing. Very fast, and great for getting around!

Nudge the character by 1 tile: CONTROL + ARROW KEY, with the corresponding key for that direction.

## Coordinates
Read cursor coordinates: K

Read cursor distance and direction from your character: SHIFT + K

Read character coordinates: CONTROL + K

Save cursor bookmark coordinates: SHIFT + B

Load cursor bookmark coordinates: B

Type in cursor coordinates to jump to: ALT + T

## Scanner Tool
Entities in the world get indexed by the scanner tool when you run a scan. If there are multiple instances of the same entity, they tend to be grouped in the same scanner list entry.

Scan for entities: END

Scan for entities in only the direction you are facing: SHIFT + END

Navigate scanner list entries: PAGE UP and PAGE DOWN. Alternatively you can use ALT + UP ARROW and ALT + DOWN ARROW.

Repeat scanner list entry: HOME

Switch between different instances of the same entry: SHIFT + PAGE UP and SHIFT + PAGE DOWN.  Alternatively you can use ALT + SHIFT + UP ARROW and ALT + SHIFT + DOWN ARROW.

Change scanner list filter category: CONTROL + PAGE UP and CONTROL + PAGE DOWN. Alternatively you can use ALT + CONTROL + UP ARROW and ALT + CONTROL + DOWN ARROW.

Sort scan results by distance from current character location: N. If you change location, you need to press again.

Sort scan results by total counts: SHIFT + N

## Interactions with one entity
Select an entity by moving the cursor on top of it. This includes selecting it from the scanner list.

Read other entities on the same tile, if any: SHIFT + F

Get its description: Y, for most entities or items. 

Get the description for the current scanner entry: SHIFT + Y

Read its status: RIGHT BRACKET, for applicable buildings when your hand is empty

Open its menu: LEFT BRACKET

Open its circuit network menu: N, if connected to a network

Mine it or pick it up: X

Shoot at it: C (not recommended)

Rotate it: R. 

Rotation Note: If you have something in your hand, you will rotate that instead, and some buildings cannot be rotated after placing them down while others cannot be rotated at all. Rectangular buildings can only be flipped.

Nudge it by one tile: SHIFT + ARROW KEY, with the key for the corresponding direction.

Smart pipette/picker tool: For a selected entity, Q, with an empty hand. This brings to hand more of the selected entity's item form, if you have it in your inventory.

Copy its settings: With empty hand, SHIFT + RIGHT BRACKET on the building

Paste its settings: With empty hand, SHIFT + LEFT BRACKET on the building

Smart collect its entire output: With empty hand, CONTROL + LEFT BRACKET on the building

Smart collect half of its entire output: With empty hand, CONTROL + RIGHT BRACKET on the building

## Interactions with multiple entities
Collect nearby items from the ground or from belts: Hold F

Repair every machine within reach: CONTROL + SHIFT + LEFT BRACKET, while you have at least 2 repair packs in your hand

Area mining obstacles within 5 tiles: SHIFT + X. Affects trees, rocks, dropped items, scorch marks, remnants, all within a 5 tile radius. 

Area mining rail objects within 10 tiles: SHIFT + X, on a rail.

Area mining ghosts within 10 tiles: SHIFT + X, on a ghost.

Area mining everything marked for deconstruction within 5 tiles: SHIFT + X, with a deconstruction planner in hand (via ALT + D).

Start instant mining tool: CONTROL + X. When you are holding this tool, everything the cursor touches is mined instantly.

Area mining everything within 5 tiles: SHIFT + X with the instant mining tool in hand. Note: This does not include ores.

Stop instant mining tool: Q

## Inventory

Open player inventory: E

Navigate inventory slots: W A S D

Get slot coordinates: K

Take selected item to hand: LEFT BRACKET

Get selected item description: Y

Get selected item logistic requests info: L

Get selected item production info: U

Set or unset inventory slot filter: ALT + LEFT BRACKET. Note: This applies for player and vehicle cargo inventories. The item in the slot or otherwise the item in hand is used to set the filter.

Pick an item from quickbar: NUMBER KEY, for keys 1 to 9 and 0.

Switch to a new quickbar page: SHIFT + NUMBER KEY, for keys 1 to 9 and 0.

Add selected item to quickbar: CONTROL + NUMBER KEY, for keys 1 to 9 and 0. Note: hand items have priority.

Switch to other menus: TAB

Close most menus: E

Select the inventory slot for the item in hand: CONTROL + Q

Select the crafting menu recipe for the item in hand: CONTROL + SHIFT + Q

## Cursor

Read cursor coordinates: K. If the cursor is over an entity, its relative location upon the entity is read out, such as the Southwest corner.

Read character coordinates: CONTROL + K

Read cursor distance and direction from character: SHIFT + K

Read vector for cursor distance and direction from character: ALT + K

Enable or disable cursor mode: I

Move cursor freely in cursor mode, by cursor size distance: W A S D

Move cursor freely in cursor mode, by always one tile distance: ARROW KEYS

Skip the cursor over repeating entities and across underground sections: SHIFT + W A S D. Alternatively NUMPAD KEYS 2 4 6 8.

Move the cursor by the size of the blueprint or preview in hand: CONTROL + W A S D. Alternatively CONTROL + NUMPAD KEYS 2 4 6 8.

Return the cursor to the character: J

Toggle remote view: ALT + I. 

Note: Remote View is an extension of Cursor Mode where the camera focuses on the cursor instead of the player character. It is required for a few actions and it allows you to hear the goingson at the cursor location.

Teleport character to cursor: SHIFT + T

Force teleport character to cursor: CONTROL + SHIFT + T

Increase cursor size to examine a larger area: SHIFT + I

Decrease cursor size to examine a smaller area: CONTROL + I

Note: You must be in cursor mode for the size of the cursor to make any difference in area scans.

Save cursor bookmark coordinates: SHIFT + B

Load cursor bookmark coordinates: B

Type in cursor coordinates to jump to: ALT + T


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

See the mod's [wiki chapter on Kruise Kontrol](https://github.com/Factorio-Access/FactorioAccess/wiki/Chapter-27-%E2%80%90-Kruise-Kontrol) for more info.

## Item in hand

Read item in hand: SHIFT + Q

Get hand item description: Y

Get hand item logistic requests info: L

Get hand item production info: U

Empty the hand to your inventory: Q

Smart pippette/picker tool: For a selected entity, Q, with an empty hand. This brings to hand more of the selected entity's item form, if you have it in your inventory.

Select the player inventory slot for the item in hand: CONTROL + Q

Select the crafting menu recipe for the item in hand: CONTROL + SHIFT + Q

Pick from the quickbar: NUMBER KEY, for keys 1 to 9 and 0.

Switch to a new quickbar page: SHIFT + NUMBER KEY, for keys 1 to 9 and 0.

Add hand item to quickbar: CONTROL + NUMBER KEY, for keys 1 to 9 and 0.

Drop 1 unit: Z. Drops the item onto the ground or onto a belt or inside an applicable building.

Insert 1 stack of the item in hand where applicable: CONTROL + LEFT BRACKET. Works for chests or for smartly feeding machines and vehicles.

Insert half a stack of the item in hand where applicable: CONTROL + RIGHT BRACKET. Works for chests or for smartly feeding machines and vehicles.

## Building from the hand

Items in hand that can be placed will have their previews active

Place it: LEFT BRACKET, for items that support it

Place a ghost of it: SHIFT + LEFT BRACKET, for items that support it

Alternative build command: CONTROL + LEFT BRACKET

Steam engine snapped placement to a nearby boiler: CONTROL + LEFT BRACKET

Rail unit placement to start a new rail line: CONTROL + LEFT BRACKET

Check building in hand preview dimensions when in Cursor Mode: K

Check the selected part of a building on the ground: K

Toggle build lock for continuous building: CONTROL + B. It is also turned off while switching cursor modes or emptying the hand.

Rotate hand item: R. 

## Blueprints and planner tools
Grab a new upgrade planner: ALT + U

Grab a new deconstruction planner: ALT + D

Grab a new blueprint planner: ALT + B

Grab a new blueprint book: CONTROL + SHIFT + ALT + B

Grab the copy-paste tool: CONTROL + C. Note: This creates a temporary blueprint in hand.

Grab the last copied area: CONTROL + V

Start and end planner area selection: LEFT BRACKET

Cancel selection: Q

Rotate blueprint in hand: R

Flip blueprint in hand horizontal: F, if supported by all blueprint members

Flip blueprint in hand vertical: G, if supported by all blueprint members

Place blueprint in hand: LEFT BRACKET

Open options menu for blueprint in hand: RIGHT BRACKET

Open options menu for blueprint book in hand: RIGHT BRACKET

Open list menu for blueprint book in hand: LEFT BRACKET

Add a blueprint to a book from the player inventory: RIGHT BRACKET with the book in hand

Copy into hand a temporary blueprint from the book list menu: LEFT BRACKET

Delete a blueprint from the book list menu: X

Delete the planner tool in hand: DELETE (press again to confirm it).

## Circuit network interactions

Toggle a power switch or constant combinator: LEFT BRACKET

Connect a wire in hand: LEFT BRACKET, if applicable

Open circuit network menu: LEFT BRACKET, if applicable

Signal selector: Open menu search: CONTROL + F

Signal selector: Run menu search forward: SHIFT + ENTER

## Floor pavings and thrown items

Resize cursor: SHIFT + I and CONTROL + I

Pave the floor with bricks or concrete: With the paving item in hand, LEFT BRACKET. The brush size is the cursor size.
  
Pick up floor paving: With any bricks or concrete in hand: X. The brush size is the cursor size.
  
Place landfill over water: With landfill in hand, LEFT BRACKET.  The brush size is the cursor size.
  
Throw a capsule item at the cursor within range: With the item in hand, LEFT BRACKET. Warning: Throwing grenades will hurt you unless the cursor is moved far enough away.

## Guns and armor equipment

Swap gun in hand: TAB
  
Fire at the cursor: C. Warning: Friendly fire is allowed.
  
Fire at enemies with aiming assistance: SPACEBAR. Note: This only works when an enemy is within range, and only for pistols or submachine guns or rocket launchers with regular rockets. Other weapons such as shotguns, flamethrowers, and special rockets, will fire at the cursor because they do not have aiming assistance. 

Deploy a drone capsule in hand towards the cursor: LEFT BRACKET.

Throw a capsule weapon or grenade in hand towards the cursor: LEFT BRACKET. Note: Grenades use smart aiming to target enemies first and avoid you.

The rest of the controls in this section require you to have the inventory screen opened (but no buildings).

Equip a gun or ammo stack: LEFT BRACKET to take it in hand and SHIFT + LEFT BRACKET to equip it.
  
Open guns (and ammo) inventory: R, from the player inventory
  
Reload all ammo slots from the inventory: SHIFT + R
  
Return all guns and ammo to inventory: CONTROL + SHIFT + R
  
Equip an armor suit or armor equipment module: LEFT BRACKET to take it in hand and SHIFT + LEFT BRACKET to equip it.
  
Read armor type and equipment stats: G
  
Read armor equipment list: SHIFT + G
  
Return all equipment and armor to inventory: CONTROL + SHIFT + G

## Fast travel

Open Fast Travel Menu: V

Select a fast travel point:  W and S

Select an option: A and D

Check relative distance: SHIFT + K

Check relative distance vector: ALT + K

Confirm an option: LEFT BRACKET

Note:  Options include Teleporting to a saved point, renaming a saved point, deleting a saved point, and creating a new point.

Confirm a new name: ENTER

## Structure travel

Travel freely from building to building as if they were laid out in a grid pattern. Also known as B-Stride. 

Warning: This feature has some bugs and is currently deprecated.

Open it with ALT + CONTROL + SHIFT + S, and explore your factory with the following controls:

First, select a direction using WASD

Next navigate the list of adjacent buildings with the two perpendicular directions.  For instance, if you are going North, then use the A and D keys to select a building from the list.

Last, confirm your selection by pressing the direction you started with.  For instance, if I wanted to go to the 2nd item in the northern list I would hit W to go north, D to select option 2, and W again to confirm.

Once you find your target, press LEFT BRACKET to teleport your character to the building.

## Warnings

Warnings Menu: P

Navigate woarnings menu:    WASD to navigate a single range

Switch Range: TAB

Teleport cursor to Building with warning: LEFT BRACKET

Close Warnings menu: E

Teleport to the location of the last damage alert: CONTROL + SHIFT + P

## While in a menu

Read menu name: SHIFT + E

Close menu: E

Change tabs within a menu: TAB, or SHIFT + TAB

Navigate inventory slots: W A S D

Coordinates of current inventory slot: K

Check ingredients and products of a recipe: K

Selected item information: Y

Grab item in hand: LEFT BRACKET

Smart Insert/Smart Withdrawal: SHIFT + LEFT BRACKET

Note: This will insert an item stack, or withdraw an item stack from a building. It is smart because it will decide the proper inventory to send the item to.  For instance, smart inserting coal into a furnace will attempt to put it in the fuel category, as opposed to the input category.

Multi stack smart transfer: CONTROL + LEFT BRACKET

Note: When you have a building inventory open, pressing CONTROL + LEFT BRACKET for a selected item in an inventory will cause an attempt to transfer the entire supply of this item to the other inventory. Non-transferred items will remain in their original inventory. Similarly, pressing CONTROL + RIGHT BRACKET will try to transfer half of the entire supply of the selected item.

Note 2: When you have a building inventory open and select an empty slot, pressing CONTROL + LEFT BRACKET will cause an attempt to transfer the full contents of the selected inventory into the other inventory. This is useful for easily filling up labs and assembling machines with everything applicable from your own inventory instead of searching for items individually. Non-transferred items will remain in their original inventory. Similarly, pressing CONTROL + RIGHT BRACKET on an empty slot will try to transfer half of the entire supply of every item.

Open menu search: CONTROL + F. This works for player inventories, building output inventories, building recipe selection, the crafting menu, and the technology menu.

Run menu search forward: SHIFT + ENTER

Run menu search backward: CONTROL + ENTER, only for inventories.

Flush away a selected fluid: X

## Special controls for some building menus

For chests, modify inventory slot limits: PAGE UP or PAGE DOWN. Alternatively: ALT + UP or ALT + DOWN.

Note: You can hold SHIFT to modify slot limits by increments of 5 instead of 1, and you can hold CONTROL to set the limit to maximum or zero.

For inserters, modify the hand stack size: PAGE UP or PAGE DOWN. Alternatively: ALT + UP or ALT + DOWN.

For buildings that can use the circuit network system, open the circuit network menu: N

For rocket silos, launch the rocket: SPACEBAR

For rocket silo, toggle automatic launching when there is any cargo: SHIFT + SPACEBAR. Alternatively: CONTROL + SPACEBAR.

## Crafting menu

Navigate recipe groups: W S

Navigate recipes within a group: A D

Check ingredients and products of a recipe: K

Check base ingredients of a recipe: SHIFT + K

Read recipe product description: Y

Craft 1 item: LEFT BRACKET

Craft 5 items: RIGHT BRACKET

Craft as many items as possible:  SHIFT + LEFT BRACKET

Open menu search: CONTROL + F

Run menu search forward: SHIFT + ENTER

## Crafting queue menu

Navigate queue: W A S D

Unqueue 1 item: LEFT BRACKET

Unqueue 5 items: RIGHT BRACKET

Unqueue all items: SHIFT + LEFT BRACKET

## In item selector submenu (alternative)

Select category: LEFT BRACKET or S

Jump to previous category level: W

Select category from currently selected tier: A and D

## Splitter interactions

Set input priority side: ALT + SHIFT + LEFT ARROW, or ALT + SHIFT + RIGHT ARROW. Press the same side again to reset to equal priority.
  
Set output priority side: ALT + CONTROL + LEFT ARROW, or ALT + CONTROL + RIGHT ARROW. Press the same side again to reset to equal priority.
  
Set an item filter: With the item in hand, CONTROL + LEFT BRACKET
  
Set item filter output side: ALT + CONTROL + LEFT ARROW, or ALT + CONTROL + RIGHT ARROW
  
Set an item filter: With the item in hand, CONTROL + LEFT BRACKET
  
Clear the item filter: With an empty hand, CONTROL + LEFT BRACKET
  
Copy and paste splitter settings: SHIFT + RIGHT BRACKET and then SHIFT + LEFT BRACKET

## Rail building and analyzing

Rail unrestricted placement: Press CONTROL + LEFT BRACKET with rails in hand to place down a single straight rail.

Rail appending: Press LEFT BRACKET with rails in hand to automatically extend the nearest end rail by one unit. Also accepts RIGHT BRACKET.

Rail structure building menu: Press SHIFT + LEFT BRACKET on any rail, but end rails have the most options. Structures include turns, train stops, etc.

Rail intersection finder: RIGHT BRACKET on a rail to find the nearest intersection.

Rail analyzer UP: Press SHIFT + J with empty hand on any rail to check which rail structure is UP along the selected rail. Note: This cannot detect trains!

Rail analyzer DOWN: Press CONTROL + J with empty hand on any rail to check which rail structure is DOWN along the selected rail. Note: This cannot detect trains!

Station rail analyzer: Select a rail behind a train stop to hear corresponding the station space. Note: Every rail vehicle is 6 tiles long and there is one tile of extra space between each vehicle on a train.

Note 1: When building parallel rail segments, it is recommended to have at least 4 tiles of space between them in order to leave space for infrastructure such as rail signals, connecting rails, or crossing buildings.

Note 2: In case of bugs, be sure to save regularly. There is a known bug related to extending rails after building a train stop on an end rail.

Shortcut for building rail right turn 45 degrees: ALT + RIGHT ARROW on an end rail.

Shortcut for building rail left turn 45 degrees: ALT + LEFT ARROW on an end rail.

Shortcut for picking up all rails and signals within 7 tiles: SHIFT + X on a rail.

## Train building and examining

Place rail vehicles: LEFT BRACKET on an empty rail with the vehicle in hand and facing a rail. Locomotives snap into place at train stops. Nearby vehicles connect automatically to each other upon placing.

Manually connect rail vehicles: CONTROL + G while selecting it

Manually disconnect rail vehicles: SHIFT + G while selecting it

Flip direction of a rail vehicle: SHIFT + R on the vehicle, but it must be fully disconnected first.

Open train menu: LEFT BRACKET on the train's locomotives

Train vehicle quick info: Y

Examine locomotive fuel tank contents: RIGHT BRACKET. 

Examine cargo wagon or fluid wagon contents: RIGHT BRACKET. Note that items can for now be added or removed only via cursor shortcuts or inserters.

Add fuel to a locomotive: With fuel items in hand, CONTROL + LEFT BRACKET on the locomotive

## Train menu
Move up: UP ARROW KEY

Move down: DOWN ARROW KEY

Click or select: LEFT BRACKET

Increase station waiting times by 5 seconds: PAGE UP. Alternatively: ALT + UP.

Increase station waiting times by 60 seconds: CONTROL + PAGE UP

Decrease station waiting times by 5 seconds: PAGE DOWN. Alternatively: ALT + DOWN.

Decrease station waiting times by 60 seconds: CONTROL + PAGE DOWN

## Driving locomotives

Read fuel inventory: RIGHT BRACKET
  
Insert fuel: With the fuel stack in hand: CONTROL + LEFT BRACKET to insert all, or CONTROL + RIGHT BRACKET to insert half.
  
Insert ammo for any vehicle weapons: With the appropriate ammo stack in hand: CONTROL + LEFT BRACKET to insert all, or CONTROL + RIGHT BRACKET to insert half.
  
Enter or exit: ENTER

The following controls are for when driving:

Accelerate forward (or break): Hold W
  
Accelerate backward (or break): Hold S
  
Steer left or right: A or D. Not needed to make trains go around turns.
  
Get heading and speed and coordinates: K
  
Get some vehicle info: Y

Read what is beeping due to collision threat: J
  
Read the first rail structure ahead: SHIFT + J
  
Read the first rail structure behind: CONTROL + J

Read the precise distance to a nearby train stop for manual alignment: SHIFT + J

Honk the horn: ALT + W
  
Open the train menu: LEFT BRACKET. Navigate with ARROW KEYS.

## Driving ground vehicles

Read fuel inventory: RIGHT BRACKET
  
Insert fuel: With the fuel stack in hand: CONTROL + LEFT BRACKET to insert all, or CONTROL + RIGHT BRACKET to insert half.
  
Insert ammo for any vehicle weapons: With the appropriate ammo stack in hand: CONTROL + LEFT BRACKET to insert all, or CONTROL + RIGHT BRACKET to insert half.
  
Enter or exit: ENTER

The following controls are for when driving:

Accelerate forward (or break): Hold W
  
Accelerate backward (or break): Hold S
  
Steer left or right: A or D. Not needed to make trains go around turns.
  
Get heading and speed and coordinates: K
  
Get some vehicle info: Y

Read what is beeping due to collision threat: J
  
Honk the horn: V

Toggle cruise control: O

Change cruise control speed: CONTROL + O

Note: Recommended speeds are between 25 and 70 units

Toggle pavement driving assistant: L

Note: The diriving assistant must have a paved road to follow out of bricks or concrete, with short diagonal sections to soften the 90 degree turns. 

Fire selected vehicle weapon: SPACEBAR

Note: Machine guns and missiles automatically lock onto enemies and can be fired only then

Change selected vehicle weapon: TAB

## Spidertron remotes

Open remote menu: RIGHT BRACKET

Quick-set autopilot target position: LEFT BRACKET

Quick-add position autopilot target list: CONTROL + LEFT BRACKET

## Logistics requests

Read the logistic requests summary for a player or chest or vehicle: L

For the selected item, read the logistic request status: L

For the selected item, increase minimum request value: SHIFT + L

For the selected item, decrease minimum request value: CONTROL + L

For the selected item, increase maximum request value: ALT + SHIFT + L, available for personal requests only

For the selected item, decrease maximum request value: ALT + CONTROL + L, available for personal requests only

For the selected item, clear the logistic request entirely: ALT + CONTROL + SHIFT + L

For the selected item, send it to logistic trash: O

For the selected item in logistic trash, take it back into inventory: LEFT BRACKET and then Q

For personal logistics, pause or unpause all requests: CONTROL + SHIFT + L. Alternatively: ALT + L.

For a logistic storage chest, set or unset the filter to the selected item: SHIFT + L

For a logistic requester chest, toggle requesting from buffer chests: CONTROL + SHIFT + L

## Using the screen reader

The screen reader, such as for NVDA, can be used but it is generally not that helpful during gameplay because in-game menus heavily use visual icons and graphs instead of text. We are designing the mod to require the screen reader as little as possible. However, the screen reader is necessary in the following situtaions: When the game crashes, when your character dies, when you win a game, and optionally when you pause the game.

# Help and Support

If your question wasn't answered here or on our wiki, feel free to contact us at our [Discord server](https://discord.gg/CC4QA6KtzP).

# Changes

An updated changelog for the beta can be found [here](https://github.com/Factorio-Access/FactorioAccess/blob/main/CHANGES.md).



# Donations

While this mod is completely free for all, our small team of volunteers is working on this mod in their free time and our main developer is a full time student.

If you are so inclined, you can donate at our [Patreon page](https://www.patreon.com/Crimso777).
