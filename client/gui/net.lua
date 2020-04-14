net = {
    width = 4,
    color = { 1, 1, 0, 100 }
}
net["pos"] = {
    x = config["windowSize"].width / 2 - net.width / 2, -- abscissa center of window
    y = 0, -- initial ordonate
    newY = 30
}

function net.draw() -- shapes the net
    local max, size, interval = config["windowSize"].height, 60, 40
    local v = size / interval

    love.graphics.setColor(net.color)
    love.graphics.setLineStyle("smooth")
    love.graphics.setLineWidth(net.width)

    -- First line
    love.graphics.line(net["pos"].x, net["pos"].y, net["pos"].x, net["pos"].newY)
    -- Line loop
    for i = 1, max do
        if i % interval == 0 then
            love.graphics.line(net["pos"].x, net["pos"].y + v * (i - 1), net["pos"].x, net["pos"].newY + v * (i - 1))
        end
    end
end