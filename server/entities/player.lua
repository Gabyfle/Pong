--[--[--------------------]--]--
-- Project: Pong              --
-- File: player.lua           --
--                            --
-- Author: Gabyfle            --
-- License: Apache 2.0        --
--]--]--------------------[--[--
local MAX = 500 -- Maximum y
local MIN = 0

local player = {}

player.__index = player

--- Player constructor
-- @param string ip: Player's IP
-- @param number port: Player's PORT
-- @return table: A player table
function player:new(key, ip, port)
    local ply = {}
    setmetatable(ply, self)

    ply.width = 15
    ply.height = 100
    ply.y = 250

    ply.client = {}

    ply.client.key = key
    ply.client.ip = ip
    ply.client.port = port

    return ply
end

--- Adds some height to the player
-- @param table player: player to add height
-- @param number height
function player:add(height)
    if not type(height) == 'number' then return end
    if (self.y + height > MAX) then
        self.y = MAX
    elseif (self.y + height < MIN) then
        self.y = MIN
    else
        self.y = self.y + height
    end

    return self
end

--- To string operator : returns player's key
-- @param table player
-- @return string: player's authentification key
function player:__tostring()
    return self.client.key
end

--- Unary operator # : returns the height of the player
-- @param table player
-- @return number: player's height
function player:getHeight()
    return self.y
end

--- Returns the data called name
-- @param string name: name of the data to return
-- @return any
function player:get(name)
    return self.client[name]
end

--- Sets a value to player[name]
-- @param string name: name of the parameter to set
-- @param any value: value to set
function player:set(name, value)
    self.client[name] = value
end

return setmetatable(player, player)
