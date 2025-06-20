local NetworkShape = require("scripts.network-shape")

local mod = {}

--[[
Definition of a connection point on a heat-using entity.

Each entry describes a single heat connection.

@field position fa.Point -- absolute tile position of the connection (useful for neighbor detection)
@field direction defines.direction? -- orientation of the connection (0=north, 4=east, 8=south, 12=west); nil for heat pipes
@field entity LuaEntity? -- entity to which this connection belongs (optional, for context)
@field raw table -- raw connection table from prototype, for debugging
]]
---@class fa.Heat.ConnectionPoint
---@field position fa.Point
---@field direction defines.direction?
---@field entity LuaEntity?
---@field raw table

---Rotates a relative position offset by a given entity direction.
---@param dx number # X offset, relative to entity origin (north-facing).
---@param dy number # Y offset, relative to entity origin (north-facing).
---@param direction defines.direction # Entity direction (0–15, one of defines.direction), where 0 is north and each increment is 22.5 degrees clockwise.
---@return number rx # Rotated X offset (relative to entity position in world).
---@return number ry # Rotated Y offset (relative to entity position in world).
local function rotate_offset(dx, dy, direction)
   local angle = (direction / 16) * 2 * math.pi
   local cos_theta = math.cos(angle)
   local sin_theta = math.sin(angle)
   return dx * cos_theta - dy * sin_theta, dx * sin_theta + dy * cos_theta
end

---Returns a list of HeatConnectionPoint for the entity's heat connections.
---@param ent LuaEntity
---@return fa.Heat.ConnectionPoint[]
function mod.get_connection_points(ent)
   local res = {}
   local proto = ent and ent.valid and ent.prototype
   if not (proto and proto.heat_buffer_prototype and proto.heat_buffer_prototype.connections) then return res end

   -- Detect if this is a heat pipe by entity type.
   local is_heat_pipe = proto.type == "heat-pipe"

   if is_heat_pipe then
      local pos = ent.position
      table.insert(res, {
         position = { x = pos.x, y = pos.y },
         direction = nil,
         entity = ent,
         raw = proto.heat_buffer_prototype.connections[1],
      })
   else
      local dir = ent.direction or 0
      for _, conn in ipairs(proto.heat_buffer_prototype.connections) do
         local pos = ent.position
         local rel = conn.position or { 0, 0 }
         local dx, dy = rel[1], rel[2]
         local rx, ry = rotate_offset(dx, dy, dir)
         table.insert(res, {
            position = { x = pos.x + rx, y = pos.y + ry },
            direction = (conn.direction + dir) % (defines.direction.south * 2),
            entity = ent,
            raw = conn,
         })
      end
   end

   return res
end

local cardinal_dirs = {
   defines.direction.north,
   defines.direction.east,
   defines.direction.south,
   defines.direction.west,
}

local direction_deltas = {
   [defines.direction.north] = { dx = 0, dy = -1, opp = defines.direction.south },
   [defines.direction.east] = { dx = 1, dy = 0, opp = defines.direction.west },
   [defines.direction.south] = { dx = 0, dy = 1, opp = defines.direction.north },
   [defines.direction.west] = { dx = -1, dy = 0, opp = defines.direction.east },
}
mod.direction_deltas = direction_deltas

---Returns a list of valid neighbor connections for a given entity and one of its heat connection points.
---If pipes_only is true, only return pipe connections.
---@param ent LuaEntity
---@param cp fa.Heat.ConnectionPoint
---@param pipes_only boolean?  -- optional flag
---@return {entity: LuaEntity, connection_point: fa.Heat.ConnectionPoint}[]
function mod.get_connected_neighbors(ent, cp, pipes_only)
   local surface = ent and ent.valid and ent.surface
   if not (surface and cp and cp.position) then return {} end
   local results = {}

   if cp.direction then
      local delta = direction_deltas[cp.direction]
      if not delta then return results end
      local nx, ny = cp.position.x + delta.dx, cp.position.y + delta.dy

      local neighbors = surface.find_entities_filtered({
         position = { nx, ny },
         force = ent.force,
      })
      for _, neighbor in ipairs(neighbors) do
         if neighbor ~= ent then
            if not pipes_only or neighbor.prototype.type == "heat-pipe" then
               for _, ncp in ipairs(mod.get_connection_points(neighbor)) do
                  if ncp.position.x == nx and ncp.position.y == ny then
                     if not ncp.direction or ncp.direction == delta.opp then
                        table.insert(results, { entity = neighbor, connection_point = ncp })
                     end
                  end
               end
            end
         end
      end
   else
      for _, dir in ipairs(cardinal_dirs) do
         local delta = direction_deltas[dir]
         local nx, ny = cp.position.x + delta.dx, cp.position.y + delta.dy
         local neighbors = surface.find_entities_filtered({
            position = { nx, ny },
            force = ent.force,
         })
         for _, neighbor in ipairs(neighbors) do
            if neighbor ~= ent then
               if not pipes_only or neighbor.prototype.type == "heat-pipe" then
                  for _, ncp in ipairs(mod.get_connection_points(neighbor)) do
                     if ncp.position.x == nx and ncp.position.y == ny then
                        if not ncp.direction or ncp.direction == delta.opp then
                           table.insert(results, { entity = neighbor, connection_point = ncp })
                        end
                     end
                  end
               end
            end
         end
      end
   end
   return results
end

---Given a heat pipe entity, determines its shape and orientation (if applicable).
---Returns { shape = "straight"/"corner"/"end"/"T"/"cross"/"alone", direction = defines.direction }
---@param ent LuaEntity
---@return { shape: string, direction: defines.direction }|nil
function mod.get_pipe_shape(ent)
   local proto = ent and ent.valid and ent.prototype
   if not (proto and proto.type == "heat-pipe") then
      return nil -- Only heat pipes have a shape
   end

   local cps = mod.get_connection_points(ent)
   if #cps == 0 then return nil end
   local cp = cps[1]

   -- Get all neighboring pipes in all four directions at once
   local neighbors = mod.get_connected_neighbors(ent, cp, true) -- pipes_only = true

   local connections = {}
   for dir, delta in pairs(direction_deltas) do
      local nx, ny = cp.position.x + delta.dx, cp.position.y + delta.dy
      for _, n in ipairs(neighbors) do
         if n.connection_point.position.x == nx and n.connection_point.position.y == ny then
            connections[dir] = true
            break
         end
      end
   end

   return NetworkShape.get_shape_from_directions(connections)
end

---Returns the total number of valid heat connections for the given entity.
---Counts all entities connected at any heat connection point (pipes and non-pipes).
---@param ent LuaEntity
---@return integer
function mod.get_total_heat_connections(ent)
   local total = 0
   local cps = mod.get_connection_points(ent)
   for _, cp in ipairs(cps) do
      local neighbors = mod.get_connected_neighbors(ent, cp)
      total = total + #neighbors
   end
   return total
end

return mod
