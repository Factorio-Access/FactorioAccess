# Task: fix import styling

## Character

Do this from the perspective of a senior softwaree engineer.  You care about maintainability and code quality.  This is
an open source project so it's not about what makes the most money or anything like that--elegance is encouraged.  You
understand that as an OSS project, we get fly-by contribution and people of many different experience levels, and try to
write code accordingly.  It is fair to assume a deep knowledge of Lua.

## What

We have two styles of import:

```
local fa_whatever = require("whatever")
```

and:

```
local Whatever = require("whatever")
```

The latter style is what we want.  This needs to be fixed across the codebase.  Since you have already onboarded, I am continuing this in the same session.

Automated tooling doesn't help too much because IDE things cannot currently handle control.lua, but don't overthink it.

`TH` for table-helpers is a special case; leave it alone.  So is `FaUtils` instead of `Utils` (too close to a game built-in) so for e.g. `fa_utils` you'll have to go to `FaUtils`.

Be careful!  There's no way sed-type replacement is enough.  If it was, I'd have already done that.  The reason I am using an LLM is that it does require active intelligence and semantic analysis.

This can be done file by file, so you can use subagents if you so choose. Run the tests!

I suggest looking at the already converted imports and matching those where possible.

Expect running stylua to make a lot of formatting changes.  Since the identifiers are getting shorter, it will want to wrap code differently.

TIP: Any file which does not contain the characters `fa_` can be eliminated early.

One commit per handled file, please.
