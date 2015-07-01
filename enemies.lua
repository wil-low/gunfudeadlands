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


EnemyAI = {}

-- ========================== UPDATE FUNCTIONS =================

function EnemyAI.update( dt )
	for i,enemy in ipairs(Level.enemies) do
		EnemyAI.update_state( dt, enemy )
		EnemyAI.update_move( dt, enemy )
		EnemyAI.update_timers( dt, enemy )
	end
end

function EnemyAI.update_state( dt, enemy )
	local former_state = enemy.state
	-- switch statement implemented as chain of ifs
	if enemy.state == 1 then
		EnemyAI.state_wandering( dt, enemy )
	elseif enemy.state == 2 then
		EnemyAI.state_alert( dt, enemy )
	elseif enemy.state == 3 then
		EnemyAI.state_engaging( dt, enemy )
	end
	-- state 0 is dead (ignore)
	enemy.former_state = former_state
end

function EnemyAI.update_move( dt, enemy )
--~   Movement.compute_predictions( enemy )
  Movement.update_character( dt, enemy )
end

function EnemyAI.update_timers( dt, enemy )

	-- shooting
	if enemy.shooting_timer > 0 then
		enemy.shooting_timer = enemy.shooting_timer - dt
	end

	-- walking straight
	if enemy.changedir_timer > 0 then
		enemy.changedir_timer = enemy.changedir_timer - dt
	end

	-- blocked while walking
	if enemy.blocked_timer > 0 then
		enemy.blocked_timer = enemy.blocked_timer - dt
	end

	-- wandering
	if enemy.wandering_timer > 0 then
		enemy.wandering_timer = enemy.wandering_timer - dt
	end

	-- dodging
	if enemy.dodging_timer > 0 then
		enemy.dodging_timer = enemy.dodging_timer - dt
	end

	-- dying
	if enemy.state == 0 and enemy.death_timer > 0 then
		enemy.death_timer = enemy.death_timer - dt
	end

	-- suspicion
	if enemy.suspicion_timer > 0 then
		enemy.suspicion_timer = enemy.suspicion_timer - dt
	end

	-- scare
	if enemy.scared_timer > 0 then
		enemy.scared_timer = enemy.scared_timer - dt
	end

	local accel = 1
	if BulletTime.active then
		accel = accel / BulletTime.slowdown_enemies
	end

	-- sight
	if enemy.see_player_timer > 0 then
		enemy.see_player_timer = enemy.see_player_timer - dt*accel
	end
	if enemy.ninja_see_player_timer > 0 then
		enemy.ninja_see_player_timer = enemy.ninja_see_player_timer - dt*accel
	end
	if enemy.see_bullet_timer > 0 then
		enemy.see_bullet_timer = enemy.see_bullet_timer - dt*accel
	end


	-- prediction
	if enemy.prediction_timer > 0 then
		enemy.prediction_timer = enemy.prediction_timer - dt*accel
	end


	-- aiming
	if enemy.target_dir[1]==0 and enemy.target_dir[2]==0 then
		enemy.target_dir={1,0}
	end
	if enemy.shoot_dir[1]==0 and enemy.shoot_dir[2]==0 then
		enemy.shoot_dir = {enemy.target_dir[1],enemy.target_dir[2]}
	else
		if Level.autoturns then
			enemy.shoot_dir = {enemy.target_dir[1],enemy.target_dir[2]}
		else
			local turn = mymath.get_angle( enemy.shoot_dir, enemy.target_dir )
			if math.abs(turn) > enemy.aiming_angular_velocity * dt then
				enemy.shoot_dir = mymath.rotate( enemy.shoot_dir, enemy.aiming_angular_velocity * dt * mymath.sign(turn) )
			else
				enemy.shoot_dir = {enemy.target_dir[1],enemy.target_dir[2]}
			end
		end
	end
end

-- ========================== END UPDATE FUNCTIONS =================

-- ========================== STATE MACHINE =================


function EnemyAI.state_wandering( dt, enemy )
	-- maybe change your mind
	if enemy.wandering_timer <= 0 then
		EnemyAI.choose_newpoint( enemy )
		enemy.wandering_timer = -math.log(1-math.random())*enemy.wandering_delay
	end

	local block_distance = 15

	
	-- steer
	if not EnemyAI.has_arrived( enemy ) then
		-- blocked? poingg!
		if math.abs(math.floor(enemy.pos[1]) - enemy.lastpos[1])<block_distance*dt and
			math.abs(math.floor(enemy.pos[2]) - enemy.lastpos[2]) < block_distance*dt then
			if enemy.blocked_timer <= 0 then
				enemy.dir = {-enemy.dir[1], -enemy.dir[2]}
				EnemyAI.choose_newpoint( enemy )
			end
		else
 		enemy.blocked_timer = enemy.blocked_delay
		end
	

		-- first make sure that the direction vector is normalized
		local dirmodsq = (enemy.dir[1]*enemy.dir[1] + enemy.dir[2]*enemy.dir[2])
		local destvector = mymath.get_dir_vector(enemy.pos[1], enemy.pos[2], enemy.destination[1], enemy.destination[2])
		if dirmodsq == 0 then
			enemy.dir = {destvector[1], destvector[2]}
		elseif dirmodsq ~= 1 then
			local dirmod = math.sqrt(dirmodsq)
			enemy.dir = {enemy.dir[1]/dirmod, enemy.dir[2]/dirmod}
		end

		-- check the angle
		local angle = mymath.get_angle(enemy.dir, destvector)
		if angle <= enemy.angular_velocity*dt then
			enemy.dir = destvector
		else
			local steer_matrix = mymath.get_rotation_matrix( enemy.angular_velocity*dt )
			local newdir = { enemy.dir[1] * steer_matrix[1] + enemy.dir[2] * steer_matrix[2] ,
							  enemy.dir[1] * steer_matrix[3] + enemy.dir[2] * steer_matrix[1] }
			enemy.dir = { newdir[1], newdir[2] }
		end


	else -- arrived: wait
		-- point to the open space

		EnemyAI.aim_openspace(enemy)

		if enemy.suspicion_timer>0 then
			EnemyAI.choose_onemorestep( enemy )
		else
			enemy.dir = {0,0}
		end

	end

	
	-- if wandering then point in the direction you are walking
	if enemy.dir[1]~=0 or enemy.dir[2]~=0 then
		enemy.target_dir = {enemy.dir[1], enemy.dir[2]}
	end

	-- unless you are suspicious, then be prepared
	if enemy.suspicion_timer > 0 then
		EnemyAI.aim_lastseen_player(enemy)
	end

	enemy.lastpos = {math.floor(enemy.pos[1]), math.floor(enemy.pos[2]) }

	-- state change: alarm
	if EnemyAI.see_bullet( enemy ) then
		enemy.state = 2
		enemy.destination = { enemy.last_seen_bullet[1], enemy.last_seen_bullet[2] }
	elseif EnemyAI.see_player( enemy ) then
		enemy.state = 3
	end

end


function EnemyAI.state_alert( dt, enemy )
	if enemy.former_state ~= enemy.state then
		-- when entering this state... if the distance is long, approach it
		-- if the distance was short, escape
		if mymath.get_distanceSq( enemy.pos, enemy.destination ) < location_range*location_range*4 then
			EnemyAI.choose_escape( enemy, enemy.destination )
			enemy.scared_timer = -math.log(1-math.random())*enemy.scared_delay
		end
	end

	EnemyAI.walk_straight( dt, enemy )

	enemy.suspicion_timer = enemy.suspicion_delay

	-- aim
	enemy.target_dir = { enemy.dir[1], enemy.dir[2] }

	if EnemyAI.see_player( enemy ) then
		enemy.state = 3
	-- if we get to the destination and still nothing has happened, then go idle
	elseif EnemyAI.has_arrived( enemy ) then
		if enemy.scared_timer <= 0 then
			enemy.state = 1
			enemy.dir = {0,0}
		else
			EnemyAI.choose_onemorestep( enemy )
		end
	end
end

function EnemyAI.state_engaging( dt, enemy )
	-- first entry
	if enemy.former_state ~= enemy.state then
		-- freeze
		enemy.dir = {0,0}
		enemy.destination = { enemy.pos[1], enemy.pos[2] }

		-- just to know where is the player now
		enemy.lastplayerpos = { Player.pos[1], Player.pos[2] }

		-- dodge if player infront of me
		local player_sight = mymath.get_angle( enemy.target_dir,
			mymath.get_dir_vector( enemy.pos[1], enemy.pos[2], Player.pos[1], Player.pos[2] ))/ math.pi
		enemy.dodging_timer = math.abs( enemy.initial_reaction_time * player_sight * player_sight )
	end

	enemy.suspicion_timer = enemy.suspicion_delay

	-- move around (don't be a static target) TIMEIT
	EnemyAI.walk_straight( dt, enemy )

	if enemy.dodging_timer <= 0 then
		enemy.dodging_timer = -math.log(1-math.random())*enemy.dodging_delay
		EnemyAI.choose_cover( enemy )
		enemy.dir = mymath.get_dir_vector( enemy.pos[1], enemy.pos[2], enemy.destination[1], enemy.destination[2] )
	end

	if  EnemyAI.has_arrived( enemy ) then
		EnemyAI.choose_onemorestep( enemy )
		enemy.dir = mymath.get_dir_vector( enemy.pos[1], enemy.pos[2], enemy.destination[1], enemy.destination[2] )
	end

	-- shoot the player
	if EnemyAI.see_player( enemy ) then
		enemy.lastplayerpos = { Player.pos[1], Player.pos[2] }
		EnemyAI.aim_player( enemy )
		EnemyAI.keep_shooting( dt, enemy )
	else
	-- if he disapears, pursue him
		enemy.state = 2 -- alert works exactly as pursue, only that the destination is the last player pos
		enemy.destination = { enemy.lastplayerpos[1], enemy.lastplayerpos[2] }
	end
end


-- ========================== END STATE MACHINE =================

-- ========================== HELPER FUNCTIONS =================

function EnemyAI.walk_straight( dt, enemy )
	-- first entry
	if enemy.former_state ~= enemy.state then
		enemy.changedir_timer = 0
	end

	-- just straight go
	if enemy.changedir_timer <= 0 then
		enemy.dir = mymath.get_dir_vector( enemy.pos[1], enemy.pos[2], enemy.destination[1], enemy.destination[2] )
		enemy.changedir_timer = enemy.changedir_delay
	end

	-- if blocked for a while, start wandering
	if math.floor(enemy.pos[1]) == enemy.lastpos[1] and math.floor(enemy.pos[2]) == enemy.lastpos[2] then
		enemy.blocked = enemy.blocked_timer < enemy.blocked_delay / 2
		if enemy.blocked_timer <= 0 then
			enemy.state = 1
			enemy.blocked = false
		end
	else
		enemy.blocked = false
		enemy.blocked_timer = enemy.blocked_delay
	end

	enemy.lastpos = {math.floor(enemy.pos[1]), math.floor(enemy.pos[2]) }
end

-- ================= CHOOSING DESTINATIONS

-- checks if the enemy can get there walking a straight line
function EnemyAI.check_walkable( enemy, newpoint )
	-- is it in the screen?
	local hl,hu = enemy.spritesize[1]/2, enemy.spritesize[2]/2
	
	if newpoint[1]-hl < 0 or newpoint[1]+hl > screensize[1] or
		newpoint[2]-hu < 0 or newpoint[2]+hu >screensize[2]
	then
		return false
	end

	-- can i get there?
	if enemy.free_box and mymath.check_pointinbox(newpoint, enemy.free_box) then
		return true
	end
	
	local l = enemy.collision_buildings
	while l do
		if mymath.check_segmentinbuilding({enemy.pos[1], enemy.pos[2], newpoint[1], newpoint[2]}, l.value) then
			enemy.collision_buildings = List.pushToFront(enemy.collision_buildings, l)
			return false
		end
		l = l.next
	end

	return true
end


function EnemyAI.choose_newpoint( enemy )
	local distance
	local mean_distance = 775

	for i=1,16 do
		distance = -math.log(1-math.random())*mean_distance
		local angle = math.random(16)/16 * 2 * math.pi
		local newpoint = { enemy.pos[1]+distance * math.cos(angle) , enemy.pos[2]+ distance * math.sin(angle) }

		if EnemyAI.check_walkable(enemy, newpoint) then
			enemy.destination = { newpoint[1], newpoint[2] }
 			return
		end
	end

end

function EnemyAI.choose_cover( enemy )
	local distance = 180
	local order=mymath.permutation(4)
	local myangle={60,120,240,300}
	local player_dir = mymath.get_dir_vector( Player.pos[1], Player.pos[2], enemy.pos[1], enemy.pos[2] )
	local candidate_dest = {}

	-- try progressively shorter distanc3es
	for j=1,4 do
		-- generate the points
		for i=1,4 do
			local angle = myangle[order[i]]*math.pi/180.0
			local candidate_dir = mymath.rotate(player_dir,angle)
			candidate_dest[i] = {enemy.pos[1]+candidate_dir[1]*distance, enemy.pos[2]+candidate_dir[2]*distance}
		end
		-- see if they cover
		for i=1,4 do
			if not EnemyAI.see_something( enemy, candidate_dest[i], Player) and
				EnemyAI.check_walkable( enemy, candidate_dest[i])
			then
				enemy.destination = { candidate_dest[i][1], candidate_dest[i][2] }
				return
			end
		end
		-- maybe they don't cover, but I can get there anyway
		for i=1,4 do
			if EnemyAI.check_walkable( enemy, candidate_dest[i]) then
				enemy.destination = { candidate_dest[i][1], candidate_dest[i][2] }
				return
			end
		end
		-- ok, so let's try half of that distance
		distance = distance/2
	end
end

function EnemyAI.choose_nearlocation( enemy )
	local order = mymath.permutation(8)

	for i=1,8 do
		local angle=(order[i]*45 + 22.5)*math.pi/180.0
		local distance = 75
		local candidate_dir = {math.cos(angle),math.sin(angle)}
		local candidate_dest = {enemy.pos[1]+candidate_dir[1]*distance, enemy.pos[2]+candidate_dir[2]*distance}
		if EnemyAI.check_walkable( enemy, candidate_dest)
		then
			enemy.destination = { candidate_dest[1], candidate_dest[2] }
			return
		end
	end
end

function EnemyAI.choose_onemorestep( enemy )
	local order = mymath.permutation(4)

	if enemy.dir[1]==0 and enemy.dir[2]==0 then
		return
	end

	for i=1,4 do
		local angle=(order[i]*45 - 112.5)*math.pi/180.0
		local distance = 85
		local candidate_dir = mymath.rotate(enemy.dir,angle)
		local candidate_dest = {enemy.pos[1]+candidate_dir[1]*distance , enemy.pos[2]+candidate_dir[2]*distance }
		if EnemyAI.check_walkable( enemy, candidate_dest)
		then
			enemy.destination = { candidate_dest[1], candidate_dest[2] }
			return
		end
	end
end

function EnemyAI.choose_escape( enemy, from )
	enemy.dir = mymath.get_dir_vector( from[1], from[2], enemy.pos[1], enemy.pos[2] )
	EnemyAI.choose_onemorestep( enemy )
end

-- =============== MOVEMENT
function EnemyAI.has_arrived( enemy )
	if mymath.get_distanceSq( enemy.pos, enemy.destination ) < location_range*location_range then
		return true
	end
	return false
end

-- =============== PERCEPTION

function EnemyAI.see_player( enemy )
	if not Player.alive and Player.death_timer <= 0 then
		return false
	end

	if enemy.see_player_timer <= 0 then
		enemy.player_was_seen = EnemyAI.see_something( enemy, Player.pos )
		enemy.see_player_timer = enemy.see_delay*math.random()
	end
	return enemy.player_was_seen

end

function EnemyAI.see_something( enemy, where )
	-- too far
	if mymath.get_distanceSq( where, enemy.pos ) > enemy.sight_dist*enemy.sight_dist then
		return false
	end

	if List.count(enemy.sight_buildings) == 0 then
		return true
	end
	
	if enemy.free_box and mymath.check_pointinbox(where, enemy.free_box) then
		return true
	end

	-- direct line of sight?
	local l = enemy.sight_buildings
	while l do
		if mymath.check_segmentinbuilding({where[1], where[2], enemy.pos[1], enemy.pos[2]}, l.value) then
			enemy.sight_buildings = List.pushToFront(enemy.sight_buildings, l)
			return false
		end
		l = l.next
	end
	
	return true
end

function EnemyAI.see_bullet( enemy )

	if enemy.see_bullet_timer <= 0 then
		enemy.bullet_was_seen = EnemyAI.compute_see_bullet( enemy )
		enemy.see_bullet_timer = enemy.bullet_see_delay*math.random()
	end
	return enemy.bullet_was_seen

end

function EnemyAI.compute_see_bullet( enemy )
	local l = Bullets
	while l do
		if l.value then
			if EnemyAI.see_something( enemy, l.value.pos ) then
				enemy.last_seen_bullet = { l.value.pos[1], l.value.pos[2] }
				return true
			end
		end
		l = l.next
	end
	return false
end

function EnemyAI.ninja_see_player_short( enemy )
	if enemy.ninja_see_player_timer <= 0 then
		enemy.ninja_player_was_seen = EnemyAI.compute_ninja_see_player_short( enemy )
		enemy.ninja_see_player_timer = enemy.see_delay*math.random()
	end
	return enemy.ninja_player_was_seen
end

function EnemyAI.compute_ninja_see_player_short( enemy )
	if EnemyAI.see_player( enemy ) then
		return true
	end

	local prediction_player = Player.get_prediction()
	local prediction_enemy = EnemyAI.get_prediction( enemy )

	-- future
	for i,building in ipairs(Level.buildings) do
		if building.solid==1 and
			mymath.check_segmentinbuilding(
				{prediction_player[1], prediction_player[2], prediction_enemy[1], prediction_enemy[2]}, building)

		then
			return false
		end
	end

	return true
end

function EnemyAI.aim_openspace(enemy)
	-- first check if the current direction is open
	local distance = 70
	local view_pos = { enemy.pos[1]+enemy.target_dir[1]*distance, enemy.pos[2]+enemy.target_dir[2]*distance }

	if EnemyAI.see_something( enemy, view_pos )
	then
		-- it's ok
		return
	end

	-- choose one from the 8 possible directions
	local check_order = mymath.permutation(8)
	for i=1,8 do
		view_pos = { enemy.pos[1]+math.cos(math.pi/4*check_order[i])*distance,
			enemy.pos[2]+math.sin(math.pi/4*check_order[i])*distance }
		if EnemyAI.see_something( enemy, view_pos )
		then
			enemy.target_dir = { math.cos(math.pi/4*i), math.sin(math.pi/4*i) }
			return
		end
	end

	-- still here? well, this means I am trapped and there is nothing to see...
	return
end

function EnemyAI.aim_player( enemy )
	local direction = mymath.get_dir_vector( enemy.pos[1], enemy.pos[2], Player.pos[1], Player.pos[2] )
	enemy.target_dir = {direction[1],direction[2]}
end

function EnemyAI.aim_lastseen_player( enemy )
	local direction = mymath.get_dir_vector( enemy.pos[1], enemy.pos[2], enemy.lastplayerpos[1], enemy.lastplayerpos[2] )
	enemy.target_dir = {direction[1],direction[2]}
end

function EnemyAI.get_prediction( enemy )
	if enemy.prediction_timer <= 0 then
		enemy.prediction_short = Movement.get_prediction( enemy, enemy.prediction_short_dt )
		enemy.prediction_timer = enemy.prediction_delay*math.random()
	end
	return enemy.prediction_short
end

-- ================== SHOOT
function EnemyAI.keep_shooting( dt, enemy )
	if enemy.shooting_timer <= 0 then
		if math.abs(mymath.get_angle(enemy.shoot_dir, enemy.target_dir)) > enemy.acceptable_arc then
			return
		end

		enemy.shoot_dir = mymath.disturb_vector(enemy.shoot_dir, enemy.accuracy)

		-- mode 1: 1 single bullet ( single gun )
		if enemy.firingmode == 1 then

			Bullets = Movement.newbullet_enemy( enemy.pos, enemy.shoot_dir)

		-- mode 2: 2 bullets ( dual gun, alternating )
		elseif enemy.firingmode == 2 then
			local bpos = {enemy.pos[1] + enemy.spritesize[1]/2, enemy.pos[2]}
			if enemy.alternatefire then
				bpos[1] = enemy.pos[1] - enemy.spritesize[1]/2
			end
			enemy.alternatefire = not enemy.alternatefire

			Bullets = Movement.newbullet_enemy( bpos, enemy.shoot_dir)

		-- mode 3: 3 bullets ( shotgun )
		elseif enemy.firingmode == 3 then
			local destup = mymath.rotate(enemy.shoot_dir, enemy.shotgun_arc*2*math.pi/360)
			local destdn = mymath.rotate(enemy.shoot_dir, -enemy.shotgun_arc*2*math.pi/360)

			Bullets = Movement.newbullet_enemy( enemy.pos, enemy.shoot_dir)
			Bullets = Movement.newbullet_enemy( enemy.pos, destup)
			Bullets = Movement.newbullet_enemy( enemy.pos, destdn)
		end

		enemy.shooting_timer = enemy.shooting_delay
		Sounds.play_shot_enemy( enemy )
	end
end

-- ========================== END HELPER FUNCTIONS =================

function EnemyAI.load_buildingLists()
	for i,e in ipairs(Level.enemies) do
		e.collision_buildings = List.fromArray( Level.buildings )
		e.collision_buildings = List.applydel( e.collision_buildings, function(b) return b.solid<=3 end)
		e.sight_buildings = List.fromArray( Level.buildings )
		e.sight_buildings = List.applydel( e.sight_buildings, function(b) return b.solid == 1 end)
	end
end
