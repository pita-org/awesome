local M = {}

M.rrect = function(radius)
  radius = radius or dpi(3)
  return function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, radius)
  end
end

M.addhover = function(element, bg, hbg)
  element:connect_signal('mouse::enter', function(self)
    self.bg = hbg
  end)
  element:connect_signal('mouse::leave', function(self)
    self.bg = bg
  end)
end

M.button = function(cmd, image, color)
  local img = gears.color.recolor_image(
    gears.filesystem.get_configuration_dir() .. "core/theme/icons/google/" .. image .. ".svg", color or beautiful.fg)

  local widget = wibox.widget {
    {
      {
        widget = wibox.widget.imagebox,
        image = img,
        valign = 'center',
        forced_height = 20,
        forced_width = 20,
        resize = true,
      },
      widget = wibox.container.margin,
      margins = 10,
    },
    buttons = {
      awful.button({}, 1, function()
        awful.spawn.with_shell(cmd)
      end)
    },
    widget = wibox.container.background,
    shape = M.rrect(),
    bg = beautiful.bg_2,
  }
  M.addhover(widget, beautiful.bg_2, beautiful.bg .. '99')
  return widget
end

M.colortext = function(txt, fg)
  if fg == "" then
    fg = beautiful.fg
  end

  return "<span foreground='" .. fg .. "'>" .. txt .. "</span>"
end

return M
