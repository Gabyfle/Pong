--[--[--------------------]--]--
-- Project: Pong              --
-- File: player.lua           --
--                            --
-- Author: Gabyfle            --
-- License: Apache 2.0        --
--]--]--------------------[--[--
package.path = '../?.lua;' .. package.path

local config = require('config')

local player = {
    width = 15,
    height = 100,
    color = { 1, 1, 0, 100 },
    here = { -- local player ordinate
        y = 250
    },
    online = { -- other player ordinate
        y = 250
    }
}

--- Initialization of the players
function player:init()
    self.here.y = 250
    self.online.y = 250
end

--- Returns the current player's position
-- @param string ply: name of the player to get the position
-- @return number: player's position on the y-axis
function player:getpos(ply)
    if not self[ply] then return end

    return self[ply].y
end

--- Moves a certain player to the y position on the y-axis
-- @param string ply: which player has to move
-- @param number y: coordinate to move the player
function player:move(ply, y)
    if not self[ply] then return end

    self[ply].y = y
end

--- Adds y to a player position
-- @param string ply: name of the player
-- @param number y: amount to add on the y-axis
function player:add(ply, y)
    if not self[ply] then return end
    local MAX = 500 -- Maximum y
    local MIN = 0

    if self[ply].y + y > MAX then
        self[ply].y = MAX
    elseif self[ply].y + y < MIN then
        self[ply].y = MIN
    else
        self[ply].y = self[ply].y + y
    end
end

function player:draw(x, y)
    love.graphics.setColor(player.color)
    love.graphics.rectangle("fill", x, y, player.width, player.height)
end

return player
