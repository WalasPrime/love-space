local vec2 = require "vec2"

local planets = {
	planets = {},
	sun = nil
}

function stableOrbitVel(M, dist)
	return math.sqrt(M/dist)
end

function planets.addPlanet(name_, sun_distance_, mass_, size_, hvel_, img_)
	table.insert(planets.planets, {static = false, name = name_, img = img_, dist = sun_distance_, m = mass_, pos = vec2(sun_distance_,0), r = size_, vel = vec2(0, hvel_)})
end

function planets.makeSun(planetName)
	for _,v in pairs(planets.planets) do
		if v.name == planetName then
			v.static = true;
			planets.sun = v
		end
	end
	for _,v in pairs(planets.planets) do
		if v ~= planets.sun then
			v.vel = vec2(0,stableOrbitVel(v.m*planets.sun.m, v.pos.y))
		end
	end
end

return planets