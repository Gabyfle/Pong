player = {
    width = 15,
    height = 100,
    color = { 1, 1, 0, 100 },
    ["one"] = { -- Player one's ordinate
        y = config["windowSize"].width / 2 - 50
    },
    ["two"] = { -- Player two's ordinate
        y = config["windowSize"].width / 2 - 50
    }
}

function player.init()
    player["one"].y = config["windowSize"].width * 0.5 - player.height * 0.5
    player["two"].y = config["windowSize"].width * 0.5 - player.height * 0.5
end

function player.draw(x, y)
    love.graphics.setColor(player.color)
    love.graphics.rectangle("fill", x, y, player.width, player.height)
end

function player.move()
    local max = config["windowSize"].width - player.height -- Maximum y
    -- Player one
    if love.keyboard.isDown(config["keys"]["one"].up) then
        if player["one"].y > 0 then
            player["one"].y = player["one"].y - 1
        end
    elseif love.keyboard.isDown(config["keys"]["one"].down) then
        if player["one"].y < max then
            player["one"].y = player["one"].y + 1
        end
    end
    -- Player two
    if love.keyboard.isDown(config["keys"]["two"].up) then
        if player["two"].y > 0 then
            player["two"].y = player["two"].y - 1
        end
    elseif love.keyboard.isDown(config["keys"]["two"].down) then
        if player["two"].y < max then
            player["two"].y = player["two"].y + 1
        end
    end
end
