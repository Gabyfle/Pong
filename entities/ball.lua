ball = {
	radius = 10, -- so 20 pixels in diameter
	color = { 3, 2, 1, 100 },
	["pos"] = {
		x = config["windowSize"].width / 2,
		y = config["windowSize"].height / 2
	},
	angle = helpers.random({0, 180}) -- initial angle
}

function ball.draw()
	love.graphics.setColor(ball.color)
	love.graphics.circle("fill", ball["pos"].x, ball["pos"].y, ball.radius, 100)
end

function ball:collide()
	local max, min =
	{ -- Maximums table
		["x"] = config["windowSize"].width - ball.radius * 1.5,
		["y"] = config["windowSize"].height - ball.radius * 1.5
	},
	{ -- Minimums table
		["x"] = 0,
		["y"] = 0
	}
	--If ball touch player one
	if ball["pos"].y > player["one"].y and ball["pos"].y < (player["one"].y + player.height) and ball["pos"].x < player.width then
		self.angle = math.random(-45, 45)
		return true
	end
	-- If ball touch player two
	if ball["pos"].y > player["two"].y and ball["pos"].y < (player["two"].y + player.height) and ball["pos"].x > config["windowSize"].width - player.width then
		self.angle = math.random(135, 225)
		return true
	end

	-- if ball touch the top (like Drake)
	if ball["pos"].y < min["y"] then
		self.angle = 90 + self.angle + math.random() * self.angle
	end
	-- if ball touch the bottom
	if ball["pos"].y > max["y"] then
		self.angle = -90 + self.angle + math.random() * self.angle
	end

	return false
end

function ball.trajectory(angle)
	local x, y

	y = math.sin(math.rad(angle))
	x = math.cos(math.rad(angle))

	return x, y
end

function ball:move()
	if self.angle == nil then
		multX, multY = 1, 1
	elseif self.angle then
		multX, multY = ball.trajectory(self.angle) -- x and y multipliers
	end

	ball["pos"].x = ball["pos"].x + 0.4 * multX
	ball["pos"].y = ball["pos"].y + 0.4 * multY
end