-- A space platform built from the starter pack, orbiting a planet. args: name (default "Testship"), planet (default "nauvis"), board (default true: the player boards it). Returns the platform's index.
local force = game.forces.player
force.unlock_space_platforms()
local platform = assert(force.create_space_platform({
   name = args.name or "Testship",
   planet = args.planet or "nauvis",
   starter_pack = "space-platform-starter-pack",
}))
platform.apply_starter_pack()
if args.board ~= false then game.get_player(1).enter_space_platform(platform) end
return platform.index
