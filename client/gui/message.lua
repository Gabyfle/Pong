--[--[--------------------]--]--
-- Project: Pong              --
-- File: message.lua          --
--                            --
-- Author: Gabyfle            --
-- License: Apache 2.0        --
--]--]--------------------[--[--
local message = {
    messages = {}
}

--- Adds a message to draw in the next frame and during a certain time
-- @param string uname: unique name
-- @param number time: time in second to display the message
-- @param string text: text of the message to display
-- @param number x: amount to add the the x axis
-- @param number y: amount to add the the y axis
function message:draw(uname, time, text, color, x, y)
    if self.messages[uname] then return end -- the message already exists
    self.messages[uname] = {
        text = text,
        color = color,
        created = os.time(),
        time = (time or 0),
        x = (x or 0),
        y = (y or 0)
    }
end

--- Deletes a message from the messages list
-- @param string uname : unique name
function message:delete(uname)
    if not self.messages[uname] then return end
    self.messages[uname] = nil
end

--- Internal function that draws all the messages to the screen
function message:_draw()
    local scrW, scrH = love.graphics.getDimensions()
    local defaultFont = love.graphics.getFont()
    for k, msg in pairs(self.messages) do
        if not (os.difftime(os.time(), msg.created) > msg.time) or msg.time == 0 then
            love.graphics.setColor(msg.color)
            love.graphics.printf(msg.text, (scrW - defaultFont:getHeight()) / 2 + msg.x, scrH / 8 + msg.y, scrW / 2, 'center')
        else
            self:delete(k)
        end
    end
end

return message
