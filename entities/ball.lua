ball = {
	radius = 10, -- so 20 pixels in diameter
	color = { 3, 2, 1, 100 },
	["pos"] = {
		x = config["windowSize"].width / 2,
		y = config["windowSize"].height / 2
	},
	angle = 0, -- initial angle
	-- Speed vector
	speed = { x = 0, y = 0 },
	speedMultiplier = 200
}

local angleHasBeenComputed = false

function ball:init()
	local values = { -1, 1 }
	self.speed.x = values[math.random(1, 2)]
end

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
	points.update(self.angle, self.angle)
	--If ball touch player one
	if ball["pos"].y > player["one"].y and ball["pos"].y < (player["one"].y + player.height) and ball["pos"].x < player.width + 2 then
		local mid = player["one"].y + player.height * 0.5 - ball["pos"].y

		self.angle = mid * math.pi * 0.01 + math.pi
		angleHasBeenComputed = false
	end
	-- If ball touch player two
	if ball["pos"].y > player["two"].y and ball["pos"].y < (player["two"].y + player.height) and ball["pos"].x > config["windowSize"].width - player.width - 2 then
		local mid = player["two"].y + player.height * 0.5 - ball["pos"].y

		self.angle = mid * math.pi * 0.02
		angleHasBeenComputed = false
	end

	-- if ball touch the top (like Drake)
	if ball["pos"].y < min["y"] + 1 then
		self.angle = self.angle + math.pi * 0.5
		angleHasBeenComputed = false
	end
	-- if ball touch the bottom
	if ball["pos"].y > max["y"] - 1 then
		self.angle = self.angle + math.pi * 0.5
		angleHasBeenComputed = false
	end

	return false
end

function ball.trajectory(angle)
	local x, y

	x = ball.speed.x * math.cos(angle) - ball.speed.y * math.sin(angle)
	y = ball.speed.x * math.sin(angle) + ball.speed.y * math.cos(angle)

	return x, y
end

function ball:move(dt)
	if self.angle and not angleHasBeenComputed then
		self.speed.x, self.speed.y = self.trajectory(self.angle)
		angleHasBeenComputed = true
	end

	ball["pos"].x = ball["pos"].x + self.speed.x * dt * ball.speedMultiplier
	ball["pos"].y = ball["pos"].y + self.speed.y * dt * ball.speedMultiplier
end