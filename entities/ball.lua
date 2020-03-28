ball = {
	radius = 10, -- so 20 pixels in diameter
	color = { 3, 2, 1, 100 },
	["pos"] = {
		x = config["windowSize"].width / 2,
		y = config["windowSize"].height / 2
	},
	angle = nil, -- initial angle
	-- Speed vector
	speed = { x = 0, y = 0 },
	speedMultiplier = 100
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
	--If ball touch player one
	if ball["pos"].y > player["one"].y and ball["pos"].y < (player["one"].y + player.height) and ball["pos"].x <= player.width then
		-- if the ball touches the center of the player one
		if ball["pos"].y >= player["one"].y + player.height * 0.5 - 10 and ball["pos"].y <= player["one"].y + player.height * 0.5 + 10 then
			self.angle = 0
		end 

		angleHasBeenComputed = false
	end
	-- If ball touch player two
	if ball["pos"].y > player["two"].y and ball["pos"].y < (player["two"].y + player.height) and ball["pos"].x > config["windowSize"].width - player.width then
		-- if the ball touches the center of the player two
		if ball["pos"].y >= player["two"].y + player.height * 0.5 - 10 and ball["pos"].y <= player["two"].y + player.height * 0.5 + 10 then
			self.angle = math.pi
		elseif ball["pos"].y <= player["two"].y + player.height * 0.5 - 10 then -- ball touches the bottom of the pad
			local bottom = player.height + player.height * 0.5 - 10
			local coefficient = bottom - ball["pos"].y

			self.angle = coefficient * math.pi / 3 + math.pi 
		end
		


		angleHasBeenComputed = false
	end

	-- if ball touch the top (like Drake)
	if ball["pos"].y < min["y"] then
		self.angle = 90 + self.angle + math.random() * self.angle
		angleHasBeenComputed = false
	end
	-- if ball touch the bottom
	if ball["pos"].y > max["y"] then
		self.angle = -90 + self.angle + math.random() * self.angle
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