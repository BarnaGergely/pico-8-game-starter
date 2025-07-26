pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- awesome game
-- by chuck norris

-- This tab is for:
-- standalone code and init function
-- this code runs before game starts

-- standalone constants --

-- constants are used
-- to store the identifiers
-- of the game elements
-- such as colors, sprites, flags, etc.
-- to make it easier to access them.

-- todo: customize constants

-- color constants --
c_clr = {
	blk = 0, -- black
	drk_blu = 1, -- dark blue
	drk_purp = 2, -- dark purple
	drk_grn = 3, -- dark green
	brn = 4, -- brown
	drk_grey = 5, -- dark grey
	lt_grey = 6, -- light grey
	wht = 7, -- white
	red = 8, -- red
	orng = 9, -- orange
	yel = 10, -- yellow
	grn = 11, -- green
	blu = 12, -- blue
	ind = 13, -- indigo
	pink = 14, -- pink
	peach = 15 -- peach
}

-- sprite constants --
c_spr = {
	plr = 0, -- player sprite
	enemy = 1 -- enemy sprite
}

-- flag constants --
c_flg = {
	sld = 0, -- solid flag: like a wall
	hrt = 1 -- hurts flag: enemy, bullet
}

-- screen constants --
c_scr = {
	min = 0, -- min coordinate in the screen
	max = 127, -- max coordinate in the screen
	width = 128, -- screen width
	center = 127 / 2 -- center coordinate in the screen
}

-- standalone variables --

-- standalone variables are used to
-- to store data which not resets
-- when the game is reseted
-- such as highscores

highscore = 0 -- highscore

-- initialize game variables
-- and setup game
-- (called once at startup and reset)
function _init()
	-- starting variables --
	score = 0
	-- current score
	plr = {
		-- player object
		x = c_scr.center, -- player x coordinate
		y = c_scr.center, -- player y coordinate
		spr = c_spr.plr, -- player sprite
		health = 3 -- player health
	}
end

-->8
-- This tab is for:
-- update game logic, handle input
-- (called 60 times per second)
function _update()
	handle_input()
end

-- handle user input
function handle_input(speed)
	speed = speed or 1 -- set default speed if no speed is provided
	if btn(⬅️) then -- left pressed
		plr.x = plr.x - speed
	end
	if btn(➡️) then -- right pressed
		plr.x = plr.x + speed
	end
	if btn(⬆️) then -- up pressed
		plr.y = plr.y - speed
	end
	if btn(⬇️) then -- down pressed
		plr.y = plr.y + speed
	end
	if btn(❎) then -- X pressed
		-- perform action, e.g. shoot or interact
	end
	if btn(🅾️) then -- O pressed
		-- perform action
	end
end

-->8
-- This tab is for:
-- draw graphics to the screen
-- (called after each update)
function _draw()
	cls(c_clr.blk) -- clear the screen with black
	spr(plr.spr, plr.x, plr.y) -- draw player sprite
end

__gfx__
0cccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
