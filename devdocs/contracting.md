# Introduction

This is a list of pending work items for our contractor(s) which will have items removed as they are completed.  This
does not correspond one-to-one for git issues, but each section mentions issues where appropriate.

If you aren't contracting with us *do *not* try to take work from this file because you want to help us out.  Insteadd,
consider the issue tracker directly or ask us if you can take something.  We have plenty of things and are happy to have
you contribute, but work in this file should be considered assigned to a paid contractor, so PRs may or may not get
reviewed and landed but will certainly get closed if we are already paying for work in that area.

Each task below has a motivation and plan section.  Some have more than that.

There is an assumption of some in person/via Discord mod onboarding.  Probably a couple hours.  Tasks are ordered in an
onboarding-friendly fashion at the cost of early ones being boring.  This isn't all the work we have.  Tasks fall off
the top of the file as they complete and new work gets added to the bottom.

There are also some dev notes here: https://github.com/Factorio-Access/FactorioAccess/wiki/Info-for-Contributors

Note that it is a year old, and only 75% or so accurate.

# Completed Work

- Onboarding and global variable audit (40 h)
- fa-info preparation for 2.0, aka `]` key (17 h, 57h total).
- Refactor cursor handling to a new viewpoint module to allow for space age and remote view enhancements (~20h give or
  take a bit, total ~78 h).
- Input Refactor for 2.0 (~52h, total 131h)
- Test Larger Cursors on Gleba. Tested; no issues found. (~1h, total 132h)
- Aquilo iceberg scanner and new terrain category (11h, total 143H)
- Heat Pipes read like fluid network (22H total 165)

# Tasks

## Script to do Releases

This needs some scoping but since we have the spare slack it'd be a good idea. What we know wrt the flow:

- It has to run locally because of Factorio creds.  So sadly no CI builds.
- Package this mod with fmtk.
- We probably just want to throw our dependency mods in a github repo or something because you copy those zips in.
- Figure out what to do about the launcher. Ideally we can grab the latest release from GitHub automatically.
- Making a GH release can be automated.

Ideally automate with Python since we already have that dependency.

We can talk about needed credentials.  You shouldn't, because you can test against your own repo for the GH side of this
and the fmtk uploading is one line.

The one weird exception to the dependency mods is that Kruise Kontrol is now maintained by us as Kruise Kontrol Remote.
That should be cloned somewhere and built.  We could put it as a submodule of the main repository no problem, and in fact that might be the best.

## Spidertrons

This is blocked on UI framework work which is in turn blocked on input refactor.

Spidertrons are broken even in 1.1.  They need to be fixed.  We don't know what this means.  Start by ignoring the new
spidertron RTS tool in 2.0, and just get the old menu working as much as possible. The RTS tool has interesting
questions around it and someone on the core team will probably have to answer them first.
