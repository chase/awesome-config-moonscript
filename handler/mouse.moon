mapHandler = require 'handler.map'
awful = require 'awful'

mouse =
   left: 1
   middle: 2
   right: 3
   back: 8
   forward: 9
   scroll:
      up: 4
      down: 5

mouseHandler = (value, implicitUp) ->
   return mapHandler(value, mouse, awful.button, implicitUp)

return mouseHandler
