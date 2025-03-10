local title = wibox.widget {
  widget = wibox.widget.imagebox,
  image = config_dir .. "/core/theme/pfp/pfp.svg",
}
title = wibox.container.background(title, beautiful.bg_3)
help.addhover(title, beautiful.bg_3, beautiful.blue)

return title
