local socket = require('socket')
local json   = require('json')

local server = {
    _serv = {
        socket,
        ip,
        port
    },
    _players = {}
}

--- Server initialization
--- the port is chosed by the OS
function server:init()
    self._serv.socket = assert(socket.bind("*", 0))
    
    -- print to the client that everything is okay
    print('Pong server has been initialized...')
    self._serv.ip, self._serv.port = self._serv.socket:getsockname()
    print('Server IP: ' .. self._serv.ip .. '\nServer PORT: ' .. self._serv.port)
end

--- On server receive
function server:receive(data)
    -- data is sent by client as JSON string
    local decoded = json.decode(data)
    
end

