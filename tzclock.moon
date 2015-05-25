wibox = require "wibox"

tzClock = (name, offset) ->
    w = wibox.widget.textbox!
    t = timer(timeout: 60)
    handler = ->
        utc = os.date("!*t", os.time!)
        tz = os.time(utc) + offset*3600
        w\set_markup(os.date(" <b>#{name}</b>: %a %b %d, %H:%M ", tz))
    t\connect_signal "timeout", handler
    t\start()
    t\emit_signal("timeout")
    return w

return tzClock
