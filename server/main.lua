local socket = require('socket')
local json   = require('cjson')

require('timer')

-- Generating a random seed for Players' connexion key
math.randomseed(os.time())

--- Generates a random string
-- @return string: the randomly generated string
local function randomString()
    local string = ""
    for i = 1, 50 do
        string = string .. string.char(math.random(1, 4) * i)
    end

    return string
end

--- Finds the entry that has the key "key" which is equal to "value"
-- @param table table: the table in which it should do the check
-- @param varargs key: the key to check
-- @param varargs value: the value to check
-- @return varargs: key of the correspondant value
local function findWithKey(table, key, value)
    for k, v in pairs(table) do
        if type(v) == 'table' and v[key] and v[key] == value then
            return k
        end
    end
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
-- @param number ip: 
function server:register(ip, port)
    local key = randomString()
    self._players[key] = { -- register this player as an actual player (lel)
        ip = ip,
        port = port,
        key = key,
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

--- Delete the player from the players table and notify that he has timed out
-- @param string player: player's name
function server:timedout(ply)
    if not self._players[ply] then
        error('Player ' .. ply .. ' does not exist')
    end
    log('Player with IP: %s and key: has been disconnected', self._players[ply], self._players[ply].key)
    self._players[ply] = nil
end

--- Server's main loop
function server:run()
    log('Your Pong server is now running.',self._serv.log)
    while true do
        local data, ip, port = self._serv.socket:receivefrom()
        if data then
            data = json.decode(data)
            if #self._players < 2 then -- this player is one of the two first _players
                self:register(ip, port)
            elseif not data.key or not findWithKey(self._players, "key", data.key) then
                log('A client tried to connect on server with IP: %s and PORT: %s', self._serv.log, ip, port)
                log('Actually, he didn\'t send any registered key, so I just rejected him!')
            end
        elseif ip ~= 'timeout' then
            error('A fatal error occurred while receiving package from a client. Error: ' .. tostring(ip))
        end

        socket.sleep(0.01)
    end
end
--- When the server receive data from a player, decode it and then update stuff from it
-- @param string data: data encoded in JSON format
function server:receive(data)
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

server:init(1234)
server:run()