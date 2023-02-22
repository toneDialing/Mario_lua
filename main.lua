Class = require 'class'
push = require 'push'

require 'util'
require 'Map'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

function love.load()
    math.randomseed(os.time())

    map = Map()

    love.graphics.setDefaultFilter('nearest', 'nearest')

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true,
        highdpi = false
    })

    --[[
        In Lua, you can add arbitrary values (e.g. 'keysPressed') to existing name spaces
        (e.g. 'keyboard').
    ]]
    love.keyboard.keysPressed = {} 
end

-- Called whenever a specified key is pressed
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    -- adds a new 'key' value to the table keysPressed and marks it as true
    -- this effectively keeps track of any key that is ever pressed
    love.keyboard.keysPressed[key] = true
end

-- Returns true or false depending on whether the key was pressed
function love.keyboard.was_pressed(key)
    return love.keyboard.keysPressed[key]
end

function love.update(dt)
    map:update(dt)

    -- resets the keysPressed table to null after every update
    love.keyboard.keysPressed = {}
end

function love.draw()
    push:apply('start')

    love.graphics.translate(math.floor(-map.camera_x + 0.5), math.floor(-map.camera_y + 0.5))

    love.graphics.clear(108/255, 140/255, 255/255, 255/255)
    map:render()

    push:apply('end')
end