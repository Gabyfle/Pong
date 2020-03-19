-- Made by Gabriel "Gabyfle" Santamaria
require ("config")
require ("helpers")
require ("fonts.fonts")
require ("entities.player")
require ("entities.ball")
require ("gui.net")

local start = false

function love.load() -- On game load
    love.window.setMode(config["windowSize"].width, config["windowSize"].height, { resizable = false, vsync = false})
    love.window.setTitle("Pong Game - by Gabyfle")

end

function love.update(dt)
    ball:collide()
    if not start then
        ball:move()
        start = true
    end

    ball:move()
    player.move()
end

function love.draw()
    net.draw()
    ball.draw()

    player.draw(0, player["one"].y)
    player.draw(config["windowSize"].width - player.width, player["two"].y)
end
