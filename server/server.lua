--[--[--------------------]--]--
-- Project: Pong              --
-- File: server.lua           --
--                            --
-- Author: Gabyfle            --
-- License: Apache 2.0        --
--]--]--------------------[--[--
package.path = '../shared/libs/?.lua;' .. package.path

local config = require('config')
local socket = require('socket')
local json   = require('json')

local player = require('entities.player')

-- Generating a random seed for Players' connexion key
math.randomseed(os.time())

-- SERVER CONSTANT
local KNOWN_ACTIONS =
{
    ['ping'] = true,
    ['move'] = true
}

-- from http://lua-users.org/wiki/CopyTable
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

--- Displays a log message to server console
-- @param string message: message to display
-- @param varargs: various arguments to add to the string format of message
local function log(message, log, ...)
    if select('#', { ... }) ~= 0 then
        message = string.format(message, ...)
    end
    local final = string.format('[%s] %s', os.date('%x %X', os.time()), message)
    -- first, write it to the log file
    local log_file = io.open(log, 'a')
    if not log_file then
        error('An error occurred while trying to write the log file!')
    else
        log_file:write(final .. '\n')
        log_file:close()
    end

    print(final)
end

local server = {
    _serv = {
        socket = nil,
        ip     = nil,
        port   = nil,
        log    = nil
    },
    _players = {},
    plyCount = 0
}

--- Server initialization
-- @param number port
function server:init(port)
    -- Log file stuff
    self._serv.log = string.format('pong_server_log_%s.log', os.date('%m_%d_%y_%H_%M_%S',os.time()))
    do
        local file = io.open(self._serv.log, 'w+')
        file:write()
        file:close()
    end
    log('Log file is ready! File name: %s', self._serv.log, self._serv.log)

    -- Socket stuff
    self._serv.socket = assert(socket.udp())
    self._serv.socket:settimeout(0)
    log('Trying to bind your server to a IP/PORT...', self._serv.log)
    self._serv.socket:setsockname('0.0.0.0', port)

    -- print to the client that everything is okay
    log('Your Pong server has been initialized', self._serv.log, self._serv.log)
    self._serv.ip, self._serv.port = self._serv.socket:getsockname()
    log('Server IP: %s', self._serv.log, self._serv.ip)
    log('Server PORT: %s', self._serv.log, self._serv.port)
end

--- Register a couple of (ip, port) as a client
-- @param number ip: Client IP
-- @param number port: Client PORT
function server:register(ip, port)
    if self.plyCount >= 2 then
        log('A client with IP: %s tried to connect on the server but we were already 2!', self._serv.log, ip)
        -- inform the client that this server is full
        local register = love.data.compress('string', 'lz4', [[{"action": "register", "data": {"key": "full"}}]])
        self:sendTo(ip, port, register)
        return
    end

    log('A client connected with IP: %s and PORT: %s!', self._serv.log, ip, port)

    local key = randomString() -- this is the player's unique name
    self._players[key] = { -- register this player as an actual player (lel)
        ip = ip,
        port = port,
        key = key,
        data = deepcopy(player),
        last_request = os.time()
    }
    local registered = string.format([[{"action": "register", "data":{"key": "%s"}}]], key)

    local data = love.data.compress('string', 'lz4', registered)
    self:sendToPlayer(self._players[key], data)
    self.plyCount = self.plyCount + 1
end

--- Execute a particular action on player ply
-- @param string action: action to execute
-- @param string key: player to execute the action on or IP to register
-- @param table data: a table containing the received data
function server:execute(action, key, data)
    if not KNOWN_ACTIONS[action] then
        log('Someone tried to launch an unknown action called %s', self._serv.log, action)
    end

    if not data then return end

    if action == 'move' then
        if not self._players[key] then return end
        local ply = self._players[key].data
        if not data['key'] then return end -- maybe the data is corrupted so abort

        if data['key'] == 'up' then
            ply:update(ply:getpos() - 1)
        elseif data['key'] == 'down' then
            ply:update(ply:getpos() + 1)
        end
    elseif action == 'ping' then
        if not self._players[key] then return end
        if data['status'] and data['status'] == 'waiting' then
            self:sendToPlayer(self._players[key], love.data.compress('string', 'lz4', [[{"action": "ping","data": {"status": "ok"}}]]))
        end
    end
end

--- Launched when a player timed out, disconnect him
-- @param table ply: player's authentification key
function server:timedout(ply)
    log('Player with IP: %s and key: %s has been disconnected', self._serv.log, ply.ip, ply.key)
    self._players[ply.key] = nil
    self.plyCount = self.plyCount - 1
end

--- When the server receive data from a player, decode it and then update stuff from it
function server:receive()
    local data, ip, port = self._serv.socket:receivefrom()
    if data then
        local status, data = pcall(function()
            return json.decode(love.data.decompress('string', 'lz4', data))
        end)
        if not status then
            log('Something wrong happened with the data. Client IP: %s', self._serv.log, data or 'can\'t get error message')
            return
        end
        if #self._players < 2 and data['action'] == 'register' and not (data['key'] and self._players[data['key']]) then
            self:register(ip, port)
        else
            if not (data['key'] and self._players[data['key']]) then
                log('A client tried to connect on server with IP: %s and PORT: %s', self._serv.log, ip, port)
                log('Actually, he didn\'t send any registered key, so I just rejected him!', self._serv.log)
                return
            end
            local ply, action = data['key'], data['action']
            self._players[ply].last_request = os.time()
            if not (action and KNOWN_ACTIONS[action]) then
                log('Player %s sent an unknown action: %s', self._serv.log, ply, action)
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
    log('Your Pong server is now running.', self._serv.log)
    while true do
        for id, ply in pairs(self._players) do
            if ply.last_request then
                local delay = os.difftime(os.time(), ply.last_request)
                if delay > config.MAX_DELAY - 15 and delay < config.MAX_DELAY - 5 then
                    self:sendToPlayer(ply, love.data.compress('string', 'lz4', [[{"action": "ping","data": {"status": "waiting"}}]]))
                elseif delay > config.MAX_DELAY then
                    log('Player %s has exceeded the maximum unanswered time (%d).', self._serv.log, id, config.MAX_DELAY)
                    self:timedout(ply)
                end
            end
        end
        self:receive()
        socket.sleep(0.01)
    end
end

--- Sends a piece of data to a particular player
-- @param table ply: the player to send the data on
-- @param binary string data: the serialized data encoded in json
function server:sendToPlayer(ply, data)
    local status, err = pcall(function ()
        return self._serv.socket:sendto(data, ply.ip, ply.port)
    end)
    if not status then
        log('An error happened while trying to send data to player : %s. Error : %s', self._serv.log, ply.ip, err)
    end
end

--- Sends a piece of data to a particular client
-- @param string ip: IP of the client
-- @param number port: PORT of the client
-- @param binary data: the serialized data encoded in json
function server:sendTo(ip, port, data)
    self._serv.socket:sendto(data, ip, port)
end

--- Sends some data to all the players
-- @param string data: data encoded in JSON format
function server:broadcast(data)
    data = love.data.compress('data', 'lz4', data)
    for _, ply in pairs(self._players) do
        self:sendToPlayer(ply, data)
    end
end

--- Returns the players table
-- @return table
function server:getPlayers()
    return self._players
end

return server
