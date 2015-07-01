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


function Editor.trytoloadcurrent()
	if Editor.checklevelfile( Editor.currentfilename ) then
		Editor.loadlevelfile( Editor.currentfilename )
		Editor.mode = 4
	else
		Editor.fileerror_timer = 1.5
		Editor.currentfilename = ""
		Editor.listingtable = Editor.getFileList()
	end
end

function Editor.trytosavecurrent()
	if Editor.savelevelfile( Editor.currentfilename) then
		Editor.addEntryInFileList( Editor.currentfilename )
		Editor.currentfilename = ""
		Editor.mode = 4
	else
		Editor.fileerror_timer = 1.5
		Editor.currentfilename = ""
		Editor.listingtable = Editor.getFileList()
	end
end


function Editor.saveslotfile( slot )
	-- generate file name
	local filename = "slot"..slot..".gfd"
	-- save version
	local versionstring=Editor.versionstring.."\n"

	-- save corresponding slot in memory
	Editor.saveslot( slot )
	local slottext=Editor.slottostring( slot )
	-- save level map in file
	local map = Editor.levelmapintext()
	-- save level options
	local options = Editor.levelOptionsToString()

	-- save slot in file
	local savedata=versionstring..map..slottext..options
	Editor.saveinFile( filename, savedata )

end

function Editor.savelevelfile( filename )
	-- generate file name
	local filename = filename..".gfl"
	-- save version
	local versionstring=Editor.versionstring.."\n"

	-- save level map in file
	local map = Editor.levelmapintext()
	-- save level options
	local options = Editor.levelOptionsToString()

	-- save slot in file
	local savedata=versionstring..map..options
	return Editor.saveinFile( filename, savedata )

end

function Editor.saveinFile( filename, savedata )
	-- save it (overwrite file if necessary)
	if love.filesystem.write( filename, savedata ) then
		return true
	end
	return false
end

function Editor.loadfromFile( filename )
	if not love.filesystem.exists( filename ) then
		return ""
	end

	local d, size = love.filesystem.read( filename )
	if  size > 0 then
		return d
	end

	return ""
end

function Editor.loadslotfile( slot )
	-- generate file name
	local filename = "slot"..slot..".gfd"
	local loaddata = Editor.loadfromFile( filename )

	-- check version
	if string.sub(loaddata,1,string.len(Editor.versionstring))~=Editor.versionstring then
		return
	end


	-- fetch level map from file
	Level.init()
	Editor.parsemapstring( string.sub(loaddata,string.len(Editor.versionstring),-1) )
	Level.restart()

	-- fetch slot
	Editor.currentslot = 1
	Editor.getslotfromtext( string.sub(loaddata,string.len(Editor.versionstring),-1) )

	-- recall slot
	Editor.loadslot(Editor.currentslot)
end

function Editor.loadlevelfile( filename )

	-- generate file name
	local filename = filename..".gfl"
	local loaddata = Editor.loadfromFile( filename )

	-- check version
	if string.sub(loaddata,1,string.len(Editor.versionstring))~=Editor.versionstring then
		return
	end


	Level.init()
	Editor.parsemapstring( string.sub(loaddata,string.len(Editor.versionstring),-1) )
	Level.restart()
end

-- returns true if the file exists, if it does not, it purges the file list
function Editor.checklevelfile( filename )
	if love.filesystem.exists( filename..".gfl" ) then
		local loaddata = Editor.loadfromFile( filename..".gfl" )

		-- check version
		if string.sub(loaddata,1,string.len(Editor.versionstring))~=Editor.versionstring then
			return false
		end
		return true
	else
		Editor.removeEntryFromfilelist( filename )
		return false
	end

end

function Split(str, delim, maxNb)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
        return { str }
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0    -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gfind(str, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end
    -- Handle the last field
    if nb ~= maxNb then
        result[nb + 1] = string.sub(str, lastPos)
    end
    return result
end

function Editor.levelmapintext()
	local outputstring = ""
	-- player
	outputstring = outputstring..Entities.entitystrings[Entities.entitylist.player].."("..
		math.floor(Player.starting_pos[1])..","..math.floor(Player.starting_pos[2])..")\n"

	-- buildings
	for i,b in ipairs(Level.buildings) do
		if not b.len then
			outputstring = outputstring..Entities.entitystrings[b.id].."("..
				math.floor(b.pos[1])..","..math.floor(b.pos[2])..")\n"
		else
			outputstring = outputstring..Entities.entitystrings[b.id].."("..
				math.floor(b.pos[1])..","..math.floor(b.pos[2])..","..b.len[2]..")\n"
		end
	end

	-- enemies
	for i,e in ipairs(Level.enemies) do
		outputstring = outputstring..Entities.entitystrings[e.id].."("..
			math.floor(e.starting_pos[1])..","..math.floor(e.starting_pos[2])..")\n"
	end

	return outputstring
end

function Editor.slottostring(slot)
	local outputstring = "slotdata("..slot..","
	for i,entry in ipairs(Editor.slots[slot]) do
		outputstring = outputstring.."["
		for j,val in ipairs(entry) do
			if math.abs(val)<0.0001 and val~=0 then
				if val>0 then val = -0.0001 else val = 0.0001 end
			end
			outputstring=outputstring..val
			if j~=table.getn(entry) then
				outputstring=outputstring..","
			else
				outputstring=outputstring.."]"
			end
		end
		if i~=table.getn(Editor.slots[slot]) then
			outputstring=outputstring..","
		else
			outputstring=outputstring..")\n"
		end
	end
	return outputstring

end

function Editor.valuestoslot(values)
	local slot = values[1]
	table.remove(values,1)
	Editor.slots[slot] = values
	Editor.currentslot = slot
end

function Editor.parselineforslot( st )
	local punt1 = string.find(st,"%(")
	local punt2 = string.find(st,"%)")
	local retlist = {}
	if punt1~=nil and punt2~=nil and punt1+1<punt2-1 then
		local aseparar = string.sub(st,punt1+1,punt2-1)
		table.insert(retlist,string.match(aseparar,"[%.%d]+"))
		local continuar = true
		while continuar do
			local clau1= string.find(aseparar,"%[")
			local clau2= string.find(aseparar,"%]")
			continuar = (clau1~=nil and clau2~=nil and clau1+1<clau2-1)
			if continuar then
				local appendage = {}
				local porcio = string.sub(aseparar,clau1+1,clau2-1)
				for number in string.gmatch(porcio,"[%-%.%d]+") do
					table.insert(appendage,number+0)
				end
				table.insert(retlist,appendage)
				aseparar=string.sub(aseparar,clau2+1,-1)
			end
		end
	end
	return retlist
end

function Editor.parseslotstring( line )
	local values = Editor.parselineforslot( line )
	local slot = values[1]
	table.remove(values,1)
	Editor.slots[slot] = values
	Editor.currentslot = slot
end

function Editor.parselineforid( st )
	return string.match(st,"[%a_]+")
end

function Editor.parselinefornumbers( st )
	local punt1 = string.find(st,"%(")
	local punt2 = string.find(st,"%)")
	local valors = {}
	if punt1~=nil and punt2~=nil and punt1+1<punt2-1 then
		local aseparar = string.sub(st,punt1+1,punt2-1)
		for number in string.gmatch(aseparar,"[%.%d]+") do
			table.insert(valors,number+0)
		end
	end
	return valors
end


function Editor.parsemapstring( st )
	  -- parse the string into the structure
		local lines = Split(st,"%c")

		for i,line in ipairs(lines) do
			-- first find the identifier
			local identifier = Editor.parselineforid(line)
			local entityid = Entities.getidfromstring( identifier )

			-- if recognised, insert the element
			if entityid ~= -1 then
				local values = Editor.parselinefornumbers(line)
				if not Entities.hasalength( entityid ) and table.getn(values) == 2 then
					Entities.add_element( entityid, {values[1], values[2]} )
				end
				if Entities.hasalength( entityid ) and table.getn(values) == 3 then
					Entities.add_element( entityid, {values[1], values[2]}, values[3] )
				end
			elseif identifier=="level_options" then
			-- else, may be slot information or options
				Editor.stringToLevelOptions( line )
			end
		end

end

function Editor.getslotfromtext( st )
	  -- parse the string into the structure
		local lines = Split(st,"%c")

		for i,line in ipairs(lines) do
			local identifier = Editor.parselineforid(line)
			if identifier=="slotdata" then
				Editor.parseslotstring( line )
			end
		end
end

function Editor.levelloaddata(data)
	for i,d in ipairs(data) do
		Entities.add_element( d[1], d[2], d[3] )
	end
end


function boolToInt(b)
	if b then
		return 1
	else
		return 0
	end
	return 0
end

function intToBool(i)
	if i*1>0 then
		return true
	else
		return false
	end
	return false
end

function Editor.saveslot(slot)

	Editor.slots[slot]={}
	-- player state

	Editor.slots[slot][1] = {
		boolToInt(Player.alive),
		Player.pos[1],Player.pos[2],
		Player.dir[1],Player.dir[2],
		Player.key_dir[1],Player.key_dir[2],
		boolToInt(Player.firing) ,
		Player.firing_timer,
		boolToInt(Player.jumping),
		boolToInt(Player.readytojump),
		Player.spinning_dir[1],Player.spinning_dir[2],
		Player.jump_timer,
		Player.prediction_short[1],Player.prediction_short[2],
		Player.bullet_pocket,
		Player.reload_timer,
		Player.prediction_timer,
		Player.dir_prediction[1],Player.dir_prediction[2],
		boolToInt(BulletTime.active),
		BulletTime.timer,
		BulletTime.charge_timer,
		boolToInt(BulletTime.charged),
		boolToInt(BulletTime.showprogress),
		boolToInt(Editor.showprogress),
	}

	for i,enemy in ipairs(Level.enemies) do
		table.insert( Editor.slots[slot], {
			enemy.pos[1],enemy.pos[2],
			enemy.dir[1],enemy.dir[2],
			enemy.shoot_dir[1], enemy.shoot_dir[2],
			enemy.target_dir[1], enemy.target_dir[2],
			enemy.prediction_short[1], enemy.prediction_short[2],
			enemy.dir_prediction[1], enemy.dir_prediction[2],
			enemy.state,
			enemy.former_state,
			enemy.last_seen_bullet[1], enemy.last_seen_bullet[2],
			enemy.blocked_timer,
			enemy.changedir_timer,
			enemy.dodging_timer,
			enemy.shooting_timer,
			enemy.death_timer,
			enemy.wandering_timer,
			enemy.suspicion_timer,
			enemy.scared_timer,
			enemy.lastplayerpos[1], enemy.lastplayerpos[2],
			enemy.destination[1], enemy.destination[2],
			enemy.lastpos[1], enemy.lastpos[2],
			enemy.see_player_timer,
			boolToInt(enemy.player_was_seen),
			enemy.see_bullet_timer,
			boolToInt(enemy.bullet_was_seen),
			enemy.ninja_see_player_timer,
			boolToInt(enemy.ninja_player_was_seen),
			enemy.prediction_timer,
		})
	end

end

function Editor.loadslot(slot)
	if not Editor.slots[slot] then return end
	for i,elem in ipairs(Editor.slots[slot]) do
		if i==1 then -- player
			Player.alive = intToBool(elem[1])
			Player.pos = {elem[2], elem[3]}
			Player.dir = {elem[4], elem[5]}
			Player.key_dir = {elem[6], elem[7]}
			Player.firing = intToBool(elem[8])
			Player.firing_timer = elem[9]
			Player.jumping = intToBool(elem[10])
			Player.readytojump = intToBool(elem[11])
 			Player.spinning_dir = {elem[12],elem[13]}
 			Player.jump_timer = elem[14]
			Player.prediction_short = {elem[15],elem[16]}
			Player.bullet_pocket = elem[17]
			Player.reload_timer = elem[18]
			Player.prediction_timer = elem[19]
			Player.dir_prediction = {elem[20],elem[21]}
			BulletTime.active = intToBool(elem[22])
			BulletTime.timer = elem[23]
			BulletTime.charge_timer = elem[24]
			BulletTime.charged = intToBool(elem[25])
			BulletTime.showprogress = intToBool(elem[26])
			Editor.showprogress = intToBool(elem[27])

		else -- enemy
			if i-1 > table.getn(Level.enemies) then break end -- some enemies disappeared
			Level.enemies[i-1].pos = {elem[1],elem[2]}
			Level.enemies[i-1].dir = {elem[3],elem[4]}
			Level.enemies[i-1].shoot_dir = {elem[5],elem[6]}
			Level.enemies[i-1].target_dir = {elem[7],elem[8]}
			Level.enemies[i-1].prediction_short = {elem[9],elem[10]}
			Level.enemies[i-1].dir_prediction = {elem[11],elem[12]}
			Level.enemies[i-1].state = elem[13]
			Level.enemies[i-1].former_state = elem[14]
			Level.enemies[i-1].last_seen_bullet = {elem[15], elem[16]}
			Level.enemies[i-1].blocked_timer = elem[17]
			Level.enemies[i-1].changedir_timer = elem[18]
			Level.enemies[i-1].dodging_timer = elem[19]
			Level.enemies[i-1].shooting_timer = elem[20]
			Level.enemies[i-1].death_timer = elem[21]
			Level.enemies[i-1].wandering_timer = elem[22]
			Level.enemies[i-1].suspicion_timer = elem[23]
			Level.enemies[i-1].scared_timer = elem[24]
			Level.enemies[i-1].lastplayerpos = {elem[25], elem[26]}
			Level.enemies[i-1].destination = {elem[27], elem[28]}
			Level.enemies[i-1].lastpos = {elem[29], elem[30]}
			Level.enemies[i-1].see_player_timer = elem[31]
			Level.enemies[i-1].player_was_seen = intToBool(elem[32])
			Level.enemies[i-1].see_bullet_timer = elem[33]
			Level.enemies[i-1].bullet_was_seen = intToBool(elem[34])
			Level.enemies[i-1].ninja_see_player_timer = elem[35]
			Level.enemies[i-1].ninja_player_was_seen = intToBool(elem[36])
			Level.enemies[i-1].prediction_timer = elem[37]
		end
	end
end

function Editor.levelOptionsToString()
	local st = "level_options("
	st = st .. boolToInt(Level.enemylessmode)..","
	st = st .. boolToInt(Level.ninjamode)..","
	st = st .. boolToInt(Level.enemiescanshoot)..","
	st = st .. boolToInt(Level.autoturns)..","
	st = st .. boolToInt(Level.onebullet)..")\n"
	return st
end

function Editor.stringToLevelOptions( st )
	local openparenthesis = string.find(st,"%(")
	if not openparenthesis then return end
	local tabl={}
	for number in string.gmatch( string.sub(st,openparenthesis+1),"[%.%d]+") do
		table.insert(tabl,number)
	end
	if table.getn(tabl)>=5 then
		Level.enemylessmode = intToBool( tabl[1] )
		Level.ninjamode = intToBool( tabl[2] )
		Level.enemiescanshoot = intToBool( tabl[3] )
		Level.autoturns = intToBool( tabl[4] )
		Level.onebullet = intToBool( tabl[5] )
	end
end

function Editor.scandir(dirname)
        local tempname = os.tmpname()

		if os.getenv("OS")=="Windows_NT" then
			os.execute("dir /b "..dirname .. " >"..tempname.." 2>NUL")
        else
			os.execute("ls -a1 "..dirname .. " >"..tempname.." 2>/dev/null")
		end
		local f = io.open(tempname,"r")
        local contents = f:read("*all")
        f:close()
        os.remove(tempname)

        local tabby = {}
          local from  = 1
          local delim_from, delim_to = string.find( contents, "\n", from  )
          while delim_from do
                    table.insert( tabby, string.sub( contents, from , delim_from-1 ) )
                    from  = delim_to + 1
                    delim_from, delim_to = string.find( contents, "\n", from  )
                  end
        -- Comment out eliminates blank line on end!
          return tabby
        end

function Editor.refreshList()
-- scan directory
	local extension=".gfl"
	local listing = Editor.scandir( "\""..love.filesystem.getSaveDirectory( ).."\"" )
	local results = ""

	-- find files with wanted extension
	for i,line in ipairs(listing) do
		local puntpoint = string.find(line, extension)
		if  puntpoint then
			results = results..string.sub(line,1,puntpoint-1).."\n"
		end
	end

	Editor.saveinFile( Editor.listingfilename, results )


end

function Editor.getFileList()
	local filelist={}
	local d = Editor.loadfromFile( Editor.listingfilename )

		filelist = Split(d, "\n")

		for i,l in ipairs(filelist) do
			if string.len(l)==0 then
				table.remove(filelist,i)
			end
		end

	return filelist
end

function Editor.addEntryInFileList(entry)
	local data = Editor.loadfromFile( Editor.listingfilename )

	filelist = Split(data, "\n")
	for i,v in ipairs(filelist) do
		if v==entry then
			return  -- break! the file was already there
		end
	end

	data = data..entry.."\n"
	Editor.saveinFile(Editor.listingfilename, data )
end

function Editor.removeEntryFromfilelist( entry )
	local data = Editor.loadfromFile( Editor.listingfilename )
	filelist = Split(data, "\n")
	for i,v in ipairs(filelist) do
		if v==entry then
			table.remove(filelist,i)
		end
	end

	data = ""
	for i,v in ipairs(filelist) do
		if string.len(v)>0 then data = data..v.."\n" end
	end

	Editor.saveinFile( Editor.listingfilename, data )
end

function Editor.deletefile( filename )

	if love.filesystem.remove( filename..".gfl" ) then
		Editor.removeEntryFromfilelist( filename )
		Editor.currentfilename = ""
		Editor.listingtable = Editor.getFileList()
		if Editor.listingoffset+Editor.listinglength > table.getn(Editor.listingtable) and
			Editor.listingoffset > 0 then
			Editor.listingoffset = Editor.listingoffset - 1
		end
	end
end
