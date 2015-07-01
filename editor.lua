-- GunFu Deadlands
-- Copyright 2009-2011 Christiaan Janssen, September 2009-October 2011
--
-- This file is part of GunFu Deadlands.
--
--     GunFu Deadlands is free software: you can redistribute it and/or modify
--     it under the terms of the GNU General Public License as published by
--     the Free Software Foundation, either version 3 of the License, or
--     (at your option) any later version.
--
--     GunFu Deadlands is distributed in the hope that it will be useful,
--     but WITHOUT ANY WARRANTY; without even the implied warranty of
--     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--     GNU General Public License for more details.
--
--     You should have received a copy of the GNU General Public License
--     along with GunFu Deadlands.  If not, see <http://www.gnu.org/licenses/>.

Editor = {}

function Editor.load()
	Editor.enabled = false

	Editor.versionstring="GunFuDeadlandsV1.00"

	Editor.defaultmode = 4

	Editor.former_mode = Editor.mode
	Editor.current_element_index = 2
	Editor.num_elements = table.getn(Entities.entitystrings)
	Editor.current_element = Entities.new_element( Editor.current_element_index )
	Editor.currentfilename=""
	Editor.deletefilename = ""
	Editor.slots={}
	Editor.listingfilename="listing.gfd"
	Editor.listingtable={}
	Editor.listingoffset = 0
	Editor.listinglength = 10
	Editor.listingbox={20,60}
	Editor.fileerror_timer = 0
	Editor.resetting=false
	Editor.showprogress = false
end

function Editor.init()
	Editor.enabled = true
	Editor.mode = Editor.defaultmode
	Editor.dragging = false
	Editor.dragging_from = {0,0}
	Editor.shiftpressed = false
	Editor.mouseposdiff = {0,0}

	-- clear level
	Level.init()

	Player.pos = {320,240}
	Player.starting_pos = { 320, 240 }
	Level.reset_player()

	Editor.firststart = false
	Editor.wiping = false
	Editor.resetting=false
	Editor.showprogress = false

	Editor.loadslotfile( 11 )
	Editor.fileerror_timer = 0

	Editor.reset_undo()
end

function Editor.draw()

	if Editor.mode ==  6 then
		Editor.showprogress = true
	else
		Editor.showprogress = false
	end

	if Editor.mode == 1 -- help
	then
		local line1="f1 - This screen\n"
		local line2="f2 - Save current level into a file (delete with double-rightclick)\n"
		local line3="f3 - Load level file into editor\n"
		local line4="f4 - Move: Drag buildings and enemies around with the mouse.\n      Erase elements with right click.\n"
		local line5="f5 - Add:  mousewheel or cursor up/down to select element, leftclick \n        for inserting new element, drag mouse for fences\n"
		local line6="f6 - Test:  Play current level\n"
		local line7="f7 - Restart level (resets player and enemies)\n"
		local line8="f8 - Change level options\n"
		local line9="f10 - Wipe:  erase level completely\n"
		local line10="0..9 / shift+0..9 - quickload / quicksave\n"
		local line11="Z / shift+Z - undo/redo\n"
		local line12="ESC - Exit editor and return to main menu\n"
		love.graphics.setColor(Colors.dark_black)
		Graphics.drawtext(line1..line2..line3..line4..line5..line6..line7..line8..line9..line10..line11..line12, 30, 30)

		love.graphics.draw(Graphics.images.f1help, 300, 5)
		return
	end



	if Editor.mode==5 then
		Graphics.draw()

		if Editor.current_element_index >= Entities.entitylist.barrier_horiz
			and Editor.current_element_index <= Entities.entitylist.fence_vert and
			Editor.dragging then
				Graphics.draw_building( Entities.new_element( Editor.current_element_index, Editor.itemcenter, Editor.itemlength ) )
		else
			Editor.drawelement({love.mouse.getX(), love.mouse.getY()})
		end

		love.graphics.draw(Graphics.images.f5add, 300, 5)
	end

	if Editor.mode==4 then
		Graphics.draw()
		love.graphics.draw(Graphics.images.f4move, 300, 5)
	end

	-- load & save: show files
	if Editor.mode==2 or Editor.mode==3 then
		Editor.showFileListing()
	end

	if Editor.mode==2 then
		love.graphics.draw(Graphics.images.f2save, 300, 5)
	end

	if Editor.mode==3 then
		love.graphics.draw(Graphics.images.f3load, 300, 5)
	end

	if Editor.mode==4 and Editor.dragging then
		Editor.drawelement({love.mouse.getX()+Editor.mouseposdiff[1], love.mouse.getY()+Editor.mouseposdiff[2]})

	end

	if Editor.mode==6 then
		-- test
		Graphics.draw()
		love.graphics.draw(Graphics.images.f6test, 300, 5)
	end

	if Editor.mode==7 then
		-- options
		local ecs="No"
		if not Level.enemiescanshoot then ecs="Yes" end
		local ninja="No"
		if Level.ninjamode then ninja="Yes" end
		local turns="No"
		if Level.autoturns then turns="Yes" end
		local onebullet="No"
		if Level.onebullet then onebullet="Yes" end
		love.graphics.setColor(Colors.dark_black)
		Graphics.drawtext("Click to change:",40,50)
		Graphics.drawtext("Enemies with no bullets ...... "..ecs, 40,100)
		Graphics.drawtext("<Thieves in the shadows> mode .... "..ninja, 40,150)
		Graphics.drawtext("Instantaneous turns .... "..turns, 40, 200)
		Graphics.drawtext("One bullet per enemy .... "..onebullet, 40, 250)

		love.graphics.draw(Graphics.images.f8opts, 300, 5)
	end

	if Editor.resetting then
		love.graphics.draw(Graphics.images.f7reset, 300, 5)
	end

	if Editor.wiping then
		love.graphics.draw(Graphics.images.f10wipe, 300, 5)
	end

end

function Editor.drawelement(position)
	if Editor.current_element.isbuilding then
		Editor.current_element.pos = {position[1], position[2]}
		Graphics.draw_building( Editor.current_element )
	else
		Graphics.drawCentered( Editor.current_element.sprite , love.mouse.getX(), love.mouse.getY() )
	end
end


function Editor.showFileListing()

	local x, y = Editor.listingbox[1],Editor.listingbox[2]
	love.graphics.setColor(Colors.dark_black)
	local firstline = "File <"..Editor.currentfilename.."> "

	Graphics.drawtext(love.filesystem.getSaveDirectory( ), x, y-30 )
	if Editor.fileerror_timer > 0 then
		if Editor.mode == 2 then
			firstline = "Error trying to save file"
		end
		if Editor.mode == 3 then
			firstline = "Error loading file"
		end
	end

	Graphics.drawtext(firstline,x,y)

	if Editor.listingoffset > 0 then
		Graphics.drawtext("(UP)",x,y+30)
	end

	local tolimit = Editor.listinglength
	local tablelen = table.getn(Editor.listingtable)
	if tolimit > tablelen then
		tolimit = tablelen
	end

	for i=1,tolimit do
		local fname = Editor.listingtable[i+Editor.listingoffset]
		Graphics.drawtext(fname, x, y+i*30+30 )
	end

	if Editor.listinglength+Editor.listingoffset < tablelen then
		Graphics.drawtext("(DOWN)",x,y+(Editor.listinglength+2)*30)
	end

	love.graphics.setLine(1,"rough")
	love.graphics.line(0,y,screensize[1],y)
	love.graphics.line(0,y+25,screensize[1],y+25)
	love.graphics.line(0,y+(Editor.listinglength+2)*30+25,screensize[1],y+(Editor.listinglength+2)*30+25)

	local myf = "F2"
	if Editor.mode==3 then myf="F3" end
	Graphics.drawtext("Type filename or double click file in the list. Press "..myf.." to scan dir again.",x,y+(Editor.listinglength+3)*30)
end

function Editor.update(dt)
	if Editor.fileerror_timer>0 then
		Editor.fileerror_timer = Editor.fileerror_timer - dt
	end

	if Editor.mode == 5 and Editor.dragging then
		Editor.dragging_to = { love.mouse.getX(), love.mouse.getY() }
		if Editor.current_element_index >= Entities.entitylist.barrier_horiz
			and Editor.current_element_index <= Entities.entitylist.fence_vert  then
			local dx = math.abs(Editor.dragging_to[1] - Editor.dragging_from[1])
			local dy = math.abs(Editor.dragging_to[2] - Editor.dragging_from[2])

			if dx > dy then
				if Editor.current_element_index == Entities.entitylist.barrier_horiz or Editor.current_element_index == Entities.entitylist.barrier_vert then
					Editor.current_element_index = Entities.entitylist.barrier_horiz
					Editor.itemlength = math.floor(dx/31) + 1
					Editor.itemcenter = { math.floor((Editor.dragging_from[1] + Editor.dragging_to[1])/2), Editor.dragging_from[2] }
				else
					Editor.current_element_index = Entities.entitylist.fence_horiz
					Editor.itemlength = math.floor(dx/14) + 1
					Editor.itemcenter = { math.floor((Editor.dragging_from[1] + Editor.dragging_to[1])/2), Editor.dragging_from[2] }
				end
			else
				if Editor.current_element_index == Entities.entitylist.barrier_horiz or Editor.current_element_index == Entities.entitylist.barrier_vert then
					Editor.current_element_index = Entities.entitylist.barrier_vert
					Editor.itemlength = math.floor(dy/32) + 1
					Editor.itemcenter = { Editor.dragging_from[1], math.floor((Editor.dragging_from[2] + Editor.dragging_to[2])/2) }
				else
					Editor.current_element_index = Entities.entitylist.fence_vert
					Editor.itemlength = math.floor(dy/18) + 1
					Editor.itemcenter = { Editor.dragging_from[1], math.floor((Editor.dragging_from[2] + Editor.dragging_to[2])/2) }
				end
			end
		end

	end


	-- mode = 6, normal update
	-- other modes... nothing to do I think
	if Editor.mode == 6 then
		Game.update(dt)
	end

	if Editor.mode == 2 or Editor.mode == 3 then

	end
end



function Editor.keypressed(key)
	local oldmode = Editor.mode
  -- mode selection
	if key == "f1" then
		-- help
		Editor.mode = 1
	end

	if key == "f2" then
		-- save
		if Editor.mode == 2 then
		-- pressed again: refresh
			Editor.refreshList()
			Editor.listingtable = Editor.getFileList()
		end
		Editor.mode = 2
	end

	if key == "f3" then
		-- load
		if Editor.mode == 3 then
		-- pressed again: refresh
			Editor.refreshList()
			Editor.listingtable = Editor.getFileList()
		end
		Editor.mode = 3
	end

	if key == "f4" then
		-- move
		Editor.mode = 4
	end

	if key == "f5" then
		-- add
		Editor.mode = 5
	end

	if key == "f6" then
		-- test
		Editor.mode = 6
	end

	if key == "f8" then
		-- options
		Editor.mode = 7
	end

	if key == "escape" then
		Editor.saveslotfile( 11 )
		Editor.mode = Editor.defaultmode
		Game.titlescreen()
    end

	if key == "f7" then
			Editor.resetting=true
			Level.restart()
	end

	if key == "f10" then
		Editor.wiping = true
		Level.init() -- wipeout
		Level.restart()
		Editor.firststart = true
		Editor.reset_undo()
	end

	if key == "lshift"  or key == "rshift" then
		Editor.shiftpressed = true
	end

	if Editor.mode == 5 and key == "up" then
		Editor.current_element_index = (Editor.current_element_index - 2) % Editor.num_elements + 1
		-- special= skip element 1 (player)
		if Editor.current_element_index == 1 then Editor.current_element_index = Editor.num_elements end
		-- special = skip vertical fences
		if Editor.current_element_index == Entities.entitylist.barrier_vert or
			Editor.current_element_index == Entities.entitylist.fence_vert then
				Editor.current_element_index = Editor.current_element_index - 1
		end
		Editor.current_element = Entities.new_element( Editor.current_element_index )
	end
	if Editor.mode == 5 and key == "down" then
		Editor.current_element_index = Editor.current_element_index % Editor.num_elements + 1
		-- special = skip vertical fences
		if Editor.current_element_index == Entities.entitylist.barrier_vert or
			Editor.current_element_index == Entities.entitylist.fence_vert then
				Editor.current_element_index = Editor.current_element_index + 1
		end

		if Editor.current_element_index > Editor.num_elements then Editor.current_element_index = 1 end
		if Editor.current_element_index == 1 then Editor.current_element_index = 2 end
		Editor.current_element = Entities.new_element( Editor.current_element_index )
	end

	if Editor.mode == 4 or Editor.mode == 5 then
		if key == "z" then
			if Editor.shiftpressed then
				Editor.redo()
			else
				Editor.undo()
			end
		end
	end

	-- slots
	if not (Editor.mode == 2 or Editor.mode==3) then
		local slot=nil
		if key=="1" then slot = 1 end
		if key=="2" then slot = 2 end
		if key=="3" then slot = 3 end
		if key=="4" then slot = 4 end
		if key=="5" then slot = 5 end
		if key=="6" then slot = 6 end
		if key=="7" then slot = 7 end
		if key=="8" then slot = 8 end
		if key=="9" then slot = 9 end
		if key=="0" then slot = 10 end
		if slot then
			if Editor.shiftpressed then
				Editor.saveslotfile(slot)
			else
				Editor.loadslotfile(slot)
			end
		end
	end

	-- type in filename
	if Editor.mode == 2 or Editor.mode == 3 then
		local k = Editor.keyboard_input(key)
		if k=="back" then
			if string.len(Editor.currentfilename)>0 then
				Editor.currentfilename = string.sub(Editor.currentfilename,1,-2)
			end
		elseif k=="return" then
			-- confirm
			if Editor.fileerror_timer <= 0 and string.len(Editor.currentfilename)>0 then
				if Editor.mode == 3 then
					Editor.trytoloadcurrent()
				else
					Editor.trytosavecurrent()
				end
			end
		elseif k~="" then
			Editor.currentfilename = Editor.currentfilename..k
		end
	end

	if Editor.mode == 6 then
		Game.keypressed(key)
	end

	if Editor.mode ~= oldmode then
		Editor.fileerror_timer = 0

		-- reload current element when switching state
		if Editor.current_element_index == Entities.entitylist.barrier_vert then
			Editor.current_element_index = Entities.entitylist.barrier_horiz
		end
		if Editor.current_element_index == Entities.entitylist.fence_vert then
			Editor.current_element_index = Entities.entitylist.fence_horiz
		end
		if Editor.current_element_index == Entities.entitylist.player then
			Editor.current_element_index = Entities.entitylist.blue_bandit
		end
		Editor.current_element = Entities.new_element( Editor.current_element_index )


		-- switching to testmode
		if Editor.mode ==  6 then
			-- make sure that the "enemyless" flag is correct
			Level.enemylessmode = (table.getn( Level.enemies ) == 0)
			if Level.end_time<=0 then Level.end_time = 3 end
			if Editor.firststart then
				Level.restart()
				Editor.firststart = false
			end
			-- activate
			Editor.showprogress = true
		else
			Editor.showprogress = false
		end

		if Editor.mode == 2 or Editor.mode == 3 then
			-- switching to file mode (load & save)
			Editor.listingtable = Editor.getFileList()
			Editor.currentfilename = ""
			Editor.deletefilename = ""
			Editor.listingoffset = 0
		end
	end
-- building selection
end

function Editor.keyboard_input(key)
	retval = ""
	if key=="a" then retval = "A" end
	if key=="b" then retval = "B" end
	if key=="c" then retval = "C" end
	if key=="d" then retval = "D" end
	if key=="e" then retval = "E" end
	if key=="f" then retval = "F" end
	if key=="g" then retval = "G" end
	if key=="h" then retval = "H" end
	if key=="i" then retval = "I" end
	if key=="j" then retval = "J" end
	if key=="k" then retval = "K" end
	if key=="l" then retval = "L" end
	if key=="m" then retval = "M" end
	if key=="n" then retval = "N" end
	if key=="o" then retval = "O" end
	if key=="p" then retval = "P" end
	if key=="q" then retval = "Q" end
	if key=="r" then retval = "R" end
	if key=="s" then retval = "S" end
	if key=="t" then retval = "T" end
	if key=="u" then retval = "U" end
	if key=="v" then retval = "V" end
	if key=="w" then retval = "W" end
	if key=="x" then retval = "X" end
	if key=="y" then retval = "Y" end
	if key=="z" then retval = "Z" end
	if key=="0" then retval = "0" end
	if key=="1" then retval = "1" end
	if key=="2" then retval = "2" end
	if key=="3" then retval = "3" end
	if key=="4" then retval = "4" end
	if key=="5" then retval = "5" end
	if key=="6" then retval = "6" end
	if key=="7" then retval = "7" end
	if key=="8" then retval = "8" end
	if key=="9" then retval = "9" end
	if key=="minus" then retval = "-" end
	if key=="backspace" then retval="back" end
	if key=="return" then retval="return" end
	if not Editor.shiftpressed then
		retval = string.lower(retval)
	end
	return retval
end

function Editor.keyreleased(key)
	if key == "f7" then
		Editor.resetting=false
	end

	if key == "f10" then
		Editor.wiping = false
	end

	if key == "lshift" or key == "rshift"  then
		Editor.shiftpressed = false
	end

	if Editor.mode == 6 then
		Game.keyreleased(key)
	end

end

function Editor.mousepressed(x, y, button)
	if Editor.mode == 4 and button == "l" then
		local dr = Editor.findfor_substract(x,y)
		local elem = Editor.substract(x,y)
		if elem then
			Editor.register_remove(dr[1],dr[2],dr[3],dr[4],dr[5],1)
			Editor.dragging = true
			Editor.current_element = elem
			Editor.current_element_index = elem.id
			Editor.current_element_original_pos = {Editor.current_element.pos[1],Editor.current_element.pos[2]}
			Editor.mouseposdiff = { elem.pos[1] - x, elem.pos[2] - y }
		end
	end

	if Editor.mode == 4 and button == "r" then
		local dr = Editor.findfor_substract(x,y)
		local elem =Editor.substract(x,y)
		if elem then
			Editor.register_remove(dr[1],dr[2],dr[3],dr[4],dr[5])
		end
	end

	if Editor.mode == 5 and button == 'wu' then
		Editor.current_element_index = (Editor.current_element_index - 2) % Editor.num_elements + 1
		-- special= skip element 1 (player)
		if Editor.current_element_index == 1 then Editor.current_element_index = Editor.num_elements end
		-- special = skip vertical fences
		if Editor.current_element_index == Entities.entitylist.barrier_vert or
			Editor.current_element_index == Entities.entitylist.fence_vert then
				Editor.current_element_index = Editor.current_element_index - 1
		end
		Editor.current_element = Entities.new_element( Editor.current_element_index )
	end
	if Editor.mode == 5 and button == 'wd' then
		Editor.current_element_index = Editor.current_element_index % Editor.num_elements + 1
		-- special = skip vertical fences
		if Editor.current_element_index == Entities.entitylist.barrier_vert or
			Editor.current_element_index == Entities.entitylist.fence_vert then
				Editor.current_element_index = Editor.current_element_index + 1
		end

		if Editor.current_element_index > Editor.num_elements then Editor.current_element_index = 1 end
		if Editor.current_element_index == 1 then Editor.current_element_index = 2 end
		Editor.current_element = Entities.new_element( Editor.current_element_index )
	end

	if Editor.mode == 5 and button == "l" then
	-- special cases: barrier and fence
		if Editor.current_element_index >= Entities.entitylist.barrier_horiz
		and Editor.current_element_index <= Entities.entitylist.fence_vert then
			Editor.dragging = true
			Editor.dragging_from = {x,y}
		else
			Editor.add_element({x,y})
		end

	end

	if Editor.mode==2 or Editor.mode==3 then
		if button == "l" then
			if y>Editor.listingbox[2] and y<Editor.listingbox[2]+(Editor.listinglength+2)*30+25 then
				local index = math.floor((y-Editor.listingbox[2])/30)

				if index>0 then Editor.fileerror_timer = 0 end
				-- up
				if index==1 and Editor.listingoffset>0 then
					Editor.listingoffset = Editor.listingoffset-1
				end

				-- down
				if index==(Editor.listinglength+2) and Editor.listingoffset+Editor.listinglength < table.getn(Editor.listingtable) then
					Editor.listingoffset = Editor.listingoffset+1
				end

				-- select file
				if index>=2 and index<=Editor.listinglength+1 then
					local newindex = index - 1 + Editor.listingoffset
					if newindex<=table.getn(Editor.listingtable) then
						local candidatefilename = Editor.listingtable[newindex]
						-- double click
						if Editor.currentfilename==candidatefilename then
							-- load level
							if Editor.mode == 3 then
								Editor.trytoloadcurrent()
							end
							if Editor.mode == 2 then
								Editor.trytosavecurrent()
							end
						else
						-- single click
							Editor.currentfilename = candidatefilename
						end
					end
				end

				-- confirm
				if index==0 and Editor.fileerror_timer <= 0 and string.len(Editor.currentfilename)>0 then
					if Editor.mode == 3 then
						Editor.trytoloadcurrent()
					else
						Editor.trytosavecurrent()
					end
				end
			end
		elseif button == "r" then
			-- esborrar
			if y>Editor.listingbox[2] and y<Editor.listingbox[2]+(Editor.listinglength+2)*30+25 then
				local index = math.floor((y-Editor.listingbox[2])/30)

				if index>0 then Editor.fileerror_timer = 0 end

				-- select file
				if index>=2 and index<=Editor.listinglength+1 then
					local newindex = index - 1 + Editor.listingoffset
					if newindex<=table.getn(Editor.listingtable) then
						local candidatefilename = Editor.listingtable[newindex]
						-- double click
						if Editor.deletefilename==candidatefilename then
							if Editor.mode == 2 then
								Editor.deletefile(Editor.deletefilename)
							end
						else
						-- single click
							Editor.deletefilename = candidatefilename
						end
					end
				end


			end
		elseif button == "wu" and Editor.listingoffset>0 then
		-- scroll up
			Editor.listingoffset = Editor.listingoffset-1
		elseif button == l"wd" and Editor.listingoffset+Editor.listinglength < table.getn(Editor.listingtable)then
		-- scroll down
			Editor.listingoffset = Editor.listingoffset+1
		end
	end

	if Editor.mode==7 then
		if x>40 and x<300 and y>75 and y<125 then Level.enemiescanshoot = not Level.enemiescanshoot end
		if x>40 and x<340 and y>125 and y<175 then Level.ninjamode = not Level.ninjamode end
		if x>40 and x<250 and y>175 and y<225 then Level.autoturns = not Level.autoturns end
		if x>40 and x<262 and y>225 and y<275 then Level.onebullet = not Level.onebullet end
	end

	if Editor.mode == 6 then
		Game.mousepressed(x, y, button)
	end
end

function Editor.add_element(point,len)
	local x,y = point[1],point[2]
	-- check collisions!
	local valid = true
	if Editor.current_element_index < 6 then -- enemy
		local enemybox = { x-9, y-11, x+9, y+11 }
		for i,building in ipairs(Level.buildings) do
			if mymath.check_boxinbuilding( enemybox, building ) then
				valid = false
				break
			end
		end
		-- collision with player

		if valid then
			local plx,ply = Player.starting_pos[1],Player.starting_pos[2]
			if Editor.current_element_index ~=Entities.entitylist.player and
				mymath.check_boxes( enemybox, { plx-9, ply-11, plx+9, ply+11 } ) then
				valid = false
			end
		end
		-- collision of player
		if valid and Editor.current_element_index == Entities.entitylist.player then
			local plx,ply = point[1],point[2]
			for i,enemy in ipairs(Level.enemies) do
				local cx,cy = enemy.starting_pos[1],enemy.starting_pos[2]
				local dx,dy = enemy.spritesize[1]/2, enemy.spritesize[2]/2
				enemybox = { cx-dx,cy-dy,cx+dx,cy+dy }
				if mymath.check_boxes( enemybox, { plx-9, ply-11, plx+9, ply+11 } ) then
					valid = false
					break
				end
			end
		end

	else -- building
		local building = Entities.new_element( Editor.current_element_index, {x,y}, len )
		for i,enemy in ipairs(Level.enemies) do
			local cx,cy = enemy.starting_pos[1],enemy.starting_pos[2]
			local dx,dy = enemy.spritesize[1]/2, enemy.spritesize[2]/2
			local enemybox = { cx-dx,cy-dy,cx+dx,cy+dy }
			if mymath.check_boxinbuilding( enemybox, building ) then
				valid = false
				break
			end
		end
		-- collision with player
		local plx,ply = Player.starting_pos[1],Player.starting_pos[2]
		if valid and mymath.check_boxinbuilding( { plx-9, ply-11, plx+9, ply+11 }, building ) then
			valid = false
		end
	end
	if valid then
		Entities.add_element( Editor.current_element_index, {x,y}, len )

		-- get index in table from class
		local itemindex = 1
		if Editor.current_element_index == 1 then
			itemindex = 1
		elseif Editor.current_element_index >= Entities.entitylist.blue_bandit and
			Editor.current_element_index <= Entities.entitylist.yellow_bandit then
			itemindex = table.getn(Level.enemies)
		else
			itemindex = table.getn(Level.buildings)
		end

		if Editor.mode==5 then
			Editor.register_add(itemindex, Editor.current_element_index, x, y, len)
		elseif Editor.mode == 4 and Editor.dragging then
			Editor.register_add(itemindex, Editor.current_element_index, x, y, len, 1)
		end
	end
	return valid
end


function Editor.mousereleased(x, y, button)
	if Editor.mode == 4 and button == "l" and Editor.dragging then
		local len = 1
		if Editor.current_element.len then len = Editor.current_element.len[2] end
		if not Editor.add_element( {x+Editor.mouseposdiff[1],y+Editor.mouseposdiff[2]}, len )
		then Editor.add_element( Editor.current_element_original_pos, len ) end
	end

	if Editor.mode ==5 and Editor.dragging and Editor.current_element_index >= Entities.entitylist.barrier_horiz
	and Editor.current_element_index <= Entities.entitylist.fence_vert then
		Editor.add_element(Editor.itemcenter, Editor.itemlength)
	end

	Editor.dragging = false
	if Editor.mode == 6 then
		Game.mousereleased(x, y, button)
	end
end

function Editor.findfor_substract(x,y)

	for i,building in ipairs(Level.buildings) do
		if mymath.check_pointinbox( {x,y},
			{building.pos[1]-building.sprite:getWidth()/2,building.pos[2]-building.sprite:getHeight()/2,
			 building.pos[1]+building.sprite:getWidth()/2,building.pos[2]+building.sprite:getHeight()/2} )
		then
			if building.id >= Entities.entitylist.barrier_horiz and
				building.id<= Entities.entitylist.fence_vert then
				return {i,building.id, building.pos[1], building.pos[2], building.len[2]}
			else
				return {i,building.id, building.pos[1], building.pos[2], 1}
			end
		end
	end

	-- find if it's a fence
	for i,building in ipairs(Level.buildings) do
		if mymath.check_pointinbuilding( {x,y}, building )
		then
			if building.id >= Entities.entitylist.barrier_horiz and
				building.id<= Entities.entitylist.fence_vert then
				return {i,building.id, building.pos[1], building.pos[2], building.len[2]}
			else
				return {i,building.id, building.pos[1], building.pos[2], 1}
			end
		end
	end

	-- find if it's an enemy
	for i,enemy in ipairs(Level.enemies) do
		if mymath.check_pointinbox( {x,y},
			{enemy.pos[1]-enemy.spritesize[1]/2,enemy.pos[2]-enemy.spritesize[2]/2,
			 enemy.pos[1]+enemy.spritesize[1]/2,enemy.pos[2]+enemy.spritesize[2]/2} )
		then
			return {i,enemy.id, enemy.starting_pos[1], enemy.starting_pos[2], 1}
		end
	end


	-- find if it's the player
	if mymath.check_pointinbox( {x,y},
		{Player.pos[1]-Player.spritesize[1]/2,Player.pos[2]-Player.spritesize[2]/2,
		 Player.pos[1]+Player.spritesize[1]/2,Player.pos[2]+Player.spritesize[2]/2} )
	then
		return {i,1, Player.starting_pos[1], Player.starting_pos[2], 1}
	end

end

function Editor.substract(x,y)
	-- returns a reference to the first entity (building or enemy or player) that corresponds to (x,y)
	-- the thing is that in moving mode, when you click on an entity, it floats on top of the list, becoming
	-- the last.  So if you click repeatedly in the same point where several buildings are overlapping, this
	-- should always bring the last one on top.

	-- find if it's a building (using the whole sprite, not the regular collision)
	for i,building in ipairs(Level.buildings) do
		if mymath.check_pointinbox( {x,y},
			{building.pos[1]-building.sprite:getWidth()/2,building.pos[2]-building.sprite:getHeight()/2,
			 building.pos[1]+building.sprite:getWidth()/2,building.pos[2]+building.sprite:getHeight()/2} )
		then
			table.remove(Level.buildings,i)
			return building
		end
	end

	-- find if it's a fence
	for i,building in ipairs(Level.buildings) do
		if mymath.check_pointinbuilding( {x,y}, building )
		then
			table.remove(Level.buildings,i)
			return building
		end
	end

	-- find if it's an enemy
	for i,enemy in ipairs(Level.enemies) do
		if mymath.check_pointinbox( {x,y},
			{enemy.pos[1]-enemy.spritesize[1]/2,enemy.pos[2]-enemy.spritesize[2]/2,
			 enemy.pos[1]+enemy.spritesize[1]/2,enemy.pos[2]+enemy.spritesize[2]/2} )
		then
			table.remove(Level.enemies,i)
			return enemy
		end
	end


	-- find if it's the player
	if mymath.check_pointinbox( {x,y},
		{Player.pos[1]-Player.spritesize[1]/2,Player.pos[2]-Player.spritesize[2]/2,
		 Player.pos[1]+Player.spritesize[1]/2,Player.pos[2]+Player.spritesize[2]/2} )
	then
		return Player
	end

end

function Editor.undo()
	if Editor.undo_point == Editor.undo_begin then
		return
	end

	Editor.rewind_undo_pointer()

	local move = (Editor.undo_list[Editor.undo_point][2]==1)

	-- do the oposite
	if Editor.undo_list[Editor.undo_point][1] == 1 then
		-- add, so remove
		local d = Editor.undo_list[Editor.undo_point]
		Editor.apply_remove( {d[3], d[4], d[5], d[6], d[7]} )
	else
		-- remove, so add
		local d = Editor.undo_list[Editor.undo_point]
		Editor.apply_add( {d[3], d[4], d[5], d[6], d[7]} )

	end


	if move then
		Editor.rewind_undo_pointer()

		if Editor.undo_list[Editor.undo_point][1] == 1 then
		-- add, so remove
			local d = Editor.undo_list[Editor.undo_point]
			Editor.apply_remove( {d[3], d[4], d[5], d[6], d[7]} )
		else
			-- remove, so add
			local d = Editor.undo_list[Editor.undo_point]
			Editor.apply_add( {d[3], d[4], d[5], d[6], d[7]} )
		end

	end

end

function Editor.redo()



	if Editor.undo_point == Editor.undo_end then
		return
	end


	local move = (Editor.undo_list[Editor.undo_point][2]==1)

	-- do the oposite
	if Editor.undo_list[Editor.undo_point][1] == 1 then
		-- add
		local d = Editor.undo_list[Editor.undo_point]
		Editor.apply_add( {d[3], d[4], d[5], d[6], d[7]} )
	else
		-- remove
		local d = Editor.undo_list[Editor.undo_point]
		Editor.apply_remove( {d[3], d[4], d[5], d[6], d[7]} )
	end

	Editor.advance_undo_pointer()


	if move then


		-- do the oposite
		if Editor.undo_list[Editor.undo_point][1] == 1 then
			-- add
			local d = Editor.undo_list[Editor.undo_point]
			Editor.apply_add( {d[3], d[4], d[5], d[6], d[7]} )
		else
			-- remove
			local d = Editor.undo_list[Editor.undo_point]
			Editor.apply_remove( {d[3], d[4], d[5], d[6], d[7]} )
		end

		Editor.advance_undo_pointer()

	end

end

function Editor.apply_add( datalist )
	local itemindex, classindex, x, y, len = datalist[1],datalist[2],datalist[3], datalist[4], datalist[5]

	if classindex == 1 then
		Entities.add_element( 1,{x,y},1 )
	elseif classindex >= Entities.entitylist.blue_bandit and classindex <= Entities.entitylist.yellow_bandit then
		table.insert( Level.enemies, itemindex, Entities.new_element( classindex, {x,y} ) )
	else
		table.insert( Level.buildings, itemindex, Entities.new_element( classindex, {x,y} , len ) )
	end

end

function Editor.apply_remove( datalist )
	local itemindex, classindex, x, y, len = datalist[1],datalist[2],datalist[3], datalist[4], datalist[5]
	if classindex==1 then
		-- player .. ignore
	elseif classindex >= Entities.entitylist.blue_bandit and classindex <= Entities.entitylist.yellow_bandit then
		table.remove(Level.enemies, itemindex )
	else -- building
		table.remove(Level.buildings, itemindex )
	end
end

-- undo/redo: three types of actions, add, remove, move (que es remove+add)
function Editor.register_add( itemindex, classindex, x, y, len, move )
	if move==nil then move = 0 end

	Editor.undo_list[Editor.undo_point] = {
		1, -- add
		move,
		itemindex,
		classindex,
		x,
		y,
		len }
	Editor.push_undo_pointer()
end

function Editor.register_remove( itemindex, classindex, x, y, len, move )
	if move==nil then move = 0 end

	Editor.undo_list[Editor.undo_point] = {
		2, -- remove
		move, -- no move
		itemindex,
		classindex,
		x,
		y,
		len }
	Editor.push_undo_pointer()
end

function Editor.push_undo_pointer()
	Editor.undo_point = Editor.undo_point + 1
	if Editor.undo_point > Editor.undo_max then
		Editor.undo_point = 1
	end
	if Editor.undo_begin == Editor.undo_point then
		Editor.undo_begin = Editor.undo_begin + 1
		if Editor.undo_begin > Editor.undo_max then
			Editor.undo_begin = 1
		end
	end
	Editor.undo_end = Editor.undo_point
end

function Editor.advance_undo_pointer()
	if Editor.undo_point == Editor.undo_end then
		return
	end

	Editor.undo_point = Editor.undo_point + 1
	if Editor.undo_point == Editor.undo_max then
		Editor.undo_point = 1
	end
end

function Editor.rewind_undo_pointer()
	if Editor.undo_point == Editor.undo_begin then
		return
	end

	Editor.undo_point = Editor.undo_point - 1
	if Editor.undo_point == 0 then
		Editor.undo_point = Editor.undo_max
	end
end

function Editor.reset_undo()
-- undo
	Editor.undo_list = {}
	Editor.undo_point = 1
	Editor.undo_max = 400 -- 400 undo actions
	Editor.undo_begin = 1
	Editor.undo_end = 1
end
