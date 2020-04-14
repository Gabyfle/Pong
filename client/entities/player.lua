player = {
    width = 15,
    height = 100,
    color = { 1, 1, 0, 100 },
    ["local"] = { -- local player ordinate
        y = config["windowSize"].width / 2 - 50
    },
    ["lan"] = { -- lan player ordinate
        y = config["windowSize"].width / 2 - 50
    }
}

function player.init()
    player["local"].y = config["windowSize"].width * 0.5 - player.height * 0.5
    player["lan"].y = config["windowSize"].width * 0.5 - player.height * 0.5
end

function player.draw(x, y)
    love.graphics.setColor(player.color)
    love.graphics.rectangle("fill", x, y, player.width, player.height)
end

function player.move()
    local max = config["windowSize"].width - player.height -- Maximum y
    if love.keyboard.isDown(config["keys"].up) then
        if player["local"].y > 0 then
            player["local"].y = player["local"].y - 1
        end
    elseif love.keyboard.isDown(config["keys"].down) then
        if player["local"].y < max then
            player["local"].y = player["local"].y + 1
        end
    end
end
