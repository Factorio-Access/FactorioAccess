local Localising = require("scripts.localising")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder

local mod = {}

-- Wildcard signal prototype names
local WILDCARD_SIGNALS = {
   ["signal-item-parameter"] = "rich-text-wildcard-item",
   ["signal-fluid-parameter"] = "rich-text-wildcard-fluid",
   ["signal-fuel-parameter"] = "rich-text-wildcard-fuel",
   ["signal-signal-parameter"] = "rich-text-wildcard-signal",
}

-- Tag type to prototype map
local TAG_PROTO_MAPS = {
   item = prototypes.item,
   entity = prototypes.entity,
   technology = prototypes.technology,
   recipe = prototypes.recipe,
   fluid = prototypes.fluid,
   tile = prototypes.tile,
   ["virtual-signal"] = prototypes.virtual_signal,
   achievement = prototypes.achievement,
   equipment = prototypes.equipment,
   ["space-location"] = prototypes.space_location,
   planet = prototypes.space_location,
}

-- Get localised name or keep the raw name if prototype not found
---@param name string
---@param proto_map table
---@return LocalisedString
local function get_localised_name_or_keep(name, proto_map)
   local proto = proto_map and proto_map[name]
   if proto then return Localising.get_localised_name_with_fallback(proto) end
   return name
end

-- Parse a single rich text tag and return tag type, name, and any parameters
---@param tag string
---@return string|nil tag_type
---@return string|nil name
---@return table|nil params
local function parse_tag(tag)
   -- Handle tags without parameters: [type]
   if not tag:find("=") then return tag, nil, nil end

   -- Handle tags with parameters: [type=name,param=value,...]
   local tag_type, rest = tag:match("^([%w%-]+)=(.+)$")
   if not tag_type then return nil end

   local params = {}
   local name = nil

   -- Split by commas (simple parser, doesn't handle nested brackets)
   for param in rest:gmatch("[^,]+") do
      local key, value = param:match("^([%w%-]+)=(.+)$")
      if key then
         params[key] = value
      elseif not name then
         name = param
      end
   end

   return tag_type, name, params
end

-- Verbalize a rich text string into audio-friendly text
-- Handles known tags and leaves unknown ones as-is
---@param text string
---@return LocalisedString
function mod.verbalize_rich_text(text)
   local mb = MessageBuilder.new()
   local pos = 1

   while pos <= #text do
      -- Find next opening bracket
      local bracket_start = text:find("[", pos, true)
      if not bracket_start then
         -- No more tags, add remaining text
         if pos <= #text then mb:fragment(text:sub(pos)) end
         break
      end

      -- Add text before the bracket
      if bracket_start > pos then mb:fragment(text:sub(pos, bracket_start - 1)) end

      -- Find closing bracket
      local bracket_end = text:find("]", bracket_start + 1, true)
      if not bracket_end then
         -- Malformed tag, include the rest literally
         mb:fragment(text:sub(bracket_start))
         break
      end

      -- Extract tag content
      local tag_content = text:sub(bracket_start + 1, bracket_end - 1)

      -- Check if this is a closing tag
      if tag_content:match("^/") then
         -- Ignore closing tags like [/color], [/font]
         pos = bracket_end + 1
         goto continue
      end

      -- Parse the tag
      local tag_type, name, params = parse_tag(tag_content)

      if tag_type and TAG_PROTO_MAPS[tag_type] and name then
         -- Known prototype tag
         local proto_map = TAG_PROTO_MAPS[tag_type]
         local localised_name = get_localised_name_or_keep(name, proto_map)
         local locale_key = "fa.rich-text-" .. tag_type

         -- Check if it's a wildcard signal
         if tag_type == "virtual-signal" and WILDCARD_SIGNALS[name] then
            mb:fragment({ "fa." .. WILDCARD_SIGNALS[name] })
         else
            mb:fragment({ locale_key, localised_name })
         end
      elseif tag_type == "space-age" then
         mb:fragment({ "fa.rich-text-space-age" })
      elseif tag_type == "armor" then
         mb:fragment({ "fa.rich-text-armor" })
      elseif tag_type == "train" and name then
         mb:fragment({ "fa.rich-text-train", name })
      elseif tag_type == "train-stop" and name then
         mb:fragment({ "fa.rich-text-train-stop", name })
      elseif tag_type == "shortcut" and name then
         mb:fragment({ "fa.rich-text-shortcut", name })
      elseif tag_type == "tip" and name then
         mb:fragment({ "fa.rich-text-tip", name })
      elseif tag_type == "space-platform" and name then
         mb:fragment({ "fa.rich-text-space-platform", name })
      elseif tag_type == "gps" then
         -- Leave GPS tags as-is for now
         mb:fragment("[" .. tag_content .. "]")
      elseif tag_type == "color" or tag_type == "font" then
         -- Ignore formatting tags
      else
         -- Unknown tag, pass through
         mb:fragment("[" .. tag_content .. "]")
      end

      pos = bracket_end + 1
      ::continue::
   end

   return mb:build()
end

-- Parse shorthand notation into rich text
-- Returns: expanded_text, errors (nil if no errors)
---@param text string
---@return string expanded_text
---@return LocalisedString[]|nil errors
function mod.parse_rich_text_shorthand(text)
   local result = {}
   local errors = {}
   local pos = 1

   while pos <= #text do
      -- Find next shorthand marker
      local colon_pos = text:find(":", pos, true)
      if not colon_pos then
         -- No more shorthands
         table.insert(result, text:sub(pos))
         break
      end

      -- Add text before the colon
      if colon_pos > pos then table.insert(result, text:sub(pos, colon_pos - 1)) end

      -- Check if this is a shorthand (next char should be type indicator)
      local shorthand_start = colon_pos
      local type_char = text:sub(colon_pos + 1, colon_pos + 1)

      -- Check for wildcards first (:*s, :*i, :*f, :*fu)
      if type_char == "*" then
         local first_char = text:sub(colon_pos + 2, colon_pos + 2)
         local second_char = text:sub(colon_pos + 3, colon_pos + 3)
         local tag_name = nil
         local consumed_chars = 0

         -- Check for two-char wildcard first
         if first_char == "f" and second_char == "u" then
            tag_name = "signal-fuel-parameter"
            consumed_chars = 4 -- :*fu
         elseif first_char == "i" then
            tag_name = "signal-item-parameter"
            consumed_chars = 3 -- :*i
         elseif first_char == "f" then
            tag_name = "signal-fluid-parameter"
            consumed_chars = 3 -- :*f
         elseif first_char == "s" then
            tag_name = "signal-signal-parameter"
            consumed_chars = 3 -- :*s
         else
            -- Invalid wildcard
            local invalid_text = text:sub(colon_pos, colon_pos + 3)
            table.insert(errors, { "fa.rich-text-error-invalid-shorthand", invalid_text })
            table.insert(result, invalid_text)
            pos = colon_pos + 4
            goto continue
         end

         table.insert(result, "[virtual-signal=" .. tag_name .. "]")
         pos = colon_pos + consumed_chars
         goto continue
      end

      -- Regular shorthands
      local proto_type = nil
      local proto_map = nil

      if type_char == "i" then
         proto_type = "item"
         proto_map = prototypes.item
      elseif type_char == "f" then
         proto_type = "fluid"
         proto_map = prototypes.fluid
      elseif type_char == "s" then
         proto_type = "virtual-signal"
         proto_map = prototypes.virtual_signal
      else
         -- Not a recognized shorthand, keep the colon
         table.insert(result, ":")
         pos = colon_pos + 1
         goto continue
      end

      -- Expect a dot after the type char
      local dot_pos = colon_pos + 2
      if text:sub(dot_pos, dot_pos) ~= "." then
         -- Not a valid shorthand format
         table.insert(result, text:sub(colon_pos, dot_pos))
         pos = dot_pos + 1
         goto continue
      end

      -- Extract prototype name (ends at space or end of string)
      local name_start = dot_pos + 1
      local name_end = text:find("%s", name_start)
      if not name_end then name_end = #text + 1 end
      name_end = name_end - 1

      local proto_name = text:sub(name_start, name_end)

      -- Validate prototype exists
      if not proto_map[proto_name] then
         table.insert(errors, { "fa.rich-text-error-missing-prototype", proto_type, proto_name })
         table.insert(result, text:sub(colon_pos, name_end))
         pos = name_end + 1
         goto continue
      end

      -- Valid shorthand, expand it
      table.insert(result, "[" .. proto_type .. "=" .. proto_name .. "]")
      pos = name_end + 1

      ::continue::
   end

   local expanded = table.concat(result)
   return expanded, (#errors > 0 and errors or nil)
end

return mod
