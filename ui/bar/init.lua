awful.screen.connect_for_each_screen(function(s)
  awful.tag({ "1", " ", " ", "4", " " }, s, awful.layout.layouts[1])

  local separator = wibox.widget {
    {
      widget = wibox.widget.separator,
      orientation = "horizontal",
      forced_height = dpi(2),
      color = beautiful.bg_2,
    },
    widget = wibox.container.place,
    valign = "center",
    content_fill_horizontal = true,
  }

  s.sidebar = awful.wibar({
    position = "bottom",
    screen = s,
    width = s.geometry.width,
    height = dpi(65),
    bg = beautiful.bg,
    fg = beautiful.fg,
    shape = help.rrect(dpi(0)),
  })

  s.sidebar:setup {
    {
      {
        require("ui.bar.modules.personal"),
        require("ui.bar.modules.fullscreen"),
        {
          {
            require("ui.bar.modules.taglist").create_taglist(s),
            widget = wibox.container.margin,
            margins = dpi(8),
          },
          shape = help.rrect(),
          widget = wibox.container.background,
          bg = beautiful.bg_1,
          forced_width = 271
        },
        layout = wibox.layout.fixed.horizontal,
        spacing = 5
      },
      nil,
      {
        require("ui.bar.modules.clock"),
        require("ui.bar.modules.systray"),

        layout = wibox.layout.fixed.horizontal,
        spacing = 5
      },
      layout = wibox.layout.align.horizontal
    },
    widget = wibox.container.margin,
    margins = dpi(8),
  }
end)
