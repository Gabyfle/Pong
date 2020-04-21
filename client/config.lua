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
		ip = '0.0.0.0',
		port = 8080
	}
}

return config
