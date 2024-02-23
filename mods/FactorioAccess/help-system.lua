--Here is the help and tutorial menu

--The tutorial strings are fetched according to locale, with the main set of tutorial strings being im English ("en").
--Other locales are expected to have the same arrangement of tutorial steps.
function load_tutorial(pindex)
   local tutorial = players[pindex].tutorial 
   local p = game.get_player(pindex)
   tutorial = {}
   
   --Load tutorial header and detail strings
   tutorial.step_headers =  {} --2D array of localised strings
   tutorial.step_details =  {} --2D array of localised strings
   local CHAPTER_1_LENGTH = 28 --Lengths are constants depending on how we write the "en" strings.
   local CHAPTER_2_LENGTH = 22
   local CHAPTER_3_LENGTH = 08
   local CHAPTER_4_LENGTH = 15
   local CHAPTER_5_LENGTH = 19
   local CHAPTER_6_LENGTH = 13
   local CHAPTER_7_LENGTH = 13
   local CHAPTER_8_LENGTH = 19
   local CHAPTER_9_LENGTH = 22

   tutorial.chapter_lengths = {CHAPTER_1_LENGTH, CHAPTER_2_LENGTH, CHAPTER_3_LENGTH, CHAPTER_4_LENGTH, CHAPTER_5_LENGTH, CHAPTER_6_LENGTH, CHAPTER_7_LENGTH, CHAPTER_8_LENGTH, CHAPTER_9_LENGTH}
   
   local str_count = 0
   local err_count = 0
   for i = 1, #tutorial.chapter_lengths, 1 do --for every chapter
      local chapter_length = tutorial.chapter_lengths[i] 
      tutorial.step_headers[i] = {}
      tutorial.step_details[i] = {}
      
      for j = 1, chapter_length, 1 do --for every step
         local header_str_name = "tutorial.tutorial-chapter-" .. i .. "-step-" .. j .. "-header"
         local header_localised_str = {header_str_name}
         if header_localised_str ~= nil then
            table.insert(tutorial.step_headers[i], j, header_localised_str) --for each step
         else
            err_count = err_count + 1
            --p.print("error in preparing tutorial header string " .. i .. "-" .. j,{volume_modifier = 0})
         end
         
         local detail_str_name = "tutorial.tutorial-chapter-" .. i .. "-step-" .. j .. "-detail"
         local detail_localised_str = {detail_str_name}
         if detail_localised_str ~= nil then
            table.insert(tutorial.step_details[i], j, detail_localised_str) --for each step
         else
            err_count = err_count + 1
            --p.print("error in preparing tutorial detail string " .. i .. "-" .. j,{volume_modifier = 0})
         end
         
         str_count = str_count + 1
      end
   end
   if err_count > 0 then
      p.print(err_count .. " errors while preparing ".. str_count .. " tutorial strings",{volume_modifier = 0})
   end
   
   --Load Chapter 0 strings
   tutorial.chapter_0_messages = { {"tutorial.tutorial-chapter-0-message-1"}, {"tutorial.tutorial-chapter-0-message-2"}, 
                                   {"tutorial.tutorial-chapter-0-message-3"}, {"tutorial.tutorial-chapter-0-message-4"} }
   
   --Load other tutorial strings
   --...
   
   --Load other tutorial variables
   tutorial.chapter_index = 0
   tutorial.step_index = 1
   tutorial.reading_the_header = false
   tutorial.clicked = false
   tutorial.rocket_fuel_provided = false

   --Done
   players[pindex].tutorial = tutorial
end

function tutorial_menu_open(pindex)--Note: In the current version we do not open/close a menu, we just progress up and down the steps.
   if players[pindex].vanilla_mode then
      return 
   end
   
   --Load the tutorial content
   if players[pindex].tutorial == nil or players[pindex].tutorial == {} then
      load_tutorial(pindex)
   end
   
   --Set the player menu tracker to this menu
   players[pindex].menu = "tutorial_menu"
   players[pindex].in_menu = true 
     
   --Play sound
   game.get_player(pindex).play_sound{path = "Open-Inventory-Sound"}  
   
   --Load menu 
   tutorial_menu(pindex, players[pindex].tutorial.reading_the_header, players[pindex].tutorial.clicked)
end

function tutorial_menu_close(pindex)
   --Set the player menu tracker to none
   players[pindex].menu = "none"
   players[pindex].in_menu = false
   
   --play sound
   game.get_player(pindex).play_sound{path="Close-Inventory-Sound"}

end

function tutorial_menu_current(pindex)
   local tutorial = players[pindex].tutorial
   if tutorial == nil then
      load_tutorial(pindex)
      tutorial_menu(pindex, players[pindex].tutorial.reading_the_header, players[pindex].tutorial.clicked) 
      return 
   end
   
   players[pindex].tutorial = tutorial
   tutorial_menu(pindex, players[pindex].tutorial.reading_the_header, players[pindex].tutorial.clicked) 
end 

function tutorial_menu_toggle_header_detail(pindex)
   local tutorial = players[pindex].tutorial
   if tutorial == nil then
      load_tutorial(pindex)
      tutorial_menu(pindex, players[pindex].tutorial.reading_the_header, players[pindex].tutorial.clicked) 
      return 
   end
   tutorial.reading_the_header = not tutorial.reading_the_header
   players[pindex].tutorial = tutorial
   tutorial_menu(pindex, players[pindex].tutorial.reading_the_header, players[pindex].tutorial.clicked) 
end 

function tutorial_menu_read_other_once(pindex)
   local tutorial = players[pindex].tutorial
   if tutorial == nil then
      load_tutorial(pindex)
   end
   tutorial_menu(pindex, (not players[pindex].tutorial.reading_the_header), players[pindex].tutorial.clicked) 
end 

function tutorial_menu_back(pindex)
	local tutorial = players[pindex].tutorial
   if tutorial == nil then
      load_tutorial(pindex)
      tutorial_menu(pindex, players[pindex].tutorial.reading_the_header, players[pindex].tutorial.clicked)
      return 
   end
	tutorial.step_index = tutorial.step_index - 1
	
   --End of the previous chapter
	if tutorial.step_index == 0 then
		tutorial.chapter_index = tutorial.chapter_index - 1
		if tutorial.chapter_index == -1 then
         --Top of the entire list
			tutorial.chapter_index = 0
			tutorial.step_index = 1
			game.get_player(pindex).play_sound{path = "inventory-edge"}
		elseif tutorial.chapter_index == 0 then 
         --End of chapter 0
			tutorial.step_index = #tutorial.chapter_0_messages
		else
         --End of another chapter
			tutorial.step_index = tutorial.chapter_lengths[tutorial.chapter_index]
		end
	end
   
   --Play sound
   game.get_player(pindex).play_sound{path = "Inventory-Move"}
   
   --Load menu 
   players[pindex].tutorial = tutorial
   tutorial_menu(pindex, players[pindex].tutorial.reading_the_header, players[pindex].tutorial.clicked)
end

function tutorial_menu_chapter_back(pindex)
	local tutorial = players[pindex].tutorial
   if tutorial == nil then
      load_tutorial(pindex)
      tutorial_menu(pindex, players[pindex].tutorial.reading_the_header, players[pindex].tutorial.clicked)
      return 
   end
	tutorial.step_index = 1
   tutorial.chapter_index = tutorial.chapter_index - 1
	
   --Check index
	if tutorial.chapter_index < 0 then
		tutorial.chapter_index = 0
      game.get_player(pindex).play_sound{path = "inventory-edge"}
	end
   
   --Play sound
   game.get_player(pindex).play_sound{path = "Inventory-Move"}
   
   --Load menu 
   players[pindex].tutorial = tutorial
   tutorial_menu(pindex, players[pindex].tutorial.reading_the_header, players[pindex].tutorial.clicked)
end

function tutorial_menu_next(pindex)
   local tutorial = players[pindex].tutorial
   if tutorial == nil then
      load_tutorial(pindex)
      tutorial_menu(pindex, players[pindex].tutorial.reading_the_header, players[pindex].tutorial.clicked)
      return 
   end
	local tutorial = players[pindex].tutorial
	tutorial.step_index = tutorial.step_index + 1
   
   --End of Chapter 0
   if tutorial.chapter_index == 0 and tutorial.step_index <= #tutorial.chapter_0_messages then
      --(do nothing)
   elseif tutorial.chapter_index == 0 and tutorial.step_index > #tutorial.chapter_0_messages then
      tutorial.chapter_index = 1
      tutorial.step_index = 1
	
   --End of another chapter
	elseif tutorial.step_index > tutorial.chapter_lengths[tutorial.chapter_index] then
		tutorial.chapter_index = tutorial.chapter_index + 1
		if tutorial.chapter_index > #tutorial.chapter_lengths or tutorial.chapter_lengths[tutorial.chapter_index] == 0 then
         --End of the entire list
			tutorial.chapter_index = tutorial.chapter_index - 1
			tutorial.step_index = tutorial.step_index - 1
         game.get_player(pindex).play_sound{path = "inventory-edge"}
		else
         --start of the next chapter
			tutorial.step_index = 1
		end
	end
   
   --Play sound
   game.get_player(pindex).play_sound{path = "Inventory-Move"}
   
   --Load menu 
   players[pindex].tutorial = tutorial
   tutorial_menu(pindex, players[pindex].tutorial.reading_the_header, players[pindex].tutorial.clicked)
end

function tutorial_menu_chapter_next(pindex)
	local tutorial = players[pindex].tutorial
   if tutorial == nil then
      load_tutorial(pindex)
      tutorial_menu(pindex, players[pindex].tutorial.reading_the_header, players[pindex].tutorial.clicked)
      return 
   end
	tutorial.step_index = 1
   tutorial.chapter_index = tutorial.chapter_index + 1
	
   --Check index
	if tutorial.chapter_index > #tutorial.chapter_lengths or tutorial.chapter_lengths[tutorial.chapter_index] == 0 then
		tutorial.chapter_index = tutorial.chapter_index - 1
      game.get_player(pindex).play_sound{path = "inventory-edge"}
	end
   
   --Play sound
   game.get_player(pindex).play_sound{path = "Inventory-Move"}
   
   --Load menu 
   players[pindex].tutorial = tutorial
   tutorial_menu(pindex, players[pindex].tutorial.reading_the_header, players[pindex].tutorial.clicked)
end

function tutorial_menu_read_out_header(pindex)
	local tutorial = players[pindex].tutorial
	local i = tutorial.chapter_index
	local j = tutorial.step_index
	local str = tutorial.step_headers[i][j]
	printout(str,pindex)
   game.get_player(pindex).print("Tutorial message summary, chapter " .. players[pindex].tutorial.chapter_index .. " , step " .. players[pindex].tutorial.step_index .. ": ",{volume_modifier=0})--
   game.get_player(pindex).print(str,{volume_modifier=0})--
end

function tutorial_menu_read_out_detail(pindex)
	local tutorial = players[pindex].tutorial
	local i = tutorial.chapter_index
	local j = tutorial.step_index
	local str = tutorial.step_details[i][j]
   local str_h = tutorial.step_headers[i][j]
	printout(str,pindex)
   game.get_player(pindex).print("Tutorial message, chapter " .. players[pindex].tutorial.chapter_index .. " , step " .. players[pindex].tutorial.step_index .. ": ",{volume_modifier=0})--
   game.get_player(pindex).print(str_h,{volume_modifier=0})--
   game.get_player(pindex).print(str,{volume_modifier=0})--
end

--For most steps this reads the already-loaded strings
function tutorial_menu(pindex, reading_the_header, clicked)
	local tutorial = players[pindex].tutorial
	local chap = tutorial.chapter_index
	local step = tutorial.step_index
   local p = game.get_player(pindex)
	if chap == 0 and step == 1 then
		--Read out chapter 0 start message
      printout(tutorial.chapter_0_messages[step],pindex)
      game.get_player(pindex).print("Tutorial start message " .. step .. ":",{volume_modifier=0})--
      game.get_player(pindex).print(tutorial.chapter_0_messages[step],{volume_modifier=0})
      
      --Give rocket fuel
      if players[pindex].tutorial.rocket_fuel_provided ~= true then
         p.insert{name = "rocket-fuel", count = 8}
      end 
      
      --Reload tutorial
      game.get_player(pindex).play_sound{path = "Open-Inventory-Sound"}  
      load_tutorial(pindex)
      players[pindex].tutorial.rocket_fuel_provided = true
      
   elseif chap == 0 and step > 1 then
      --Read out chapter 0 start message
      printout(tutorial.chapter_0_messages[step],pindex)
      game.get_player(pindex).print("Tutorial start message " .. step .. ":",{volume_modifier=0})--
      game.get_player(pindex).print(tutorial.chapter_0_messages[step],{volume_modifier=0})
      
	elseif chap == -1 and step == -1 then --Example
		--Do a specific action for this step, e.g. provide an item or run a check
      if clicked == false then
         --Read this step's header/detail
         if reading_the_header == true then
            tutorial_menu_read_out_header(pindex)--Check step header, e.g. "multiple furnaces check"
         else
            tutorial_menu_read_out_detail(pindex)--Check step detail, e.g. "click here to run a check for this step" 
         end
      else --if clicked == true then
         --Run the check and print the appropriate tutorial check result string
         local ents = p.surface.find_entities_filtered{position = p.position, radius = 100, name = "stone-furnace"}
         if #ents > 1 then --(more checks here)
            --printout(tutorial.check_passed,pindex) --e.g. "Check passed"
         elseif #ents == 1 then --(more checks here)
            --printout(tutorial.check_message_just_1_ent,pindex) --e.g. "Check issue, only 1 ent found"
         else
            --printout(tutorial.check_failed,pindex) --e.g. "Check failed"
         end
      end      
	elseif chap > 0 and step > 0 then
		--All other steps: Just read the header/detail
		if reading_the_header == true then
			tutorial_menu_read_out_header(pindex)
		else
			tutorial_menu_read_out_detail(pindex)
		end
	else
		printout({"tutorial.tutorial-error"},pindex)--**
	end
end
