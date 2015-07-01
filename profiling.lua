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

ProfilingEnabled = true
DebugInfo = {}
DebugStrings = {}

function doTrace( when )
	local funcname = debug.getinfo(2,"n").name
	if not funcname then 
		return
	end
	
	if when == "call" then
		beginBlock(funcname)
	elseif when == "return" then
		endBlock(funcname)
	end
end

function beginBlock( funcname )
	if not DebugInfo[funcname] then
		table.insert( DebugStrings, funcname )
		DebugInfo[funcname] = {calls=0, totaltime=0, timers={}}
	end
	table.insert(DebugInfo[funcname].timers, os.clock())
end

function endBlock( funcname )
	local entry = DebugInfo[ funcname ]
	if entry then
		local ndx = table.getn(entry.timers)
		if (ndx > 0) then
			local duration = os.clock() - entry.timers[ndx]
			table.remove( entry.timers, ndx )
			entry.totaltime = entry.totaltime + duration
			entry.calls = entry.calls + 1
		end
	end
end

function dumpTrace()
	print("funcname totaltime meantime callcount")
	for i,funcname in ipairs(DebugStrings) do
		if DebugInfo[funcname].calls > 0 then
			print( funcname .. " " .. DebugInfo[funcname].totaltime .. " " .. DebugInfo[funcname].totaltime/DebugInfo[funcname].calls*1e6 .. " " .. DebugInfo[funcname].calls )
		end
	end
end
	
debug.sethook( doTrace, "cr" )