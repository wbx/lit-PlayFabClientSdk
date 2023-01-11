-- Wrapper for PlayFab calls to make them coro-style.

local coroutine_wrap, coroutine_yield, coroutine_resume, coroutine_running = coroutine.wrap, coroutine.yield, coroutine.resume, coroutine.running

local function assertResume(thread, ...)
  local success, err = coroutine_resume(thread, ...)
  if not success then
    error(debug.traceback(thread, err), 0)
  end
end

local function makeSuccessCb()
  local thread = coroutine_running()
  return function(v, ...)
    assertResume(thread, v == nil and true or v, ...)
  end
end

local function makeErrorCb()
  local thread = coroutine_running()
  return function(...)
    assertResume(thread, nil, ...)
  end
end


local cache = setmetatable({}, {__mode = 'kv'})

local function wrapFn(fn)
    if cache[fn] then return cache[fn] end
    local wrapped = function(req)
        coroutine_wrap(fn)(req, makeSuccessCb(), makeErrorCb())
        return coroutine_yield()
    end
    cache[fn] = wrapped
    return wrapped
end

---@generic T : function|table
---@param obj T
---@return T
local function M(obj)
    if type(obj) == 'function' then
        -- return a coro-style variant of the function
        return wrapFn(obj)
    elseif type(obj) == 'table' then
        -- a whole proxy table that converts functions called in it on the fly (with cache)
        local mt = {}
        mt.__index = function(t, k)
            local o = obj[k]
            if type(o) == 'function' then
                return wrapFn(o)
            else
                return o
            end
        end
        mt.__newindex = function(t, k, v)
            obj[k] = v
        end
        return setmetatable({}, mt)
    else
        error("cannot wrap object with type "..type(obj))
    end
end

return M
