wibox = require "wibox"

batteryWidget = (options={}) ->
   opt = {
      timeout: 60
      battery: "BAT0"
      notify: "on"
      normal: color: "#43AB59"
      low:
         percent: 25
         color: "#FFC66D"
      critical:
         percent: 10
         color: "#CD5C5C"
   }

   readBattery = (var) ->
      ok, f = pcall(io.open,'/sys/class/power_supply/'..opt.battery..'/'..var,'r')
      return nil  if not ok or not f
      line = f\lines!!
      f\close!
      return line

   -- Override the options given as an argument
   opt[key] = value for key, value in pairs options
   textbox = wibox.widget.textbox!

   ok, val = pcall(readBattery,'present')
   return nil  if not ok or val != "1"

   timerHandler = ->
      -- Upon resume, sometimes the battery isn't initialized
      return  if readBattery('present') != "1"

      current = readBattery('energy_now') or readBattery('charge_now')
      return  unless current
      full = readBattery('energy_full') or readBattery('charge_full')
      return  unless full
      percentage = math.floor(current / full * 100)
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
