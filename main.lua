local planets = require "planets"
local solver = require "euler"

local planetScale = 20
local distanceScale = 5

local timeAccum = 0

local userZoom = 1

local pUScale = 100
function love.load()
	print("Starting...")
	planets.addPlanet("Merkury", pUScale*0.38, 0.05, 0.38, 13)
	planets.addPlanet("Wenus", pUScale*0.72, 0.81, 0.94, 10)
	planets.addPlanet("Ziemia", pUScale*1, 1, 1, 8)
	planets.addPlanet("Mars", pUScale*1.52, 0.1, 0.53, 7)
	planets.addPlanet("Jowisz", pUScale*5.2, 317.8, 11.2, 4)
	planets.addPlanet("Saturn", pUScale*9.53, 95.16, 9.44, 3)
	planets.addPlanet("Uran", pUScale*19.19, 14.53, 4, 2)
	planets.addPlanet("Neptun", pUScale*30, 17.14, 3.88, 1.3)

end

function love.draw()
	w,h = love.graphics.getDimensions()
	love.graphics.push()
	love.graphics.translate(w/2,h/2)

	-- Zoom
	love.graphics.scale(userZoom,userZoom)

	for _,v in pairs(planets.planets) do
		love.graphics.push()
		--love.graphics.rotate(timeAccum*3/v.dist)
			love.graphics.translate(v.pos.x*distanceScale, v.pos.y*distanceScale)
			love.graphics.circle("fill", 0, 0, planetScale*v.r)
		love.graphics.pop()
	end

	love.graphics.pop()
end

function love.update(dt)
	timeAccum = timeAccum + dt
	local i = 0
	while i < 30 do
		solver(planets.planets, dt)
		i = i + 1
	end
end

function love.keypressed(key,rep)

end

function love.wheelmoved(x,y)
	if y > 0 then
		userZoom = userZoom * 2
	else
		userZoom = userZoom / 2
	end
end

function love.mousepressed(x,y,btn,touch)
	print (btn)
end