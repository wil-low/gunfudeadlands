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


mymath = {}

-- 2d rotation of a vector, angle given in radians
function mymath.get_rotation_matrix( angle )
	local c,s = math.cos(angle), math.sin(angle)
	return { c, -s, s, c }
end

function mymath.rotate(vector, angle)
	local m = mymath.get_rotation_matrix(angle)
	return {vector[1]*m[1]+vector[2]*m[2],vector[1]*m[3]+vector[2]*m[4]}
end

function mymath.disturb_vector(vector, deviation)
	local normal_dist = mymath.randn2()
	local direction = {vector[1] + normal_dist[1] * deviation, vector[2] + normal_dist[2] * deviation }
	-- force normalization again
	return mymath.get_dir_vector( 0, 0, direction[1], direction[2] )
end

function mymath.sign( a )
	if a>=0 then return 1 end
	return -1
end

function mymath.round( r )
	return math.floor(r+0.5)
end

function mymath.normalize_vector( vec )
	local mag = math.sqrt( vec[1]*vec[1] + vec[2]*vec[2] )
	return { vec[1] / mag, vec[2] / mag }
end

function mymath.get_angle( v1, v2 )
	nv1 = mymath.normalize_vector( v1 )
	nv2 = mymath.normalize_vector( v2 )
 	local cosangle = math.acos( nv1[1]*nv2[1] + nv1[2]*nv2[2] )
	local sinangle = math.asin( nv1[1]*nv2[2] - nv1[2]*nv2[1] )

	return cosangle*mymath.sign(sinangle)

end



-- returns gaussian random number
-- from http://www.taygeta.com/random/gaussian.html
-- Algorithm by Dr. Everett (Skip) Carter, Jr.

function mymath.randn()
	local x1,x2
	local w = 1
	while w >= 1 and w>0 do
		x1 = 2 * math.random() - 1
		x2 = 2 * math.random() - 1
		w = x1*x1 + x2*x2
	end

	w = math.sqrt( (-2 * math.log( w ) / w ) )
	return x1 * w
end

function mymath.randn2()
	local x1,x2
	local w = 1
	while w >= 1 and w>0 do
		x1 = 2 * math.random() - 1
		x2 = 2 * math.random() - 1
		w = x1*x1 + x2*x2
	end

	w = math.sqrt( (-2 * math.log( w ) / w ) )
	return {x1 * w, x2 * w}
end

-- returns a list with the ordinals of a random permutation of length len
function mymath.permutation( len )
	used = {}
	seq = {}

	for i=1,len do
		used[i]=0
	end

	for i=1,len do
		newnum = math.random(len-i+1)
		j=0
		while newnum>0 do
			j=j+1
			if used[j]==0 then
				newnum = newnum-1
			end
		end

		used[j]=1
		seq[i]=j
	end

	return seq

end

function mymath.get_distance(point1, point2)
	local dx = point2[1] - point1[1]
	local dy = point2[2] - point1[2]
	return math.sqrt(dx*dx + dy*dy)
end

function mymath.get_distanceSq(point1, point2)
	local dx = point2[1] - point1[1]
	local dy = point2[2] - point1[2]
	return (dx*dx + dy*dy)
end

-- the "public" function
function mymath.check_intersection(segment, box)

  -- the first point is inside the box?
  if segment[1]>= box[1] and segment[1]<=box[3] and segment[2]>=box[2] and segment[2]<=box[4] then
	return true
  end

  -- the second point is inside the box?
  if segment[3]>= box[1] and segment[3]<=box[3] and segment[4]>=box[2] and segment[4]<=box[4] then
	return true
  end

  -- we sort here the segment coordinates because we treat it as a box
  if not mymath.check_boxes(
    { math.min(segment[1],segment[3]), math.min(segment[2],segment[4]),
	  math.max(segment[1],segment[3]), math.max(segment[2],segment[4]) },
	box
  ) then
	return false
  end


  -- for the real intersection check, the points must not be sorted
  return mymath.check_intersection_internal( segment, box )

end


-- for internal use
function mymath.check_intersection_internal( segment, box )
	local dX = segment[3] - segment[1]
	local dY = segment[4] - segment[2]
	
	if math.abs(dX) > 0.001 then
		-- find intersection with left side of the box
		local tL = (box[1]-segment[1])/dX
		if tL >= 0  and tL <= 1 -- in the valid range
		then
			local yL = segment[2] + tL*dY
			if yL <= box[4] and yL >= box[2] then
				return true -- yes they are!
			end
		end


		-- find intersection with right side of the box
		local tR = (box[3]-segment[1])/dX
		if tR >= 0  and tR <= 1 -- in the valid range
		then
			local yR = segment[2] + tR*dY
			if yR <= box[4] and yR >= box[2] then
				return true -- yes they are!
			end
		end

	end

	if math.abs(dY) > 0.001 then
		-- find intersection with upper side of the box
		local tU = (box[2]-segment[2])/dY
		if tU >= 0  and tU <= 1 -- in the valid range
		then
			local xU = segment[1] + tU*dX
			if xU >= box[1] and xU <= box[3] then
				return true -- yes they are!
			end
		end

		-- find intersection with lower side of the box
		local tD = (box[4]-segment[2])/dY
		if tD >= 0  and tD <= 1 -- in the valid range
		then
			local xD = segment[1] + tD*dX
			if xD >= box[1] and xD <= box[3] then
				return true -- yes they are!
			end
		end
	end

	return false
end

-- for internal use (returns true if boxes intersect
function mymath.check_boxes(box1, box2)
	if box1[3]<box2[1] or
		box1[1]>box2[3] or
		box1[2]>box2[4] or
		box1[4]<box2[2] then 
		return false 
	end
	return true
end

function mymath.check_boxinbox(small_box, big_box)
	if small_box[1] < big_box[1] or
		small_box[2] < big_box[2] or
		small_box[3] > big_box[3] or
		small_box[4] > big_box[4] then 
		return false 
	end
	return true
end

function mymath.check_pointinbox(point, box)
	if point[1] >= box[1] and point[1] <= box[3] and
		point[2] >= box[2] and point[2] <= box[4] then
		return true
	else
		return false
	end
end

function mymath.get_dir_vector(origx, origy, destx, desty)
	-- local destv = { love.mouse.getX() - origx, love.mouse.getY() - origy }
	local destv = { destx - origx, desty - origy }
	local modul = math.sqrt( destv[1]*destv[1] + destv[2]*destv[2] )
	if modul < 0.001 then
	  modul = 0.001
	end
	return { destv[1]/modul, destv[2]/modul }
end


-- more complex collision detection
function mymath.check_pointinbuilding( point, building )
	-- for each box...
	-- first check if the point is inside the box
	-- if it is, check if it's also inside all the halfspaces
	for i,colli in ipairs(building.collision) do
		if mymath.check_pointinbox(point, colli) then
				return true

		end
	end
	return false
end

function mymath.check_segmentinbuilding( segment, building )
	-- for each box...
	-- first check if the segment intersects the bounding box
	-- if it does, check if at least one of the points is actually inside
	for i,colli in ipairs(building.collision) do
		if mymath.check_intersection(segment, colli) then
				return true

		end
	end
	return false

end

-- assuming the point is outside of the box
-- returns { distance squared, pointx, pointy }
-- the returned point is the closest point in the box's edge to the input point
function mymath.distanceSq_to_box( point, box )
	-- directly above or below?
	if point[1] >= box[1] and point[1]<= box[3] then
		if point[2] < box[2] then
			-- above
			local diff = box[2] - point[2]
			return { diff*diff, point[1], box[2] }
		else
			-- below
			local diff = box[4] - point[2]
			return { diff*diff, point[1], box[4] }
		end
	end
	
	-- directly on the side?
	if point[2] >= box[2] and point[2]<= box[4] then
		if point[1] < box[1] then
			-- left
			local diff = box[1] - point[1]
			return { diff*diff, box[1], point[2] }
		else
			-- right
			local diff = box[3] - point[1]
			return { diff*diff, box[3], point[2] }
		end
	end
	
	-- diagonal...
	local p1
	if point[1] < box[1] then
		p1 = box[1]
	else
		p1 = box[3]
	end
	
	local p2
	if point[2] < box[2] then
		p2 = box[2]
	else
		p2 = box[4]
	end
	
	local d1,d2 = p1 - point[1], p2 - point[2]
	return {d1*d1+d2*d2, p1, p2}
end

function mymath.check_boxinbuilding( box1, building )
	-- first check mutual box collision
	-- if it happens, check each individual point and see if at least
	-- one of them is inside the building
	for i,colli in ipairs(building.collision) do
		if mymath.check_boxes(box1, colli) then
			return true
		end
	end
	return false
end


