local socket = require('socket')
local json   = require('json')

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


local server = {
    _serv = {
        socket = nil,
        ip     = nil,
        port   = nil
    },
    _players = {}
}

--- Server initialization
function server:init(port)
    self._serv.socket = assert(socket.udp())
    self._serv.socket:settimeout(0)
    self._serv.socket:setsockname('*', port)

    -- print to the client that everything is okay
    print('Pong server has been initialized...')
    self._serv.ip, self._serv.port = self._serv.socket:getsockname()
    print('Server IP: ' .. self._serv.ip .. '\nServer PORT: ' .. self._serv.port)
end

--- Server's main loop
function server:run()
    while true do
        local data, ip, port = self._serv.socket:receivefrom()
        data = json.decode(data)
        if data then
            if #self._players < 2 then -- this player is one of the two first _players
                local key = randomString()
                table.insert(self._players, { -- register this player as an actual player (lel)
                    ip = ip,
                    port = port,
                    key = key,
                    last_request = os.time()
                })
                local registered = string.format([[
                    {
                        "action": "register",
                        "key": %s
                    }
                ]], key)

                local client = self._players[findWithKey(self._players, "key", key)]
                if not client then
                    error('A fatal error occurred right after registering the client into the server.')
                end
                -- Inform the client that we just registered him has a proper 
                self._serv.socket:sendto(registered, client.ip,  client.port)
            elseif not data.key or not findWithKey(self._players, "key", data.key) then
                print('A client tried to connect on server with IP: ' .. ip .. ' and PORT: ' .. port)
                print('Actually, he didn\'t send any registered key, so I just rejected him!')
            end
        elseif ip ~= 'timeout' then
            error('A fatal error occurred while receiving package from a client. Error: ' .. tostring(msg))
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
