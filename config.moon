gears = require "gears"
awful = require "awful"
awful.rules = require "awful.rules"
require "awful.autofocus"
wibox = require "wibox"
beautiful = require "beautiful"
naughty = require "naughty"
menubar = require "menubar"
mouseHandler = require "handler.mouse"
keyHandler = require "handler.key"
battery = require "battery"
taglist = require "taglist"
lainLayout = require "lain.layout"
tzclock = require "tzclock"

unpackJoin = (tablesTable) -> awful.util.table.join(unpack(tablesTable))
curdir = debug.getinfo(1, "S").source\sub(2)\match("(.*/)")

naughty.config.defaults.height = 24
naughty.config.defaults.width = 200

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

shell = (...)-> awful.util.spawn_with_shell(table.concat({...}," "), false)
-- Compositing
shell "killall compton; sleep 2s && compton",
   "-cCzG -t-3 -l-5 -r4",
   "--config /dev/null",
   "--backend glx --xrender-sync-fence --unredir-if-possible",
   "--shadow-exclude 'argb && _NET_WM_OPAQUE_REGION@:c || bounding_shaped'"

-- {{{ Variable definitions
beautiful.init(curdir.."themes/focuspoint/theme.lua")

terminal = "urxvt"
editor_cmd = "cd ~/Development && urxvt -e vim -c 'Unite directory -no-split -start-insert -default-action=cd'"

modkey = "Mod4"

with lainLayout.centerfair
   .nmaster = 1
   .ncol = 2

with awful.layout
   .layouts = {
      lainLayout.uselesspiral.dwindle,
      lainLayout.uselessfair.horizontal,
      lainLayout.uselessfair.vertical,
      lainLayout.centerwork,
      lainLayout.centerfair,
      .suit.max.fullscreen,
      .suit.floating
   }
-- }}}

-- Window switcher
switcher = (all) ->
   now = if all then "-now" else "-dnow"
   shell "killall simpleswitcher;",
      "simpleswitcher",
      now,
      "-bw '#{beautiful.border_width}'",
      "-bc '#{beautiful.border_focus}'",
      "-hlbg '#{beautiful.bg_focus}'",
      "-hlfg '#{beautiful.fg_focus}'",
      "-bg '#{beautiful.bg_normal}'",
      "-fg '#{beautiful.fg_normal}'",
      "-font 'Input:pixelsize=14'"

-- {{{ Wallpaper
if beautiful.wallpaper
   for s = 1, screen.count!
      gears.wallpaper.maximized(beautiful.wallpaper, s, true)
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
musicIcon = "6 <span font='FontAwesome 10'>  </span>"
chatIcon = "7 <span font='FontAwesome 10'>  </span>"
mytags = awful.tag({ 1, 2, 3, 4, 5, musicIcon, chatIcon }, s, awful.layout.layouts[1])
for s = 1, screen.count!
   -- Duplicate tags for each screen
   tags[s] = mytags
-- }}}

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
myclock = tzclock("EDT", -5)
nswclock = tzclock("AEST", 9) -- Doesn't account for daylight time

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist =
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

clientsmenu = nil
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
         if not clientsmenu
            clientsmenu = awful.menu.clients(theme: width: 250)
         else
            clientsmenu\hide!
            clientsmenu = nil
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
      :layouts, :inc = awful.layout
      mouseHandler
         left: -> inc(layouts, 1, 1)
         right: -> inc(layouts, -1, 1)
         scroll:
            up: -> inc(layouts, 1, 1)
            down: -> inc(layouts, -1, 1)
   -- Create a taglist widget
   mytaglist[s] = taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

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
   right_layout\add(myclock)
   right_layout\add(nswclock)
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
      swipeRight: awful.tag.viewnext
      swipeLeft: awful.tag.viewprev
-- }}}

focusByDirection = (dir) ->
   awful.client.focus.bydirection(dir)
   client.focus\raise!  if client.focus

-- {{{ Key bindings
globalkeys = do
   :tag, util:spawn:launch = awful
   keyHandler
      -- Display keys
      "XF86MonBrightnessUp": -> launch "xbacklight -inc 7", false
      "XF86MonBrightnessDown": -> launch "xbacklight -dec 7", false
      -- Volume keys
      "XF86AudioRaiseVolume": -> launch "amixer set Master 9%+", false
      "XF86AudioLowerVolume": -> launch "amixer set Master 9%-", false
      "XF86AudioMute": -> launch "amixer set Master toggle", false
      -- Media keys
      "XF86AudioPrev": -> launch "playerctl previous", false
      "XF86AudioPlay": -> launch "playerctl play-pause", false
      "XF86AudioNext": -> launch "playerctl next", false
      meta:
         -- Standard programs
         f: -> launch "thunar"
         e: -> shell editor_cmd
         w: -> launch "google-chrome-beta"
         r: -> launch "xboomx", false
         "Return": -> launch terminal
         -- Jump between tags
         "Left": tag.viewprev
         "Right": tag.viewnext
         -- Layout manipulation
         j: -> focusByDirection("down")
         k: -> focusByDirection("up")
         h: -> focusByDirection("left")
         l: -> focusByDirection("right")
         u: awful.client.urgent.jumpto
         "Tab": -> switcher(true)
         ";": -> switcher(false)
         space: -> awful.layout.inc(awful.layout.layouts, 1, 1)
         -- Menubar
         p: -> menubar.show!

         shift:
            j: -> awful.client.swap.byidx(1)
            k: -> awful.client.swap.byidx(-1)
            h: -> awful.tag.incnmaster(1)
            l: -> awful.tag.incnmaster(-1)
            space: -> awful.layout.inc(awful.layout.layouts,-1, 1)
            n: awful.client.restore

         ctrl:
            j: -> awful.tag.incmwfact(0.05)
            k: -> awful.tag.incmwfact(-0.05)
            h: -> awful.tag.incncol(1)
            l: -> awful.tag.incncol(-1)
            r: awesome.restart
            shift: q: awesome.quit

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
for i = 1, 7
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
   swipeRight: (c)-> awful.tag.viewnext(c.screen)
   swipeLeft: (c)-> awful.tag.viewprev(c.screen)
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
      -- Start Slack in chat tag
      rule: instance: "crx_cnjajkcaapiegeibkcdbomdebcjoklnl"
      properties: tag: mytags[7]
   }
   {
      -- Start Spotify in music tag
      rule: class: "Spotify"
      properties: tag: mytags[6]
   }
   {
      rule: class: "Oblogout"
      properties: fullscreen: true
   }
   {
      rule: class: "simpleswitcher"
      properties:
         raise: true
         focus: true
   }
}

-- Enable sloppy focus
client.connect_signal("mouse::enter", (c)->
   return  if awful.layout.get(c.screen) == awful.layout.suit.magnifier
   client.focus = c  if awful.client.focus.filter(c))

client.connect_signal("focus", (c)-> c.border_color = beautiful.border_focus)
client.connect_signal("unfocus", (c)-> c.border_color = beautiful.border_normal)
-- }}}
