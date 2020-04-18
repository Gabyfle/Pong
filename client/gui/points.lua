--[--[--------------------]--]--
-- Project: Pong              --
-- File: points.lua           --
--                            --
-- Author: Gabyfle            --
-- License: Apache 2.0        --
--]--]--------------------[--[--

local points = {
    pos = {
        [1] = {
            x = 150,
            y = 5
        },
        [2] = {
            x = 140,
            y = 5
        }
    },

    pts = {
        here = 0,
        online = 0
    }
}

local ply_one
local ply_two

function points.init() -- to be called a unique time
    points.update(0, 0)
end

function points.update(herePoints, onlinePoints)
    if not herePoints then herePoints = 0 end
    if not onlinePoints then onlinePoints = 0 end

    points.pts['local'] = herePoints
    points.pts['lan'] = onlinePoints

    ply_one = love.graphics.newText(fonts:getFont("DS-DIGII"))
    ply_two = love.graphics.newText(fonts:getFont("DS-DIGII"))

    ply_one:set({ { 255, 100, 0, 255 }, tostring(herePoints) })
    ply_two:set({ { 0, 100, 255, 255 }, tostring(onlinePoints) })
end

function points.draw()
    love.graphics.draw(ply_one, points.pos[1].x, points.pos[1].y, 0)
    love.graphics.draw(ply_two, points.pos[2].x, points.pos[2].y, 0)
end

return points
