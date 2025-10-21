# Overview of 2.0 Changes (so far)

This is a living document. Last updated 2025-10-21.

## Directions

First, note the following important warnings:

- We do not support combat yet and that is not coming soon. Play in no enemies.
- We may break your save. I mean on purpose, not by accident.  We are trying not to but getting rid of technical debt
  takes priority while we still have the opportunity to do so easily. Most breakage simply results in losing settings.
- We do not support Space Age and that is not coming soon.

Next, read the [2.0 migration document](docs/2.0-migration.md)

We now deploy automatic updates for everything.  To playtest:

- Get Factorio from factorio.com as the stand-alone zip version and extract it.
- Get the latest launcher from this page: https://github.com/factorio-access/factorio-access-launcher/releases
- Put launcher.exe in the root of your factorio install. Same folder with `bin`, `mods`, `config-path.cfg` etc.
- Run the launcher. It will offer to make config directories and apply config changes. Let it do so.
- If you bought space age, disable the elevated rails, space age, and quality mods in the launcher's mods menu.

You will periodically need to update the launcher and/or your Factorio game itself.  We will announce this on playtesting-2 on Discord or in CHANGELOG.md.  The mods now automatically update themselves.

## Reporting

We are coordinating on channel `playtesting-2`.  Drop your tracebacks or bugs there.  We will probably ping you on a
different channel if something needs to be a lengthy discussion.

For practical purposes Claude Sonnet 4.5 is our primary maintainer believe it or not.  Right now the process is manual,
but your messages may be seen by Anthropic in some form if you post to the channel. Other channels on our Discord are
not fed to AI at this time.  We may automate this process if we receive high enough volume.

At this time we are seeing mostly bugs and not crashes, so for the moment AI use is manual.

## Things that don't Work at all (if you test these we will ignore you because we already know, we're working down this list in no particular order)

- Combat. Play in no enemies.
- Trains.
- Decider, arithmetic, and selector combinators
- spidertrons and other vehicles are only partly functional

There's also a lot of roughness around the edges we're still spending down. Support for quality is intentionally sparse.
We are doing it where not doing so would cause tech debt, but quality is a space age feature and not priority at this
time.
