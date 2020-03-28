points = {
    pos = {
        [1] = {
            x = config["windowSize"].width / 4,
            y = 5
        },
        [2] = {
            x = 0.75 * config["windowSize"].width - 10,
            y = 5
        }
    },

    pts = {
        plyOne = 0,
        plyTwo = 0
    }
}

local ply_one
local ply_two

function points.init() -- to be called a unique time
    points.update(0, 0)
end

function points.update(plyOnePoints, plyTwoPoints)
    if not plyOnePoints then plyOnePoints = 0 end
    if not plyTwoPoints then plyTwoPoints = 0 end

    points.pts.plyOne = plyOnePoints
    points.pts.plyTwo = plyTwoPoints

    ply_one = love.graphics.newText(fonts:getFont("DS-DIGII"))
    ply_two = love.graphics.newText(fonts:getFont("DS-DIGII"))

    ply_one:set({ { 255, 100, 0, 255 }, tostring(plyOnePoints) })
    ply_two:set({ { 0, 100, 255, 255 }, tostring(plyTwoPoints) })
end

function points.draw()
    love.graphics.draw(ply_one, points.pos[1].x, points.pos[1].y, 0)
    love.graphics.draw(ply_two, points.pos[2].x, points.pos[2].y, 0)
end