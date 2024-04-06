# Welcome to Factorio Access BETA!

This is the BETA VERSION for an accessibility mod for the popular game Factorio. The goal of this mod is to make the game completely accessible to the blind and visually impaired. This beta version is the current main repository for the mod, while the original repository is on hold.

This "read me" file covers the basics of the mod, which include the installation guide, the mod controls, and links to other information sources.

# Installing Factorio (Windows)
The game can be purchased from Factorio.com or from Steam. We recommend installing it using ONLY one of the three options below.

## Windows Zip Version / Standalone Version (recommended for easy install and troubleshooting)
1. Go to https://www.factorio.com/download
2. If needed, login using your Factorio account or Steam account.
3. Among the install options, select the Windows zip package, also called the manual install. Note that this is different from the regular Windows version. Selecting the zip version will download a zip file that is about 1.5 gigabytes in size.
4. Create a folder where you want to keep the game. Extract the zip file into this folder.
5. If you want, create a desktop shortcut for your Factorio folder.
6. All done! You need to install the mod next.

## Steam Version (recommended for easy multiplayer setup)
1. Install Factorio using Steam settings, like any other game on Steam.
2. That is it, pretty much. You next need to install the mod next and then configure Steam settings.

## Regular Windows Version (not recommended)
1. Go to https://www.factorio.com/download
2. If needed, login using your Factorio account or Steam account.
3. Among the install options, select the Windows the normal Windows version. This will download an exe file which is the setup application.
4. Run the exe file and follow the instructions.
5. All done! You need to install the mod next.


# Installing Factorio Access (Windows)

To install a mod release, follow the instructions below:

## Mod release install for Factorio Windows Zip version
1. Download the latest release zip file such as "Factorio_Access_Beta_0_X_X.zip" from the releases page here: https://github.com/LevFendi/Factorio-Access/releases. There are other files that you can download there but you need only the one mentioned. You may get a security warning about downloading an unlicensed application, which is true for the mod launcher. For safety reasons, please do not download the mod launcher from anywhere else.
2. Put the zip file in an empty folder and extract its contents. You should find a folder named "Factorio_Access_Beta_content". You need to open it and copy everything inside of it. These contents should include the mod's own launcher called "launcher.exe" as well as a "mods" folder and a "Factorio.jkm" file.
3. Navigate to your Factorio standalone folder, with a name such as "Factorio_1.1.101". This is your Factorio game data folder.
4. Make sure you copied all of the contents in Step 2 and paste them into the Factorio game data folder you found in Step 3.
5. The mod is now installed, but you need to configure it. Note that the game is both configured and played using "launcher.exe", which is necessary for the mod to read out the game. If you want, you can create a shortcut for this launcher.
6. If you are a jaws user for screen reading, you may want to copy Factorio.jkm file into your JAWS settings folder, which is found in the AppData folder. An example file path is `C:\Users\Your_User_Name_Here\AppData\Roaming\Freedom Scientific\JAWS\2022\Settings\enu\`
7. You can run the mod launcher directly or in administrator mode if needed. Running it the first time will generate a Windows security warning because you are running an unlicensed application.
8. Follow the mod launcher instructions while the game is configured. This may involve launching the game itself temporarily.
9. The game is ready to play from the launcher when the main menu appears.


## Mod release install for Factorio Steam version or regular Windows version
1. Download the latest release zip file such as "Factorio_Access_Beta_0_X_X.zip" from the releases page here: https://github.com/LevFendi/Factorio-Access/releases. There are other files that you can download there but you need only the one mentioned. You may get a security warning about downloading an unlicensed application, which is true for the mod launcher. For safety reasons, please do not download the mod launcher from anywhere else.
2. Put the zip file in an empty folder and extract its contents. You should find a folder named "Factorio_Access_Beta_content". You need to open it and copy everything inside of it. These contents should include the mod's own launcher called "launcher.exe" as well as a "mods" folder and a "Factorio.jkm" file.
3. Navigate to your Factorio game data folder. This is inside a special Windows folder called "AppData". There are two ways to access the AppData folder, you either enter its short name using % signs, or you use the full path name. If you use the short name with the signs, the path is called `%AppData%/Factorio`. If you use the full path, the path depends on your windows user name and it is something like `C/Users/Your_User_Name_Here/AppData/Roaming/Factorio`.
4. Make sure you copied all of the contents in Step 2 and paste them into the Factorio game data folder you found in Step 3.
5. The mod is now installed, but you still need to configure Steam and also the mod itself. Note that the game is both configured and played using "launcher.exe", which is necessary for the mod to read out the game. If you want, you can create a shortcut for this launcher.
6. If you are a jaws user for screen reading, you may want to copy Factorio.jkm file into your JAWS settings folder, which is found in the AppData folder. An example file path is `C:\Users\Your_User_Name_Here\AppData\Roaming\Freedom Scientific\JAWS\2022\Settings\enu\`
7. You can run the mod launcher directly or in administrator mode if needed. Running it the first time will generate a Windows security warning because you are running an unlicensed application.
8. The first time you run the launcher, it will ask you to configure Steam launch settings. It will ask you to copy a setup text string. This string should include the path location of the mod launcher application in quotation marks, and also the string "%command%". For example, the setup text string in total could be ` "C:\Users\Your_User_Name_Here\AppData\Roaming\Factorio\launcher.exe" %command% `.
9. Open your Steam Library and find the Factorio page.
10. Find the Properties menu for Factorio. On the Steam Library, the Proprties menu for a game can be opened by finding the game's name in the library list, and then right clicking it to open the context menu, and then selecting the last option called "Properties...". Alternatively, you can open the game's page in the Steam Library and open the "Manage" menu, which is denoted by a gear symbol that you can left click. From the "Manage" menu you can select the last option called "Properties..."
11. When the Properties menu is open, you should be immediately at the "General" section. At the bottom of this section is the part called "Launch Options" with a text field that you can type in. Here, you need paste the mod launcher setup text string that you copied earlier.
12. Try launching the game from Steam. This should now run the mod launcher instead, and say "Hello Factorio". If not setup correctly, the game might launch directly and you will hear music.
13. Follow the mod launcher instructions while the game is configured. This may involve launching the game itself temporarily.
14. The game is ready to play from the launcher when the main menu appears.

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

Toggle Vanilla Mode: CONTROL + ALT + V. Note that this will mute the narrator until you toggle back out.

Toggle Cursor Drawing: CONTROL + ALT + C. Note: This is enabled by Vanilla Mode by default, but it can be toggled separately for those who want it.

Toggle cursor hiding: CONTROL + ALT + C. This is for Vanilla Mode players who do not want to see the mod building previews.

Clear all renders: CONTROL + ALT + R. Note: This is for clearing any mod-drawn objects that fail to disappear on their own.

Recalibrate zoom: CONTROL + END. This is rarely needed for resolving bugs related to zooming.

## Tutorial

Read current step: H

Read current summary: ALT + H

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

Change movement mode: CONTROL + W

Note the 3 movement types are as follows:

   1- Telestep: Press a direction to turn in that direction, then continue pressing in that direction to move.

   2- Step-By-Walk:  Temporarily removed. This mode is similar to Telestep, however the player character will physically take steps in the direction chosen.  The biggest difference is footsteps.

   3- Smooth-Walking: In this mode the character will move similarly to in a sighted game. The player will be notified if they run into something, but otherwise will not be notified of entities they are passing. Very fast, and great for getting around!

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

Navigate scanner list entries: PAGE UP and PAGE DOWN. Alternatively you can use UP ARROW and DOWN ARROW.

Repeat scanner list entry: HOME

Switch between different instances of the same entry: SHIFT + PAGE UP and SHIFT + PAGE DOWN.  Alternatively you can use SHIFT + UP ARROW and SHIFT + DOWN ARROW.

Change scanner list filter category: CONTROL + PAGE UP and CONTROL + PAGE DOWN. Alternatively you can use CONTROL + UP ARROW and CONTROL + DOWN ARROW.

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

Nudge it by one tile: CONTROL + SHIFT + DIRECTION, where the direction is one of W A S D. 

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

Skip the cursor over repeating entities and across underground sections: SHIFT +  W A S D

Return the cursor to the character: J

Teleport character to cursor: SHIFT + T

Force teleport character to cursor: CONTROL + SHIFT + T

Increase cursor size to examine a larger area: SHIFT + I

Decrease cursor size to examine a smaller area: CONTROL + I

Note: You must be in cursor mode for the size of the cursor to make any difference in area scans.

Save cursor bookmark coordinates: SHIFT + B

Load cursor bookmark coordinates: B

Type in cursor coordinates to jump to: ALT + T

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

Start and end planner area selection: LEFT BRACKET

Cancel selection: Q

Rotate blueprint in hand: R

Flip blueprint in hand horizontal: F, if supported by all blueprint members

Flip blueprint in hand vertical: G, if supported by all blueprint members

Place blueprint in hand: LEFT BRACKET

Open menu for blueprint in hand: RIGHT BRACKET

Note: Most blueprint options are found in its menu.

Open menu for blueprint book in hand: RIGHT BRACKET

Open contents for blueprint book in hand: LEFT BRACKET

Copy into hand a blueprint from the book menu: LEFT BRACKET

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

Throw a capsule weapon or grenade in hand towards the cursor: LEFT BRACKET. Warning: It is likely that a grenade or similar weapon will damage you because the cursor is usually automatically nearby.

The rest of the controls in this section require you to have the inventory screen opened (but no buildings).

Equip a gun or ammo stack: LEFT BRACKET to take it in hand and SHIFT + LEFT BRACKET to equip it.
  
Read currently equipped guns (up to 3) and ammo: R
  
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

Travel freely from building to building as if they were laid out in a grid pattern.

Open the BStride menu with CONTROL + S, and explore your factory with the following controls:

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

Modify chest inventory slot limits: PAGE UP or PAGE DOWN. 

Note: You can hold SHIFT to modify limits by increments of 5 instead of 1 and you can hold CONTROL to set the limit to maximum or zero.

Open menu search: CONTROL + F. This works for player inventories, building output inventories, building recipe selection, the crafting menu, and the technology menu.

Run menu search forward: SHIFT + ENTER

Run menu search backward: CONTROL + ENTER, only for inventories.

Flush away a selected fluid: X

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

Set input priority side: SHIFT + LEFT ARROW, or SHIFT + RIGHT ARROW. Press the same side again to reset to equal priority.
  
Set output priority side: CONTROL + LEFT ARROW, or CONTROL + RIGHT ARROW. Press the same side again to reset to equal priority.
  
Set an item filter: With the item in hand, CONTROL + LEFT BRACKET
  
Set item filter output side: CONTROL + LEFT ARROW, or CONTROL + RIGHT ARROW
  
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

Shortcut for building rail right turn 45 degrees: CONTROL + RIGHT ARROW on an end rail.

Shortcut for building rail left turn 45 degrees: CONTROL + LEFT ARROW on an end rail.

Shortcut for picking up all rails and signals within 7 tiles: SHIFT + X on a rail.

## Train building and examining

Place rail vehicles: LEFT BRACKET on an empty rail with the vehicle in hand and facing a rail. Locomotives snap into place at train stops. Nearby vehicles connect automatically to each other upon placing.

Manually connect rail vehicles: G near vehicles

Manually disconnect rail vehicles: SHIFT + G near vehicles

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

Increase station waiting times by 5 seconds: PAGE UP

Increase station waiting times by 60 seconds: CONTROL + PAGE UP

Decrease station waiting times by 5 seconds: PAGE DOWN

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

Honk the horn: V
  
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

For the selected item, send it to logistic trash: O

For the selected item in logistic trash, take it back into inventory: LEFT BRACKET and then Q

For personal logistics, pause or unpause all requests: CONTROL + SHIFT + L

For a logistic storage chest, set or unset the filter to the selected item: SHIFT + L

For a logistic requester chest, toggle requesting from buffer chests: CONTROL + SHIFT + L

## Using the screen reader

The screen reader, such as for NVDA, can be used but it is generally not that helpful during gameplay because in-game menus heavily use visual icons and graphs instead of text. We are designing the mod to require the screen reader as little as possible. However, the screen reader is necessary in the following situtaions: When the game crashes, when your character dies, when you win a game, and optionally when you pause the game.

# More info at the wiki

For information about the mod and the game, please check out our own [Factorio Access Wiki](https://github.com/Crimso777/Factorio-Access/wiki) being written by the developers.

Factorio also has an [official wiki](https://wiki.factorio.com/).

# Frequently Asked Questions
Please check the [Factorio Access Wiki main page](https://github.com/Crimso777/Factorio-Access/wiki) for frequently asked questions section.

# Help and Support

If your question wasn't answered here or on our wiki, feel free to contact us at our [Discord server](https://discord.gg/CC4QA6KtzP).

# Changes

An updated changelog for the beta can be found [here](https://github.com/LevFendi/Factorio-Access/blob/main/CHANGES.md).



# Donations

While this mod is completely free for all, our small team of volunteers is working on this mod in their free time and our main developer is a full time student.

If you are so inclined, you can donate at our [Patreon page](https://www.patreon.com/Crimso777).
