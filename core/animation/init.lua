--"simple animation module for moving things, i have made this because i havnt been able to use rubatos" - pita

local M = {}
M.easing = {
  linear = function(t) return t end,
  easin = function(t) return t * t end,
  bounce = function(t)
    if t < 0.5 then
      return 4 * t * t
    else
      return 1 - (t - 0.75) * (t - 0.75) * 4
    end
  end,
  sinusoidal = function(t)
    return math.sin((t * math.pi) / 2)
  end,
  quadratic = function(t) return 1 - (1 - t) * (1 - t) end,
  cubic = function(t) return 1 - (1 - t) * (1 - t) * (1 - t) end,
  elastic = function(t)
    local p = 0.3
    return 2 ^ (-10 * t) * math.sin((t - p / 4) * (2 * math.pi) / p) + 1
  end,
  exponential = function(t)
    return t == 1 and 1 or 1 - 2 ^ (-10 * t)
  end
}

function M.animate(params)
  local start_value = params.start or 0
  local target_value = params.target or 1
  local duration = params.duration or 0.5
  local interval = params.interval or 0.016
  local easing = params.easing or M.easing.quadratic
  local on_update = params.update or function() end
  local on_complete = params.complete or function() end

  local time_elapsed = 0
  local current_value = start_value
  local is_paused = false

  on_update(start_value, 0)

  local timer = gears.timer {
    timeout = interval,
    autostart = true,
    callback = function()
      if is_paused then return true end

      time_elapsed = time_elapsed + interval
      local progress = math.min(time_elapsed / duration, 1)
      local eased_progress = easing(progress)
      current_value = start_value + (target_value - start_value) * eased_progress

      on_update(current_value, progress)

      if progress >= 1 then
        timer:stop()
        timer = nil
        on_complete()
        return false
      end
      return true
    end
  }

  return {
    stop = function()
      if timer then
        timer:stop()
        timer = nil
      end
    end,
    pause = function()
      is_paused = true
    end,
    resume = function()
      is_paused = false
    end,
    set_speed = function(speed_multiplier)
      if timer then
        timer.timeout = interval / (speed_multiplier or 1)
      end
    end,
    get_value = function()
      return current_value
    end
  }
end

function M.slide_y(element, params)
  params.update = params.update or function(pos)
    element.y = pos
  end
  return M.animate(params)
end

function M.slide(element, params)
  params.update = params.update or function(pos)
    element.x = pos
  end
  return M.animate(params)
end

function M.progress(params)
  params.update = params.update or function(value)
    if params.progress_bar then
      params.progress_bar:set_value(value)
    end
  end
  return M.animate(params)
end

function M.fade(element, params)
  params.update = params.update or function(value)
    element.opacity = value
  end
  return M.animate(params)
end

--i dont use this rn
function M.resize(element, params)
  local start_width = params.start_width or element.width
  local target_width = params.target_width or element.width
  local start_height = params.start_height or element.height
  local target_height = params.target_height or element.height

  params.start = 0
  params.target = 1
  params.update = function(progress)
    local width = start_width + (target_width - start_width) * progress
    local height = start_height + (target_height - start_height) * progress
    element.width = width
    element.height = height
    if params.on_resize then
      params.on_resize(width, height, progress)
    end
  end

  return M.animate(params)
end

return M
