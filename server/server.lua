--[--[--------------------]--]--
-- Project: Pong              --
-- File: server.lua           --
--                            --
-- Author: Gabyfle            --
-- License: Apache 2.0        --
--]--]--------------------[--[--
package.path = '../shared/libs/?.lua;' .. package.path

local config  = require('config')
local socket  = require('socket')
local json    = require('json')
local players, serv = dofile('objects.lua')

local player  = require('entities.player')

-- Generating a random seed for Players' connexion key
math.randomseed(os.time())

-- SERVER CONSTANT
local KNOWN_ACTIONS =
{
    ['ping'] = true,
    ['move'] = true
}

-- START | CODE from http://lua-users.org/wiki/CopyTable
local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
-- END | CODE from http://lua-users.org/wiki/CopyTable

--- Generates a random string
-- @return string: the randomly generated string
local function randomString()
    local prohibed = {
        ['"'] = true,
        ['\\'] = true,
        ['\t'] = true
    }
    local string = ''
    for i = 1, 16 do
        local char = math.random(33, 126)
        while prohibed[string.char(char)] do
            char = math.random(33, 126)
        end
        string = string .. string.char(char)
    end

    return string
end

local server = {}

--- Server initialization
-- @param number port
function server:init(port)
    self._serv = serv(port)
    -- Players stuff
    self._serv:log('Setting up various yet useless but usefull stuff...')
    self._players = players()
end

--- Register a couple of (ip, port) as a client
-- @param number ip: Client IP
-- @param number port: Client PORT
function server:register(ip, port)
    if #self._players >= 2 then
        self._serv:log('A client with IP: %s tried to connect on the server but we were already 2!', ip)
        -- inform the client that this server is full
        local register = [[{"action": "register", "data": {"key": "full"}}]]
        self:sendTo(ip, port, register)
        return
    end

    self._serv:log('A client connected with IP: %s and PORT: %s!', ip, port)

    local key = randomString() -- this is the player's unique name

    self._players = self._players + player:new(key, ip, port) -- adds a new player to the players table
    local registered = string.format([[{"action": "register", "data":{"key": "%s"}}]], key)

    self:sendToPlayer(self._players:getPlayer(key), registered)
end

--- Execute a particular action on player ply
-- @param string action: action to execute
-- @param table ply: player to execute the action on or IP to register
-- @param table data: a table containing the received data
function server:execute(action, ply, data)
    if not KNOWN_ACTIONS[action] then
        self._serv:log('Someone tried to launch an unknown action called %s', action)
    end
    if not ply then return end
    if not data then return end -- no data to use

    if action == 'move' then
        if not data['key'] then return end -- maybe the data is corrupted so abort

        if data['key'] == 'up' then
            ply = ply + 1
        elseif data['key'] == 'down' then
            ply = ply + (-1)
        end

        -- get the other player's data to send him the position of this player
        local otherPly = self._players:getOtherPlayer(tostring(ply))
        self:sendTo(otherPly, string.format('[[{"action": "players", "data":{"online": %d, "here": %d}}]]', #ply, #otherPly))
    elseif action == 'ping' then
        if data['status'] and data['status'] == 'waiting' then
            self:sendToPlayer(ply, [[{"action": "ping","data": {"status": "ok"}}]])
        end
    end
end

--- Launched when a player timed out, disconnect him
-- @param table ply: player's authentification key
function server:timedout(ply)
    self._serv:log('Player with IP: %s and key: %s has been disconnected', ply:get('ip'), ply:get('key'))
    self._players = self._players - self._players:getPlayer(ply)
end

--- When the server receive data from a player, decode it and then update stuff from it
function server:receive()
    local data, ip, port = self._serv:receive()
    if data then
        local status, data = pcall(function()
            return json.decode(love.data.decompress('string', 'lz4', data))
        end)
        if not status then
            self._serv:log('Something wrong happened with the data. Client IP: %s', data or 'can\'t get error message')
            return
        end
        if #self._players < 2 and data['action'] == 'register' and not (data['key'] and self._players:getPlayer(data['key'])) then
            self:register(ip, port)
        else
            if not (data['key'] and self._players:getPlayer(data['key'])) then
                self._serv:log('A client tried to connect on server with IP: %s and PORT: %s', ip, port)
                self._serv:log('Actually, he didn\'t send any registered key, so I just rejected him!')
                return
            end
            local ply, action = self._players:getPlayer(data['key']), data['action']
            ply:set('last', os.time())
            if not (action and KNOWN_ACTIONS[action]) then
                self._serv:log('Player %s sent an unknown action: %s', self._serv.log, ply, action)
            else
                server:execute(action, ply, data['data'])
            end
        end
    elseif ip ~= 'timeout' then
        error('A fatal error occurred while receiving package from a client. Error: ' .. tostring(ip))
    end
end

--- Server's main loop
function server:run()
    self._serv:log('Your Pong server is now running.')
    while true do
        for id, ply in pairs(self._players:getPlayers()) do
            if ply:get('last') then
                local delay = os.difftime(os.time(), ply:get('last'))
                if delay > config.MAX_DELAY - 15 and delay < config.MAX_DELAY - 5 then
                    self:sendToPlayer(ply, [[{"action": "ping","data": {"status": "waiting"}}]])
                elseif delay > config.MAX_DELAY then
                    self._serv:log('Player %s has exceeded the maximum unanswered time (%d).', id, config.MAX_DELAY)
                    self:timedout(ply)
                end
            end
        end
        self:receive()
        socket.sleep(0.001)
    end
end

--- Sends a piece of data to a particular player
-- @param table ply: the player to send the data on
-- @param binary string data: the serialized data encoded in json
function server:sendToPlayer(ply, data)
    local status, err = pcall(function ()
        return self._serv:send(ply:get('ip'), ply:get('port'), data)
    end)
    if not status then
        self._serv:log('An error happened while trying to send data to player : %s. Error : %s', ply:get('ip'), err)
    end
end

--- Sends a piece of data to a particular client
-- @param string ip: IP of the client
-- @param number port: PORT of the client
-- @param binary data: the serialized data encoded in json
function server:sendTo(ip, port, data)
    local status, err = pcall(function ()
        return self._serv:send(ip, port, data)
    end)
    if not status then
        self._serv:log('An error happened while trying to send data to IP : %s. Error : %s', ip, err)
    end
end

--- Sends some data to all the players
-- @param string data: data encoded in JSON format
function server:broadcast(data)
    for _, ply in ipairs(self._players:getPlayers()) do
        self:sendToPlayer(ply, data)
    end
end

--- Returns the players table
-- @return table
function server:getPlayers()
    return self._players:getPlayers()
end

return server
