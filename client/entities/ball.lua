--[--[--------------------]--]--
-- Project: Pong              --
-- File: ball.lua             --
--                            --
-- Author: Gabyfle            --
-- License: Apache 2.0        --
--]--]--------------------[--[--

local ball = {
    radius = 10, -- so 20 pixels in diameter
    color = { 3, 2, 1, 100 },
    ["pos"] = {
        x = 300,
        y = 300
    },
    angle = 0, -- initial angle
    angleHasBeenComputed = false,
    -- Speed vector
    speed = { x = 0, y = 0 },
    speedMultiplier = 300
}

function ball:init()
    local values = { -1, 1 }
    self.speed.x = values[math.random(1, 2)]
    self.speed.y = 0
    self.speedMultiplier = 300
    ball["pos"] = {
        x = 300,
        y = 300
    }
end

function ball.draw()
    love.graphics.setColor(ball.color)
    love.graphics.circle("fill", ball["pos"].x, ball["pos"].y, ball.radius, 100)
end

function ball.trajectory(angle)
    local x, y

    x = ball.speed.x * math.cos(angle) - ball.speed.y * math.sin(angle)
    y = ball.speed.x * math.sin(angle) + ball.speed.y * math.cos(angle)

    return x, y
end

function ball:move(dt)
    if self.angle and not self.angleHasBeenComputed then
        self.speed.x, self.speed.y = self.trajectory(self.angle)
        self.angleHasBeenComputed = true
    end

    ball["pos"].x = ball["pos"].x + self.speed.x * dt * ball.speedMultiplier
    ball["pos"].y = ball["pos"].y + self.speed.y * dt * ball.speedMultiplier
end
