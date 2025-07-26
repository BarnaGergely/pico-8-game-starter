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
clr_blk = 0 -- black
clr_drk_blu = 1 -- dark blue
clr_drk_purp = 2 -- dark purple
clr_drk_grn = 3 -- dark green
clr_brn = 4 -- brown
clr_drk_grey = 5 -- dark grey
clr_lt_grey = 6 -- light grey
clr_wht = 7 -- white
clr_red = 8 -- red
clr_orng = 9 -- orange
clr_yel = 10 -- yellow
clr_grn = 11 -- green
clr_blu = 12 -- blue
clr_ind = 13 -- indigo
clr_pink = 14 -- pink
clr_peach = 15 -- peach

-- sprite constants --
spr_plr = 1 -- player sprite
spr_enemy = 2 -- enemy sprite

-- flag constants --
flg_sld = 0 -- solid flag: like a wall
flg_hrt = 1 -- hurts flag: enemy, bullet


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
    score = 0 -- current score
end

-->8
-- This tab is for:
-- update game logic, handle input
-- (called 60 times per second)
function _update()

end

-->8
-- This tab is for:
-- draw graphics to the screen
-- (called after each update)
function _draw()
    cls(clr_blk) -- clear the screen with black
    print("game is ready")
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
