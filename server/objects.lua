--[--[--------------------]--]--
-- Project: Pong              --
-- File: objects.lua          --
--                            --
-- Author: Gabyfle            --
-- License: Apache 2.0        --
--]--]--------------------[--[--
local player = require('entities.player')
local socket = require('socket')

--- Players metatable
-- Used to handle server players
local tags = { 1, 2 }

local players = {
    tags = {},
    plytbl = {},
    plyCount = 0
}
players.__index = players


--- Players constructor
-- @return players
function players:__call()
    return self
end

--- Adds a player to the players
-- @param table players: players table
-- @param table ply: Player to add to the players table
function players:add(ply)
    if not getmetatable(ply) == player then return end
    if self.plyCount >= 2 then return end

    self.plytbl[tostring(ply)] = ply
    self.tags[tostring(ply)] = tags[#tags]
    table.remove(tags, #tags)
    self.plyCount = self.plyCount + 1

    for k, v in pairs(self.plytbl) do
        print(k)
        print(v:get('ip') .. ' PORT  ' .. v:get('port'))
    end

    return self
end

--- Delete a player from the players table
-- @param table players: players table
-- @param table player: player to delete
function players:delete(ply)
    if not getmetatable(ply) == player then return end
    if not self.plytbl[tostring(ply)] then return end

    self.plytbl[tostring(ply)] = nil
    tags[self.tags[tostring(ply)]] = self.tags[tostring(ply)]
    self.plyCount = self.plyCount - 1

    return self
end

--- Returns the number of current players
-- @param table players: players table
-- @return number: number of connected players
function players:playerCount()
    return self.plyCount
end

--- Returns the player with the given authentification key
-- @param table players
-- @param string key: player's authentification key
-- @return table player
function players:getPlayer(key)
    return self.plytbl[key]
end

--- Returns the other player (which is the player who have a different authentification key)
-- @param string key: authentification key
-- @return table player
function players:getOtherPlayer(key)
    for k, ply in pairs(self.plytbl) do
        if k ~= key then -- we can basically do this cuz we know that we'll got only two players
            return ply
        end
    end
end

--- Returns all the players connected to the server
-- @return table players: a table containing all the players
function players:getPlayers()
    local plys = {}
    for _, ply in pairs(self.plytbl) do
        table.insert(plys, self.tags[ply:get('key')], ply)
    end

    return plys
end


--- Server metatable
-- Used to handle internal server logic

local serv = {
    socket = nil,
    ip     = nil,
    port   = nil,
    logf    = nil
}

serv.__index = serv

--- Server internal initialization
-- @param number port: Port to bind the server
-- @param table server
-- @return serv: a serv metatable
function serv:__call(port, server)
    server = server or {}
    setmetatable(server, self)

    -- Log file stuff
    server.logf = string.format('pong_server_log_%s.log', os.date('%m_%d_%y_%H_%M_%S',os.time()))
    do
        local file = io.open(server.logf, 'w+')
        file:write()
        file:close()
    end

    server:log('Log file is ready! File name: %s', server.logf)

    -- Socket stuff
    server.socket = assert(socket.udp())
    server.socket:settimeout(0)
    server:log('Trying to bind your server to a IP/PORT...')
    server.socket:setsockname('0.0.0.0', port)

    -- print to the client that everything is okay
    server:log('Your Pong server has been initialized', server.log, server.log)
    server.ip, server.port = server.socket:getsockname()
    server:log('Server IP: %s', server.ip)
    server:log('Server PORT: %s', server.port)

    return server
end

--- Logs a message to the log file and to the console
-- @param string message: message to log
-- @params varargs ...: arguments to replace in string.format
function serv:log(message, ...)
    if select('#', { ... }) ~= 0 then
        message = string.format(message, ...)
    end
    local final = string.format('[%s] %s', os.date('%x %X', os.time()), message)
    -- first, write it to the log file
    local log_file = io.open(self.logf, 'a')
    if not log_file then
        error('An error occurred while trying to write the log file!')
    else
        log_file:write(final .. '\n')
        log_file:close()
    end

    print(final)
end

--- Sends data to a player
-- @param string IP: player's IP
-- @param number PORT: player's PORT
-- @param string data: data to send
function serv:send(ip, port, data)
    data = love.data.compress('string', 'lz4', data)
    local status, err = pcall(function ()
        return self.socket:sendto(data, ip, port)
    end)
    if not status then
        self:log('An error happened while trying to send data to player : %s. Error : %s', ip, err)
    end
end

--- Just a "wrapper" function of the socket:receivefrom() function
function serv:receive()
    return self.socket:receivefrom()
end

return setmetatable(players, players), setmetatable(serv, serv)
