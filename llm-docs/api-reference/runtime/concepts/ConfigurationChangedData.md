# ConfigurationChangedData

**Type:** Table

## Parameters

### migration_applied

`true` when mod prototype migrations have been applied since the last time this save was loaded.

**Type:** `boolean`

**Required:** Yes

### migrations

Dictionary of prototype changes due to [migrations](runtime:migrations). The inner dictionary maps the old prototype name to the new prototype name. The new name will be an empty string if the prototype was removed. Entries are omitted if the old and new prototype name are the same.

**Type:** Dictionary[`IDType`, Dictionary[`string`, `string`]]

**Required:** Yes

### mod_changes

Dictionary of mod changes. It is indexed by mod name.

**Type:** Dictionary[`string`, `ModChangeData`]

**Required:** Yes

### mod_startup_settings_changed

`true` when mod startup settings have changed since the last time this save was loaded.

**Type:** `boolean`

**Required:** Yes

### new_version

New version of the map. Present only when loading map version other than the current version.

**Type:** `string`

**Optional:** Yes

### old_version

Old version of the map. Present only when loading map version other than the current version.

**Type:** `string`

**Optional:** Yes

