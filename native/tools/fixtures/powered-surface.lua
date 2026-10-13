-- A surface where every electric entity has power. args: name (default "fa-dev"), radius in chunks (default 4). Returns its index.
local name = args.name or "fa-dev"
local surface = game.get_surface(name) or game.create_surface(name)
surface.request_to_generate_chunks({ x = 0, y = 0 }, args.radius or 4)
surface.force_generate_chunk_requests()
-- The global network reaches every entity on the surface; the interface feeds it.
surface.create_global_electric_network()
if surface.count_entities_filtered({ name = "electric-energy-interface" }) == 0 then
   surface.create_entity({ name = "electric-energy-interface", position = { x = -20, y = -20 }, force = "player" })
end
return surface.index
