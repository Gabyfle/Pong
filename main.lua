-- Made by Gabriel "Gabyfle" Santamaria
require ("config")
require ("helpers")
require ("fonts.fonts")
require ("entities.player")
require ("entities.ball")
require ("gui.net")
require ("gui.points")

function gameInit()
    ball:init() -- initializing the ball object
    player.init() -- initializing player entities
end

function love.load() -- On game load
    love.window.setMode(config["windowSize"].width, config["windowSize"].height, { resizable = false, vsync = false})
    love.window.setTitle("Pong Game - by Gabyfle")
    -- Loading the font that will be used to display the points number
    fonts:loadFont("DS-DIGII", 60)

    points.init()
    gameInit()
end

function love.update(dt)
    ball:collide()
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
