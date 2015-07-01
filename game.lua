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

Game = {}


function Game.init()
	Game.gamemode = 1
	Game.paused = false
	Game.testlevel = false
	Game.smallcollision = true
	Game.helpmode = false
end

function Game.titlescreen()
	Level.init()
	Level.currentlevel = 0
	Level.menutext = "           by Christiaan Janssen\n\nObjective -                   kill all bandits\nArrow keys or WASD -    move\nMouse -                     aim\nLeft Click -                  shoot\nMiddle Click -               bullet time\nRight Click + Direction -    jump + bullet time\nSpace, R or RShift -        reload gun\nF12 -                         toggle fullscreen\nESC -                         quit\n\n           Press space to start"
	Level.menutext_U = "           by Christiaan Janssen"
--~ 	Level.menutext_L = "Objective -\nArrow keys or WASD -\nMouse -\nLeft Click -\nMiddle Click -\nRight Click + Direction -\nSpace, R or RShift -\nP -\nF12 -\nN -\nM -\nESC -"
--~ 	Level.menutext_R = "kill all bandits\nmove\naim\nshoot\nbullet time\njump + bullet time\nreload gun\npause game\ntoggle fullscreen\nsound FX on-off\nmusic on-off\nquit"
	Level.menutext_L = "Objective: \n\n          Movement:\nArrow keys or WASD -\nMouse -\nLeft Click -\nMiddle Click -\nRight Click + Direction -\nSpace, R or RShift -\n\n          Other:\nP -\nN -\nM -\nF12 -\nESC -\n\n          Press F1 to go back"
	Level.menutext_R = "kill all bandits\n\n\nmove\naim\nshoot\nbullet time\njump + bullet time\nreload gun\n\n\npause game\nsound FX on-off\nmusic on-off\ntoggle fullscreen\nquit"
	Entities.add_element(Entities.entitylist.player,{184,24})
	Entities.add_element(Entities.entitylist.blue_bandit,{91,393})
	Entities.add_element(Entities.entitylist.blue_bandit,{584,324})
	Entities.add_element(Entities.entitylist.cactus,{54,124})
	Entities.add_element(Entities.entitylist.cactus,{554,224})
	Entities.add_element(Entities.entitylist.cactus,{484,400})
	Graphics.prepareBackground()
	Graphics.prepareTopLayer()
	Level.reset_enemies()
	Player.alive = false
	Player.death_timer = 0
	BulletTime.showprogress = false
	Editor.enabled=false

end

function Game.endgame()
	Level.init()
	Level.currentlevel = 11
	Level.endtext = "Victory!\n\nEveryone is dead now.\nYou are the only survivor in this ghost town.\nNo more bad people.  No more people at all.\n\nYou win.\n\nESC for main menu"
	Level.hardtext = "You've beaten the hard mode! You are a true badass!"
	Entities.add_element(Entities.entitylist.player,{30,30})
	Entities.add_element(Entities.entitylist.cactus,{54,124})
	Entities.add_element(Entities.entitylist.cactus,{554,224})
	Entities.add_element(Entities.entitylist.cactus,{354,400})
	Graphics.prepareBackground()
	Graphics.prepareTopLayer()
end

function Game.update(dt)
--~ 	if Level.currentlevel == 0 then
--~ 		return
--~ 	end

	if Game.paused or Game.helpmode then
		return
	end

	if not BulletTime.active then
		Player.update( dt )

		Movement.update_bullets( dt )
		
		EnemyAI.update( dt )

		Graphics.update_player( dt )
		Graphics.update_enemies( dt )
	else
		Player.update( dt * BulletTime.slowdown_player )
		
		Movement.update_bullets( dt * BulletTime.slowdown_bullets )
		
		EnemyAI.update( dt * BulletTime.slowdown_enemies )

		Graphics.update_player( dt * BulletTime.slowdown_player )
		Graphics.update_enemies( dt * BulletTime.slowdown_enemies )
	end

	BulletTime.update( dt )

	Level.update( dt )
end


function Game.keypressed( key )


	if key == "escape" then
		if Game.helpmode then
			Game.helpmode = false
		elseif Level.currentlevel == 0 and not Editor.enabled then
			if ProfilingEnabled then
				dumpTrace()
			end
 			love.event.push('q')
		else
			Game.paused = false
			Game.titlescreen()
		end
    end

	if key == "p" then
		Game.paused = not Game.paused
	end

	if key == "f1" and (not Editor.enabled) and (not Game.paused) then
		Game.helpmode = not Game.helpmode
	end

	if Game.paused or Game.helpmode then
		return
	end

	if key == "f7" then
		if Editor.enabled then
			Level.restart()
		end
	end

	if Level.currentlevel == 0 and not Editor.enabled then
		if key == "f2" then
			-- start normal game
			BulletTime.showprogress = true
			Game.gamemode = 1
			Level.currentlevel = 1
			Level.load(1)
		end
		if key == "f3" then
			-- start hard game
			BulletTime.showprogress = true
			Game.gamemode = 2
			Level.currentlevel = 1
			Level.load(1)
		end
		if key== "f5" then
			Level.currentlevel = 1
			Editor.init()
		end
		if key== "f4" then
			Level.currentlevel = 1
			UserLevel.init()
		end
	end

	if Level.currentlevel > 0 and
		(key == "r" or key == "rshift" or key == " ") then
		Player.start_reload()
	end

end


function Game.keyreleased(key)
end


function Game.mousepressed(x,y,button)
	if Game.paused or Game.helpmode then
		return
	end

	if Level.currentlevel == 0 and not Editor.enabled then
		return
	end

-- Checks which button was pressed.
    if button == "l" then
       Player.start_firing()

    elseif button == "r" then
			Player.start_jumping()
			BulletTime.start()
	elseif button == "m" then
		BulletTime.start()
	end
end

function Game.mousereleased(x,y, button)
	if Game.paused or Game.helpmode then
		return
	end
-- Checks which button was pressed.
    if button == "l" then
       Player.stop_firing()
    elseif button == "r" then
		Player.set_jumping_done()
	end
end
