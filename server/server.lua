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
local json   = require('cjson')

local player = require('entities.player')

-- Generating a random seed for Players' connexion key
math.randomseed(os.time())

-- SERVER CONSTANT
local KNOWN_ACTIONS =
{
    ['ping'] = true,
    ['move'] = function (ply, key)
        if key == 'up' then
            ply:update(ply.y + 1)
        elseif key == 'down' then
            ply:update(ply.y - 1)
        end
    end
}

--- Generates a random string
-- @return string: the randomly generated string
local function randomString()
    local string = ""
    for i = 1, 16 do
        local char = math.random(33, 126)
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
end

local server = {
    _serv = {
        socket = nil,
        ip     = nil,
        port   = nil,
        log    = nil
    },
    _players = {}
}

--- Server initialization
-- @param number port
function server:init(port)
    -- Log file stuff
    self._serv.log = string.format('pong_server_log_%s.log', os.date('%m_%d_%y_%X',os.time()))
    do
        local log_file = io.open(self._serv.log, 'r')
        if not log_file then
            local file = io.open(self._serv.log, 'w')
            file:write()
            file:close()
        end
    end
    log('Log file is ready! File name: %s', self._serv.log, self._serv.log)

    -- Socket stuff
    self._serv.socket = assert(socket.udp())
    self._serv.socket:settimeout(0)
    log('Trying to bind your server to a IP/PORT...', self._serv.log)
    self._serv.socket:setsockname('*', port)

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
    if #self._players == 2 then
        log('A client with IP: %s tried to connect on the server but we were already 2!', ip)
        -- inform the client that this server is full
        local register = string.pack([[
            {
                "action": "register",
                "key": "full"
            }
        ]])
        self:sendTo(ip, port, register)
        return
    end

    local key = randomString() -- this is the player's unique name
    self._players[key] = { -- register this player as an actual player (lel)
        ip = ip,
        port = port,
        key = key,
        data = table.copy(player),
        last_request = os.time()
    }
    local registered = string.format([[
        {
            "action": "register",
            "key": %s
        }
    ]], key)

    local data = string.pack(registered)
    self:sendToPlayer(key, data)
end

--- Execute a particular action on player ply
-- @param string action: action to execute
-- @param string ply: player to execute the action on or IP to register
-- @param table data: a table containing the received data
function server:execute(action, ply, data)
    if not KNOWN_ACTIONS[action] then
        log('Someone tried to launch an unknown action called %s', ply)
    end

    if action == 'move' then
        if not self.players[ply] then return end
        local ply_data = self._players[ply].data
        if not data['key'] then return end -- maybe the data is corrupted so abort
        KNOWN_ACTIONS[action](ply_data, data['key'])
    elseif action == 'ping' then
        if not self.players[ply] then return end
        if data['status'] and data['status'] == 'waiting' then
            self:sendToPlayer(ply, string.pack([[
                {
                    "action": "ping",
                    "data": {
                        "status": "ok"
                    }
                }
            ]]))
        end
    end
end

--- Launched when a player timed out, disconnect him
-- @param string ply: player's authentification key
function server:timedout(ply)
    if not self._players[ply] then
        error('Player ' .. ply .. ' does not exist')
    end
    log('Player with IP: %s and key: has been disconnected', self._players[ply], self._players[ply].key)
    self._players[ply] = nil
end

--- When the server receive data from a player, decode it and then update stuff from it
function server:receive()
    local data, ip, port = self._serv.socket:receivefrom()
    data = string.unpack(data)
    data = json.decode(data)

    if data then
        if #self._players < 2 and not (data['key'] and self._players[data['key']]) then
            self:register()
        else
            if not (data['key'] and self._players[data['key']]) then
                log('A client tried to connect on server with IP: %s and PORT: %s', self._serv.log, ip, port)
                log('Actually, he didn\'t send any registered key, so I just rejected him!')
                return
            end
            local ply, action = data['key'], data['action']
            self._players[ply].last_request = os.time()
            if not (action and KNOWN_ACTIONS[action]) then
                log('Player %s sent an unknown action: %s', ply, action)
            else
                server:execute(ply, action)
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
                if delay > 5 and delay < config.MAX_DELAY - 5 then
                    self:sendToPlayer(id, string.pack([[
                        {
                            "action": "ping",
                            "data": {
                                "status": waiting
                            }
                        }
                    ]]))
                elseif delay > config.MAX_DELAY then
                    self:timedout(id)
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
    self._serv.socket:sendto(data, ply.ip, ply.port)
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
    data = string.pack(data)
    for _, ply in pairs(self._players) do
        self:sendToPlayer(ply, data)
    end
end

return server
