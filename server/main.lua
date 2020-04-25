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
local ball   = require('entities.ball')


function love.load()
    -- server initialization
    server:init(config.PORT)

    ball:init()
end

function love.update(dt)
    ball:collide(unpack(server:getPlayers()))
    ball:move(dt)

    -- then, run the server
    server:run()
end
