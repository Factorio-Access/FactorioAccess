--- Test to verify pipe walkability collision mask changes

local TestRegistry = require("scripts.test-registry")
local describe = TestRegistry.describe
local it = TestRegistry.it

describe("Pipe Walkability Collision Masks", function()
   it("should have correct collision masks for walkable pipes", function(ctx)
      ctx:init(function()
         local output_lines = {}

         -- Check character mask
         local char_proto = prototypes.entity["character"]
         local char_has_player = char_proto.collision_mask.layers["player"]
         local char_has_is_object = char_proto.collision_mask.layers["is_object"]

         table.insert(output_lines, "=== VERIFICATION OF PIPE WALKABILITY ===")
         table.insert(output_lines, "")
         table.insert(output_lines, "Character collision mask:")
         local char_layers = {}
         for l, _ in pairs(char_proto.collision_mask.layers) do
            table.insert(char_layers, l)
         end
         table.sort(char_layers)
         table.insert(output_lines, "  [" .. table.concat(char_layers, ", ") .. "]")
         table.insert(output_lines, "  has player: " .. tostring(char_has_player))
         table.insert(output_lines, "  has is_object: " .. tostring(char_has_is_object))

         -- Check pipe mask
         local pipe_proto = prototypes.entity["pipe"]
         local pipe_has_player = pipe_proto.collision_mask.layers["player"]
         local pipe_has_is_object = pipe_proto.collision_mask.layers["is_object"]

         table.insert(output_lines, "")
         table.insert(output_lines, "Pipe collision mask:")
         local pipe_layers = {}
         for l, _ in pairs(pipe_proto.collision_mask.layers) do
            table.insert(pipe_layers, l)
         end
         table.sort(pipe_layers)
         table.insert(output_lines, "  [" .. table.concat(pipe_layers, ", ") .. "]")
         table.insert(output_lines, "  has player: " .. tostring(pipe_has_player))
         table.insert(output_lines, "  has is_object: " .. tostring(pipe_has_is_object))

         -- Check enemy mask
         local enemy_proto = prototypes.entity["small-biter"]
         local enemy_has_player = enemy_proto.collision_mask.layers["player"]
         local enemy_has_is_object = enemy_proto.collision_mask.layers["is_object"]

         table.insert(output_lines, "")
         table.insert(output_lines, "Enemy (small-biter) collision mask:")
         local enemy_layers = {}
         for l, _ in pairs(enemy_proto.collision_mask.layers) do
            table.insert(enemy_layers, l)
         end
         table.sort(enemy_layers)
         table.insert(output_lines, "  [" .. table.concat(enemy_layers, ", ") .. "]")
         table.insert(output_lines, "  has player: " .. tostring(enemy_has_player))
         table.insert(output_lines, "  has is_object: " .. tostring(enemy_has_is_object))

         -- Calculate collisions
         table.insert(output_lines, "")
         table.insert(output_lines, "=== COLLISION RESULTS ===")

         -- Character vs Pipe
         local char_pipe_collide = false
         for l, _ in pairs(char_proto.collision_mask.layers) do
            if pipe_proto.collision_mask.layers[l] then
               char_pipe_collide = true
               break
            end
         end
         table.insert(output_lines, "Character vs Pipe collides: " .. tostring(char_pipe_collide))

         -- Enemy vs Pipe
         local enemy_pipe_collide = false
         local shared_layer = nil
         for l, _ in pairs(enemy_proto.collision_mask.layers) do
            if pipe_proto.collision_mask.layers[l] then
               enemy_pipe_collide = true
               shared_layer = l
               break
            end
         end
         table.insert(
            output_lines,
            "Enemy vs Pipe collides: "
               .. tostring(enemy_pipe_collide)
               .. (shared_layer and " (via " .. shared_layer .. ")" or "")
         )

         -- Character vs Enemy
         local char_enemy_collide = false
         local char_enemy_shared = nil
         for l, _ in pairs(char_proto.collision_mask.layers) do
            if enemy_proto.collision_mask.layers[l] then
               char_enemy_collide = true
               char_enemy_shared = l
               break
            end
         end
         table.insert(
            output_lines,
            "Character vs Enemy collides: "
               .. tostring(char_enemy_collide)
               .. (char_enemy_shared and " (via " .. char_enemy_shared .. ")" or "")
         )

         -- Write output
         helpers.write_file("pipe-walkability-verification.txt", table.concat(output_lines, "\n"), false)
         print("Verification written to script-output/pipe-walkability-verification.txt")

         -- Assertions
         ctx:assert(char_has_player, "Character should have player layer")
         ctx:assert(not char_has_is_object, "Character should NOT have is_object layer")
         ctx:assert(not pipe_has_player, "Pipe should NOT have player layer")
         ctx:assert(pipe_has_is_object, "Pipe should have is_object layer")
         ctx:assert(enemy_has_player, "Enemy should have player layer")
         ctx:assert(enemy_has_is_object, "Enemy should have is_object layer")
         ctx:assert(not char_pipe_collide, "Character should NOT collide with pipe")
         ctx:assert(enemy_pipe_collide, "Enemy SHOULD collide with pipe")
         ctx:assert(char_enemy_collide, "Character SHOULD collide with enemy")
      end)
   end)
end)
