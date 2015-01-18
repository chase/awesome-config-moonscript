tag = require "awful.tag"
client = require "awful.client"
capi = :client, :screen

groove =
   name: 'groove'
   arrange: (p) ->
      area = p.geometry
      clients = p.clients
      maxwidth = tag.getmwfact(tag.selected(p.screen))

      focus = capi.client.focus
      focus = nil  if focus and focus.screen != p.screen

      if not focus and client.floating.get(focus) or #clients > 0
         focus = clients[1]

      return  unless focus

      geometry = height: area.height - focus.border_width * 2, y: area.y
      geometry.width = area.width * math.sqrt(maxwidth)
      geometry.x = area.x + (area.width - geometry.width)/2

      focus\geometry(geometry)

      if #clients > 1
         for client in *clients
            client.minimized = focus != client

return groove
