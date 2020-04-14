player = {
    width = 15,
    height = 100,
    color = { 1, 1, 0, 100 },
    ["one"] = { -- player one ordinate
        y = 250
    },
    ["two"] = { -- player two ordinate
        y = 250
    }
}

--- Player initialization
function player.init()
    player["one"].y = 300 - player.height * 0.5
    player["two"].y = 300 - player.height * 0.5
end


--- Updates a player's ordinate
-- @param string ply: Player's name
function player:update(ply, y)
    local max = 300 - player.height -- Maximum y
    if ply ~= "one" and ply ~= "two" then
        print("Unknown player " .. tostring(ply))
    else
        if y > max then
            print("Trying to set a y greater than " .. max ..". Aborting.")
        else
            self[ply].y = y
        end
    end
end


