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

    if love.keyboard.isDown(config.keys.up) then
        player:add('here', -1)
        --client:send([[
        --    {
        --        "action": "move",
        --        "data": {
        --            "key": "up"
        --        }
        --    }
        --]])
    elseif love.keyboard.isDown(config.keys.down) then
        player:add('here', 1)
        --client:send([[
        --    {
        --        "action": "move",
        --        "data": {
        --            "key": "down"
        --       }
        --    }
        --]])
    end

    client:run()
end

function love.draw()
    net.draw()
    points.draw()
    ball.draw()

    player:draw(0, player.here.y)
    player:draw(585, player.online.y)
end
