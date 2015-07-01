
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

Level = {}

-- initializes an empty canvas
function Level.init()

	Level.buildings = {}

	Level.enemies = {}

	-- what radius around a point is considered "home"
	location_range = 40

	-- used to prevent going out of screen when fleeing
	screenborder = 30

	Level.enemy_count = 0
	Level.end_time = 3

	Level.enemylessmode = true
	Level.ninjamode = Graphics.shadow_mode
	Level.enemiescanshoot = true
	Level.autoturns = false
	Level.onebullet = false
end

function Level.update( dt )
	if not Level.enemylessmode then
		if Level.enemy_count == 0 or not Player.alive then
			if Level.end_time >= 0 then
				Level.end_time = Level.end_time - dt
			else
				if Editor.enabled then
					Level.restart()
				elseif UserLevel.enabled then
					if Player.alive then
						-- alive? you won! next level
						UserLevel.mode = 3
					else
					-- normal mode: restart this level
						Level.restart()
					end
				else
					if Player.alive then
						-- alive? you won! next level
						Level.currentlevel = Level.currentlevel + 1
						Level.load( Level.currentlevel )
					else
						-- dead?  restart
						if Game.gamemode == 2 then
							-- hard mode! restart game
							Level.currentlevel = 1
							Level.load( Level.currentlevel )
						else
							-- normal mode: restart this level
							Level.restart()
						end
					end
				end
			end
		end
	end
end


-- prepares level "lvl" (a number)
function Level.load( lvl )
	Level.init()
	if Game.testlevel then
		Level.load_testlevel()
		Level.restart()
		return
	end

	if Game.gamemode == 2 then -- hard
		if lvl==1 then
			Level.load_lvl1_hard()
		elseif lvl==2 then
			Level.load_lvl2_hard()
		elseif lvl==3 then
			Level.load_lvl3_hard()
		elseif lvl==4 then
			Level.load_lvl4_hard()
		elseif lvl==5 then
			Level.load_lvl5_hard()
		elseif lvl==6 then
			Level.load_lvl6_hard()
		elseif lvl==7 then
			Level.load_lvl7_hard()
		elseif lvl==8 then
			Level.load_lvl8_hard()
		elseif lvl==9 then
			Level.load_lvl9_hard()
		elseif lvl==10 then
			Level.load_lvl10_hard()
		elseif lvl==11 then
			Game.endgame()
		end
	else -- normal
		if lvl==1 then
			Level.load_lvl1()
		elseif lvl==2 then
			Level.load_lvl2()
		elseif lvl==3 then
			Level.load_lvl3()
		elseif lvl==4 then
			Level.load_lvl4()
		elseif lvl==5 then
			Level.load_lvl5()
		elseif lvl==6 then
			Level.load_lvl6()
		elseif lvl==7 then
			Level.load_lvl7()
		elseif lvl==8 then
			Level.load_lvl8()
		elseif lvl==9 then
			Level.load_lvl9()
		elseif lvl==10 then
			Level.load_lvl10()
		elseif lvl==11 then
			Game.endgame()
		end
	end

	Level.restart()
end


--  Resets enemies, bullets, player
function Level.restart()
	Level.reset_player()
	Level.reset_enemies()

	Bullets = List.reset(Bullets)
	Bullets = List.newlist(nil)

	Level.enemy_count = table.getn( Level.enemies )
	Level.end_time = 3
	Level.enemylessmode = (Level.enemy_count == 0)

	if not (Editor.enabled and Editor.mode~=6) and not UserLevel.enabled then
		if love.mouse.isDown("l") then
			love.mousepressed(love.mouse.getX(), love.mouse.getY(), "l")
		end

		if love.mouse.isDown("r") then
			love.mousepressed(love.mouse.getX(), love.mouse.getY(), "r")
		end
	end
	
	Graphics.prepareBackground()
	Graphics.prepareTopLayer()

end

function Level.reset_player()

	Player.alive = true

	Player.pos = {Player.starting_pos[1], Player.starting_pos[2]}
	Player.dir = {0,0}
	Player.shoot_dir = {1,0}
	Player.prediction_short = {Player.starting_pos[1], Player.starting_pos[2]}
	Player.dir_prediction = { 0, 0 }
	Player.key_dir = {0,0}
	Player.firing = false
	Player.firing_timer = 0
	Player.jumping = false
	Player.readytojump = true
	Player.spinning_dir = {0,0}
	Player.jump_timer = 0

	Player.bullet_pocket = Player.total_bullets
	Player.reload_timer = 0
	Player.prediction_timer = 0
	Player.remaining_bullets = table.getn(Level.enemies)
	
	Player.free_box = nil

	if Level.onebullet then
		if Player.bullet_pocket > Player.remaining_bullets then
			Player.bullet_pocket = Player.remaining_bullets
		end
		Player.remaining_bullets = Player.remaining_bullets - Player.bullet_pocket
	end

	BulletTime.reset()
	
	Player.collision_buildings = List.fromArray( Level.buildings )
	Player.collision_buildings = List.applydel( Player.collision_buildings, function(b) return b.solid <= 2 end)
end


function Level.reset_enemy( enemy )

	local px, py = enemy.starting_pos[1], enemy.starting_pos[2]

	enemy.pos = {px, py}
	enemy.dir = {0,0}
	enemy.shoot_dir = {1,0}
	enemy.target_dir = {1,0}
	enemy.prediction_short = {px, py}
	enemy.dir_prediction = { 0, 0 }
	enemy.state = 1
	enemy.former_state = 0
	enemy.last_seen_bullet = {0,0}
	enemy.blocked_timer = 0
	enemy.dodging_timer = 0

	enemy.changedir_timer = 0
	enemy.lastplayerpos = {Player.starting_pos[1],Player.starting_pos[2]}

	enemy.shooting_timer = 0
	enemy.destination = { px, py }
	enemy.lastpos = { px, py }
	enemy.death_timer = Graphics.get_deathtime()
	enemy.wandering_timer = 0
	enemy.suspicion_timer = 0
	enemy.scared_timer = 0

	enemy.see_player_timer = 0
	enemy.player_was_seen = false
	enemy.see_bullet_timer = 0
	enemy.bullet_was_seen = false
	enemy.ninja_see_player_timer = 0
	enemy.ninja_player_was_seen = false
	enemy.prediction_timer = 0
	enemy.free_box = nil
end

function Level.reset_enemies()
	for i,enemy in ipairs(Level.enemies) do
		Level.reset_enemy( enemy )
	end
	EnemyAI.load_buildingLists()
end

function Level.player_dies(direction)
	-- if already dead, ignore (duh)
	if not Player.alive then
		return
	end

	Player.alive = false
	Player.death_timer = Graphics.get_deathtime()

	-- adjust player
	Player.dir = {direction[1], direction[2]}
	Player.speed = 100 -- half of my walking speed (direction of fallover)

	BulletTime.force( Level.end_time )

	Graphics.reset_jump()
	Graphics.reset_death()
	Sounds.play_scream_player()
end

function Level.enemy_dies(enemy, direction)
	enemy.state = 0
	enemy.dir = {direction[1], direction[2] }
	enemy.speed = 100

	Graphics.resetAnim( enemy.sprite_dying )
	Graphics.resetAnim( enemy.sprite_ninja_dying )

	Level.enemy_count = Level.enemy_count - 1

	-- last enemy: pause for dramatism
	if Level.enemy_count <= 0 then
		BulletTime.force( Level.end_time )
	end

	Sounds.play_scream_enemy( enemy )
end

------------------------------------------------------------------------------
function Level.load_testlevel()
	Level.enemiescanshoot = false
	Entities.add_element(Entities.entitylist.player, {100,100})
	Entities.add_element(Entities.entitylist.red_bandit, {500,300})
	Entities.add_element(Entities.entitylist.saloon, {200,200})

end

------------------------------------------------------------------------------

function Level.load_lvl1()
	Entities.add_element(Entities.entitylist.player,{67,79})
	Entities.add_element(Entities.entitylist.bank,{387,342})
	Entities.add_element(Entities.entitylist.house,{155,319})
	Entities.add_element(Entities.entitylist.herb,{265,468})
	Entities.add_element(Entities.entitylist.bush,{30,381})
	Entities.add_element(Entities.entitylist.fence_vert,{22,295},8)
	Entities.add_element(Entities.entitylist.fence_horiz,{105,236},4)
	Entities.add_element(Entities.entitylist.fence_vert,{601,336},4)
	Entities.add_element(Entities.entitylist.barrier_horiz,{549,445},2)
	Entities.add_element(Entities.entitylist.bush,{504,442})
	Entities.add_element(Entities.entitylist.bush,{457,442})
	Entities.add_element(Entities.entitylist.bush,{482,442})
	Entities.add_element(Entities.entitylist.cactus,{93,203})
	Entities.add_element(Entities.entitylist.herb,{603,250})
	Entities.add_element(Entities.entitylist.herb,{24,201})
	Entities.add_element(Entities.entitylist.church,{598,408})
	Entities.add_element(Entities.entitylist.house,{50,427})
	Entities.add_element(Entities.entitylist.fence_horiz,{263,450},9)
	Entities.add_element(Entities.entitylist.barrier_horiz,{383,445},4)
	Entities.add_element(Entities.entitylist.bank,{140,426})
	Entities.add_element(Entities.entitylist.warehouse,{500,103})
	Entities.add_element(Entities.entitylist.house,{590,83})
	Entities.add_element(Entities.entitylist.cactus,{573,25})
	Entities.add_element(Entities.entitylist.house,{590,143})
	Entities.add_element(Entities.entitylist.bush,{543,59})
	Entities.add_element(Entities.entitylist.warehouse,{257,336})
	Entities.add_element(Entities.entitylist.barrier_horiz,{337,231},7)
	Entities.add_element(Entities.entitylist.sheriff_box,{476,249})
	Entities.add_element(Entities.entitylist.cactus,{377,18})
	Entities.add_element(Entities.entitylist.herb,{78,23})
	Entities.add_element(Entities.entitylist.barrier_vert,{25,93},3)
	Entities.add_element(Entities.entitylist.bank,{83,149})
	Entities.add_element(Entities.entitylist.mansion,{179,198})
	Entities.add_element(Entities.entitylist.well,{190,108})
	Entities.add_element(Entities.entitylist.fence_horiz,{251,52},32)
	Entities.add_element(Entities.entitylist.barrier_horiz,{51,231},2)
	Entities.add_element(Entities.entitylist.house,{50,425})
	Entities.add_element(Entities.entitylist.fence_vert,{562,250},3)
	Entities.add_element(Entities.entitylist.house,{590,203})
	Entities.add_element(Entities.entitylist.house,{590,296})
	Entities.add_element(Entities.entitylist.barber,{287,133})
	Entities.add_element(Entities.entitylist.barber,{425,133})
	Entities.add_element(Entities.entitylist.blue_bandit,{91,319})
	Entities.add_element(Entities.entitylist.blue_bandit,{145,373})
	Entities.add_element(Entities.entitylist.blue_bandit,{491,351})
	Entities.add_element(Entities.entitylist.blue_bandit,{284,189})
	Entities.add_element(Entities.entitylist.blue_bandit,{307,338})

end



function Level.load_lvl2()
	Entities.add_element(Entities.entitylist.player,{307,208})
	Entities.add_element(Entities.entitylist.barrier_vert,{277,258},8)
	Entities.add_element(Entities.entitylist.barrier_horiz,{146,227},6)
	Entities.add_element(Entities.entitylist.barrier_horiz,{43,227},1)
	Entities.add_element(Entities.entitylist.barrier_vert,{339,311},5)
	Entities.add_element(Entities.entitylist.herb,{63,258})
	Entities.add_element(Entities.entitylist.herb,{120,140})
	Entities.add_element(Entities.entitylist.herb,{259,30})
	Entities.add_element(Entities.entitylist.herb,{370,78})
	Entities.add_element(Entities.entitylist.herb,{455,188})
	Entities.add_element(Entities.entitylist.herb,{548,136})
	Entities.add_element(Entities.entitylist.herb,{610,294})
	Entities.add_element(Entities.entitylist.herb,{511,338})
	Entities.add_element(Entities.entitylist.herb,{312,296})
	Entities.add_element(Entities.entitylist.cactus,{457,80})
	Entities.add_element(Entities.entitylist.cactus,{616,446})
	Entities.add_element(Entities.entitylist.cactus,{355,211})
	Entities.add_element(Entities.entitylist.herb,{232,407})
	Entities.add_element(Entities.entitylist.cactus,{46,426})
	Entities.add_element(Entities.entitylist.bank,{181,245})
	Entities.add_element(Entities.entitylist.warehouse,{214,327})
	Entities.add_element(Entities.entitylist.barrier_vert,{67,434},3)
	Entities.add_element(Entities.entitylist.church,{86,348})
	Entities.add_element(Entities.entitylist.barrier_vert,{29,322},6)
	Entities.add_element(Entities.entitylist.bank,{87,245})
	Entities.add_element(Entities.entitylist.saloon,{436,403})
	Entities.add_element(Entities.entitylist.barrier_vert,{539,422},4)
	Entities.add_element(Entities.entitylist.sheriff_box,{480,290})
	Entities.add_element(Entities.entitylist.sheriff_box,{480,291})
	Entities.add_element(Entities.entitylist.sheriff_box,{96,70})
	Entities.add_element(Entities.entitylist.church,{223,69})
	Entities.add_element(Entities.entitylist.barrier_horiz,{509,104},3)
	Entities.add_element(Entities.entitylist.barrier_vert,{277,32},3)
	Entities.add_element(Entities.entitylist.barrier_vert,{381,204},7)
	Entities.add_element(Entities.entitylist.barrier_vert,{426,156},4)
	Entities.add_element(Entities.entitylist.barrier_vert,{606,133},6)
	Entities.add_element(Entities.entitylist.barrier_vert,{582,366},5)
	Entities.add_element(Entities.entitylist.barrier_vert,{339,110},5)
	Entities.add_element(Entities.entitylist.bank,{549,199})
	Entities.add_element(Entities.entitylist.warehouse,{540,58})
	Entities.add_element(Entities.entitylist.house,{556,290})
	Entities.add_element(Entities.entitylist.barrier_horiz,{28,163},2)
	Entities.add_element(Entities.entitylist.cactus,{144,330})
	Entities.add_element(Entities.entitylist.cactus,{29,115})
	Entities.add_element(Entities.entitylist.herb,{135,191})
	Entities.add_element(Entities.entitylist.barrier_horiz,{404,42},4)
	Entities.add_element(Entities.entitylist.house,{453,200})
	Entities.add_element(Entities.entitylist.house,{459,198})
	Entities.add_element(Entities.entitylist.house,{137,123})
	Entities.add_element(Entities.entitylist.barrier_horiz,{217,163},4)
	Entities.add_element(Entities.entitylist.barrier_horiz,{254,435},8)
	Entities.add_element(Entities.entitylist.yellow_bandit,{198,135})
	Entities.add_element(Entities.entitylist.yellow_bandit,{147,326})
	Entities.add_element(Entities.entitylist.yellow_bandit,{612,331})
	Entities.add_element(Entities.entitylist.yellow_bandit,{404,201})
	Entities.add_element(Entities.entitylist.yellow_bandit,{82,133})
	Entities.add_element(Entities.entitylist.yellow_bandit,{515,460})
end

function Level.load_lvl3()
	Entities.add_element(Entities.entitylist.player,{369,231})
	Entities.add_element(Entities.entitylist.bank,{402,313})
	Entities.add_element(Entities.entitylist.mansion,{236,149})
	Entities.add_element(Entities.entitylist.house,{116,163})
	Entities.add_element(Entities.entitylist.barrel,{195,233})
	Entities.add_element(Entities.entitylist.barrel,{195,246})
	Entities.add_element(Entities.entitylist.barrel,{195,260})
	Entities.add_element(Entities.entitylist.barrel,{195,275})
	Entities.add_element(Entities.entitylist.barrel,{195,289})
	Entities.add_element(Entities.entitylist.warehouse,{265,448})
	Entities.add_element(Entities.entitylist.saloon,{541,76})
	Entities.add_element(Entities.entitylist.church,{47,263})
	Entities.add_element(Entities.entitylist.barrier_horiz,{40,184},3)
	Entities.add_element(Entities.entitylist.sheriff_box,{490,452})
	Entities.add_element(Entities.entitylist.herb,{440,150})
	Entities.add_element(Entities.entitylist.herb,{297,42})
	Entities.add_element(Entities.entitylist.herb,{196,444})
	Entities.add_element(Entities.entitylist.herb,{445,367})
	Entities.add_element(Entities.entitylist.herb,{600,425})
	Entities.add_element(Entities.entitylist.cactus,{567,414})
	Entities.add_element(Entities.entitylist.cactus,{220,253})
	Entities.add_element(Entities.entitylist.cactus,{177,54})
	Entities.add_element(Entities.entitylist.cactus,{77,327})
	Entities.add_element(Entities.entitylist.cactus,{457,42})
	Entities.add_element(Entities.entitylist.saloon,{553,327})
	Entities.add_element(Entities.entitylist.mansion,{86,395})
	Entities.add_element(Entities.entitylist.bank,{85,63})
	Entities.add_element(Entities.entitylist.bank,{232,359})
	Entities.add_element(Entities.entitylist.sheriff_box,{342,165})
	Entities.add_element(Entities.entitylist.sheriff_box,{295,254})
	Entities.add_element(Entities.entitylist.house,{241,74})
	Entities.add_element(Entities.entitylist.warehouse,{118,245})
	Entities.add_element(Entities.entitylist.warehouse,{368,376})
	Entities.add_element(Entities.entitylist.mansion,{580,208})
	Entities.add_element(Entities.entitylist.barber,{379,59})
	Entities.add_element(Entities.entitylist.barber,{472,225})
	Entities.add_element(Entities.entitylist.red_bandit,{606,459})
	Entities.add_element(Entities.entitylist.red_bandit,{216,423})
	Entities.add_element(Entities.entitylist.red_bandit,{17,217})
	Entities.add_element(Entities.entitylist.red_bandit,{41,133})
	Entities.add_element(Entities.entitylist.red_bandit,{618,15})
	Entities.add_element(Entities.entitylist.red_bandit,{369,464})
end

function Level.load_lvl4()
	Entities.add_element(Entities.entitylist.player,{315,213})
	Entities.add_element(Entities.entitylist.barrier_horiz,{329,185},10)
	Entities.add_element(Entities.entitylist.barrier_vert,{125,174},7)
	Entities.add_element(Entities.entitylist.bank,{370,260})
	Entities.add_element(Entities.entitylist.warehouse,{403,326})
	Entities.add_element(Entities.entitylist.house,{293,110})
	Entities.add_element(Entities.entitylist.house,{352,110})
	Entities.add_element(Entities.entitylist.house,{411,110})
	Entities.add_element(Entities.entitylist.house,{470,110})
	Entities.add_element(Entities.entitylist.warehouse,{583,245})
	Entities.add_element(Entities.entitylist.warehouse,{583,318})
	Entities.add_element(Entities.entitylist.barrel,{178,201})
	Entities.add_element(Entities.entitylist.barrel,{175,215})
	Entities.add_element(Entities.entitylist.barrel,{167,226})
	Entities.add_element(Entities.entitylist.barrel,{161,238})
	Entities.add_element(Entities.entitylist.dead_branch,{59,277})
	Entities.add_element(Entities.entitylist.dead_branch,{289,427})
	Entities.add_element(Entities.entitylist.herb,{101,221})
	Entities.add_element(Entities.entitylist.herb,{198,405})
	Entities.add_element(Entities.entitylist.herb,{399,428})
	Entities.add_element(Entities.entitylist.herb,{304,317})
	Entities.add_element(Entities.entitylist.herb,{454,211})
	Entities.add_element(Entities.entitylist.herb,{518,324})
	Entities.add_element(Entities.entitylist.herb,{528,175})
	Entities.add_element(Entities.entitylist.herb,{623,410})
	Entities.add_element(Entities.entitylist.herb,{614,103})
	Entities.add_element(Entities.entitylist.barrier_horiz,{78,83},3)
	Entities.add_element(Entities.entitylist.bush,{17,82})
	Entities.add_element(Entities.entitylist.barrier_vert,{350,19},2)
	Entities.add_element(Entities.entitylist.barrier_vert,{234,66},2)
	Entities.add_element(Entities.entitylist.herb,{293,33})
	Entities.add_element(Entities.entitylist.herb,{175,81})
	Entities.add_element(Entities.entitylist.bush,{366,16})
	Entities.add_element(Entities.entitylist.house,{234,110})
	Entities.add_element(Entities.entitylist.fence_horiz,{490,36},11)
	Entities.add_element(Entities.entitylist.barrier_horiz,{295,279},1)
	Entities.add_element(Entities.entitylist.mansion,{520,401})
	Entities.add_element(Entities.entitylist.mansion,{551,401})
	Entities.add_element(Entities.entitylist.barrier_vert,{570,64},2)
	Entities.add_element(Entities.entitylist.dead_branch,{560,62})
	Entities.add_element(Entities.entitylist.dead_tree,{577,62})
	Entities.add_element(Entities.entitylist.sheriff_box,{46,156})
	Entities.add_element(Entities.entitylist.church,{151,445})
	Entities.add_element(Entities.entitylist.church,{217,307})
	Entities.add_element(Entities.entitylist.barrier_vert,{481,253},4)
	Entities.add_element(Entities.entitylist.barrier_horiz,{210,359},8)
	Entities.add_element(Entities.entitylist.herb,{42,46})
	Entities.add_element(Entities.entitylist.barrel,{122,43})
	Entities.add_element(Entities.entitylist.barrel,{122,20})
	Entities.add_element(Entities.entitylist.green_bandit,{496,213})
	Entities.add_element(Entities.entitylist.green_bandit,{119,467})
	Entities.add_element(Entities.entitylist.green_bandit,{30,40})
	Entities.add_element(Entities.entitylist.green_bandit,{361,315})
	Entities.add_element(Entities.entitylist.green_bandit,{318,156})
	Entities.add_element(Entities.entitylist.green_bandit,{386,56})
	Entities.add_element(Entities.entitylist.green_bandit,{626,304})
end

function Level.load_lvl5()
	Entities.add_element(Entities.entitylist.player,{401,108})
	Entities.add_element(Entities.entitylist.barrel,{447,288})
	Entities.add_element(Entities.entitylist.warehouse,{468,366})
	Entities.add_element(Entities.entitylist.cactus,{560,428})
	Entities.add_element(Entities.entitylist.cactus,{599,209})
	Entities.add_element(Entities.entitylist.cactus,{199,99})
	Entities.add_element(Entities.entitylist.cactus,{37,410})
	Entities.add_element(Entities.entitylist.herb,{39,76})
	Entities.add_element(Entities.entitylist.herb,{217,290})
	Entities.add_element(Entities.entitylist.herb,{472,447})
	Entities.add_element(Entities.entitylist.herb,{568,273})
	Entities.add_element(Entities.entitylist.barrel,{357,261})
	Entities.add_element(Entities.entitylist.barrel,{357,288})
	Entities.add_element(Entities.entitylist.saloon,{303,349})
	Entities.add_element(Entities.entitylist.barrier_horiz,{236,437},8)
	Entities.add_element(Entities.entitylist.barrel,{447,263})
	Entities.add_element(Entities.entitylist.barrier_vert,{359,458},2)
	Entities.add_element(Entities.entitylist.warehouse,{83,159})
	Entities.add_element(Entities.entitylist.barrier_horiz,{195,46},9)
	Entities.add_element(Entities.entitylist.warehouse,{335,92})
	Entities.add_element(Entities.entitylist.herb,{497,36})
	Entities.add_element(Entities.entitylist.smith,{494,204})
	Entities.add_element(Entities.entitylist.barrel,{447,146})
	Entities.add_element(Entities.entitylist.church,{463,76})
	Entities.add_element(Entities.entitylist.house,{273,131})
	Entities.add_element(Entities.entitylist.mansion,{303,195})
	Entities.add_element(Entities.entitylist.house,{570,338})
	Entities.add_element(Entities.entitylist.house,{610,88})
	Entities.add_element(Entities.entitylist.house,{518,88})
	Entities.add_element(Entities.entitylist.pile,{30,289})
	Entities.add_element(Entities.entitylist.warehouse,{83,335})
	Entities.add_element(Entities.entitylist.barrier_vert,{182,361},2)
	Entities.add_element(Entities.entitylist.barrier_vert,{182,245},9)
	Entities.add_element(Entities.entitylist.crate,{448,433})
	Entities.add_element(Entities.entitylist.blue_bandit,{578,195})
	Entities.add_element(Entities.entitylist.blue_bandit,{620,343})
	Entities.add_element(Entities.entitylist.blue_bandit,{516,345})
	Entities.add_element(Entities.entitylist.yellow_bandit,{150,340})
	Entities.add_element(Entities.entitylist.yellow_bandit,{146,178})
	Entities.add_element(Entities.entitylist.blue_bandit,{209,334})
	Entities.add_element(Entities.entitylist.green_bandit,{215,137})
	Entities.add_element(Entities.entitylist.red_bandit,{29,456})

end

function Level.load_lvl6()
	Entities.add_element(Entities.entitylist.player,{328,408})
	Entities.add_element(Entities.entitylist.warehouse,{92,423})
	Entities.add_element(Entities.entitylist.barrel,{161,195})
	Entities.add_element(Entities.entitylist.fence_horiz,{61,229},5)
	Entities.add_element(Entities.entitylist.house,{557,56})
	Entities.add_element(Entities.entitylist.fence_vert,{554,98},2)
	Entities.add_element(Entities.entitylist.bush,{78,12})
	Entities.add_element(Entities.entitylist.bush,{78,37})
	Entities.add_element(Entities.entitylist.saloon,{285,98})
	Entities.add_element(Entities.entitylist.saloon,{436,98})
	Entities.add_element(Entities.entitylist.house,{115,232})
	Entities.add_element(Entities.entitylist.house,{115,291})
	Entities.add_element(Entities.entitylist.barrier_horiz,{286,181},3)
	Entities.add_element(Entities.entitylist.warehouse,{219,227})
	Entities.add_element(Entities.entitylist.house,{557,141})
	Entities.add_element(Entities.entitylist.warehouse,{61,111})
	Entities.add_element(Entities.entitylist.barrier_horiz,{361,12},8)
	Entities.add_element(Entities.entitylist.mansion,{209,410})
	Entities.add_element(Entities.entitylist.sheriff_box,{386,307})
	Entities.add_element(Entities.entitylist.fence_vert,{304,392},7)
	Entities.add_element(Entities.entitylist.sheriff_box,{293,307})
	Entities.add_element(Entities.entitylist.barrier_vert,{29,337},7)
	Entities.add_element(Entities.entitylist.barrier_horiz,{147,324},4)
	Entities.add_element(Entities.entitylist.generic_house,{433,448})
	Entities.add_element(Entities.entitylist.generic_house,{433,410})
	Entities.add_element(Entities.entitylist.church,{453,235})
	Entities.add_element(Entities.entitylist.stable,{561,342})
	Entities.add_element(Entities.entitylist.well,{484,327})
	Entities.add_element(Entities.entitylist.tiny_house,{163,83})
	Entities.add_element(Entities.entitylist.tiny_house,{163,143})
	Entities.add_element(Entities.entitylist.barrier_horiz,{493,181},6)
	Entities.add_element(Entities.entitylist.red_bandit,{180,199})
	Entities.add_element(Entities.entitylist.green_bandit,{110,173})
	Entities.add_element(Entities.entitylist.yellow_bandit,{46,463})
	Entities.add_element(Entities.entitylist.red_bandit,{307,229})
	Entities.add_element(Entities.entitylist.yellow_bandit,{391,234})
	Entities.add_element(Entities.entitylist.yellow_bandit,{605,98})
	Entities.add_element(Entities.entitylist.blue_bandit,{630,385})
	Entities.add_element(Entities.entitylist.yellow_bandit,{359,36})


end
function Level.load_lvl7()
	Entities.add_element(Entities.entitylist.player,{204,198})
	Entities.add_element(Entities.entitylist.sheriff_box,{48,152})
	Entities.add_element(Entities.entitylist.barrier_horiz,{362,77},3)
	Entities.add_element(Entities.entitylist.mansion,{468,44})
	Entities.add_element(Entities.entitylist.cactus,{40,268})
	Entities.add_element(Entities.entitylist.herb,{346,209})
	Entities.add_element(Entities.entitylist.herb,{42,421})
	Entities.add_element(Entities.entitylist.warehouse,{291,123})
	Entities.add_element(Entities.entitylist.smith,{419,178})
	Entities.add_element(Entities.entitylist.barrier_horiz,{364,263},7)
	Entities.add_element(Entities.entitylist.bank,{203,244})
	Entities.add_element(Entities.entitylist.well,{577,101})
	Entities.add_element(Entities.entitylist.barrier_horiz,{204,169},4)
	Entities.add_element(Entities.entitylist.house,{193,95})
	Entities.add_element(Entities.entitylist.house,{193,4})
	Entities.add_element(Entities.entitylist.well,{84,52})
	Entities.add_element(Entities.entitylist.stable,{551,317})
	Entities.add_element(Entities.entitylist.herb,{604,440})
	Entities.add_element(Entities.entitylist.cactus,{594,165})
	Entities.add_element(Entities.entitylist.generic_house,{153,447})
	Entities.add_element(Entities.entitylist.warehouse,{116,317})
	Entities.add_element(Entities.entitylist.saloon,{413,373})
	Entities.add_element(Entities.entitylist.herb,{332,303})
	Entities.add_element(Entities.entitylist.crate,{241,356})
	Entities.add_element(Entities.entitylist.crate,{398,96})
	Entities.add_element(Entities.entitylist.crate,{373,106})
	Entities.add_element(Entities.entitylist.blue_bandit,{495,168})
	Entities.add_element(Entities.entitylist.yellow_bandit,{365,33})
	Entities.add_element(Entities.entitylist.yellow_bandit,{329,33})
	Entities.add_element(Entities.entitylist.red_bandit,{604,277})
	Entities.add_element(Entities.entitylist.blue_bandit,{558,33})
	Entities.add_element(Entities.entitylist.red_bandit,{454,450})
	Entities.add_element(Entities.entitylist.green_bandit,{112,393})
	Entities.add_element(Entities.entitylist.yellow_bandit,{328,387})
	Entities.add_element(Entities.entitylist.blue_bandit,{168,303})


end
function Level.load_lvl8()
	Entities.add_element(Entities.entitylist.player,{613,36})
	Entities.add_element(Entities.entitylist.sheriff_box,{46,315})
	Entities.add_element(Entities.entitylist.barber,{593,162})
	Entities.add_element(Entities.entitylist.barrel,{448,155})
	Entities.add_element(Entities.entitylist.mansion,{499,44})
	Entities.add_element(Entities.entitylist.generic_house,{34,103})
	Entities.add_element(Entities.entitylist.warehouse,{448,290})
	Entities.add_element(Entities.entitylist.house,{451,202})
	Entities.add_element(Entities.entitylist.barber,{523,253})
	Entities.add_element(Entities.entitylist.well,{455,462})
	Entities.add_element(Entities.entitylist.cactus,{378,44})
	Entities.add_element(Entities.entitylist.cactus,{113,33})
	Entities.add_element(Entities.entitylist.herb,{26,259})
	Entities.add_element(Entities.entitylist.herb,{39,404})
	Entities.add_element(Entities.entitylist.cactus,{122,344})
	Entities.add_element(Entities.entitylist.cactus,{513,150})
	Entities.add_element(Entities.entitylist.cactus,{613,311})
	Entities.add_element(Entities.entitylist.herb,{501,446})
	Entities.add_element(Entities.entitylist.fence_vert,{255,201},6)
	Entities.add_element(Entities.entitylist.bush,{345,175})
	Entities.add_element(Entities.entitylist.bush,{278,196})
	Entities.add_element(Entities.entitylist.bush,{334,224})
	Entities.add_element(Entities.entitylist.house,{451,109})
	Entities.add_element(Entities.entitylist.barrier_horiz,{439,395},5)
	Entities.add_element(Entities.entitylist.fence_horiz,{310,153},8)
	Entities.add_element(Entities.entitylist.fence_horiz,{310,254},8)
	Entities.add_element(Entities.entitylist.fence_vert,{366,201},6)
	Entities.add_element(Entities.entitylist.bank,{110,210})
	Entities.add_element(Entities.entitylist.stable,{171,225})
	Entities.add_element(Entities.entitylist.barber,{194,97})
	Entities.add_element(Entities.entitylist.pile,{271,81})
	Entities.add_element(Entities.entitylist.dead_tree,{309,192})
	Entities.add_element(Entities.entitylist.sheriff_box,{563,378})
	Entities.add_element(Entities.entitylist.tiny_house,{579,417})
	Entities.add_element(Entities.entitylist.saloon,{308,334})
	Entities.add_element(Entities.entitylist.generic_house,{312,411})
	Entities.add_element(Entities.entitylist.fence_horiz,{331,76},5)
	Entities.add_element(Entities.entitylist.crate,{361,85})
	Entities.add_element(Entities.entitylist.church,{175,342})
	Entities.add_element(Entities.entitylist.mansion,{137,436})
	Entities.add_element(Entities.entitylist.green_bandit,{34,449})
	Entities.add_element(Entities.entitylist.yellow_bandit,{51,31})
	Entities.add_element(Entities.entitylist.blue_bandit,{221,147})
	Entities.add_element(Entities.entitylist.green_bandit,{29,164})
	Entities.add_element(Entities.entitylist.green_bandit,{119,265})
	Entities.add_element(Entities.entitylist.red_bandit,{221,359})
	Entities.add_element(Entities.entitylist.yellow_bandit,{428,460})
	Entities.add_element(Entities.entitylist.red_bandit,{491,294})


end
function Level.load_lvl9()
	Entities.add_element(Entities.entitylist.player,{283,265})
	Entities.add_element(Entities.entitylist.generic_house,{231,65})
	Entities.add_element(Entities.entitylist.tiny_house,{336,267})
	Entities.add_element(Entities.entitylist.tiny_house,{30,115})
	Entities.add_element(Entities.entitylist.well,{170,464})
	Entities.add_element(Entities.entitylist.warehouse,{111,54})
	Entities.add_element(Entities.entitylist.church,{111,145})
	Entities.add_element(Entities.entitylist.smith,{97,233})
	Entities.add_element(Entities.entitylist.saloon,{466,203})
	Entities.add_element(Entities.entitylist.well,{595,351})
	Entities.add_element(Entities.entitylist.herb,{581,439})
	Entities.add_element(Entities.entitylist.herb,{591,155})
	Entities.add_element(Entities.entitylist.herb,{329,40})
	Entities.add_element(Entities.entitylist.herb,{167,169})
	Entities.add_element(Entities.entitylist.herb,{41,337})
	Entities.add_element(Entities.entitylist.herb,{25,183})
	Entities.add_element(Entities.entitylist.cactus,{112,442})
	Entities.add_element(Entities.entitylist.cactus,{332,410})
	Entities.add_element(Entities.entitylist.cactus,{401,288})
	Entities.add_element(Entities.entitylist.cactus,{451,39})
	Entities.add_element(Entities.entitylist.cactus,{29,26})
	Entities.add_element(Entities.entitylist.pile,{274,443})
	Entities.add_element(Entities.entitylist.barrel,{520,263})
	Entities.add_element(Entities.entitylist.crate,{629,219})
	Entities.add_element(Entities.entitylist.crate,{613,232})
	Entities.add_element(Entities.entitylist.crate,{595,246})
	Entities.add_element(Entities.entitylist.barrel,{520,332})
	Entities.add_element(Entities.entitylist.barrel,{84,381})
	Entities.add_element(Entities.entitylist.barrel,{23,381})
	Entities.add_element(Entities.entitylist.barrel,{9,381})
	Entities.add_element(Entities.entitylist.barber,{532,80})
	Entities.add_element(Entities.entitylist.crate,{424,99})
	Entities.add_element(Entities.entitylist.crate,{448,99})
	Entities.add_element(Entities.entitylist.barrel,{575,12})
	Entities.add_element(Entities.entitylist.sheriff_box,{259,360})
	Entities.add_element(Entities.entitylist.stable,{232,230})
	Entities.add_element(Entities.entitylist.bank,{153,358})
	Entities.add_element(Entities.entitylist.tiny_house,{336,326})
	Entities.add_element(Entities.entitylist.barber,{305,158})
	Entities.add_element(Entities.entitylist.warehouse,{380,128})
	Entities.add_element(Entities.entitylist.mansion,{426,393})
	Entities.add_element(Entities.entitylist.house,{516,378})
	Entities.add_element(Entities.entitylist.red_bandit,{169,126})
	Entities.add_element(Entities.entitylist.green_bandit,{322,78})
	Entities.add_element(Entities.entitylist.yellow_bandit,{524,24})
	Entities.add_element(Entities.entitylist.yellow_bandit,{448,127})
	Entities.add_element(Entities.entitylist.yellow_bandit,{335,383})
	Entities.add_element(Entities.entitylist.green_bandit,{68,171})
	Entities.add_element(Entities.entitylist.blue_bandit,{20,65})
	Entities.add_element(Entities.entitylist.blue_bandit,{180,262})
	Entities.add_element(Entities.entitylist.yellow_bandit,{52,381})

end
function Level.load_lvl10()
	Entities.add_element(Entities.entitylist.player,{456,43})
	Entities.add_element(Entities.entitylist.barrier_horiz,{383,93},7)
	Entities.add_element(Entities.entitylist.house,{611,240})
	Entities.add_element(Entities.entitylist.warehouse,{506,228})
	Entities.add_element(Entities.entitylist.cactus,{250,267})
	Entities.add_element(Entities.entitylist.cactus,{392,265})
	Entities.add_element(Entities.entitylist.dead_branch,{572,435})
	Entities.add_element(Entities.entitylist.herb,{36,316})
	Entities.add_element(Entities.entitylist.herb,{220,73})
	Entities.add_element(Entities.entitylist.herb,{520,31})
	Entities.add_element(Entities.entitylist.herb,{609,317})
	Entities.add_element(Entities.entitylist.stable,{139,263})
	Entities.add_element(Entities.entitylist.well,{488,304})
	Entities.add_element(Entities.entitylist.saloon,{539,126})
	Entities.add_element(Entities.entitylist.cactus,{201,443})
	Entities.add_element(Entities.entitylist.herb,{429,457})
	Entities.add_element(Entities.entitylist.bush,{12,53})
	Entities.add_element(Entities.entitylist.bush,{50,13})
	Entities.add_element(Entities.entitylist.bush,{33,37})
	Entities.add_element(Entities.entitylist.warehouse,{28,226})
	Entities.add_element(Entities.entitylist.sheriff_box,{307,111})
	Entities.add_element(Entities.entitylist.warehouse,{141,139})
	Entities.add_element(Entities.entitylist.pile,{86,93})
	Entities.add_element(Entities.entitylist.house,{316,193})
	Entities.add_element(Entities.entitylist.barrel,{316,152})
	Entities.add_element(Entities.entitylist.generic_house,{110,387})
	Entities.add_element(Entities.entitylist.barber,{527,350})
	Entities.add_element(Entities.entitylist.crate,{486,386})
	Entities.add_element(Entities.entitylist.crate,{486,403})
	Entities.add_element(Entities.entitylist.crate,{486,420})
	Entities.add_element(Entities.entitylist.smith,{336,317})
	Entities.add_element(Entities.entitylist.barrier_horiz,{281,366},7)
	Entities.add_element(Entities.entitylist.crate,{382,385})
	Entities.add_element(Entities.entitylist.crate,{382,402})
	Entities.add_element(Entities.entitylist.tiny_house,{273,450})
	Entities.add_element(Entities.entitylist.crate,{382,420})
	Entities.add_element(Entities.entitylist.blue_bandit,{397,141})
	Entities.add_element(Entities.entitylist.red_bandit,{457,198})
	Entities.add_element(Entities.entitylist.red_bandit,{428,178})
	Entities.add_element(Entities.entitylist.green_bandit,{368,176})
	Entities.add_element(Entities.entitylist.yellow_bandit,{415,206})
	Entities.add_element(Entities.entitylist.yellow_bandit,{442,271})
	Entities.add_element(Entities.entitylist.red_bandit,{204,181})
	Entities.add_element(Entities.entitylist.yellow_bandit,{198,292})
	Entities.add_element(Entities.entitylist.blue_bandit,{217,238})
	Entities.add_element(Entities.entitylist.blue_bandit,{245,328})
	Entities.add_element(Entities.entitylist.red_bandit,{251,190})
	Entities.add_element(Entities.entitylist.blue_bandit,{202,248})

end

------------------------------------------------------------------------------
function Level.load_lvl1_hard()
	Entities.add_element(Entities.entitylist.player,{67,79})
	Entities.add_element(Entities.entitylist.bank,{387,342})
	Entities.add_element(Entities.entitylist.house,{155,319})
	Entities.add_element(Entities.entitylist.herb,{265,468})
	Entities.add_element(Entities.entitylist.bush,{30,381})
	Entities.add_element(Entities.entitylist.fence_vert,{22,295},8)
	Entities.add_element(Entities.entitylist.fence_horiz,{105,236},4)
	Entities.add_element(Entities.entitylist.fence_vert,{601,336},4)
	Entities.add_element(Entities.entitylist.barrier_horiz,{549,445},2)
	Entities.add_element(Entities.entitylist.bush,{504,442})
	Entities.add_element(Entities.entitylist.bush,{457,442})
	Entities.add_element(Entities.entitylist.bush,{482,442})
	Entities.add_element(Entities.entitylist.cactus,{93,203})
	Entities.add_element(Entities.entitylist.herb,{603,250})
	Entities.add_element(Entities.entitylist.herb,{24,201})
	Entities.add_element(Entities.entitylist.church,{598,408})
	Entities.add_element(Entities.entitylist.house,{50,427})
	Entities.add_element(Entities.entitylist.fence_horiz,{263,450},9)
	Entities.add_element(Entities.entitylist.barrier_horiz,{383,445},4)
	Entities.add_element(Entities.entitylist.bank,{140,426})
	Entities.add_element(Entities.entitylist.warehouse,{500,103})
	Entities.add_element(Entities.entitylist.house,{590,83})
	Entities.add_element(Entities.entitylist.cactus,{573,25})
	Entities.add_element(Entities.entitylist.house,{590,143})
	Entities.add_element(Entities.entitylist.bush,{543,59})
	Entities.add_element(Entities.entitylist.warehouse,{257,336})
	Entities.add_element(Entities.entitylist.barrier_horiz,{337,231},7)
	Entities.add_element(Entities.entitylist.sheriff_box,{476,249})
	Entities.add_element(Entities.entitylist.cactus,{377,18})
	Entities.add_element(Entities.entitylist.herb,{78,23})
	Entities.add_element(Entities.entitylist.barrier_vert,{25,93},3)
	Entities.add_element(Entities.entitylist.bank,{83,149})
	Entities.add_element(Entities.entitylist.mansion,{179,198})
	Entities.add_element(Entities.entitylist.well,{190,108})
	Entities.add_element(Entities.entitylist.fence_horiz,{251,52},32)
	Entities.add_element(Entities.entitylist.barrier_horiz,{51,231},2)
	Entities.add_element(Entities.entitylist.house,{50,425})
	Entities.add_element(Entities.entitylist.fence_vert,{562,250},3)
	Entities.add_element(Entities.entitylist.house,{590,203})
	Entities.add_element(Entities.entitylist.house,{590,296})
	Entities.add_element(Entities.entitylist.barber,{287,133})
	Entities.add_element(Entities.entitylist.barber,{425,133})
	Entities.add_element(Entities.entitylist.red_bandit,{91,319})
	Entities.add_element(Entities.entitylist.blue_bandit,{145,373})
	Entities.add_element(Entities.entitylist.blue_bandit,{491,351})
	Entities.add_element(Entities.entitylist.blue_bandit,{284,189})
	Entities.add_element(Entities.entitylist.blue_bandit,{307,338})
end
function Level.load_lvl2_hard()
	Entities.add_element(Entities.entitylist.player,{307,208})
	Entities.add_element(Entities.entitylist.barrier_vert,{277,258},8)
	Entities.add_element(Entities.entitylist.barrier_horiz,{146,227},6)
	Entities.add_element(Entities.entitylist.barrier_horiz,{43,227},1)
	Entities.add_element(Entities.entitylist.barrier_vert,{339,311},5)
	Entities.add_element(Entities.entitylist.herb,{63,258})
	Entities.add_element(Entities.entitylist.herb,{120,140})
	Entities.add_element(Entities.entitylist.herb,{259,30})
	Entities.add_element(Entities.entitylist.herb,{370,78})
	Entities.add_element(Entities.entitylist.herb,{232,407})
	Entities.add_element(Entities.entitylist.cactus,{46,426})
	Entities.add_element(Entities.entitylist.bank,{181,245})
	Entities.add_element(Entities.entitylist.warehouse,{214,327})
	Entities.add_element(Entities.entitylist.barrier_vert,{67,434},3)
	Entities.add_element(Entities.entitylist.church,{86,348})
	Entities.add_element(Entities.entitylist.barrier_vert,{29,322},6)
	Entities.add_element(Entities.entitylist.bank,{87,245})
	Entities.add_element(Entities.entitylist.saloon,{436,403})
	Entities.add_element(Entities.entitylist.sheriff_box,{96,70})
	Entities.add_element(Entities.entitylist.church,{223,69})
	Entities.add_element(Entities.entitylist.barrier_vert,{277,32},3)
	Entities.add_element(Entities.entitylist.barrier_vert,{381,204},7)
	Entities.add_element(Entities.entitylist.barrier_vert,{339,110},5)
	Entities.add_element(Entities.entitylist.barrier_horiz,{28,163},2)
	Entities.add_element(Entities.entitylist.cactus,{29,115})
	Entities.add_element(Entities.entitylist.herb,{135,191})
	Entities.add_element(Entities.entitylist.barrier_horiz,{404,42},4)
	Entities.add_element(Entities.entitylist.house,{137,123})
	Entities.add_element(Entities.entitylist.barrier_horiz,{217,163},4)
	Entities.add_element(Entities.entitylist.barrier_horiz,{254,435},8)
	Entities.add_element(Entities.entitylist.barrier_horiz,{428,103},3)
	Entities.add_element(Entities.entitylist.well,{538,106})
	Entities.add_element(Entities.entitylist.smith,{496,203})
	Entities.add_element(Entities.entitylist.herb,{560,343})
	Entities.add_element(Entities.entitylist.cactus,{417,264})
	Entities.add_element(Entities.entitylist.herb,{621,21})
	Entities.add_element(Entities.entitylist.cactus,{138,363})
	Entities.add_element(Entities.entitylist.barrier_horiz,{492,304},7)
	Entities.add_element(Entities.entitylist.barrier_vert,{597,147},6)
	Entities.add_element(Entities.entitylist.barrier_horiz,{554,42},3)
	Entities.add_element(Entities.entitylist.house,{571,400})
	Entities.add_element(Entities.entitylist.yellow_bandit,{198,135})
	Entities.add_element(Entities.entitylist.yellow_bandit,{147,326})
	Entities.add_element(Entities.entitylist.yellow_bandit,{404,201})
	Entities.add_element(Entities.entitylist.yellow_bandit,{82,133})
	Entities.add_element(Entities.entitylist.yellow_bandit,{515,460})
	Entities.add_element(Entities.entitylist.yellow_bandit,{623,212})

end
function Level.load_lvl3_hard()
	Entities.add_element(Entities.entitylist.player,{369,231})
	Entities.add_element(Entities.entitylist.bank,{402,313})
	Entities.add_element(Entities.entitylist.mansion,{236,149})
	Entities.add_element(Entities.entitylist.house,{116,163})
	Entities.add_element(Entities.entitylist.barrel,{195,233})
	Entities.add_element(Entities.entitylist.barrel,{195,246})
	Entities.add_element(Entities.entitylist.barrel,{195,260})
	Entities.add_element(Entities.entitylist.barrel,{195,275})
	Entities.add_element(Entities.entitylist.barrel,{195,289})
	Entities.add_element(Entities.entitylist.warehouse,{265,448})
	Entities.add_element(Entities.entitylist.saloon,{542,76})
	Entities.add_element(Entities.entitylist.barrier_horiz,{40,184},3)
	Entities.add_element(Entities.entitylist.sheriff_box,{490,452})
	Entities.add_element(Entities.entitylist.herb,{440,150})
	Entities.add_element(Entities.entitylist.herb,{196,444})
	Entities.add_element(Entities.entitylist.herb,{445,367})
	Entities.add_element(Entities.entitylist.herb,{600,425})
	Entities.add_element(Entities.entitylist.cactus,{567,414})
	Entities.add_element(Entities.entitylist.cactus,{220,253})
	Entities.add_element(Entities.entitylist.cactus,{177,54})
	Entities.add_element(Entities.entitylist.cactus,{457,42})
	Entities.add_element(Entities.entitylist.saloon,{553,327})
	Entities.add_element(Entities.entitylist.mansion,{86,395})
	Entities.add_element(Entities.entitylist.bank,{85,63})
	Entities.add_element(Entities.entitylist.bank,{232,359})
	Entities.add_element(Entities.entitylist.sheriff_box,{342,165})
	Entities.add_element(Entities.entitylist.sheriff_box,{295,254})
	Entities.add_element(Entities.entitylist.warehouse,{118,245})
	Entities.add_element(Entities.entitylist.warehouse,{368,376})
	Entities.add_element(Entities.entitylist.barber,{379,59})
	Entities.add_element(Entities.entitylist.mansion,{542,165})
	Entities.add_element(Entities.entitylist.barber,{472,225})
	Entities.add_element(Entities.entitylist.house,{301,74})
	Entities.add_element(Entities.entitylist.barrel,{155,95})
	Entities.add_element(Entities.entitylist.barrel,{167,107})
	Entities.add_element(Entities.entitylist.cactus,{46,265})
	Entities.add_element(Entities.entitylist.crate,{159,381})
	Entities.add_element(Entities.entitylist.red_bandit,{606,459})
	Entities.add_element(Entities.entitylist.red_bandit,{216,423})
	Entities.add_element(Entities.entitylist.red_bandit,{17,217})
	Entities.add_element(Entities.entitylist.red_bandit,{41,133})
	Entities.add_element(Entities.entitylist.red_bandit,{618,15})
	Entities.add_element(Entities.entitylist.red_bandit,{369,464})

end
function Level.load_lvl4_hard()
	Entities.add_element(Entities.entitylist.player,{69,36})
	Entities.add_element(Entities.entitylist.barrier_horiz,{329,185},10)
	Entities.add_element(Entities.entitylist.barrier_vert,{125,174},7)
	Entities.add_element(Entities.entitylist.bank,{370,260})
	Entities.add_element(Entities.entitylist.warehouse,{403,326})
	Entities.add_element(Entities.entitylist.house,{293,110})
	Entities.add_element(Entities.entitylist.house,{352,110})
	Entities.add_element(Entities.entitylist.house,{411,110})
	Entities.add_element(Entities.entitylist.house,{470,110})
	Entities.add_element(Entities.entitylist.warehouse,{583,245})
	Entities.add_element(Entities.entitylist.warehouse,{583,318})
	Entities.add_element(Entities.entitylist.barrel,{178,201})
	Entities.add_element(Entities.entitylist.barrel,{175,215})
	Entities.add_element(Entities.entitylist.barrel,{167,226})
	Entities.add_element(Entities.entitylist.barrel,{161,238})
	Entities.add_element(Entities.entitylist.dead_branch,{59,277})
	Entities.add_element(Entities.entitylist.dead_branch,{289,427})
	Entities.add_element(Entities.entitylist.herb,{101,221})
	Entities.add_element(Entities.entitylist.herb,{198,405})
	Entities.add_element(Entities.entitylist.herb,{399,428})
	Entities.add_element(Entities.entitylist.herb,{304,317})
	Entities.add_element(Entities.entitylist.herb,{454,211})
	Entities.add_element(Entities.entitylist.herb,{518,324})
	Entities.add_element(Entities.entitylist.herb,{528,175})
	Entities.add_element(Entities.entitylist.herb,{623,410})
	Entities.add_element(Entities.entitylist.herb,{614,103})
	Entities.add_element(Entities.entitylist.barrier_horiz,{78,83},3)
	Entities.add_element(Entities.entitylist.bush,{17,82})
	Entities.add_element(Entities.entitylist.barrier_vert,{350,19},2)
	Entities.add_element(Entities.entitylist.barrier_vert,{234,66},2)
	Entities.add_element(Entities.entitylist.herb,{293,33})
	Entities.add_element(Entities.entitylist.herb,{175,81})
	Entities.add_element(Entities.entitylist.bush,{366,16})
	Entities.add_element(Entities.entitylist.house,{234,110})
	Entities.add_element(Entities.entitylist.fence_horiz,{490,36},11)
	Entities.add_element(Entities.entitylist.barrier_horiz,{295,279},1)
	Entities.add_element(Entities.entitylist.mansion,{520,401})
	Entities.add_element(Entities.entitylist.mansion,{551,401})
	Entities.add_element(Entities.entitylist.barrier_vert,{570,64},2)
	Entities.add_element(Entities.entitylist.dead_branch,{560,62})
	Entities.add_element(Entities.entitylist.dead_tree,{577,62})
	Entities.add_element(Entities.entitylist.sheriff_box,{46,156})
	Entities.add_element(Entities.entitylist.church,{217,307})
	Entities.add_element(Entities.entitylist.barrier_vert,{481,253},4)
	Entities.add_element(Entities.entitylist.barrier_horiz,{210,359},8)
	Entities.add_element(Entities.entitylist.herb,{42,46})
	Entities.add_element(Entities.entitylist.barrel,{122,43})
	Entities.add_element(Entities.entitylist.barrel,{122,20})
	Entities.add_element(Entities.entitylist.house,{114,448})
	Entities.add_element(Entities.entitylist.green_bandit,{361,315})
	Entities.add_element(Entities.entitylist.green_bandit,{318,156})
	Entities.add_element(Entities.entitylist.green_bandit,{386,56})
	Entities.add_element(Entities.entitylist.green_bandit,{25,222})
	Entities.add_element(Entities.entitylist.green_bandit,{214,447})
	Entities.add_element(Entities.entitylist.green_bandit,{518,260})
	Entities.add_element(Entities.entitylist.green_bandit,{627,196})

end
function Level.load_lvl5_hard()
	Entities.add_element(Entities.entitylist.player,{571,464})
	Entities.add_element(Entities.entitylist.cactus,{110,428})
	Entities.add_element(Entities.entitylist.cactus,{439,99})
	Entities.add_element(Entities.entitylist.cactus,{277,410})
	Entities.add_element(Entities.entitylist.herb,{279,76})
	Entities.add_element(Entities.entitylist.herb,{457,290})
	Entities.add_element(Entities.entitylist.herb,{188,447})
	Entities.add_element(Entities.entitylist.barrel,{597,261})
	Entities.add_element(Entities.entitylist.barrel,{597,288})
	Entities.add_element(Entities.entitylist.saloon,{543,349})
	Entities.add_element(Entities.entitylist.barrier_horiz,{476,437},8)
	Entities.add_element(Entities.entitylist.warehouse,{323,159})
	Entities.add_element(Entities.entitylist.barrier_horiz,{435,46},9)
	Entities.add_element(Entities.entitylist.warehouse,{575,92})
	Entities.add_element(Entities.entitylist.herb,{173,36})
	Entities.add_element(Entities.entitylist.smith,{178,204})
	Entities.add_element(Entities.entitylist.barrel,{226,146})
	Entities.add_element(Entities.entitylist.church,{210,76})
	Entities.add_element(Entities.entitylist.mansion,{543,195})
	Entities.add_element(Entities.entitylist.house,{100,338})
	Entities.add_element(Entities.entitylist.house,{58,88})
	Entities.add_element(Entities.entitylist.pile,{270,289})
	Entities.add_element(Entities.entitylist.warehouse,{323,335})
	Entities.add_element(Entities.entitylist.barrier_vert,{422,361},2)
	Entities.add_element(Entities.entitylist.barrier_vert,{422,245},9)
	Entities.add_element(Entities.entitylist.warehouse,{214,358})
	Entities.add_element(Entities.entitylist.barrel,{233,253})
	Entities.add_element(Entities.entitylist.barrel,{241,274})
	Entities.add_element(Entities.entitylist.crate,{234,425})
	Entities.add_element(Entities.entitylist.house,{155,88})
	Entities.add_element(Entities.entitylist.house,{-2,88})
	Entities.add_element(Entities.entitylist.cactus,{43,195})
	Entities.add_element(Entities.entitylist.herb,{71,271})
	Entities.add_element(Entities.entitylist.bush,{596,464})
	Entities.add_element(Entities.entitylist.blue_bandit,{92,195})
	Entities.add_element(Entities.entitylist.blue_bandit,{50,343})
	Entities.add_element(Entities.entitylist.blue_bandit,{154,345})
	Entities.add_element(Entities.entitylist.yellow_bandit,{390,340})
	Entities.add_element(Entities.entitylist.yellow_bandit,{386,178})
	Entities.add_element(Entities.entitylist.blue_bandit,{449,334})
	Entities.add_element(Entities.entitylist.green_bandit,{455,137})
	Entities.add_element(Entities.entitylist.red_bandit,{265,342})

end
function Level.load_lvl6_hard()
	Entities.add_element(Entities.entitylist.player,{263,215})
	Entities.add_element(Entities.entitylist.warehouse,{92,423})
	Entities.add_element(Entities.entitylist.barrel,{161,195})
	Entities.add_element(Entities.entitylist.fence_horiz,{61,229},5)
	Entities.add_element(Entities.entitylist.house,{557,56})
	Entities.add_element(Entities.entitylist.fence_vert,{554,98},2)
	Entities.add_element(Entities.entitylist.bush,{78,12})
	Entities.add_element(Entities.entitylist.bush,{78,37})
	Entities.add_element(Entities.entitylist.saloon,{285,98})
	Entities.add_element(Entities.entitylist.saloon,{436,98})
	Entities.add_element(Entities.entitylist.house,{115,232})
	Entities.add_element(Entities.entitylist.house,{115,291})
	Entities.add_element(Entities.entitylist.barrier_horiz,{286,181},3)
	Entities.add_element(Entities.entitylist.warehouse,{219,227})
	Entities.add_element(Entities.entitylist.house,{557,141})
	Entities.add_element(Entities.entitylist.warehouse,{61,111})
	Entities.add_element(Entities.entitylist.barrier_horiz,{361,12},8)
	Entities.add_element(Entities.entitylist.mansion,{209,410})
	Entities.add_element(Entities.entitylist.sheriff_box,{386,307})
	Entities.add_element(Entities.entitylist.fence_vert,{304,392},7)
	Entities.add_element(Entities.entitylist.sheriff_box,{293,307})
	Entities.add_element(Entities.entitylist.barrier_vert,{29,337},7)
	Entities.add_element(Entities.entitylist.barrier_horiz,{147,324},4)
	Entities.add_element(Entities.entitylist.generic_house,{433,448})
	Entities.add_element(Entities.entitylist.generic_house,{433,410})
	Entities.add_element(Entities.entitylist.church,{453,235})
	Entities.add_element(Entities.entitylist.stable,{561,342})
	Entities.add_element(Entities.entitylist.well,{484,327})
	Entities.add_element(Entities.entitylist.tiny_house,{163,83})
	Entities.add_element(Entities.entitylist.tiny_house,{163,143})
	Entities.add_element(Entities.entitylist.barrier_horiz,{493,181},6)
	Entities.add_element(Entities.entitylist.red_bandit,{180,199})
	Entities.add_element(Entities.entitylist.green_bandit,{110,173})
	Entities.add_element(Entities.entitylist.yellow_bandit,{46,463})
	Entities.add_element(Entities.entitylist.yellow_bandit,{605,98})
	Entities.add_element(Entities.entitylist.blue_bandit,{630,385})
	Entities.add_element(Entities.entitylist.yellow_bandit,{359,36})
	Entities.add_element(Entities.entitylist.red_bandit,{334,390})
	Entities.add_element(Entities.entitylist.yellow_bandit,{330,437})

end
function Level.load_lvl7_hard()
	Entities.add_element(Entities.entitylist.player,{613,36})
	Entities.add_element(Entities.entitylist.barber,{593,162})
	Entities.add_element(Entities.entitylist.barrel,{448,155})
	Entities.add_element(Entities.entitylist.mansion,{499,44})
	Entities.add_element(Entities.entitylist.warehouse,{448,290})
	Entities.add_element(Entities.entitylist.house,{451,202})
	Entities.add_element(Entities.entitylist.barber,{523,253})
	Entities.add_element(Entities.entitylist.well,{455,462})
	Entities.add_element(Entities.entitylist.cactus,{378,44})
	Entities.add_element(Entities.entitylist.cactus,{513,150})
	Entities.add_element(Entities.entitylist.cactus,{613,311})
	Entities.add_element(Entities.entitylist.herb,{501,446})
	Entities.add_element(Entities.entitylist.fence_vert,{255,201},6)
	Entities.add_element(Entities.entitylist.bush,{345,175})
	Entities.add_element(Entities.entitylist.bush,{278,196})
	Entities.add_element(Entities.entitylist.bush,{334,224})
	Entities.add_element(Entities.entitylist.house,{451,109})
	Entities.add_element(Entities.entitylist.barrier_horiz,{439,395},5)
	Entities.add_element(Entities.entitylist.fence_horiz,{310,153},8)
	Entities.add_element(Entities.entitylist.fence_horiz,{310,254},8)
	Entities.add_element(Entities.entitylist.fence_vert,{366,201},6)
	Entities.add_element(Entities.entitylist.stable,{171,225})
	Entities.add_element(Entities.entitylist.dead_tree,{309,192})
	Entities.add_element(Entities.entitylist.sheriff_box,{563,378})
	Entities.add_element(Entities.entitylist.tiny_house,{579,417})
	Entities.add_element(Entities.entitylist.saloon,{308,334})
	Entities.add_element(Entities.entitylist.generic_house,{312,411})
	Entities.add_element(Entities.entitylist.fence_horiz,{331,76},5)
	Entities.add_element(Entities.entitylist.crate,{361,85})
	Entities.add_element(Entities.entitylist.fence_horiz,{123,76},5)
	Entities.add_element(Entities.entitylist.dead_branch,{48,329})
	Entities.add_element(Entities.entitylist.bush,{120,139})
	Entities.add_element(Entities.entitylist.bush,{18,172})
	Entities.add_element(Entities.entitylist.bush,{114,336})
	Entities.add_element(Entities.entitylist.herb,{23,288})
	Entities.add_element(Entities.entitylist.mill,{79,245})
	Entities.add_element(Entities.entitylist.dead_tree,{37,191})
	Entities.add_element(Entities.entitylist.dead_branch,{114,190})
	Entities.add_element(Entities.entitylist.herb,{118,255})
	Entities.add_element(Entities.entitylist.bush,{24,354})
	Entities.add_element(Entities.entitylist.barber,{194,97})
	Entities.add_element(Entities.entitylist.generic_house,{35,103})
	Entities.add_element(Entities.entitylist.pile,{271,81})
	Entities.add_element(Entities.entitylist.fence_horiz,{77,384},12)
	Entities.add_element(Entities.entitylist.church,{175,342})
	Entities.add_element(Entities.entitylist.yellow_bandit,{51,31})
	Entities.add_element(Entities.entitylist.blue_bandit,{221,147})
	Entities.add_element(Entities.entitylist.red_bandit,{221,359})
	Entities.add_element(Entities.entitylist.yellow_bandit,{428,460})
	Entities.add_element(Entities.entitylist.red_bandit,{491,294})

end
function Level.load_lvl8_hard()
	Entities.add_element(Entities.entitylist.player,{283,265})
	Entities.add_element(Entities.entitylist.generic_house,{231,65})
	Entities.add_element(Entities.entitylist.tiny_house,{336,267})
	Entities.add_element(Entities.entitylist.tiny_house,{30,115})
	Entities.add_element(Entities.entitylist.smith,{97,233})
	Entities.add_element(Entities.entitylist.saloon,{466,203})
	Entities.add_element(Entities.entitylist.herb,{581,439})
	Entities.add_element(Entities.entitylist.herb,{591,155})
	Entities.add_element(Entities.entitylist.herb,{329,40})
	Entities.add_element(Entities.entitylist.herb,{167,169})
	Entities.add_element(Entities.entitylist.herb,{41,337})
	Entities.add_element(Entities.entitylist.cactus,{112,442})
	Entities.add_element(Entities.entitylist.cactus,{451,39})
	Entities.add_element(Entities.entitylist.crate,{629,219})
	Entities.add_element(Entities.entitylist.crate,{613,232})
	Entities.add_element(Entities.entitylist.crate,{595,246})
	Entities.add_element(Entities.entitylist.barrel,{84,382})
	Entities.add_element(Entities.entitylist.barrel,{23,382})
	Entities.add_element(Entities.entitylist.barrel,{9,382})
	Entities.add_element(Entities.entitylist.barber,{532,80})
	Entities.add_element(Entities.entitylist.stable,{232,230})
	Entities.add_element(Entities.entitylist.bank,{153,359})
	Entities.add_element(Entities.entitylist.tiny_house,{336,326})
	Entities.add_element(Entities.entitylist.barber,{305,158})
	Entities.add_element(Entities.entitylist.warehouse,{380,128})
	Entities.add_element(Entities.entitylist.mansion,{426,393})
	Entities.add_element(Entities.entitylist.house,{516,378})
	Entities.add_element(Entities.entitylist.cactus,{475,296})
	Entities.add_element(Entities.entitylist.cactus,{276,410})
	Entities.add_element(Entities.entitylist.barrel,{111,88})
	Entities.add_element(Entities.entitylist.barrel,{111,69})
	Entities.add_element(Entities.entitylist.barrel,{111,50})
	Entities.add_element(Entities.entitylist.church,{111,145})
	Entities.add_element(Entities.entitylist.cactus,{50,35})
	Entities.add_element(Entities.entitylist.herb,{20,178})
	Entities.add_element(Entities.entitylist.pile,{621,395})
	Entities.add_element(Entities.entitylist.well,{204,464})
	Entities.add_element(Entities.entitylist.bush,{292,342})
	Entities.add_element(Entities.entitylist.bush,{268,345})
	Entities.add_element(Entities.entitylist.bush,{355,221})
	Entities.add_element(Entities.entitylist.bush,{355,202})
	Entities.add_element(Entities.entitylist.red_bandit,{169,126})
	Entities.add_element(Entities.entitylist.yellow_bandit,{524,24})
	Entities.add_element(Entities.entitylist.blue_bandit,{20,65})
	Entities.add_element(Entities.entitylist.blue_bandit,{180,262})
	Entities.add_element(Entities.entitylist.yellow_bandit,{52,381})
	Entities.add_element(Entities.entitylist.yellow_bandit,{393,325})
	Entities.add_element(Entities.entitylist.green_bandit,{21,219})

end
function Level.load_lvl9_hard()
	Entities.add_element(Entities.entitylist.player,{315,249})
	Entities.add_element(Entities.entitylist.barrier_horiz,{383,93},7)
	Entities.add_element(Entities.entitylist.house,{611,240})
	Entities.add_element(Entities.entitylist.warehouse,{506,228})
	Entities.add_element(Entities.entitylist.dead_branch,{572,435})
	Entities.add_element(Entities.entitylist.herb,{36,316})
	Entities.add_element(Entities.entitylist.herb,{220,73})
	Entities.add_element(Entities.entitylist.herb,{520,31})
	Entities.add_element(Entities.entitylist.herb,{609,317})
	Entities.add_element(Entities.entitylist.stable,{139,263})
	Entities.add_element(Entities.entitylist.well,{488,304})
	Entities.add_element(Entities.entitylist.saloon,{539,126})
	Entities.add_element(Entities.entitylist.cactus,{201,443})
	Entities.add_element(Entities.entitylist.herb,{429,457})
	Entities.add_element(Entities.entitylist.bush,{12,53})
	Entities.add_element(Entities.entitylist.bush,{50,13})
	Entities.add_element(Entities.entitylist.bush,{33,37})
	Entities.add_element(Entities.entitylist.warehouse,{28,226})
	Entities.add_element(Entities.entitylist.sheriff_box,{307,111})
	Entities.add_element(Entities.entitylist.warehouse,{141,139})
	Entities.add_element(Entities.entitylist.pile,{86,93})
	Entities.add_element(Entities.entitylist.house,{316,193})
	Entities.add_element(Entities.entitylist.barrel,{316,152})
	Entities.add_element(Entities.entitylist.generic_house,{110,387})
	Entities.add_element(Entities.entitylist.barber,{527,350})
	Entities.add_element(Entities.entitylist.crate,{486,386})
	Entities.add_element(Entities.entitylist.crate,{486,403})
	Entities.add_element(Entities.entitylist.crate,{486,420})
	Entities.add_element(Entities.entitylist.smith,{336,317})
	Entities.add_element(Entities.entitylist.barrier_horiz,{281,366},7)
	Entities.add_element(Entities.entitylist.crate,{382,385})
	Entities.add_element(Entities.entitylist.crate,{382,402})
	Entities.add_element(Entities.entitylist.tiny_house,{273,450})
	Entities.add_element(Entities.entitylist.crate,{382,420})
	Entities.add_element(Entities.entitylist.cactus,{422,193})
	Entities.add_element(Entities.entitylist.cactus,{223,292})
	Entities.add_element(Entities.entitylist.red_bandit,{21,117})
	Entities.add_element(Entities.entitylist.red_bandit,{118,450})
	Entities.add_element(Entities.entitylist.blue_bandit,{90,332})
	Entities.add_element(Entities.entitylist.yellow_bandit,{340,399})
	Entities.add_element(Entities.entitylist.green_bandit,{522,303})
	Entities.add_element(Entities.entitylist.yellow_bandit,{563,192})
	Entities.add_element(Entities.entitylist.red_bandit,{514,406})
	Entities.add_element(Entities.entitylist.blue_bandit,{611,347})
	Entities.add_element(Entities.entitylist.blue_bandit,{198,404})

end
function Level.load_lvl10_hard()
	Entities.add_element(Entities.entitylist.player,{436,34})
	Entities.add_element(Entities.entitylist.barrier_vert,{474,180},7)
	Entities.add_element(Entities.entitylist.fence_horiz,{247,191},7)
	Entities.add_element(Entities.entitylist.fence_horiz,{185,85},7)
	Entities.add_element(Entities.entitylist.stable,{377,99})
	Entities.add_element(Entities.entitylist.warehouse,{110,136})
	Entities.add_element(Entities.entitylist.bank,{144,193})
	Entities.add_element(Entities.entitylist.house,{258,76})
	Entities.add_element(Entities.entitylist.bush,{221,121})
	Entities.add_element(Entities.entitylist.bush,{204,146})
	Entities.add_element(Entities.entitylist.tiny_house,{322,169})
	Entities.add_element(Entities.entitylist.fence_vert,{564,157},6)
	Entities.add_element(Entities.entitylist.sheriff_box,{518,83})
	Entities.add_element(Entities.entitylist.fence_horiz,{519,170},6)
	Entities.add_element(Entities.entitylist.barrel,{563,213})
	Entities.add_element(Entities.entitylist.barrel,{551,213})
	Entities.add_element(Entities.entitylist.barrel,{575,213})
	Entities.add_element(Entities.entitylist.church,{331,431})
	Entities.add_element(Entities.entitylist.smith,{203,417})
	Entities.add_element(Entities.entitylist.fence_horiz,{290,408},5)
	Entities.add_element(Entities.entitylist.fence_horiz,{71,283},3)
	Entities.add_element(Entities.entitylist.bush,{63,341})
	Entities.add_element(Entities.entitylist.bush,{80,341})
	Entities.add_element(Entities.entitylist.bush,{160,467})
	Entities.add_element(Entities.entitylist.bush,{447,429})
	Entities.add_element(Entities.entitylist.bush,{458,448})
	Entities.add_element(Entities.entitylist.bush,{472,466})
	Entities.add_element(Entities.entitylist.fence_vert,{540,440},5)
	Entities.add_element(Entities.entitylist.barrier_horiz,{401,401},4)
	Entities.add_element(Entities.entitylist.well,{42,42})
	Entities.add_element(Entities.entitylist.herb,{29,192})
	Entities.add_element(Entities.entitylist.herb,{186,29})
	Entities.add_element(Entities.entitylist.herb,{600,33})
	Entities.add_element(Entities.entitylist.herb,{379,233})
	Entities.add_element(Entities.entitylist.herb,{502,375})
	Entities.add_element(Entities.entitylist.cactus,{512,227})
	Entities.add_element(Entities.entitylist.cactus,{234,239})
	Entities.add_element(Entities.entitylist.cactus,{81,438})
	Entities.add_element(Entities.entitylist.cactus,{615,252})
	Entities.add_element(Entities.entitylist.fence_horiz,{389,293},5)
	Entities.add_element(Entities.entitylist.fence_horiz,{387,283},5)
	Entities.add_element(Entities.entitylist.house,{448,270})
	Entities.add_element(Entities.entitylist.barber,{309,304})
	Entities.add_element(Entities.entitylist.generic_house,{154,310})
	Entities.add_element(Entities.entitylist.barrier_vert,{52,345},4)
	Entities.add_element(Entities.entitylist.bush,{603,390})
	Entities.add_element(Entities.entitylist.bush,{627,390})
	Entities.add_element(Entities.entitylist.warehouse,{565,347})
	Entities.add_element(Entities.entitylist.red_bandit,{510,138})
	Entities.add_element(Entities.entitylist.red_bandit,{176,120})
	Entities.add_element(Entities.entitylist.red_bandit,{398,450})
	Entities.add_element(Entities.entitylist.green_bandit,{73,308})
	Entities.add_element(Entities.entitylist.yellow_bandit,{285,443})
	Entities.add_element(Entities.entitylist.yellow_bandit,{267,442})
	Entities.add_element(Entities.entitylist.blue_bandit,{581,447})
	Entities.add_element(Entities.entitylist.blue_bandit,{538,142})
	Entities.add_element(Entities.entitylist.blue_bandit,{150,126})
	Entities.add_element(Entities.entitylist.green_bandit,{424,461})
	Entities.add_element(Entities.entitylist.yellow_bandit,{616,439})

end
