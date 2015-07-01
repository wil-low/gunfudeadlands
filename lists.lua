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

List = {}

function List.newlist(val)
	return {next = nil, prev=nil, value = val }
end


function List.push(node,val)
    local last
    if node then
		last = node
	else
		last = nil
	end

	node = {next = node, prev= nil, value = val }

	if last then
		last.prev = node
	end

	return node
end

function List.del(list, node)
	local beginning = list
	if node == beginning then
		beginning = beginning.next
	end
	if node.prev then
		node.prev.next = node.next
	end
	if node.next then
		node.next.prev = node.prev
	end
	node = nil
	return beginning
end

function List.count(beginning)
	local count = 0
	local l = beginning
	while l do
		count = count + 1
		l = l.next
	end
	return count
end

-- aplies func(params) to each element
function List.apply(beginning, func, params)
	local l = beginning
	while l do
		if l.value then
			if params then
				func(l.value, params)
			else
				func(l.value)
			end
		end
		l = l.next
	end
end

-- applies func(params) to each element.  If func returns false, element is
-- deleted, else it is kept
function List.applydel(beginning, func, params)
	local l = beginning
	local newb = beginning
	while l do
		if l.value then
			if params then
				if not func(l.value, params) then
					newb = List.del(newb, l)
				end
			else
				if not func(l.value) then
					newb = List.del(newb, l)
				end
			end
		end
		l = l.next
	end
	return newb
end

-- applies func(params) to each element until func returns false, then returns true if all the list was processed
function List.applyfirst(beginning, func, params)
	local l = beginning
	while l do
		if l.value then
			if params then
				if not func(l.value, params) then
					return false
				end
			else
				if not func(l.value) then
					return false
				end
			end
		end
		l = l.next
	end
	return true
end

function List.reset(beginning)
	local l = beginning
	while l do
		local n = l.next
		l = {next = nil, prev= nil, value = nil }
		l = n
	end
	return nil
end

function List.fromArray(array)
	local newlist = nil
	for i,v in ipairs(array) do
		newlist = List.push(newlist, v)
	end
	return newlist
end

function List.pushToFront(beginning, node)
	if node == beginning then 
		return beginning
	end
	if node.next then
		node.next.prev = node.prev
	end
	if node.prev then
		node.prev.next = node.next
	end
	node.prev = nil
	node.next = beginning
	beginning.prev = node
	
	return node
end
