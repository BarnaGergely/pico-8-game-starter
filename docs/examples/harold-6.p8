pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- harold's bad day
-- by biovoid
-- rob@rmd.com.au
-- inspiration and additional graphics by thefreakar

function shadow_print(s, x, y)
  print(s, x + 1, y, 0)
  print(s, x, y + 1, 0)
  print(s, x + 1, y + 1, 0)
  print(s, x, y, 7)
end

g = {
	grav = 0.2,
  water = -0.3,
  waterfric = .8,
  jumpvel = 2.4,
  runvel = .5,
  runfriction = .8,
  maxvel = 1.5,
  termvel = 3.6,
  drownframes = 155,
  arrowfreq = 60,
  arrowspeed = 3,
  windfreq = 4,
  windspeed = 2,
  windpower = .21,
  wind_c = 7,
  dooropen = false,
  doorclosed = false,
  reset = false,
  fading = false,
  fade_frame = 0,
  fade_lev = 1,
  fireworks_lev = 3,
  prev_lev = 1,
  fade_dir = 0,
  reset_enabled = false,
  resetting = false,
  reset_value = 0,
  reset_released = true,
  muffle_frame = 0,
}

active_player = nil
actors = {}
sprites = {}
players = {}
particles = {}
bg_particles = {}
water_particles = {}
arrows = {}
firetiles = {}
firetiles_by_position = {}
windtiles = {}
fadetiles = {}
fadetiles_by_position = {}
arrowtiles = {}
levels = {}
level = {}

curlevel = 0

corners_erased = false

lives = 0
lives_saved = 0
deaths = 0
resets = 0
final_time_m = 0
final_time_s = 0
start_time = time()

dirs = {
  {x = 0, y = -1},
  {x = 1, y = 0},
  {x = 0, y = 1},
  {x = -1, y = 0},
}
tile_to_dir = {
  [43] = 1,
  [28] = 2,
  [59] = 3,
  [27] = 4
}

fades = {}

--- player ---

function new_player()

  lives -= 1

  local player = {
  	x = level.px,
  	y = level.py,
    oldx = 0,
  	dx = 0,
  	dy = 0,
    sprite = 1,
    runsprite = 0,
    faceleft = false,
    running = false,
  	grounded = false,
    falling = false,
    inwater = false,
    inwind = false,
    onfire = false,
    onsprite = false,
    playeron = false,
    dead = false,
    burnt = false,
    shot = false,
    fell = false,
    respawned = false,
    spawned = true,
    frame = 0,
    fireframe = 0,
    drownframe = 0,
    swimframe = 1,
    blinkframe = 0,
  }

  active_player = player

  add(actors, player)
  add(sprites, player)
  add(players, player)

  function player:update()

    self:start_end_check()

    if self.dead then
      if self.burnt then
        self.sprite = 21
      else
        self.sprite = 20
      end
    else
      self.sprite = 1
    end

    if self.grounded and not self.shot then
      self.dx *= g.runfriction
    end

    if not self.spawned then
      self:handle_input()
    end

    if self.running then
      self.frame += 1
      if self.frame%3 == 0 then
        self.runsprite += 1
        self.runsprite = self.runsprite%4
      end
      self.sprite = self.runsprite + 1
    else
      if self.grounded and not self.inwater and not self.onsprite and abs(self.dx) > 0.2 then
        new_grass_particle(self.x - self.dx*2 + 4, self.y + 8, -self.dx*.5, -abs(self.dx) - rnd(1))
      end
    end

    if self.inwater and not self.shot then
      self.dy += g.water
      self.dy *= g.waterfric
      self.dx *= g.waterfric
      self.drownframe += 1
    elseif self.shot then
      -- no change to velocities
    else
      self.dy += g.grav
    end

    if self.dy < 0 then
      self.grounded = false
    end

  	self.y += self.dy

    if self.y > 120 then
      self.y = 120
      if self.dead then
        self.x = -16
      else
        self.fell = true
        self:die()
        sfx(7)
      end      
    end

    if self.dy > g.termvel then
      self.falling = true
    else
      self.falling = false
    end

    if self.drownframe >= g.drownframes and not self.dead then
      self:die()
    end

    if self.drownframe >= g.drownframes and self.drownframe < g.drownframes + 10 and not self.dead then
      new_bubble_particle(self.x, self.y)
    end

    self:ground_collision()

    self:fire_water_wind_collision()

  	self:ceiling_collision()

    self.x += self.dx

  	self:wall_collision(self.dx)

    if not self.grounded and not self.dead then
      if self.falling then
        self.sprite = 6
      else
        if self.dy > 2 then
          self.sprite = 5
        else
          self.sprite = 91
        end
      end
    end

    if self.inwater and not self.dead then
      self.sprite = 4 + self.swimframe
      if self.drownframe > 60 then
        self.sprite = 7 + self.swimframe
        if self.drownframe < 70 then
          new_bubble_particle(self.x, self.y)
        end
      end
      if self.drownframe > 120 then
        self.sprite = 9 + self.swimframe
        if self.drownframe < 130 then
          new_bubble_particle(self.x, self.y)
        end
      end
    end

    if self.shot then
      if rnd() > .9 then
        new_particle(self.x + 4, self.y + 6, {2, 8, 8, 8}, 100, 0, 0)
      end

      if not self.dead then 
        self.sprite = 16
      end

      if self.dead and self.respawned then
        self.sprite = 19
      end   
    end

    if self.dead and not self.respawned then
      self.frame += 1

      if self.shot then
        if self.frame > 1 then
          self.sprite = 17
        end
        if self.frame > 4 then
          self.sprite = 18
        end
        if self.frame > 7 then
          self.sprite = 19
        end
      end

      if self.frame >= 10 then
        self.respawned = true
        if lives == 0 then
          g.reset = true
        else
          new_player()
          if self.fell then
            del(actors, self)
            del(sprites, self)
          end
        end
      end
    end

    if self.x >= 119 and not self.dead then
      if lives > 0 then
        lives_saved += lives
        sfx(13)
      end
      g.reset_enabled = true
      next_level()
    end
  end

  function player:start_end_check()
    if curlevel == 1 then
      if self.x > 54 and not g.dooropen then
        sfx(5)

        mset(3, 3, 90)
        mset(3, 4, 90)
        mset(3, 5, 90)

        mset(4, 3, 88)
        mset(4, 4, 110)
        mset(4, 5, 126)

        mset(5, 3, 88)
        mset(5, 4, 111)
        mset(5, 5, 127)

        mset(6, 3, 44)
        mset(6, 4, 60)
        mset(6, 5, 60)

        mset(7, 3, 103)
        mset(7, 4, 119)
        mset(7, 5, 119)

        g.dooropen = true
      end
    end

    if curlevel == 32 then
      if self.x > 60 and not g.doorclosed then
        sfx(6)

        mset(115, 51, 87)
        mset(115, 52, 87)
        mset(115, 53, 87)

        mset(116, 51, 105)
        mset(116, 52, 121)
        mset(116, 53, 94)

        mset(117, 51, 105)
        mset(117, 52, 122)
        mset(117, 53, 95)

        mset(118, 51, 102)
        mset(118, 52, 118)
        mset(118, 53, 118)

        mset(119, 51, 63)
        mset(119, 52, 106)
        mset(119, 53, 106)

        g.doorclosed = true
        g.reset_enabled = false
        final_time_m, final_time_s = get_time()
        lives_saved += 1

        music(36)
      end
    end
  end

  function player:handle_input()

    local moving = false

    self.running = false
    self.oldx = self.x

    if not self.dead and not self.shot then
      if btn(0) then
        moving = true

        if not self.inwater then
          self.running = true
        end
  		  self.dx -= g.runvel
        if self.grounded or self.inwater then
          self.dx = max(self.dx, -g.maxvel)
        end
        self.faceleft = true

        if self.grounded and not self.onsprite and not self.inwater and self.dx > .2 then
          new_grass_particle(self.x + self.dx*2 + 4, self.y + 8, self.dx)
        end
      end

      if btn(1) then
        moving = true

        if not self.inwater then
          self.running = true
        end
        self.dx += g.runvel
        if self.grounded or self.inwater then 
          self.dx = min(self.dx, g.maxvel)
        end
        self.faceleft = false

        if self.grounded and not self.onsprite and not self.inwater and self.dx < -.2 then
          new_grass_particle(self.x + self.dx*2 + 4, self.y + 8, self.dx)
        end
      end

      if btn(5) then

        local t1 = level:get_tile(self.x, self.y - 1)
        local t2 = level:get_tile(self.x + 7, self.y - 1)

  	    if not fget(t1, 0) and not fget(t2, 0) then
          if self.grounded and not self.inwater then
            self.grounded = false
            self.dy = -g.jumpvel
            sfx(0)
          end
        end
      end

      if btn(2) and self.inwater then
        moving = true
        self.dy -= g.runvel*.80
      end

      if btn(3) and self.inwater then
        moving = true
        self.dy += g.runvel
      end
    end

    if moving then
      local swimspeed = 4

      if self.drownframe > 60 then
        swimspeed = 3
      end
      if self.drownframe > 120 then
        swimspeed = 2
      end

      self.frame += 1
      if self.frame%swimspeed == 0 then
        self.swimframe = 1 - self.swimframe
      end
    end

    if self.inwind and not self.shot then
      local t1 = level:get_tile(self.x + 4, self.y + 3)
      dir = tile_to_dir[t1]
      if dir then
        local wx = dirs[dir].x
        local wy = dirs[dir].y

        local xmod = 2.5

        if self.dead then
          xmod = .25
        end
      
        self.dx += wx*g.windpower*xmod
        self.dy += wy*g.windpower
        if wy < 0 then
          self.dx *= .9
          self.dy *= .98
        end
        if wy > 0 then
          self.dy *= .96
        end
      end

      self.dx = max(self.dx, -g.maxvel*1.5)
      self.dx = min(self.dx, g.maxvel*1.5)

    else

      self.dx = max(self.dx, -g.maxvel)
      self.dx = min(self.dx, g.maxvel)

    end

  end

  function player:ground_collision()
    local t1 = level:get_tile(self.x, self.y + 8)
    local t2 = level:get_tile(self.x + 7, self.y + 8)
    local sprite
    local olddy = self.dy

  	if self.dy >= 0 then
  		if fget(t1, 0) or fget(t2, 0) then
  			self.y = flr((self.y)/8)*8
  			self.dy = 0

        if self.falling then
          self:die()
        end

        if not self.grounded then
          self.grounded = true
          self.spawned = false
          if olddy > 1 then
            if self.falling then
              sfx(2)
              for i = 0, 20 do
                new_particle(self.x + 4, self.y + 10, {2, 8, 8, 8}, 50, rnd(2) - 1, -rnd(1) - 2)
              end
            else
              sfx(1)
              for i = 0, 6 do
                new_grass_particle(self.x + 4, self.y + 8)
              end
            end
          end
        end
      else
        self.onsprite = false

        for sprite in all(sprites) do
          if self ~= sprite then
            if self.x > sprite.x - 8 and self.x < sprite.x + 8 then
              if self.y < sprite.y then
                if self.y > sprite.y - 8 then
                  self.y = sprite.y - 8
                  self.dy = 0
                  self.onsprite = true
                  if sprite.onfire then
                    self.onfire = true
                  end
                  sprite.playeron = true
                end
              end
            end
          end
        end

        if self.onsprite then
          if not self.grounded then
            self.grounded = true
            if olddy > 1 then
              sfx(2)
              for i = 0, 6 do
                new_particle(self.x + 4, self.y + 12, {2, 8, 8, 8}, 50)
              end
            end
          end
        else
          self.grounded = false
        end
  		end
  	end
  end

  function player:fade_collision()

    local t1 = level:get_tile(self.x, self.y + 8)
    local t2 = level:get_tile(self.x + 7, self.y + 8)

    local tx, ty, fadetile

    if t1 >= 32 and t1 <= 36 then
      tx = flr((self.x)/8)
      ty = flr((self.y + 8)/8)
      fadetile = fadetiles_by_position[ty*16 + tx]
      fadetile.playeron = true
    end

    if t2 >= 32 and t2 <= 36 then
      tx = flr((self.x + 7)/8)
      ty = flr((self.y + 8)/8)
      fadetile = fadetiles_by_position[ty*16 + tx]
      fadetile.playeron = true
    end
  end

  function player:fire_water_wind_collision()
    local t1 = level:get_tile(self.x + 4, self.y + 3)

    self.inwind = false

    if fget(t1, 1) then
      if not self.inwater then
        self.inwater = true
        if self.onfire then
          sfx(12)
          for i = 0, 20 do
            new_steam_particle(self.x + 4, self.y + 4)
          end
        end
        self.drownframe = 0
        if self.dy > 1 then
          if not self.onfire then 
            sfx(3)
          end
          for i = 0, 50 do
            new_water_particle(self.x + 4, self.y + 4)
          end
        end
        self.onfire = false
      end
    elseif fget(t1, 5) then
      self.inwind = true
    else
      if self.inwater then
        self.inwater = false
        self.drownframe = 0
        if self.dy < -1 then
          sfx(4)
          for i = 0, 15 do
            new_water_particle(self.x + 4, self.y + 7)
          end
        end
      end
    end

    if fget(t1, 2) then
      if not self.onfire then
        self.onfire = true
        self.fireframe = 0
      end
    end

    if self.onfire then
      self.fireframe += 1
      local p = 3

      if self.fireframe > 180 then
        p = 2
      end
      if self.fireframe > 220 then
        p = 1
      end

      for i = 0, p do
        new_fire_particle(self.x + rnd(7), self.y + rnd(7))
      end
      if not self.burnt and self.fireframe > 150 then
        self.burnt = true
        self:die()
      end
      if self.fireframe > 260 then
        self.onfire = false
      end
    end
  end

  function player:ceiling_collision()
    local t1 = level:get_tile(self.x, self.y)
    local t2 = level:get_tile(self.x + 7, self.y)

  	if self.dy <= 0 then
  		if fget(t1, 0) or fget(t2, 0) then
  			self.y = flr((self.y + 8)/8)*8
  			self.dy = 0
      else

        for sprite in all(sprites) do
          if self ~= sprite then
            if self.x > sprite.x - 8 and self.x < sprite.x + 8 then
              if self.y > sprite.y then
                if self.y < sprite.y + 8 then
                  self.y = sprite.y + 8
                  self.dy = 0
                  onsprite = true
                end
              end
            end
          end
        end
  		end
  	end
  end

  function player:wall_collision(dir)
    local xoffset = 0
  	if dir > 0 then xoffset = 7 end

  	local t1 = level:get_tile(self.x + xoffset, self.y)
    local t2 = level:get_tile(self.x + xoffset, self.y + 7)

  	if fget(t1, 0) or fget(t2, 0) then
  		self.x = self.oldx
      self.x = flr((self.x + 4)/8)*8
      self.dx = 0

      if self.shot and not self.dead then
        self:die()
      end
  	end

    for sprite in all(sprites) do
      if self ~= sprite then
        if self.y > sprite.y - 8 and self.y < sprite.y + 8 then
          if self.x < sprite.x then
            if self.x > sprite.x - 8 then
              self.x = sprite.x - 8
              self.dx = 0

              if self.shot and not self.dead then
                self:die()
              end
            end
          elseif self.x > sprite.x then
            if self.x < sprite.x + 8 then
              self.x = sprite.x + 8
              self.dx = 0

              if self.shot and not self.dead then
                self:die()
              end
            end
          end
        end
      end
    end
  end

  function player:draw()

     if self.fireframe > 120 and self.fireframe <= 150 then
      pal(4, 2)
      pal(9, 4)
      pal(15, 14)
    end
  
    spr(self.sprite, self.x, self.y, 1, 1, self.faceleft)

    if not self.grounded and not self.falling and not self.dead and not self.inwater and not self.shot then
      pset(self.x - 1, self.y + 4, 0)
      pset(self.x + 8, self.y + 4, 0)
      if self.faceleft then
        line(self.x + 6, self.y + 8, self.x + 7, self.y + 8, 0)
        line(self.x - 1, self.y + 6, self.x - 1, self.y + 7, 0) 
      else
        line(self.x, self.y + 8, self.x + 1, self.y + 8, 0) 
        line(self.x + 8, self.y + 6, self.x + 8, self.y + 7, 0)
      end
    end

    if not self.dead and not self.falling then
      self.blinkframe += 1
      if self.blinkframe > 20 then
        if rnd() > .98 then
          self.blinkframe = 0
          local xoffset = 1
          if self.faceleft then
            xoffset = 0
          end
          pset(self.x + 2 + xoffset, self.y + 2, 14)
          pset(self.x + 4 + xoffset, self.y + 2, 14)
        end
      end
    end

    if self.fireframe > 120 and self.fireframe <= 150 then
      pal(4, 4)
      pal(9, 9)
      pal(15, 15)
    end

  end

  function player:draw_shadow()
    if self.grounded and not self.shot and not self.dead and not self.inwater and g.dooropen then 
      line(flr(self.x) + 1.5, self.y + 8, flr(self.x) + 6.5, self.y + 8, 0)
    end

    if self.dead and not self.shot then
      if self.faceleft then
        line(self.x + 8, self.y + 1, self.x + 8, self.y + 7, 0)
      else
        line(self.x - 1, self.y + 1, self.x - 1, self.y + 7, 0)
      end
    end

    if self.shot and self.dead then
      line(self.x + 1, self.y + 8, self.x + 6, self.y + 8, 0)
    end
  end

  function player:die()
    deaths += 1
    self.frame = 0
    self.dead = true
  end

  function player:shoot(d)
    self.grounded = false
    self.running = false
    self.inwater = false
    self.shot = true
    self.y = flr((self.y + 2)/8)*8
    self.dx = g.arrowspeed*d
    self.dy = 0
    if d > 0 then
      self.faceleft = true
    else
      self.faceleft = false
    end

    for i = 1, 20 do
      new_particle(self.x + 3 - d*5, self.y + 6, {2, 8, 8, 8}, 50, rnd(2)-1, rnd(3) - 2)
    end

  end
end

--- particle ---

function new_grass_particle(x, y, dx, dy) 
  if g.dooropen and not g.doorclosed then
    new_particle(x, y, {3, 4, 11}, 50, dx, dy)
  end
end

function new_water_particle(x, y)
  new_particle(x, y, {1, 7, 12, 13}, 20)
end

function new_fire_particle(x, y)
  new_particle(x, y, {10, 9, 8, 13}, 14, rnd(1) - .5, 0, -.1)
end

function new_particle(x, y, colors, life, dx, dy, grav, bg, water)
  if life then
    life = life/2 + rnd(life/2)
  else
    life = 7 + rnd(7)
  end

  local particle = {
    x = x,
    y = y,
    c = colors[flr(rnd(#colors))+1],
    totalframe = life,
    dx = dx or rnd(2) - 1,
    dy = dy or -rnd(1) - 1,
    grav = grav or g.grav,
    bg = bg or false,
    frame = 0,
    water = water or false,
  }

  if bg then 
    add(bg_particles, particle)
  else
    add(particles, particle)
  end

  function particle:update()
    self.dy += self.grav
    self.x += self.dx
    self.y += self.dy
    self.frame += 1
    if self.frame >= self.totalframe then
      self:die()
    end

    if not self.bg then
      local t = level:get_tile(self.x, self.y)
      if fget(t, 0) then
        self:die()
      end
      if fget(t, 1) and self.dy > 0 and not self.water then 
        self:die()
      end
    end
  end

  function particle:draw()
    pset(self.x, self.y, self.c)
  end

  function particle:die()
    del(particles, self)
    del(bg_particles, self)
  end
end

--- fireworks ---

function new_fireworks(x, y)

  local r = rnd()
  local colors

  if r < .33 then 
    colors = {10, 9, 8}
  elseif r < .67 then
    colors = {11, 3}
  else
    colors = {12, 13, 1}
  end

  for i = 0, 300 do
    local a = rnd()
    local v = rnd()
    local vx = sin(a)*v
    local vy = cos(a)*v - 1
    new_particle(x, y, colors, 50, vx, vy, 0.05, true)
  end

  sfx(11, -1, rnd(3))
end

--- bubble particle ---

function new_bubble_particle(x, y)
  local xoffset = 1
  if active_player.faceleft then
    xoffset = 0
  end
  local colors = {7, 12, 13}

  sfx(10, 3)

  local particle = {
    x = x + 3 + xoffset,
    y = y + 4,
    c = colors[flr(rnd(#colors))+1],
    dy = -rnd(.2),
    grav = -.1,
  }

  function particle:update()
    self.dy += self.grav
    self.x += rnd(1.5)-.75
    self.y += self.dy
    
    local t = level:get_tile(self.x, self.y)
  	if not fget(t, 1) then
      self:die()
    end
  end

  function particle:draw()
    pset(self.x, self.y, self.c)
  end

  function particle:die()
    del(water_particles, self)
  end

  add(water_particles, particle)
end

--- steam particle ---

function new_steam_particle(x, y)

  local colors = {6, 7}

  local particle = {
    x = x + rnd(6),
    y = y,
    c = colors[flr(rnd(#colors))+1],
    dy = rnd(1) - 1,
    grav = -.02,
  }

  function particle:update()
    self.dy += self.grav
    self.x += rnd(1.5)-.75
    self.y += self.dy
    
    local t = level:get_tile(self.x, self.y)
  	if fget(t, 0) then
      self:die()
    end
  end

  function particle:draw()
    pset(self.x, self.y, self.c)
  end

  function particle:die()
    del(particles, self)
  end

  add(particles, particle)
end

--- animtile ---

function new_animtile(x, y, speed, tiles)
  local animtile = {
    x = x,
    y = y,
    speed = speed,
    tiles = tiles,
    frame = 0,
    tile = (x*2)%#tiles,
    dead = false,
  }

  add(actors, animtile)

  function animtile:update()
    self.frame += 1

    if self.frame%self.speed == 0 then
      self.tile += 1
      self.tile = self.tile%#self.tiles
    end
  end

  function animtile:draw()
    if self.dead then
      mset(self.x, self.y, 64)
    else
      mset(self.x, self.y, self.tiles[self.tile + 1])
    end
  end

  function animtile:die()
    del(actors, self)
  end

  return animtile
end

--- firetile ---

function new_firetile(x, y)
  local firetile = new_animtile(x, y, 2, {74, 75, 76, 77, 78, 79})
  
  add(firetiles, firetile)
  firetiles_by_position[firetile.y*16*8 + firetile.x] = firetile

  function firetile:extinguish()
    self.dead = true
  end

  function firetile:die()
    mset(self.x, self.y, self.tiles[1])
    del(actors, self)
    del(firetiles, self)
  end
end

--- arrowtile ---

function new_arrowtile(mapx, mapy, scrx, scry, faceleft)
  local arrowtile = {
    mapx = mapx,
    mapy = mapy,
    scrx = scrx,
    scry = scry,
    faceleft = faceleft,
    frame = 0,
  }

  add(actors, arrowtile)
  add(arrowtiles, arrowtile)

  function arrowtile:update()
    self.frame += 1
    if self.frame >= g.arrowfreq then
      self.frame = 0
      local dx = g.arrowspeed
      if self.faceleft then
        dx = -dx
      end
      new_arrow(self.scrx, self.scry, dx, self.faceleft)
    end
  end

  function arrowtile:draw()

  end

  function arrowtile:die()
    del(actors, self)
    del(arrowtiles, self)
  end

end

--- arrow ---

function new_arrow(x, y, dx, faceleft)
  local arrow = {
    x = x,
    y = y,
    dx = dx,
    faceleft = faceleft,
  }

  add(actors, arrow)
  add(arrows, arrow)
  sfx(8, 3)

  function arrow:update()
    self.x += self.dx

    local xoffset = 1
  	if self.dx > 0 then xoffset = 6 end

  	local t = level:get_tile(self.x + xoffset, self.y)

  	if fget(t, 0) then
      self:shatter()
    end

    for sprite in all(sprites) do
      if self.y + 6 > sprite.y and self.y + 6 < sprite.y + 8 then
        if self.dx < 0 then
          if self.x + 1 > sprite.x and self.x + 1 < sprite.x + 8 then
            if sprite == active_player then
              self:die()
              active_player:shoot(-1)
            else
              self:shatter(true)
            end
          end
        else
          if self.x + 6 > sprite.x and self.x + 6 < sprite.x + 8 then
            if sprite == active_player then
              self:die()
              active_player:shoot(1)
            else
              self:shatter(true)
            end
          end
        end
      end
    end

    if self.x < -8 or self.x > 128 then
      self:die()
    end
  end

  function arrow:draw()
    spr(29, self.x, self.y, 1, 1, self.faceleft)
  end

  function arrow:shatter(blood)
    if blood then
      local offset = 1
      if self.dx > 0 then
        offset = -1
      end
      for i = 1, 10 do
        new_particle(self.x + 3 - offset*5, self.y + 6, {2, 8, 8, 8}, 50, rnd(2)*offset, rnd(3) - 2)
      end
    else
      local t = level:get_tile(self.x - self.dx*4, self.y)
      local grav = g.grav
      local water = false
      if fget(t, 1) then 
        grav = -.02
        water = true
      end
      for i = 1, 6 do
        local yv = rnd(2) - 1
        if fget(t, 1) then 
          yv = rnd(.5) - .25
        end
        new_particle(self.x + i, self.y + 5, {6, 7, 7, 7}, 20, -rnd()*self.dx*.2, yv, grav, false, water)
      end
    end

    sfx(9, 3)
    self:die()
  end

  function arrow:die()
    del(actors, self)
    del(arrows, self)
  end
end

--- windtile ---

function new_windtile(mapx, mapy, scrx, scry, minx, miny, dir)
  local windtile = {
    mapx = mapx,
    mapy = mapy,
    scrx = scrx,
    scry = scry,
    minx = minx,
    miny = miny,
    dir = dir,
    tiles = {43, 28, 59, 27},
    frame = 0,
    dead = false,
  }

  add(actors, windtile)
  add(windtiles, windtile)

  function windtile:update()
    if not self.dead then
      self:set_tiles(true)
      self:set_tiles()
      self:make_particles()
    end
  end
  
  function windtile:set_tiles(clear)
    local dx = dirs[self.dir].x
    local dy = dirs[self.dir].y

    local mx = self.mapx
    local my = self.mapy
    local sx = self.scrx + 4
    local sy = self.scry + 4 - dy*3
    local t, f
    local continue = true

    while(continue) do
      t = mget(mx, my)
      if clear then
        mset(mx, my, 64)
      else
        if t == 64 or (t >= 74 and t <= 79) then
          
          if t >= 74 and t <= 79 then
            firetile = firetiles_by_position[my*16*8 + mx]
            if firetile then
              firetile:extinguish()
            end
          end

          mset(mx, my, self.tiles[self.dir])
        end
      end

      mx += dx
      my += dy
      sx += dx*8
      sy += dy*8
      if mx < self.minx or my < self.miny or mx > self.minx + 16 or my > self.miny + 15 then
        continue = false
        break
      end
      
      t = mget(mx, my)

      if clear then
        if not fget(t, 5) and t != 64 then
          continue = false
          break
        end
      else
        if t != 64 and not (t >= 74 and t <= 79) then
         continue = false
         break
        end
      end

      if not clear then
        for sprite in all(sprites) do
          if sx - dx*8 > sprite.x and sx - dx*8 < sprite.x + 8 then
            if sy - dy*8 > sprite.y and sy - dy*8 < sprite.y + 8 then  
              continue = false
            end
          end
        end
      end
    end
  end

  function windtile:die()
    self.dead = true
    del(actors, self)
    del(windtiles, self)
    self:set_tiles(true)
    mset(self.mapx, self.mapy, self.tiles[self.dir])
  end

  function windtile:make_particles()
    self.frame += 1
    if self.frame >= g.windfreq then
      self.frame = 0
      local dx = dirs[self.dir].x
      local dy = dirs[self.dir].y
      local x = self.scrx + rnd(8) - dx * 4
      local y = self.scry + rnd(8) - dy * 4
      x = min(max(x, self.scrx), self.scrx + 8)
      y = min(max(y, self.scry), self.scry + 8)
      new_windparticle(x, y, dx, dy)
    end
  end

  function windtile:draw()

  end
end

--- wind particle ---

function new_windparticle(x, y, dx, dy)
  local windparticle = {
    x = x,
    y = y,
    ox = x, 
    oy = y,
    dx = dx,
    dy = dy,
  }

  add(actors, windparticle)

  function windparticle:update()
    self.x += self.dx*g.windspeed
    self.y += self.dy*g.windspeed

  	local t = level:get_tile(self.x, self.y)

    for sprite in all(sprites) do
      if self.x > sprite.x and self.x < sprite.x + 8 then
        if self.y > sprite.y and self.y < sprite.y + 8 then
          self:die()
        end
      end
    end

  	if fget(t, 0) or t == 58 then
      self:die()
    end

    if self.x < -8 or self.x > 128 or self.y < -8 or self.y > 128 then
      self:die()
    end
  end

  function windparticle:draw()
    mod = sin((self.x + self.y)*.03)
    line(self.x + mod, self.y + mod, self.ox, self.oy, g.wind_c)
    self.ox = self.x + mod
    self.oy = self.y + mod
  end

  function windparticle:die()
    del(actors, self)
  end
end

--- fadetile ---

function new_fadetile(mapx, mapy)
  local fadetile = {
    mapx = mapx,
    mapy = mapy,
    sprite = 32,
    health = 5,
    playeron = false,
  }

  add(actors, fadetile)
  add(fadetiles, fadetile)
  fadetiles_by_position[fadetile.mapy*16 + fadetile.mapx] = fadetile

  function fadetile:update()
    if self.playeron then
      self.health -= 1

      if self.health <= 0 then
        self.health = 5
        self.sprite += 1
        if self.sprite > 36 then
          self.sprite = 64
        end
      end
    end
  end

  function fadetile:draw()
    mset(self.mapx + level.x, self.mapy + level.y, self.sprite)
  end

  function fadetile:die()
    mset(self.mapx + level.x, self.mapy + level.y, 32)
    del(actors, self)
    del(fadetiles, self)
    del(fadetiles_by_position, self)
  end
end

--- level ---

function new_level(name, x, y, lives, px, py)
  local level = {
    name = name,
    x = x,
    y = y,
    lives = lives,
    px = px,
    py = py,
  }

  add(levels, level)

  function level:init()

    actors = {}
    sprites = {}
    players = {}
    firetiles = {}
    firetiles_by_position = {}
    windtiles = {}
    fadetiles = {}
    fadetiles_by_position = {}
    new_player()

    local x, y

    for y = 0, 14 do
      for x = 0, 15 do
        local t = mget(self.x + x, self.y + y)
        if t >= 66 and t <= 73 then
          new_animtile(self.x + x, self.y + y, 2, {66, 67, 68, 69, 70, 71, 72, 73})
        end
        if fget(t, 2) then
          new_firetile(self.x + x, self.y + y)
        end
        if fget(t, 3) then
          local faceleft = false
          if t == 12 or t == 30 or t == 46 then
            faceleft = true
          end
          new_arrowtile(self.x + x, self.y + y, x*8, y*8, faceleft)
        end
        if fget(t, 5) then
          local dir = tile_to_dir[t]
          new_windtile(self.x + x, self.y + y, x*8, y*8, self.x, self.y, dir)
        end
        if t == 32 then
          new_fadetile(x, y)
        end
      end
    end
  end

  function level:draw(occlude)
    if occlude then
      map(self.x, self.y, 0, 0, 16, 15, 0x80)
    else
      map(self.x, self.y, 0, 0, 16, 15)
    end
  end

  function level:get_tile(x, y)
    return mget(x/8 + self.x, y/8 + self.y)
  end
end

function reset_sky()
  clouds = {}

  for i = 0, 3 do
    local s = flr(rnd(10))
    c = {
      frame = 0,
      size = s + 5,
      speed = 40-s*2,
      x = rnd(128),
      y = rnd(96),
    }

    add(clouds, c)
  end
end

function update_sky()
  for cloud in all(clouds) do
    cloud.frame += 1

    if cloud.frame%cloud.speed == 0 then
      cloud.x -= 1

      if cloud.x + cloud.size*2 < -20 then
        cloud.x = 128 + cloud.size 
        cloud.y = rnd(96)
      end
    end
  end
end

function draw_sky()
  local celestial_y = 16
  local sky_c = 12
  local cloud_c = 6
  local cy = {18, 20, 24, 32, 40, 48, 56, 64, 72, 80, 88, 96}

  if curlevel >= 30 then
    sky_c = 0
    -- draw stars
  elseif curlevel >= 28 then
    g.wind_c = 13
    sky_c = 1
    cloud_c = 5
    celestial_y = 128
  elseif curlevel >= 18 then
    celestial_y = cy[curlevel - 17]
  end

  if curlevel < 30 then
    rectfill(0, 0, 128, 128, sky_c)
  end

  if curlevel < 30 then
    circfill(24, celestial_y, 10, 10)
    for cloud in all(clouds) do
      circfill(cloud.x, cloud.y, cloud.size, cloud_c)
      circfill(cloud.x + cloud.size*.7, cloud.y - cloud.size*.7, cloud.size*.5, cloud_c)
      circfill(cloud.x + cloud.size*1.2, cloud.y + cloud.size*.2, cloud.size*.8, cloud_c)
    end
  else
    circfill(24, celestial_y, 12, 6)
    circfill(24, celestial_y, 11, 7)
  end
end

--- main routines ---

function _init()
  music(0, 0, 2)

  create_fade_palette()
  erase_wind_arrows()

  new_level("harold's bad day", 0, 0, 1, 36, 40)
  new_level("don't fall", 16, 0, 1, 16, -8)
  new_level("come up for air", 32, 0, 1, 16, -8)
  new_level("i'm on fire", 48, 0, 1, 16, -8)
  new_level("arrows", 64, 0, 1, 16, -8)
  new_level("fall on me", 80, 0, 3, 8, -8)
  new_level("let me drown", 96, 0, 3, 8, -8)
  new_level("jump into the fire", 112, 0, 3, 16, -8)
  new_level("arrow through me", 0, 16, 6, 16, -8)
  new_level("firestarter", 16, 16, 6, 16, -8)
  new_level("psychotic precision", 32, 16, 2, 8, -8)
  new_level("bridge over trouble", 48, 16, 8, 8, -8)
  new_level("stairway to heaven", 64, 16, 7, 8, -8)
  new_level("something in the air", 80, 16, 1, 8,  -8)
  new_level("shield wall", 96, 16, 10, 8, -8)
  new_level("against the wind", 112, 16, 2, 8, -8)
  new_level("sky pilot", 0, 32, 2, 16, -8)
  new_level("windshield", 16, 32, 4, 8, -8)
  new_level("blowin' in the wind", 32, 32, 2, 8, -8)
  new_level("close the window", 48, 32, 4, 8, -8)
  new_level("wind beneath my wings", 64, 32, 4, 8, -8)
  new_level("the tempest", 80, 32, 1, 8, -8)
  new_level("jump", 96, 32, 1, 8, 0)
  new_level("don't stop believing", 112, 32, 1, 8, -8)
  new_level("right on time", 0, 48, 2, 16, -8)
  new_level("leap of faith", 16, 48, 2, 8, -8)
  new_level("put out the fire", 32, 48, 1, 8, -8)
  new_level("earth, wind and fire", 48, 48, 1, 8, -8)
  new_level("ride on time", 64, 48, 2, 16, -8)
  new_level("so close", 80, 48, 1, 8, -8)
  new_level("running the gauntlet", 96, 48, 8, 8, -8)
  new_level("home sweet home", 112, 48, 1, 8, -8)

  next_level()
end

function create_fade_palette()
  local c, l, x, y
  for c = 0, 15 do
    fades[c + 1] = {}
    for l = 0, 3 do
      x = 88 + l + flr(c/8)*4
      y = c%8
      fades[c + 1][l + 1] = sget(x, y)
    end
  end
end

function erase_wind_arrows()
  clear_tile(88, 8, 23)
  clear_tile(96, 8, 7)
  clear_tile(80, 24, 7)
end

function clear_tile(xp, yp, h)
  for y = yp, yp + h do
    for x = xp, xp + 7 do
      sset(x, y, 12)
    end
  end
end

function next_level()
  curlevel += 1
  init_level()

  if curlevel == 32 then
    g.reset_enabled = false
  end

  if curlevel >= 28 and not corners_erased then
    sset(0, 40, 1)
    sset(23, 40, 0)
    sset(23, 63, 0)
    sset(112, 12, 0)
    sset(114, 13, 0)
    sset(112, 14, 0)
    sset(125, 13, 0)
    sset(127, 14, 0)

    corners_erased = true
  end
end

function reset_level()
  if g.fading == false then
    g.fading = true
    g.fade_dir = 1
  end
end

function init_level()
  for windtile in all(windtiles) do
    windtile:die()
  end

  for firetile in all(firetiles) do
    firetile:die()
  end

  for fadetile in all(fadetiles) do
    fadetile:die()
  end

  for arrowtile in all(arrowtiles) do
    arrowtile:die()
  end

  for particle in all(particles) do
    particle:die()
  end

  for particle in all(bg_particles) do
    particle:die()
  end

  for particle in all(water_particles) do
    particle:die()
  end

  for arrow in all(arrows) do
    arrow:die()
  end

  reset_sky()

  g.reset = false
  level = levels[curlevel]
  lives = level.lives
  level:init()
end

function draw_hud()
  rectfill(0, 120, 128, 128, 0)
  spr(1, 0, 120, 1, 1)
  pset(9, 124, 7)
  pset(9, 126, 7)
  pset(10, 125, 7)
  pset(11, 124, 7)
  pset(11, 126, 7)

  print(lives, 13, 122, 7)

  local str = level.name

  if g.reset then
    str = "hold \142 to reset"
    g.reset_enabled = true
  end

  if g.reset_value > 0 then
    rectfill(45, 121, 45 + g.reset_value, 128, 8)
    str = "resetting"
  end

  print(str, 64 - #str*2, 122, 7)

  if g.dooropen and not g.doorclosed then
    local m, s = get_time()
    draw_time(m, s, 118, 122)
  end
end

function draw_time(m, s, x, y, left_align)
  if left_align then
    x += #m*4
  end
  shadow_print(m, x - #m*4, y, 7)
  shadow_print(s, x + 2, y, 7)
  shadow_print(":", x - 1, y)
end

function get_time()
  local s = flr(time() - start_time)
  local m = flr(s/60) .. ""
  s = s%60
  if s < 10 then
    s = "0" .. s
  end
  return m, s
end

function _update()

  if btn(4) then
    
    if g.reset_enabled and g.reset_released then
      g.resetting = true
      g.reset_released = false
    end
  else
    g.resetting = false
    g.reset_released = true
  end

  if g.resetting then
    g.reset_value += 1
  else
    g.reset_value -= 5
  end

  g.reset_value = max(g.reset_value, 0)

  if g.reset_value >= 37 then
    g.reset = false
    g.resetting = false
    g.reset_value = 0
    resets += 1
    reset_level()
  end

  if not g.dooropen then
    start_time = time()
  end

  do_fade()

  update_sky()

  for fadetile in all(fadetiles) do
    fadetile.playeron = false
  end

  for player in all(players) do
    player:fade_collision()
  end

  for actor in all(actors) do
    actor:update()
  end

  for particle in all(particles) do
    particle:update()
  end

  for particle in all (water_particles) do
    particle:update()
  end

  for particle in all(bg_particles) do
    particle:update()
  end

  if active_player.inwater and not active_player.dead then
    poke(0x5f41, 15)
    poke(0x5f43, 15)
    g.muffle_frame = 0
  else
    g.muffle_frame += 1
    if g.muffle_frame > 5 then
      poke(0x5f41, 0)
      poke(0x5f43, 0)
      g.muffle_frame = 0
    end
  end

  if g.doorclosed then
    if rnd() > .95 and #bg_particles < 850 then
      new_fireworks(rnd(128), rnd(32))
      g.fireworks_lev = 0
      g.fade_frame = 9
    end

    if g.fade_frame%9 == 0 then
      g.fireworks_lev += 1
      if g.fireworks_lev > 3 then
        g.fireworks_lev = 3
      end
    end
  end
end

function _draw()
  cls()

  pal()

  draw_fade()

  for particle in all(bg_particles) do
    particle:draw()
  end

  if curlevel >= 31 then
    g.prev_lev = 0
    if not g.fading then
      g.fade_lev = 1
    end
    draw_fade()
    draw_sky()
    if not g.fading then
      g.fade_lev = g.fireworks_lev
    end
    draw_fade()
  elseif curlevel >= 30 then
    g.prev_lev = 0
    if not g.fading then
      g.fade_lev = 2
    end
    draw_fade()
    draw_sky()
  else
    draw_sky()
  end

  if curlevel == 1 or curlevel == 32 then
    rectfill(32, 30, 88, 48, 1)
  end

  palt(0, false)
  palt(12, true)

  level:draw()

  for actor in all(actors) do
    actor:draw()
  end

  for player in all(players) do
    player:draw_shadow()
  end

  for particle in all(particles) do
    particle:draw()
  end

  level:draw(true)

  for particle in all(water_particles) do
    particle:draw()
  end

  pal()
  palt(0, false)
  palt(12, true)

  draw_hud()
  
  if g.doorclosed then

    local text_x = 32
    local text_y = 56

    shadow_print("well done!", text_x, text_y)
    shadow_print("harolds killed: " .. deaths, text_x, text_y + 16)
    shadow_print("harolds saved: " .. lives_saved, text_x, text_y + 24)
    shadow_print("resets: " .. resets, text_x, text_y + 32)
    shadow_print("final time:", text_x, text_y + 40)
    draw_time(final_time_m, final_time_s, text_x + 48, text_y + 40, true)
  end

end

function do_fade()
  g.fade_frame += 1

  if g.fade_frame%2 == 0 then
    g.fade_lev += g.fade_dir
  end

  if g.fade_lev != g.prev_lev then
    if g.fade_lev > 8 then
      g.fade_lev = 8
      g.fade_dir = -1
      init_level()
    end

    if g.fade_lev <= 1 then
      g.fade_dir = 0
      g.fade_lev = 1
      g.fading = false
    end
  end
end

function draw_fade()
  local fl = g.fade_lev

  if curlevel == 31 then
    if fl <= 3 then
      fl = 3
    end
  end
  
  if fl != g.prev_lev then
    local c

    for c = 0, 15 do
      if fl >= 5 then
        pal(c, 0)
      elseif fl <= 1 then
        pal()
        palt(0, false)
      else
        pal(c, fades[c + 1][fl])
      end
    end
  end
end

__gfx__
00000000c100001cc100001cc100001cc100001cc100001c101f101cc100001cc100001cc100001cc100001c0000842019442444444244201111111111111111
00000000109fff91109fff91109fff91109fff91109fff91440b0401104eee41104eee411067d7611067d7611000942119424444444424201499949941994941
0070070014f0f0f014f0f0f014f0f0f014f0f0f004f0f0f014339f9012e0e0e002e0e0e01160d0600160d0602110a94219412444444214201944424442442420
00077000c09fff91c09fff91c09fff91c09fff91109fff41c1bbff00c04eee41104eee41c02ddd21102ddd213510b35119444444444444201944424442442420
000770001b3bb30c133bbb311b3bb30cc0bbb30cfb3bb3bfc1bb0ff0c0bbb30cfb3bb3f0c0bbb30cfb3bb3f04210cd5110024444444420011944444442444420
007007001f3bb31c19344b911f3bb31cc1f3b31c103bb302c1330f00c1f3b31c103bb302c1f3b31c103bb3025110d51011104444444401111944442444444420
00000000c041120cc004101cc02140cccc0421cc04411122120f4f91cc0421cc04411122cc0421cc044111226d51e42110024444444420011944442444444420
00000000c0441220cc0221ccc022440ccc0440cc141ccc100220101ccc0440cc141ccc10cc0440cc141ccc1076d5f94219444444444444201944444444444420
c100001cc100001ccc1001cccc1001cccc11c11ccc11c11cc12212122212220c194444444444444444444420cccccccccccccccccccccccc1944244444424420
1090f091109fff91c100001cc100001c006b020100d50101cc121212221220cc194244444442444444424420ccc7cccccccc7ccccccccccc1942444444442420
14fffff014f4f4f010d6666110d666614433d6d0d5222d20ccc1222222220ccc142244444422444444224420cc77cccccccc77cccccccccc1941244444421420
c09f0091c09fff91126d6d60126d6d6041bb6d6051d5d2d0ccc1222222220ccc122222222222222222222220c777777cc777777ccccccccc1944444444444420
1b3b830c1b3b830103d666d103d666d111bb6660115dddd0ccc1212221220ccc011111101111111011111110c777777cc777777ccccccccc2002444444442001
7df8d7777b38d7777b3887776b38877722bb6d60d555d2d0ccc1212221220ccc199494201994942019949420cc77cccccccc77cc67777776ccd0444444440dcc
104482200f41820160418201064182012033d6d1d0222d21ccc1222222220ccc142222201422222014222220ccc7cccccccc7ccccccccccc5112444444442112
cc041120c041120cc041120cc048120c0111101c0111101cccc1222222220ccc000100000001000000010000cccccccccccccccccccccccc1944444444444420
cddddddccddddddccddddddccddddddccdcdcdcc22212212ccc1221221220ccccc1520cccc5420cc11111110ccccccccffffffffffffffffd11111111111111d
df7777f5d6ffff65d666666ddd6d6d6ddcddddcd22222212ccc1221221220ccccc1421cccc1421cc19949420ccc77cccffffffffffffffff13bbbbbbbbbbbb30
d7ffff65df6666d5d66d6dd5d6ddddddcddcdcdc22222222ccc1222222220ccccc5421cccc1521cc14222220cc7777ccffffffffffffffff1bbb33bb332b33b0
d7ffff65df666665d6d6d6ddddddddddddcdcdcd22222222ccc1222222220ccccc5420cccc5421cc00000000c777777cfff1111111110fff1b32223332222230
d7ffff65df6666d5d66d6dd5d6ddddddcddcdcdc22222222ccc1222222220ccccc1410cccc1420cc22222210ccc77cccff619999444206ff2002444424442001
d7ffff65df666665d6d6d6ddddddddddddcdcdcd22222222ccc1222212220ccccc1421cccc1520cc24244220ccc77cccff61422222220d6fccd0444444440dcc
df6666d5d6d6d6d5d6ddddd5d6ddddddccdcdcdc12212222ccc1222212210ccccc5420cccc1521cc44244420ccc77cccff60010001000d6f5112444444442112
c555555cc555555ccd5d5d5ccddddddccdcdcdcc12212222ccc1221212210ccccc1421cccc1420cc44444420ccccccccff6d142014205d6f1944444444444420
115111114444444411111111444444444441144421221212ccc1222222220ccc1111111011111110ccccccccccccccccfff614201420d6fff61420ccffffffff
bb3babbb4442444449941999444424441116611421221212ccc1212222120ccc1994942019949420c7cccc7cccc77cccfff614201420d6fff61420ccffffffff
33bb3b3b44424444244424444244244466dddd6122221222ccc1212222120ccc1422222014222220c77cc77cccc77cccfff614201420d6fff61420ccffffffff
324222234442444424442444424424426dd6d65622221222ccc1212222120ccc0000000000000000cc7777ccccc77cccfff614201420d6fff61420cc11111111
24444242444444444444244444444442d566666622222222ccc1212222220ccc1222222222222222cc7777ccc777777cfff614201420d6fff61420cc49949444
4444444444442442444444444424444266d6d65612222222ccc1222212220ccc1924424224244242c77cc77ccc7777ccfff614201420d6fff61420cc22222222
444444442222122244444444442442446222dd6212212222cc122222122120cc1924424444244244c7cccc7cccc77cccfff614201420d6fff61420cc00000000
444444440001000044444444444442442444222412212212c12222121221220c1944424444444244ccccccccccccccccfff614201420d6fff61420cc12022022
cccccccc11111111ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccdccc8ccccccc8ccccccd8ccc8ccc8ccc8cccdccc8c
cccccccc11111111dddcccccd55dccccd5115dcccccd55dcccccdddcccccccccddccccdd55dcccd5cc8ddcccc8a8ccccc898cc8ccc8cc8a8ccccc898ccc88ccc
cccccccc1111111111115dd51111115511111111551111115dd51155555111111111111111111111c898cc8c89a8cc8ccc8cc898cccccd98ccc88c8ccccccccc
cccccccc11111111111111111111111111111111111111111111111111111111111111111111111189a8888d89888898c8cc88a8ccd8888cc88998ccc898cccc
cccccccc1111111111111111111111111111111111111111111111111111111111111111111111118faf9988d8999fa888889ff8889aa9988898888c89a98888
cccccccc1111111111111111111111111111111111111111111111111111111111111111111111118f7aaa9889aaaaf889faaa9889faaa9889af99988f7a9f98
cccccccc11111111111111111111111111111111111111111111111111111111111111111111111189a77a8dd9a77a98c8a77a98d8a77a9889aaaa9889aaa98d
cccccccc111111111111111111111111111111111111111111111111111111111111111111111111c899f98cc89fa98cc89aa98cc8faf98cc89af98cc89f998c
d1111111511111151111111d33444444444444423344444444444442cc1420d6fffffffff61420cccc1420d6c100001cccccccccccccccccf6140cccccc140d6
13abbbbbbbbbbbb3bbbbbb30b444444444442443b444444444444443cc1420d6fffffffff61420cccc1420d61090f091ccccccccccccccccf6140cccccc140d6
1abb33bb332b33bb332b33b034444444444424433444444444444443cc1420d6fffffffff61420cccc1420d604fffff0cccccccccccccccc61120cccccc12106
1b322233322222333222223044244444444424444444442444444424cc1420d6fffffffff61420cccc1420d6109f0041cccccccccccccccc619444444444440d
14444242242442422424442044244444444444444424442444244424cc1420d6fffffffff61420cccc1420d6fb3bb3bf5111511151115115600000000000000d
19444244442442444424442044244444444444444424422444244224cc1420d6fffffffff61420cccc1420d6103bb302d7aad7a9d7a9da4066dddddddddddddd
19444244444442444444442044444444444444442222221222222212cc1420d6fffffffff61420cccc1420d6044111225a995a995a995940ff66666666666666
19444444444444444444442044444444444444440000010000000100cc1420d6fffffffff61420cccc1420d6141ccc102455245524552450ffffffffffffffff
194444444444444444444420444444444444444411111111ffffffffffffffffffffffffffffffff241441441944d949d944d9494944d940ff1111111111106f
1944444444444444444444204444444444444444bbbbbbbbffffffffffffffffffffffffffffffff241441441a5999599959995999599950f6199949444440d6
1944444444444444444444204444444444444444332b33bbffffffffffffffffffffffffffffffff49999999195a995a995a9954995a9950f6120000000020d6
194444444444444444444420444444444444442432222233fff111111111111111110fffffffffff44444444152455245524552555245520f6140cccccc140d6
194444444444444444444420444444444444442444244424ff61999949949444444206ffffffffff12022022194944994449449944494440f6140cccccc140d6
194444444444444444444420442444444424444444244224ff6142222222222222220d6fffffffff241441441a9959a9599959a959995940f6140cccccc140d6
194444444444444444444420442444444424444222222212ff6001000000000001000d6fffffffff241441441a995a995a995a995a995a40f6140cccccc140d6
194444444444444444444420044444444444442000000000ff6d1420cccccccc14205d6fffffffff24144144145524552455245524552450f6140cccccc140d6
194444444444444444444420444444451111111194444444fff61420cccccccc1420d6ffff1111111111106f194449494944d94949444940f6140cccccc140d6
194444444444444444444420444424444199949944424444fff61420cccccccc1420d6fff6199949444440d61a5a995a9959a95a995a9950f6140cccccc140d6
194444444444444444444420444424444244424444424444fff61420cccccccc1420d6fff6120000000020d61a5a995a995a995a995a995061120cccccc12106
194442444442444444424420444424444244424444424444fff61420cccccccc1420d6fff6140cccccc140d6152455245524552455245520619444444444440d
194442444442444244424420444444444244444444444444fff61420cccccccc1420d6fff6140cccccc140d6000100000000000000010000600000000000000d
144422444422444244224420444444444444442444444444fff61420cccccccc1420d6fff6140cccccc140d6cc121025ddddddddd51210cc66dddddddddddddd
152221222221222222212210444444444444442444444444fff61420cccccccc1420d6fff6140cccccc140d6cc14205ddddddddddd1420ccff66666666666666
100000000010000000000001444444444444444444444444fff61420cccccccc1420d6fff6140cccccc140d6cc1420d666666666661420ccffffffffffffffff
26040407171717171717171717173616260404040404046253537204040406160404040616161616161616161616161626040404040404b3b3b3040404040406
260404040404040404040404040404042604040404b3040404b3040404b306162604040404040404040404820404040626040404040404040404040404040406
2604040404040404040404040404061626040404040404625253720404040633c104040717171717171717171717361626040404040404040404040404040406
26040404040404040404040404040404260404040404040404040404040406332704040404040404040404920404040626040404040404040404040404040406
2604040404040404040404040404061626040404040404625252720404040616c104040404040404040404040404061626040404040525040404040404040406
2604040404040404040404040404040426040404040404040404040404040616c104040404040404040404820404040626040404040404040404040404040406
2604040404040404040404040404061626040404040404625352730404040616c104040404040404040404040404061645150315153526040404052504040406
0315250404a3a3a3a3a3a3a3a304051545250404040404040404040404040717c104040404040404040404920404040626040404040404040404040404040406
4503250404040404040404040404061645031525040404635253e025040406331515031515150315032504040404061616161616161626040404072704040406
16162604040404040404040404040633332604040404040404040404040404042504052504040404040404820404040645150325020202020202020525040406
161626040404040404040404040406161616162604040523232357260404061616461717131713131727040404053516171713171713270404040404040404e1
46132704040404040404040404040616162604040404040404040404040404044515352604040404040404832504040617131727a4a4a4a4a4a4a40727040406
16162604040404040404040404040616461717270404071713171327040407131626040404040404040404040407171726040404040404040404040404040406
2604040404040404040404040404061616260404040404040404040404040404461317a104040404040404072704040726040404040404040404046171040406
16162604040404040404040404040616260404040404040404040404040404b1162604040404040404040404040404b126040404040404040404040404051503
2604040404040404040404040404061616260404040404040404040404040515260404820404040404040404040404b1f1040404040404040404046373040406
16162604040404052504040404040616260404040404040404040404040404b1162604040404040404040404040404b126040404040404040404040404061616
2604040404040404040404040404061633260404040404040404040404040616260404920404040404040404040404b1f104040402020202020202e023031535
161626040404040626040404040406162604e0470325040405150315150315031626040404040515031515150303151526040404052504040404051503251616
26040404a40404040404040404040616162604040404040404040404040406332604048204040404040404040404051515250404a4a4a4a4a4a4a40713171717
16162604040404062604040404040616260406161626040407131713131717131626040404040717171317131313171726040404072704040404061616261616
263434052504040404040404040406331626040404040404040404040404061626040483250404040404040515033516132704040404040404040404040404e1
16162604040404062604040404040717260406163326040404615353527104041727040404040404040404040404040426040404040404040404061616261616
261414062604040404040404040406161626040404040404040404040404061627040407270404040404040717131717f1040404040404040404040404040407
1616260404040406260404040404040426040633162604040462525352720404c104040404040404040404040404040426040404040404040404071317271317
2614140626040404040404040404061633260404040404040404040404040616c104040404040404040404040404040403250202020202020202020404040404
1616260404040406260404040404040426040643162604040463525253730404c104040404040404040404040404040426040404040404040404040404040404
2614140626040404040404040404063316260404040404040404040404040633c10404040404040404040404040404041626a4a4a4a4a4a4a4a4a4a4a4040404
161626b2b2b2053526b2b2b205151515374357161645031515234723234715031515150315031515151515031503151526b20503152504040405150315031515
3747475726b2b2b2b2b2b2b2b20525163326b2b2b204b2b2b204b2b2b204061625b2051503250404040404040515031516264723234747232347232347474747
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
162604040404062604040404040616332604040404040404040404040404040426040404b3b3b30404040404b3b3b30626535272b3b3b3b3b3b3b3b3b3b3b306
162604040404062604040404040633162604046253535353535353535353530626535353061616332604040404040404260404c5c5c5c5c5c5c5c5d504040404
33260404040407270404040404071717260404040404040404040404040404042604040404040404040404040404040626525373040404040404040404040406
332604040404072704040404040717172604046353535353535353535353530626535353063343462704040404040404260404b6c6c6c6c6c6c6c6d604040404
16451525a4a4a40404040404020404b14515250404040404040404040404050345032504040404051515032502020206374723f0020205250202020525020206
433703250404a40404040404020404b1450315232347472323472347f05353063747f053064346270404040404040404260404b7c7c7c7c7c7c7c7d704040404
46171727040515032504040404e02323431626040404040404040404040406161643452504040407131717270404040616331626040407270404040626040406
46171327040515032504040404e023234617171313171713364333462753530643462753064627040404040404040404260404a58585c276d29696e304040405
2652537304064316260404040206331616332604040404040404040404040633163316260404040404615371040404061616432604046171a4a4a40626040406
265253730406431626040404040616332653525353525353073646275352530616265353062604040404040405151515452504a5e6f6c377d397a7e304040406
2652e02315353316260404040406161616162604040404040404040404040616150315030315250404635273a4a4a40616161626040463730202020626040406
2652e023153533162604040404064316265252535352535253072753525353063326535306f104040404040407171317332604a5e7f7c377d3e5f5e304040406
2652071717173633260404040206331616162604040404040404040404040616161633431633260404e023f00202020616161626a4a4e0f00404040626040406
2652071717173633260404040206161626535253e023f0535252535253e02357162653e057260404040404040404e11603151503151503031503150325040406
26535252535306162604040404061616331626040404040404040404040406431317171317132704040713270404040616163326020207270404040626040406
2653525253530643260404040406331626535352073637f053535253e05716431626530705031525040404040404064346171317911713171713139127040406
37234723f05206162604040402061633163326040404040404040404040406162653525252710404046152710404a40616161626040461710404a40626040406
37234723f0520633260404040406164337f052525306433747234723573316161626535306164326040404040404e11626527104820404615371049204040406
4617171727530616260404040406161616162604040404040404040404040616265352535273040404625373a4a405351616162604046373a4a4e05726040406
461317132753061626040404020633164326525353063316161643161616161616265353064316f1040404040404063326537204920404635373048204040406
2653535252530633260404040206431616162604040404040404040404040633265253e023f004040463e0230315063316331626a4a4e0232347574326040406
2653535252530643260404040407171716265353e057164316163316164316334337f05306163326040404040515031526527205930315472347039315150315
2652e047234757462704040402063316161626040404040402040404040406162653530713271515152357461713071716161626020207171317131727040407
2652e04723475746270404040204040433265252071713171313171317171317164627530713172704040404e116161626527207911313171713179113171717
26520717171717270404040402071717331626040404040402040404040406162653525253071313131317275252535216431626040404615352537104040404
26520717131713270404040402040404332652535352535253535253525352533326535353537104040404050643331626537204920461535371048204046153
265352525253527304040404040404041616260404040404020404040204061637f0535352525253535352535352525316161626a4a404635253527304a4a404
265352525253527304040404020404041637f05253535352535352535253535316d0535353537304040404060616164326537304820463535373049204046353
372347472323472315150315150303151633260404040404b2040404b20406161637472347232347472323472347472316163337472347234723232347472323
37234747232347232504040402040405334337232347472323474723472323471637472323472315031503060633161637472315931547234747159303152347
__label__
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccbaaaaaabccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccbaaaaaaaaaaaaaabccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaaaacccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaaaaaaccccccccc
ccccccccccccccccccccccccccccccccccccccc6666cccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaaaaaaaacccccccc
ccccccccccccccccccccccccccccccccccccc66666666ccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaaaaaaaaaaccccccc
cccccccccccccccccccccccccccccccccccc6666666666ccccccccccccccccccccccccccccccccccccccccccccccccccbaaaaaaaaaaaaaaaaaaaaaaaabcccccc
ccccccccccccccccccccccccccccccccccc666666666666cccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaaaaaaaaaaaacccccc
ccccccccccccccccccccccccccccc666666666666666666ccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaaaaaaaaaaaaaaccccc
ccccccccccccccccccccccccccc66666666666666666666ccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaaaaaaaaaaaaaaccccc
cccccccccccccccccccccccccc666666666666666666666ccccccccccccccccccccccccccccccccccccccccccc500004aaaaaaaaaaaaaaaaaaaaaaaaaaabcccc
cccccccccccccccccccccc0000000000000000000000000000000000005cc500000000000000000000000000000000000000004aaaaaaaaaaaaaaaaaaaaacccc
cccccccccccccccccccccc0000000000000000000000000000000000000550000000000000000000000000000000aa0000000000aaaaaaaaaaaaaaaaaaaacccc
cccccccccccccccccccccc009aaa90009aaa900009a900009aaaaaa940000009aaaa90009aaa900009aaaaaa9400990009aaa9000aaaaaaaaaaaaaaaaaaacccc
cccccccccccccccccccccc500999000009990000099900000999999999000099999999000999000000999999999009009999999004aaaaaaaaaaaaaaaaaacccc
ccccccccccccccccccccccc00999000009990000499940000999000499400499400499400999000000999000499400049940099400aaaaaaaaaaaaaaaaaacccc
ccccccccccccccccccccccc00999000009990000999990000999000099900999000099900999000000999000099900099900499900aaaaaaaaaaaaaaaaaacccc
ccccccccccccccccccccccc00999000009990000999990000999000099900999000099900999000000999000099900099900000000aaaaaaaaaaaaaaaaabcccc
ccccccccccccccccccccccc00999000009990004994994000999000099900999000099900999000000999000099900099940000000aaaaaaaaaaaaaaaaaccccc
ccccccccccccccccccccccc00999aaaaa999000999099900099900009990099900009990099900000099900009990004999aaa4000aaaaaaaaaaaaaaaaaccccc
ccccccccccccccccccccccc00999999999990009940499000999000499400999000099900999000000999000099900004999999400aaaaaaaaaaaaaaaacccccc
ccccccccccccc666666cccc00999000009990049900099400999aaa999000999000099900999000000999000099900000000499900aaaaaaaaaaaaaaabcccccc
cccccccccc666666666666c00999000009990099900099900999999990000999000099900999000000999000099900000000099900aaaaaaaaaaaaaaaccccccc
ccccccccc66666666666666009990000099900999aaa99900999004999000999000099900999000000999000099900aaa900099900aaaaaaaaaaaaaacccccccc
66666ccc666666666666666009990000099904999999999409990004994004994004994009990000409990004994004990004994004aaaaaaaaaaaaccccccccc
66666666666d00000000000009990000099909990000099909990000999000999aa999000999aaaa90999aaa999000099aaa99900004a400000004cccccccccc
666666666d0000000000000049994000499999994000499999994000999400099999900049999999999999999400000049999400000040000000000dcccccccc
6666666d00001555555552100000000000000000000000000000000000000000000000000000000000000000000000000000000115000000555210000dcccccc
66666660005ddddddddddddd55100000001111110000000111111111111100000000111111111111100000000001111110011155ddd0000115dddd1000cccccc
666666600eeeeeeeeeeeeed5555100000eeeeed1100000eeeeeeeeeed5111000000011eeeeeeeeeed510000000111eeeee0112eeee800001115eeeee20cccccc
66666660088888888888888825211000188888111000008888888888888111000000118888888888882000000011188888101188888000111118888800cccccc
66666660088888888888888882111000288888211000008888888888888811100000118888888888888200000011288888201128888200111128888200cccccc
6666666008888888888888888211110088888881110000888888888888882110000011888888888888882000011188888880111888880111118888800dcccccc
6666666008888880000288888811110188888881110000888888000288888111000011888888000288888000011188888881011288882011128888200ccccccc
666666600888888000008888881111028888888211000088888800008888821100001188888800008888820001128888888201118888801118888800dccccccc
666666600888888000008888881111088888888811100088888800008888881100001188888800008888880011188888888801112888820128888200cccccccc
66666660088888800001888888111018888288881110008888880000888888110000118888880000888888001118888288881011188888018888800dcccccccc
66666660088888811112888882110028888188882110008888880000888888110000118888880000888888001128888188882011128888228888200ccccccccc
666666600888888eeee888888111108888808888811100888888000088888811000011888888000088888801118888808888800111888888888800dccccccccc
66666cc008888888888888882111118888202888811100888888000088888811000011888888000088888801118888202888810111288888888200cccccccccc
ccccccc00888888888888888811102888810188882110088888800008888881100001188888800008888880112888810188882001118888888800dcccccccccc
ccccccc00888888888888888821108888800088888111088888800008888881100001188888800008888880118888800088888001112888888200ccccccccccc
ccccccc0088888800002888888111888821112888811108888880000888888110000118888880000888888011888821112888810011188888800d6666ccccccc
ccccccc008888880000088888810288888eee888882110888888000088888811000011888888000088888801288888eee88888200111888888006666666ccccc
ccccccc008888880000088888810888888888888888110888888000088888811000011888888000088888801888888888888888001118888880066666666cccc
ccccccc0088888800001888888118888888888888881108888880001888882110000118888880001888882018888888888888881011188888800666666666ccc
ccccccc00888888111128888820288888888888888821088888811128888811000001188888811128888800288888888888888820111888888006666666666cc
ccccccc00888888eeee888888008888880000088888810888888eee888882110000011888888eee88888200888888000008888880111888888006666666666cc
ccccccc008888888888888882018888820000028888810888888888888881100050011888888888888820018888820000028888810118888880066666666666c
ccccccc008888888888888820028888810000018888820888888888888811000cc0011888888888882000028888810000018888820118888880066666666666c
ccccccc00888888888888200008888880000000888888088888888888210001ccc5000000000000000000000000000000000000000000012880066666666666c
ccccccc000000000000000000000000000000000000000000000000000000dccc10000000000000000000000000000000000000000000000000066666666666c
ccccccc0000000000000000000000000000000000000000000000000001dcccc000000000000000000000000000000000000000000000000000066666666666c
cdddccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000000000000000006666666666c
ccccddddcccccccccccccccccccccccccccccccccccccccccccccccccccccc0000002444444444444444444444444444444444444444444200000066666666cc
cccccccdddddccccccccccccccccccccccccccccccccccccccccccccccccc00000244444444444444444444444444444444444444444444442000006666666cc
cccccccccccddddccccccccccccccccccccccccccccccccccccccccccccc50000444444444444444444444444444444444444444444444444440000566666ccc
cccccccccccccccc0015dccccccccccccccccccccccccccccccccccccccc0000444444444444444444444444444444444444444444444444444400006666cccc
cccccccccccccccc50000015dcccccccccccccccccccccccccccccccccc1000244444444999999999999999999999999999999999999999999994000166ccccc
ccccccccccccccccccd5100000015dccccccccccccccccccccccccccccc00004444444499999999999999999999999999999999999999999999990000ccccccc
ccccccccccccccccccccccd51000000015dccccccc6ccccccccccccccc500024444444999ffffffffffffffffffffffffffffffffffffffffffff40005cccccc
cccccccccccccccccccccccccd5100000000015dcc76cccccccccccccc10004444444499fffffffff40fffffffffffffffffffffff04fffffffff90001cccccc
cccccccccccccccccccccccccccccd51000000000d776ccccccccccccc00004444444499ffffffff404fffffffffffffffffffffff404fffffffff0000cccccc
dcccccccccccccccccccccccc8ccccccd510000056777fcccccccccccc00004444444499fffffff404fffffffffffffffffffffffff404ffffffff0000cccccc
222dcccccccccccccccccccc88cccccccccd510d77666776cccccccccc00004444444499ffffff404ff9444449fffffffff9444449ff404fffffff0000cccccc
22222dccccccccccccccccc888cccccccccccc7777777f67fccccccccc00004444444499ffffff04ff944444449fffffff944444449ff40fffffff0000cccccc
442222d222dccccccccccc88888cccccccccccccccc666ffffcccccccc00004444444499ffffffffff4000677449ffffff4000677449ffffffffff0000cccccc
4422222222222dcccccc8888988ccccccccccccccccccccccccccccccc00004444444499ffffffffff0000077749ffffff0000077749ffffffffff0000cccccc
42224444442222dd2dc88899988cccccccccccc8cccccccccccccccccc00004444444999ffffffffff0000077799ffffff0000077799ffffffffff0000cccccc
224444444442222222288999988cccccccccccc88ccccccccccccccccc00004444449999ffffffffff0000077799ffffff0000077799ffffffffff0000cccccc
44444444442222242288999f9888ccccccccccc88ccccccccccccccccc0000999999999fffffffffff6000677799ffffff6000677799ffffffffff0000cccccc
44444444222224444888999a9988cccccccccc888ccccccccccccccccc000099999999ffffffffffff7777777799ffffff7777777799ffffffffff0000cccccc
4444444222244444488999aa998882dcccccc88888cccccccccccccccc000099999999ffffffffffff7777777799ffffff7777777799ffffffffff0000cccccc
444444442244444448899faaf988822222dcc88888cccccccccccccccc100099999999fffffffffffff777777999fffffff777777999fffffffff90001cccccc
444444422444444448899faaf998822222228888988ccccccccccccccc500049999999ffffffffffffff9999999fffffffff9999999ffffffffff40005cccccc
444444444444444448899aaaa9988444222288889888ccccccccccccccc000099999999ffffffffffffff99999fffffffffff99999ffffffffff90000ccccccc
444444444444444448899aaaf9988444444888899888dcccccccccccccc100049999999ffffffffffffffffffffff940004ffffffffffffffff940001ccccccc
4444444444444444488999ff99988444488888999888822dcccccccccccc500099999999fffffffffffffffffff900004fffffffffffffffff990005cccccccc
44444444444444444888999999888444488889999888822222dcc5000000000009999999999ffffffffffffffff0000fffffffffffffffff999000000000005c
44444444444444444488888888884444888899ff9988822222220000000000000049999999999999999999999990049999999999999999999400000000000001
44444444444444444448888888844448888999fa9988882222200000000000000000499999999999999999999999999999999999999999940000000000000000
4444444444444444484444444444488888999aaaf998884422100000000000000000004499999999999999999999999999999999999944000000000000000000
444444444444444448844444444488888899aaaaf9988844220000049fffffbbbb33333333333333333333333333333333333333333111111113bbffffff9000
44444444444444448888444444488888899faaaaf998884224000049ffffffbbbbbb3333333333333333333333333333333333333333111113bbbbfffffff900
4444444444444444889884444488898889faaaaaf998842244000099ffffffbbbbbbbbbbbb33333bbbbbbbbbbbbbbbbbbbbbbbbbb3333333bbbbbbffffffff00
4444444444444448889888888888999889fffffff998842444000099ffffffbbbbbbbbbbbb3333bbbbbbbbbbbbbbbbbbbbbbbbbbbb33333bbbbbbbffffffff00
4444444444444448889998888899999888999ffff988844444000099ffffffbbbbbbbbbbb33333bbbbbbbbbbbbbbbbbbbbbbbbbbbb3333bbbbbbbbffffffff00
444444444444444888999999999999999999999998888444440000999fffffbbbbbbbbbbb33333bbbbbbbbbbbbbbbbbbbbbbbbbbbb3333bbbbbbbbfffffff900
4444444444444488899fff999ffffffffff9999888888844440000499999993333333333333333bbbbbbbbbbbbbbbbbbbbbbbbbbbb3333333333339999999400
4444444444444488899ffffffffaaaaaaaaff99988898844440000049999993333333333333333bbbbbbbbbbbbbbbbbbbbbbbbbbbb3333333333339999994000
4444444444444488899ffaaaaaaaaaaaa7aaff9998998844442000000000000000000011333333bbbbbbbbbbbbbbbbbbbbbbbbbbbb1100000000000000000000
44444444444444888999faaaaaa77777777aaff999998844444000000000000000000011333333bbbbbbbbbbbbbbbbbbbbbbbbbbbb1100000000000000000000
44444444444444888999faaa77a77777777aaaff99988844444400000000000000000011333333bbbbbbbbbbbbbbbbbbbbbbbbbbbb1100000000000000000001
44444444444444888899ffaa77777777777aaaff99988844444442000000000000000011333333bbbbbbbbbbbbbbbbbbbbbbbbbbb3110000000000000000005c
444444444444444888999faaa7777777777aaaff999888444444444444444444420000111333333bbbbbbbbbbbbbbbbbbbbbbbbbb11100000000005ccccccccc
444444444444444888899ffaa777777777aaaff9998884444444444444444444000000011333333bbbbbbbbbbbbbbbbbbbbbbbbb3111000000000000cccccccc
444444444444444488889ffaa77777777aaafff99988844444444444444444400000000111333333bbbbbbbbbbbbbbbbbbbbbbb311142000000000000ccccccc
4444444444444444488889ffaaaaaaaaaaafff99988844444444444444444420000000001111333333bbbbbbbbbbbbbbbbbbb311114442000000000005cccccc
44222224444444444488889ffaaaaaaaaffff9998888444444444444444444000012242222222211111111111111111111111111144421149999400000cccccc
4222224444444444448888899fffffffff9999988884444444444444444444000022442244442211111111111111111111111111224411499999940000cccccc
4224444444444444444888888999999999998888844444444444444444444400002244224444441111111111111111111111111122241144444999000022dccc
22244444444444444444488888888888888888884444444444444444444444000022442244444411111111111111111111111111222211444444990000222dd2
22444444444444444444448888888888888888444444444444444444444444000022442244444421111111111110000000000011222211444444990000222222
22444444244444444444444444444444444444444444444444444444444444000022442224444441111111111100000000000000122211444444990000442222
24444422244444444444444444444444444444444444444444444444444444000022444222222222111111111000000000000000012211444444990000442222
22442222444444444444444444444444444444444444444444444444444444000022444422222222211111100000000000000000001211444444990000422224
22112224444444444444444444444444444444444444444444444444444422000022444444000000000000000000244444442000000111444444990000422444
22112224444444444444444444444444444444444444444444444444442222000022444444000000000000000004444444444420000011444444990000422444
22112224444444444444444444444444444444444444444444444444422222000022444444000000000000000122222222222222000001244444940000224444
21112244444444444422444444444444444444444444444444444444222222000012244442000000000000012222222222222222200000124444400000224444
21112244444444444222444444444444444444444444444444444442222222100000000000000222222222222222222222222222220000000000000002444444
21112222444444222224444444444444444444444444444444444442222222200000000000001222222222222222222222222222222000000000000004444444
21112222224212222224444444444444444444444444444444444442222222220000000000002222222222222222222222222222222200000000000044444444
21112222221112222444444444444444444444444444444444444442222222222100000000122222222222222222222222222222222221000000002444444444
21112222221112244444444444444444422444444444444444444444222222222222222222222222222222222222222222222222222222222222244444444444
21112222221112244444444444444442224444444444444444444444222222222222222222222222222222222222222222222222222222222222244444444444
21112222221112224444444444442222444444444444444444444444422222222222222222222222222222222222222222222222222222222222244444444444
22112222221112222244444422222244444444444444444444444444442222222222222222222222222222222222222222222222222222222222444444444444
22112222221112222222442122224444444444444444444444444444444222222222222222222222222222222224444222222222222222222222444444444444
22112222221112222222211122244444444444444444444444444444444444222222222222222222222222244444444442222222222222222224444444444444
21112222221122222222211122444444444424444444444444444444444444444444444444444444444444444444444444444222222222222244444444444444
21111222221122222222211222244444444224444444444444444444444444444444444444444444444444444444444444444444222222224444444444444444
21111222221122222222211222222444222244444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444

__gff__
0000000000000000000000008989818100000000000000008181812020008989818181818100000080808120008189898181810001000000818100200080818000020202020202020202848484848484818181818181818100000000000080808181818181818100008080000000000081818181818180800080800000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
6240405c5c5c5c5c5c5c5c5d4040404035352535174040404040606240404040624040404040404040404040404040604040404040404040404040404040404040404040404040404040404040404050252740404060616162717171717171604040404040404040404040404040404040404040404040404040404060616161
6240406b6c6c6c6c6c6c6c6d404040400f25352527404040404060624040404062404040404040404040404040404060524040404040404040404040404040505240404040404050524040404040401e0f2740404060336162404040404040605240404040404040404040404040404052404040404040404040404060613361
6240407b7c7c7c7c7c7c7c7d4040404062352535374040404040606240404040545151303051515130515240404040606240404040404a4a4a404040404040606240404040405053624040404040406062374040406061616240404040404060624040404040404040405052404040406240404040404a404040404060616161
624040576969663f685858594040405073743232745152404040606240404040616161336161616161616240404040605451305130515151305151305240406051513051305153335451513052404060737452404060616162404050524040606240404040404040404060624040404054513030515151305152404060616161
54524057797a766a786e6f59404040606471317171311a404040606240404040647131505130527131717242424242606471317119713171317171197240406071713131717171317171317172404060616162404060616162424260624040605451524242424242424260624242505164713131717131717172404060615051
336240575e5f766a787e7f594040406062404040404028404040606240404040624040606133624141414141414141606240404029404040404040294040406062404040162535253525351740404060336162404060613362414160624040603361624141414141414160624141606162404040404016251740404060336061
3051513051513030513051305240406062404040404029404040606240404040624040606161624141414141414141606240404028404a4a4a404028404040606240404026253535253525274040406061616240407071636241416062404060616173743274320f414160624141603362404040404036352740404060616033
64713171197131717131311972404060624040404040284040505362404040406242427071317241410e323274327475624040503951305151305139513051531f404040363535253525253740405051616162404040406062414160624040606161647171717172414160624141606162404040400e0f252740505153616061
6225174028404016351740294040406062404040505139305153647240404040624141414141414141606471317119716240407031713131717171317171317162404050743274323274327451515361613362404040406062414160624040606161624141414141414160624141606162404040406062353740606164316061
6235274029404036353740284040406062404040703171713171724040404040624141414141414141606240404028406240404016253517404040404040404062404070197131717171713171317171616162404040406062414160624040606161624141414141414160624141606154305240406073743232756472407031
6225275039305174327430395151305162404040401635353517404040405051624141410e327432747562404040294062404040263525274040404040404040624040402940404040163535253525355130513052404060624141606240407061336241410e3232747475624141606164317240407071317171317240404040
6225277019313171713171193171717162404040403625352527404040505361624141417031717131636240405039513052404036253537404040404040503051524040284040404026353525253535616161616242427072414160624040406161624141707171717171724141606162404040404040162535174040404040
62352740294016353517402840401635624040405052352535274040505361616241414141414141417072424260616151305151743232745242424242505361611f40402940404040263525350e74326161613362414141414141606240404051526241414141414141414141416061624a4040404040263525274040405051
623537402840363535374029404036356240404060623535253740505361615062414141410e0f414141414141603361613361616161613362414141416033616162404028405052403635350e756161616161616241414141414160624040406162624141414141414141414141606154513030515240362535374040406061
7374325139517432747451393051327454513051517474327432515361615053737432743260627432747432743251306161616133616161737474747475616161545130395160625174327475616161613361617374323274327475545151516162737432747432327432747432756161616133615451743232743051515361
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6240404040404040404040404026356062404040404040404040404040404060353525606240404040404040404040604040404040404040404040404040404040404040404040404040404040404040624040404040406061616161616161616240404040406061616240404040404062404070717171717171717171716361
62404040404040404040404040362560624040404040505240404040404040600f25357072404040404040404040401e5240404040404040404040404040404052404040404040404040404040404040624040404040406061647131633361616240404040406033616240404040404062404040404040404040404040407071
624040502f404040404040400e0f356062405052404060624a404040404040606225251740404040404040404040406062404040404040404040404040404040624040404040404040404040404040405451305240404060616240401e616161624040404040606161624040405051306240404040404040404040404040401b
545130535430524040404040707235606240707240406054513051305240406062353537404040404040404040404060624040404040404040404040404040406240404040404040404040404040404061336162424242703172424260346133543052404040606133624040406061616240404040404040404040404040401b
6431711971317240404040401625256062401617404070317171313172404060327432745240405030515130524040605151524040404040404040404040404054305240404040404040404040404040616161730f4141414141414160616161616162434343606161624242420c336130515130513051524040405051305151
62404029404040404040404026352560624036374040401625351740404040606161613362404060647171636240406061611f404040404040404040405051516161624040404040404040404050303064713163624141414141414160613361613362414141606161624141410c616161647131713171724040407031713171
62404028404040404040404026250e3262400e0f4040403635253740404050536133616162404060624040606240406061336240404040404040404040603361613362404040404040404040406033611f404060737432740f41414160336161616162414141606161624141410c616133624040401635174040505362404040
624040294040404040404040363560616240606240405032743274524040603361616161624040606242426062404060616162424242424242424242426061616161624040404040404040404060613362424270317131717241414160616161333362414141703171724141410c613361624040403625374050536472404040
624040382f4040404040405051516061624060545130533361336154305153616161336162404060737432756240406033616241414141414141414141606133336162404040404a404040404060616162414141414141414141410e75643171336162414141414141414141410c336171724040400e32325130527240404040
62405053624a4a4a4a4a4a606161606162406033616471317171313171713171717171717240407071717171724040606133624141414141414141414160616161336242424250305130513051513051624141414141414141414160647240406161624141410e32320f4141410c61331c404040406033616133624040404050
62407063737432743274740f6161606162407031717235253535353535253535610d35253740403625353517404040606161624141414141414141414160336161616241414160336161616161616161624141410e7432743232747562404040616162414141707131724141410c61611c404040406061613361624040503053
624040703171713131713172717170716240401625352525352525352535253561737432323051320f25252740404070616162414141414141414141416061336161624141416061346133615051513062414141707131713131713172424250613362414141414141414141410c616151305240407031717131724040606161
62404040404016252535353525251740624040263525350e0f2535352525350e61616133616161610d2535274040404033616241414141414141414141606161616162414141606164313131603361610d4141414141414141414141414141606161624141414141414141414160336161336240404016352517404040603361
5452404040403635352535252535374062404036253525606235252535253560613361616161613362253537404040406161730f41414141414141410e75616133617374327475616235253560616133320f414141414141414141414141410c3361624141414141414141414160616161616240404036253537404040606133
6154515151323274747432743232745154513032743274757374327432327475616161616161616173327432524040506161337332743274743232747561336133616161336161336225253560616161617374743232743274323232747432606161737432323232327432747475613351305151513074747474522b2b603361
__sfx__
000100001637013370113701037010370113701337016370193601e350243402b3200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000b07006070030600204001020010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000e47015660194500c650016000745005600056500630007450176500d4401c4302c610206000430002300140000000000000000000000000000000000000000000000000000000000000000000000000
000100003f6103f6503f6703c6603965034650306402c64027630246301f6201b6201762013620136201462018620256303664028640126300b62007620056100461003610026100261001610016100161001610
0001000007620126401b66021670286702d67032670366703a6703d6703f6703f6603f6603f6503f6503f6403f6303f6303f6303d6203b6203962036620326202c610246101b6100b61002610006000000000000
000100000a670076500465006350093400d3401034013340173301c3200d310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000216701c6701a6601736015350103500d34009330073200000011350103500e3400c3400a3300732000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000028760277602576024750217501e7401c740197301773014720117200e7100a71007710047100171000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000008610116101c610246202d620356303e64000600016001b6001e6002260025600296002d60030600366003a6000000000000000000000000000000000000000000000000000000000000000000000000
000100003f630296203641023410384102b310383102d30031300310003100034000350003800039000364003c4003e4003f40000000000000000000000000000000000000000000000000000000000000000000
000200000b070070600606005060050500505005050080400b050110400e0300c0500b0300a030090500a0200e0201202018010150101301012010140501801018010200101d0101c0101b0501d0102101024010
000300001d6501b64014640116300b63009620056200361001010010100e61016610000100b65019610020101f610000100d6102563000000156100000014620236100000026610000001c610006001761000000
000200003f6103f6303f6503f6603f6603f6603f6603f6503f6503f6403f6303f6203f6203f6203f6203f6203f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f6103f610
010500003c5703c0503c0403c0303c0203c0203c0203c0103c0103c0103c0103c0153f000370053000030000245001f500305001c500245001f500305001c5001f00037000370003700037000370000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
150600001c47618436134261c4163c61518400134761c4361c426184163c6151c4001c47618436134261c4161c43618426134161c4061c426184163c6151c4061d47618436134261d4161c47618436134261c416
150600001d47618436134261d4163c61518406134761d4361d426184163c6151d4061c47618436134261c4161c43618426134161c4061c426184163c6151c4061d47618436134261d4161c47618436134261c416
15060000184761543611426184163961515406114761843618426154163c61518406184761543611426184161843615426114161840618426154163c615184061a47615436114261a41618476154361142618416
150600001c47617436134261c4163761517406134761c4361c426174163c6151c4061a47617436134261a4161a43617426134161a4061a426174163b6151a4063c615150063c6151a0063c6153c6153c6153c615
150600001c47617436134261c4163761517406134761c4361c426174163c6151c4061a47617436134261a4161a43617426134161a4061a426174163b6151a4061c47617436134261c4161a47617436134261a416
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600001877018771187711877113770137711377113771187701877118771187001f7711f7711f7701f7701f7721f7721f7721f7721f7721f7721f7721f7721d7701d7711d7711d7001c7701c7711c7711c700
010600001d7701d7701d7701d7701f7701f7701f7701f7701d7701d7701d7701d7001c7701c7701c7701c70018770187701877018700137701377013770137701577015770157701577013770137701377013770
010600001d7701d7701d7701d7701d7701d7701d7701d7001d7701d7701d7701d7701c7701c7701c7701c7701c7701c7701c7701c7701c7701c7701c7701c7701877018770187701877018770187701877018770
010600001a7701a7701a7701a7701a7701a7701a7701a7701a7721a7721a7721a7721a7721a7721a7721a7721a7621a7621a7521a7521a7421a7421a7321a7321a7221a7221a7121a7121a7001a7001a7001a700
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600001337300330003300033000330003300c4300c4303c65030630094301330309330093300933000000133730933009330093300c4300c43000000000003c65030630246201861013353000001343013430
0106000013373053300533005330053300533011430114303c650306300e430186000e3300e3300e33000000133730e3300e3300e330114301143000000000003c65030630246201861013353000031343013430
0106000013373073300733007330073300733013430134303c6503063024620186100733007330073300000013373073300733007330306302462011430114303c6503063024620186100e4300e4303063024620
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
450800001847018471184711847113470134711347113471184701847118471187001f4711f4711f4701f4701f4721f4721f4721f4721f4721f4721f4721f4721d4701d4711d4711d4001c4701c4711c4711c400
450800001d4701d4701d4701d4701f4701f4701f4701f4701d4701d4701d4701d4001c4701c4701c4701c40018470184701847018400134701347013470134701547015470154701547013470134701347013470
450900001d4701d4701d4701d4701d4701d4701d4701d4001d4701d4701d4701d4701c4701c4701c4701c4701c4701c4701c4701c4701c4701c4701c4701c4701a4701a4701a4701a4701a4701a4701a4701a470
450a00001847018470184701847018470184701847018470184721847218472184721847218472184721847218462184621845218452184421844218432184321842218422184121841218410184151840518405
150800000c3700c3710c3710c371073700737107371073010737007371073710c7000c3710c3710c3700c3700c3720c3720c3720c3720c3720c3720c3720c3720e3700e3710e3711d7001037010371103711c700
150800000e3700e3700e3700e370103701037010370103701137011370113701d3001037010370103701c3000c3700c3700c3700c300073700737007370073700937009370093700937007370073700737007370
15090000053700537005370053700537005370053701d300053700537005370053700737007370073700737007370073700737007370073700737007370073700937009370093700937009370093700937009370
150a00000c3700c3700c3700c3700c3700c3700c3700c3700c3720c3720c3720c3720c3720c3720c3720c3720c3620c3620c3520c3520c3420c3420c3320c3320c3220c3220c3120c3120c3100c3151a3001a300
__music__
01 145e6844
00 155f6844
00 16606944
00 18616a44
00 145e6844
00 155f6844
00 16606944
00 17616a44
00 545e2844
00 555f2844
00 56602944
00 57612a44
00 545e2844
00 555f2844
00 56602944
00 57612a44
00 145e2844
00 155f2844
00 16602944
00 18612a44
00 145e2844
00 155f2844
00 16602944
00 17612a44
00 145e6844
00 155f6844
00 16606944
00 17616a44
00 141e2844
00 151f2844
00 16202944
00 17212a44
00 141e2844
00 151f2844
00 16202944
02 17212a44
00 383c4344
00 393d4344
00 3a3e4344
00 3b3f4344

