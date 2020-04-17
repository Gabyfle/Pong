--[--[--------------------]--]--
-- Project: Pong              --
-- File: player.lua           --
--                            --
-- Author: Gabyfle            --
-- License: Apache 2.0        --
--]--]--------------------[--[--

local player = {
    width = 15,
    height = 100,
    color = { 1, 1, 0, 100 },
    y = 250
}

--- Player initialization
function player:init()
    self.y = 300 - self.height * 0.5
end

local MAX = 300 - player.height -- Maximum y
local MIN = 0

--- Updates a player's ordinate
-- @param string ply: Player's name
function player:update(y)
    if y > MAX then
        self.y = MAX
    elseif y < MIN then
        self.y = MIN
    else
        self.y = y
    end
end

return player
