require 'Player'
Map = Class{}

-- grid values based on graphics/spritesheet.png
TILE_BRICK = 1
TILE_EMPTY = 4
CLOUD_LEFT = 6
CLOUD_RIGHT = 7
BUSH_LEFT = 2
BUSH_RIGHT = 3
PILLAR_TOP = 10
PILLAR_BOTTOM = 11
JUMP_BLOCK = 5
JUMP_BLOCK_HIT = 9

local SCROLL_SPEED = 62

function Map:init()
    self.spritesheet = love.graphics.newImage('graphics/spritesheet.png')
    self.tile_width = 16
    self.tile_height = 16
    self.map_width = 30 -- how many tiles wide the map is
    self.map_height = 28 -- how many tiles high the map is
    self.map_width_pixels = self.map_width * self.tile_width -- how many pixels wide the map is
    self.map_height_pixels = self.map_height * self.tile_height -- how many pixels high the map is
    --[[note: the tile width/height values were arbitrarily selected and actually exceed the bounds
        of the initial screen window]]

    self.camera_x = 0
    self.camera_y = 0

    self.music = love.audio.newSource('sounds/blue_alien_loop.wav', 'static')

    self.player = Player(self)

    --[[
        self.tile_sprites contains the actual graphical 'quads', while self.tiles contains
        integers serving as indices for self.tile_sprites. Each entry in self.tiles
        corresponds to a tile position on the screen, starting in the top left corner and
        moving right along a row before jumping down to the next row.
    ]]
    self.tiles = {}
    self.tile_sprites = generateQuads(self.spritesheet, self.tile_width, self.tile_height)

    -- fills the first half of self.tiles with TILE_EMPTY
    for y = 1, self.map_height/2 do
        for x = 1, self.map_width do
            self:setTile(x, y, TILE_EMPTY)
        end
    end

    local x = 1
    while x < self.map_width do

        -- Cloud generation
        if x < (self.map_width-2) then -- at least two tiles away from right edge
            if math.random(20)==1 then -- 5% chance
                local cloud_height = math.random(self.map_height/2 - 6)
                self:setTile(x, cloud_height, CLOUD_LEFT)
                self:setTile(x+1, cloud_height, CLOUD_RIGHT)
            end
        end

        -- Pillar generation
        if math.random(20)==1 then -- 5% chance
            self:setTile(x, self.map_height/2 - 2, PILLAR_TOP)
            self:setTile(x, self.map_height/2 - 1, PILLAR_BOTTOM)

            for y = self.map_height/2, self.map_height do
                self:setTile(x, y, TILE_BRICK)
            end

            x = x + 1 -- iterate to next vertical scan line
        
        -- Bush generation
        elseif math.random(10)==1 and x < (self.map_width - 3) then -- 10% chance
            local bush_height = self.map_height/2 - 1
            self:setTile(x, bush_height, BUSH_LEFT)
            for y = self.map_height/2, self.map_height do
                self:setTile(x, y, TILE_BRICK)
            end
            x = x + 1

            self:setTile(x, bush_height, BUSH_RIGHT)
            for y = self.map_height/2, self.map_height do
                self:setTile(x, y, TILE_BRICK)
            end
            x = x + 1
        
        -- Jump block generation (only possible if no other items generated in that column)
        elseif math.random(10) ~= 1 then
            for y = self.map_height/2, self.map_height do
                self:setTile(x, y, TILE_BRICK)
            end

            if math.random(15)==1 then
                self:setTile(x, self.map_height/2 - 4, JUMP_BLOCK)
            end
            
            x = x + 1
            
        else
            x = x + 2
        end
    end

    -- fills the second half of self.tiles with TILE_BRICK
    --[[ note that since self.map_height well exceeds the bounds of the screen,
        self.map_height/2 is actually already near the bottom of the screen, so the
        brick tiles appear starting near the bottom of the screen. ]]
    for y = self.map_height/2, self.map_height do
        for x = 1, self.map_width do
            self:setTile(x, y, TILE_BRICK)
        end
    end

    self.music:setLooping(true)
    self.music:play()
end

-- Here, x and y are pixel coordinates
function Map:tile_at_coordinates(x, y)
    return self:getTile(math.floor(x/self.tile_width)+1, math.floor(y/self.tile_height)+1)
end

-- Here, x and y are tile coordinates
function Map:setTile(x, y, tile)
    self.tiles[(y-1)*self.map_width + x] = tile
end

-- Here, x and y are tile coordinates
function Map:getTile(x, y)
    return self.tiles[(y-1)*self.map_width + x]
end

function Map:collides(tile)
    local collidables = {
        TILE_BRICK, JUMP_BLOCK, JUMP_BLOCK_HIT, PILLAR_TOP, PILLAR_BOTTOM
    }

    for _, v in ipairs(collidables) do
        if tile == v then
            return true
        end
    end
    
    return false
end

function Map:update(dt)
    --[[ As with Pong, the order of the if statements means that certain keys can override
        the others, but not vice-versa. E.g. 'up' overrides all the others while 'right'
        cannot override any. ]]
    --[[
    if love.keyboard.isDown('up') then
        self.camera_y = math.max(0, self.camera_y - SCROLL_SPEED*dt)
    elseif love.keyboard.isDown('down') then
        self.camera_y = math.min(self.map_height_pixels - VIRTUAL_HEIGHT, self.camera_y + SCROLL_SPEED*dt)
    elseif love.keyboard.isDown('left') then
        self.camera_x = math.max(0, self.camera_x - SCROLL_SPEED*dt)
    elseif love.keyboard.isDown('right') then
        self.camera_x = math.min(self.map_width_pixels - VIRTUAL_WIDTH, self.camera_x + SCROLL_SPEED*dt)
    end ]]

    self.camera_x = math.max(0,
        math.min(self.player.x - (VIRTUAL_WIDTH/2),
            math.min(self.map_width_pixels - VIRTUAL_WIDTH, self.player.x)))

    self.player:update(dt)
end

function Map:render()
    for y = 1, self.map_height do
        for x = 1, self.map_width do
            love.graphics.draw(self.spritesheet, self.tile_sprites[self:getTile(x, y)],
                (x-1)*self.tile_width, (y-1)*self.tile_height)
        end
    end

    self.player:render()
end