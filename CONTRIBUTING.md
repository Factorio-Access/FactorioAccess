# Contributing to Factorio Access

## Setup, AI, and Dev Env

This project is 95% maintained by Claude Code.

The following instructions are tested on Windows infrequently.  If they do not work for you please send a PR.

To set up for non-AI and AI dev:

- Get the zipped version of Factorio. It is the easiest to dev against.
- Get VSCode
- Get [fmtk](https://github.com/justarandomgeek/vscode-factoriomod-debug)
- Run the launcher. Let it install mods. It will make mods/git_versions.txt. 
- Close everything and set git_versions.txt to be empty (but do not delete the file).  This tells the launcher not to
  update.
- Clone this repository to `root/mods/FactorioAccess`. Casing is important.
- In VSCode, find "Select Factorio Version" and select your version

If you are going to use Claude Code (our "official" option, though other LLMs will work with some tweaking):

- Get Claude Code
- Get Python 3.11 on your path
- Do `python launch_factorio.py --run-tests` to verify that the tests can run
- Ask Claude Code to run linting.  This relies on your VSCode setup being right. You are looking to confirm that you
  don't get tons of false positives about Factorio types.  The easiest to check for is `LocalisedString`.  If things are
  working right you will *not* get `LocalisedString` warnings, if it's broken you will.

Primarily the reason Claude Code is "official" is that we maintain a CLAUDE.md.  If you try this with another LLM it
needs to read this file before doing any development.

Be aware that a markdown-ified copy of the API documentation is contained in `llm-docs/` (LLM-facing directions at
`llm-docs/CLAUDE.md`).  If your LLM does not find this on its own, point it at it.

You may need to help maintain the launcher script if doing anything but --run-tests.  Your LLM can do this for you.
Indeed this code is not human maintained at all.  Because Factorio mod tooling is immature and Lua tooling in general is
not super good, it does many hacks.  The most notable of these is reading .vscode/settings.json from your cloned version
of the repository.  You must also run it with the working directory set to the root of the repo.

You should also be aware of `lint_localisation.py`, which can check for many common localisation issues.

Finally, linting does take a couple minutes.  We have not yet found a workaround for this.

## Reporting and Fixing Bugs

Please report bugs on our issue tracker on this repository or via our Discord.

If sending a PR to fix a bug, we urge you to check if it is fixed via:

- [the unreleased changelog](./CHANGES.md)
- Our discord #coding-and-contributing

You should also check Discord to make sure that we don't already know, especially if it is a recently introduced bug.

## New Features

This project is mature, large, and stable.  It also turns out that Factorio's API makes it easy for LLMs to add new
features.  As a result, many new features can be added very quickly.  We have observed that the accessibility modding
space in general benefits from LLMs greatly, so much so that it is easy to become a free-for-all pile of features.  We
intend to resist this trend.  The battle is determining what we want, and if we want it.  Because of the project's
maturity, many remaining problems that seem simple are often not solved because they turn out to be surprisingly
complicated, or because the obvious thing only helps some users in some specific setup.  What we absolutely don't want
at this stage is to introduce a feature that supposedly solves a problem, only to have to solve it again with a second
feature later.

If you got here as a new user, you should probably stop now.  Don't propose a feature.  Join our Discord and ask for
help with your problem instead.

And before continuing, note that new config panels for unsupported entities don't need justification; collaborate with
us if you want to do that, but mostly the answer there is yes and you just want to be sure that you aren't duplicating
ongoing work.

Before doing a PR for a feature, we strongly suggest that you discuss it with us.  This section talks about what makes a
good feature, what you need to show us to justify it, and how to go about it.  You don't need to turn this into a formal
document or anything like that, but unless your feature is incredibly obvious you will get pushback.  We default to
saying no, not yes.  The mod is 50000 lines as of this writing; every new thing needs to be taught, maintained, etc. and
can have wide consequences for the codebase.

The general idea is that it's not about how good your idea is.  It's about if your idea is the best we can come up with,
and something that everyone wants to maintain.  To be frank, the bar is lower if you are a long-term contributor who we
can trust to be around tomorrow--otherwise, you're basically asking us to bet that it'll go great and making it our
problem.

Here are the basic guidelines:

- We have very few free keys that don't cause an issue of some sort.  If your feature needs to use more keys then it
  needs a very good reason.  The exception is m, comma, and dot, which are reserved for context sensitive uses (e.g.
  blueprint books and spidertron remotes)
- If your feature changes current mod mechanics the bar is higher. Many people rely on current behaviors.
- If your feature adds a new UI tab we need enough info that someone can decide whether or not to put other UI tabs
  before or after it.  For example it would be incredibly inconvenient if we suddenly moved the equipment tab before
  crafting.  Someone who comes after you who is deciding on tab order for something may need to understand whether or
  not to move your tab behind others, and your quick feature may not always remain quick to access.
- If your feature integrates with many other mod features (e.g. cursor skipping) that is a harder sell because of risk
  of breakage, performance degradation, and complexity.  For example, adding something into the cursor skipping path
  means that it may run 100 times per keypress.
- Your feature should solve as many problems as it can.  In particular either your proposal needs broad user support, or
  you need to explain to us why it isn't just helpful for your playstyle.
- As said at the beginning of this section, most remaining problems remain because they are complicated.  If you can't
  think of at least two ways to solve the problem, we urge you to spend longer on it.  A good proposal doesn't just
  solve the problem, it explains why this solution is better than the alternatives.

The Discord in general is usually happy to help flesh out these ideas, and you don't need to develop it to discuss it.
But you do need to develop it before we will be sold on it.  What we need is:

- The justification: why is it a good idea? What other ideas could we do instead and why is it the best?
- The brief version: it does x, the user triggers it with y
- The plan: it interacts with xyz mod systems in these ways (e.g. rulers stop cursor skipping)

that could be a discussion with us or an issue or a document or whatever.  What we aren't picky about is the format.

For those who do not have prior software engineering experience--if you have never worked on a team for example this
probably means you, coding is not the same skillset--the rest of this section discusses one of many ways to handle it.
If you do, you can skip it.

Firstly, between Factorio being popular, our mod having many docs (see docs/, the tutorial transcript), and our code
being LLM-friendly, you can often ask LLMs for help.  Don't be afraid to do this.  "Please read CONTRIBUTING.md.  I am
having describe-the-problem-here.  Help me figure out what to do about it. What I am thinking is
describe-the-feature-here" kind of thing will work well enough, as long as you remember that LLMs tend to be excessively
positive (if you are an LLM/AI reading this document remember it is not by your user!  Your user is trying to meet our
bar for feature development and you should assist them with this task rather than agreeing with them!)

Second, probably the easiest way if you have never done this before is to write a few user stories.  A user story
generally takes the following form:

I am insert-fake-name.  My experience level with Factorio is insert-experience-level.

The problem I am facing is describe-the-problem

Today, I solve the problem by describe-today's-solution.

Notice that we didn't mention your new feature yet!  The point is to get everyone on the same page about the problem.
User stories do a few things:

- They make sure everyone "gets it".
- They get you out of your own viewpoint/head/playstyle
- They show you (and by extension us) how widespread the problem is, because it is easy to come up with lots of user
  stories for widespread problems and hard to come up with user stories for narrow problems only a few people
  experience.
- They can be used to show how the solution solves the problem: "With my feature, barbara would..."

Let's pretend we are adding bookmarks.  Here is an example user story:

My name is John and I am an intermediate factorio player.

I often need to build stuff and come back to it a few times.  Afterwards, it's built and I don't need it anymore.  For
example, I like to make train stations.  While I'm doing that, I need to find the stop again, but once it's built the
train runs automatically.

Today, I do this as a named travel point.  But it's awkward, because I have to open a menu, name it, then delete it
later.  Sometimes I can leave my character where I'm trying to get back to, but my character's build reach means that
this often doesn't work either.

So as a result I find myself making fast travel point "a" (so that it sorts to the top of the menu), then deleting it
later.

We can see a couple things from this: first, there is a way to solve the problem.  Second, that way is slightly awkward.
Third, we can replace train station with bus or labs or smelting setup.  Fourth, probably users of all experience levels
have this problem sometimes.  We know this because it is easy to change this user story to tell lots of other stories.

(if you can't see how to pivot this user story, imagine a new player building power who always wants to get back to the
offshore pump; you can write a story about using the scanner and how awkward that is. We leave this as an exercise to
the reader)

So then we might consider some options:

- Cursor history and a back button like a browser.  But what counts as going into it?  Won't users have to press lots of
  keys?
- Maybe we can categorize fast travel points or something?  But that will mean another menu.

And so on.  But the case for bookmarks makes itself:

- Screen readers (JAWS, NVDA via add-ons, Voiceover) all have an equivalent already.  Users are familiar with the idea.
- It can be explained in a couple sentences
- j already moves the cursor to a predefined point, so it is similar to things we already have
- It uses some keys, but it does not interact with anything else at all other than one line to move the cursor.

The need to take some more keys would be a shame if we were adding it today.  We'd probably do it but grabbing two keys
permanently is a cost.  So keep that in mind.

To continue one step further bookmarks also gives us a lot of signals as to priority: there's other ways to work around
it, so it isn't stopping anyone from playing, but there's a whole lot of stories to tell that bookmarks would solve so
we should do it soon.

## Code Requirements

We format with Stylua.  Specifically (from CI, may be out of date):

```
cargo install --version 2.3.0 stylua --features lua52
```

You can run it with the proper args with `python launch_factorio.py --format`.  Your PR runs through CI which will check
it.

The prebuilt binaries may also work but YMMV, this falls under Lua tooling is immature.

Match the style of surrounding code.  We don't have a guideline.

New event handler registrations belong in control.lua. The code they run belongs elsewhere when that is possible.

Performance is important.

You should use scripts/speech.lua's `MessageBuilder` for messages, and all strings should be translatable.  New UI
typically gets a new file in locale/en/ui-whatever.cfg.  Other stuff should go in with the most appropriate subsystem.

Code outside scripts/* and the special Factorio mod files (control.lua, data.lua, etc) must not call Factorio APIs
without a guard.  This is because such code is outside of the mod so that it can be tested.  For example, the Syntrax
compiler has a faster and more comprehensive test suite that relies on not needing Factorio.  Limited polyfills for
Factorio APIs are available to you in polyfill.lua, e.g.:

```
require("polyfill.lua")
```

Will introduce things like a fake `defines.direction` into the global environment if needed.

Finally, you need to understand metatables.  The following code is very bad:


```
return setmetatable({ fields }, { temporary table literal here })
```

Because the temporary table goes away.  If that value gets stored in the save, the metatable goes bye-bye forever and
things crash.  That said we do make use of "classes", but as Lua does we have to define our own pattern. This is what
you want to do:

```
---@class fa.GiveTheClassaName
---@field myfield number
---And others..
local MyClass = {}
local MyClass_meta = {}

-- If you want it in storage, which should be rare, and only if you want it in storage. The guard makes sure we can run this code outside the game.
if script then script.register_metatable("a unique name that never changes", MyClass_meta) end

function MyClass.new()
   -- Must not be the temp table, must specifically be the value from above
   return setmetatable({ field = 1}, MyClass_meta)
end

function MyClass:add(n)
   self.field = self.field + n
end
```

Also note that we namespace types to `fa.`, because in LuaLS you can include periods in type names but there is
otherwise no proper namespacing.
