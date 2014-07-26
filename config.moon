gears = require "gears"
awful = require "awful"
awful.rules = require "awful.rules"
require "awful.autofocus"
wibox = require "wibox"
beautiful = require "beautiful"
naughty = require "naughty"
menubar = require "menubar"
mouseHandler = require "mouseHandler"
keyHandler = require "keyHandler"

unpackJoin = (tablesTable) -> awful.util.table.join(unpack(tablesTable))
curdir = debug.getinfo(1, "S").source\sub(2)\match("(.*/)")

interceptSpotify = (data, appname, replaces_id, icon, title, text, actions, hints, expire)->
   if appname == "Spotify"
      return false
   return true

shrinkNotifications = (args)->
   args.icon_size = 48
   return args

naughty.config.presets.low.callback = interceptSpotify
naughty.config.notify_callback = shrinkNotifications


do
   in_error = false
   awesome.connect_signal "debug::error", (err)->
      return  if in_error
      in_error = true
      naughty.notify {
         preset: naughty.config.presets.critical,
         title: "Oops, an error happened!",
         text:err
      }
      in_error = false

-- {{{ Variable definitions
beautiful.init(curdir.."themes/focuspoint/theme.lua")

terminal = "urxvt"
editor = "gvim"
editor_cmd = terminal .. " -e " .. editor

modkey = "Mod4"

with awful.layout
   .layouts = {
      .suit.tile.left,
      .suit.tile,
      .suit.tile.bottom,
      .suit.tile.top,
      .suit.fair,
      .suit.fair.horizontal,
      .suit.spiral,
      .suit.spiral.dwindle,
      .suit.max,
      .suit.max.fullscreen,
      .suit.magnifier,
      .suit.floating
   }
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper
   for s = 1, screen.count!
      gears.wallpaper.maximized(beautiful.wallpaper, s, true)
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count!
   -- Each screen has its own tag table.
   tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, awful.layout.layouts[1])
-- }}}

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock!

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {
   buttons: do
      :tag = awful
      mouseHandler
         left: tag.viewonly
         right: tag.viewtoggle
         scroll:
            up: (t)-> tag.viewnext(tag.getscreen(t))
            down: (t)-> tag.viewprev(tag.getscreen(t))
         meta:
            left: client.movetotag
            right: client.toggletag
}

mytasklist = {
   buttons: mouseHandler
      left: (c)->
         if c == client.focus
            c.minimized = true
         else
            c.minimized = false
            awful.tag.viewonly(c\tags![1])  if not c\isvisible!
            client.focus = c
            c\raise!
      right: ->
         if not instance
            instance = awful.menu.clients(theme: width: 250)
         else
            instance\hide!
            instance = nil
      scroll:
         up: ->
            awful.client.focus.byidx(1)
            client.focus\raise!  if client.focus
         down: ->
            awful.client.focus.byidx(-1)
            client.focus\raise!  if client.focus
}

for s = 1, screen.count!
   -- Create a promptbox for each screen
   mypromptbox[s] = awful.widget.prompt!
   -- Create an imagebox widget which will contains an icon indicating which layout we're using.
   -- We need one layoutbox per screen.
   mylayoutbox[s] = awful.widget.layoutbox(s)
   mylayoutbox[s]\buttons do
      :layout = awful
      mouseHandler
         left: -> layout:inc(1)
         right: -> layout:inc(-1)
         scroll:
            up: -> layout:inc(1)
            down: -> layout:inc(-1)
   -- Create a taglist widget
   mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

   -- Create a tasklist widget
   mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

   -- Create the wibox
   mywibox[s] = awful.wibox(position: "top", screen: s)

   -- Widgets that are aligned to the left
   left_layout = wibox.layout.fixed.horizontal!
   left_layout\add(mytaglist[s])
   left_layout\add(mypromptbox[s])

   -- Widgets that are aligned to the right
   right_layout = wibox.layout.fixed.horizontal!
   right_layout\add(wibox.widget.systray!)
   right_layout\add(mytextclock)
   right_layout\add(mylayoutbox[s])

   -- Now bring it all together (with the tasklist in the middle)
   layout = wibox.layout.align.horizontal!
   layout\set_left(left_layout)
   layout\set_middle(mytasklist[s])
   layout\set_right(right_layout)

   mywibox[s]\set_widget(layout)
-- }}}

-- {{{ Mouse bindings
   root.buttons mouseHandler
      scroll:
         up: awful.tag.viewnext
         down: awful.tag.viewprev
-- }}}

-- {{{ Key bindings
globalkeys = do
   :tag, util:spawn:launch = awful
   keyHandler
       -- Volume keys
      "XF86AudioRaiseVolume": -> launch("amixer set Master 9%+", false)
      "XF86AudioLowerVolume": -> launch("amixer set Master 9%-", false)
      "XF86AudioMute": -> launch("amixer set Master toggle", false)
      -- Media keys
      "XF86AudioPrev": -> launch("playerctl previous", false)
      "XF86AudioPlay": -> launch("playerctl play-pause", false)
      "XF86AudioNext": -> launch("playerctl next", false)
      meta:
         -- Standard programs
         f: -> launch("thunar")
         e: -> launch(editor)
         w: -> launch("chromium")
         r: -> launch("xboomx", false)
         "Return": -> launch(terminal)
         -- Jump between tags
         "Left": tag.viewprev
         "Right": tag.viewnext
         -- Layout manipulation
         j: ->
            awful.client.focus.byidx(1)
            client.focus\raise!  if client.focus
         k: ->
            awful.client.focus.byidx(-1)
            client.focus\raise!  if client.focus
         u: awful.client.urgent.jumpto
         "Tab": ->
            awful.client.focus.history.previous!
            client.focus\raise!  if client.focus
         l: -> awful.tag.incmwfact(0.05)
         h: -> awful.tag.incmwfact(-0.05)
         space: -> awful.layout.inc(awful.layout.layouts, 1, 1)
         -- Menubar
         p: -> menubar.show!

         shift:
            j: -> awful.client.swap.byidx(1)
            k: -> awful.client.swap.byidx(-1)
            h: -> awful.tag.incnmaster(1)
            l: -> awful.tag.incnmaster(-1)
            space: -> awful.layout.inc(awful.layout.layouts,-1, 1)

         ctrl:
            j: -> awful.screen.focus_relative(1)
            k: -> awful.screen.focus_relative(-1)
            h: -> awful.tag.incncol(1)
            l: -> awful.tag.incncol(-1)
            r: awesome.restart
            shift: q: awesome.quit
            n: awful.client.restore

clientkeys = keyHandler
   meta:
      ctrl:
         space:  awful.client.floating.toggle
         "Return": (c)-> c\swap(awful.client.getmaster!)
      q: (c)-> c\kill!
      o: awful.client.movetoscreen
      t:(c)-> c.ontop = not c.ontop
      n:(c)-> c.minimized = true
      m: (c)->
         c.maximized_horizontal = not c.maximized_horizontal
         c.maximized_vertical = not c.maximized_vertical

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9
   globalkeys = awful.util.table.join globalkeys,
      keyHandler
         meta:
            -- View tag only
            ['#'..i+9]: ->
               screen = mouse.screen
               tag = awful.tag.gettags(screen)[i]
               awful.tag.viewonly(tag)
            -- Move client to tag
            shift: ['#'..i+9]: ->
               if client.focus
                  tag = awful.tag.gettags(client.focus.screen)[i]
                  awful.client.movetotag(tag)  if tag
            -- Toggle tag
            ctrl:
               ['#'..i+9]: ->
                  screen = mouse.screen
                  tag = awful.tag.gettags(screen)[i]
                  awful.tag.viewtoggle(tag)  if tag
               shift: ['#'..i+9]: ->
                     if client.focus
                        tag = awful.tag.gettags(client.focus.screen)[i]
                        awful.client.toggletag(tag)  if tag

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
clientbuttons = mouseHandler
   left: (c)->
      client.focus = c
      c\raise!
   meta:
      left: awful.mouse.client.move
      right: awful.mouse.client.resize

awful.rules.rules = {
   {
      -- All clients will match this rule.
      rule: {}
      properties:
         border_width: beautiful.border_width
         border_color: beautiful.border_normal
         focus: awful.client.focus.filter
         raise: true
         keys: clientkeys
         buttons: clientbuttons
   }
   {
      rule: class: "Oblogout"
      properties: fullscreen: true
   }
   {
      --Without compositing, LINE leaves black boxes on top
      rule: instance: "Line.exe"
      except: name: "emoji"
      properties:
         floating: false
         size_hints_honor: false
      callback: (c)->
         c\kill!  if c.name == nil
   }
   {
      rule: instance: "Line.exe", name: "emoji"
      properties:
         floating: true
         raise: true
         focus: true
      callback: (c)->
         g=c\geometry!
         mouse.coords({
            x:g.x+(g.width/2)
            y:g.y+(g.height/2)
         })
         awful.client.setslave(c)
   }
}

-- Enable sloppy focus
client.connect_signal("mouse::enter", (c)->
   return  if awful.layout.get(c.screen) == awful.layout.suit.magnifier
   client.focus = c  if awful.client.focus.filter(c))

client.connect_signal("focus", (c)-> c.border_color = beautiful.border_focus)
client.connect_signal("unfocus", (c)-> c.border_color = beautiful.border_normal)
-- }}}
