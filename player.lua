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

Player = {}


function Player.update( dt )
	if Player.alive then
		if Player.jumping then
			Player.dir = {Player.spinning_dir[1], Player.spinning_dir[2]}
			Player.speed = Player.speed_jumping
		else
			Player.dir = Player.get_dir_from_keys()
			Player.speed = Player.speed_walking
		end

		--Movement.compute_predictions( Player )
		Movement.update_character( dt, Player )

		-- jumping!
		if Player.jumping then
			Player.jump_timer = Player.jump_timer - dt
			if Player.jump_timer <= 0 then
				Player.jumping = false
			end
		end

		Player.update_fire( dt )

		-- prediction
		local accel = 1
		if BulletTime.active then
			accel = accel / BulletTime.slowdown_player
		end
		if Player.prediction_timer > 0 then
			Player.prediction_timer = Player.prediction_timer - dt*accel
		end

	else
		Movement.update_character( dt, Player )

		if Player.death_timer > 0 then
 			Player.death_timer = Player.death_timer - dt
 		end
	end
end

function Player.start_jumping()
	if Player.readytojump and Player.alive and not Player.jumping and not (Player.dir[1]==0 and Player.dir[2]==0) then
		Player.jumping = true
		Player.readytojump = false
		Player.spinning_dir = {Player.dir[1],Player.dir[2]}
		Player.jump_timer = Graphics.get_jumptime()
		Graphics.reset_jump()
	end
end


function Player.set_jumping_done()
	Player.readytojump = true
end

function Player.get_dir_from_keys()
	local mydir = {0,0}
	if love.keyboard.isDown( "s" ) or love.keyboard.isDown( "down" ) then
		mydir[2] = 1
	end

	if love.keyboard.isDown( "w" ) or love.keyboard.isDown( "up" ) then
		mydir[2] = -1
	end

	if love.keyboard.isDown( "a" ) or love.keyboard.isDown( "left" ) then
		mydir[1] = -1
	end

	if love.keyboard.isDown( "d" ) or love.keyboard.isDown( "right" ) then
		mydir[1] = 1
	end

	if mydir[1]*mydir[1]+mydir[2]*mydir[2] > 1 then
		mydir = mymath.normalize_vector( mydir )
	end

	return mydir

end

function Player.start_reload()
	if Player.reload_timer <= 0 and Player.bullet_pocket < Player.total_bullets then
		Player.reload_timer = Player.bullet_loadingdelay
		Sounds.play_reload_start()
	end
end

function Player.update_fire( dt )
	if Player.firing_timer>0 then
		Player.firing_timer = Player.firing_timer - dt
	end

	if Player.reload_timer > 0 then
		Player.reload_timer = Player.reload_timer - dt
		if Player.reload_timer <= 0 then
			-- reached 0: charge is done
			if Level.onebullet then
				Player.remaining_bullets = Player.remaining_bullets + Player.bullet_pocket
				Player.bullet_pocket = Player.remaining_bullets
				if Player.bullet_pocket > Player.total_bullets then
					Player.bullet_pocket = Player.total_bullets
				end
				Player.remaining_bullets = Player.remaining_bullets - Player.bullet_pocket
			else
				Player.bullet_pocket = Player.total_bullets
			end
			Sounds.play_reload_done()
		end
	end


	if Player.firing and Player.firing_timer<=0 then
		if Player.bullet_pocket > 0 and Player.reload_timer<=0 then
			-- new bullet
			local lpos = {Player.pos[1], Player.pos[2]}
			Bullets = Movement.newbullet_hero(lpos, {love.mouse.getX(), love.mouse.getY()})
			if Player.firing_rate>0 then
				Player.firing_timer = 1 / Player.firing_rate
			end

			Player.bullet_pocket = Player.bullet_pocket - 1

			Sounds.play_shot_player()

		else
			Player.start_reload()
		end

	end

end


function Player.start_firing()
	Player.firing = true
end

function Player.stop_firing()
	Player.firing = false
end

function Player.get_prediction()
	if Player.prediction_timer <= 0 then
		Player.prediction_short = Movement.get_prediction( Player, Player.prediction_short_dt )
		Player.prediction_timer = Player.prediction_delay*math.random()
	end
	return Player.prediction_short
end
