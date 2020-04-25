--[--[--------------------]--]--
-- Project: Pong              --
-- File: timer.lua            --
--                            --
-- Author: Gabyfle            --
-- License: Apache 2.0        --
--]--]--------------------[--[--

local timer = {
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

--- Completely stops a timer
function timer:stop(name)
    if not self._timers[name] then return end

    self._timers[name] = nil
end

--- Repeats a "callback" call "repeatitions" times every "delay" seconds
-- @param string name: name of the timer
-- @param number repeatitions: number of times to repeat the process
-- @param number delay: delay between each repeatition
-- @param function callback: callback function to call right after a repeatition ended
function timer:regular(name, repeatitions, delay, callback,  ...)
    if self._timers[name] then return end

    self._timers[name] = {
        repeats = repeatitions,
        thread = coroutine.create(delayer)
    }

    while self._timers[name].repeats do
        coroutine.resume(self._timers[name].thread, delay)

        while coroutine.status(self._timers[name].thread) ~= 'dead' do
            if coroutine.status(self._timers[name].thread) == 'suspended' then
                coroutine.resume(self._timers[name].thread)
                sleep(0.01)
            end
        end

        --- we give to callback the number of left repeatitions
        self._timers[name].repeats = self._timers[name].repeats - 1
        callback(self._timers[name].repeats, ...)
    end

end

--- Returns whether or not a timer does exist
-- @param string name: name of the timer
-- @return bool
function timer:exists(name)
    if self._timers[name] then
        return true
    else
        return false
    end
end

return timer
