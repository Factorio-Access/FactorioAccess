--[[
Compiler for Syntrax language.

Transforms AST into VM bytecode.
]]

local Ast = require("syntrax.ast")
local Vm = require("syntrax.vm")

local mod = {}

---@class syntrax.compiler.State
---@field bytecode syntrax.vm.Bytecode[]
---@field next_register number Next available register number
---@field compile_node fun(self: syntrax.compiler.State, node: syntrax.ast.Node)

local Compiler = {}
local Compiler_meta = { __index = Compiler }

---@return syntrax.compiler.State
function mod.new()
   return setmetatable({
      bytecode = {},
      next_register = 1,
   }, Compiler_meta)
end

---@return number
function Compiler:allocate_register()
   local reg = self.next_register
   self.next_register = self.next_register + 1
   return reg
end

---@param bc syntrax.vm.Bytecode
---@param span syntrax.Span?
function Compiler:emit(bc, span)
   if span then bc.span = span end
   table.insert(self.bytecode, bc)
end

---@return number Current bytecode position (1-indexed)
function Compiler:current_position()
   return #self.bytecode + 1
end

---@param node syntrax.ast.Node
function Compiler:compile_node(node)
   if node.type == Ast.NODE_TYPE.LEFT then
      self:emit(Vm.bytecode(Vm.BYTECODE_KIND.LEFT), node.span)
   elseif node.type == Ast.NODE_TYPE.RIGHT then
      self:emit(Vm.bytecode(Vm.BYTECODE_KIND.RIGHT), node.span)
   elseif node.type == Ast.NODE_TYPE.STRAIGHT then
      self:emit(Vm.bytecode(Vm.BYTECODE_KIND.STRAIGHT), node.span)
   elseif node.type == Ast.NODE_TYPE.RPUSH then
      self:emit(Vm.bytecode(Vm.BYTECODE_KIND.RPUSH), node.span)
   elseif node.type == Ast.NODE_TYPE.RPOP then
      self:emit(Vm.bytecode(Vm.BYTECODE_KIND.RPOP), node.span)
   elseif node.type == Ast.NODE_TYPE.RESET then
      self:emit(Vm.bytecode(Vm.BYTECODE_KIND.RESET), node.span)
   elseif node.type == Ast.NODE_TYPE.SEQUENCE then
      -- Simply compile each statement in order
      ---@cast node syntrax.ast.Sequence
      for _, stmt in ipairs(node.statements) do
         self:compile_node(stmt)
      end
   elseif node.type == Ast.NODE_TYPE.REPETITION then
      ---@cast node syntrax.ast.Repetition
      self:compile_repetition(node)
   else
      error("Unknown node type: " .. tostring(node.type))
   end
end

---@param node syntrax.ast.Repetition
function Compiler:compile_repetition(node)
   -- For "body rep N", we generate:
   -- MOV counter, N
   -- loop_start:
   -- <body>
   -- counter = counter - 1
   -- JNZ counter, offset_to_loop_start

   local counter_reg = self:allocate_register()

   -- Initialize counter
   self:emit(Vm.bytecode(Vm.BYTECODE_KIND.MOV, Vm.register(counter_reg), Vm.value(Vm.VALUE_TYPE.NUMBER, node.count)))

   -- Remember where the loop starts
   local loop_start = self:current_position()

   -- Compile the body
   self:compile_node(node.body)

   -- Decrement counter
   self:emit(
      Vm.bytecode(
         Vm.BYTECODE_KIND.MATH,
         Vm.register(counter_reg),
         Vm.register(counter_reg),
         Vm.value(Vm.VALUE_TYPE.NUMBER, 1),
         Vm.math_op(Vm.MATH_OP.SUB)
      )
   )

   -- Jump back if counter is not zero
   local current_pos = self:current_position()
   local jump_offset = loop_start - current_pos

   self:emit(Vm.bytecode(Vm.BYTECODE_KIND.JNZ, Vm.register(counter_reg), Vm.value(Vm.VALUE_TYPE.NUMBER, jump_offset)))
end

---@param ast syntrax.ast.Node
---@return syntrax.vm.Bytecode[]
function mod.compile(ast)
   local compiler = mod.new()
   compiler:compile_node(ast)
   return compiler.bytecode
end

-- Pretty printing support for debugging
function mod.format_bytecode_listing(bytecode)
   local lines = {}
   local labels = {}

   -- First pass: identify jump targets and create labels
   for i, bc in ipairs(bytecode) do
      if bc.kind == Vm.BYTECODE_KIND.JNZ then
         local offset = bc.arguments[2]
         if offset.kind == Vm.OPERAND_KIND.VALUE then
            local target = i + offset.argument
            if target >= 1 and target <= #bytecode then
               labels[target] = labels[target] or string.format("L%d", target)
            end
         end
      end
   end

   -- Second pass: format bytecode with labels
   for i, bc in ipairs(bytecode) do
      table.insert(lines, string.format("%3d: %s", i, Vm.format_bytecode(bc, i, labels)))
   end

   return table.concat(lines, "\n")
end

return mod
