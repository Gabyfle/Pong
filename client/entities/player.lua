--[--[--------------------]--]--
-- Project: Pong              --
-- File: player.lua           --
--                            --
-- Author: Gabyfle            --
-- License: Apache 2.0        --
--]--]--------------------[--[--

player = {
    width = 15,
    height = 100,
    color = { 1, 1, 0, 100 },
    ["local"] = { -- local player ordinate
        y = 250
    },
    ["lan"] = { -- lan player ordinate
        y = 250
    }
}

function player.init()
    player["local"].y = 300 - player.height * 0.5
    player["lan"].y = 300 - player.height * 0.5
end

function player.move()
    local max = 300 - player.height -- Maximum y
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
