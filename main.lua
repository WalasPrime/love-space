local vec2 = require "vec2"
local planets = require "planets"
local solver = require "euler"

local planetScale = 20
local distanceScale = 5

local timeAccum = 0

local userZoom = 1
local userPos = vec2(0,0)

local pUScale = 100

local planetShader, planetMesh, nebulaBg, sunFlare, chroma, lensFlare
function love.load()
	print("Starting...")
	planets.addPlanet("Merkury", pUScale*0.38, 0.05, 0.38, 13, love.graphics.newImage('gfx/edu_what_is_mars.jpg'))
	planets.addPlanet("Wenus", pUScale*0.72, 0.81, 0.94, 10, love.graphics.newImage('gfx/8.png'))
	planets.addPlanet("Ziemia", pUScale*1, 1, 1, 8, love.graphics.newImage('gfx/289884_900.jpg'))
	planets.addPlanet("Mars", pUScale*1.52, 0.1, 0.53, 7, love.graphics.newImage('gfx/nettuno,-pianeta-187078.jpg'))
	planets.addPlanet("Jowisz", pUScale*5.2, 317.8, 11.2, 4, love.graphics.newImage('gfx/GasGiant-Ca04.png'))
	planets.addPlanet("Saturn", pUScale*9.53, 95.16, 9.44, 3, love.graphics.newImage('gfx/0010_23.jpg'))
	planets.addPlanet("Uran", pUScale*19.19, 14.53, 4, 2, love.graphics.newImage('gfx/Planet-Venus-3D-Screensaver.jpg'))
	planets.addPlanet("Neptun", pUScale*30, 17.14, 3.88, 1.3, love.graphics.newImage('gfx/Glacial-0005.png'))

	planetShader = require "planet_shader"
	local normalSphere = love.graphics.newImage('gfx/sphere_normal.jpg')
	planetShader:send("sphere_normal", normalSphere)

	planetMesh = love.graphics.newMesh({
		{0,0,0,0}, {0,1,0,1},
		{1,1,1,1}, {1,0,1,0}
	})

	nebulaBg = love.graphics.newImage('gfx/nebula-bg.jpg')
	sunFlare = love.graphics.newImage('gfx/flare.jpg')
	chroma = love.graphics.newImage('gfx/lens_chroma.png')
	lensFlare = love.graphics.newImage('gfx/lensflare.png')

	makeLensFlares()
end

local lensFlares = {}
function makeLensFlares()
	local amp = 2
	local num = 10
	for i=1,num do
		local distMult = ((2*i-num/2) + love.math.randomNormal(1,0))/num
		local clr = {125+love.math.random(0,125), 125+love.math.random(0,125), 200+love.math.random(0,55)}
		table.insert(lensFlares, {mul = distMult, lmul = love.math.random()*0.7, size = love.math.randomNormal(1,0), color = clr})
	end
end

local bgStars = {}
function mageBgStar(bounds)
	local pos = {x=0,y=0,zmult=love.math.randomNormal(1,0)*1}
	local dice = love.math.random(1,4)
	-- x
	if dice % 2 == 0 then
		pos.x = love.math.random(bounds[1], bounds[3])
		if dice == 2 then
			pos.y = bounds[2]
		else
			pos.y = bounds[4]
		end
	else
		pos.y = love.math.random(bounds[2], bounds[4])
		if dice == 1 then
			pos.x = bounds[1]
		else
			pos.x = bounds[3]
		end
	end
	table.insert(bgStars, {x = pos.x, y = pos.y, zmult = pos.zmult})
end
function initBgStar(bounds)
	table.insert(bgStars, {x = love.math.random(bounds[1], bounds[3]), y = love.math.random(bounds[2], bounds[4]), zmult = love.math.randomNormal(1,0)*1})
end
function love.draw()
	w,h = love.graphics.getDimensions()

	--love.graphics.setColor(255,255,255)
	--love.graphics.rectangle("fill",0,0,w,h)

	love.graphics.push()
	love.graphics.translate(w/2,h/2)

	love.graphics.push()
		love.graphics.scale(1+userZoom/30, 1+userZoom/30)
		love.graphics.translate(userPos.x/200, userPos.y/200)
		love.graphics.setColor(255,255,255,math.min(120,100/(userZoom/1)))
		love.graphics.draw(nebulaBg, -nebulaBg:getWidth()/2, -nebulaBg:getHeight()/2)
	love.graphics.pop()

	-- Zoom
	love.graphics.scale(userZoom,userZoom)
	love.graphics.translate(userPos.x, userPos.y)

	love.graphics.setColor(255,255,255)
	love.graphics.setShader(planetShader)
	for _,v in pairs(planets.planets) do
		love.graphics.push()
		--love.graphics.rotate(timeAccum*3/v.dist)
			love.graphics.translate(v.pos.x*distanceScale, v.pos.y*distanceScale)
			--love.graphics.circle("fill", 0, 0, planetScale*v.r)
			love.graphics.scale(planetScale*v.r*2)
			planetShader:send("dirToSun", vec2(-v.pos.x, v.pos.y):normalized():table())
			if v.img then planetShader:send("sphere_texture", v.img) end
			love.graphics.draw(planetMesh)
		love.graphics.pop()
	end

	love.graphics.setShader()

	-- bgStars
	love.graphics.setPointSize(2)
	for _,v in pairs(bgStars) do
		love.graphics.push()
			love.graphics.translate(v.x+(userPos.x-v.x)*v.zmult, v.y+(userPos.y-v.y)*v.zmult)
			local shade = 125+(v.zmult)*50
			love.graphics.setColor(shade,shade,shade,127/(userZoom/2))
			love.graphics.points({0,0})
			--love.graphics.circle("fill",0,0,10)
		love.graphics.pop()
	end

	-- Star
	love.graphics.setBlendMode("add")
	love.graphics.push()
		love.graphics.setColor(100,100,255)
		love.graphics.circle("fill",0 ,0, planetScale)
		love.graphics.setColor(255,255,255)
		love.graphics.scale(1/userZoom,1/userZoom)
		local mag = math.max(userZoom/2,1)
		love.graphics.scale(mag,mag)
		love.graphics.draw(sunFlare,-sunFlare:getWidth()/2,-sunFlare:getHeight()/2+29)
	love.graphics.pop()

	-- Star and lens flare
	-- (only if Star is within the screenspace)
	local camPos = vec2(userPos.x*userZoom, userPos.y*userZoom)
	if math.abs(camPos.x) < w/2 and math.abs(camPos.y) < h/2 then
		local LIGHT = (1-camPos:dist(vec2(0,0))*userZoom/(userZoom*w/2))
		love.graphics.push()
			love.graphics.scale(1/userZoom, 1/userZoom)
			love.graphics.translate(-camPos.x*2, -camPos.y*2)
			local angle = camPos:angleTo(vec2(0,1))
			love.graphics.rotate(angle)
			love.graphics.setColor(255,255,255,127*LIGHT)
			love.graphics.draw(chroma, -chroma:getWidth()/2, -chroma:getHeight()/2)
		love.graphics.pop()

		love.graphics.push()
			love.graphics.scale(1/userZoom, 1/userZoom)
			for _,v in pairs(lensFlares) do
				love.graphics.push()
					love.graphics.translate(-camPos.x*2*v.mul, -camPos.y*2*v.mul)
					love.graphics.scale(v.size, v.size)
					love.graphics.setColor(v.color[1],v.color[2],v.color[3],127*v.lmul*LIGHT)
					love.graphics.draw(lensFlare, -lensFlare:getWidth()/2, -lensFlare:getHeight()/2)
				love.graphics.pop()
			end
		love.graphics.pop()
	end
	love.graphics.setBlendMode("alpha")

	love.graphics.pop()
end

function getDefaultBounds()
	local w,h = love.graphics.getDimensions()
	local realZoom = userZoom
	local bounds = {-userPos.x-w/2/realZoom, -userPos.y-h/2/realZoom, -userPos.x+w/2/realZoom, -userPos.y+h/2/realZoom}
	return bounds
end
function love.update(dt)
	timeAccum = timeAccum + dt
	local i = 0
	while i < 2*(1/userZoom) do
		solver(planets.planets, dt*(1/userZoom/10))
		i = i + 1
	end

	-- bgStars
	local removalBound = 10/userZoom
	local bounds = getDefaultBounds()
	for k,v in pairs(bgStars) do
		if v.x < bounds[1]-removalBound or v.x > bounds[3]+removalBound or v.y < bounds[2]-removalBound or v.y > bounds[4]+removalBound then
			table.remove(bgStars, k)
		end
	end
	if #bgStars == 0 then
		for i=0,100 do
			initBgStar(bounds)
		end
	end
	for i=#bgStars,100 do
		mageBgStar(bounds)
	end
end

function love.keypressed(key,rep)

end

function love.wheelmoved(x,y)
	local oldZoom = userZoom 
	if y > 0 then
		userZoom = userZoom * 2
	else
		userZoom = userZoom / 2
	end
	if userZoom < 0.02 then userZoom = 0.02 end
	if userZoom ~= oldZoom then bgStars = {} end
end


local mouseDrag = false
function love.mousepressed(x,y,btn,touch)
	if btn == 2 and not touch then
		mouseDrag = true
	end
end
function love.mousereleased(x,y,btn,touch)
	if btn == 2 and not touch then
		mouseDrag = false
	end
end
function love.mousemoved(x,y,dx,dy,touch)
	if mouseDrag then
		userPos = userPos+vec2(dx,dy)*(1/userZoom)
	end
end

function love.touchmoved(id,x,y,dx,dy,pressure)
	local touches = love.touch.getTouches()
	if table.getn(touches) == 2 then
		for _,v in pairs(touches) do
			if v ~= id then
				local ox, oy = love.touch.getPosition(v)
				
				local p1 = vec2(x-ox, y-oy):normalized()
				local p2 = vec2(dx,dy):normalized()

				local dot = p1.x*p2.x + p1.y*p2.y

				userZoom = userZoom + userZoom*dot*vec2(dx,dy):len()/100
				table.remove(bgStars, 1)
				if userZoom < 0.02 then userZoom = 0.02 end
			end
		end
	elseif table.getn(touches) == 1 then
		userPos = userPos+vec2(dx,dy)*(1/userZoom)
	end
end