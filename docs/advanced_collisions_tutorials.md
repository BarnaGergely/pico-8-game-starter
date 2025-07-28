# Advanced Collisions Tutorials

## Rectangle to Map Flag

A rectangle collides with map flags when any part of the rectangle overlaps with tiles on the map that have specific sprite flags set. This is useful for checking if a larger game object (like a player or enemy with width and height) intersects with solid walls, collectible items, or hazardous areas defined by map tiles.

Unlike basic map collision which only checks a single point, rectangle to map flag collision checks multiple points around the rectangle's edges to ensure accurate collision detection for objects larger than a single pixel.

```lua
function rect_map_collision( r, flag )
  local left = r.x\8
  local right = (r.x+r.w-1)\8
  local top = r.y\8
  local bottom = (r.y+r.h-1)\8
  
  for x=left,right do
    for y=top,bottom do
      if map_collision(x,y,flag) then
        return true
      end
    end
  end
  return false
end

function map_collision( tile_x, tile_y, flag )
  return fget( mget(tile_x,tile_y), flag )
end
```

### 1. How it Works?

#### Storing Rectangle Coordinates

First, we need an easy way to store the coordinates and dimensions of a rectangle that represents our game object. We can do that with a [table](../Guide/create_tables) that stores X, Y, width, and height variables. The rectangle table is what the above function expects.

It would be created like this:

```lua
--create object table for a rectangle
r = { x=20, y=30, w=8, h=8 }
```

Now we have a rectangle at coordinates `X` and `Y`, with a width of `w` and a height of `h`. To get the value of the player's `x`, we use `player.x`. ([See Table Shorthand](about:blank/Guide/Tables#shorthand))

```lua
--get value out of object table
print( r.x )  --prints 20
```

#### Converting Rectangle to Tile Coordinates

Since the map uses tile coordinates (each tile is 8x8 pixels), we need to convert the rectangle's pixel coordinates to tile coordinates. You can find more info in the [Map and Flags Collision guide](https://nerdyteachers.com/PICO-8/Collision/98). We need to find which tiles the rectangle spans across.

For the rectangle's bounds, we calculate:

```lua
--convert rectangle bounds to tile coordinates
left = r.x\8           --leftmost tile
right = (r.x+r.w-1)\8  --rightmost tile  
top = r.y\8            --topmost tile
bottom = (r.y+r.h-1)\8 --bottommost tile
```

The `-1` in the width and height calculations ensures we don't include an extra tile when the rectangle's edge aligns exactly with a tile boundary. The `\` operator performs division and rounding down in one step.

#### Checking Multiple Tiles

Once we have the tile bounds, we need to check every tile that the rectangle overlaps with. We use nested loops to iterate through all tiles from left to right and top to bottom:

```lua
--check all tiles the rectangle overlaps
for x=left,right do
  for y=top,bottom do
    if fget(mget(x,y), flag) then
      --found a tile with the target flag
      return true
    end
  end
end
```

If any tile within the rectangle's bounds has the specified flag, we immediately return `true` indicating a collision was found.

#### Understanding an Expanded Version

Now that we understand the coordinate conversion and tile checking process, we can put it all together into an expanded function:

```lua
--expanded example
function rect_map_collision( r, flag )
  --convert rectangle bounds to tile coordinates
  local left = r.x\8
  local right = (r.x+r.w-1)\8
  local top = r.y\8
  local bottom = (r.y+r.h-1)\8
  
  --check all tiles the rectangle overlaps
  for x=left,right do
    for y=top,bottom do
      local sprite = mget(x, y)
      local has_flag = fget(sprite, flag)
      if has_flag then
        return true
      end
    end
  end
  
  --no collision found
  return false
end
```

This function has [parameters](../Guide/ARGUMENTS) `(r,flag)` and it is expecting `r` to be an object with X, Y, W, and H [keys](about:blank/Guide/TABLE#terms), and `flag` to be a number representing the sprite flag to check for.

Step 1: Convert the rectangle's pixel coordinates to tile coordinate bounds.

Step 2: Loop through all tiles that the rectangle overlaps.

Step 3: For each tile, get the sprite number and check if it has the target flag.

Step 4: Return true immediately if any tile has the flag, or false if none do.

You can call this function to check if your game object is colliding with specific map elements:

```lua
--check if player is touching a wall
--(flag 0 represents solid walls)
if rect_map_collision( player, 0 ) then
  --player hit a solid wall, prevent movement
  player.x = player.old_x
  player.y = player.old_y
end
```

```lua
--check if player is collecting an item
--(flag 1 represents collectible items)
if rect_map_collision( player, 1 ) then
  --player collected an item, increase score
  score += 10
  --you'd also want to remove the item from the map
end
```

#### Understanding the Simplified Version

We can condense the expanded version to be more efficient:

```lua
function rect_map_collision( r, flag )
  local left = r.x\8
  local right = (r.x+r.w-1)\8
  local top = r.y\8
  local bottom = (r.y+r.h-1)\8
  
  for x=left,right do
    for y=top,bottom do
      if map_collision(x,y,flag) then
        return true
      end
    end
  end
  return false
end

function map_collision( tile_x, tile_y, flag )
  return fget( mget(tile_x,tile_y), flag )
end
```

This works the same way as the expanded version but uses a separate `map_collision` function created in the [Collision: Map and Flags tutorial](https://nerdyteachers.com/PICO-8/Collision/98) to check if a specific tile has the target flag. This keeps the rectangle collision function cleaner and allows for easier reuse of the tile checking logic. The nested loops ensure we check every tile the rectangle touches, and we return `true` as soon as we find any tile with the target flag, making it efficient for most collision scenarios.

### 2. When to Use this?

Rectangle to Map Flag collision is essential for platformer and adventure games where the player character and other game objects are larger than a single pixel and need to interact with the game world defined by the map.

- Classic examples include side-scrolling platformers like Super Mario Bros, where Mario's rectangular hitbox needs to check for solid ground tiles, collectible coin tiles, or dangerous lava tiles.
- Top-down adventure games like The Legend of Zelda also benefit greatly from rectangle to map collision. Link's rectangular sprite needs to check for wall collisions, door tiles, water tiles, and more.

### 3. Game Dev Tip

When implementing rectangle to map collision, consider the performance implications. The function checks multiple tiles for each collision test, so you may want to optimize for common cases.

#### Tip 1: Check corners first

For scenarios where the rectangle is at least as large as the smallest tile, checking just the four corners of the rectangle might be sufficient and faster than checking every tile:

```lua
function rect_map_collision_fast( r, flag )
  local corners = {
    --list of rectangle corners in tile coordinates
    {x=r.x\8, y=r.y\8},                --top-left
    {x=(r.x+r.w-1)\8, y=r.y\8},        --top-right
    {x=r.x\8, y=(r.y+r.h-1)\8},        --bottom-left
    {x=(r.x+r.w-1)\8, y=(r.y+r.h-1)\8} --bottom-right
  }
  
  for corner in all(corners) do
    if map_collision(corner.x, corner.y, flag) then
      return true
    end
  end
  return false
end

function map_collision( tile_x, tile_y, flag )
  return fget( mget(tile_x,tile_y), flag )
end
```

#### Tip 2: Separate X and Y collision checks

For movement collision, check horizontal and vertical movement separately to enable sliding along walls:

```lua
--check horizontal movement
new_x = player.x + player.dx
temp_player = {x=new_x, y=player.y, w=player.w, h=player.h}
if not rect_map_collision(temp_player, wall_flag) then
  player.x = new_x
end

--check vertical movement
new_y = player.y + player.dy  
temp_player = {x=player.x, y=new_y, w=player.w, h=player.h}
if not rect_map_collision(temp_player, wall_flag) then
  player.y = new_y
end
```

By handling each axis independently, the player can move along one axis even if blocked on the other, allowing them to "slide" along walls when moving diagonally, creating smoother movement feel.

## Rectangle to boundary

```lua
--check if rectangle collides with a boundary
--returns true if rectangle is inside the boundary
function rect_boundary_collision(r, b)
  return r.x < b.min_x or
        flr(r.x + r.w - 1) > b.max_x or
        r.y < b.min_y or
        flr(r.y + r.h - 1) > b.max_y
end
```

## Continous Rectangle to Rectangle - Hit Library

Hit is one of the smallest advanced collision detection library. It provides reliable collision detection for fastly moving rectangles.

- [Forum discussion](https://www.lexaloffle.com/bbs/?tid=144551)
- [Documentation and source code](https://github.com/kikito/hit.p8)

### How to Use it?

### Importing the Library

Copy the hit function from the [source code](https://github.com/kikito/hit.p8/blob/main/hit.lua) and paste it into your project.

#### Parameters and return values

```lua
t,nx,ny,tx,ty,intersect = hit(x1,y1,w1,h1,x2,y2,w2,h2,goalx,goaly)
```

Hit takes 10 parameters:

- `x1,y1,w1,h1`: A first moving rectangle, represented by its top-left coordinate, a width and height
- `x2,y2,w2,h2`: A second static rectangle
- `goalx,goaly`: A point in space where the first rectangle "wants to move" (x1,y1 "wants to become" goalx,goaly)

Hit returns nil if the first rectangle can move freely to goalx,goaly without touching the second rectangle. If the rectangles touch at any point during this journey, hit will return:

- `t`: "how far along" the journey did the contact occur. 0 means that the two boxes touch right at the beginning of the journey, and 1 means they touch at the end. In some degenerate cases t can also be bigger than 1 or smaller than 0 (see below). This parameter is useful for sorting collisions (the one with the smaller t will usually have "happened" first)
- `nx,ny`: the "normals" of the contact. Given that we are dealing with aabbs, both nx and ny can only have -1,0 or 1
- `tx,ty`: the coordinates where the first rectangle's top-left corner would be when it starts touching the second rectangle
- `intersect`: `true` if the boxes were intersecting at the beginning of the journey, `false` if they were not. This parameter is useful to treat intersections differently from non-intersections in the collision resolution

### 1. How it Works?

Hit combines two algorithms: The Minkowsky Difference and the Liang-Barsky line clipping algorithm.

The Minkowsky difference is a geometrical operation, where one object "gets smoothed over" the perimeter of another object. If you do the minkowsky difference between a square and a circle you will get a bigger square with rounded corners. When you do the minkowsky difference between two rectangles you get another (bigger) rectangle.

The neat thing about this is that if you make one of the rectangles "bigger", you can make the other "smaller", and the properties of the collision work the same (as long as you respect some norms). If we make one of the rectangles as big as the Minkowsky diff, we can make the other one as small as a single point.

Which means that our "how do I collide these two moving boxes with each other" gets simplified to "how do I intersect this bigger box with this pixel that is moving, in other words, this segment".

The family of algorithms that solve this particular problem is called "line-clipping algorithms", and the Liang-Barsky one seems to be the fastest generic one. So we clip the diff with the segment, which gives us t and the normals. We then calculate tx and ty, paving over the floating point imprecision as much as possible.

### 2. When to Use this?

Use the Hit library when you need collision detection for fast-moving rectangles, especially in platformers or top-down shooters.

#### Cost

Hit costs 422 tokens approximately. Most of the tokens come from the calculation of tx,ty,nx and ny. If those are not needed, then it can be strip down to a much leaner function that only returns true or false.

The function has several comments which can be stripped in order to save characters if necessary.

Performance-wise, it is not very expensive. There will be always some calls to abs, and number comparisons. For non-degenerate cases there will always be 4 divisions per collision detection.

### 3. Game Dev Tip

Only use Hit when it is really necessary. The simpler PICO-8 collision functions are fast and efficient for most cases.

Hit also has some [limitations](https://github.com/kikito/hit.p8?tab=readme-ov-file#notes-and-degenerate-cases), so if you need more advanced features, you may need to use the creator's previous more robust collision library: [bump.lua](https://github.com/kikito/bump.lua)
