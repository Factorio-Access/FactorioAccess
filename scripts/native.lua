--[[
The bridge to the native code (native/ in this repository), which is injected into the game process and
exposes a `_fa_native` global to this mod's Lua state only.

The native code is the last resort: nothing goes through it that the Factorio API can do. It is only used in
single player, because it reads state that is local to one machine; in multiplayer the launcher keeps doing
these jobs.

Everything checks `Native.is_available()` first. Calling anything else while it is false is a bug and errors.
]]
local mod = {}

---@class (exact) fa.NativeApi
---@field api_version integer
---@field speak fun(str: LocalisedString, interrupt: boolean?)
---@field audio_cmd fun(json: string)
---@field set_cursor fun(x: integer, y: integer)
---@field set_clipboard fun(text: string)
---@field localise fun(str: LocalisedString): string

---@return fa.NativeApi?
local function get_native()
   -- rawget: the global only exists when the DLL is loaded.
   return rawget(_G, "_fa_native")
end

---Whether the native code can be used: it is loaded, and this is a single player game.
---@return boolean
function mod.is_available()
   return get_native() ~= nil and not game.is_multiplayer()
end

---@param cb fun(n: fa.NativeApi)
local function with_native(cb)
   local n = get_native()
   if not n then error("the native code is not loaded; check Native.is_available() first") end
   if game.is_multiplayer() then
      error("the native code is not used in multiplayer; check Native.is_available() first")
   end
   cb(n)
end

---Speak through the native screen reader bridge. The engine localises the string immediately.
---@param str LocalisedString
---@param interrupt boolean? defaults to true
function mod.speak(str, interrupt)
   with_native(function(n)
      n.speak(str, interrupt)
   end)
end

---Send one audio command (the JSON the launcher's audio engine accepts) to the native audio engine.
---@param json string
function mod.audio_cmd(json)
   with_native(function(n)
      n.audio_cmd(json)
   end)
end

---Move the real mouse pointer to a pixel of the game window, as the launcher's setCursor does.
---@param x integer
---@param y integer
function mod.set_cursor(x, y)
   -- Every tick with an item in hand: no closure.
   local n = get_native()
   if not n or game.is_multiplayer() then
      error("the native code is not available; check Native.is_available() first")
   end
   n.set_cursor(x, y)
end

---Put text on the system clipboard (newlines allowed).
---@param text string
function mod.set_clipboard(text)
   with_native(function(n)
      n.set_clipboard(text)
   end)
end

---The text a localised string reads as, translated by the engine at once. Development tooling only.
---@param str LocalisedString
---@return string
function mod.localise(str)
   ---@type string
   local text
   with_native(function(n)
      text = n.localise(str)
   end)
   return text
end

return mod
