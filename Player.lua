require 'Animation'
Player = Class{}

local MOVE_SPEED = 80
local JUMP_VELOCITY = 400
local GRAVITY = 40

function Player:init(map)
    self.width = 16
    self.height = 20 -- slightly higher than tile size of map

    self.x = map.tile_width * 10 -- 10 tiles to right of screen
    self.y = map.tile_height * (map.map_height/2 - 1) - self.height

    self.dx = 0
    self.dy = 0

    self.texture = love.graphics.newImage('graphics/blue_alien.png')
    self.frames = generateQuads(self.texture, self.width, self.height)

    self.state = 'idle'
    self.direction = 'right'

    self.animations = {
        --[[ 
            Even though Animation:init() is a function, we don't need parentheses around the curly
            brackets here. This is because in Lua, if a function only has one argument and it's
            a table, then as a shorthand you can skip the () and go straight to the {}.
        ]]
        ['idle'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[1]
            }
        },
        ['walking'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[9], self.frames[10], self.frames[11]
            },
            interval = 0.15
        },
        ['jumping'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[3]
            }
        }
    }

    self.current_animation = self.animations['idle']


    -- Currently 'idle' and 'walking' are exactly the same lol
    self.behaviors = {
        ['idle'] = function(dt)
            if love.keyboard.was_pressed('space') then
                self.dy = -JUMP_VELOCITY
                self.state = 'jumping'
                self.current_animation = self.animations['jumping']
            elseif love.keyboard.isDown('left') then
                self.dx = -MOVE_SPEED
                self.current_animation = self.animations['walking']
                self.direction = 'left'
            elseif love.keyboard.isDown('right') then
                self.dx = MOVE_SPEED
                self.current_animation = self.animations['walking']
                self.direction = 'right'
            else
                self.current_animation = self.animations['idle']
                self.dx = 0
            end

            self:check_left_collision()
            self:check_right_collision()

            if not map:collides(map:tile_at_coordinates(self.x, self.y + self.height)) and
                not map:collides(map:tile_at_coordinates(self.x + self.width - 1, self.y + self.height)) then
                self.state = 'jumping'
                self.current_animation = self.animations['jumping']
            end
        end,
        ['walking'] = function(dt)
            if love.keyboard.was_pressed('space') then
                self.dy = -JUMP_VELOCITY
                self.state = 'jumping'
                self.current_animation = self.animations['jumping']
            elseif love.keyboard.isDown('left') then
                self.dx = -MOVE_SPEED
                self.current_animation = self.animations['walking']
                self.direction = 'left'
            elseif love.keyboard.isDown('right') then
                self.dx = MOVE_SPEED
                self.current_animation = self.animations['walking']
                self.direction = 'right'
            else
                self.current_animation = self.animations['idle']
                self.dx = 0
            end

            self:check_left_collision()
            self:check_right_collision()

            if not map:collides(map:tile_at_coordinates(self.x, self.y + self.height)) and
                not map:collides(map:tile_at_coordinates(self.x + self.width - 1, self.y + self.height)) then
                self.state = 'jumping'
                self.current_animation = self.animations['jumping']
            end
        end,
        ['jumping'] = function(dt)
            if love.keyboard.isDown('left') then
                self.direction = 'left'
                self.dx = -MOVE_SPEED
            elseif love.keyboard.isDown('right') then
                self.direction = 'right'
                self.dx = MOVE_SPEED
            else
                self.dx = 0
            end

            self.dy = self.dy + GRAVITY

            if map:collides(map:tile_at_coordinates(self.x, self.y + self.height)) or
                map:collides(map:tile_at_coordinates(self.x + self.width - 1, self.y + self.height)) then
                self.dy = 0
                self.state = 'idle'
                self.current_animation = self.animations['idle']
                self.y = math.floor((self.y+self.height)/map.tile_height) * map.tile_height - self.height
            end

            self:check_left_collision()
            self:check_right_collision()

            --[[
            if self.y >= map.tile_height * (map.map_height/2 - 1) - self.height then
                self.y = map.tile_height * (map.map_height/2 - 1) - self.height
                self.dy = 0
                self.state = 'idle'
                self.current_animation = self.animations[self.state]
            end ]]
        end
    }
end

function Player:update(dt)
    self.behaviors[self.state](dt)
    self.current_animation:update(dt)
    self.current_frame = self.current_animation:get_current_frame()
    self.x = self.x + self.dx*dt

    if self.dy<0 then
        if map:tile_at_coordinates(self.x, self.y) == JUMP_BLOCK or
            map:tile_at_coordinates(self.x + self.width - 1, self.y) == JUMP_BLOCK or 
            map:tile_at_coordinates(self.x, self.y) == JUMP_BLOCK_HIT or
            map:tile_at_coordinates(self.x + self.width - 1, self.y) == JUMP_BLOCK_HIT then
            self.dy = 0

            if map:tile_at_coordinates(self.x, self.y) == JUMP_BLOCK then
                map:setTile(math.floor(self.x/map.tile_width) + 1,
                math.floor(self.y/map.tile_height) + 1, JUMP_BLOCK_HIT)
            end
            if map:tile_at_coordinates(self.x + self.width - 1, self.y) == JUMP_BLOCK then
                map:setTile(math.floor((self.x + self.width - 1)/map.tile_width) + 1,
                math.floor(self.y/map.tile_height) + 1, JUMP_BLOCK_HIT)
            end
        end
    end

    --self.y = math.min(self.y + self.dy*dt,
        --map.tile_height * ((map.map_height-2) / 2) - self.height)
    
    self.y = self.y + self.dy*dt
end

function Player:check_left_collision()
    if self.dx < 0 then
        if map:collides(map:tile_at_coordinates(self.x-1, self.y)) or
            map:collides(map:tile_at_coordinates(self.x-1, self.y + self.height - 1)) then
            self.dx = 0
            --self.x = (math.floor(self.x/map.tile_width) + 1) * map.tile_width
        end
    end
end

function Player:check_right_collision()
    if self.dx > 0 then
        if map:collides(map:tile_at_coordinates(self.x+self.width, self.y)) or
            map:collides(map:tile_at_coordinates(self.x+self.width, self.y + self.height - 1)) then
            self.dx = 0
            --self.x = (math.floor(self.x/map.tile_width)) * map.tile_width
        end
    end
end

function Player:render()

    local scale_x

    if self.direction=='right' then
        scale_x = 1
    else
        scale_x = -1
    end

    love.graphics.draw(self.texture, self.current_animation:get_current_frame(),
        math.floor(self.x + (self.width/2)), math.floor(self.y + (self.height/2)),
        0, scale_x, 1, self.width/2, self.height/2)
        --[[
            Parameters on bottom row are ([rotation], [x_stretch factor], [y_stretch factor],
                [x origin point], [y origin point]).
            
            Stretch factors stretch/shrink the image by the specified factor.
            A factor of -1 results in a flipped image.
            
            By default, origin points of image are (0, 0), or the top left corner, and so any
            stretching is applied to that origin point. So if the x_stretch factor is -1, the
            image will flip over its (0, 0) origin, as if attached to a door hinge. Artificially
            moving the origin to the image's center causes the image to flip in place instead.
        ]]
end