--[[
Handle research for a player. This means:

- Computing the research graph, of what technologies come from what.
- Announcing the requirements, either in science packs or trigger conditions.
- Managing the research queue.

Broadly speaking this is all pretty simple.  The complexity comes in with handling successor researches and the like.

This module handles announcements.  Those announcements are in locale/en/research.cfg.

Note that some 2.0 technologies do not have descriptions and names because they are not necessarily to be shown to the
player. To deal with this, you may add support by adding to research.cfg  a key of the form
research-technology-name-prototype-name and research-technology-description-prototype-name, e.g.
research-technology-name-steam-power.

This module's primary public interface are the menu_xxx  s which correspond to inputs.  Until we have a better UI setup,
we do what we can to at least pull that out. They get called from control.lua at appropriate points.

After a bunch of thought the underlying representation of the lists is a flat array tagged with the category each thing
goes in e.g. locked etc.  This lets us represent the position with an index.  That complicates things a bit, but greatly
simplifies menu search.  Hopefully, this can be revisited in future once we have better UI abstractions.
]]
local Consts = require("scripts.consts")
local DataToRuntimeMap = require("scripts.data-to-runtime-map")
local FaUtils = require("scripts.fa-utils")
local Functools = require("scripts.functools")
local Localising = require("scripts.localising")
local Speech = require("scripts.speech")
local TH = require("scripts.table-helpers")

-- This is the workaround for the lack of counts in craft-item research
-- triggers. See data-final-fixes.lua for the data declaration.
---@type fun(): table<string, table<string, integer?>>
local CRAFT_ITEM_COUNTS = Functools.cached(function()
   local map_outer = DataToRuntimeMap.load(Consts.RESEARCH_CRAFT_ITEMS_MAP_OUTER)

   local res = {}

   for protoname, mapname in pairs(map_outer) do
      -- With ModData, numbers are stored directly, no need to convert from strings
      local inner_map = DataToRuntimeMap.load(mapname)
      res[protoname] = inner_map
   end

   return res
end)

---@enum fa.research.ResearchList
local RESEARCH_LISTS = {
   RESEARCHABLE = "researchable",
   LOCKED = "locked",
   RESEARCHED = "researched",
}

local mod = {}

-- Wrap a research's localised name so that, if vanilla doesn't have a localised
-- description, we have a chance ourselves.
---@param tech LuaTechnology | LuaTechnologyPrototype | string
---@return LocalisedString
local function tech_name_string(tech)
   if type(tech) == "string" then tech = prototypes.technology[tech] end
   return { "?", tech.localised_name, { string.format("fa.research-technology-name-%s", tech.name) }, tech.name }
end

---@param tech LuaTechnology | LuaTechnologyPrototype | string
---@return LocalisedString
local function tech_description_string(tech)
   if type(tech) == "string" then tech = prototypes.technology[tech] end

   return {
      "?",
      tech.localised_description,
      { string.format("fa.research-technology-description-%s", tech.name) },
      tech.name,
   }
end

-- Place a given technology at the given index in the research queue for a
-- player's force if possible; tell the player if it was; and return what to announce and true if it
-- happened.  If the index is nil, put it at the end, like table.insert does.
---@param player LuaPlayer
---@param name string
---@param index integer?
---@return LocalisedString, boolean
function mod.enqueue(player, name, index)
   local tech = prototypes.technology[name]
   if not tech then error(string.format("Got an invalid technology name! %s", name)) end

   if tech.research_trigger then return { "fa.research-not-in-labs" }, false end

   -- Reading a player's force always gives a LuaForce; the types carry the write type
   local force = player.force --[[@as LuaForce]]
   local queue = force.research_queue
   if index then
      table.insert(queue, index, name)
   else
      table.insert(queue, name) -- Append to end
   end
   -- redundant? no—Factorio needs the copy written back
   force.research_queue = queue
   -- re-fetch in case the engine normalized it
   queue = force.research_queue
   local added = false
   for _, e in pairs(queue) do
      if e.name == name then
         added = true
         break
      end
   end

   if added then
      local tech_param = tech_name_string(player.force.technologies[name])
      if index == 1 then
         return { "fa.research-enqueued-front", tech_param }, true
      elseif index == nil then
         return { "fa.research-enqueued-back", tech_param }, true
      else
         -- Shouldn't be reachable, but whatever, do we care?
         return { "fa.research-enqueued-front", tech_param }, true
      end
   else
      for pred in pairs(tech.prerequisites) do
         if not force.technologies[pred].researched then return { "fa.research-needs-dependencies" }, false end
      end
   end

   return { "fa.research-not-enqueued" }, false
end

---@param trig ResearchTrigger
---@return LocalisedString
local function localise_trigger(tech, trig)
   local res = { string.format("fa.research-trigger-%s", trig.type) }

   if trig.type == "craft-item" then
      table.insert(res, Localising.get_localised_name_with_fallback(prototypes.item[trig.item.name]))

      local amount = CRAFT_ITEM_COUNTS()[tech.name][trig.item.name]
      assert(amount)
      table.insert(res, amount)
      -- Read back as a LuaQualityPrototype, though the generated types say string
      local quality = trig.item.quality --[[@as QualityID?]]
      local quality_name = "normal"
      if type(quality) == "string" then
         quality_name = quality
      elseif quality then
         quality_name = quality.name
      end
      table.insert(res, quality_name)
   elseif trig.type == "mine-entity" then
      local parts = {}
      for _, e in
         pairs((trig --[[@as ResearchTrigger.mine_entity]]).entities)
      do
         table.insert(parts, Localising.get_localised_name_with_fallback(prototypes.entity[e]))
      end
      table.insert(res, FaUtils.localise_cat_table(parts, ", "))
   elseif trig.type == "craft-fluid" then
      table.insert(res, Localising.get_localised_name_with_fallback(prototypes.fluid[trig.fluid]))
      table.insert(res, trig.amount)
   elseif trig.type == "capture-spawner" then
      table.insert(res, Localising.get_localised_name_with_fallback(prototypes.entity[trig.entity]))
   elseif trig.type == "build-entity" then
      -- TODO: We don't handle quality yet because that is very hard to
      -- localise, and we are just getting 1.0 parity at the moment.
      table.insert(res, Localising.get_localised_name_with_fallback(prototypes.entity[trig.entity.name]))
   elseif trig.type == "send-item-to-orbit" then
      table.insert(res, trig.item.name)
   end

   return res
end

---@param tech LuaTechnology
---@return LocalisedString
local function localise_science_cost(tech)
   -- We have a cost, then we have individual costs beyond that, then what we want
   -- to do is alphabetize the list and very carefully avoid repeating repeated
   -- numbers.

   -- How many "rounds" of the ingredients will be needed.
   local units = tech.research_unit_count

   -- By the types, technically these ingredients can be fluids. Fluids can't happen because the actual prototype only
   -- accepts tools.
   local ingredients = {}

   for _, ingredient in pairs(tech.research_unit_ingredients) do
      ingredients[ingredient.name] = (ingredients[ingredient.name] or 0) + ingredient.amount
   end

   -- Now invert this.  Then we get groups for "free". We will announce greatest to least, so use negatives and
   -- table-helpers helps us table.
   local groups = TH.defaulting_table()
   for name, amount in pairs(ingredients) do
      local real = amount * units
      table.insert(groups[-real], name)
   end

   local sorted = TH.set_to_sorted_array(groups)

   for _, t in pairs(sorted) do
      table.sort(t[2])
   end

   -- Okay, finally we can do this.
   local grouplist = {}
   for _, g in pairs(sorted) do
      local names = g[2]
      local amount = -g[1]
      local namelist = {}
      for _, n in pairs(names) do
         table.insert(namelist, Localising.get_localised_name_with_fallback(prototypes.item[n]))
      end

      table.insert(grouplist, { "fa.research-costs-items-entry", FaUtils.localise_cat_table(namelist, ", "), amount })
   end

   if not next(grouplist) then
      return { "fa.research-technology-costs-nothing" }
   else
      return { "fa.research-costs-items", FaUtils.localise_cat_table(grouplist, " and ") }
   end
end

---Get the time per research unit for a technology.
---Returns nil for trigger-based research (no lab time).
---@param tech LuaTechnology
---@return LocalisedString?
local function localise_research_time_per_unit(tech)
   -- Trigger-based research doesn't have a time per unit
   if tech.prototype.research_trigger then return nil end

   local ticks = tech.research_unit_energy
   return { "fa.research-time-per-unit", FaUtils.format_time(ticks) }
end

---@param tech LuaTechnology
local function localise_research_requirements(tech)
   local trig_or_cost
   if tech.prototype.research_trigger then
      trig_or_cost = localise_trigger(tech, tech.prototype.research_trigger)
   else
      trig_or_cost = localise_science_cost(tech)
   end

   if not next(tech.prerequisites) then return trig_or_cost end

   ---@type table
   local prereqs = {}
   for k, v in pairs(tech.prerequisites) do
      table.insert(prereqs, v)
   end
   table.sort(prereqs, function(a, b)
      return a.name < b.name
   end)

   local prereqs_msg = FaUtils.localise_cat_table(TH.map(prereqs, tech_name_string), ", ")
   return FaUtils.spacecat(trig_or_cost, { "fa.research-needs-techs", prereqs_msg })
end

---@type table<string, true?>
local BONUSES_ARE_PERCENTS = TH.array_to_set({}, {
   "laboratory-speed",
   "worker-robot-speed",
   "ammo-damage",
   "gun-speed",
   "character-crafting-speed",
   "character-mining-speed",
   "character-running-speed",
   "worker-robot-battery",
   "laboratory-productivity",
   "artillery-range",
})

---@param player LuaPlayer
---@param tech LuaTechnology
local function localise_research_rewards(player, tech)
   local direct_unlocks = {}
   local indirect_unlock_count = 0
   local recipes = {}

   -- Figure out the technologies this technology unlocks, if it has not yet been researched.  If it has, then just
   -- leave these two parts out.
   if not tech.researched then
      -- Iterate over all successors. Check that 1, 2, or more predecessors are unlocked. If it's exactly one it must be
      -- us, otherwise it must be indirect. Stop after the second for performance.
      for _, candidate in pairs(tech.successors) do
         -- Skip hidden successors
         if not candidate.prototype.hidden then
            local locked = 0
            for name, pred in pairs(candidate.prerequisites) do
               if not pred.researched then
                  locked = locked + 1
                  if locked > 1 then break end
               end
            end

            if locked == 1 then
               -- If only one predecessor of this successor was locked, it's us and will unlock after this research.
               table.insert(direct_unlocks, candidate)
            elseif locked > 1 then
               indirect_unlock_count = indirect_unlock_count + 1
            end
         end
      end
   end

   local other_bonuses = {}

   -- Go over the rewards collecting them one by one. Carve out our special cases, otherwise fallb ack to Vanilla. TODO:
   -- we will need to carve out the space age bonuses. For now I have ignored them.
   for _, reward in pairs(tech.prototype.effects) do
      if reward.type == "gun-speed" then
         table.insert(other_bonuses, {
            "fa.research-reward-gun-speed",
            Localising.get_localised_name_with_fallback(prototypes.ammo_category[reward.ammo_category]),
            string.format("%2.d", reward.modifier * 100),
         })
      elseif reward.type == "ammo-damage" then
         table.insert(other_bonuses, {
            "fa.research-reward-gun-damage",
            Localising.get_localised_name_with_fallback(prototypes.ammo_category[reward.ammo_category]),
            string.format("%2.d", reward.modifier * 100),
         })
      elseif reward.type == "turret-attack" then
         table.insert(other_bonuses, {
            "fa.research-reward-turret-attack",
            Localising.get_localised_name_with_fallback(prototypes.entity[reward.turret_id]),
            string.format("%2.d", reward.modifier * 100),
         })
      elseif reward.type == "give-item" then
         table.insert(other_bonuses, {
            "fa.research-reward-give-item",
            Localising.get_localised_name_with_fallback(prototypes.item[reward.item]),
            reward.count,
         })
      elseif reward.type == "nothing" then
         table.insert(
            other_bonuses,
            { "fa.research-reward-nothing", reward.effect_description or "NO DESCRIPTION AVAILABLE" }
         )
      elseif reward.type == "unlock-recipe" then
         table.insert(recipes, prototypes.recipe[reward.recipe])
      else
         -- It's something else, or that we don't know how to handle.
         local key = "fa.research-reward-vanilla-localised-bonus"
         local amount = tostring(reward.modifier)
         if BONUSES_ARE_PERCENTS[reward.type] then
            key = "fa.research-reward-vanilla-localised-bonus-percent"
            amount = string.format("%2.d", reward.modifier * 100)
         end
         -- This complicated string is saying try Vanilla to see if it's
         -- localised, otherwise directly say the raw type.
         table.insert(
            other_bonuses,
            { key, { "?", { string.format("gui-bonus.%s", reward.type) }, reward.type }, amount }
         )
      end
   end

   table.sort(recipes, function(a, b)
      return a.name < b.name
   end)
   table.sort(direct_unlocks, function(a, b)
      return a.name < b.name
   end)

   local result = {}

   -- This magic value is 0xffffffff e.g. UINT32_MAX, and is how Factorio is
   -- converting max levels to the runtime stage API for infinite technologies.
   if tech.prototype.max_level == 4294967295 then table.insert(result, { "fa.research-rewards-tech-infinite" }) end

   if next(recipes) then
      local recipe_string = FaUtils.localise_cat_table(
         TH.map(recipes, function(r)
            return Localising.get_localised_name_with_fallback(r)
         end),
         ", "
      )
      table.insert(result, { "fa.research-rewards-recipes", recipe_string })
   end

   TH.concat_arrays(result, other_bonuses)

   if next(direct_unlocks) then
      local unlocks_string = FaUtils.localise_cat_table(
         TH.map(direct_unlocks, function(t)
            return Localising.get_localised_name_with_fallback(t)
         end),
         ", "
      )
      table.insert(result, { "fa.research-rewards-next-researches", unlocks_string })
   end

   if indirect_unlock_count > 0 then
      table.insert(result, { "fa.research-rewards-other-researches", indirect_unlock_count })
   end

   return FaUtils.localise_cat_table(result)
end

---@class fa.research.ResearchEntry
---@field name string
---@field tech LuaTechnology
---@field list fa.research.ResearchList

-- Get an array of all visible technologies for this player, ordered by prototype name
-- and tagged with the category to which they belong.
---@param player LuaPlayer
---@return fa.research.ResearchEntry[]
local function get_visible_researches(player)
   ---@type fa.research.ResearchEntry[]
   local res = {}

   for name, tech in
      pairs((player.force --[[@as LuaForce]]).technologies)
   do
      -- Skip hidden technologies - they're not meant to be shown to players
      if tech.prototype.hidden then goto continue end

      local list

      if tech.researched then
         list = RESEARCH_LISTS.RESEARCHED
      else
         local all_unlocked = true

         for _, t in pairs(tech.prerequisites) do
            if not t.researched then
               all_unlocked = false
               break
            end
         end

         list = all_unlocked and RESEARCH_LISTS.RESEARCHABLE or RESEARCH_LISTS.LOCKED
      end

      table.insert(res, {
         name = name,
         tech = tech,
         list = list,
      })

      ::continue::
   end

   table.sort(res, function(a, b)
      return a.name < b.name
   end)

   return res
end

-- For when pressing `t`, the research part of the string.
---@param pindex integer
---@return LocalisedString
function mod.get_progress_string(pindex)
   local player = game.get_player(pindex)
   assert(player)
   local tech = player.force.current_research
   if tech then
      local progress = player.force.research_progress
      return { "fa.research-progress", tech_name_string(tech), FaUtils.format_percentage(progress * 100, "complete") }
   end

   return { "fa.research-no-progress" }
end

-- Called when the menu "gains focus".

---@param event EventData.on_research_finished
function mod.on_research_finished(event)
   local tech = event.research
   local name_str = tech_name_string(tech)
   local recipes = {}

   for _, v in pairs(tech.prototype.effects) do
      if v.type == "unlock-recipe" then table.insert(recipes, v.recipe) end
   end

   local announcing = { "fa.research-finished-plain", name_str }
   if next(recipes) then
      local namified = TH.map(recipes, function(r)
         return Localising.get_localised_name_with_fallback(prototypes.recipe[r])
      end)

      local joined = FaUtils.localise_cat_table(namified, ", ")
      announcing = { "fa.research-finished-with-recipes", name_str, joined }
   end

   local force = tech.force
   local players = force.players
   for _, p in pairs(players) do
      Speech.speak(p.index, announcing)
   end
end

-- Export functions for UI
mod.tech_name_string = tech_name_string
mod.tech_description_string = tech_description_string
mod.localise_research_requirements = localise_research_requirements
mod.localise_research_rewards = localise_research_rewards
mod.localise_research_time_per_unit = localise_research_time_per_unit
mod.get_visible_researches = get_visible_researches

return mod
