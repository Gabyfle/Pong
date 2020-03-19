-- FONTS handler
fonts = {
    fonts = {} -- contains all the fonts
}

--- Loads a new font from /fonts/ path
function fonts:loadFont(name)
    if not type(name) == 'string' then 
        love.errorhandler("Font name should be a string")
        return false
    end
    fontPath = "fonts/" .. name ".ttf"
    self.fonts[name] = love.graphics.newFont(fontPath, 12)
end

function fonts:getFont(name)
    if self.fonts[name] then
        return self.fonts[name]
    else
        love.errorhandler("WTF are you doing bro, I don't know this font.")
    end
end