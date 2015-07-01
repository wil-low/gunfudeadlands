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

Colors = {
	green ={124,164,26},
	dk_green = {120,115,19},
	red = {164,26,33},
	black = {33,18,5},
	orange = {206,111,33},
	dk_red = {120,19,24},
	lt_red = {183,29,39},
	dark_black = {0,0,0},
	lt_blue = {26,122,160},
	yellow = {207,198,33},
}

function Colors.init()
	Colors.background = Colors.orange
	Colors.foreground = Colors.dk_red

	love.graphics.setBackgroundColor(Colors.background)
	love.graphics.setColor(Colors.foreground)
	love.graphics.setPointSize(1)
	love.graphics.setPointStyle("rough")
end

Graphics = {}

Graphics.walk_framedelay = 0.030
Graphics.jump_framedelay = 0.045
Graphics.death_framedelay = 0.060
Graphics.shadow_mode = false
Graphics.show_shoot_dir = true
Graphics.show_personalprogressbar=true

function Graphics.imageSection( filename, xfraction, yfraction, wfraction, hfraction )
	local image = love.graphics.newImage(filename)
	local x = math.floor(xfraction * image:getWidth())
	local y = math.floor(yfraction * image:getHeight())
	local w = math.floor(wfraction * image:getWidth())
	local h = math.floor(hfraction * image:getHeight())
	
	local frameBuffer = love.graphics.newCanvas( w, h )
	love.graphics.setCanvas( frameBuffer )
	love.graphics.clear()
	love.graphics.draw( image, -x, -y)
	
	
	local img = love.graphics.newImage( frameBuffer:getImageData() )
	love.graphics.setCanvas()
	return img
end

Graphics.images = {

	title = love.graphics.newImage("images/title.png"),

 	guy_standing = love.graphics.newImage("images/guy.png"),
	guy_walk_right = love.graphics.newImage("images/guy_walk_right.png"),
 	guy_walk_up = love.graphics.newImage("images/guy_walk_up.png"),
 	guy_jumping_right = love.graphics.newImage("images/guy_jumping_right.png"),
	guy_jumping_up = love.graphics.newImage("images/guy_jumping_up.png"),
 	guys_gun_right = Graphics.imageSection("images/guys_gun.png", 0, 0, 1/2, 1),
	guys_gun_left = Graphics.imageSection("images/guys_gun.png", 1/2, 0, 1/2, 1),
	guy_dying_right = love.graphics.newImage("images/guy_die_right.png"),

	blue_bandit_standing = love.graphics.newImage("images/blue_bandit.png"),
	blue_bandit_walk_right = love.graphics.newImage("images/blue_bandit_walk_right.png"),
 	blue_bandit_walk_up = love.graphics.newImage("images/blue_bandit_walk_up.png"),
 	blue_bandit_gun_right= Graphics.imageSection("images/blue_gun.png", 0, 0, 1/2, 1),
	blue_bandit_gun_left =Graphics.imageSection("images/blue_gun.png", 1/2, 0, 1/2, 1),
	blue_bandit_dying_right = love.graphics.newImage("images/blue_bandit_die_right.png"),

	red_bandit_standing = love.graphics.newImage("images/red_bandit.png"),
	red_bandit_walk_right = love.graphics.newImage("images/red_bandit_walk_right.png"),
 	red_bandit_walk_up = love.graphics.newImage("images/red_bandit_walk_up.png"),
 	red_bandit_gun_right= Graphics.imageSection("images/red_gun.png", 0, 0, 1/2, 1),
	red_bandit_gun_left =Graphics.imageSection("images/red_gun.png", 1/2, 0, 1/2, 1),
	red_bandit_dying_right = love.graphics.newImage("images/red_bandit_die_right.png"),

	green_bandit_standing = love.graphics.newImage("images/green_bandit.png"),
	green_bandit_walk_right = love.graphics.newImage("images/green_bandit_walk_right.png"),
 	green_bandit_walk_up = love.graphics.newImage("images/green_bandit_walk_up.png"),
 	green_bandit_gun_right= Graphics.imageSection("images/green_gun.png", 0, 0, 1/2, 1),
	green_bandit_gun_left =Graphics.imageSection("images/green_gun.png", 1/2, 0, 1/2, 1),
	green_bandit_dying_right = love.graphics.newImage("images/green_bandit_die_right.png"),

	yellow_bandit_standing = love.graphics.newImage("images/yellow_bandit.png"),
	yellow_bandit_walk_right = love.graphics.newImage("images/yellow_bandit_walk_right.png"),
 	yellow_bandit_walk_up = love.graphics.newImage("images/yellow_bandit_walk_up.png"),
 	yellow_bandit_gun_right= Graphics.imageSection("images/yellow_gun.png", 0, 0, 1/2, 1),
	yellow_bandit_gun_left =Graphics.imageSection("images/yellow_gun.png", 1/2, 0, 1/2, 1),
	yellow_bandit_dying_right = love.graphics.newImage("images/yellow_bandit_die_right.png"),

	ninja_bandit_standing = love.graphics.newImage("images/ninja_bandit.png"),
	ninja_bandit_walk_right = love.graphics.newImage("images/ninja_bandit_walk_right.png"),
 	ninja_bandit_walk_up = love.graphics.newImage("images/ninja_bandit_walk_up.png"),
	ninja_bandit_walk_dn = love.graphics.newImage("images/ninja_bandit_walk_dn.png"),
	ninja_bandit_blue_gun_right= Graphics.imageSection("images/ninja_bandit_blue_gun.png", 0, 0, 1/2, 1),
	ninja_bandit_blue_gun_left =Graphics.imageSection("images/ninja_bandit_blue_gun.png", 1/2, 0, 1/2, 1),
	ninja_bandit_red_gun_right= Graphics.imageSection("images/ninja_bandit_red_gun.png", 0, 0, 1/2, 1),
	ninja_bandit_red_gun_left =Graphics.imageSection("images/ninja_bandit_red_gun.png", 1/2, 0, 1/2, 1),
	ninja_bandit_green_gun_right= Graphics.imageSection("images/ninja_bandit_green_gun.png", 0, 0, 1/2, 1),
	ninja_bandit_green_gun_left =Graphics.imageSection("images/ninja_bandit_green_gun.png", 1/2, 0, 1/2, 1),
	ninja_bandit_yellow_gun_right= Graphics.imageSection("images/ninja_bandit_yellow_gun.png", 0, 0, 1/2, 1),
	ninja_bandit_yellow_gun_left =Graphics.imageSection("images/ninja_bandit_yellow_gun.png", 1/2, 0, 1/2, 1),
	ninja_bandit_dying_right = love.graphics.newImage("images/ninja_bandit_die_right.png"),

	bullet = love.graphics.newImage("images/bullet.png"),
	bullet_marker = love.graphics.newImage("images/bullet_huge.png"),

	cactus = love.graphics.newImage("images/cactus.png"),
	barrel = love.graphics.newImage("images/barrel.png"),
	saloon = love.graphics.newImage("images/saloon.png"),
	sheriff_box = love.graphics.newImage("images/sheriff.png"),
	church = love.graphics.newImage("images/church.png"),
	bank = love.graphics.newImage("images/bank.png"),
	mansion = love.graphics.newImage("images/mansion.png"),
	house = love.graphics.newImage("images/house.png"),
	warehouse = love.graphics.newImage("images/warehouse.png"),
	barrier_horiz = love.graphics.newImage("images/barrier_horiz.png"),
	barrier_vert = love.graphics.newImage("images/barrier_vert.png"),
	dead_branch = love.graphics.newImage("images/dead_branch.png"),
	dead_tree = love.graphics.newImage("images/dead_tree.png"),
	fence_horiz = love.graphics.newImage("images/fence_horiz.png"),
	fence_vert = love.graphics.newImage("images/fence_vert.png"),
	herb = love.graphics.newImage("images/herb.png"),
	mill = love.graphics.newImage("images/mill.png"),
	bush = love.graphics.newImage("images/bush.png"),
	barber = love.graphics.newImage("images/barber.png"),
	crate = love.graphics.newImage("images/crate.png"),
	generic_house = love.graphics.newImage("images/generic_house.png"),
	smith = love.graphics.newImage("images/smith.png"),
	stable = love.graphics.newImage("images/stable.png"),
	tiny_house = love.graphics.newImage("images/tiny_house.png"),
	pile = love.graphics.newImage("images/pile.png"),
	well = love.graphics.newImage("images/well.png"),


	commands = love.graphics.newImage("images/functions.png"),
	f1help = love.graphics.newImage("images/f1help.png"),
	f2save = love.graphics.newImage("images/f2save.png"),
	f3load = love.graphics.newImage("images/f3load.png"),
	f4move = love.graphics.newImage("images/f4move.png"),
	f5add = love.graphics.newImage("images/f5add.png"),
	f6test = love.graphics.newImage("images/f6test.png"),
	f7reset = love.graphics.newImage("images/f7reset.png"),
	f8opts = love.graphics.newImage("images/f8opts.png"),
	f10wipe = love.graphics.newImage("images/f10wipe.png"),

}

function Graphics.initAnim( _strip, _w, _h, _frametime )
	local frames = {}
	local i
	local data ={
		frame_w = _w,
		frame_h = _h,
		frame_count = math.floor(_strip:getWidth() / _w),
		frame_ndx = 0,
		frame_delay = _frametime,
		frame_timer = _frametime
	}
	
	local frameBuffer = love.graphics.newCanvas( data.frame_w, data.frame_h )
	love.graphics.setCanvas( frameBuffer )
	for i=0,data.frame_count-1 do
		love.graphics.clear()
		love.graphics.draw( _strip, -data.frame_w * i, 0)
		frames[i] = love.graphics.newImage( frameBuffer:getImageData() )
	end
	data.strip = frames
	love.graphics.setCanvas()
	return data
end


function Graphics.resetAnim( anim )
	anim.frame_timer = anim.frame_delay
	anim.frame_ndx = 0
end

function Graphics.updateAnim( anim, dt )
	anim.frame_timer = anim.frame_timer - dt
	while (anim.frame_timer <= 0) do
		anim.frame_timer = anim.frame_timer + anim.frame_delay
		anim.frame_ndx = anim.frame_ndx + 1
		if (anim.frame_ndx == anim.frame_count) then
			anim.frame_ndx = 0
		end
	end
end

function Graphics.drawCurrentFrame( anim, x, y, reverse )
	local x0 = (x - anim.frame_w/2)
	local y0 =  (y-anim.frame_h/2)
	
	if not reverse then
		love.graphics.draw(anim.strip[anim.frame_ndx], x, y, 0, 1, 1, math.floor(anim.frame_w/2), math.floor(anim.frame_h/2))
	else
		love.graphics.draw(anim.strip[anim.frame_ndx], x, y, 0, -1, 1, math.floor(anim.frame_w/2), math.floor(anim.frame_h/2))
	end
end

Graphics.animations = {
	guy_walk_right = Graphics.initAnim(Graphics.images.guy_walk_right, 18, 22, Graphics.walk_framedelay),
	guy_walk_up = Graphics.initAnim(Graphics.images.guy_walk_up, 18, 22, Graphics.walk_framedelay),
	guy_jumping_right = Graphics.initAnim(Graphics.images.guy_jumping_right, 18, 22, Graphics.jump_framedelay),
	guy_jumping_up = Graphics.initAnim(Graphics.images.guy_jumping_up, 18, 22, Graphics.jump_framedelay),
	guy_dying_right = Graphics.initAnim(Graphics.images.guy_dying_right, 18, 22, Graphics.death_framedelay),
}

function Graphics.animations.new_blue_bandit_walk_right()
	return Graphics.initAnim(Graphics.images.blue_bandit_walk_right, 18, 24, Graphics.walk_framedelay)
end

function Graphics.animations.new_blue_bandit_walk_up()
	return  Graphics.initAnim(Graphics.images.blue_bandit_walk_up, 18, 24, Graphics.walk_framedelay)
end
function Graphics.animations.new_blue_bandit_dying_right()
	return  Graphics.initAnim(Graphics.images.blue_bandit_dying_right, 18, 22, Graphics.death_framedelay)
end

function Graphics.animations.new_red_bandit_walk_right()
	return  Graphics.initAnim(Graphics.images.red_bandit_walk_right, 18, 22, Graphics.walk_framedelay)
end
function Graphics.animations.new_red_bandit_walk_up()
	return  Graphics.initAnim(Graphics.images.red_bandit_walk_up, 18, 22, Graphics.walk_framedelay)
end
function Graphics.animations.new_red_bandit_dying_right()
	return  Graphics.initAnim(Graphics.images.red_bandit_dying_right, 18, 22, Graphics.death_framedelay)
end

function Graphics.animations.new_green_bandit_walk_right()
	return  Graphics.initAnim(Graphics.images.green_bandit_walk_right, 18, 24, Graphics.walk_framedelay)
end
function Graphics.animations.new_green_bandit_walk_up()
	return  Graphics.initAnim(Graphics.images.green_bandit_walk_up, 18, 24, Graphics.walk_framedelay)
end
function Graphics.animations.new_green_bandit_dying_right()
	return  Graphics.initAnim(Graphics.images.green_bandit_dying_right, 18, 22, Graphics.death_framedelay)
end

function Graphics.animations.new_yellow_bandit_walk_right()
	return  Graphics.initAnim(Graphics.images.yellow_bandit_walk_right, 18, 22, Graphics.walk_framedelay)
end
function Graphics.animations.new_yellow_bandit_walk_up()
	return  Graphics.initAnim(Graphics.images.yellow_bandit_walk_up, 18, 22, Graphics.walk_framedelay)
end
function Graphics.animations.new_yellow_bandit_dying_right()
	return  Graphics.initAnim(Graphics.images.yellow_bandit_dying_right, 18, 22, Graphics.death_framedelay)
end

function Graphics.animations.new_ninja_bandit_walk_right()
	return  Graphics.initAnim(Graphics.images.ninja_bandit_walk_right, 18, 22, Graphics.walk_framedelay)
end
function Graphics.animations.new_ninja_bandit_walk_up()
	return  Graphics.initAnim(Graphics.images.ninja_bandit_walk_up, 18, 22, Graphics.walk_framedelay)
end
function Graphics.animations.new_ninja_bandit_walk_dn()
	return  Graphics.initAnim(Graphics.images.ninja_bandit_walk_dn, 18, 22, Graphics.walk_framedelay)
end
function Graphics.animations.new_ninja_bandit_dying_right()
	return  Graphics.initAnim(Graphics.images.ninja_bandit_dying_right, 18, 22, Graphics.death_framedelay)
end

function Graphics.get_jumptime(  )
	return Graphics.jump_framedelay * Graphics.animations.guy_jumping_up.frame_count
end

function Graphics.get_deathtime( )
	return Graphics.death_framedelay * Graphics.animations.guy_dying_right.frame_count - Graphics.death_framedelay/2
end

function Graphics.reset_jump()
	Graphics.resetAnim( Graphics.animations.guy_jumping_right )
	Graphics.resetAnim( Graphics.animations.guy_jumping_up )
end

function Graphics.reset_death()
	Graphics.resetAnim( Graphics.animations.guy_dying_right )
end

function Graphics.update_player(delta)
	Graphics.updateAnim( Graphics.animations.guy_walk_right, delta)
	Graphics.updateAnim( Graphics.animations.guy_walk_up, delta)
	Graphics.updateAnim( Graphics.animations.guy_jumping_right, delta)
	Graphics.updateAnim( Graphics.animations.guy_jumping_up, delta)
	Graphics.updateAnim( Graphics.animations.guy_dying_right, delta)
end

function Graphics.update_enemies(delta)
	if Level.ninjamode and not (Editor.enabled and Editor.mode ~= 6) and Level.currentlevel > 0 then
		Graphics.update_ninja_enemies( delta )
		return
	end
	
	for i,enemy in ipairs(Level.enemies) do
		if enemy.dir ~= {0,0} then
			if math.abs(enemy.dir[1]) > math.abs(enemy.dir[2]) then
				Graphics.updateAnim( enemy.sprite_walking_right, delta)
			else
				if enemy.dir[2]<0 then
					Graphics.updateAnim( enemy.sprite_walking_up, delta)
				else
					Graphics.updateAnim( enemy.sprite_walking_dn, delta)
				end
			end
		end

		if enemy.state == 0 then
			Graphics.updateAnim( enemy.sprite_dying, delta)
		end

	end

end

function Graphics.update_ninja_enemies(delta)
	for i,enemy in ipairs(Level.enemies) do
		if enemy.dir ~= {0,0} then
			if math.abs(enemy.dir[1]) > math.abs(enemy.dir[2]) then
				Graphics.updateAnim( enemy.sprite_ninja_walking_right, delta)
			else
				if enemy.dir[2]<0 then
					Graphics.updateAnim( enemy.sprite_ninja_walking_up, delta)
				else
					Graphics.updateAnim( enemy.sprite_ninja_walking_dn, delta)
				end
			end
		end

		if enemy.state == 0 then
			Graphics.updateAnim( enemy.sprite_ninja_dying, delta)
		end

	end

end

-- ============== modes ==================
-- viewmodes= 1-fullscreen, 2-windowed
Graphics.viewmode = 2
function Graphics.toggleMode()
	if Graphics.viewmode == 1 then
		return Graphics.setWindowed()
	else
		return Graphics.setFullscreen()
	end
end

function Graphics.setWindowed()
	local success = love.window.setMode( screensize[1], screensize[2], { fullscreen = false } )
	Graphics.viewmode = 2
	return success
end

function Graphics.setFullscreen()
  local success = love.window.setMode( screensize[1], screensize[2], { fullscreen = true } )
	Graphics.viewmode = 1
	return success
end

function Graphics.drawtext(text, x, y)
	love.graphics.setColor(Colors.dark_black)
	love.graphics.print(text,x,y)
end

function Graphics.drawCentered( image, x, y, reversed )
	if not reversed then
		love.graphics.draw(image, x, y, 0, 1, 1, math.floor(image:getWidth()/2), math.floor(image:getHeight()/2) )
	else
		love.graphics.draw(image, x , y, 0, -1, 1, math.floor(image:getWidth()/2), math.floor(image:getHeight()/2))
	end
end

function Graphics.prepareBackground()
	local frameBuffer = love.graphics.newCanvas( screensize[1], screensize[2] )
	love.graphics.setCanvas( frameBuffer )
	love.graphics.clear()
	
	if Level.buildings then
		for i,building in ipairs(Level.buildings) do
			if building.solid == 5 then
				Graphics.draw_building( building )
			end
		end
	end
	
	Graphics.backgroundImage = love.graphics.newImage( frameBuffer:getImageData() )
	love.graphics.setCanvas()
end

function Graphics.prepareTopLayer()
	local frameBuffer = love.graphics.newCanvas( screensize[1], screensize[2] )
	love.graphics.setCanvas( frameBuffer )
	love.graphics.clear()

	if Level.buildings then
		for i,building in ipairs(Level.buildings) do
			if building.solid ~= 5 then
				Graphics.draw_building( building )
			end
		end
	end
		
	Graphics.topImage = love.graphics.newImage( frameBuffer:getImageData() )
	love.graphics.setCanvas()
end

function Graphics.init()
	-- initialize empty ones
	Graphics.prepareTopLayer()
	Graphics.prepareBackground()
end
-- ============== DRAW FUNCTION ==============
function Graphics.drawTitleScreen()

	Graphics.drawCentered(Graphics.images.title,320,60)
--		Graphics.drawCentered(Level.menutext, 150, 130)
	Graphics.drawtext(Level.menutext_U,  150, 95)
	Graphics.drawtext("F1 - Instructions\n\nF2 - Start in normal mode\n\nF3 - Start in hard mode\n\nF4 - Play user level\n\nF5 - Level editor\n\nESC - Exit", 200,160)
end

function Graphics.drawEndScreen()
	Graphics.drawtext(Level.endtext, 130, 130)
	if Game.gamemode == 2 then
		Graphics.drawtext(Level.hardtext, 130,70)
	end
end

function Graphics.showinstructions()
	Graphics.drawtext(Level.menutext_L,  150, 30)
	Graphics.drawtext(Level.menutext_R,  370, 30)
end
-- in graphics!
function Graphics.draw()
	
	if Game.paused then
		love.graphics.setColor(Colors.dark_black)
		Graphics.drawtext("Game Paused",280,240)
		return
	end

	if Game.helpmode then
		Graphics.showinstructions()
		return
	end

	if not Editor.enabled then
		if Level.currentlevel == 0 then
			Graphics.drawTitleScreen()

	--~ 		return
		elseif Level.currentlevel == 11 then
			Graphics.drawEndScreen()
	--		return
		end
	end


	--Graphics.drawCentered("WANTED\nDead or Alive\nJoseph <Joe> Smith\nWilliam <Happy Trigger> Gordon\nAbraham <Gramps> Derrick\nRobert <Crazy Horse> Morris\n6000$",10,10)

	love.graphics.draw(Graphics.backgroundImage, 0, 0)
  
	Graphics.draw_player()
	
	List.apply(Bullets, Graphics.draw_bullet)
	
	for i,enemy in ipairs(Level.enemies) do
		Graphics.draw_enemy(enemy)
	end
	
	love.graphics.draw( Graphics.topImage, 0, 0 )
	
	-- bullettime progressbar
	if BulletTime.showprogress and ((Editor.enabled and Editor.showprogress) or not Editor.enabled) then
		if Graphics.show_personalprogressbar then
			Graphics.draw_personalprogressbar()
		else
			Graphics.draw_progressbar(550, 10)
		end
	end
	
end

function Graphics.draw_player( )
	local lplayerpos = { math.floor( Player.pos[1] ), math.floor( Player.pos[2]) }
	if Player.alive then

		if Player.jumping then
		  -- jumping animation
			if Player.spinning_dir[1] > 0 then
				Graphics.drawCurrentFrame(Graphics.animations.guy_jumping_right, lplayerpos[1], lplayerpos[2])
			elseif Player.spinning_dir[1] < 0 then
				Graphics.drawCurrentFrame(Graphics.animations.guy_jumping_right, lplayerpos[1], lplayerpos[2], true)
			elseif Player.spinning_dir[2] < 0 then
				Graphics.drawCurrentFrame(Graphics.animations.guy_jumping_up, lplayerpos[1], lplayerpos[2])
			elseif Player.spinning_dir[2] > 0 then
				Graphics.drawCurrentFrame(Graphics.animations.guy_jumping_up, lplayerpos[1], lplayerpos[2], true)
			else
				Player.jumping = false
			end
		else
		  -- normal walk
			if Player.dir[1] > 0 then
				Graphics.drawCurrentFrame(Graphics.animations.guy_walk_right, lplayerpos[1], lplayerpos[2])
			elseif Player.dir[1] < 0 then
				Graphics.drawCurrentFrame(Graphics.animations.guy_walk_right, lplayerpos[1], lplayerpos[2], true)
			elseif Player.dir[2] ~= 0 then
				Graphics.drawCurrentFrame(Graphics.animations.guy_walk_up, lplayerpos[1], lplayerpos[2])
			else
				Graphics.drawCentered(Graphics.images.guy_standing, lplayerpos[1], lplayerpos[2])
			end

		  -- render gun
			if Player.firing_timer > 0 then
				if love.mouse.getX() > lplayerpos[1] then
					love.graphics.draw(Graphics.images.guys_gun_right, math.floor(lplayerpos[1]), math.floor(lplayerpos[2]), 0, 1, 1,
						Player.spritesize[1]/2, Player.spritesize[2]/2)
				else
					love.graphics.draw(Graphics.images.guys_gun_left, math.floor(lplayerpos[1]), math.floor(lplayerpos[2]), 0, 1, 1,
						Player.spritesize[1]/2, Player.spritesize[2]/2)
				end
			end
		end
	else
		if Player.death_timer > 0 then
			if Player.dir[1]>=0 then
				Graphics.drawCurrentFrame(Graphics.animations.guy_dying_right, lplayerpos[1], lplayerpos[2])
			else
				Graphics.drawCurrentFrame(Graphics.animations.guy_dying_right, lplayerpos[1], lplayerpos[2], true)
			end
		end
	end
end

function Graphics.draw_bullet( bullet )
	Graphics.drawCentered(Graphics.images.bullet, bullet.pos[1], bullet.pos[2])
end

function Graphics.draw_enemy( enemy )

	if Level.ninjamode and not (Editor.enabled and Editor.mode ~= 6) and Level.currentlevel > 0 then
		Graphics.draw_ninja_enemy( enemy )
		return
	end

	local px, py = math.floor(enemy.pos[1]), math.floor(enemy.pos[2])

	-- if it's dead, don't draw
	if enemy.state == 0 then
		if enemy.death_timer > 0 then
			if enemy.dir[1]>=0 then
				Graphics.drawCurrentFrame(enemy.sprite_dying, px, py)
			else
				Graphics.drawCurrentFrame(enemy.sprite_dying, px, py,  true)
			end
		end
		return
	end



	if enemy.blocked or (enemy.dir[1] == 0 and enemy.dir[2] == 0)   then
		Graphics.drawCentered(enemy.sprite_standing, px, py)
	else
	-- moving!
		if math.abs(enemy.dir[1]) > math.abs(enemy.dir[2]) then
			-- horizontal movement
			if enemy.dir[1]>0 then
				-- moving right
				Graphics.drawCurrentFrame(enemy.sprite_walking_right, px, py)
			else
				-- moving left
				Graphics.drawCurrentFrame(enemy.sprite_walking_right, px, py,  true )
			end
		else
			-- vertical movement
			if enemy.dir[2]<0 then
				Graphics.drawCurrentFrame(enemy.sprite_walking_up, px, py)
			else
				Graphics.drawCurrentFrame(enemy.sprite_walking_dn, px, py)
			end
		end
	end

	-- if he is shooting, draw the gun
	if enemy.shooting_timer > 0 then
		local lx, ly = enemy.sprite_gun_left:getWidth()/2, enemy.sprite_gun_left:getHeight()
		if enemy.shoot_dir[1]>enemy.accuracy*2 then
			enemy.side = 1
		end
		if enemy.shoot_dir[1]<-enemy.accuracy*2 then
			enemy.side = 2
		end
		if enemy.side==1 then
			Graphics.drawCentered(enemy.sprite_gun_right, px, py)
		else
			Graphics.drawCentered(enemy.sprite_gun_left, px, py)
		end

	end

	-- show the shooting direction pointer
	if Graphics.show_shoot_dir then
		love.graphics.setColor(Colors.black)
		love.graphics.point(enemy.pos[1]+enemy.shoot_dir[1]*15,enemy.pos[2]+enemy.shoot_dir[2]*15)
		love.graphics.point(enemy.pos[1]+enemy.shoot_dir[1]*16,enemy.pos[2]+enemy.shoot_dir[2]*16)
	end
end

function Graphics.draw_ninja_enemy( enemy )

	local px, py = math.floor(enemy.pos[1]), math.floor(enemy.pos[2])

	-- if it's dead, don't draw
	if enemy.state == 0 then
		if enemy.death_timer > 0 then
			if enemy.dir[1]>=0 then
				Graphics.drawCurrentFrame(enemy.sprite_ninja_dying, px, py)
			else
				Graphics.drawCurrentFrame(enemy.sprite_ninja_dying, px, py, true)
			end
		end
		return
	end

	if not EnemyAI.ninja_see_player_short( enemy ) then
		return
	end


	if enemy.blocked or (enemy.dir[1] == 0 and enemy.dir[2] == 0)   then
		Graphics.drawCentered(enemy.sprite_ninja_standing, px, py)
	else
	-- moving!
		if math.abs(enemy.dir[1]) > math.abs(enemy.dir[2]) then
			-- horizontal movement
			if enemy.dir[1]>0 then
				-- moving right
				Graphics.drawCurrentFrame(enemy.sprite_ninja_walking_right, px, py)
			else
				-- moving left
				Graphics.drawCurrentFrame(enemy.sprite_ninja_walking_right, px, py, true )
			end
		else
			-- vertical movement
			if enemy.dir[2]<0 then
				Graphics.drawCurrentFrame(enemy.sprite_ninja_walking_up, px, py)
			else
				Graphics.drawCurrentFrame(enemy.sprite_ninja_walking_dn, px, py)
			end
		end
	end

	-- if he is shooting, draw the gun
	if enemy.shooting_timer > 0 then
		local lx, ly = enemy.sprite_ninja_gun_left:getWidth()/2, enemy.sprite_ninja_gun_left:getHeight()
		if enemy.shoot_dir[1]>enemy.accuracy*2 then
			enemy.side = 1
		end
		if enemy.shoot_dir[1]<-enemy.accuracy*2 then
			enemy.side = 2
		end
		if enemy.side==1 then
			Graphics.drawCentered(enemy.sprite_ninja_gun_right, px, py)
		else
			Graphics.drawCentered(enemy.sprite_ninja_gun_left, px, py)
		end

	end

	-- show the shooting direction pointer
	if Graphics.show_shoot_dir then
		love.graphics.setColor(enemy.color)
		love.graphics.point(enemy.pos[1]+enemy.shoot_dir[1]*15,enemy.pos[2]+enemy.shoot_dir[2]*15)
		love.graphics.point(enemy.pos[1]+enemy.shoot_dir[1]*16,enemy.pos[2]+enemy.shoot_dir[2]*16)
	end
end

function Graphics.draw_building( building )
	if building.sprite then
		if building.len then
		-- several
		-- len[1] tells the direction: 1 horiz, 2 vert
		-- len[2] tells the number of repetitions
		-- len[3] tells the size of a single element
			if building.len[1] == 1 then
				for j=1,building.len[2] do
					Graphics.drawCentered(building.sprite,
						math.floor(building.pos[1]+(j-1-(building.len[2]-1)/2)*building.len[3]),
						math.floor(building.pos[2]))
				end
			elseif building.len[1] == 2 then
				for j=1,building.len[2] do
					Graphics.drawCentered(building.sprite,
						math.floor(building.pos[1]),
						math.floor(building.pos[2]+(j-1-(building.len[2]-1)/2)*building.len[3]))

				end

			end
		else
		-- just one
			Graphics.drawCentered(building.sprite, math.floor(building.pos[1]), math.floor(building.pos[2]))
		end
	end
end

function Graphics.draw_progressbar(px, py)

	local fraction
	local bar_len = 100

	-- enclosing box
	love.graphics.setColor(Colors.black)
	love.graphics.setLine(12,love.line_rough)
	love.graphics.line( px- bar_len/2 -3, py, px + bar_len/2 + 3, py )

	-- bar

	-- charging or discharging?
	if BulletTime.charged then
		love.graphics.setColor(Colors.dk_green)
		fraction = 1
	else
		if BulletTime.active then
			fraction = BulletTime.timer / BulletTime.duration
			-- green when discharging
			love.graphics.setColor(Colors.dk_green)
		else
			fraction = BulletTime.charge_timer/BulletTime.charge_duration
			-- red when charging
			love.graphics.setColor(Colors.red)
		end
	end

	love.graphics.setLine(6,love.line_rough ) -- big dots!
	love.graphics.line( px- bar_len/2 , py, px- bar_len/2 + math.floor(fraction*bar_len) , py)

	-- rest
	love.graphics.setColor(Colors.background)
	love.graphics.line(   px- bar_len/2 + math.floor(fraction*bar_len) , py , px + bar_len/2, py)

	-- bullet pocket
	for i=1,Player.bullet_pocket do
		Graphics.drawCentered(Graphics.images.bullet_marker,i*10, 8)
	end

	-- return to foreground color
	love.graphics.setColor(Colors.foreground)



end

function Graphics.draw_personalprogressbar()

	local fraction
	local bar_len = 18
	local px,py = Player.pos[1],math.floor(Player.pos[2] - 13)

	-- bar

	-- charging or discharging?
	if BulletTime.charged then
		love.graphics.setColor(Colors.dk_green)
		fraction = 1
	else
		if BulletTime.active then
			fraction = BulletTime.timer / BulletTime.duration
			-- green when discharging
			love.graphics.setColor(Colors.dk_green)
		else
			fraction = BulletTime.charge_timer/BulletTime.charge_duration
			-- red when charging
			love.graphics.setColor(Colors.red)
		end
	end

	love.graphics.setLine(1,"rough" ) -- small dots!
	love.graphics.line( px- bar_len/2 , py, px- bar_len/2 + math.floor(fraction*bar_len) , py)

	-- bullet pocket
	love.graphics.setColor(Colors.dark_black)

	for i=1,Player.bullet_pocket do
 		love.graphics.point(math.floor(px-bar_len/2) + i*3 - 2, py-1)
		love.graphics.point(math.floor(px-bar_len/2) + i*3 - 2, py-2)
 	end

	-- return to foreground color
	love.graphics.setColor(Colors.foreground)

end

-- ============== END DRAW FUNCTION ==============

