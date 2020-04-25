--[--[--------------------]--]--
-- Project: Pong              --
-- File: main.lua             --
--                            --
-- Author: Gabyfle            --
-- License: Apache 2.0        --
--]--]--------------------[--[--
local config  = require('config')
local fonts   = require('fonts.fonts')
local player  = require('entities.player')
local ball    = require('entities.ball')
local net     = require('gui.net')
local points  = require('gui.points')
local message = require('gui.message')
local client  = require('client')

function love.load() -- On game load
    client:init()

    love.window.setMode(600, 600, { resizable = false, vsync = false })
    love.window.setTitle("Pong Game - by Gabyfle")
    -- Loading the font that will be used to display the points number
    fonts:loadFont("DS-DIGII", 60)

    points.init(fonts:getFont('DS-DIGII'))
    ball:init()
    player:init()
end

function love.update(dt)
    ball:move(dt)

    do -- check if the server is still alive
        if client:isConnected() then
            local delay = os.difftime(os.time(), client.last)
            if (delay > config.server.max_delay - 15) and delay < config.server.max_delay - 5 then
                client:send(string.format([[{"key": "%s", "action": "ping", "data": { "status": "waiting" }}]], client:getKey()))
            elseif (delay > config.server.max_delay) then
                message:draw('timedOut', 0, 'You losed connection to the server.', { 255, 0, 0, 255 }, 0, 20)
                client.connected = false
            end
        end
    end

    if love.keyboard.isDown(config.keys.up) then
        if client:isConnected() then
            player:add('here', -1)
            client:send(string.format([[{"key": "%s", "action": "move", "data": {"key": "up"}}]], client:getKey()))
        else
            message:draw('notConnected', 2, 'You\'re not connected to a server.', { 255, 255, 255, 255 })
        end
    elseif love.keyboard.isDown(config.keys.down) then
        if client:isConnected() then
            player:add('here', 1)
            client:send(string.format([[{"key": "%s", "action": "move", "data": {"key": "down"}}]], client:getKey()))
        else
            message:draw('notConnected', 2, 'You\'re not connected to a server.', { 255, 255, 255, 255 })
        end
    end

    client:run()
end

function love.draw()
    net.draw()
    points.draw()
    ball.draw()

    player:draw(0, player.here.y)
    player:draw(585, player.online.y)

    message:_draw()
end
