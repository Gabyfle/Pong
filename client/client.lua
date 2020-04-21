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
local json   = require('cjson')

-- load all the stuff
local player = require('entities.player')
local ball   = require('entities.ball')
local points = require('gui.points')

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
        players = { unpack(player) },
        ball = { unpack(ball) },
        points = { unpack(points) }
    },

    last = nil
}


function client:init()
    print('Initializing client...')
    self.socket = assert(socket.udp())
    self.socket:settimeout(0)
    self.socket:setpeername(config.server.ip, config.server.port)

    -- when everything is setup, we try to register to the server by sending a packet
    self:send('{}')
end

--- Sends a piece of data to a server
-- @param string data: serialized data encoded in JSON
function client:send(data)
    data = love.data.compress('string', 'lz4', data)
    print(love.data.decompress('string', 'lz4', data))
    self.socket:send(data)
end

function client:receive()
    local data, err = self.socket:receive()
    if data then
        data = json.decode(love.data.decompress('string', 'lz4', data))
        if not (data['action'] and KNOWN_ACTIONS[data['action']]) then
            print('We received a packet that is not usable. Aborting')
            return
        end

        if data['action'] == 'register' then
            if data['data']['key'] == 'full' then
                -- the server is full, should display to screen that this server is full
            else
                self.key = data['data']['key']
                self.connected = true
            end
        elseif data['action'] == 'ping' then
            local ping = data['data']
            if not ping['status'] then return end
            if ping['status'] == 'waiting' then
                self:send([[{"action": "ping","data": {"status": "ok"}}]])
            end
        elseif data['action'] == 'players' then
            local ply_data = data['data']
            if not (ply_data['here'] and ply_data['online']) then
                return -- we abort because the data may be corrupted
            end

            self.game.players:add('here', ply_data['here'] - self.game.players:getpos('here'))
            self.game.players:add('online', ply_data['online'] - self.game.players:getpos('online'))
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

return client
