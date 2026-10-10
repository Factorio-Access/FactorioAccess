--[[
Development tooling: runs Lua sent over UDP and sends back the result, so test loops can inspect and drive a running
game (`python native/tools/fadev.py lua "<code>"`).

It does nothing unless the game was started with `--enable-lua-udp <port>` (fadev.py launch passes it): without the
flag recv_udp is a no-op. Only packets that start with "fa-eval\n" are run, so other users of the flag are not
affected.

The rest of the packet is a Lua chunk run in this mod's Lua state; a single expression is evaluated as
`return <expression>`. require works only while the mod loads, so chunks get `loaded("scripts.fa-utils")`, which
returns an already loaded module by its require name. Globals a chunk assigns stay in that chunk. The reply, sent
to the packet's source port, is "ok\n" followed by the serpent-serialised return values, one per line group, or
"error\n" followed by the message.
]]
local EventManager = require("scripts.event-manager")

local mod = {}

local PREFIX = "fa-eval\n"

---@param name string A require name, e.g. "scripts.fa-utils"
---@return any
local function loaded(name)
   return package.loaded["__FactorioAccess__/" .. name:gsub("%.", "/") .. ".lua"]
end

---@param code string
---@return string
local function run(code)
   local env = setmetatable({ loaded = loaded }, { __index = _G })
   local chunk, err = load("return " .. code, "=fadev", "t", env)
   if not chunk then
      chunk, err = load(code, "=fadev", "t", env)
   end
   if not chunk then return "error\n" .. tostring(err) end

   local results = table.pack(pcall(chunk))
   if not results[1] then return "error\n" .. tostring(results[2]) end
   local parts = {}
   for i = 2, results.n do
      table.insert(parts, serpent.block(results[i], { comment = false, nocode = true }))
   end
   return "ok\n" .. table.concat(parts, "\n")
end

EventManager.on_nth_tick(1, function()
   helpers.recv_udp()
end)

EventManager.on_event(defines.events.on_udp_packet_received, function(event)
   if event.payload:sub(1, #PREFIX) ~= PREFIX then return end
   helpers.send_udp(event.source_port, run(event.payload:sub(#PREFIX + 1)))
end)

return mod
