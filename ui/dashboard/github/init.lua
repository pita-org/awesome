local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")
local gfs = require("gears.filesystem")

-- GitHub notifications widget
local github_widget = {}

-- Widget configuration
local config = {
    timeout = 120,  -- Update every 2 minutes
    max_notifications = 5,
    cache_dir = gfs.get_cache_dir() .. "github_avatars/",
    github_token = os.getenv("GITHUB_TOKEN")  -- Get token from environment variable
}

-- Create cache directory if it doesn't exist
gears.filesystem.make_directories(config.cache_dir)

-- Download avatar and cache it locally
local function download_avatar(username)
    local avatar_path = config.cache_dir .. username .. ".png"

    -- Check if avatar is already cached
    if gfs.file_readable(avatar_path) then
        return avatar_path
    end

    -- Download avatar using curl
    awful.spawn.easy_async(string.format(
        "curl -L 'https://github.com/%s.png' --create-dirs -o %s",
        username,
        avatar_path
    ), function()
        -- Ensure the download was successful
        if not gfs.file_readable(avatar_path) then
            naughty.notify({ text = "Failed to download avatar for " .. username })
        end
    end)

    return avatar_path
end

-- Create the widget
function github_widget:new()
    local widget = wibox.widget {
        layout = wibox.layout.fixed.vertical,
        spacing = 8,
    }

    -- Create notification widget
    local function create_notification_widget(repo_owner, repo_name, title)
        local avatar_path = download_avatar(repo_owner)

        local notif_widget = wibox.widget {
            {
                {
                    {
                        image = avatar_path,
                        forced_width = 40,
                        forced_height = 40,
                        resize = true,
                        widget = wibox.widget.imagebox
                    },
                    shape = gears.shape.circle,
                    widget = wibox.container.background
                },
                {
                    {
                        markup = string.format(
                            "<b>%s/%s</b>",
                            gears.string.xml_escape(repo_owner),
                            gears.string.xml_escape(repo_name)
                        ),
                        widget = wibox.widget.textbox
                    },
                    {
                        text = gears.string.xml_escape(title),
                        widget = wibox.widget.textbox
                    },
                    layout = wibox.layout.fixed.vertical
                },
                spacing = 10,
                layout = wibox.layout.fixed.horizontal
            },
            margins = 8,
            widget = wibox.container.margin
        }

        -- Add hover effect
        local old_cursor, old_wibox
        notif_widget:connect_signal("mouse::enter", function()
            local w = mouse.current_wibox
            old_cursor, old_wibox = w.cursor, w
            w.cursor = "hand1"
        end)

        notif_widget:connect_signal("mouse::leave", function()
            if old_wibox then
                old_wibox.cursor = old_cursor
                old_wibox = nil
            end
        end)

        -- Open notification in browser on click
        notif_widget:buttons(awful.util.table.join(
            awful.button({}, 1, function()
                awful.spawn(string.format("xdg-open https://github.com/%s/%s", repo_owner, repo_name))
            end)
        ))

        return notif_widget
    end

    -- Update notifications
    local function update_notifications()
        awful.spawn.easy_async_with_shell(string.format([[
            curl -s -H 'Authorization: token %s' 'https://api.github.com/notifications' |
            grep -o '"repository":{[^}]*"full_name":"[^"]*"' |
            cut -d'"' -f6
        ]], config.github_token), function(stdout)
            -- Clear existing widgets
            widget:reset()

            -- Process each line of output
            for line in stdout:gmatch("[^\r\n]+") do
                local repo_owner, repo_name = line:match("([^/]+)/([^/]+)")
                if repo_owner and repo_name then
                    widget:add(create_notification_widget(repo_owner, repo_name, "New notification"))
                end
            end
        end)
    end

    -- Set up timer for periodic updates
    gears.timer {
        timeout = config.timeout,
        call_now = true,
        autostart = true,
        callback = update_notifications
    }

    return widget
end

return github_widget
