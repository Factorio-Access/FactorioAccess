---Help UI viewer
---
---Displays help messages from message lists or direct localised strings.
local TabList = require("scripts.ui.tab-list")
local UiKeyGraph = require("scripts.ui.key-graph")
local Menu = require("scripts.ui.menu")
local MessageLists = require("scripts.message-lists")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder
local Router = require("scripts.ui.router")

local mod = {}

---@enum fa.ui.help.MessageKind
mod.MESSAGE_KIND = {
   MESSAGE_LIST = 1,
   MESSAGE = 2,
}

---@class fa.ui.help.HelpItem
---@field kind fa.ui.help.MessageKind
---@field value string Either message list name or localised string

---@class fa.ui.help.Parameters
---@field items fa.ui.help.HelpItem[] Array of help items to display

local help_graph = UiKeyGraph.declare_graph({
   name = "help",
   title = { "fa.help-title" },
   render_callback = function(ctx)
      ---@type fa.ui.help.Parameters
      local params = ctx.global_parameters

      local menu = Menu.MenuBuilder.new()

      -- Handle missing or empty parameters
      if not params or not params.items or #params.items == 0 then
         menu:add_label("empty", { "fa.help-no-content" })
         return menu:build()
      end

      -- Collect all messages to display
      local all_messages = {}
      local all_ready = true

      for _, item in ipairs(params.items) do
         if item.kind == mod.MESSAGE_KIND.MESSAGE_LIST then
            -- Get message list metadata
            local result = MessageLists.get_message_list_meta(ctx.pindex, item.value)

            if result.status == MessageLists.STATUS.NOT_FOUND then
               table.insert(all_messages, { "fa.help-message-list-not-found", item.value })
            elseif result.status == MessageLists.STATUS.PENDING then
               all_ready = false
            elseif result.status == MessageLists.STATUS.READY then
               -- Add all messages from the list (programmatically built keys)
               for _, message in ipairs(result.messages) do
                  table.insert(all_messages, message)
               end
            end
         elseif item.kind == mod.MESSAGE_KIND.MESSAGE then
            -- Direct localised string
            table.insert(all_messages, item.value)
         end
      end

      -- If not all ready, show pending message
      if not all_ready then
         menu:add_label("pending", { "fa.help-loading" })
         return menu:build()
      end

      -- If no messages, show empty
      if #all_messages == 0 then
         menu:add_label("empty", { "fa.help-empty" })
         return menu:build()
      end

      -- Add navigation message first
      menu:add_label("navigation", { "fa.help-menu-navigation" })

      -- Add each message as a label
      for i, message in ipairs(all_messages) do
         local key = "msg_" .. tostring(i)
         menu:add_label(key, message)
      end

      return menu:build()
   end,
})

local help_ui = TabList.declare_tablist({
   ui_name = Router.UI_NAMES.HELP,
   tabs_callback = function(pindex, parameters)
      return {
         {
            name = "help",
            tabs = { help_graph },
         },
      }
   end,
})

-- Register with router
Router.register_ui(help_ui)

---Create help parameters from a list of help items
---@param items fa.ui.help.HelpItem[]
---@return fa.ui.help.Parameters
function mod.create_parameters(items)
   return { items = items }
end

---Helper to create a message list help item
---@param list_name string
---@return fa.ui.help.HelpItem
function mod.message_list(list_name)
   return { kind = mod.MESSAGE_KIND.MESSAGE_LIST, value = list_name }
end

---Helper to create a direct message help item
---@param message LocalisedString
---@return fa.ui.help.HelpItem
function mod.message(message)
   return { kind = mod.MESSAGE_KIND.MESSAGE, value = message }
end

return mod
