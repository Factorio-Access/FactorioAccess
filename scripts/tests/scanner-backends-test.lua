local TestRegistry = require("scripts.test-registry")
local describe, it = TestRegistry.describe, TestRegistry.it

local FaInfo = require("scripts.fa-info")
local TileBodiesBackend = require("scripts.scanner.backends.tile-bodies")
local TreeBackend = require("scripts.scanner.backends.trees")

describe("Scanner backends", function()
   it("reads a water patch as one entry with its size", function(ctx)
      ctx:init(function()
         local player = assert(game.get_player(1))
         local surface = player.surface
         -- Chunk 20, 20, away from anything else the tests build.
         local chunk_area = { left_top = { x = 640, y = 640 }, right_bottom = { x = 672, y = 672 } }
         surface.request_to_generate_chunks({ 656, 656 }, 0)
         surface.force_generate_chunk_requests()

         local tiles = {}
         for x = 640, 671 do
            for y = 640, 671 do
               local water = x >= 650 and x < 655 and y >= 650 and y < 653
               table.insert(tiles, { name = water and "water" or "grass-1", position = { x, y } })
            end
         end
         surface.set_tiles(tiles)

         local backend = TileBodiesBackend.TileBodiesBackend.new(surface)
         backend:on_new_chunk({ x = 20, y = 20, area = chunk_area })

         local entries = {}
         backend:dump_entries_to_callback(player, function(e)
            table.insert(entries, e)
         end)

         ctx:assert_equals(1, #entries, "one water body")
         ctx:assert_equals("water", entries[1].subcategory)
         ctx:assert_table_equals(
            { "fa.scanner-tile-body", { "tile-name.water" }, 5, 3 },
            backend:readout_entry(player, entries[1])
         )

         local summary = FaInfo.area_scan_summary_info(1, { x = 650, y = 650 }, { x = 660, y = 660 })
         ctx:assert(serpent.line(summary):find("tile-name.water", 1, true) ~= nil, serpent.line(summary))
      end)
   end)

   it("follows a lake split by landfill, rejoined, and across chunk borders", function(ctx)
      ctx:init(function()
         local player = assert(game.get_player(1))
         local surface = player.surface
         -- Chunks 22 and 23 by 20, away from anything else the tests build.
         surface.request_to_generate_chunks({ 736, 656 }, 1)
         surface.force_generate_chunk_requests()

         -- A lake 12 by 3 from x 698 to 709, across the border at x 704, ending on the chunk's last row 671.
         local tiles = {}
         for x = 704 - 32, 704 + 63 do
            for y = 640, 703 do
               local water = x >= 698 and x < 710 and y >= 669 and y < 672
               table.insert(tiles, { name = water and "water" or "grass-1", position = { x, y } })
            end
         end
         surface.set_tiles(tiles)

         local backend = TileBodiesBackend.TileBodiesBackend.new(surface)
         for cx = 21, 23 do
            for cy = 20, 21 do
               backend:on_new_chunk({
                  x = cx,
                  y = cy,
                  area = {
                     left_top = { x = cx * 32, y = cy * 32 },
                     right_bottom = { x = cx * 32 + 32, y = cy * 32 + 32 },
                  },
               })
            end
         end

         local function readouts()
            local out = {}
            backend:dump_entries_to_callback(player, function(e)
               table.insert(out, serpent.line(backend:readout_entry(player, e)))
            end)
            table.sort(out)
            return out
         end

         ctx:assert_table_equals({ serpent.line({ "fa.scanner-tile-body", { "tile-name.water" }, 12, 3 }) }, readouts())

         -- Landfill a column: two lakes.
         local fill = {}
         for y = 669, 671 do
            table.insert(fill, { name = "landfill", position = { 703, y } })
         end
         surface.set_tiles(fill)
         backend:on_tiles_changed({ { x = 703, y = 669 } })
         ctx:assert_table_equals({
            serpent.line({ "fa.scanner-tile-body", { "tile-name.water" }, 5, 3 }),
            serpent.line({ "fa.scanner-tile-body", { "tile-name.water" }, 6, 3 }),
         }, readouts())

         -- Mining one landfill tile brings the water back and joins them; an unannounced change is caught by the
         -- rescan's tile count.
         surface.set_tiles({ { name = "water", position = { 703, 670 } } })
         backend:on_chunk_rescanned({
            x = 21,
            y = 20,
            area = { left_top = { x = 672, y = 640 }, right_bottom = { x = 704, y = 672 } },
         })
         ctx:assert_table_equals({ serpent.line({ "fa.scanner-tile-body", { "tile-name.water" }, 12, 3 }) }, readouts())
      end)
   end)

   it("drops felled trees on the next scan of their chunk", function(ctx)
      ctx:init(function()
         local player = assert(game.get_player(1))
         local surface = player.surface
         local chunk =
            { x = 25, y = 25, area = { left_top = { x = 800, y = 800 }, right_bottom = { x = 832, y = 832 } } }
         surface.request_to_generate_chunks({ 816, 816 }, 0)
         surface.force_generate_chunk_requests()
         for _, e in pairs(surface.find_entities_filtered({ area = chunk.area, type = { "tree", "plant" } })) do
            e.destroy()
         end
         local a = assert(surface.create_entity({ name = "tree-01", position = { 802.5, 802.5 } }))
         local b = assert(surface.create_entity({ name = "tree-01", position = { 828.5, 828.5 } }))

         local backend = TreeBackend.TreeBackend.new(surface)
         backend:on_new_entity(a)
         backend:on_new_entity(b)
         backend:on_chunk_scanned(chunk)
         local function count()
            local n = 0
            backend:dump_entries_to_callback(player, function()
               n = n + 1
            end)
            return n
         end
         ctx:assert_equals(2, count(), "two trees too far apart to be one forest")

         b.destroy()
         backend:on_chunk_scanned(chunk)
         ctx:assert_equals(1, #backend.clusterer:get_groups(), "the felled tree's square is gone")
         a.destroy()
      end)
   end)

   it("reads a lone tree as that tree", function(ctx)
      ctx:init(function()
         local player = assert(game.get_player(1))
         local surface = player.surface
         local tree = assert(surface.create_entity({ name = "tree-01", position = { 700.5, 640.5 } }))

         local backend = TreeBackend.TreeBackend.new(surface)
         backend:on_new_entity(tree)
         local entries = {}
         backend:dump_entries_to_callback(player, function(e)
            table.insert(entries, e)
         end)

         ctx:assert_equals(1, #entries, "one tree")
         ctx:assert_equals(tree, entries[1].backend_data.zoom_ent)
         ctx:assert(backend:validate_entry(player, entries[1]), "the tree is still there")
         tree.destroy()
      end)
   end)
end)
