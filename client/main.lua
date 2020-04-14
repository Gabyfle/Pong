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
    player.init(two) -- initializing player entities
end

function love.load() -- On game load
    love.window.setMode(600, 600, { resizable = false, vsync = false})
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

    player.draw(0, player["local"].y)
    player.draw(600 - player.width, player["lan"].y)
end
