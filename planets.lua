local vec2 = require "vec2"

local planets = {
	planets = {}
}

function planets.addPlanet(name_, sun_distance_, mass_, size_)
	table.insert(planets.planets, {name = name_, dist = sun_distance_, m = mass_, pos = vec2(sun_distance_,0), r = size_})
end

return planets