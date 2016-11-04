-- Euler Solver for basic kinematics
local vec2 = require "vec2"

function eulerAdvanceAllObjects(objectList, timestep)
	for k,v in pairs(objectList) do
		if v.static ~= true then
			v.pos = v.pos + v.vel*timestep
			v.vel = v.vel + sunForce(objectList, k)/v.m*timestep
		end
	end
end

function sunForce(objectList, k)
	local me = objectList[k]
	return -me.pos:normalized()*(10000*me.m)/(me.pos:dist2(vec2(0,0)))
end

function totalForceOnObject(list, except)
	local force = vec2(0,0)
	local me = list[except]
	for k,v in pairs(list) do
		if k ~= except then
			force = force + (v.pos-me.pos):normalized()*(v.m*me.m)/(me.pos:dist2(v.pos))
		end
	end
	return force
end

return eulerAdvanceAllObjects