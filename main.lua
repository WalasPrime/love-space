local planets = require "planets"

local currentScale = 0.3
local planetScale = 10
local distanceScale = 50

local timeAccum = 0

function love.load()
	print("Starting...")
	planets.addPlanet("Merkury", 0.38, 0.05, 0.38)
	planets.addPlanet("Wenus", 0.72, 0.81, 0.94)
	planets.addPlanet("Ziemia", 1, 1, 1)
	planets.addPlanet("Mars", 1.52, 0.1, 0.53)
	planets.addPlanet("Jowisz", 5.2, 317.8, 11.2)
	planets.addPlanet("Saturn", 9.53, 95.16, 9.44)
	planets.addPlanet("Uran", 19.19, 14.53, 4)
	planets.addPlanet("Neptun", 30, 17.14, 3.88)
end

function love.draw()
	w,h = love.graphics.getDimensions()
	love.graphics.push()
	love.graphics.translate(w/2,h/2)
	love.graphics.scale(currentScale,currentScale)
	love.graphics.circle("line",0,0,10)

	for _,v in pairs(planets.planets) do
		love.graphics.push()
		love.graphics.rotate(timeAccum*3/v.dist)
			love.graphics.translate(v.pos.x*distanceScale, v.pos.y*distanceScale)
			love.graphics.circle("fill", 0, 0, planetScale*v.r)
		love.graphics.pop()
	end

	love.graphics.pop()
end

function love.update(dt)
	timeAccum = timeAccum + dt
end