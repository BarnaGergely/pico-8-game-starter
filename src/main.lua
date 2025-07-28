--This tab is for:
--standalone code and init function
--this code runs before game starts

--standalone constants--

--constants are used
--to store the identifiers
--of the game elements
--such as colors, sprites, flags, etc.
--to make it easier to access them.

--todo: customize constants

--color constants
c_clr = {
	blk = 0, --black
	drk_blu = 1, --dark blue
	drk_purp = 2, --dark purple
	drk_grn = 3, --dark green
	brn = 4, --brown
	drk_grey = 5, --dark grey
	lt_grey = 6, --light grey
	wht = 7, --white
	red = 8, --red
	orng = 9, --orange
	yel = 10, --yellow
	grn = 11, --green
	blu = 12, --blue
	ind = 13, --indigo
	pink = 14, --pink
	peach = 15 --peach
}

--sprite constants
c_spr = {
	plr = 0, --player sprite
	enemy = 1 --enemy sprite
}

--flag constants
c_flg = {
	sld = 0, --solid flag: like a wall
	hrt = 1 --hurts flag: enemy, bullet
}

--screen constants
c_scr = {
	min = 0, --min coordinate in the screen
	max = 127, --max coordinate in the screen
	width = 128, --screen width
	center = 127 / 2 --center coordinate in the screen
}

--Screen boundary constants
c_bnd_scr = {
	min_x = c_scr.min,
	max_x = c_scr.max,
	min_y = c_scr.min,
	max_y = c_scr.max
}

c_gravity = 0.3 --gravity constant
c_friction = 0.1 --friction constant

--standalone variables--

--standalone variables are used
--to store data which not resets
--when the game is reseted
--such as highscores

highscore = 0 --highscore
debug_message = "" --debug message

--initialize game variables
--and setup game
--(called once at startup and reset)
function _init()
	--starting variables --
	score = 0 --current score
	plr = { --player object
		x = c_scr.center, --player x coordinate
		y = c_scr.center, --player y coordinate
		dx = 0, --player x speed (delta x)
		dy = 0, --player y speed (delta y)
		dx_max = 2, --player max x speed
		dy_max = 2, --player max y speed
		acc = 0.5, --player acceleration
		boost = 4, --jump speed boost
		w = 8, --player width
		h = 8, --player height
		flip_x = false, --player sprite flipped horizontally
		flip_y = false, --player sprite flipped vertically
		spr = c_spr.plr, --player sprite
		anim = 0, --player animation timing
	}
end

-->8
--This tab is for:
--update game logic, handle input
--(called 60 times per second)
function _update()
	handle_controls()
	handle_plr_movement()
end

--handle button presses (controls)
function handle_controls(speed)
	speed = speed or 1 --set default speed if no speed is provided
	if btn(⬅️) then --left pressed
		plr.dx -= plr.acc
		plr.flip_x = true
	end
	if btn(➡️) then --right pressed
		plr.dx += plr.acc
		plr.flip_x = false
	end
	if btn(⬆️) then --up pressed
		plr.dy -= plr.acc
		plr.flip_y = true
	end
	if btn(⬇️) then --down pressed
		plr.dy += plr.acc
		plr.flip_y = false
	end
	if btn(❎) then --X pressed
		--perform action, e.g. shoot or  interact
	end
	if btn(🅾️) then --O pressed
		--perform jump
		plr.dy -= plr.acc * plr.boost
	end
end

function handle_plr_movement()
	--apply friction
	plr.dx = approach(plr.dx, 0, c_friction)

	--apply gravity
	plr.dy += c_gravity

	--limit player speed
	plr.dx = mid(-plr.dx_max, plr.dx, plr.dx_max)
	plr.dy = mid(-plr.dy_max, plr.dy, plr.dy_max)

	handle_boundary_collision()

	handle_map_collision()

	--update player position
	plr.x += plr.dx
	plr.y += plr.dy
end

function handle_map_collision()
end

function handle_boundary_collision()
	--if the next position is
	--out of bounds,
	--then stop the player

	--The two sides of the boundary
	--are checked separately
	--to allow diagonal movement

    -- Check X boundary separately
    local next_x_pos = {
        x = plr.x + plr.dx,
        y = plr.y,
        w = plr.w,
        h = plr.h
    }
    if rect_boundary_collision(next_x_pos, c_bnd_scr) then
        plr.dx = 0
    end

    -- Check Y boundary separately
    local next_y_pos = {
        x = plr.x,
        y = plr.y + plr.dy,
        w = plr.w,
        h = plr.h
    }
    if rect_boundary_collision(next_y_pos, c_bnd_scr) then
        plr.dy = 0
    end
end

function rect_boundary_collision(r, b)
    return r.x < b.min_x or
         flr(r.x + r.w - 1) > b.max_x or
         r.y < b.min_y or
         flr(r.y + r.h - 1) > b.max_y
end

--approach function
--approaches val1 to val2 by amount
function approach(val1, val2, amount)
    if (val1 < val2) then
        return min(val1 + amount, val2)
    else
        return max(val1 - amount, val2)
    end
end

-->8
--This tab is for:
--draw graphics to the screen
--(called after each update)
function _draw()
	cls(c_clr.blk) --clear the screen with black
	map(0, 0) --draw the map
	vis_hitbox(plr)
	local scr_hitbox = {
		x = c_scr.min,
		y = c_scr.min,
		w = c_scr.width,
		h = c_scr.width
	}
	vis_hitbox(scr_hitbox, c_clr.pink) --visualize screen boundaries
	spr(plr.spr, plr.x, plr.y, plr.w/8, plr.h/8, plr.flip_x, plr.flip_y) --draw player sprite
	--draw debug message
	if debug_message ~= "" then
		print(debug_message, 0, 100, c_clr.wht) --print debug message at (0, 100)
	end
	-- TODO: why we need to divide width and height by 8?
end

--visualize rectangle hitbox
--(for debugging purposes)
function vis_hitbox(obj, clr)
	clr = clr or c_clr.pink --set default color if no color is provided

	--show pixels in the corners of the rectangle
	pset(obj.x, obj.y, clr) --top-left corner
	pset(obj.x + obj.w - 1, obj.y, clr) --top-right corner
	pset(obj.x, obj.y + obj.h - 1, clr) --bottom-left corner
	pset(obj.x + obj.w - 1, obj.y + obj.h - 1, clr) --bottom-right corner
end