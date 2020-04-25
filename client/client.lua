--[--[--------------------]--]--
-- Project: Pong              --
-- File: client.lua           --
--                            --
-- Author: Gabyfle            --
-- License: Apache 2.0        --
--]--]--------------------[--[--
package.path = '../shared/libs/?.lua;' .. package.path

local config = require('config')
local socket = require('socket')
local json   = require('json')

-- load all the stuff
local player  = require('entities.player')
local ball    = require('entities.ball')
local points  = require('gui.points')
local message = require('gui.message')

local KNOWN_ACTIONS = {
    ['ping'] = true,
    ['ball'] = true,
    ['players'] = true,
    ['register'] = true
}

local client = {
    socket = nil,
    key = '',
    connected = false,
    game = {
        players = player,
        ball = ball,
        points = points
    },

    last = nil
}


function client:init()
    print('Initializing client...')
    self.socket = assert(socket.udp())
    self.socket:settimeout(0)
    self.socket:setpeername(config.server.ip, config.server.port)

    -- when everything is setup, we try to register to the server by sending a packet
    self:send('{"action": "register"}')
end

--- Sends a piece of data to a server
-- @param string data: serialized data encoded in JSON
function client:send(data)
    data = love.data.compress('string', 'lz4', data)
    self.socket:send(data)
end

function client:receive()
    local data, err = self.socket:receive()
    if data then
        print(love.data.decompress('string', 'lz4', data))
        local status, data = pcall(function()
            return json.decode(love.data.decompress('string', 'lz4', data))
        end)
        if not status then
            print('An error occurred on the last received data. Error : ' .. data)
            return
        end
        if not (data['action'] and KNOWN_ACTIONS[data['action']]) then
            print('We received a packet that is not usable. Aborting')
            return
        end

        if data['action'] == 'register' then
            if data['data']['key'] == 'full' then
                message:draw('serverFull', 0, string.format('The server with IP %s is full! Choose an other one!', config.server.ip), { 255, 0, 0, 255 }, -295, 50)
            else
                self.key = data['data']['key']
                self.connected = true
                print('You\'ve been accepted by the server!')
            end
        elseif data['action'] == 'ping' then
            local ping = data['data']
            if not ping['status'] then return end
            if ping['status'] == 'waiting' then
                self:send(string.format([[{"key": "%s", "action": "ping","data": {"status": "ok"}}]], self.key))
            end
        elseif data['action'] == 'players' then
            local ply_data = data['data']
            if not (ply_data['here'] and ply_data['online']) then
                return -- we abort because the data may be corrupted
            end

            if ply_data['here'] then
                self.game.players:add('here', ply_data['here'] - self.game.players:getpos('here'))
            elseif ply_data['online'] then
                self.game.players:add('online', ply_data['online'] - self.game.players:getpos('online'))
            end
        elseif data['action'] == 'ball' then
            local ball_data = data['data']
            if not (ball_data['angle'] and ball_data['speedMultiplier']) then return end

            self.game.ball.angle = data['angle']
            self.game.ball.speedMultiplier = ball_data['speedMultiplier']
            self.game.ball.angleHasBeenComputed = false
        end

        self.last = os.time()

        return true
    elseif err ~= 'timeout' then
        error('A fatal error occurred while receiving package from the server. Error: ' .. tostring(err))
    end

    return false
end

function client:run()
    while self:receive() do
        -- chill bro
    end
end

--- Returns the player table of the client
--@return string: the authentification key
function client:getKey()
    if not self.connected then return end
    return self.key
end

--- Returns whether or not we're connected to a server
-- @return bool
function client:isConnected()
    return self.connected
end

return client
