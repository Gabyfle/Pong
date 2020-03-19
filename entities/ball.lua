ball = {
	radius = 10, -- so 20 pixels in diameter
	color = { 3, 2, 1, 100 },
	["pos"] = {
		x = config["windowSize"].width / 2,
		y = config["windowSize"].height / 2
	}
}

function ball.draw()
	love.graphics.setColor(ball.color)
	love.graphics.circle("fill", ball["pos"].x, ball["pos"].y, ball.radius, 100)
end

function ball.collide()
	local max, min =
	{ -- Maximums table
		["x"] = config["windowSize"].width - ball.radius * 1.5,
		["y"] = config["windowSize"].height - ball.radius * 1.5
	},
	{ -- Minimums table
		["x"] = 0,
		["y"] = 0
	}
	-- If ball touch top of screen
	if ball["pos"].y < min["y"] then return 0 end
	-- If ball touch bottom of screen
	if ball["pos"].y > max["y"] then return 45 end
	--If ball touch player one
	if ball["pos"].y >= player["one"].y and ball["pos"].y <= player["one"].y + player.height and ball["pos"].x >= config["windowSize"].width - player.width then
		return 0
	end
	-- If ball touch player two
	if ball["pos"].y >= player["two"].y and ball["pos"].y <= player["two"].y + player.height and ball["pos"].x >= config["windowSize"].width - player.width then
		return 180
	end

	return nil
end

function ball.trajectory(angle)
	local x, y

	y = math.sin(math.rad(angle))
	x = math.cos(math.rad(angle))

	return x, y
end

function ball.move(angle)
	if angle == nil then
		multX, multY = 1, 1
	elseif angle then
		multX, multY = ball.trajectory(angle) -- x and y multipliers
	end

	ball["pos"].x = ball["pos"].x + 0.1 * multX
	ball["pos"].y = ball["pos"].y + 0.1 * multY

	love.graphics.print(tostring(ball["pos"].x))
end