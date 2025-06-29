--Here: functions specific to the menus of buildings and vehicles.
local util = require("util")
local Blueprints = require("scripts.blueprints")
local Crafting = require("scripts.crafting")
local FaUtils = require("scripts.fa-utils")
local Filters = require("scripts.filters")
local localising = require("scripts.localising")
local MessageBuilder = require("scripts.message-builder")
local TransportBelts = require("scripts.transport-belts")
local BeltAnalyzer = require("scripts.ui.belt-analyzer")
local UiRouter = require("scripts.ui.router")
local Viewpoint = require("scripts.viewpoint")

local mod = {}

--[[Function to increase/decrease the bar (restricted slots) of a given chest/container by a given amount, while protecting its lower and upper bounds.
* Returns the verbal explanation to print out.
* amount = number of slots to change, set negative value for a decrease.
]]
function mod.add_to_inventory_bar(ent, amount)
   local inventory = ent.get_inventory(defines.inventory.chest)

   --Checks
   if not inventory then return { "fa.failed-inventory-limit-ajust-notcontainter" } end
   if not inventory.supports_bar() then return { "fa.failed-inventory-limit-ajust-no-limit" } end

   local max_bar = #inventory + 1
   local current_bar = inventory.get_bar()

   --Change bar
   amount = amount or 1
   current_bar = current_bar + amount

   if current_bar < 1 then
      current_bar = 1
   elseif current_bar > max_bar then
      current_bar = max_bar
   end

   inventory.set_bar(current_bar)

   --Return result
   ---@ type LocalisedString
   local value = current_bar - 1 --Mismatch correction
   if current_bar == max_bar then
      value = { "gui.all" }
      current_bar = 1000
   else
      current_bar = value
   end
   return { "fa.inventory-limit-status", value, current_bar }
end

--Increases the selected inserter's hand stack size by 1
function mod.inserter_hand_stack_size_up(inserter)
   local result = ""
   inserter.inserter_stack_size_override = inserter.inserter_stack_size_override + 1
   result = inserter.inserter_stack_size_override .. " set for hand stack size"
   return result
end

--Decreases the selected inserter's hand stack size by 1
function mod.inserter_hand_stack_size_down(inserter)
   local result = ""
   if inserter.inserter_stack_size_override > 1 then
      inserter.inserter_stack_size_override = inserter.inserter_stack_size_override - 1
      result = inserter.inserter_stack_size_override .. " set for hand stack size"
   else
      inserter.inserter_stack_size_override = 0
      local cap = inserter.force.inserter_stack_size_bonus + 1
      if inserter.name == "stack-inserter" or inserter.name == "stack-filter-inserter" then
         cap = inserter.force.stack_inserter_capacity_bonus + 1
      end
      result = "restored " .. cap .. " as default hand stack size "
   end
   return result
end

--Loads and opens the building menu
function mod.open_operable_building(ent, pindex)
   local router = UiRouter.get_router(pindex)
   local vp = Viewpoint.get_viewpoint(pindex)

   if ent.operable and ent.prototype.is_building then
      --Check if within reach
      if
         util.distance(game.get_player(pindex).position, vp:get_cursor_pos())
         > game.get_player(pindex).reach_distance
      then
         game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
         printout({ "fa.bvs-building-out-of-reach" }, pindex)
         game.get_player(pindex).opened = nil
         return
      end
      --Open GUI if not already
      local p = game.get_player(pindex)
      if p.opened == nil then p.opened = ent end
      --Other stuff...
      players[pindex].menu_search_index = 0
      players[pindex].menu_search_index_2 = 0
      if ent.prototype.subgroup.name == "belt" then
         router:open_ui(UiRouter.UI_NAMES.BELT)
         BeltAnalyzer.belt_analyzer:open(pindex, { entity = ent })
         return
      end
      if ent.prototype.ingredient_count ~= nil then
         players[pindex].building.recipe = ent.get_recipe()
         players[pindex].building.recipe_list = Crafting.get_recipes(pindex, ent)
         players[pindex].building.category = 1
      else
         players[pindex].building.recipe = nil
         players[pindex].building.recipe_list = nil
         players[pindex].building.category = 0
      end
      players[pindex].building.item_selection = false
      players[pindex].inventory.lua_inventory = game.get_player(pindex).get_main_inventory()
      players[pindex].inventory.max = #players[pindex].inventory.lua_inventory
      players[pindex].building.sectors = {}
      players[pindex].building.sector = 1

      --Inventories as sectors
      if ent.get_output_inventory() ~= nil then
         table.insert(players[pindex].building.sectors, {
            name = "Output",
            inventory = ent.get_output_inventory(),
         })
      end
      if ent.get_fuel_inventory() ~= nil then
         table.insert(players[pindex].building.sectors, {
            name = "Fuel",
            inventory = ent.get_fuel_inventory(),
         })
      end
      if ent.prototype.ingredient_count ~= nil then
         table.insert(players[pindex].building.sectors, {
            name = "Input",
            inventory = ent.get_inventory(defines.inventory.assembling_machine_input),
         })
      end
      if ent.get_module_inventory() ~= nil and #ent.get_module_inventory() > 0 then
         table.insert(players[pindex].building.sectors, {
            name = "Modules",
            inventory = ent.get_module_inventory(),
         })
      end
      if ent.get_burnt_result_inventory() ~= nil and #ent.get_burnt_result_inventory() > 0 then
         table.insert(players[pindex].building.sectors, {
            name = "Burnt result",
            inventory = ent.get_burnt_result_inventory(),
         })
      end
      if ent.fluidbox ~= nil and #ent.fluidbox > 0 then
         table.insert(players[pindex].building.sectors, {
            name = "Fluid",
            inventory = ent.fluidbox,
         })
      end

      --Special inventories
      local invs = defines.inventory
      if ent.type == "rocket-silo" then
         if ent.get_inventory(invs.rocket_silo_rocket) ~= nil and #ent.get_inventory(invs.rocket_silo_rocket) > 0 then
            table.insert(players[pindex].building.sectors, {
               name = "Rocket",
               inventory = ent.get_inventory(invs.rocket_silo_rocket),
            })
         end
      end

      if ent.filter_slot_count > 0 and ent.type == "inserter" then
         table.insert(players[pindex].building.sectors, {
            name = "Filters",
            inventory = {},
         })
         --Add inserter filter info
         for i = 1, ent.filter_slot_count do
            local filter = Filters.get_filter_prototype(ent, i)
            if filter == nil then filter = "No filter selected." end
            table.insert(players[pindex].building.sectors[#players[pindex].building.sectors].inventory, filter)
         end
         table.insert(
            players[pindex].building.sectors[#players[pindex].building.sectors].inventory,
            ent.inserter_filter_mode
         )
         players[pindex].item_selection = false
         players[pindex].item_cache = {}
         players[pindex].item_selector = {
            index = 0,
            group = 0,
            subgroup = 0,
         }
      end

      for i1 = #players[pindex].building.sectors, 2, -1 do
         for i2 = i1 - 1, 1, -1 do
            if players[pindex].building.sectors[i1].inventory == players[pindex].building.sectors[i2].inventory then
               table.remove(players[pindex].building.sectors, i2)
               i2 = i2 + 1
            end
         end
      end
      if #players[pindex].building.sectors > 0 then
         players[pindex].building.ent = ent
         router:open_ui(UiRouter.UI_NAMES.BUILDING)
         players[pindex].move_queue = {}
         players[pindex].inventory.index = 1
         players[pindex].building.index = 1
         local pb = players[pindex].building
         players[pindex].building.sector_name = pb.sectors[pb.sector].name

         --For assembling machine types with no recipe, open recipe building sector directly
         local recipe = players[pindex].building.recipe
         if
            (recipe == nil or not recipe.valid)
            and (ent.prototype.type == "assembling-machine")
            and players[pindex].building.recipe_list ~= nil
         then
            players[pindex].building.sector = #players[pindex].building.sectors + 1
            players[pindex].building.index = 1
            players[pindex].building.category = 1
            players[pindex].building.recipe_selection = false
            players[pindex].building.sector_name = "unloaded recipe selection"

            players[pindex].building.item_selection = false
            players[pindex].item_selection = false
            players[pindex].item_cache = {}
            players[pindex].item_selector = {
               index = 0,
               group = 0,
               subgroup = 0,
            }
            mod.read_building_recipe(pindex, "Select a Recipe, ")
            return
         end
         mod.read_sector_slot(pindex, true)
      else
         --No building sectors
         if game.get_player(pindex).opened ~= nil then
            players[pindex].building.ent = ent
            router:open_ui(UiRouter.UI_NAMES.BUILDING_NO_SECTORS)
            local result =
               { "", localising.get_localised_name_with_fallback(ent), { "fa.bvs-this-menu-has-no-options" } }
            if ent.type == "inserter" then
               result =
                  { "", localising.get_localised_name_with_fallback(ent), { "fa.bvs-pageup-pagedown-edit-hand-stack" } }
            end
            if ent.get_control_behavior() ~= nil then table.insert(result, { "fa.bvs-press-n-circuit-network" }) end
            printout(result, pindex)
         else
            printout({ "", localising.get_localised_name_with_fallback(ent), { "fa.bvs-has-no-menu" } }, pindex)
         end
      end
   else
      printout({ "fa.bvs-not-operable-building" }, pindex)
   end
end

--Loads and opens the vehicle menu
function mod.open_operable_vehicle(ent, pindex)
   local router = UiRouter.get_router(pindex)
   local vp = Viewpoint.get_viewpoint(pindex)

   if ent.valid and ent.operable then
      --Check if within reach
      if
         util.distance(game.get_player(pindex).position, vp:get_cursor_pos())
         > game.get_player(pindex).reach_distance
      then
         game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
         game.get_player(pindex).opened = nil
         printout({ "fa.bvs-vehicle-out-of-reach" }, pindex)
         return
      end
      --Open GUI if not already
      local p = game.get_player(pindex)
      if p.opened == nil then p.opened = ent end
      --Other stuff...
      players[pindex].menu_search_index = 0
      players[pindex].menu_search_index_2 = 0
      if ent.prototype.ingredient_count ~= nil then
         players[pindex].building.recipe = ent.get_recipe()
         players[pindex].building.recipe_list = Crafting.get_recipes(pindex, ent)
         players[pindex].building.category = 1
      else
         players[pindex].building.recipe = nil
         players[pindex].building.recipe_list = nil
         players[pindex].building.category = 0
      end
      players[pindex].building.item_selection = false
      players[pindex].inventory.lua_inventory = game.get_player(pindex).get_main_inventory()
      players[pindex].inventory.max = #players[pindex].inventory.lua_inventory
      players[pindex].building.sectors = {}
      players[pindex].building.sector = 1

      --Inventories as sectors
      if ent.get_output_inventory() ~= nil then
         table.insert(players[pindex].building.sectors, {
            name = "Output",
            inventory = ent.get_output_inventory(),
         })
      end
      if ent.get_fuel_inventory() ~= nil then
         table.insert(players[pindex].building.sectors, {
            name = "Fuel",
            inventory = ent.get_fuel_inventory(),
         })
      end
      if ent.get_burnt_result_inventory() ~= nil and #ent.get_burnt_result_inventory() > 0 then
         table.insert(players[pindex].building.sectors, {
            name = "Burnt result",
            inventory = ent.get_burnt_result_inventory(),
         })
      end

      --Special inventories
      local invs = defines.inventory
      if ent.type == "car" then
         --Trunk = Output, Fuel = Fuel
         if ent.get_inventory(invs.car_ammo) ~= nil and #ent.get_inventory(invs.car_ammo) > 0 then
            table.insert(players[pindex].building.sectors, {
               name = "Ammo",
               inventory = ent.get_inventory(invs.car_ammo),
            })
         end
      end
      if ent.type == "spider-vehicle" then
         if ent.get_inventory(invs.spider_trunk) ~= nil and #ent.get_inventory(invs.spider_trunk) > 0 then
            table.insert(players[pindex].building.sectors, {
               name = "Output",
               inventory = ent.get_inventory(invs.spider_trunk),
            })
         end
         if ent.get_inventory(invs.spider_trash) ~= nil and #ent.get_inventory(invs.spider_trash) > 0 then
            table.insert(players[pindex].building.sectors, {
               name = "Trash",
               inventory = ent.get_inventory(invs.spider_trash),
            })
         end
         if ent.get_inventory(invs.spider_ammo) ~= nil and #ent.get_inventory(invs.spider_ammo) > 0 then
            table.insert(players[pindex].building.sectors, {
               name = "Ammo",
               inventory = ent.get_inventory(invs.spider_ammo),
            })
         end
      end

      for i1 = #players[pindex].building.sectors, 2, -1 do
         for i2 = i1 - 1, 1, -1 do
            if players[pindex].building.sectors[i1].inventory == players[pindex].building.sectors[i2].inventory then
               table.remove(players[pindex].building.sectors, i2)
               i2 = i2 + 1
            end
         end
      end
      if #players[pindex].building.sectors > 0 then
         players[pindex].building.ent = ent
         router:open_ui(UiRouter.UI_NAMES.VEHICLE)
         players[pindex].move_queue = {}
         players[pindex].inventory.index = 1
         players[pindex].building.index = 1
         local pb = players[pindex].building
         players[pindex].building.sector_name = pb.sectors[pb.sector].name

         mod.read_sector_slot(pindex, true)
      else
         if game.get_player(pindex).opened ~= nil then
            players[pindex].building.ent = ent
            router:open_ui(UiRouter.UI_NAMES.VEHICLE_NO_SECTORS)
            local message = MessageBuilder.new()
            message:fragment(ent.name)
            message:fragment(", this menu has no options ")
            printout(message:build(), pindex)
         else
            local message = MessageBuilder.new()
            message:fragment(ent.name)
            message:fragment(" has no menu ")
            printout(message:build(), pindex)
         end
      end
   else
      printout({ "fa.bvs-not-operable-vehicle" }, pindex)
   end
end

--Building recipe selection sector: Read the selected recipe
function mod.read_building_recipe(pindex, start_phrase)
   start_phrase = start_phrase or ""
   if players[pindex].building.recipe_selection then --inside the selector
      local recipe =
         players[pindex].building.recipe_list[players[pindex].building.category][players[pindex].building.index]
      if recipe and recipe.valid then
         local message = MessageBuilder.new()
         if start_phrase ~= "" then message:fragment(start_phrase) end
         message:fragment(localising.get_localised_name_with_fallback(recipe))
         message:fragment(" ")
         message:fragment(recipe.category)
         message:fragment(" ")
         message:fragment(recipe.group.name)
         message:fragment(" ")
         message:fragment(recipe.subgroup.name)
         printout(message:build(), pindex)
      else
         local message = MessageBuilder.new()
         if start_phrase ~= "" then message:fragment(start_phrase) end
         message:fragment({ "fa.bvs-blank" })
         printout(message:build(), pindex)
      end
   else
      local recipe = players[pindex].building.recipe
      if recipe ~= nil then
         printout(
            { "", start_phrase, { "fa.bvs-currently-producing" }, localising.get_localised_name_with_fallback(recipe) },
            pindex
         )
      else
         printout({ "", start_phrase, { "fa.bvs-press-left-bracket" } }, pindex)
      end
   end
end

--Building sectors: Read the item or fluid at the selected slot.
function mod.read_sector_slot(pindex, prefix_inventory_size_and_name, start_phrase_in)
   local building_sector = players[pindex].building.sectors[players[pindex].building.sector]
   local start_phrase = start_phrase_in or ""
   if building_sector.name == "Filters" then
      local inventory = building_sector.inventory
      if prefix_inventory_size_and_name then
         start_phrase = start_phrase .. #inventory .. " " .. building_sector.name .. ", "
      end
      printout(
         start_phrase
            .. players[pindex].building.index
            .. ", "
            .. building_sector.inventory[players[pindex].building.index],
         pindex
      )
   elseif building_sector.name == "Fluid" then
      if
         players[pindex].building.ent ~= nil
         and players[pindex].building.ent.valid
         and players[pindex].building.ent.type == "fluid-turret"
         and players[pindex].building.index ~= 1
      then
         --Prevent fluid turret crashes
         players[pindex].building.index = 1
      end
      local box = building_sector.inventory
      if #box == 0 then
         printout({ "fa.bvs-no-fluid" }, pindex)
         return
      elseif players[pindex].building.index > #box or players[pindex].building.index == 0 then
         players[pindex].building.index = 1
         game.get_player(pindex).play_sound({ path = "inventory-wrap-around" })
      end
      local capacity = box.get_capacity(players[pindex].building.index)
      local type = box.get_prototype(players[pindex].building.index).production_type
      local fluid = box[players[pindex].building.index]
      local len = #box
      if prefix_inventory_size_and_name then
         start_phrase = start_phrase .. len .. " " .. building_sector.name .. ", "
      end
      --fluid = {name = "water", amount = 1}
      local name = "Any"
      local amount = 0
      if fluid ~= nil then
         amount = fluid.amount
         name = localising.get_localised_name_with_fallback(prototypes.fluid[fluid.name])
      end --laterdo use fluidbox.get_locked_fluid(i) if needed.
      --Read the fluid ingredients & products
      --Note: We could have separated by input/output but right now the "type" is "input" for all fluids it seeems?
      local recipe = players[pindex].building.recipe
      if recipe ~= nil then
         local index = players[pindex].building.index
         local input_fluid_count = 0
         local input_item_count = 0
         for i, v in pairs(recipe.ingredients) do
            if v.type == "fluid" then
               input_fluid_count = input_fluid_count + 1
            else
               input_item_count = input_item_count + 1
            end
         end
         local output_fluid_count = 0
         local output_item_count = 0
         for i, v in pairs(recipe.products) do
            if v.type == "fluid" then
               output_fluid_count = output_fluid_count + 1
            else
               output_item_count = output_item_count + 1
            end
         end
         if index < 0 then index = 0 end
         local prev_name = name
         name = { "fa.bvs-empty-slot-reserved-for" }
         if index <= input_fluid_count then
            index = index + input_item_count
            for i, v in pairs(recipe.ingredients) do
               if v.type == "fluid" and i == index then
                  local localised_name = localising.get_localised_name_with_fallback(prototypes.fluid[v.name])
                  name = {
                     "",
                     name,
                     " ",
                     { "fa.bvs-input" },
                     " ",
                     localised_name,
                     " ",
                     { "fa.bvs-times" },
                     " ",
                     tostring(v.amount),
                     " ",
                     { "fa.bvs-per-cycle" },
                     " ",
                  }
                  if prev_name ~= "Any" then
                     name = {
                        "",
                        { "fa.bvs-input" },
                        " ",
                        prev_name,
                        " ",
                        { "fa.bvs-times" },
                        " ",
                        tostring(math.floor(0.5 + amount)),
                     }
                  end
               end
            end
         else
            index = index - input_fluid_count
            index = index + output_item_count
            for i, v in pairs(recipe.products) do
               if v.type == "fluid" and i == index then
                  local localised_name = localising.get_localised_name_with_fallback(prototypes.fluid[v.name])
                  name = {
                     "",
                     name,
                     " ",
                     { "fa.bvs-output" },
                     " ",
                     localised_name,
                     " ",
                     { "fa.bvs-times" },
                     " ",
                     tostring(v.amount),
                     " ",
                     { "fa.bvs-per-cycle" },
                     " ",
                  }
                  if prev_name ~= "Any" then
                     name = {
                        "",
                        { "fa.bvs-output" },
                        " ",
                        prev_name,
                        " ",
                        { "fa.bvs-times" },
                        " ",
                        tostring(math.floor(0.5 + amount)),
                     }
                  end
               end
            end
         end
      else
         name = { "", name, " ", { "fa.bvs-times" }, " ", tostring(math.floor(0.5 + amount)) }
      end
      --Read the fluid found, including amount if any
      if type(name) == "string" then
         printout({ "", start_phrase, " ", name }, pindex)
      else
         printout({ "", start_phrase, " ", name }, pindex)
      end
   elseif #building_sector.inventory > 0 then
      --Item inventories
      local inventory = building_sector.inventory
      if prefix_inventory_size_and_name then
         start_phrase = start_phrase .. #inventory .. " " .. building_sector.name .. ", "
         if inventory.supports_bar() and #inventory > inventory.get_bar() - 1 then
            --local unlocked = inventory.supports_bar() and inventory.get_bar() - 1 or nil
            local unlocked = inventory.get_bar() - 1
            start_phrase = { "", start_phrase, ", ", tostring(unlocked), " ", { "fa.bvs-unlocked" }, ", " }
         end
      end
      --Mention if the selected slot is locked
      if inventory.supports_bar() and players[pindex].building.index > inventory.get_bar() - 1 then
         start_phrase = { "", start_phrase, " ", { "fa.bvs-locked" }, " " }
      end
      --Read the slot stack
      local stack = building_sector.inventory[players[pindex].building.index]
      if stack and stack.valid_for_read and stack.valid then
         if stack.is_blueprint then
            printout(Blueprints.get_blueprint_info(stack, false, pindex), pindex)
         elseif stack.is_blueprint_book then
            printout(Blueprints.get_blueprint_book_info(stack, false), pindex)
         else
            --Check if the slot is filtered
            local index = players[pindex].building.index
            if building_sector.inventory.supports_filters() then
               local filter_name = building_sector.inventory.get_filter(index)
               if filter_name ~= nil then start_phrase = { "", start_phrase, " ", { "fa.bvs-filtered" }, " " } end
            end
            --Check if the stack has damage
            if stack.health < 1 then start_phrase = { "", start_phrase, " ", { "fa.bvs-damaged" }, " " } end
            local remote_info = ""
            if stack.name == "spidertron-remote" then
               if stack.connected_entity == nil then
                  remote_info = { "", { "fa.bvs-not-linked" } }
               else
                  if stack.connected_entity.entity_label == nil then
                     remote_info = { "", { "fa.bvs-for-unlabelled-spidertron" } }
                  else
                     remote_info = { "", { "fa.bvs-for-spidertron" }, " ", stack.connected_entity.entity_label }
                  end
               end
            end
            printout({
               "",
               start_phrase,
               localising.get_localised_name_with_fallback(stack.prototype),
               remote_info,
               " x ",
               tostring(stack.count),
            }, pindex)
         end
      else
         --Read the "empty slot"
         local result = { "", { "fa.bvs-empty-slot" } }
         --Check if the empty slot has a filter set
         if building_sector.inventory.supports_filters() then
            local index = players[pindex].building.index
            local filter_name = building_sector.inventory.get_filter(index)
            if filter_name ~= nil then
               table.insert(result, { "fa.bvs-filtered-for" })
               table.insert(result, localising.get_localised_name_with_fallback(prototypes.item[filter_name]))
            end
         end
         if building_sector.name == "Modules" then result = { "", { "fa.bvs-empty-module-slot" } } end
         local recipe = players[pindex].building.recipe
         if recipe ~= nil then
            if building_sector.name == "Input" then
               --For input slots read the recipe ingredients
               table.insert(result, { "fa.bvs-reserved-for" })
               for i, v in pairs(recipe.ingredients) do
                  if v.type == "item" and i == players[pindex].building.index then
                     local localised_name = localising.get_localised_name_with_fallback(prototypes.item[v.name])
                     table.insert(result, localised_name)
                     table.insert(result, " ")
                     table.insert(result, { "fa.bvs-times" })
                     table.insert(result, " ")
                     table.insert(result, tostring(v.amount))
                     table.insert(result, " ")
                     table.insert(result, { "fa.bvs-per-cycle" })
                     table.insert(result, " ")
                  end
               end
               --result = result .. "nothing"
            elseif building_sector.name == "Output" then
               --For output slots read the recipe products
               table.insert(result, { "fa.bvs-reserved-for" })
               for i, v in pairs(recipe.products) do
                  if v.type == "item" and i == players[pindex].building.index then
                     local localised_name = localising.get_localised_name_with_fallback(prototypes.item[v.name])
                     table.insert(result, localised_name)
                     table.insert(result, " ")
                     table.insert(result, { "fa.bvs-times" })
                     table.insert(result, " ")
                     table.insert(result, tostring(v.amount))
                     table.insert(result, " ")
                     table.insert(result, { "fa.bvs-per-cycle" })
                     table.insert(result, " ")
                  end
               end
               --result = result .. "nothing"
            end
         elseif
            players[pindex].building.ent ~= nil
            and players[pindex].building.ent.valid
            and players[pindex].building.ent.type == "lab"
            and building_sector.name == "Output"
         then
            --laterdo switch to {"item-name.".. ent.prototype.lab_inputs[players[pindex].building.index] }
            table.insert(result, { "fa.bvs-reserved-for-science-pack" })
            table.insert(result, " ")
            table.insert(result, tostring(players[pindex].building.index))
         elseif
            players[pindex].building.ent ~= nil
            and players[pindex].building.ent.valid
            and players[pindex].building.ent.type == "roboport"
         then
            result = result .. " reserved for worker robots "
         elseif
            players[pindex].building.ent ~= nil
               and players[pindex].building.ent.valid
               and players[pindex].building.ent.type == "ammo-turret"
            or players[pindex].building.ent.type == "artillery-turret"
         then
            result = result .. " reserved for ammo "
         end
         printout(start_phrase .. result, pindex)
      end
   elseif prefix_inventory_size_and_name then
      printout("0 " .. building_sector.name, pindex)
   end
end

return mod
