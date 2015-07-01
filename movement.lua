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

Movement = {}



function Movement.update_character( dt, who )
  -- just for convenience, move to the upperleft corner now, and back to the center at the end
  if who.dir[1]==0 and who.dir[2]==0 then
	return
  end

  local newpos = {
	who.pos[1] + who.dir[1] * dt * who.speed,
	who.pos[2] + who.dir[2] * dt * who.speed
	}


  local hl,hr,hu,hd = mymath.round(who.spritesize[1]/2-who.collisionbox[1]),
	  mymath.round(who.spritesize[1]/2-(who.spritesize[1]-who.collisionbox[3])),
	  mymath.round(who.spritesize[2]/2-who.collisionbox[2]),
	  mymath.round(who.spritesize[2]/2-(who.spritesize[2]-who.collisionbox[4]))

  if not Game.smallcollision then
	hl = who.spritesize[1]/2
	hr = who.spritesize[1]/2
	hu = who.spritesize[2]/2
	hd = who.spritesize[2]/2
  end

  if newpos[1]<=hl then
    newpos[1]= hl
	who.dir[1]=0
  end

  if newpos[1]>=screensize[1]-hr then
    newpos[1]=screensize[1]-hr
	who.dir[1]=0
  end

  if newpos[2]<=hu then
    newpos[2]=hu
	who.dir[2]=0
  end

  if newpos[2]>=screensize[2]-hd then
    newpos[2]=screensize[2]-hd
	who.dir[2]=0
  end

  newpos = Movement.check_building_collision(who, newpos, {hl, hr, hu, hd})

  who.pos[1] = newpos[1]
  who.pos[2] = newpos[2]

end

function Movement.check_building_collision(who, newpos, box)
	local collided = false
	local hl, hr, hu, hd = box[1],box[2],box[3],box[4]
	local containerbox = {newpos[1]-hl, newpos[2]-hu, newpos[1]+hr, newpos[2]+hd}
	
	-- first check if I'm in the freebox
	if who.free_box and mymath.check_boxinbox(containerbox, who.free_box) then
		return newpos
	end
		
	-- actual collision check
	local l = who.collision_buildings
	while l do
		local building = l.value
		if (mymath.check_boxinbuilding(containerbox, building ) or
			mymath.check_segmentinbuilding({who.pos[1],who.pos[2],newpos[1],newpos[2]}, building) )
		then
			collided = true
			local dpos = {who.pos[1],who.pos[2]}
			
			-- if we keep moving horizontally, is the new position valid?
			if not mymath.check_boxinbuilding({newpos[1]-hl, who.pos[2]-hu, newpos[1]+hr, who.pos[2]+hd}, building ) and
				not mymath.check_segmentinbuilding({who.pos[1],who.pos[2],newpos[1],who.pos[2]}, building)
			then
				-- if so, allow it
				dpos[1] = newpos[1]
			end

			-- if we keep moving vertically, is the new position valid?
			if not mymath.check_boxinbuilding(	{who.pos[1]-hl, newpos[2]-hu, who.pos[1]+hr, newpos[2]+hd}, building ) and
				not mymath.check_segmentinbuilding({who.pos[1],who.pos[2],who.pos[1],newpos[2]}, building)
			then
					-- if so, allow it
					dpos[2] = newpos[2]
			end

			newpos = {dpos[1],dpos[2]}
		
			-- push to front and advance
			local nextOne = l.next
			who.collision_buildings = List.pushToFront(who.collision_buildings, l)
			l = nextOne
			
			if who.pos[1] == newpos[1] and who.pos[2] == newpos[2] then 
				return newpos 
			else
				containerbox = {newpos[1]-hl, newpos[2]-hu, newpos[1]+hr, newpos[2]+hd}
			end
		else
			l = l.next
		end
	end
	
	if not collided then
		-- we were out of the free box but we haven't collided: get new free box!
		local collisionpoint = Movement.get_closest_collision_point( newpos, who.collision_buildings )
		-- create a square around the center, with one of its vertexs being the collisionpoint
		local lhalf = math.max( math.abs( collisionpoint[1] - newpos[1] ), math.abs(collisionpoint[2] - newpos[2] ) )
		who.free_box = { newpos[1] - lhalf, newpos[2] - lhalf, newpos[1] + lhalf, newpos[2] + lhalf }
	end

      return newpos
end

function Movement.get_closest_collision_point ( point, buildinglist )
	
	if List.count(buildinglist) == 0 then
		-- superbig!
		return {-screensize[1], -screensize[2] }
	end
	
	-- arbitrary upper bound
	local distance = screensize[1]*screensize[1] + screensize[2]*screensize[2]
	local result
	
	local l = buildinglist
	while l do
		for i,colli in ipairs(l.value.collision) do
			local arr = mymath.distanceSq_to_box( point, colli )
			if arr[1] < distance then
				distance = arr[1]
				result = {arr[2], arr[3] }
			end
		end
		l = l.next
	end
	
	return result
end

function Movement.get_prediction( who, dt )

	-- assume that the player did not stop
	if who.dir[1]~=0 or who.dir[2]~=0 then
		who.dir_prediction = { who.dir[1], who.dir[2] }
	end

	-- prediction: if the character walks straight ahead X time, where will he be?
	local prediction = {
		who.pos[1] + who.dir_prediction[1] * dt * who.speed,
		who.pos[2] + who.dir_prediction[2] * dt * who.speed
	}

	local hl,hr,hu,hd = mymath.round(who.spritesize[1]/2-who.collisionbox[1]),
	  mymath.round(who.spritesize[1]/2-(who.spritesize[1]-who.collisionbox[3])),
	  mymath.round(who.spritesize[2]/2-who.collisionbox[2]),
	  mymath.round(who.spritesize[2]/2-(who.spritesize[2]-who.collisionbox[4]))

  if not Game.smallcollision then
	hl = who.spritesize[1]/2
	hr = who.spritesize[1]/2
	hu = who.spritesize[2]/2
	hd = who.spritesize[2]/2
  end

  if prediction[1]<=hl then
    prediction[1]= hl
  end

  if prediction[1]>=screensize[1]-hr then
    prediction[1]=screensize[1]-hr
  end

  if prediction[2]<=hu then
    prediction[2]=hu
  end

  if prediction[2]>=screensize[2]-hd then
    prediction[2]=screensize[2]-hd
  end

	-- if the prediction crosses a wall it is not valid
	for i,building in ipairs(Level.buildings) do
		if (building.solid==1 or building.solid==2 or
			(building.solid==3 and not who.isplayer)) and
			mymath.check_segmentinbuilding({who.pos[1], who.pos[2], prediction[1], prediction[2]}, building) or
			mymath.check_boxinbuilding({prediction[1]-hl, prediction[2]-hu, prediction[1]+hr, prediction[2]+hd}, building )
		then
			prediction = {who.pos[1],who.pos[2]}
			return prediction
		end
	end

	return prediction
end


function Movement.teleport( thing )
-- make a thing disappear by teleporting it far outside of the screen
	thing.pos = { 10000, 10000 }
	thing.dir = { 0,0 }

end

-- ======================== BULLETS!

function Movement.newbullet_hero( from, to )
	return List.push(Bullets, {
			pos = {from[1], from[2]},
			dir = mymath.get_dir_vector( from[1], from[2], to[1], to[2] ),
			good = true, -- "true" for player fire, "false" for enemy fire
			speed = 1000, -- or whatever
			})
end

function Movement.newbullet_enemy( from, direction )
	if not Level.enemiescanshoot then
		return Bullets
	end

	return List.push(Bullets, {
			pos = {from[1], from[2]},
			dir = {direction[1],direction[2]},
			good = false, -- "true" for player fire, "false" for enemy fire
			speed = 1000, -- or whatever
			})
end

function Movement.newbullet_enemy_( from, to, deviation )
	local direction = mymath.get_dir_vector( from[1], from[2], to[1], to[2] )
	local normal_dist = mymath.randn2()
	direction = {direction[1] + normal_dist[1] * deviation, direction[2] + normal_dist[2] * deviation }
	-- force normalization again
	direction = mymath.get_dir_vector( 0, 0, direction[1], direction[2] )

	return List.push(Bullets, {
			pos = {from[1], from[2]},
			dir = direction,
			good = false, -- "true" for player fire, "false" for enemy fire
			speed = 1000, -- or whatever
			})
end

function Movement.newbullet_enemy_displaced( from, to, deviation, displacement_angle )
	local direction = mymath.get_dir_vector( from[1], from[2], to[1], to[2] )
	local normal_dist = mymath.randn2()
	direction = {direction[1] + normal_dist[1] * deviation, direction[2] + normal_dist[2] * deviation }
	-- force normalization again
	direction = mymath.get_dir_vector( 0, 0, direction[1], direction[2] )

	displacement_matrix = mymath.get_rotation_matrix( displacement_angle )
	direction = {direction[1]*displacement_matrix[1]+direction[2]*displacement_matrix[2],
		direction[1]*displacement_matrix[3]+direction[2]*displacement_matrix[4]}

	return List.push(Bullets, {
			pos = {from[1], from[2]},
			dir = direction,
			good = false, -- "true" for player fire, "false" for enemy fire
			speed = 1000, -- or whatever
			})
end

function Movement.update_bullets( dt )

	List.applydel( Bullets, Movement.update_singlebullet, dt )
	-- for each bullet, update position
end

function Movement.update_singlebullet( bullet, dt )
	local formerpos = {bullet.pos[1], bullet.pos[2]}
	bullet.pos[1] = bullet.pos[1] + bullet.dir[1] * dt * bullet.speed
	bullet.pos[2] = bullet.pos[2] + bullet.dir[2] * dt * bullet.speed

	if bullet.pos[1]<0 or bullet.pos[1]>screensize[1] or
	    bullet.pos[2]<0 or bullet.pos[2]>screensize[2] then
		Movement.teleport( bullet )
		return false
	end

	local bullet_trajectory = { formerpos[1], formerpos[2], bullet.pos[1], bullet.pos[2]}

	--  ********* hit a building?
	for i,building in ipairs(Level.buildings) do
		if building.solid==1 and mymath.check_segmentinbuilding( bullet_trajectory, building)
			then
				Movement.teleport( bullet )
				return false
		end
	end

	--- hit an enemy?
	if bullet.good then
		for i,enemy in ipairs(Level.enemies) do
			if enemy.state ~= 0 and
				mymath.check_intersection(bullet_trajectory,
				{enemy.pos[1]-enemy.spritesize[1]/2, enemy.pos[2]-enemy.spritesize[2]/2,
				enemy.pos[1]+enemy.spritesize[1]/2, enemy.pos[2]+enemy.spritesize[2]/2, } )
			then
				Level.enemy_dies( enemy, { bullet.dir[1], bullet.dir[2] } )

				--Movement.teleport( enemy )
				Movement.teleport( bullet )
				return false
			end
		end
	end

	-- hit me?

	if not bullet.good and mymath.check_intersection( bullet_trajectory,
		{Player.pos[1]-Player.spritesize[1]/2, Player.pos[2]-Player.spritesize[2]/2,
		Player.pos[1]+Player.spritesize[1]/2, Player.pos[2]+Player.spritesize[2]/2, } )
		then
			Level.player_dies( { bullet.dir[1], bullet.dir[2] } )
			return false
		end
	return true
end

