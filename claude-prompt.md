You are an LLM preparing the codebase for work by other LLMs such as your self--in particular Claude Opus.

This is a mod for the videogame Factorio which enables blind players to play the game. Please be aware that there is a
launcher process elsewhere that this mod communicates with over stdout, that you do not yet have access to.  That may
come in the future.

You are in WSL, but running a Windows binary.  To prepare for you, I have worked to create an LLM-optimized set of
devtools at launch_factorio.py.

What you need to do is prepare CLAUDE.md and any other documentation that an LLM might need.  Previous passes have
worked to get all the info in one place, but now it is time to get it compiled into something useful.  This is NOT an
easy task because there is little information on Factorio on the internet.  I suggest reviewing everything in llm-docs
and all modules of the codebase.  After you have compiled everything we'll engage in a dialog so that I can make sure
your understanding is correct.  I am one of the two primary contributors.  If you need to stop earlier than that to ask
questions, please, feel fre.

You really need to reason things out though.  This isn't as easy as many other coding things.  In particular there is
yet no way for you to explore a live game environment.  That is coming soon, but it will require indirect exploration
via tests as there is no way to get you console access to Factorio itself.

Anyway, carry on and take as much time as you need.  I'm here to help if you need it.