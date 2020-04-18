--[--[--------------------]--]--
-- Project: Pong              --
-- File: main.lua             --
--                            --
-- Author: Gabyfle            --
-- License: Apache 2.0        --
--]--]--------------------[--[--
local config = require('config')
local server = require('server')
-- entities
local ball = require('entities.ball')
local player = require('entities.player')

function love.init()
    -- server initialization
    server:init(config.PORT)
    ball:init()

    -- then, run the server
    server:run()
end

function love.update(dt)
    ball:collide()
    ball:move(dt)
end
