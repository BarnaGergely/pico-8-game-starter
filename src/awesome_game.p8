pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--awesome game
--by chuck norris

--constants--

--static values,
--identifiers of game elements
--such as sprites, flags, sizes
--makes it easier to access them

--sprites
c_spr = {
	plr = 0, --player
	lava = 1 --lava
}

--flags
c_flg = {
	wall = 1,
	kills = 2
}

--standalone variables--

--data which not resets
--when the game is reseted
--such as highscores

highscore = 0

function _init()
	init_plr()

	score = 0 --current score
end--_init

function _update()
	upd_plr()
end--_update

function _draw()
	cls() --clear screen
	map() --draw map
	draw_plr()
end--_draw

-->8
--player movement--

-- initialize player
function init_plr()
	plr = {
		x = 0,
		y = 0,
		w = 8, --width
		h = 8, --height
		speed = 1,
		spr = c_spr.plr --sprite
	}
end--init_plr

-- update player
function upd_plr()
	--store old position
	local old_x = plr.x
	local old_y = plr.y

	--handle movement input
	if btn(⬅️) then
		plr.x=plr.x-plr.speed
	elseif btn(➡️) then
		plr.x=plr.x+plr.speed
	end--if⬅️➡️
	
	if btn(⬆️) then
		plr.y=plr.y-plr.speed
	elseif btn(⬇️) then
		plr.y=plr.y+plr.speed
	end--if⬆️⬇️

	-- if collision with wall
	if plr_coll_flag(c_flg.wall) then
		--revert to old position
		plr.x = old_x
		plr.y = old_y
	end--if collision
end--upd_plr

-- draw player
function draw_plr()
	spr(plr.spr, plr.x, plr.y, 
	    plr.w / 8, plr.h / 8)
end--draw_plr

-- is player collides with flag
function plr_coll_flag(flag)
	--4 corners of player sprite
	local tl=fget(mget(plr.x,plr.y),flag)
	local tr=fget(mget(plr.x+7,plr.y),flag)
	local bl=fget(mget(plr.x,plr.y+7),flag)
	local br=fget(mget(plr.x+7,plr.y+7),flag)

	--if any corner collides
	if tl or tr or bl or br then
		return true
	else
		return false
	end	
end--plr_coll_flag

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
