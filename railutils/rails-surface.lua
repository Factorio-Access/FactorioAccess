---Rails Surface Interface
---
---Defines the interface that all surface implementations must provide.
---This allows railutils to work with both real Factorio surfaces and test/dry-run surfaces.

require("polyfill")

local mod = {}

---Surface interface for querying rails
---
---This is an interface that both GameSurface and TestSurface implement.
---It provides a uniform way to query for rails regardless of whether we're
---working with a real Factorio surface or an in-memory test surface.
---
---@class railutils.RailsSurface
---@field get_rails_at_point fun(self: railutils.RailsSurface, point: fa.Point): railutils.RailInfo[] Get all rails at a tile position

return mod
