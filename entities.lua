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

Entities = {}

function Entities.add_element( index, point, length )
	if index==1 then Entities.new_player( point[1], point[2] )
	elseif index>1 and index<6 then
		table.insert( Level.enemies, Entities.new_element( index, point ) )
	else
		table.insert(Level.buildings, Entities.new_element( index, point, length ) )
	end
end

Entities.entitylist = {
	player			= 1,
	blue_bandit		= 2,
	red_bandit		= 3,
	green_bandit	= 4,
	yellow_bandit	= 5,
	saloon			= 6,
	sheriff_box		= 7,
	church			= 8,
	bank			= 9,
	mansion			= 10,
	house			= 11,
	warehouse		= 12,
	barber			= 13,
	generic_house 	= 14,
	smith 			= 15,
	stable 			= 16,
	tiny_house 		= 17,
	barrel			= 18,
	crate 			= 19,
	well			= 20,
	pile			= 21,
	herb			= 22,
	cactus			= 23,
	bush			= 24,
	mill			= 25,
	dead_branch		= 26,
	dead_tree		= 27,
	barrier_horiz	= 28,
	barrier_vert	= 29,
	fence_horiz		= 30,
	fence_vert		= 31,
}
Entities.entitystrings = {
	"player",
	"blue_bandit",
	"red_bandit",
	"green_bandit",
	"yellow_bandit",
	"saloon",
	"sheriff_box",
	"church",
	"bank",
	"mansion",
	"house",
	"warehouse",
	"barber",
	"generic_house",
	"smith",
	"stable",
	"tiny_house",
	"barrel",
	"crate",
	"well",
	"pile",
	"herb",
	"cactus",
	"bush",
	"mill",
	"dead_branch",
	"dead_tree",
	"barrier_horiz",
	"barrier_vert",
	"fence_horiz",
	"fence_vert",
}

function Entities.getidfromstring( str )
	for i,v in ipairs(Entities.entitystrings) do
		if str==v then
			return i
		end
	end
	-- not found
	return -1
end

function Entities.hasalength( id )
	if id==Entities.entitylist.barrier_horiz or
		id==Entities.entitylist.barrier_vert or
		id==Entities.entitylist.fence_horiz or
		id==Entities.entitylist.fence_vert then
		return true
	end
	return false
end

function Entities.new_element( index, point, length )
	if not length then length = 1 end
	if not point then point = {0,0} end

	if index == Entities.entitylist.player then return Entities.new_player(point[1],point[2])
	elseif index==Entities.entitylist.blue_bandit then return Entities.new_blue_bandit(point[1],point[2])
	elseif index==Entities.entitylist.red_bandit then return Entities.new_red_bandit( point[1],point[2] )
	elseif index==Entities.entitylist.green_bandit then return Entities.new_green_bandit( point[1],point[2] )
	elseif index==Entities.entitylist.yellow_bandit then return Entities.new_yellow_bandit( point[1],point[2] )
	elseif index==Entities.entitylist.saloon then return Entities.new_saloon( point[1],point[2] )
	elseif index==Entities.entitylist.sheriff_box then return Entities.new_sheriff_box(point[1],point[2])
	elseif index==Entities.entitylist.church then return Entities.new_church(point[1],point[2])
	elseif index==Entities.entitylist.bank then return Entities.new_bank(point[1],point[2])
	elseif index==Entities.entitylist.mansion then return Entities.new_mansion(point[1],point[2])
	elseif index==Entities.entitylist.house then return Entities.new_house(point[1],point[2])
	elseif index==Entities.entitylist.warehouse then return Entities.new_warehouse(point[1],point[2])
	elseif index==Entities.entitylist.barrel then return Entities.new_barrel(point[1],point[2])
	elseif index==Entities.entitylist.dead_branch then return Entities.new_dead_branch(point[1],point[2])
	elseif index==Entities.entitylist.dead_tree then return Entities.new_dead_tree(point[1],point[2])
	elseif index==Entities.entitylist.herb then return Entities.new_herb(point[1],point[2])
	elseif index==Entities.entitylist.cactus then return Entities.new_cactus(point[1],point[2])
	elseif index==Entities.entitylist.bush then return Entities.new_bush(point[1],point[2])
	elseif index==Entities.entitylist.mill then return Entities.new_mill(point[1],point[2])
	elseif index==Entities.entitylist.crate then return Entities.new_crate(point[1],point[2])
	elseif index==Entities.entitylist.barber then return Entities.new_barber(point[1],point[2])
	elseif index==Entities.entitylist.generic_house then return Entities.new_generic_house(point[1],point[2])
	elseif index==Entities.entitylist.smith then return Entities.new_smith(point[1],point[2])
	elseif index==Entities.entitylist.stable then return Entities.new_stable(point[1],point[2])
	elseif index==Entities.entitylist.tiny_house then return Entities.new_tiny_house(point[1],point[2])
	elseif index==Entities.entitylist.pile then return Entities.new_pile(point[1],point[2])
	elseif index==Entities.entitylist.well then return Entities.new_well(point[1],point[2])
	elseif index==Entities.entitylist.barrier_horiz then return Entities.new_barrier_horiz(point[1],point[2], length)
	elseif index==Entities.entitylist.barrier_vert then return Entities.new_barrier_vert(point[1],point[2], length)
	elseif index==Entities.entitylist.fence_horiz then return Entities.new_fence_horiz(point[1],point[2], length)
	elseif index==Entities.entitylist.fence_vert then return Entities.new_fence_vert(point[1],point[2], length)
	end
end

function Entities.new_player(px, py)

	Player.id = Entities.entitylist.player
	Player.sprite = Graphics.images.guy_standing

	Player.alive = true

	Player.pos = {px,py}
	Player.starting_pos = {px,py}
	Player.dir = {0,0}
	Player.key_dir = {0,0}
	Player.speed = 200
	Player.speed_walking = 200
	Player.speed_jumping = 300 -- so it gives you an advantage
	Player.spritesize={Graphics.images.guy_standing:getWidth(),Graphics.images.guy_standing:getHeight()}
	Player.collisionbox = {5,1,12,20}

	Player.prediction_short = {px,py}
	Player.dir_prediction = { 0, 0 }
	Player.prediction_short_dt = 0.05
	Player.prediction_timer = 0
	Player.prediction_delay = 0.25 -- 250ms

	Player.firing = false
	Player.firing_rate = 5  -- shots per second
	Player.firing_timer = 0 -- timer until next shot

	Player.jumping = false
	Player.readytojump = true
	Player.spinning_dir = {0,0}
	Player.jump_timer = 0

	Player.isplayer = true

	Player.total_bullets = 6
	Player.bullet_pocket = Player.total_bullets
	Player.bullet_loadingdelay = 0.9 -- seconds
	Player.reload_timer = 0

	Player.eyesight = 350

	Player.isbuilding = false



	BulletTime.init()

	return nil
end

-- building type (building.solid):
-- 1- solid - no one can cross it
-- 2- semisolid - only bullets can cross it
-- 3- semitransparent - bullets and player can cross it
-- 4- transparent (ceilings) - bullets, player and enemies can cross it
-- 5- transparent (floors) - again, anyone can cross it, but it's rendered under the characters

-- game objects
function Entities.new_saloon( px, py )
	-- adds a "saloon" building at px, py
	return	{
			id = Entities.entitylist.saloon,
			sprite = Graphics.images.saloon,
			spritesize = {Graphics.images.saloon:getWidth(), Graphics.images.saloon:getHeight()},
			pos = {px, py},
			solid = 1,
			collision = { { px-60, py-45, px+59, py+44 } , },
			isbuilding = true,
		}

end

function Entities.new_sheriff_box(px, py)
	return {
			id = Entities.entitylist.sheriff_box,
			sprite = Graphics.images.sheriff_box,
			spritesize = {Graphics.images.sheriff_box:getWidth(), Graphics.images.sheriff_box:getHeight()},
			pos = {px, py},
			solid = 1,
			collision = {
				{ px-47, py-30, px+46, py+29 },
				 },
			isbuilding = true,
		}
end

function Entities.new_church(px,py)
	return {
			id = Entities.entitylist.church,
			sprite = Graphics.images.church,
			spritesize = {Graphics.images.church:getWidth(), Graphics.images.church:getHeight()},
			pos = {px, py},
			solid = 1,
			collision = {
				{ px-22, py-18, px+21, py+49 },
				{ px-7, py-42, px+6, py },
				},
			isbuilding = true,
		}

end

function Entities.new_bank(px,py)
	return {
			id = Entities.entitylist.bank,
			sprite = Graphics.images.bank,
			spritesize = {Graphics.images.bank:getWidth(), Graphics.images.bank:getHeight()},
			pos = {px, py},
			solid = 1,
			collision = { { px-61, py-31, px+60, py+31 } },
			isbuilding = true,
		}
end

function Entities.new_mansion(px,py)
	return {
			id = Entities.entitylist.mansion,
			sprite = Graphics.images.mansion,
			spritesize = {Graphics.images.mansion:getWidth(), Graphics.images.mansion:getHeight()},
			pos = {px, py},
			solid = 1,
			collision = { { px-60, py-45, px+59, py+45 } },
			isbuilding = true,
		}
end

function Entities.new_house(px,py)
	return {
			id = Entities.entitylist.house,
			sprite = Graphics.images.house,
			spritesize = {Graphics.images.house:getWidth(), Graphics.images.house:getHeight()},
			pos = {px, py},
			solid = 1,
			collision = { { px-30, py-30, px+29, py+30 } , },
			isbuilding = true,
		}
end

function Entities.new_warehouse(px,py)
	return {
			id = Entities.entitylist.warehouse,
			sprite = Graphics.images.warehouse,
			spritesize = {Graphics.images.warehouse:getWidth(), Graphics.images.warehouse:getHeight()},
			pos = {px, py},
			solid = 1,
			collision = { { px-27, py-58, px+27, py+58 } , },
			isbuilding = true,
		}
end

function Entities.new_barrel(px,py)
	return {
			id = Entities.entitylist.barrel,
			sprite = Graphics.images.barrel,
			spritesize = {Graphics.images.barrel:getWidth(), Graphics.images.barrel:getHeight()},
			pos = {px, py},
			solid = 1,
			collision = { { px-6, py-9, px+5, py+8 } },
			isbuilding = true,
		}
end

function Entities.new_barrier_horiz(px,py, len)
	return {
			id = Entities.entitylist.barrier_horiz,
			sprite = Graphics.images.barrier_horiz,
			spritesize = {Graphics.images.barrier_horiz:getWidth(), Graphics.images.barrier_horiz:getHeight()},
			pos = {px, py},
			len = {1, len, 31},
			solid = 1,
			collision = { { px-math.floor(31*len/2), py-12, px+math.floor(31*len/2), py+12 } },
			isbuilding = true,
		}
end

function Entities.new_barrier_vert(px,py, len)
	return {
			id = Entities.entitylist.barrier_vert,
			sprite = Graphics.images.barrier_vert,
			spritesize = {Graphics.images.barrier_vert:getWidth(), Graphics.images.barrier_vert:getHeight()},
			pos = {px, py},
			len = {2, len, 32},
			solid = 1,
			collision = { { px-3, py-math.floor(32*len/2), px+3, py+math.floor(32*len/2) } },
			isbuilding = true,
		}
end

function Entities.new_dead_branch(px, py)
	return {
			id = Entities.entitylist.dead_branch,
			sprite = Graphics.images.dead_branch,
			spritesize = {Graphics.images.dead_branch:getWidth(), Graphics.images.dead_branch:getHeight()},
			pos = {px, py},
			solid = 1,
			collision = { { px+1, py+1, px+17, py+23 } },
			isbuilding = true,
		}
end

function Entities.new_dead_tree(px, py)
	return {
			id = Entities.entitylist.dead_tree,
			sprite = Graphics.images.dead_tree,
			spritesize = {Graphics.images.dead_tree:getWidth(), Graphics.images.dead_tree:getHeight()},
			pos = {px, py},
			solid = 1,
			collision = {  { px-13, py+23, px-2, py+50 } },
			isbuilding = true,
		}
end

function Entities.new_fence_horiz(px, py, len)
	return {
			id = Entities.entitylist.fence_horiz,
			sprite = Graphics.images.fence_horiz,
			spritesize = {Graphics.images.fence_horiz:getWidth(), Graphics.images.fence_horiz:getHeight()},
			pos = {px, py},
			len = {1, len, 14},
			solid = 2,
			collision = { { px-math.floor(14*len/2), py-7, px+math.floor(14*len/2), py+7 }  },
			isbuilding = true,
		}
end

function Entities.new_fence_vert(px, py, len)

	return {
			id = Entities.entitylist.fence_vert,
			sprite = Graphics.images.fence_vert,
			spritesize = {Graphics.images.fence_vert:getWidth(), Graphics.images.fence_vert:getHeight()},
			pos = {px, py},
			len = {2, len, 18},
			solid = 2,
			collision = {  { px-2, py-math.floor(18*len/2), px, py+math.floor(18*len/2) }  },
			isbuilding = true,
		}
end

function Entities.new_herb(px, py)
	return {
			id = Entities.entitylist.herb,
			sprite = Graphics.images.herb,
			spritesize = {Graphics.images.herb:getWidth(), Graphics.images.herb:getHeight()},
			solid = 5,
			pos = {px, py},
			collision = {},
			isbuilding = true,
		}
end

function Entities.new_mill(px, py)
	return {
			id = Entities.entitylist.mill,
			sprite = Graphics.images.mill,
			spritesize = {Graphics.images.mill:getWidth(), Graphics.images.mill:getHeight()},
			solid = 4,
			pos = {px, py},
			collision = {},
			isbuilding = true,
		}

end

function Entities.new_crate(px, py)
	return	{
			id = Entities.entitylist.crate,
			sprite = Graphics.images.crate,
			spritesize = {Graphics.images.crate:getWidth(), Graphics.images.crate:getHeight()},
			pos = {px, py},
			solid = 1,
			collision = { { px-7, py-9, px+7, py+9 } , },
			isbuilding = true,
		}
end

function Entities.new_generic_house(px, py)
	return	{
			id = Entities.entitylist.generic_house,
			sprite = Graphics.images.generic_house,
			spritesize = {Graphics.images.generic_house:getWidth(), Graphics.images.generic_house:getHeight()},
			pos = {px, py},
			solid = 1,
			collision = { { px-64, py-34, px+64, py+34 } , },
			isbuilding = true,
		}
end

function Entities.new_smith(px, py)
	return	{
			id = Entities.entitylist.smith,
			sprite = Graphics.images.smith,
			spritesize = {Graphics.images.smith:getWidth(), Graphics.images.smith:getHeight()},
			pos = {px, py},
			solid = 1,
			collision = { { px-53, py-39, px+53, py+39 } , },
			isbuilding = true,
		}
end

function Entities.new_barber(px, py)
	return	{
			id = Entities.entitylist.barber,
			sprite = Graphics.images.barber,
			spritesize = {Graphics.images.barber:getWidth(), Graphics.images.barber:getHeight()},
			pos = {px, py},
			solid = 1,
			collision = { { px-48, py-28, px+48, py+28 } , },
			isbuilding = true,
		}
end

function Entities.new_stable(px, py)
	return	{
			id = Entities.entitylist.stable,
			sprite = Graphics.images.stable,
			spritesize = {Graphics.images.stable:getWidth(), Graphics.images.stable:getHeight()},
			pos = {px, py},
			solid = 1,
			collision = { { px-25, py-100, px+25, py+100 } , },
			isbuilding = true,
		}
end

function Entities.new_pile(px, py)
	return	{
			id = Entities.entitylist.pile,
			sprite = Graphics.images.pile,
			spritesize = {Graphics.images.pile:getWidth(), Graphics.images.pile:getHeight()},
			pos = {px, py},
			solid = 1,
			collision = { { px-29, py-12, px+28, py+13 } , },
			isbuilding = true,
		}
end

function Entities.new_well(px, py)
	return	{
			id = Entities.entitylist.well,
			sprite = Graphics.images.well,
			spritesize = {Graphics.images.well:getWidth(), Graphics.images.well:getHeight()},
			pos = {px, py},
			solid = 1,
			collision = { { px-9, py-16, px+9, py+16 } , },
			isbuilding = true,
		}
end

function Entities.new_tiny_house(px, py)
	return	{
			id = Entities.entitylist.tiny_house,
			sprite = Graphics.images.tiny_house,
			spritesize = {Graphics.images.tiny_house:getWidth(), Graphics.images.tiny_house:getHeight()},
			pos = {px, py},
			solid = 1,
			collision = { { px-30, py-30, px+30, py+30 } , },
			isbuilding = true,
		}
end

function Entities.new_cactus(px, py)
	return {
			id = Entities.entitylist.cactus,
			sprite = Graphics.images.cactus,
			spritesize = {Graphics.images.cactus:getWidth(), Graphics.images.cactus:getHeight()},
			solid = 5,
			pos = {px, py},
			collision = {},
			isbuilding = true,
		}
end

function Entities.new_bush(px, py)
	return {
			id = Entities.entitylist.bush,
			sprite = Graphics.images.bush,
			spritesize = {Graphics.images.bush:getWidth(), Graphics.images.bush:getHeight()},
			pos = {px, py},
			solid = 3,
			collision = {{ px-10, py-12, px+10, py+16 }  },
			isbuilding = true,
		}
end


function Entities.new_blue_bandit( px, py )

		return {
				id = Entities.entitylist.blue_bandit,
				color = Colors.lt_blue,
				pos = {px, py},
				starting_pos = {px, py},
				dir = {0,0},
				shoot_dir = {1,0},
				target_dir = {1,0},
				prediction_short = {px, py},
				dir_prediction = { 0, 0 },
				spritesize = {Graphics.images.blue_bandit_standing:getWidth(), Graphics.images.blue_bandit_standing:getHeight()},
				collisionbox = {5,0,11,20},
				sprite = Graphics.images.blue_bandit_standing,
				sprite_standing = Graphics.images.blue_bandit_standing,
				sprite_gun_left = Graphics.images.blue_bandit_gun_left,
				sprite_gun_right = Graphics.images.blue_bandit_gun_right,
				sprite_ninja_gun_left = Graphics.images.ninja_bandit_blue_gun_left,
				sprite_ninja_gun_right = Graphics.images.ninja_bandit_blue_gun_right,
				sprite_walking_right = Graphics.animations.new_blue_bandit_walk_right(),
				sprite_walking_up = Graphics.animations.new_blue_bandit_walk_up(),
				sprite_walking_dn = Graphics.animations.new_blue_bandit_walk_up(),
				sprite_dying = Graphics.animations.new_blue_bandit_dying_right(),
				sprite_ninja_standing = Graphics.images.ninja_bandit_standing,
				sprite_ninja_walking_right = Graphics.animations.new_ninja_bandit_walk_right(),
				sprite_ninja_walking_up = Graphics.animations.new_ninja_bandit_walk_up(),
				sprite_ninja_walking_dn = Graphics.animations.new_ninja_bandit_walk_dn(),
				sprite_ninja_dying = Graphics.animations.new_ninja_bandit_dying_right(),
				destination = { px, py },
				lastpos = { px, py },
				suspicion_timer = 0,
				suspicion_delay = 3.5,
				state = 1,
				former_state = 0,
				sight_dist = 800,
				wandering_timer = 0,
				wandering_delay = 1.11,
				speed = 100,
				angular_velocity = math.pi / 180 * 180, --  180 degrees per sec
				aiming_angular_velocity = math.pi / 180 * 180 * 2,
				acceptable_arc = math.pi / 180 * 5,
				initial_reaction_time = 0.015 * 4,
				last_seen_bullet = {0,0},
				blocked_timer = 0,
				blocked_delay = 0.28, -- 1 second
				changedir_timer = 0,
				changedir_delay = 1.5, -- 1.5 seconds
				lastplayerpos = {0,0},
				dodging_timer = 0,
				dodging_delay = 2.66,
				scared_timer = 0,
				scared_delay = 3.35,
				shooting_timer = 0,
				shooting_delay = 0.4,
				accuracy = 0.15, -- lower is better
				firingmode = 1,
				death_timer = Graphics.get_deathtime() ,
				scream = Sounds.scream_blue,
				scream_slow = Sounds.scream_blue_slow,
				shot_sound = Sounds.shot_blue,
				see_player_timer = 0,
				player_was_seen = false,
				see_bullet_timer = 0,
				bullet_was_seen = false,
				ninja_see_player_timer = 0,
				ninja_player_was_seen = false,
				prediction_timer = 0,
				shotgun_arc = 10,
				prediction_short_dt = 0.05,
				prediction_delay = 0.25, -- 250ms
				see_delay = 0.1, -- 100ms
				bullet_see_delay = 0.05,
				isplayer = false,
				isbuilding = false,
			}
end

function Entities.new_red_bandit( px, py )

		return {
				id = Entities.entitylist.red_bandit,
				color = Colors.lt_red,
				pos = {px, py},
				starting_pos = {px, py},
				dir = {0,0},
				shoot_dir = {1,0},
				target_dir = {1,0},
				prediction_short = {px, py},
				dir_prediction = { 0, 0 },
				spritesize = {Graphics.images.red_bandit_standing:getWidth(), Graphics.images.red_bandit_standing:getHeight()},
				collisionbox = {3,1,14,20},
				sprite = Graphics.images.red_bandit_standing,
				sprite_standing = Graphics.images.red_bandit_standing,
				sprite_gun_left = Graphics.images.red_bandit_gun_left,
				sprite_gun_right = Graphics.images.red_bandit_gun_right,
				sprite_ninja_gun_left = Graphics.images.ninja_bandit_red_gun_left,
				sprite_ninja_gun_right = Graphics.images.ninja_bandit_red_gun_right,
				sprite_walking_right = Graphics.animations.new_red_bandit_walk_right(),
				sprite_walking_up = Graphics.animations.new_red_bandit_walk_up(),
				sprite_walking_dn = Graphics.animations.new_red_bandit_walk_up(),
				sprite_dying = Graphics.animations.new_red_bandit_dying_right(),
				sprite_ninja_standing = Graphics.images.ninja_bandit_standing,
				sprite_ninja_walking_right = Graphics.animations.new_ninja_bandit_walk_right(),
				sprite_ninja_walking_up = Graphics.animations.new_ninja_bandit_walk_up(),
				sprite_ninja_walking_dn = Graphics.animations.new_ninja_bandit_walk_dn(),
				sprite_ninja_dying = Graphics.animations.new_ninja_bandit_dying_right(),
				suspicion_timer = 0,
				suspicion_delay = 1.5,
				destination = { px, py },
				lastpos = { px, py },
				state = 1,
				former_state = 0,
				sight_dist = 800,
				wandering_timer = 0,
				wandering_delay = 4.57,
				speed = 70,
				angular_velocity = math.pi / 180 * 120, --  120 degrees per sec
				aiming_angular_velocity = math.pi / 180 * 120 * 2,
				acceptable_arc = math.pi / 180 * 5,
				initial_reaction_time = 0.022 * 4,
				last_seen_bullet = {0,0},
				blocked_timer = 0,
				blocked_delay = 0.45, -- second
				changedir_timer = 0,
				changedir_delay = 1.9, -- seconds
				lastplayerpos = {0,0},
				dodging_timer = 0,
				dodging_delay = 2.34,
				scared_timer = 0,
				scared_delay = 8.33,
				shooting_timer = 0,
				shooting_delay = 0.2,
				accuracy = 0.20,
				firingmode = 2,
				alternatefire = true,
				death_timer = Graphics.get_deathtime() ,
				scream = Sounds.scream_red,
				scream_slow = Sounds.scream_red_slow,
				shot_sound = Sounds.shot_red,
				see_player_timer = 0,
				player_was_seen = false,
				see_bullet_timer = 0,
				bullet_was_seen = false,
				ninja_see_player_timer = 0,
				ninja_player_was_seen = false,
				prediction_timer = 0,
				shotgun_arc = 10,
				prediction_short_dt = 0.05,
				prediction_delay = 0.25, -- 250ms
				see_delay = 0.1, -- 100ms
				bullet_see_delay = 0.05,
				isplayer = false,
				isbuilding = false,
			}
end

function Entities.new_green_bandit( px, py )

		return {
				id = Entities.entitylist.green_bandit,
				color = Colors.green,
				pos = {px, py},
				starting_pos = {px, py},
				dir = {0,0},
				shoot_dir = {1,0},
				target_dir = {1,0},
				prediction_short = {px, py},
				dir_prediction = { 0, 0 },
				spritesize = {Graphics.images.green_bandit_standing:getWidth(), Graphics.images.green_bandit_standing:getHeight()},
				collisionbox = {5,0,12,20},
				sprite = Graphics.images.green_bandit_standing,
				sprite_standing = Graphics.images.green_bandit_standing,
				sprite_gun_left = Graphics.images.green_bandit_gun_left,
				sprite_gun_right = Graphics.images.green_bandit_gun_right,
				sprite_ninja_gun_left = Graphics.images.ninja_bandit_green_gun_left,
				sprite_ninja_gun_right = Graphics.images.ninja_bandit_green_gun_right,
				sprite_walking_right = Graphics.animations.new_green_bandit_walk_right(),
				sprite_walking_up = Graphics.animations.new_green_bandit_walk_up(),
				sprite_walking_dn = Graphics.animations.new_green_bandit_walk_up(),
				sprite_dying = Graphics.animations.new_green_bandit_dying_right(),
				sprite_ninja_standing = Graphics.images.ninja_bandit_standing,
				sprite_ninja_walking_right = Graphics.animations.new_ninja_bandit_walk_right(),
				sprite_ninja_walking_up = Graphics.animations.new_ninja_bandit_walk_up(),
				sprite_ninja_walking_dn = Graphics.animations.new_ninja_bandit_walk_dn(),
				sprite_ninja_dying = Graphics.animations.new_ninja_bandit_dying_right(),
				destination = { px, py },
				lastpos = { px, py },
				suspicion_timer = 0,
				suspicion_delay = 2.0,
				state = 1,
				former_state = 0,
				sight_dist = 800,
				wandering_timer = 0,
				wandering_delay = 1.33,
				speed = 90,
				angular_velocity = math.pi / 180 * 150, --  150 degrees per sec
				aiming_angular_velocity = math.pi / 180 * 120 * 2,
				acceptable_arc = math.pi / 180 * 5,
				initial_reaction_time = 0.05 * 4,
				last_seen_bullet = {0,0},
				blocked_timer = 0,
				blocked_delay = 0.58, -- 1 second
				changedir_timer = 0,
				changedir_delay = 1.95, -- 1.5 seconds
				lastplayerpos = {0,0},
				dodging_timer = 0,
				dodging_delay = 1.52,
				scared_timer = 0,
				scared_delay = 6.62,
				shooting_timer = 0,
				shooting_delay = 0.55,
				accuracy = 0.25,
				firingmode = 3,
				death_timer = Graphics.get_deathtime() ,
				scream = Sounds.scream_green,
				scream_slow = Sounds.scream_green_slow,
				shot_sound = Sounds.shot_green,
				see_player_timer = 0,
				player_was_seen = false,
				see_bullet_timer = 0,
				bullet_was_seen = false,
				ninja_see_player_timer = 0,
				ninja_player_was_seen = false,
				prediction_timer = 0,
				shotgun_arc = 10,
				prediction_short_dt = 0.05,
				prediction_delay = 0.25, -- 250ms
				see_delay = 0.1, -- 100ms
				bullet_see_delay = 0.05,
				isplayer = false,
				isbuilding = false,
			}
end

function Entities.new_yellow_bandit( px, py )

		return {
				id = Entities.entitylist.yellow_bandit,
				color = Colors.yellow,
				pos = {px, py},
				starting_pos = {px, py},
				dir = {0,0},
				shoot_dir = {1,0},
				target_dir = {1,0},
				prediction_short = {px, py},
				dir_prediction = { 0, 0 },
				spritesize = {Graphics.images.yellow_bandit_standing:getWidth(), Graphics.images.yellow_bandit_standing:getHeight()},
				collisionbox = {6,3,11,19},
				sprite = Graphics.images.yellow_bandit_standing,
				sprite_standing = Graphics.images.yellow_bandit_standing,
				sprite_gun_left = Graphics.images.yellow_bandit_gun_left,
				sprite_gun_right = Graphics.images.yellow_bandit_gun_right,
				sprite_ninja_gun_left = Graphics.images.ninja_bandit_yellow_gun_left,
				sprite_ninja_gun_right = Graphics.images.ninja_bandit_yellow_gun_right,
				sprite_walking_right = Graphics.animations.new_yellow_bandit_walk_right(),
				sprite_walking_up = Graphics.animations.new_yellow_bandit_walk_up(),
				sprite_walking_dn = Graphics.animations.new_yellow_bandit_walk_up(),
				sprite_dying = Graphics.animations.new_yellow_bandit_dying_right(),
				sprite_ninja_standing = Graphics.images.ninja_bandit_standing,
				sprite_ninja_walking_right = Graphics.animations.new_ninja_bandit_walk_right(),
				sprite_ninja_walking_up = Graphics.animations.new_ninja_bandit_walk_up(),
				sprite_ninja_walking_dn = Graphics.animations.new_ninja_bandit_walk_dn(),
				sprite_ninja_dying = Graphics.animations.new_ninja_bandit_dying_right(),
				suspicion_timer = 0,
				suspicion_delay = 5.5,
				destination = { px, py },
				lastpos = { px, py },
				state = 1,
				former_state = 0,
				sight_dist = 800,
				wandering_timer = 0,
				wandering_delay = 0.41,
				speed = 140,
				angular_velocity = math.pi / 180 * 170, --  170 degrees per sec
				aiming_angular_velocity = math.pi / 180 * 190 * 2,
				acceptable_arc = math.pi / 180 * 5,
				initial_reaction_time = 0.008 * 4,
				last_seen_bullet = {0,0},
				blocked_timer = 0,
				blocked_delay = 0.25, -- 1 second
				changedir_timer = 0,
				changedir_delay = 1.0, -- 1.5 seconds
				lastplayerpos = {0,0},
				dodging_timer = 0,
				dodging_delay = 3.11,
				scared_timer = 0,
				scared_delay = 8.56,
				shooting_timer = 0,
				shooting_delay = 0.35,
				accuracy = 0.01,
				firingmode = 1,
				death_timer = Graphics.get_deathtime() ,
				scream = Sounds.scream_yellow,
				scream_slow = Sounds.scream_yellow_slow,
				shot_sound = Sounds.shot_yellow,
				see_player_timer = 0,
				player_was_seen = false,
				see_bullet_timer = 0,
				bullet_was_seen = false,
				ninja_see_player_timer = 0,
				ninja_player_was_seen = false,
				prediction_timer = 0,
				shotgun_arc = 10,
				prediction_short_dt = 0.05,
				prediction_delay = 0.25, -- 250ms
				see_delay = 0.1, -- 100ms
				bullet_see_delay = 0.05,
				isplayer = false,
				isbuilding = false,
			}
end
