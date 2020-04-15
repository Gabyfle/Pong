-- This is a very (very) basic timer helper for our server

timer = {
    _timers = {}
}

--- Waits sec seconds
-- took from Lua wiki http://lua-users.org/wiki/SleepFunction
-- @param number sec: seconds to sleep
local function sleep(sec)
    local to = os.time() + sec
    repeat until os.time() > to
end

local function delayer(wait)
    local now   = os.time()
    local delay = os.difftime(os.time(), now)

    while delay < wait do
        coroutine.yield(delay)
        delay = os.difftime(os.time(), now)
    end
end

--- Waits "delay" seconds before calling "callback"
-- @param string name: name of the coroutine
-- @param number delay: delay to wait before calling "callback"
-- @param function callback: function that has to be called right after the timer has ended
function timer:create(name, delay, callback, ...)
    if self._timers[name] then
        error('A timer with name ' .. name .. ' has already been created')
    end

    self._timers[name] = coroutine.create(delayer)
    coroutine.resume(self._timers[name], delay)
    while coroutine.status(self._timers[name]) ~= 'dead' do
        if coroutine.status(self._timers[name]) == 'suspended' then
            coroutine.resume(self._timers[name])
            sleep(1)
        end
    end
    -- launch the callback
    callback(...)
end

--- Completly stop a timer
-- @param string name: timer's unique name
function timer:stop(name)
    if not self._timers[name] then
        error('Unknown timer called ' .. name)
    end

    self._timers[name] = nil
end
