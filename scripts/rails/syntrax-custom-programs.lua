---Storage module and helpers for custom Syntrax programs
---
---Each player has their own array of programs.
---Programs have: id, name, source

local StorageManager = require("scripts.storage-manager")
local UID = require("scripts.uid")
local Parser = require("syntrax.parser")

local mod = {}

---@class fa.syntrax.CustomProgram
---@field id number Unique ID from uid()
---@field name string User-provided program name
---@field source string Syntrax source code

---@class fa.syntrax.CustomProgramStorage
---@field programs fa.syntrax.CustomProgram[]

---@type table<number, fa.syntrax.CustomProgramStorage>
local syntrax_storage = StorageManager.declare_storage_module("syntrax_custom_programs", {
   programs = {},
})

---Create a new custom program
---@param pindex number
---@param name string
---@param source string
---@return number id The ID of the newly created program
function mod.create_program(pindex, name, source)
   local id = UID.uid()
   local program = {
      id = id,
      name = name,
      source = source,
   }
   table.insert(syntrax_storage[pindex].programs, program)
   return id
end

---Get a program by ID
---@param pindex number
---@param id number
---@return fa.syntrax.CustomProgram?
function mod.get_program(pindex, id)
   for _, prog in ipairs(syntrax_storage[pindex].programs) do
      if prog.id == id then return prog end
   end
   return nil
end

---Get all programs for a player
---@param pindex number
---@return fa.syntrax.CustomProgram[]
function mod.get_all_programs(pindex)
   return syntrax_storage[pindex].programs
end

---Update a program
---@param pindex number
---@param id number
---@param name string
---@param source string
---@return boolean success
function mod.update_program(pindex, id, name, source)
   local prog = mod.get_program(pindex, id)
   if not prog then return false end

   prog.name = name
   prog.source = source

   return true
end

---Delete a program
---@param pindex number
---@param id number
---@return boolean success
function mod.delete_program(pindex, id)
   local programs = syntrax_storage[pindex].programs
   for i, prog in ipairs(programs) do
      if prog.id == id then
         table.remove(programs, i)
         return true
      end
   end
   return false
end

---Check if a program source compiles without errors
---@param source string
---@return string? error_message Error message if compilation failed, nil if successful
function mod.compile_check(source)
   local _, err = Parser.parse(source)
   if err then return err.message end
   return nil
end

return mod
