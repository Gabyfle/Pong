--[--[--------------------]--]--
-- Project: Pong              --
-- File: server.lua           --
--                            --
-- Author: Gabyfle            --
-- License: Apache 2.0        --
--]--]--------------------[--[--
package.path = '../shared/libs/?.lua;' .. package.path

local socket = require('socket')
local json   = require('cjson')
local timer  = require('timer')

-- SERVER CONSTANT
local KNOWN_ACTIONS =
{
    ['register'] = true,
    ['ping'] = true,
    ['move'] = true
}

-- Generating a random seed for Players' connexion key
math.randomseed(os.time())

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

    local client = self._players[key]
    if not client then
        error('A fatal error occurred right after registering the client into the server.')
    end

    -- TODO : send this JSON data to the player
end

--- Execute a particular action on player ply
-- @param string action: action to execute
-- @param table data: a table containing the received data
-- @param string ply: player to execute the action on
function server:execute(action, data, ply)
    ply = ply or ''
    if not KNOWN_ACTIONS[action] then
        log('Someone tried to launch an unknown action called %s', ply)
    end

    if action == 'move' then
        if not self._players[ply] then return end
        local ply_data = self._players[ply].data

        ply_data:update(data.y)
    end
end

--- Delete the player from the players table and notify that he has timed out
-- @param string player: player's name
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

    if not data['key'] or not self._players[data['key']] then
        self:register()
    else
        local ply, action, ip, port = data['key'], data['action'], data['ip'], data['port']
        if not action or not KNOWN_ACTIONS[action] then
            log('Player %s sent an unknown action: %s', ply, action)
        else
            server:execute(ply, action)
        end
    end
end

--- Server's main loop
function server:run()
    log('Your Pong server is now running.',self._serv.log)
    while true do
        if data then
            data = json.decode(data)
            if #self._players < 2 then -- this player is one of the two first _players
                self:register(ip, port)
            elseif not data.key or not self._players[data.key] then
                log('A client tried to connect on server with IP: %s and PORT: %s', self._serv.log, ip, port)
                log('Actually, he didn\'t send any registered key, so I just rejected him!')
            end
        elseif ip ~= 'timeout' then
            error('A fatal error occurred while receiving package from a client. Error: ' .. tostring(ip))
        end

        socket.sleep(0.01)
    end
end

--- Sends a piece of data to a particular player
-- @param table ply: the player to send the data on
-- @param string data: the data encoded in json
function server:sendToPlayer(ply, data)
end

--- Sends some data to all the players
-- @param string data: data encoded in JSON format
function server:broadcast(data)
    for _, ply in pairs(self._players) do
        -- send the data to everyone
    end
end

return server
