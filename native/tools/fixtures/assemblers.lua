-- A grid of crafting machines, announced to the mod as built. args: count (default 100), recipe (default "iron-gear-wheel"), machine (default "assembling-machine-2"), surface (default the player's), x, y (the first machine, default 0, 0), columns (default 50). Returns how many were placed.
local surface = args.surface and assert(game.get_surface(args.surface), "no surface " .. args.surface)
   or game.get_player(1).surface
local machine = args.machine or "assembling-machine-2"
local size = math.ceil(prototypes.entity[machine].tile_width)
local columns = args.columns or 50
local x0, y0 = args.x or 0, args.y or 0
local placed = 0
for i = 0, (args.count or 100) - 1 do
   local entity = surface.create_entity({
      name = machine,
      position = { x = x0 + (i % columns) * size + size / 2, y = y0 + math.floor(i / columns) * size + size / 2 },
      force = "player",
      recipe = args.recipe or "iron-gear-wheel",
      raise_built = true,
   })
   if entity then placed = placed + 1 end
end
return placed
