# FileName

A slash `"/"` is always used as the directory delimiter. A path always begins with the specification of a root, which can be one of three formats:

- **core**: A path starting with `__core__` will access the resources in the data/core directory, these resources are always accessible regardless of mod specifications.

- **base**: A path starting with `__base__` will access the resources in the base mod in data/base directory. These resources are usually available, as long as the base mod isn't removed/deactivated.

- **mod path**: The format `____` is placeholder for root of any other mod (mods/), and is accessible as long as the mod is active.

