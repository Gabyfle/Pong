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
    key = nil,
    ip = nil,
    port = nil,
    last = nil
}
player.__index = player

--- Player constructor
-- @param string ip: Player's IP
-- @param number port: Player's PORT
-- @return table: A player table
function player:new(key, ip, port)
    local ply = {}
    setmetatable(ply, self)

    ply.key = key
    ply.ip = ip
    ply.port = port

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
    return self.key
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
    if name == 'key' then
        return self.key
    elseif name == 'ip' then
        return self.ip
    elseif name == 'port' then
        return self.port
    elseif name == 'last' then
        return self.last
    else
        return nil
    end
end

--- Sets a value to player[name]
-- @param string name: name of the parameter to set
-- @param any value: value to set
function player:set(name, value)
    if name == 'key' then
        self.key = value
    elseif name == 'ip' then
        self.ip = value
    elseif name == 'port' then
        self.port = value
    elseif name == 'last' then
        self.last = value
    else
        return nil
    end
end

return setmetatable(player, player)
