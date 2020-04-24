--[--[--------------------]--]--
-- Project: Pong              --
-- File: player.lua           --
--                            --
-- Author: Gabyfle            --
-- License: Apache 2.0        --
--]--]--------------------[--[--
local MAX = 500 -- Maximum y
local MIN = 0

local player = {
    --- Game parameters
    width = 15,
    height = 100,
    y = 250,
    --- Client identification parameters
    client = {
        key = nil,
        ip = nil,
        port = nil,
        last = nil
    }
}
player.__index = player
player.__metatable = player

--- Player constructor
-- @param string ip: Player's IP
-- @param number port: Player's PORT
-- @return table: A player table
function player:new(key, ip, port)
    local ply = {}
    setmetatable(ply, self)

    ply.client.key = key
    ply.client.ip = ip
    ply.client.port = port

    return ply
end

--- Binary operator +
-- @param table player: player to add height
-- @param number height
function player:__add(height)
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
function player:__len()
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

return player
