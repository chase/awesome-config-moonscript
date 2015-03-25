----------------------------------
--  "Focuspoint" awesome theme  --
--        By Chase Colman       --
----------------------------------

-- Alternative icon sets and widget icons:
--  * http://awesome.naquadah.org/wiki/Nice_Icons

curdir = debug.getinfo(1, "S").source:sub(2):match("(.*/)")

-- {{{ Main
theme = {}
theme.wallpaper = curdir.."wallpaper.png"
-- }}}

-- {{{ Styles
theme.font      = "Sego UI 9"

-- {{{ Colors
theme.fg_normal  = "#F8F8F2"
theme.fg_focus   = "#F8F8F2"
theme.fg_urgent  = "#43AB59"
theme.bg_normal  = "#232526"
theme.bg_focus   = "#465457"
theme.bg_urgent  = "#232526"
theme.bg_systray = theme.bg_normal
-- }}}

-- {{{ Borders
theme.border_width  = 1
theme.border_normal = "#3F3F3F"
theme.border_focus  = "#6F6F6F"
theme.border_marked = "#CC9393"
-- }}}

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- Example:
--theme.taglist_bg_focus = "#CC9393"
theme.tasklist_disable_icon = true
-- }}}

-- {{{ Widgets
-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.fg_widget        = "#AECF96"
--theme.fg_center_widget = "#88A175"
--theme.fg_end_widget    = "#FF5656"
--theme.bg_widget        = "#494B4F"
--theme.border_widget    = "#3F3F3F"
-- }}}

-- {{{ Mouse finder
theme.mouse_finder_color = "#CC9393"
-- mouse_finder_[timeout|animate_timeout|radius|factor]
-- }}}

-- {{{ Menu
-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_height = 15
theme.menu_width  = 100
-- }}}

-- {{{ Icons
-- {{{ Taglist
theme.taglist_squares_sel   = curdir.."taglist/squarefz.png"
theme.taglist_squares_unsel = curdir.."taglist/squarez.png"
--theme.taglist_squares_resize = "false"
-- }}}

-- {{{ Misc
theme.menu_submenu_icon      = "/usr/share/awesome/themes/default/submenu.png"
-- }}}

-- {{{ Layout
theme.layout_tile       = curdir.."layouts/tile.png"
theme.layout_tileleft   = curdir.."layouts/tileleft.png"
theme.layout_tilebottom = curdir.."layouts/tilebottom.png"
theme.layout_tiletop    = curdir.."layouts/tiletop.png"
theme.layout_fairv      = curdir.."layouts/fairv.png"
theme.layout_fairh      = curdir.."layouts/fairh.png"
theme.layout_spiral     = curdir.."layouts/spiral.png"
theme.layout_dwindle    = curdir.."layouts/dwindle.png"
theme.layout_max        = curdir.."layouts/max.png"
theme.layout_fullscreen = curdir.."layouts/fullscreen.png"
theme.layout_magnifier  = curdir.."layouts/magnifier.png"
theme.layout_floating   = curdir.."layouts/floating.png"
theme.layout_centerfair = curdir.."layouts/centerfair.png"
theme.layout_centerwork = curdir.."layouts/centerwork.png"
theme.layout_uselessfairh = curdir.."layouts/fairh.png"
theme.layout_uselessdwindle = curdir.."layouts/spiral.png"

theme.useless_gap_width = 10
-- }}}

return theme
