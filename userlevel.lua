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


UserLevel = {}

function UserLevel.load()
	UserLevel.enabled = false
	UserLevel.mode = 1
end

function UserLevel.init()
	UserLevel.enabled = true
	Game.gamemode = 3
	Editor.mode = 3
	UserLevel.mode = 1
	Editor.listingtable = Editor.getFileList()
	Editor.currentfilename = ""
	Editor.listingoffset = 0
	UserLevel.block_mouse = false
end

function UserLevel.update( dt )
	if UserLevel.mode == 1 then
		if Editor.fileerror_timer>0 then
			Editor.fileerror_timer = Editor.fileerror_timer - dt
			Editor.mode = 3
		end
	end
	if UserLevel.mode == 2 then
		Game.update(dt)
	end
end

function UserLevel.draw()
	if UserLevel.mode == 1 then
		Editor.showFileListing()
	end

	if UserLevel.mode == 2 then
		Graphics.draw()
	end

	if UserLevel.mode == 3 then
		Graphics.draw()

		-- victory panel
		love.graphics.setColor(Colors.orange)
		love.graphics.rectangle( "fill" , 180, 182, 275, 85 )

		love.graphics.setColor(Colors.lt_red)
		love.graphics.setLine(1,"rough")
		love.graphics.line(179,182,180+275,182)
		love.graphics.line(180,182,180,182+85)
		love.graphics.line(180,182+85,180+275,182+85)
		love.graphics.line(180+275,182,180+275,182+85)

		love.graphics.setColor(Colors.dark_black)
		Graphics.drawtext("Victory!  You defeated the level\n  ESC to return to load menu", 200, 200)
	end
end

function UserLevel.keypressed( key )
	if key=="f3" and UserLevel.mode==1 then
		Editor.refreshList()
		Editor.listingtable = Editor.getFileList()
	end

	if key == "escape" then
		if UserLevel.mode == 1 then
			UserLevel.enabled = false
			Game.titlescreen()
		else
			UserLevel.init()
		end
    end

	-- type in filename
	if UserLevel.mode == 1 then
		local k = Editor.keyboard_input(key)
		if k=="back" then
			if string.len(Editor.currentfilename)>0 then
				Editor.currentfilename = string.sub(Editor.currentfilename,1,-2)
			end
		elseif k=="return" then
			-- confirm
			if string.len(Editor.currentfilename)>0 then
				UserLevel.trytoloadcurrent()
			end
		elseif k~="" then
			Editor.currentfilename = Editor.currentfilename..k
		end
	end

	-- game
	if UserLevel.mode == 2 then
		Game.keypressed(key)
	end

end

function UserLevel.keyreleased( key )
	-- game
	if UserLevel.mode == 2 then
		Game.keyreleased(key)
	end
end

function UserLevel.mousepressed(x, y, button)

	if UserLevel.mode == 1 then
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
							UserLevel.trytoloadcurrent()
						else
						-- single click
							Editor.currentfilename = candidatefilename
						end
					end
				end

				-- confirm
				if index==0 and Editor.fileerror_timer <= 0 and string.len(Editor.currentfilename)>0 then
					UserLevel.trytoloadcurrent()
				end
			end
		elseif button == "r" then
		-- delete
		elseif button == "wu" and Editor.listingoffset>0 then
		-- scroll up
			Editor.listingoffset = Editor.listingoffset-1
		elseif button == "wd" and Editor.listingoffset+Editor.listinglength < table.getn(Editor.listingtable)then
		-- scroll down
			Editor.listingoffset = Editor.listingoffset+1
		end
	end

	-- game
	if UserLevel.mode == 2 and not UserLevel.block_mouse then
		Game.mousepressed(x, y, button)
	end
end

function UserLevel.mousereleased(x, y, button)
	if UserLevel.block_mouse then
		UserLevel.block_mouse = false
	end

	-- game
	if UserLevel.mode == 2 then
		Game.mousereleased(x, y, button)
	end
end

function UserLevel.trytoloadcurrent()
	Editor.fileerror_timer = 0
	Editor.trytoloadcurrent()
	if Editor.fileerror_timer <= 0 then
		-- success
		UserLevel.mode = 2
		Level.currentlevel = 1
		-- override shooting enemies option
		Level.enemiescanshoot = true
		Level.restart()
		UserLevel.block_mouse = true
	else
		-- fail
		UserLevel.mode = 1
		Editor.currentfilename = ""
	end
end


