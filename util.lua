function generateQuads(atlas, tile_width, tile_height)
    -- tile_width and getWidth are both in pixels, so sheet_width counts # of tiles
    local sheet_width = atlas:getWidth() / tile_width
    local sheet_height = atlas:getHeight() / tile_height

    local sheet_counter = 1 -- in Lua, arrays increment starting at 1
    local quads = {}

    -- however, pixels still increment starting at 0
    for y = 0, sheet_height - 1 do
        for x = 0, sheet_width - 1 do
            quads[sheet_counter] = love.graphics.newQuad(x * tile_width, y * tile_height,
                tile_width, tile_height, atlas:getDimensions())
            sheet_counter = sheet_counter + 1
        end
    end

    return quads
end