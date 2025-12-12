# Combat

## Keys

NOTE: Most of these only work in combat mode because they have other meanings elsewhere

Enter or exit combat mode: control shift i

Fire your weapon: hold space

Fire at the selected entity, in or out of combat mode: hold c with your cursor over something

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
Capsules are things like grenades, which can be "fired", but not from a weapon.

A sighted player  aims with the mouse, in one of two ways.  Either they select an entity and fire at it directly, or
they move their mouse into the general area of enemies and the game figures it out.  This depends both on what they are
trying to do (for example destroying a chest or hitting a specific enemy) and the kind of weapon it is (for example
shotguns require manual aiming).

IMPORTANT: before reading further, please note that unlike most audiogames, in Factorio friendly fire is possible.  Your
poison capsules poison you.  Your grenades can blow you up.  Etc.  We do not disable this mechanic.

To make combat possible, we offer two related functions: an aim assist and an audio radar.  Both of these respect your
zoom level, set with + and -, which is also linked visually to the graphics. To use combat features, you enter combat
mode with control shift i, which changes the meanings of some keys.

## The Radar

Enemies make the repeated clicking sound.  Spawners make the rising pop.  See the video to learn these.  Enemies below
your character have a lowpass filter.

The radar respects your zoom level. If you are zoomed to 200 tiles far away things sound close. if you are zoomed to 20
tiles, far away things are not audible.

Pitch tells you how much health something has, which is a general approximation of how much of a threat it is.

## Aim Assist

You probably want to actually use your weapons.  To do so, aim assist takes over most of the cursor keys.  In combat
mode, you control your character's body with the arrow keys, and set various aiming settings with wasd and r plus
various modifiers.  For those who are familiar, this is designed to play somewhat like a twin-stick shooter, though with
the hands reversed.  You move with the right hand and aim with the left.

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

Factorio has many kinds of capsule.  These are Factorio's category of "random item that does something", and
unfortunately you will have to know a bit about this to understand how they work. We want to support mods, so we don't
operate off hardcoded lists in vanilla.  In vanilla, at least all of the following are capsules: grenades, the poison
capsule, cliff explosives, fish, remotes, and the combat robot deployers.

If you are not in combat mode, left bracket uses the capsule at the position of your cursor. This happens regardless of
whether or not it is safe to do so.  You can blow yourself up with it in other words.

In combat mode, capsules are fired with shift+wasd.  This does one of a few things depending on the context:

- If it's for yourself, like a fish, it is used on you
- If it's something that does damage, like a grenade, it is used either    on enemies, or if there are no enemies at the
  maximum possible range.  If no enemies are present, you also get a verbal warning.
- If it deploys something like the combat robots, the capsule is used at the maximum range in that direction.

Unlike aim assist, these directional preferences are absolutely respected.  This is because unlike weapons, capsules are
for strategy.  For example it makes sense to throw slowdown or poison capsules around before starting a fight.


## Vehicles


TBD, untested

## Equipment Management

TBD, needs completion; documenting this with combat is probably the best place rather than scattering it around the other files.
