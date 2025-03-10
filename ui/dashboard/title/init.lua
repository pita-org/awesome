local widget = wibox.widget {
  {
    {
      require("ui.dashboard.title.title"),
      widget = wibox.container.background,
      bg = beautiful.bg_3,
      shape = help.rrect(),
      forced_width = 40
    },
    nil,
    {
      {
        widget = wibox.widget.textbox,
        markup = help.colortext(" Time and date ", beautiful.fg),
        font = beautiful.font_custom .. "15"
      },
      widget = wibox.container.background,
      bg = beautiful.bg_3,
      shape = help.rrect(),
    },
    layout = wibox.layout.align.horizontal
  },
  widget = wibox.container.background,
  bg = beautiful.bg_2,
  forced_height = 40
}

return widget
