-- Made by Gabriel "Gabyfle" Santamaria
require ("config")
require ("helpers")
require ("fonts.fonts")
require ("entities.player")
require ("entities.ball")
require ("gui.net")
require ("gui.points")

local start = false

function love.load() -- On game load
    love.window.setMode(config["windowSize"].width, config["windowSize"].height, { resizable = false, vsync = false})
    love.window.setTitle("Pong Game - by Gabyfle")

    -- Loading the font that will be used to display the points number
    value = fonts:loadFont("DS-DIGII", 60)
    ball:init() -- initializing the ball object
    points.update(0, 0)
end

function love.update(dt)
    ball:collide()
    if not start then
        start = true
    end

    ball:move(dt)
    player.move()
end

function love.draw()
    net.draw()
    points.draw()
    ball.draw()

    player.draw(0, player["one"].y)
    player.draw(config["windowSize"].width - player.width, player["two"].y)
end
