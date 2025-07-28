# Collisions tutorials

## What is Collision?

When you play a video game, characters jump on platforms, enemies bump into each other, and items get picked up when touched. All of that happens thanks to something called collision detection, checking when something collides.

Collision is when two things in a game **touch or overlap**. The game needs to detect when this happens so it can respond appropriately. Sometimes things are allowed to overlap, or pass in front or behind one another, while other times they should bump, bounce, crash, hurt, collect, etc. In all cases, it is better to know where your game objects are in relation to each other, and have them respond correctly.

### What is Collision in Games?

![](../resources/img/tutorials/collision/pause_jelpi.gif)

Something as simple as having a character walking and jumping on the ground uses collision detection.

![](../resources/img/tutorials/collision/pause_jelpi_watermelon.gif)

Collecting points, items, or resources uses collision detection.

![](../resources/img/tutorials/collision/pause_jelpi_bird.gif)

Players interacting with objects in the game or with each other uses collision detection.

![](../resources/img/tutorials/collision/pause_jelpi_frog.gif)

Enemies hurting or killing the player uses collision detection.

Without collision detection, everything would just pass through everything else. Some interactions in games are caused by button presses, or timers that trigger changes, but the rest happen because of some form of collision detection. So collision detection is an important part in all types of games!

###### PICO-8 Does Not have Built-in Collision Detection

Many game engines have different types of collision detection built into the engine, and you can apply different colliders to objects by clicking a few buttons. But PICO-8 does not provide any for you. This can be a frustrating realization, especially if you don't know where to start to make things in your game interact with each other. However, once you learn a few ways you can build your own collision in games, you realize how much power and control you have over exactly how things in your game interact.

### Types of Collision Detection

There are many different types of collision detection, most based on the different shapes of your game objects. There are a few types that don't depend on shapes such as boundary collision, color-based collision, and map collision, which is a simple place to start.

For the more traditional shape-based collision, we'll use geometry to figure out if two shapes are touching. As complicated as they might seem, they all need just 3 things:

* The **positions** of your game objects (coordinates X and Y ).
* The **size** of the objects (width, height, or radius).
* The **rule** for checking if they overlap, which is different for different shapes.

## Color Detection

One of the simplest forms of collision detection is simply color detection. You just check what color pixel is on the screen ahead of where the player or game object is about to move to, and do something based on what color that is.

```lua
function color_collision(x,y,c)
 return pget(x,y) == c
end
```

### 1. How it Works

#### Preparing Coordinates

First, we need an easy way to store the coordinates of a point for the player or other game object that is moving. We can do that with a [table](../Guide/create_tables) that stores X, and Y, variables. The above function expects to get coordinates X and Y, and a color C. It will then check what color pixel is at those coordinates and compare it with the color given.

The player, as a point, could be created like this:

```lua
--create object table
p = { x=10, y=20 }
```

To get the values out of that table, we use `p.x` ([See Table Shorthand](about:blank/Guide/Tables#shorthand)).

```lua
--get values out of object table
print( p.x ) --prints 10
```

#### Understanding PGET( )

PICO-8 has a built-in function for getting the color of a pixel on the screen.

```lua
 pget( x, y )
```

|x|the distance from the left side of the screen.|
|---|----------------------------------------------|
|y|the distance from the top side of the screen. |

This function will return the color number (0-15) of a single pixel currently drawn at the (x,y) coordinates specified. If you request a pixel that is outside of the screen, then `pget` will return 0 (zero).

We can compare the `pget(x,y)` color with any color number to know if the color we choose matches the pixel on the screen.

```lua
c = pget(x,y)
if c == 8 then print("it is red") end
```

#### Understanding an Expanded Version

We can write the same tiny function at the top of the page in a way where we break down each step:

```lua
function color_collision(x,y,c)
 local target = pget(x,y)

 if target == c then
  return true
 else
  return false
 end
end
```

This function has [parameters](../Guide/ARGUMENTS) `(x,y,c)` and it is expecting those to be numbers. X and Y should be somewhere on screen (0 -127) and the C should be one of the color numbers (0-15).

Step 1: get the target pixel's color with `pget`.

Step 2: compare the target pixel's color with the color number given to this function as `c`.

Step 3: if the colors match, then return true, otherwise, return false.

### Understanding the Simplified Version

We can simplify and condense the expanded version down to just one line:

```lua
function color_collision(x,y,c)
 return pget(x,y) == c
end
```

This works the exact same way as the expanded version because all the steps of getting the target's color, comparing it to a specific color, and returning true or false all happen in this one line.

The first way we condensed the code is to skip saving the target's color in a local variable. We immediately compare the color returned by `pget` with the color given in `c`.

```lua
pget(x,y) == c
```

 The second trick to condense it is to simply return the result of the comparison. It will get the color with `pget` first, then compare those results with the color given `c`, then `return` the comparison's result of `true` or `false`.

```lua
return pget(x,y) == c
```

### How to use it?

Honestly, it's so simple you don't even need the function to do this type of color detection. You could just place the comparison right in an [if statement](../Guide/IF). It's up to you to decide and customize it to make it easier to use in your specific game and with your style of writing.

Here's how we could use it to check multiple colors by using the function:

```lua
if color_collision(p.x,p.y,8) then
 print("red")
elseif color_collision(p.x,p.y,12) then
 print("blue")
end
```

Here's how we could do the same thing without the function:

```lua
if pget(p.x,p.y) == 8 then
 print("red")
elseif pget(p.x,p.y) == 12then
 print("blue")
end
```

The real benefit of using color detection as a function (which you can rename shorter) is that it is easier to read and understand what the code is doing instead of seeing the comparison of `pget` with a number and have to remember what that means.

### 2. When to Use this?

Collision through color detection can be used in very simple games and works well in the ultra low resolution arcade classics such as Pong, Frogger, and Adventure.

Here is a good idea for one of the first games you make in PICO-8, a maze. Simply learn how to control a player as a single pixel, navigating through a hand drawn maze and use the colors of the floor and walls to allow or not allow the player to move there.

![](../resources/img/tutorials/collision/maze.png)

```lua
--init
player = { x=64, y=64 }
wall = 3--dark green

--update
if color_collision( player.x, player.y, wall ) then
 --cannot move here
end
```

Sometimes you can simplify a larger sprite down to a single point near its center. A classic example is the Light Cycle minigame from Tron. The cycles can be sprites and single pixels of a certain color are placed behind them. All you need to do for collision in this game is to detect the color of the pixel in front of your light cycle and check if it is either of the trail colors, in which case you explode.

![](../resources/img/tutorials/collision/tron.png)

```lua
--init
player = { x=64, y=64 }
enemy = { x=64, y=64 }
floor = 0--black
wall = 1 --dark blue
player_trail = 12 --blue
enemy_trail = 10 --yellow

--update
if color_collision( player.x, player.y, floor ) then
 --can move here
elseif color_colision( player.x, player.y, player_trail )
or color_colision( player.x, player.y, enemy_trail ) then
 --crash
end
```

## Boundary

### 1. How it Works

###### Preparing an Object

First, we need an easy way to store the position and other data for a player or other game object that is moving in your game. We can do that with a [table](../Guide/create_tables) that stores at least X and  Y variables. The above function expects to get an object table and 4 numbers that will serve as the placement rectangular edges of the boundary.

The player or any game object, could be created like this:

```lua
--create object table
obj = { x=10, y=20 }
```

To get the values out of that table, we use `obj.x` ([See Table Shorthand](about:blank/Guide/Tables#shorthand)).

```lua
--get values out of object table
print( obj.x )   --prints 10
```

###### Creating a Boundary

The simplest and most common boundary that you might use in your game is keeping objects on the screen. The edges of the screen become the bounds that you don't want to allow movement outside of.

The PICO-8 screen is 128x128 pixels, starting at 0 on the left edge and ending at 127 on the right edge. The same goes for the top (0) and bottom (127).

![](../resources/img/tutorials/collision/screen_boundary_values.png)

You could name these boundary edges whatever make the most sense to you which could be for example "left, right, top, bottom" or as minimum and maximums on the axes, "min\_x, max\_x, min\_y, max\_y".

![](../resources/img/tutorials/collision/screen_boundary_minmax.png)

|side  |variable|screen|
|------|--------|------|
|left  |min_x   |0     |
|right |max_x   |127   |
|top   |min_y   |0     |
|bottom|max_y   |127   |

To keep your game object inside of the boundary, first think of it one side at a time. So considering the left side ( the minimum on the X-axis ), you just want to check if the object is to the right of the left side. Since left on the x-axis are lower numbers, we could simply check if the game object's X is more than the left edge ( `min_x` ):

```lua
if obj.x > min_x then 
 --allow movement
end
```

Or you could do the opposite to force the object to stop at the edge:

```lua
if obj.x < min_x then 
 obj.x = min_x
end
```

The above code will check if the object is moving to the left of the left edge, and if true, then the object X will just get set back to the left edge of the boundary. The player could press the left button as much as they want, and every time the player tries to move past the boundary, it just gets reset to the boundary edge. In the game, this would happen before the character is drawn, so to the player, it simply looks like the character hit a wall.

Now let's do the same for both the left and right sides of the screen.

![](../Guide/picoImg/mid_example_2.gif)

```lua
if obj.x < min_x then 
 obj.x = min_x
elseif obj.x > max_x then
 obj.x = max_x
end
```

Just change all of those X's to Y's and you create vertical edges to the boundary. This is the basic idea of how to create a boundary and keep a game object within that boundary.

###### Understanding an Expanded Version

We can continue the logic of checking each edge and keeping the object within all four sides of a rectangular boundary like this:

```lua
function boundary_collision(obj,min_x,max_x,min_y,max_y)
  if obj.x < min_x then 
   obj.x = min_x
  elseif obj.x > max_x then
   obj.x = max_x
  elseif obj.y < min_y then 
   obj.y = min_y
  elseif obj.y > max_y then
   obj.y = max_y
  end
end
```

This function has [parameters](../Guide/ARGUMENTS) `( obj, min_x, max_x, min_y, max_y )` and it is expecting the obj to be a table and the rest to be numbers that will be compared to the object's X and Y position.

###### Why No Return?

After checking all 4 sides of the boundary, we just set the object's X and Y, without returning anything because the global table that is passed to this function will be updated even within this function, and even as the table becomes a local variable named `obj`.

For example, if we pass this function a player object table, the original player table will be updated even though it will be referenced as a local variable named `obj` from inside the function. This is because tables in Lua are passed by reference, as stated here in the [Lua manual](https://www.lua.org/manual/5.4/manual.html#2.1):

"Tables...are objects: variables do not actually contain these values, only references to them. Assignment, parameter passing, and function returns always manipulate references to such values; these operations do not imply any kind of copy."

```lua
player = { x=30, y=40 }

boundary_collision( player, 0, 0, 127, 127 )

--player table is updated by boundary function
```

###### Understanding the Simplified Version

We can simplify and condense the expanded version down to just one line:

```lua
function boundary_collision(obj, min_x, min_y, max_x, max_y)
 obj.x, obj.y = mid(min_x,obj.x,max_x), mid(min_y,obj.y,max_y)
end
```

This works the exact same way as the expanded version because all the steps of comparing the object's X and Y with all four edges of the boundary (X and Y minimums and maximums), and then setting the object's X and Y to those edges if it goes beyond them, all happen in this one line.

The first way we condensed the code is what is called [multiple assignments](about:blank/Guide/VARIABLE#multiple). Where we assign more than one value to more than one variable on a single line. That way we assign obj.x and obj.y together on the first line of the function, separated by commas.

```lua
obj.x, obj.y = value1, value2
```

 The second trick to condense it is to use a very handy PICO-8 function named [`mid()`](../Guide/MID) which returns the middle of 3 numbers.

```lua
mid( 12, 104, 60 )  --returns 60
```

We can use this one function to compare the object's X with both left and right edges of the boundary we set, and then the object's Y with both edges of the top and bottom edges. Since it returns whichever value is in the middle of the 3 compared, we will get the edge's value whenever the object tries to move beyond it. Then we can simply set whatever is returned to the object's X and Y, which would stay the same values as they were as long as the object is within the boundary.

We can expand it to 2 lines to make it easier to read:

```lua
 obj.x = mid( min_x, obj.x, max_x ) 
 obj.y = mid( min_y, obj.y, max_y )
```

![](../Guide/picoImg/mid_example_2.gif)

### 1. When to Use this?

Boundary Collision can be used in a variety of ways and often used with other forms of collision.  You don't always need a full rectangular boundary, you might only use a single side, or separate out each side to do something different, not just keep the player within the boundary.

One classic game that kept you within a boundary on a single screen was Bubble Bobble. Notice that the boundary (in red) is not at the screen edges, but shrunk to within the smaller game play area with the gray bricks creating a frame outside of the play boundary. This is a perfect case to use our boundary function at the top of this page.

![](../resources/img/tutorials/collision/bubblebobble.png)

```lua
--init
player = { x=20, y=110 }

--update
boundary_collision( player, 8, 8, 120, 120 )
```

#### Note: You would also take the height and width of the sprites into consideration

Some games such as Super Mario Bros 3, have levels where you must outrun a constantly moving screen edge such as this airship level with the left side being an invisible force that kills you if you fall too far behind. Sometimes it is a jumping game with water or lava rising from the bottom, or a wall of spikes or fire closing in on you. Instead of trying to create complicated collision detection for a hazard like that, you could simplify it to a single boundary edge that could be fixed to the side of the screen, or slowly advancing towards the player.

![](../resources/img/tutorials/collision/SMB3.png)

```lua
--init
player = { x=64, y=64 }
min_x = 0 

--update
if player.x < min_x then
 --player dies
end
```

In Pong, you could have the screen as the boundary where the ball collides with the top and bottom sides, but the left and right sides trigger the opposite player to gain a point and reset the game. In this case, you would want to separate the sides of the boundary collision to trigger different reactions to the ball trying to cross the specific side.

![](../resources/img/tutorials/collision/pong.png)

```lua
--init
ball = { x=64, y=64 }

min_x = 0   --player goal
max_x = 127 --computer goal

min_y = 0   --top wall
max_y = 127 --bottom wall

--update
if ball.x < min_x then  --left
 --computer scores 
end
if ball.x > max_x then  --right
 --player scores 
end

if ball.y < min_y        --top
or ball.y > max_y then   --bottom
 --bounce ball off wall 
end
```

# Map and Flags

If your game uses the [map](../Guide/WHAT_MAP) as anything more than a background, then you'll want some form of map collision. Map collision, in its simplest form, is checking the tile on the map and finding out what type of sprite is drawn there. You can keep it as simple as that or make it as complex as you need by saving information on your sprites to know how they should interact with your game objects.

### No Collision

PICO-8 Collision Function
-------------------------

```lua
function map_collision( tile_x, tile_y, flag )
  return fget( mget(tile_x,tile_y), flag )
end
```

  1. Understanding the Map

###### Storing Pixel Coordinates

First, you'll probably need an easy way to store the coordinates of an game object that will be moving around over the map. We can do that with a [table](../Guide/create_tables) that stores X and Y variables specific to that object. This would be the pixel coordinates of where the object is on the screen, between 0 and 127.

It would be created like this:

```lua
--create an object table
obj = { x=10, y=20 }
```

Now that we have a table with coordinates `X` and `Y`, we can get the value out of the table with `obj.x`. ([See Table Shorthand](about:blank/Guide/Tables#shorthand))

```lua
--get value out of object table
print( obj.x )  --prints 10
```

###### Map Tile Coordinates

![](../Guide/picoImg/map_coordinates.gif)

#### Tile Coordinates are displayed in bottom left of map editor

The map does not use pixel coordinates. Instead, it uses tile coordinates. Each tile is 8x8 pixels. So on a screen of 128x128 pixels, there are only 16x16 tiles. To convert from pixels to tiles, you just divide by 8.

```lua
tile_x = obj.x / 8
```

To make sure that we don't get a fraction, we will want to round down after dividing. We can do that two ways:

```lua
--option 1: floor function
tile_x = flr( obj.x/8 )

--option 2: floor division
tile_x = obj.x\8
```

The [floor](../Guide/FLR) function will round any number down to its nearest integer (whole number). If you want to floor after dividing like we do here, then we can use a backslash "**\\**", which is a special [operator](../Guide/OPERATORS) for dividing AND rounding down.

So understanding the difference between pixel coordinates (which most game objects are saved in) and tile coordinates (which the map is saved in) is necessary when we want to compare an object's screen placement with the map's sprites.

```lua
--pixels to tiles
tile_x = obj.x\8
tile_y = obj.y\8
```

If you play with the demo at the top of this page and click "Show Measurements" button, you will see how the point at the mouse cursor, has X and Y pixel coordinates, and we convert that to "Map Tile" coordinates.

That's how we get tile coordinates to use in this map collision function...

###### Getting Sprite from the Map

The next step is to look at those map tile coordinates and find out what sprite is currently drawn there. PICO-8 has a built in function to do this named [`mget()`](../Guide/MGET), which stands for "map get".

```lua
sprite = mget( tile_x, tile_y )
```

The `sprite` variable will store the sprite _number_ that `mget` returns. Make sure to use tile coordinates for this function, not pixel coordinates.

At this point you could simply compare `sprite` with a specific sprite number that you want to look for. And that is the simplest form of map collision you could use in your game. For example, if you only use 1 sprite for all the walls in your game, then you just check for that one wall's sprite number.

![](../resources/img/tutorials/collision/bubblebobble_map.png)

```lua
wall = 1 --sprite number
tile_x = obj.x\8
tile_y = obj.y\8
sprite = mget( tile_x, tile_y )

if sprite==wall then 
 --cannot move here
end
```

However, for more visually interesting games, you'll want many variations of the same sprites that you can group together as types, for example: walls, plants, rocks, signs, doors, etc. Those would be too many sprite numbers to check them one by one, so instead, grouping them all as "solid" is a better idea. We can group sprites like this by turning on sprite flags....

###### Using Sprite Flags

Here is an example where we draw a bomb sprite and add a sprite flag to it in the sprite editor. Read more about how to use sprite flags under this [guide page](../Guide/FGET).

![](../Guide/picoImg/fget_bomb.png)

Now that we are using a flag, we can find out what flag a sprite has from another built-in function named [`fget`](../Guide/FGET). It is common to use `mget()` and `fget()` together, since `mget()` will find what sprite is on the map, and provide the sprite number, which `fget()` will use to find out if it has the certain flag you are looking out for.

```lua
bomb = 0 --flag number
sprite = mget( tile_x, tile_y )
is_bomb = fget( sprite, bomb )
```

The `is_bomb` variable will be **true** or **false** if the sprite has the `bomb` flag number because  `fget` compares the two and returns true if they are equal.

By using a flag, we can draw many more bomb sprites or other hazards, and simply give them all the same flag, then the game's collision will treat all those sprites placed on the map the same way.

The sprite flags have no meaning by themselves. They are just numbers, so it is up to you to designate meanings to those numbers and group sprites any way you'd like, for example:

|Flag #|Arbitrary Meaning                        |
|------|-----------------------------------------|
|0     |Sprites that are solid. (all walls)      |
|1     |Sprites that are collectable. (all items)|
|2     |Sprites that are dangerous. (all hazards)|

  1. How the Function Works

###### Understanding an Expanded Version

Now that you know how map tile coordinates and sprite flags work, we just need to compare what flags the tiles on the map have with the type of sprite we are looking for.

**Step 1:** get the sprite number at a certain location on the map, using tile coordinates.  
**Step 2:** get the flag(s) of that sprite, using the sprite number.  
**Step 3:** compare the flag(s) of the sprite to the flag you are looking for.

We can put all that together into an expanded function like this:

```lua
--expanded example
function map_collision( tile_x, tile_y, flag )
 --get sprite number from map
 local sprite = mget( tile_x, tile_y )

 --get flags of that sprite number
 local tile_flag = fget( sprite )

 --compare sprite flag with target flag
 if tile_flag == flag then
  return true
 else
  return false
 end
end
```

This function has [parameters](../Guide/ARGUMENTS) `(tile_x,tile_y,flag)` and it is expecting those to be numbers. However, by expanding out each step of the function, we've actually changed how it will work a little. If you use the function above, you'll need to change what flag number you are looking for. Instead of just 0-7 flags, this will return a unique number between 0 and 256, which is how you could create many many flag meanings by using a combination of the 8 sprite flags.

#### Read more about how to use multiple sprite flags under this [guide page](../Guide/FGET)

The logical steps of the function remain the same, and from this example, it is easier to understand what shortcuts we use to condense the function down to just one line.

You can call this function in two ways to catch the returned true or false result:

```lua
--catch result in a variable
is_colliding = map_collision( obj.x\8, obj.y\8, 0 )

if is_colliding then
 print("collided!")
end
```

```lua
--directly inside an if statement
if map_collision( obj.x\8, obj.y\8, 0 ) then
 print("collided!")
end
```

If you don't know why we use `obj.x\8, obj.y\8`, read the above section: "Understanding the Map".

###### Understanding the Simplified Version

We can simplify and condense the expanded version down to a single line:

```lua
--simplified version
function map_collision( tile_x, tile_y, flag )
  return fget( mget(tile_x,tile_y), flag )
end
```

This works the exact same way because all 3 steps of the function are happening in this one line. Read the line from inside out to follow the steps of the logic and to understand how this line gets resolved.

Step 1: `mget(tile_x,tile_y)`

This function will return the sprite number at those coordinates on the map. Instead of saving that to a variable, it is immediately being passed to `fget()` as argument 1, which is where fget expects to get a sprite number. This is why you'll often see `mget` inside of `fget` working together like this.

Step 2: `fget( [sprite_number], flag )`

This function will take the sprite number from `mget` and get what flags that sprite has. Since we also provide a flag as the second argument, the `fget` function will also compare the sprites flag with the flag number we pass to it.

Step 3: `return [true or false]`

The `fget` function will resolve to **true** or **false** since it is already doing the comparison of flags for us. So we can just `return` the result of the comparison immediately in a single step and it does the same thing as the expanded "if true then return true, if false then return false" redundant logic. The `fget` function compares the flags, and our `map_collision` function simply return the result.

This is as simple and useful as we could make it, but we also wanted to provide you with a potentially more useful version of this map collision function which you can customize even further...

###### Understanding an Abstracted Version

We can customize this map collision function to be easier to use in our games, depending on how we are going to use. For example, if your game uses object tables for your player, items, and enemies that move on top of the map, and you know that you will want them all to interact with solid walls on the map, then you could realize that you will be doing a lot of converting from pixel coordinates to tile coordinates in order to pass the tile\_x and tile\_y arguments to the map\_collision function, like this:

```lua
tile_x = player.x\8
tile_y = player.y\8

if map_collision( tile_x, tile_y, 0 ) then
  --player hit a wall
end
```

You would have to do that for each player, item, and enemy in your game before you could use the simplified `map_collision` function above. That's why we wanted to provide an example of how you could make it a little easier on yourself if your game uses a lot of object tables.

In this version, you simply pass an object table and let the collision function convert the coordinates for you:

```lua
--abstracted version
function map_collision( obj, flag )
  local x,y = obj.x\8, obj.y\8
  return fget( mget(x,y), flag )
end
```

### 2. When to Use this?

Map Collision can be used in many creative ways. Classic games such as Link's Awakening is a good example where the character is mostly walking on top of a map, and where each map sprite has a designation like sprite flags to determine how Link interacts with those spaces on the map.

If we were to recreate this scene in PICO-8, Link's sprite is the only object table, able to move around on top of everything else that is drawn on the map. But thanks to flagging the different sprites on the map, it will feel like Link is actually in the space, not just drawn on top of it. The floor tiles are walkable, the wall tiles are not, and the doorways trigger a scene change to the next room. All of those interactions are done with just map collision!

![links awakening dungeon showing map tiles color overlay](../resources/img/tutorials/collision/link_map.png)

|Flag #|Arbitrary Meaning              |
|------|-------------------------------|
|0     |(red) Sprites that are solid.  |
|1     |(blue) Sprites that are floors.|
|2     |(green) Sprites that are doors.|

Another example could be side-scrolling platformers such as Kirby's Dreamland. This could use the map but you may be surprised that it is for the midground not the background. The background could be made as separate layer(s) of the map to create the parallax scrolling effect, but those layers would not need map collision. Otherwise, the background sky is drawn and animated in code.

The midground however is where the main map is being used, where it designates which sprites are ground and platforms and which are passable. Kirby would be an object table, as well as the enemies and items being thrown, and they get drawn on top of the map and interact with the certain map sprites that are flagged as solid ground.

![kirby platformer showing map tiles color overlay](../resources/img/tutorials/collision/kirby_map.png)

|Flag #|Arbitrary Meaning                             |
|------|----------------------------------------------|
|0     |(red) Sprites that are solid ground/platforms.|
|1     |(blue) Sprites that are passable.             |

## Point to Point

The simplest form of collision detection. Two points collide only when they occupy the exact same space. Their positions are known by their X and Y coordinates and we know they occupy the same space when their x's are equal _and_ their y's are equal at the same time.

PICO-8 Collision Function
-------------------------

```lua
function point_point_collision( p1, p2 )
  return p1.x==p2.x and p1.y==p2.y
end
```

### 1. How it Works

###### Comparing Coordinates

First, we need an easy way to store the coordinates of 2 points on the screen. We can do that with 4 different variables, or even better as 2 [tables](../Guide/create_tables) that store separate X and Y variables. Those tables, named `p1` and `p2` are what the above function expects.

They would be created like this:

```lua
--create 2 points as object tables
p1 = { x=10, y=20 }
p2 = { x=30, y=40 }
```

Now that we have 2 points, each with coordinates `X` and `Y`, we can compare them. To get the value of point 1's `x`, we use `p1.x`. ([See Table Shorthand](about:blank/Guide/Tables#shorthand))

```lua
--get value out of point table
print( p1.x )  --prints 10
```

We want to compare point 1's X with point 2's X, and point 1's Y with point 2's Y. In expanded form, this check can be written as:

```lua
--compare x
if p1.x == p2.x then print("same x") end

--compare y
if p1.y == p2.y then print("same y") end
```

We can do both of those checks at the same time using the [and operator](about:blank/Guide/OPERATORS#logical):

```lua
--compare x and y
if  p1.x == p2.x 
and p1.y == p2.y then 
 print("same position") 
end
```

###### Understanding an Expanded Version

Now that we have 2 points, with coordinates, and we know how to compare them, we can put it all together into an expanded function like this:

```lua
--expanded example
function point_point_collision(p1,p2)
 if  p1.x == p2.x 
 and p1.y == p2.y then 
  return true
 else
  return false
 end
end
```

This function has [parameters](../Guide/ARGUMENTS) `(p1,p2)` and it is expecting those to be objects with X and Y [keys](about:blank/Guide/TABLE#terms).

The function has 1 if statement that compares the first point's X with the second point's X to check if they are exactly equal. It does the same, comparing the first point's Y with the second point's Y. The `and` is used to make sure that both of those checks are true before running the code inside: `return true`, which will send the value `true` back to where this function was called.

If one or both of those checks are `false`, then the code after `else` will run, which will return the value `false` instead.

You can call this function in two ways to catch the returned true or false result:

```lua
--catch result in variable
is_colliding = point_point_collision( p1, p2 )

if is_colliding then
 print("collided!")
end
```

```lua
--directly inside of if statement
if point_point_collision( p1, p2 ) then
 print("collided!")
end
```

Note that these examples use the same argument names as parameter names just for the convenience of this tutorial, but to make the difference clear, this is how the parameters of the function still uses `(p1,p2)` but the [arguments](../Guide/ARGUMENTS) when calling the function could be any [object table](about:blank/Guide/create_tables#object) such as:

```lua
player = { x=10, y=20 }
enemy = { x=30, y=40 }

if point_point_collision( player, enemy ) then
 print("collided!")
end
```

#### (See more examples below in When to Use this?)

###### Understanding the Simplified Version

We can simplify and condense the expanded version down to a single line:

```lua
function point_point_collision(p1, p2)
  return p1.x==p2.x and p1.y==p2.y
end
```

This works the exact same way because the comparisons of `p1.x==p2.x and p1.y==p2.y` will result in either true or false the same way it does in an if statement. So we don't need the if statement at all.

The expanded function boils down to _"if both true, return true, and if either false, return false"_ which is an unnecessary step to explicitly return true or false since what we want to return is the same as the result of the comparisons.

So we can just `return` the result of the comparisons immediately in a single step and it does the same thing. Compare the Xs and the Ys, then just return the result.

### 2. When to Use this?

Point to Point Collision can be used in low graphics games where the game objects are represented by single pixels. Classic arcade games are good examples, such as Snake where you only care about the head of the snake colliding with either the food pellet or the body.

![classic snake and a single pixel pellet.](../resources/img/tutorials/collision/snake.png)

```lua
snake = { x=10, y=20 }
food = { x=50, y=70 }
body = {}

if point_point_collision( snake, food ) then
 score+=1
end
```

Another example could be a more complicated game visually, but still very simple in terms of where game objects are placed on the screen. Tactical games where everything is placed always on a grid means that you can check collision of the coordinates where the objects are placed instead of checking for overlapping rectangles.

Here is a mockup of a tactical tank game. Each tank and city is drawn with 16x16 sprites but their placement is always on the grid of tiles over top of and after drawing the grassy map. Their sprites are drawn starting from the top left corner of the sprite, which is a single point. We can therefore check if two tanks are overlapping or if a tank occupies a city by comparing only those two points.

![blue and red tanks on a green grassy tiled map](../resources/img/tutorials/collision/turnbased_tanks.png)

```lua
blue_1 = { x=10, y=20 }
red_1 = { x=50, y=70 }
city_1 = { x=20, y=80 }

if point_point_collision( blue_1, city_1 ) then
 --blue captures city
end
```

## Point to Rect

A point collides with a rectangle when the point's coordinates fall within the rectangle's four sides, also called the rectangle's "bounds", or in games they are often called "hitboxes". We know when a point is inside of a rectangle by comparing the point's coordinates with each side of the rectangle. Only when all four comparisons are true do we know that the point has collided with the rectangle.

PICO-8 Collision Function
-------------------------

```lua
function point_rect_collision( p, r )
  return p.x >= r.x and
         p.x <= r.x+r.w and
         p.y >= r.y and
         p.y <= r.y+r.h
end
```

### 1. How it Works

###### Comparing Coordinates

First, we need an easy way to store the coordinates of a point and the sides of a rectangle on the screen. We can do that with 2 [tables](../Guide/create_tables) that store separate X, Y, width, and height variables. Those tables (named `p`for point and `r` for rectangle) are what the above function expects.

They would be created like this:

```lua
--create object tables
p = { x=10, y=20 }
r = { x=30, y=40, w=10, h=10 }
```

Now we have a point, starting at coordinates `X` and `Y`, and a rectangle at coordinates `X` and `Y`, and with a width of `w` and a height of `h`. To get the value of point 1's `x`, we use `p.x`. ([See Table Shorthand](about:blank/Guide/Tables#shorthand))

```lua
--get value out of point table
print( p.x )  --prints 10
```

We also need to be able to get the sides of the rectangle, so we can compare them with the point.

```lua
--get sides of rectangle table
print( r.x )      --left side
print( r.x+r.w )  --right side
print( r.y )      --top side
print( r.y+r.h )  --bottom side
```

Next, we want to compare the point's X with the rectangle's left and right sides, and the point's Y with the rectangle's top and bottom sides. In expanded form, this check can be written as:

```lua
--compare x
if p.x >= r.x then print("right of left side") end
if p.x <= r.x+r.w then print("left of right side") end

--compare y
if p.y >= p.y then print("below top side") end
if p.y <= p.y then print("above bottom side") end
```

We can do all of those checks at the same time using the [and operator](about:blank/Guide/OPERATORS#logical):

```lua
--compare point with 4 sides
if  p.x >= r.x
and p.x <= r.x+r.w
and p.y >= r.y 
and p.y <= r.y+r.h then
 print("point is inside rectangle")
end
```

###### Understanding an Expanded Version

Now that we have a point with coordinates, as well as a rectangle with coordinates and dimensions, and we know how to compare the point to all 4 sides of the rectangle, we can put it all together into an expanded function like this:

```lua
--expanded example
function point_rect_collision( p, r )
 if  p.x >= r.x
 and p.x <= r.x+r.w
 and p.y >= r.y 
 and p.y <= r.y+r.h then   
  return true
 else
  return false
 end
end
```

This function has [parameters](../Guide/ARGUMENTS) `(p,r)` and it is expecting those to be objects with X and Y [keys](about:blank/Guide/TABLE#terms), and the `r` to also have W and H keys.

The function has 1 if statement that compares the point with each side of the rectangle. The `and` operator is used to make sure that all four of those checks are true before running the code inside: `return true`, which will send the value `true` back to where this function was called.

If any one of those checks are `false`, then the code after `else` will run instead, which will return the value `false`.

You can call this function in two ways to catch the returned true or false result:

```lua
--catch result in variable
is_colliding = point_rect_collision( p, r )

if is_colliding then
 print("collided!")
end
```

```lua
--directly inside of if statement
if point_rect_collision( p, r ) then
 print("collided!")
end
```

Note that these examples use the same [argument names and parameter names](../Guide/ARGUMENTS) just for the convenience of this tutorial, but to make the difference clear, this is how the parameters of the function still uses `(p,r)` but the arguments when calling the function could be any [object table](about:blank/Guide/create_tables#object) such as:

```lua
bullet = { x=10, y=20 }
enemy = { x=30, y=40, w=8, h=8 }

if point_rect_collision( bullet, enemy ) then
 print("collided!")
end
```

#### (See more examples below in When to Use this?)

###### Understanding the Simplified Version

We can simplify and condense the expanded version down to a single line:

```lua
function point_rect_collision( p, r )
  return p.x >= r.x and p.x <= r.x+r.w and p.y >= r.y and p.y <= r.y+r.h 
end
```

_(This is the same function as under the interactive demo, but we removed the new lines.)_

This works the exact same way as the expanded version because the comparisons of the point to each side of the rectangle will result in either true or false the same way it does in an if statement. So we don't need the if statement at all.

The expanded function boils down to _"if all checks true, return true, and if any are false, return false"_ which is an unnecessary step to explicitly return true or false since what we want to return is the same as the final result of the four comparisons.

So we can just `return` the result of the comparisons immediately in a single step and it does the same thing.

### 2. When to Use this?

Point to Rectangle Collision can be used in a variety of games whenever you have something as small as a single pixel and another thing any size larger. A classic game that would use this is Duck Hunt, where the "gun" is a single point on the screen that you could move around with the arrow keys or the mouse instead of the actual NES hardware.

The duck sprite would be the rectangle which we drew here but the rectangle hitbox would be invisible to the player in the actual game. The point that we check collision with would be the center point of the reticle.

![](../resources/img/tutorials/collision/duckhunt.png)

Another classic game example is Contra, and so this is true for many shooting games where the bullets are small enough to consider them points, and you want to check collision of the bullets with enemies or other game objects. Note that we could draw the bullets as larger sprites but still use point to rectangle collision on them where the point is the center of the sprite. Again, the red rectangle around the enemy would not be visible in the actual game.

![](../resources/img/tutorials/collision/contra.png)

A third example is when you have a cursor that freely moves around the screen, either controlled by the mouse or just arrow keys. You may want the cursor to interact with buttons in a menu, or select units in a strategy game.

![](../resources/img/tutorials/collision/button.png)

Notice that we drew the mouse with a single red pixel at the point. All of the red indicators in this example would be invisible in the actual game. This demonstrates that even when using a larger sprite such as a mouse cursor icon, in code, we consider it as just a single point at the tip that we use to check collision.

## Rect to Rect

A rectangle collides with another rectangle when the edges overlap on both the x and y axes. This is usually checked by comparing each of the four sides of one rectangle with the _opposite_ sides of the other rectangle.

This type of collision is commonly referred to as **AABB** (axis aligned bounding box) and it is the most widely used collision detection in games.  

PICO-8 Collision Function
-------------------------

```lua
function rect_rect_collision( r1, r2 )
  return r1.x < r2.x+r2.w and
         r1.x+r1.w > r2.x and
         r1.y < r2.y+r2.h and
         r1.y+r1.h > r2.y
end
```

### 1. How it Works

###### Comparing Coordinates

First, we need an easy way to store the sides of a rectangle. We can do that with 2 [tables](../Guide/create_tables) that store separate X, Y, width, and height variables. Those tables (named `r1`for the first rectangle and `r2` for the second) are what the above function expects.

They could be created like this:

```lua
--create object tables
r1 = { x=10, y=20, w=10, h=10 }
r2 = { x=50, y=60, w=15, h=15 }
```

Now we have two rectangles at their own coordinates of `X` and `Y`, and with widths of `w` and a heights of  `h`. To get the sides of  `r1`, we use a combination of these variables. For example, the right side of the rectangle is found with `r1.x` (left side) plus the width `r1.w` ([See Table Shorthand](about:blank/Guide/Tables#shorthand)).

```lua
--get sides out of rectangle table
r1.x         --left side
r1.x + r1.w  --right side
r1.y         --top side
r1.y + r1.h  --bottom side
```

Next, we want to compare the first rectangle's left and right sides with the second rectangle's right and left sides, and the first rectangle's top and bottom sides with the second rectangle's bottom and top sides. In expanded form, this check can be written as:

```lua
--compare r1 left with r2 right
if r1.x < r2.x+r2.w then ... end

--compare r1 right with r2 left
if r1.x+r1.w > r2.x then ... end

--compare r1 top with r2 bottom
if r1.y < r2.y+r2.h then ... end

--compare r1 bottom with r2 top
if r1.y+r1.h > r2.y then ... end
```

We can combine all of those checks at the same time using the [and operator](about:blank/Guide/OPERATORS#logical) because it is only when all four checks are true that we know the two rectangles are overlapping:

```lua
--compare all 4 sides
if  r1.x < r2.x+r2.w
and r1.x+r1.w > r2.x
and r1.y < r2.y+r2.h 
and r1.y+r1.h > r2.y then
 print( "rectangles are overlapping" )
end
```

###### Understanding an Expanded Version

Now that we have two rectangles with coordinates and dimensions, and we know how to compare all 4 sides of the rectangles, we can put it all together into an expanded function like this:

```lua
--expanded example
function rect_rect_collision( r1, r2 )
 if  r1.x < r2.x+r2.w
 and r1.x+r1.w > r2.x
 and r1.y < r2.y+r2.h 
 and r1.y+r1.h > r2.y then  
  return true
 else
  return false
 end
end
```

This function has [parameters](../Guide/ARGUMENTS) `(r1,r2)` and it is expecting those to be objects with X, Y, W, and H [keys](about:blank/Guide/TABLE#terms).

The function has one if statement that compares the opposite sides of the two rectangles. The `and` operator is used to make sure that all four of those checks are true before running the code inside: `return true`, which will send the value `true` back to where this function was called.

If any one of those checks is `false`, then the code after `else` will run instead, which will return the value `false`.

You can call this function in two ways to catch the returned true or false result:

```lua
--catch result in variable
is_colliding = rect_rect_collision( r1, r2 )

if is_colliding then
 print( "collided!" )
end
```

```lua
--directly inside of if statement
if rect_rect_collision( r1, r2 ) then
 print( "collided!" )
end
```

Note that these examples use the same [argument names and parameter names](../Guide/ARGUMENTS) just for the convenience of this tutorial, but to make the difference clear, this is how the parameters of the function still uses `(r1,r2)` but the arguments when calling the function could be any [object table](about:blank/Guide/create_tables#object) such as:

```lua
player = { x=10, y=20, w=8, h=8 }
enemy = { x=30, y=40, w=8, h=8 }

if rect_rect_collision( player, enemy ) then
 player_health = 0
end
```

#### (See more examples below in When to Use this?)

###### Understanding the Simplified Version

We can simplify and condense the expanded version down to a single line:

```lua
function rect_rect_collision( r1, r2 )
  return r1.x < r2.x+r2.w and r1.x+r1.w > r2.x and r1.y < r2.y+r2.h and r1.y+r1.h > r2.y
end
```

_(This is the same function as under the interactive demo, but we removed the new lines.)_

This works the exact same way as the expanded version because all the comparisons of the each side of the rectangles will result in either true or false the same way it does in an if statement. So we don't need the if statement at all.

The expanded function boils down to _"if all checks true, return true, and if any are false, return false"_ which is an unnecessary step to explicitly return true or false since what we want to return is the same as the final result of the four comparisons.

So we can just `return` the result of the comparisons immediately in a single step and it does the same thing.

### 2. When to Use this?

Rectangle to Rectangle Collision (or AABB Collision) is the most widely used form of collision detection in game development because of its simplicity and efficiency to know when two things of any size larger than a point are overlapping.

Most games simplify any complex shapes in their game to have rectangular hit boxes in order to make collision detection easy using this method. Here are some classic game examples and where they use rectangle to rectangle collision:

![](../resources/img/tutorials/collision/zelda.png)

### Legend of Zelda; Item Collection

![](../resources/img/tutorials/collision/megaman.png)

### Megaman; Moving Platforms

![](../resources/img/tutorials/collision/mario.png)

### Mario Bros; Enemies

![](../resources/img/tutorials/collision/bomberman.png)

### Bomberman; Explosion Attacks

![](../resources/img/tutorials/collision/StreetFighter.png)

### Street Fighter; Multiple Hitboxes

### 3. Game Dev Tip

Collision detection is often where a game **_feels_** good or bad. If your invisible rectangular hitbox leaves too much empty space, particularly at the corners, around your game object, then it could sometimes not even look like two things collided when this collision method says that they are. This is a frequent cause of player frustration and complaints.

![](../resources/img/tutorials/collision/collision_tip1.png)

In this example, the computer will say these fish collide and that could be game over.

So it is common to make the hitbox slightly smaller than the game object. This makes sure that the player will visually see the overlapping game objects, and sometimes even allow what looks like collision to pass undetected, which makes the game feel more relaxed and tolerant, which is appreciated by the player.

![](../resources/img/tutorials/collision/collision_tip2.png)

## Point to Circle

```lua
function point_circle_collision( p, c )
    local dx,dy = p.x-c.x, p.y-c.y
    return dx*dx + dy*dy <= c.r*c.r
end
```

  1. How it Works

###### Preparing Coordinates

First, we need an easy way to store the coordinates of both a point and a circle as well as the circle's size. We can do that with 2 [tables](../Guide/create_tables) that store separate X, Y, variables. For the size of the circle, we will save a radius `r`, which is the distance from the center of the circle to the outer edge. Those tables (named `p` for the point and `c` for the circle) are what the above function expects.

They could be created like this:

```lua
--create object tables
p = { x=10, y=20 }
c = { x=63, y=63, r=30 }
```

Now we have two points at their own coordinates of `X` and `Y`, and the second point will be the center of a circle with a size of `r`. Next we need to know how to get the values out of the tables. For example, to get the radius of the circle, we use `c.r` ([See Table Shorthand](about:blank/Guide/Tables#shorthand)).

```lua
--get values out of object table
print( c.r )   --prints 30
```

##### Understanding the Math

The good news is you don't _need_ to understand the details of how it works in order to use this collision function in your game. As long as you understand what you need to pass to the function and what you can expect to get returned, then you can simply trust that the math inside is working properly.

However, if you want to take more control over your code and customize how your game collision works, then understanding exactly how and why the math works the way it does is important. So we will break it down as best we can.

Overall, we want to get the distance between the point and the circle by using the coordinates of the point and the center point of the circle. We'll use some algebra and geometry here to figure out the distance. First we can easily find the difference between each point on each axis. Think of the center point of the circle at coordinates **( x1, y1 )** and the point at **( x2, y2 )**.

### x2 - x1 = horizontal difference

### y2 - y1 = vertical difference

![](../resources/img/tutorials/collision/2_points_pythagoras.gif)

We can do this with any 2 points, imagining them as part of a right triangle, and with just subtraction we get the lengths of 2 sides of that triangle. The 3rd side is the actual distance we want to figure out. Now that we have the lengths of 2 sides of a triangle, we can figure out the third side using the **Pythagorean Theorem**:

### c2 = a2 + b2

Basically it's just a rule about right triangles where the longest side equals the two shorter sides added together, but only when all three sides are multiplied by themselves ("squared").

We can expand that out to look like this:

### c×c = a×a + b×b

And this is how we would write it in code:

### `c*c = a*a + b*b`

###### Applying to our Point and Circle

Let's not get confused when we change from the math where we use **A B C** for the triangle sides above, back to code where we are using **P** and **C** for the point and the circle again. This is how we do the same but with our point and circle data.

|              |math   |code     |
|--------------|-------|---------|
|Difference X =|x2 - x1|p.x - c.x|
|Difference Y =|y2 - y1|p.y - c.y|

In code, we can do that math to get the length of the two smaller sides, and save them in variables named `dx` and `dy`.

```lua
--difference of points
dx = p.x - c.x
dy = p.y - c.y
```

The next step is to multiply those sides by themselves, remember:

### `c*c = a*a + b*b`

In the case of Point and Circle, the A is DX and the B is DY, so we want to do:

```lua
distance_squared = dx*dx + dy*dy
```

And now we could simply square root the result to find the distance:

```lua
distance = sqrt( distance_squared )
```

#### (PICO-8 has a built in math function for this: [`sqrt`](../Guide/SQRT))

After we get the distance between the two points, we just need to compare that with the radius of the circle. If the distance is shorter than the radius, then the point must be inside the circle!

![](../resources/img/tutorials/collision/distance_radius_collision.png)

Now that you understand the math of finding the distance and comparing it with the radius, play with the demo at the top of this page to see all the pieces come together.

###### Understanding an Expanded Version

We can combine all of the steps above into a single function, written out clearly to show each step:

```lua
function point_circle_collision( p, c )
  --get lengths of two sides; the differences
 local dx = p.x-c.x
 local dy = p.y-c.y

 --get length of 3rd side; the distance
 local distance_squared = dx*dx + dy*dy
 local distance = sqrt( distance_squared )

 --check if point is inside circle radius
 if distance <= c.r then
  return true
 else
  return false
 end
end
```

This function has [parameters](../Guide/ARGUMENTS) `(p,c)` and it is expecting those to be objects with X, and Y [keys](about:blank/Guide/TABLE#terms), with the circle also having an R key for radius.

Step 1: get the differences between the points on each axis, which creates an imaginary right triangle.

Step 2: get the distance of the third side of the triangle, the actual distance of the two points.

Step 3: compare the distance and the circle's radius

Step 4: return true if the distance is shorter than the radius or false if it is longer.

You can call this function in two ways to catch the returned true or false result:

```lua
--catch result in variable
is_colliding = point_circle_collision( p, c )

if is_colliding then
 print( "collided!" )
end
```

```lua
--directly inside of if statement
if point_circle_collision( p, c ) then
 print( "collided!" )
end
```

Note that these examples use the same [argument names and parameter names](../Guide/ARGUMENTS) just for the convenience of this tutorial, but to make the difference clear, this is how the parameters of the function still uses `(p,c)` but the arguments when calling the function could be any [object table](about:blank/Guide/create_tables#object) such as:

```lua
bullet = { x=10, y=20 }
shield = { x=30, y=40, r=8 }

if point_circle_collision( bullet, shield ) then
 player_health = 0
end
```

#### (See more examples below in When to Use this?)

###### Understanding the Simplified Version

We can simplify and condense the expanded version down to just two lines:

```lua
function point_circle_collision( p, c )
    local dx,dy = p.x-c.x, p.y-c.y
    return dx*dx + dy*dy <= c.r*c.r
end
```

This works the exact same way as the expanded version because all the steps of getting the distance and comparing it to the radius is happening here too.

The first way we condensed the code is what is called [multiple assignments](about:blank/Guide/VARIABLE#multiple). Where we assign more than one value to more than one variable on a single line. That way we assign `dx` and `dy` together on the first line of the function, separated by commas.

```lua
local dx,dy = p.x-c.x, p.y-c.y
```

The second trick we do to condense the code is to skip square rooting the distance. We do the math for finding the distance squared and immediately compare it with the circle's radius squared.

```lua
dx*dx + dy*dy <= c.r*c.r
```

 The final trick to condense it is to simply return the result of the math and the comparison, which lets us do all of that in a single line of code. It will do the math first, then compare those results, then `return` the comparison's result of `true` or `false`.

```lua
return dx*dx + dy*dy <= c.r*c.r
```

### 2. When to Use this?

Point to Circle Collision is not used that often because it is pretty specific. You need a circular game object and something small enough that you only care about a single point.

A classic game that immediately comes to mind is the circular character of Pacman who eats single pixel pellets.

![](../resources/img/tutorials/collision/pacman.png)

```lua
--init
pacman = { x=10, y=20, r=5 }
pellets = {} --empty table
add_pellets() --fills table with points

--update
for pellet in all( pellets ) do
 --collision check
 if point_circle_collision( pellet, pacman ) then
  score += 100
  del(pellet) --remove from game
 end
end
```

Sometimes you can simplify a larger sprite down to a single point near its center. Many bullet-hell shmups will do this where the ship looks big but the hitbox is only the tiny cockpit. So the cockpit could be the point and enemy bullets could be large circles.

Or the opposite, where the player has a circular energy shield, and the enemy bullets are just points.

![](../resources/img/tutorials/collision/shmup.png)

```lua
--init
ship = { x=10, y=20, r=5 }
shield = true
enemy_bullets = {} --empty table
add_enemy_bullets() --fills table with points

--update
for bullet in all( enemy_bullets ) do
 --collision check
 if shield then
  if point_circle_collision( bullet, ship ) then
   del(bullet) --remove from game
  end
 else
  if point_point_collision( bullet, ship ) then
   health -= 10
   del(bullet) --remove from game
  end
 end
end
```

#### Multiple Collision Check Example

This shows how you could use two different collision functions. If the shield is on, then it checks point\_circle\_collision(), but if the shield is off, then it checks point\_point\_collision() to see if the bullet hits the player cockpit instead and the player could lose health.

Another example of using Point to Circle Collision is when your game has a circular field of view and you want to determine if the player or other objects are within that space. That could be for creating fog-of-war in a strategy game, a camera's line-of-sight for a stealth game, or the light radius of a torch in an adventure game.

## Circle to Circle

PICO-8 Collision Function

```lua
function circle_circle_collision(c1, c2)
  local dx,dy,rsum = c2.x-c1.x, c2.y-c1.y, c1.r+c2.r
  return dx*dx+dy*dy <= rsum*rsum
end
```

### 1. How it Works

###### Preparing Coordinates

First, we need an easy way to store the coordinates of both circles as well as the circles' sizes. We can do that with 2 [tables](../Guide/create_tables) that store separate X, Y, and R (radius) variables. The radius is the distance from the center of the circle to the outer edge. Those tables ( we will name `c1` and `c2` ) are what the above function expects.

They could be created like this:

```lua
--create object tables
c1 = { x=10, y=20, r=20 }
c2 = { x=63, y=63, r=30 }
```

Now we have two points at their own coordinates of `X` and `Y`, which will be the center points of the circles, and the each circle has a size of `r`. Next we need to know how to get the values out of the tables. For example, to get the radius of the first circle, we use `c1.r` ([See Table Shorthand](about:blank/Guide/Tables#shorthand)).

```lua
--get values out of object table
print( c1.r )   --prints 20
```

##### Understanding the Math

The good news is you don't _need_ to understand the details of how it works in order to use this collision function in your game. As long as you understand what you need to pass to the function and what you can expect to get returned, then you can simply trust that the math inside is working properly.

However, if you want to take more control over your code and customize how your game collision works, then understanding exactly how and why the math works the way it does is important. So we will break it down as best we can.

Overall, we want to get the distance between the two center points by using the coordinates. We'll use some algebra and geometry here to figure out the distance. First we can easily find the difference between each point on each axis. Think of the center point of the circle `c1` at **( x1, y1 )** and `c2` at **( x2, y2 )**.

### x2 - x1 = horizontal difference

### y2 - y1 = vertical difference

![](../resources/img/tutorials/collision/2_points_pythagoras.gif)

We can do this with any 2 points, imagining them as part of a right triangle, and with just subtraction we get the lengths of 2 sides of that triangle. The 3rd side is the actual distance we want to figure out. Now that we have the lengths of 2 sides of a triangle, we can figure out the third side using the **Pythagorean Theorem**:

### c2 = a2 + b2

Basically it's just a rule about right triangles where the longest side equals the two shorter sides added together, but only when all three sides are multiplied by themselves ("squared").

We can expand that out to look like this:

### c×c = a×a + b×b

And this is how we would write it in code:

### `c*c = a*a + b*b`

###### Applying to our Circles

Let's not get confused when we change from the math where we use **A B C** for the triangle sides above, back to code where we are using **C1** and **C2** for the circles again. This is how we do the same but with our point and circle data.

|              |math   |code       |
|--------------|-------|-----------|
|Difference X =|x2 - x1|c2.x - c1.x|
|Difference Y =|y2 - y1|c2.y - c1.y|

In code, we can do that math to get the length of the two smaller sides, and save them in variables named `dx` and `dy`.

```lua
--difference of points
dx = c2.x - c1.x
dy = c2.y - c1.y
```

The next step is to multiply those sides by themselves, remember:

### `c*c = a*a + b*b`

Translating this to code, the A is DX and the B is DY, so we want to do:

```lua
distance_squared = dx*dx + dy*dy
```

And now we could simply square root the result to find the distance:

```lua
distance = sqrt( distance_squared )
```

#### (PICO-8 has a built in math function for this: [`sqrt`](../Guide/SQRT))

After we get the distance between the two points, we just need to compare that distance with the two radii of the circles. If the distance between their centers is shorter than the two radii added together, then the circles must be overlapping!

![](../resources/img/tutorials/collision/distance_radius_collision_2.png)

```lua
if distance <= c1.r + c2.r then
 print( "circles are overlapping!" )
end
```

Now that you understand the math of finding the distance and comparing it with the two radii, play with the demo at the top of this page to see all the pieces come together.

###### Understanding an Expanded Version

We can combine all of the steps above into a single function, written out clearly to show each step:

```lua
function circle_circle_collision( c1, c2 )
 --get the differences
 local dx = c2.x-c1.x
 local dy = c2.y-c1.y

 --get the distance
 local distance_squared = dx*dx + dy*dy
 local distance = sqrt( distance_squared )

 --get the sum of radii
 local rsum = c1.r + c2.r

 --compare distance with radii
 if distance <= rsum then
  return true
 else
  return false
 end
end
```

This function has [parameters](../Guide/ARGUMENTS) `(c1,c2)` and it is expecting those to be objects with X, Y, and R [keys](about:blank/Guide/TABLE#terms).

Step 1: get the differences between the center points on each axis, which creates an imaginary right triangle.

Step 2: get the distance of the third side of the triangle, the actual distance of the two points.

Step 3: compare the distance and the circles' radii added together (their sum).

Step 4: return true if the distance is shorter than the sum of the two radii or false if it is longer.

You can call this function in two ways to catch the returned true or false result:

```lua
--catch result in variable
is_colliding = circle_circle_collision( c1, c2 )

if is_colliding then
 print( "collided!" )
end
```

```lua
--directly inside of if statement
if circle_circle_collision( c1, c2 ) then
 print( "collided!" )
end
```

Note that these examples use the same [argument names and parameter names](../Guide/ARGUMENTS) just for the convenience of this tutorial, but to make the difference clear, this is how the parameters of the function still uses `(c1,c2)` but the arguments when calling the function could be any [object table](about:blank/Guide/create_tables#object) such as in a pool/billiards/snooker game:

```lua
--init
cue_ball = { x=10, y=20 }
balls = {}
add_balls() --creates billiard balls

--update
for ball in all(balls) do
 if circle_circle_collision( cue_ball, ball ) then
  --apply bounce physics
 end
end
```

#### (See more examples below in When to Use this?)

###### Understanding the Simplified Version

We can simplify and condense the expanded version down to just two lines:

```lua
function circle_circle_collision(c1, c2)
  local dx,dy,rsum = c2.x-c1.x, c2.y-c1.y, c1.r+c2.r
  return dx*dx+dy*dy <= rsum*rsum
end
```

This works the exact same way as the expanded version because all the steps of getting the distance and comparing it to the sum of the radii is happening here too.

The first way we condensed the code is what is called [multiple assignments](about:blank/Guide/VARIABLE#multiple). Where we assign more than one value to more than one variable on a single line. That way we assign `dx`, `dy`, and `rsum` together on the first line of the function, separated by commas.

```lua
local dx,dy,rsum = c2.x-c1.x, c2.y-c1.y, c1.r+c2.r
```

The second trick we do to condense the code is to skip saving the distance squared in a variable and then having to square root that to get the distance in another variable. Instead, we do the math for finding the distance squared and immediately compare it with the sum of the circles' radii squared.

```lua
dx*dx+dy*dy <= rsum*rsum
```

 The final trick to condense it is to simply return the result of the comparison (if the distance squared **is less than or equal to** the sum of the radii squared), which lets us do all of that in a single line of code. It will do the math first, then compare the two results, then `return` the comparison's result of `true` or `false`.

```lua
return dx*dx+dy*dy <= rsum*rsum
```

### 2. When to Use this?

Circle to Circle Collision is used quite often, obviously when circular game objects are used like balls, rings, hoops, etc, but you might be surprised that it comes in handy even for: non-circular objects; fields of view; or gravity, magnetic, or electric fields; swings and chains, and more. Here are some examples:

![](../resources/img/tutorials/collision/pool.png)

Billiards / Pool / Snooker games want to recreate realistic physics with the way the balls bounce off of each other and the sides. Getting this right is really important to the feel of the game. Other sports games such as football (soccer) could have both the ball and the players as circular objects, and the goals rectangular. Pinball is another similar example, where the ball collides with circular bouncers or pins in the middle of the table.

![](../resources/img/tutorials/collision/agar.png)

![](../resources/img/tutorials/collision/planets.png)

Planetary space games like this may have visible or invisible circular bounds much larger than the planets themselves where their gravity will affect each other. You may even be a tiny ship trying to navigate through all these circle colliders trying not to get pulled in toward the centers where there can be a second smaller circle collider that means destruction. It doesn't have to be space themed either, this idea also applies to games using magnets or electrical fields too.

![](../resources/img/tutorials/collision/bustamove.png)

The classics Bust-a-Move and Bubble Bobble both use circular colorful bubbles or marbles that bounce around the screen and interact with each other. Although the objects are all circular and use Circle to Circle collision when moving freely, they also align the bubbles to a grid that is traditionally rectangular or a modern version may use hexagonal grid to stick the bubbles diagonally like this mockup. The point is, collision systems can be a complex mix of shapes that interact and align your game objects the way you want them.

### 3. Game Dev Tip

Sometimes you'll have a game where it looks like it should use rectangles for hitboxes and collision, but circles could actually look and feel even better. Here is an example of rectangular sprites in our made-up zombie top-down game.

This mockup (below and on the left) doesn't look bad at all, with the zombies spaced out according to their rectangular hitboxes that cover their entire sprite. This is simple to do in code since both the sprite and the collision hitboxes use the same X, Y, W, H variables. But once you notice that the zombies bump in to each other awkwardly, and keep a perfect distance from each other, you won't be able to unsee it, and the game will just feel "off" somehow.

![](../resources/img/tutorials/collision/zombies_square_compared.png)

On the other hand, we could change the zombies and player to use circular collision bounds instead, where the lower half of the body is outside of the circle. This allows the zombies to get closer together, bump into each other better, overlap their lower halves, and slide around each other easier. All of that helps the game look and feel more natural and realistic to the player.

![](../resources/img/tutorials/collision/zombies_circle_compared.png)