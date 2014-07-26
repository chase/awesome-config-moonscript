mapHandler = require 'mapHandler'
awful = require 'awful'

keyHandler = (value, implicitUp) ->
   return mapHandler(value, nil, awful.key, implicitUp)

return keyHandler
