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

Sounds = {

	bullet_time = love.audio.newSource("sounds/explosion.ogg","static"),

	revolver = {
		love.audio.newSource("sounds/Revolver_shot1.ogg","static"),
		love.audio.newSource("sounds/Revolver_shot2.ogg","static"),
	},

	revolver_slow = {
		love.audio.newSource("sounds/Revolver_shot1_slow.ogg","static"),
		love.audio.newSource("sounds/Revolver_shot2_slow.ogg","static"),
	},

	shot_blue = {
		normal = love.audio.newSource("sounds/Revolver_shot_blue.ogg","static"),
		slow = love.audio.newSource("sounds/Revolver_shot_blue_slow.ogg","static"),
	},

	shot_red = {
		normal = love.audio.newSource("sounds/Revolver_shot_red.ogg","static"),
		slow = love.audio.newSource("sounds/Revolver_shot_red_slow.ogg","static"),
	},

	shot_green = {
		normal = love.audio.newSource("sounds/Revolver_shot_green.ogg","static"),
		slow = love.audio.newSource("sounds/Revolver_shot_green_slow.ogg","static"),
	},

	shot_yellow = {
		normal = love.audio.newSource("sounds/Revolver_shot_yellow.ogg","static"),
		slow = love.audio.newSource("sounds/Revolver_shot_yellow_slow.ogg","static"),
	},

	scream_blue = {
		love.audio.newSource("sounds/scream_blue1.ogg","static"),
 		love.audio.newSource("sounds/scream_blue2.ogg","static"),
	},

	scream_blue_slow = {
		love.audio.newSource("sounds/scream_blue_slow1.ogg","static"),
 		love.audio.newSource("sounds/scream_blue_slow2.ogg","static"),
	},

	scream_red = {
		love.audio.newSource("sounds/scream_red1.ogg","static"),
		love.audio.newSource("sounds/scream_red2.ogg","static"),
	},

	scream_red_slow = {
		love.audio.newSource("sounds/scream_red_slow1.ogg","static"),
		love.audio.newSource("sounds/scream_red_slow2.ogg","static"),
	},

	scream_yellow = {
		love.audio.newSource("sounds/scream_yellow.ogg","static"),
	},

	scream_yellow_slow = {
		love.audio.newSource("sounds/scream_yellow_slow.ogg","static"),
	},

	scream_green = {
		love.audio.newSource("sounds/scream_green.ogg","static"),
	},

	scream_green_slow = {
		love.audio.newSource("sounds/scream_green_slow.ogg","static"),
	},

	scream_player = love.audio.newSource("sounds/scream_player.ogg","static"),

	reload_start = love.audio.newSource("sounds/reload_start.ogg","static"),
	reload_done = love.audio.newSource("sounds/reload_done.ogg","static"),
	reload_start_slow = love.audio.newSource("sounds/reload_start_slow.ogg","static"),
	reload_done_slow = love.audio.newSource("sounds/reload_done_slow.ogg","static"),

}

Sounds.active = true

function Sounds.playsound( sound )
	love.audio.stop( sound )
	love.audio.rewind( sound )
	love.audio.play( sound )
end

function Sounds.play_shot_player()
	if not Sounds.active then return end
	if not BulletTime.active then
		Sounds.playsound(Sounds.revolver[math.random(table.getn(Sounds.revolver))])
	else
		Sounds.playsound(Sounds.revolver_slow[math.random(table.getn(Sounds.revolver_slow))])
	end
end

function Sounds.play_shot_enemy( enemy )
	if not Sounds.active then return end
	if not BulletTime.active then
		Sounds.playsound(enemy.shot_sound.normal)
	else
		Sounds.playsound(enemy.shot_sound.slow)
	end
end

function Sounds.play_bullettime()
	if not Sounds.active then return end
	Sounds.playsound(Sounds.bullet_time)
end

function Sounds.play_scream_enemy(enemy)
	if not Sounds.active then return end
	if not BulletTime.active then
		Sounds.playsound(enemy.scream[math.random(table.getn(enemy.scream))])
	else
		Sounds.playsound(enemy.scream_slow[math.random(table.getn(enemy.scream))])
	end
end

function Sounds.play_scream_player()
	if not Sounds.active then return end
	Sounds.playsound(Sounds.scream_player)
end

function Sounds.play_reload_start()
	if not Sounds.active then return end
	if not BulletTime.active then
		Sounds.playsound(Sounds.reload_start)
	else
		Sounds.playsound(Sounds.reload_start_slow)
	end
end

function Sounds.play_reload_done()
	if not Sounds.active then return end
	if not BulletTime.active then
		Sounds.playsound(Sounds.reload_done)
	else
		Sounds.playsound(Sounds.reload_done_slow)
	end
end

function Sounds.switch()
	Sounds.active = not Sounds.active
end

Music={
	active = true,
	maintheme = love.audio.newSource( 'music/GunFuMainTheme.ogg' ),
}

function Music.start()
	Music.maintheme:setLooping(true)
	Sounds.playsound( Music.maintheme )
end

function Music.pause()
	love.audio.pause(  Music.maintheme )
	Music.active = false
end

function Music.continue()
	love.audio.resume( Music.maintheme )
	Music.active = true
end

function Music.switch()
	if Music.active then
		Music.pause()
	else
		Music.continue()
	end
end

