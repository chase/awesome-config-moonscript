naughty = require "naughty"
wibox = require "wibox"

readFirstLine = (filename) ->
   -- io.lines is an iterator, first call is the first line
   return io.lines(filename)!

batteryWidget = (options={}) ->
   opt = {
      timeout: 60
      battery: "BAT0"
      notify: "on"
      normal: color: "#43AB59"
      low:
         percent: .25
         color: "#FFC66D"
      critical:
         percent: .1
         color: "#CD5C5C"
   }

   readBattery = (var) ->
      return readFirstLine('/sys/class/power_supply/'..opt.battery..'/'..var)

   -- Override the options given as an argument
   opt[key] = value for key, value in pairs options
   textbox = wibox.widget.textbox!

   return nil  if readBattery('present') != "1"

   timerHandler = ->
      current = readBattery('energy_now') or readBattery('charge_now')
      full = readBattery('energy_full') or readBattery('charge_full')
      percentage = current / full * 100
      batteryPercent = string.format(" %d%% ", percentage)
      if percentage <= opt.critical.percent
         return textbox\set_markup "<span color='#{opt.critical.color}'>#{batteryPercent}</span>"
      if percentage <= opt.low.percent
         return textbox\set_markup "<span color='#{opt.low.color}'>#{batteryPercent}</span>"
      return textbox\set_markup "<span color='#{opt.normal.color}'>#{batteryPercent}</span>"

   -- Setup the widget
   timerHandler!

   -- Update the widget based on the timeout
   updateTimer = timer(timeout: opt.timeout)
   updateTimer\connect_signal "timeout", timerHandler
   updateTimer\start()

   return textbox

return batteryWidget
