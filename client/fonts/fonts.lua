--[--[--------------------]--]--
-- Project: Pong              --
-- File: fonts.lua            --
--                            --
-- Author: Gabyfle            --
-- License: Apache 2.0        --
--]--]--------------------[--[--

local fonts = {
    fonts = {} -- contains all the fonts
}

--- Loads a new font from /fonts/ path
function fonts:loadFont(name, size)
    if not type(name) == 'string' then 
        love.errorhandler("Font name should be a string")
        return false
    elseif not type(size) == 'number' then
        love.errorhandler("Font size should be a number")
        return false
    end

    local font_path = "fonts/" .. name .. ".ttf"
    self.fonts[name] = love.graphics.newFont(font_path, size)
end

-- Get a font from the fonts list
function fonts:getFont(name)
    if self.fonts[name] then
        return self.fonts[name]
    else
        debug.debug()
        for i in pairs(self.fonts) do
            print(i)
        end
    end
end

return fonts
