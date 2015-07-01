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

BulletTime = {}

function BulletTime.init()

	BulletTime.showprogress = true

	BulletTime.slowdown_player = 1/3 -- player goes 3 times slower
	BulletTime.slowdown_enemies = 1/5 -- enemies go 5 times slower
	BulletTime.slowdown_bullets = 1/6 -- bullets go 6 times slower

	BulletTime.active = false
	BulletTime.timer = 0
	BulletTime.duration = Graphics.get_jumptime()/BulletTime.slowdown_player

	BulletTime.charge_duration = 2.5
	BulletTime.charge_timer = 0
	BulletTime.charged = true

end

function BulletTime.reset()
	-- bullet time!
	BulletTime.showprogress = true
	BulletTime.active = false
	BulletTime.timer = 0
	BulletTime.charge_timer = 0
	BulletTime.charged = true
end

function BulletTime.start()
	if not BulletTime.active and BulletTime.charged then
		BulletTime.active = true
		BulletTime.timer = BulletTime.duration
		BulletTime.charged = false
		BulletTime.charge_timer = 0
		Sounds.play_bullettime()
	end
end

function BulletTime.force( timer )
  -- for dramatic effects..
  -- but we want the marker to freeze!
  -- ok, so what we do is just hide it, since this will always happen at the end of a level
  -- we assume that with the new level start the marker will be shown again
	BulletTime.showprogress = false
	BulletTime.active = true
	BulletTime.timer = timer
	BulletTime.charged = false
	BulletTime.charge_timer = 0
end

function BulletTime.update( dt )
	if BulletTime.active then

		-- timer
		BulletTime.timer = BulletTime.timer - dt
		if BulletTime.timer <= 0 then
			BulletTime.active = false
			BulletTime.timer = BulletTime.charge_duration
		end

	else

		if BulletTime.charge_timer < BulletTime.charge_duration then
			BulletTime.charge_timer = BulletTime.charge_timer + dt
			if BulletTime.charge_timer >= BulletTime.charge_duration then
				BulletTime.charged = true
			end
		end

	end

end



