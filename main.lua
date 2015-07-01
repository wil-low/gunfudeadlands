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

function loadModule( moduleName )
	local chunk = love.filesystem.load( moduleName )
	chunk()
end

function love.load()
	-- uncomment this for profiling (will affect performance!)
	--loadModule("profiling.lua")

	-- Dependencies
	loadModule("mymath.lua")
	loadModule("lists.lua")

	loadModule("sprites.lua")
	loadModule("audio.lua")

	loadModule("player.lua")
	loadModule("movement.lua")
	loadModule("enemies.lua")

	loadModule("entities.lua")
	loadModule("level.lua")

	loadModule("bullettime.lua")
	loadModule("editor.lua")
	loadModule("editor_files.lua")
	loadModule("userlevel.lua")

	loadModule("game.lua")



	-- Initialization
	math.randomseed(os.time())

	-- Init graphics mode
	screensize = { 640, 480 }
	--if not love.graphics.setMode( screensize[1], screensize[2], false, true, 0 ) then
	if not Graphics.setWindowed() then
		love.event.push('q')
	end
	
	love.graphics.setColorMode("replace")

	Game.init()

	-- Colors
	Colors.init()
	Graphics.init()

	-- Audio system
	if Sounds.active then
	love.audio.setVolume(.3)
	end

	-- Font
	love.graphics.setFont( love.graphics.newImageFont ("images/western_font_clear.png",
		"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890($>:.,!?)'<-+\\/ ") )


	Editor.load()
	UserLevel.load()

	Game.titlescreen()

	Music.start()


end

function love.update(dt)
	if Editor.enabled then
		Editor.update(dt)
		return
	elseif UserLevel.enabled then
		UserLevel.update(dt)
		return
	end

    Game.update(dt)

end

function love.draw()
	if Editor.enabled then
		Editor.draw()
		return
	elseif UserLevel.enabled then
		UserLevel.draw()
		return
	end

	Graphics.draw()

end


function love.keypressed(key)
	-- general
	if key == "n" then
		Sounds.switch()
	end

	if key == "m" then
		Music.switch()
	end

	if key == "f12" then
		Graphics.toggleMode()
	end

	if Editor.enabled then
		Editor.keypressed( key )
		return
	elseif UserLevel.enabled then
		UserLevel.keypressed( key )
		return
	end

	Game.keypressed(key)

end


function love.keyreleased(key)
	if Editor.enabled then
		Editor.keyreleased( key )
		return
	elseif UserLevel.enabled then
		UserLevel.keyreleased( key )
		return
	end


	Game.keyreleased(key)

end


function love.mousepressed(x, y, button)
	if Editor.enabled then
		Editor.mousepressed(x, y, button)
		return
	elseif UserLevel.enabled then
		UserLevel.mousepressed(x, y, button)
		return
	end

	Game.mousepressed(x,y,button)

end



function love.mousereleased(x, y, button)
	if Editor.enabled then
		Editor.mousereleased(x, y, button)
		return
	elseif UserLevel.enabled then
		UserLevel.mousereleased(x, y, button)
		return
	end


	Game.mousereleased(x,y, button)

end



