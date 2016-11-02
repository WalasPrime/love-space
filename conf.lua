function love.conf(t)
	t.modules.physics = false
	t.modules.joystick = false

	t.version = "0.10.2"
	t.console = true

	t.window.title = "Love Space - Fizyka i animacja w grafice komputerowej - projekt"
	t.window.borderless = false
	t.window.resizable = true
	t.window.minwidth = 640
	t.window.minheight = 640
	t.window.fullscreen = false
	t.window.vsync = true

	love.filesystem.setIdentity("lovespace")
end