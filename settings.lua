local setting_decls = require("scripts.settings-decls")

-- fa.SettingDecl covers every setting kind in one shape, so it is not any single setting prototype type.
data:extend(setting_decls.declarations --[[@as data.AnyModSettingPrototype[] ]])
