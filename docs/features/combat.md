# Combat

## Keys

NOTE: Most of these only work in combat mode because they have other meanings elsewhere

Enter or exit combat mode: control shift i

Cycle between equipped weapons: c

Fire your weapon: hold space

Fire at the selected entity or approximately at the tile under the cursor: shift + space outside combat mode. N/a in combat mode since that disables your cursor.

Set your aiming preference direction: w, a, s, or d

Use a capsule in the given direction: shift + w, a, s, or d

Use a capsule in the given direction, regardless of if it would hit you: control + shift + w, a, s, d

Use a capsule on yourself, even if it is dangerous to do so: left bracket

Toggle safe mode: ctrl + shift + r

Toggle spawners first: shift + r

Toggle closest or strongest enemies first: control + r

# Explanation

## Introduction

NOTE: see our explanation video (todo: make the explanation video)

In Factorio combat consists of weapons, armor, and capsules.  Weapons are things like machine guns.  Armor is armor.
Capsules are disposable items like grenades.

A sighted player  aims with the mouse, in one of two ways.  Either they select an entity and fire at it directly, or
they move their mouse into the general area of enemies and the game figures it out.  This depends both on what they are
trying to do (for example destroying a chest or hitting a specific enemy) and the kind of weapon it is (for example
shotguns require manual aiming).

IMPORTANT: before reading further, please note that unlike most audiogames, in Factorio friendly fire is possible.  Your
poison capsules poison you.  Your grenades can blow you up.  Etc.  We do not disable this mechanic.

To make combat possible, we offer two related functions: an aim assist and an audio radar.  Both of these respect your
zoom level, set with + and -, which is also linked visually to the graphics. To use combat features, you enter combat
mode with control shift i, which changes the meanings of some keys.

This document also explains vehicle driving and equipment.

## The Radar

The enemy radar places sounds at enemy locations in a not at all realistic but informative manner, like most traditional
audiogames. Enemies make the repeated clicking sound.  Spawners make the rising pop.  See the video to learn these.
Enemies below your character have a lowpass filter.

The radar respects your zoom level. If you are zoomed to 200 tiles far away things sound close. If you are zoomed to 20
tiles, far away things are not audible.

Pitch tells you how much health something has, which is a general approximation of how much of a threat it is.

## Aim Assist

In combat mode, you control your character's body with the arrow keys, and set various aiming settings with wasd and r
plus various modifiers.  The mod then handles aiming.  For those who are familiar, this is designed to play somewhat
like a twin-stick shooter, though with the hands reversed.  You move with the right hand and aim with the left.  These
controls are awkward for technical reasons that we cannot work around.

You have control over 3 settings.  Which direction to shoot, whether to prefer spawners over other things, and whether
to shoot the strongest or closest thing first. Set your preferred direction with wasd, and change your spawners first
and strongest/closest first settings with r plus modifiers.

When nothing is in range, holding space blocks firing.  Space also blocks firing in safe mode, if your equipped weapon
would hurt you.  Examples of equipped weapons that can hurt you include explosive rockets and the atomic bomb.

Your aiming preference is not absolute.  If nothing is in your preferred direction, the mod will pick another direction
instead.

Unlike the sighted experience, aim asisst works universally on all weapons.  This makes it possible to fire weapons like
the shotgun, which require the sighted player to be precise with the mouse.

## Capsules

Capsules are Factorio's catch-all category for "item you can use that doesn't fit anywhere else".  They are exposed to the sighted in the same way as building, and used with roughly the same controls.  The mod however provides help: you can use your aim assist with combat-related capsules.

In vanilla, at least all of the following are capsules: grenades, the poison capsule, cliff explosives, fish, remotes,
and the combat robot deployers.

If you are not in combat mode, left bracket uses the capsule at the position of your cursor. This happens regardless of
whether or not it is safe to do so.  You can blow yourself up with it in other words.  This is intended to be used with
"safe" capsules, for example cliff explosives or the spidertron remote.

In combat mode, capsules are fired with shift+wasd.  This does one of a few things depending on the context:

- If it's for yourself, like a fish, it is used on you
- If it's something that does damage, like a grenade, it is used on enemies. If there aren't any in the configured
  direction it's used at the maximum possible range and you get a warning.
- If it deploys something like the combat robots, the capsule is used at the maximum range in that direction always.

Unlike aim assist, these directional preferences are always respected.  This is because unlike weapons, capsules are
for strategy.  For example it makes sense to throw slowdown or poison capsules around before starting a fight.

## Vehicles

Vehicles work just like the player in terms of shooting, and the spidertron (a very late game vehicle) also walks like the player.


unfortunately all other vehicles don't, and instead turn like real life cars.  In these cases, a directional tone plays
every 50 tiles or when the car is turning.

Vehicles in Factorio have slightly odd driving controls.  In general, to drive in a given direction hold the arrow key
in that direction.  We sonify the car's direction so that you can learn the following details.  You can also get info on
heading and speed with k.  Anyway, here are the rules:

- If the car is not initially facing the direction you want to move the game will turn it.  Cars have a turning radius, so this is not instant.
- If the car is moving then holding the exact opposite direction breaks until the car stops.  The car will not continue
  until you let go and press it again.
- If the car is facing in a direction, stopped, and you hold the exact opposite direction, it will choose to reverse instead of doing a half circle.

The mod cannot replace vanilla's driving controls. In fact we are already toggling a setting for you.  The default driving controls are even worse for the blind.

As an alternative outside combat, using Kruise Kontrol can perform long-distance driving with pathfinding.  Note,
however, that automatic driving in this way is not perfectly precise.  the game does not have an in-built pathfinder for
vehicdles, so Kruise Kontrol does its best, but:

- You may not end up exactly on your target point.  Usually you are within 10-20 tiles
- Sometimes it just can't find a path because it'd have to ram through something, for example trees, and gives up even though you'd probably consider that fine


## Equipment Management

IMPORTANT: Equipment in an armor stays with the armor when you unequip it. You did not lose the equipment. To get it out, put the armor back on and unequip the equipment from it first.

Weapons and armor are configured via the equipment overview tab in an entity's menus, or via your personal menu.  To briefly summarize complex mechanics:

- you personally can wear armor and have up to 3 weapons
- Your vehicles have fixed weapons and usually no other equipment, but you can sometimes add things like roboports
- Your personal armor and vehicles supporting equipment can have any of a large variety of things added to them, serving a large variety of functions

Early game you start with a pistol and that's it, so for a while you don't have to worry about much of this.

Equipment in Factorio is equipped into an equipment grid, and each piece of equipment has a size.  You must pick from one of two ways to equip stuff:

- In the equipment overview tab, you can click equipment and it will be shoved into the first spot it can fit.
- Instead you can put it in hand and manually place it in the grid.

Our recommended strategy is to use the first method, equipping from largest to smallest. Equipment dimensions are
announced with k on the equipment in your inventory.

The main use of the equipment grid is to see why you still have some free slots, assuming that you do.  For the most part, equipping largest to smallest will use almost all space, but sometimes the advanced player may wish to optimize.  It does not matter where equipment is relative to other pieces of equipment, only that it is somewhere in the grid.

Otherwise, these menus are normal UIs, and have help text in the labels explaining how to use them.
