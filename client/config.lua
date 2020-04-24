--[--[--------------------]--]--
-- Project: Pong              --
-- File: config.lua           --
--                            --
-- Author: Gabyfle            --
-- License: Apache 2.0        --
--]--]--------------------[--[--

local config = {
	keys = { -- See https://love2d.org/wiki/KeyConstant for available keys
		up = "z",
		down = "s"
	},
	-- server to join
	server = {
		ip = '192.168.1.177',
		port = 15155,
		max_delay = 40
	}
}

return config
