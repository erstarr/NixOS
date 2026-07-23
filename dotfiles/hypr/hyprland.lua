-- Refer to the wiki for more information.
-- https://wiki.hypr.land/Configuring/Start/


---------------------------
---- Constant Includes ----
---------------------------

-- If the file depends on a certain value that is defined below these lines; the execution of the function that needs that value MUST be executed by the event loop post config-reading
local sharedConstants = require("./scripts/sharedConstants")






------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/


-- MSI 1440p 180hz Monitor
hl.monitor({
    output   = "DP-1",
    mode     = "2560x1440@180",
    position = "0x0",
    scale    = "1",
    transform = 0
    -- bitdepth = 8, -- This especially is monitor specific!
    -- cm = "srgb",
})


---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
local terminal    = "kitty"


local fileManager_dolphin = "flatpak run org.kde.dolphin"
local fileManager_yazi = terminal.." yazi"

-- Rofi Rounded Corners with proper blurring, use this: -transient-window
local menu = "pkill rofi || rofi -show drun -replace -i" -- Rofi isn't wrapped in nix but do -r just in case


-- Screenshot - Grimblast (Uses grim, slurp, hyprpicker), satty (to edit/annotate the screenshots)
local screenShot = "grimblast -f -t png save area - | satty --filename - --output-filename ~/Pictures/Screenshots/Screenshot-$(date '+%Y%m%d-%H:%M:%S').png"








-- Commands as variables
local waybar_toggle = "pkill waybar || waybar" -- in nix waybar is wrapped. I want to make it work in both nix and arch so just kill by pattern


local swaync_toggle = "swaync-client -t -sw"






-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
-- hl.on("hyprland.start", function () 
--   hl.exec_cmd(terminal)
--   hl.exec_cmd("nm-applet")
--   hl.exec_cmd("waybar & hyprpaper & firefox")
-- end)

hl.on("hyprland.start", function ()

    -- ---------------------------------------------------------------------------------
    -- ---------------------------------------------------------------------------------
    -- THIS IS A PATCH FOR GRAPHICAL SESSION TARGET PROBLEM - NOTED IN OBSIDIAN NOTEBOOK
    --     AFTER A MORE PERMA FIX IS IMPLEMENTED, GET RID OF THIS LINE AS WELL AS DOING
    --        THE STUFF NOTED IN OBSIDIAN NOTEBOOK
    -- ---------------------------------------------------------------------------------
    -- ---------------------------------------------------------------------------------
    hl.exec_cmd("systemctl --user start hyprland-session.target")










    -- Wallpaper ---

    -- The image itself will be variable depending on the theme I'm using

    -- Starts the daemon
    hl.exec_cmd("awww-daemon")

    -- set the wallpaper
    hl.exec_cmd("sleep 0.5 && awww img ~/Documents/Archive/Wallpapers/monochrome-gaze.png --resize crop --transition-type none")

    --  TODO move this to the theme switcher script
    --  Info -- Transition FPS should be the refresh rate of your monitor
    --  exec = awww img ~/Downloads/george-earl-abalayan-nightlordcreeps-earltheartist.jpg --resize crop --transition-type grow --transition-pos top-right --transition-fps 180  # This is for when you are switching configs TODO


    -- Hyprland Plugins - allow (all that are enabled via hyprpm are ran)
    -- hl.exec_cmd("hyprpm reload -n")


    -- Hypridle -- Idle manager
--     hl.exec_cmd("hypridle") ===> THIS IS ENABLED AS A SERVICE IN NIX! In normal linux distros, this should still be started by hyprland


    -- Hyprsunset - Scheduled -- Blue Light / Gamma Filter
    hl.exec_cmd("hyprsunset")

    -- Hyprpolkitagent - Polkitagent
    hl.exec_cmd("systemctl --user start hyprpolkitagent")

    -- waybar
    hl.exec_cmd("waybar")

    -- clipse
    hl.exec_cmd("clipse -listen") -- run listener on startup

end)


hl.on("hyprland.shutdown", function ()


    -- ---------------------------------------------------------------------------------
    -- ---------------------------------------------------------------------------------
    -- THIS IS A PATCH FOR GRAPHICAL SESSION TARGET PROBLEM - NOTED IN OBSIDIAN NOTEBOOK
    --     AFTER A MORE PERMA FIX IS IMPLEMENTED, GET RID OF THIS LINE AS WELL AS DOING
    --        THE STUFF NOTED IN OBSIDIAN NOTEBOOK
    -- ---------------------------------------------------------------------------------
    -- ---------------------------------------------------------------------------------
    os.execute("systemctl --user stop hyprland-session.target && sleep 0.1")









    -- Clean-up awww during shutdown
    hl.exec_cmd("awww clear-cache && pkill awww") -- in nix awww is wrapped. I want to make it work in both nix and arch so just kill by pattern

    -- Clean-up hypridle during shutdown
    hl.exec_cmd("pkill hypridle") -- Not wrapped in nix - kill by pattern just in case

    -- Clean-up hyprsunset during shutdown
    hl.exec_cmd("pkill hyprsunset") -- Not wrapped in nix - kill by pattern just in case

    -- Clean-up waybar during shutdown
    hl.exec_cmd("pkill waybar") -- in nix waybar is wrapped. I want to make it work in both nix and arch so just kill by pattern

    -- clear unpinned clipse clipboard items on shutdown
    hl.exec_cmd("clipse -clear && clipse -clean")

end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

-- Hyprland Default Env Vars (from example config)
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")


-- This part is my doing. Taken From the wiki: https://wiki.hypr.land/Configuring/Environment-variables/ -- Didn't try the aquamarine env vars yet. Should be no need as long as hyprland uses DGPU


hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")


hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- For qt6ct
hl.env("QT_QPA_PLATFORMTHEME","qt6ct")

-- for grimblast - manually passing arguments to slurp
hl.env("SLURP_ARGS", "-c '##ff0000ff'")



-----------------------------------
----- ECOSYSTEM & PERMISSIONS -----
-----------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

hl.config({
    ecosystem = {
        enforce_permissions = false,
        no_donation_nag = true,
    },
})

-- Allow screenshots with grimblast
-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")

-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in  = sharedConstants.HYPRLAND_GAPS_IN,
        gaps_out = sharedConstants.HYPRLAND_GAPS_OUT,

        border_size = sharedConstants.HYPRLAND_BORDER_SIZE,

        col = {
            active_border   = { colors = {"rgba(218,218,218,0.93)", "rgba(195,195,195,0.93)"}, angle = 45 },
            inactive_border = "rgba(89,89,89,0.667)",
        },

        no_focus_fallback = true,


        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,

        layout = "scrolling",


    snap = {
      enabled = true,
      window_gap = 10,
      monitor_gap = 10,
      border_overlap = false,
      respect_gaps = false,
    },


  },
})


hl.config({
    decoration = {
        rounding       = sharedConstants.HYPRLAND_ROUNDING,
        rounding_power = 2,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        fullscreen_opacity = 1.0,

        dim_inactive = false,
        --How much to dim the rest of the screen by when a special workspace is open
        dim_special = 0.7,

        border_part_of_window = true,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 1,
            color        = "rgba(26,26,26,0.933)",
        },

        blur = {
            enabled   = true,
            size      = 8,
            passes    = 2,
            ignore_opacity = true,
            xray = false,
            vibrancy  = 0.1696,
            special = false,
            popups = true,
        },

        glow = {
            enabled = false,
        },

        -- motion_blur = {
        --     enabled = false
        -- },
  },
})

hl.config({
    animations = {
        enabled = true,
    },
})

-- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

-- Default springs (Modified)
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 878.5, dampening = 59.29 })

hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true,  speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.1,  spring = "easy",         style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 7,    bezier = "quick" })

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only"
-- uncomment all if you wish to use that.
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
    dwindle = {        
        preserve_split = true, -- You probably want this
        smart_split = true,
        smart_resizing = true,
        use_active_for_splits = false,
        precise_mouse_move = true,
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
    master = {
        new_status = "slave",
        orientation = "left",
        mfact = 0.50,
        smart_resizing = true,
        drop_at_cursor = true,
        always_keep_position = false,
        center_master_fallback = "right",
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
    scrolling = {
        fullscreen_on_one_column = false,
        column_width = 0.5,
        focus_fit_method = 1,
        follow_focus = false,
--      follow_min_visible = 0.4, -- This is only for when follow_focus = true
--      explicit_column_widths = "...", I don't use +/-conf
        wrap_focus = false,
        wrap_swapcol = false,
        direction = "right",
    },
})

-- No config options yet
-- hl.config({
--     monocle = {
--     }
-- })



----------------
---- Groups ----
----------------

hl.config({
    group = {

        auto_group = false,
        insert_after_current = true,
        focus_removed_window = true,
        drag_into_group = 2,
        merge_groups_on_drag = false,
        merge_groups_on_groupbar = true,
        merge_floated_into_tiled_on_groupbar = false, -- whether dragging a floating window into a tiled window groupbar will merge them
        group_on_movetoworkspace = false,


        col = {
            -- Groups Border Color
            border_active = { colors = {"rgba(218,218,218,0.93)", "rgba(195,195,195,0.93)"}, angle = 45 },
            border_inactive = "rgba(89,89,89,0.667)",
            border_locked_active = { colors = {"rgba(218,169,136,0.93)", "rgba(218,154,113,0.93)"}, angle = 45 },
            border_locked_inactive = "rgba(89,70,57,0.667)",
        },

        -- TODO in 0.55: need to make an actually good groupbar!
        groupbar = {

            enabled = true,


            blur = true,

            font_family = "NotoMono Nerd Font Mono",
            font_size = 10,
            font_weight_active = "normal",
            font_weight_inactive = "book",       

            text_color = "rgba(255,255,255,1)",
            text_color_locked_active = "rgba(255,255,255,1)",
            text_color_inactive = "rgba(255,255,255,0.90)",
            text_color_locked_inactive = "rgba(255,255,255,0.90)",

            col = {
                active = "rgba(141,141,141,0.40)",
                locked_active = "rgba(123,104,91,0.45)",
                inactive = "rgba(41,41,41,0.8)",
                locked_inactive = "rgba(60,51,46,0.7)",
            },


            gradients = true,
            gradient_rounding_power = 1.5,
            gradient_round_only_edges = false,

            height = 16,

            indicator_gap = 0,
            indicator_height = 0,
            
            rounding = 5,
            rounding_power = 1.0,
            round_only_edges = false,
            
            render_titles = true,
            text_offset = 1,
            text_padding = 0,
            
            stacked = false,
            
            scrolling = true,
            
            keep_upper_gap = true,

            middle_click_close = true,
            
            gaps_in = 3,
            gaps_out = 2,

        },

    },
})




----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = 0, -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo = true, -- If true disables the random hyprland logo / anime girl background. :(
        disable_splash_rendering = true,
        

        middle_click_paste = false,

        vrr = 3, -- Make this 0 if there are any problems with Adaptive Sync being on. 3 is for game and video content auto detection.

        always_follow_on_dnd = true,
        layers_hog_keyboard_focus = true, -- If true, will make keyboard-interactive layers keep their focus on mouse move (e.g. wofi, bemenu)

        animate_manual_resizes = false,
        animate_mouse_windowdragging = false,

        disable_autoreload = false,

        enable_swallow = true, -- probably need to write a regex for this
        swallow_regex = "^(?i)(kitty|alacritty)$", -- Add terminals/apps as you get em.

        focus_on_activate = false,

        mouse_move_focuses_monitor = true,

        allow_session_lock_restore = true, -- Allows the restarting of a lockscreen app - in case it crashes

        close_special_on_empty = true, -- Close spcial workspace when it is empty


        on_focus_under_fullscreen = 2,
        exit_window_retains_fullscreen = false,

        -- render_unfocused_fps = 15, -- Let deafult be, but be aware that this is an option

        size_limits_tiled = false, -- whether to apply min_size and max_size rules to tiled windows

        -- disable_watchdog_warning = false, -- THIS IS ONLY TO BE USED IN DEBUG ENVIRONMENTS (in those envs make it true)

    },
})




----------------
---- Layout ----
----------------

-- hl.config({
--     layout = {

--     },
-- })







---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        numlock_by_default = false, -- handled by mobo on aorus b650e

        follow_mouse = 1,
        focus_on_close = 1, -- set to 1, focus will shift to the window under the cursor
        float_switch_override_focus = 2,

        special_fallthrough = false,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        -- scroll_method = "2fg", -- touchpad scrolling related
        
        touchpad = {
            natural_scroll = false,
        },

        touchdevice = {
            enabled = true,
        },


        -- virtualkeyboard = {
        -- },

        -- tablet = {
        -- },

    },
})


hl.config({
    cursor = {
        invisible = false,
        inactive_timeout = 0,
        no_warps = false,
        warp_on_change_workspace = 0,
        warp_on_toggle_special = 0,
        hide_on_key_press = false,
        hide_on_touch = true,
        warp_back_after_non_mouse_input = false,
    }
})


-- hl.config({
--     gestures = {
--     }
-- })



-- hl.gesture({
--     fingers = 3,
--     direction = "horizontal",
--     action = "workspace"
-- })

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
-- hl.device({
--     name        = "epic-mouse-v1",
--     sensitivity = -0.5,
-- })




---------------------
------- Binds -------
---------------------

hl.config ({
    binds = {
        pass_mouse_when_bound = false, -- if disabled, will not pass the mouse events to apps / dragging windows around if a keybind has been triggered.
        workspace_back_and_forth = false,
        hide_special_on_workspace_change = true,
        allow_workspace_cycles = false,
        workspace_center_on = 0,
        focus_preferred_method = 0, -- 0 -> history have prio, 1-> longest edge has prio. With scrolling longest edge means little
        ignore_group_lock = false,
        movefocus_cycles_fullscreen = false,
        movefocus_cycles_groupfirst = false,
        window_direction_monitor_fallback = false, -- multi-monitor stuff
        disable_keybind_grabbing = false, -- If enabled, apps that request keybinds to be disabled (e.g. VMs) will not be able to do so.
        allow_pin_fullscreen = true, -- If enabled, Allow fullscreen to pinned windows, and restore their pinned status afterwards
    },
})





------------------------
------- XWayland -------
------------------------



hl.config({
    xwayland = {
        enabled = true,
    },
})


------------------------
-------- OpenGL --------
------------------------


-- hl.config({
--     opengl = {
--     },
-- })






----------------------
------- Render -------
----------------------



-- hl.config({
--     render = {
--     },
-- })










----------------------
------- Quirks -------
----------------------



-- hl.config({
--     quirks = {
--     },
-- })









---------------------
------- Debug -------
---------------------

-- ---THIS IS FOR DEBUGGING!

-- hl.config({
--     debug = {
--         disable_logs = false,
--         enable_stdout_logs = true,
--     },
-- })






-------------------------
---- Script Includes ----
-------------------------

-- If the file depends on a certain value that is defined below these lines; the execution of the function that needs that value MUST be executed by the event loop post config-reading
local sharedScripts = require("./scripts/sharedScripts")
local scrollingScripts = require("./scripts/scrollingScripts")
local minimiseScripts = require("./scripts/minimiseScripts")



---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))

hl.bind(mainMod .. " + CTRL + ALT + SHIFT + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

-- open file managers
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager_yazi))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(fileManager_dolphin))

-- Waybar Toggle
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(waybar_toggle))

-- Sway Control Center / Notification Bar
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(swaync_toggle))

-- Screenshot
hl.bind(mainMod .. " + F5", hl.dsp.exec_cmd(screenShot))

-- Clipboard - Clipse
-- Standard clipse command from its git page + paste the currently copied element into stdout, wait 0.7 seconds, then simulate Ctrl + v with wtype: functionally auto-paste without messing with what clipse git page says to do to get its own auto-paste working
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("~/.config/clipse/scripts/clipse_launch_w_AutoPaste_command.sh"))


-- Backup clipboard command - pumps clipse contents to rofi dmenu. This is for when clipse bugs out as it happens sometimes and fails to paste certain text content
-- clipse -output-all raw to print clipboard contents to stdout
-- sed command to remove the "" which enclose each clipboard item in clipse's output for display in dmenu, and then add them back in so jq can parse it as json
-- jq to transform the text from json to raw so newlines actually act as newlines and don't print '\n'
-- wl-copy --trim-newline --> trim-newline to trim the trailing newline that rofi dmenu puts
-- sleep to give me time to focus on the correct window
-- wtype to simulate Ctrl + V keystroke 
-- STRING FORMAT: [[ ]] is the lua long string literal syntax; since "" in the command caused problems with the fact that the whole command also has to be a string
-- IMPORTANT: THE COMMAND ITSELF DOESN'T HAVE THE [[ ]] PART! THAT IS LUA SYNTAX!
hl.bind(mainMod .. " + CTRL + SHIFT + V", hl.dsp.exec_cmd([[clipse -output-all raw | sed 's/^"//; s/"$//' | rofi -dmenu -i -lines 8 -theme-str 'window { width:45em; }' -theme-str 'listview { columns: 2; lines: 8; cycle: false; } element-icon { size: 0em; margin: 0; }' | sed 's/^/"/; s/$/"/' | jq -r . | wl-copy --trim-newline && sleep 0.7 && wtype -M ctrl v -m ctrl]]))




-- Close a window. -- sample of how one can enable/disable binds
local closeWindowBind = hl.bind(mainMod .. " + ESCAPE", hl.dsp.window.close())
closeWindowBind:set_enabled(true)

-- kill a window
hl.bind(mainMod .. " + SHIFT + ESCAPE", hl.dsp.window.kill())


-- float active window
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle", window = "activewindow" }))


-- pin window
hl.bind(mainMod .. " + K", hl.dsp.window.pin({ window = "activewindow" }))


-- open menu
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))


-- set active window as pseudotiling
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo({ action = "toggle", window = "activewindow" }))


-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))


-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i, follow = false }))
end


-- Move active window to the workspace right/left of the current one
hl.bind(mainMod .. " + ALT + left",  hl.dsp.window.move({
    workspace = "r-1",
    follow = false,
}))

hl.bind(mainMod .. " + ALT + right",  hl.dsp.window.move({
    workspace = "r+1",
    follow = false,
}))



-- Special Workspace "A"
hl.bind(mainMod .. " + A",         hl.dsp.workspace.toggle_special("A"))
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.window.move({ workspace = "special:A", follow = false}))

-- Special Workspace "S"
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("S"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:S", follow = false}))

-- Special Workspace "D"
hl.bind(mainMod .. " + D",         hl.dsp.workspace.toggle_special("D"))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.window.move({ workspace = "special:D", follow = false }))


-- Special Workspaces for Minimise (one per workspace for workspaces 1 through 10 [keypress:0 -> workspace:10])
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + CTRL + " .. key,             hl.dsp.workspace.toggle_special(i .. "_S"))
    hl.bind(mainMod .. " + CTRL + SHIFT + " .. key,     hl.dsp.window.move({ workspace = "special:" .. i .. "_S" , follow = false}))
end





-- TODO: I think I deleted this in my own config(?)
-- -- Scroll through existing workspaces with mainMod + scroll
-- hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
-- hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))


-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })



local function toggleFs(fullscreenMode, layoutAware)


    local mode_string = nil

    if fullscreenMode == 1 then
        mode_string = "maximized"
    elseif fullscreenMode == 2 then
        mode_string = "fullscreen"
    else
        hl.notification.create({ text = "Invalid fullscreenMode passed - This is a bug", timeout = 5000, icon = "error" })
        return

    end


    local window = hl.get_active_window()
    local workspace = sharedScripts.getActiveWorkspace()

    if window == nil or workspace == nil then
        return
    end

    local isWorkspaceLayoutScrolling = workspace.tiled_layout == "scrolling"

    -- Avoid viewport move
    if isWorkspaceLayoutScrolling then
        hl.dispatch(hl.dsp.layout("inhibit_scroll true"))
    end


    -- If we are unFullscreening the window, give the workspace back its gaps (read below comments for why we can't leave this to f[1])
    if window.fullscreen == fullscreenMode then
        -- Scroll specific - don't do that if it's supposed to be max-size -- assumes that the window has no other tag. Turn this into "iterate over all tags" if windows may have more than one tag
        if (isWorkspaceLayoutScrolling) and (window.tags[1] == "scroll_MaximiseCandidate") then
        else    
            sharedScripts.workspaceRule_RemoveGaps(workspace, false)
        end
    end

    -- If there's already a covering FS window in the current workspace, we must have had the gaps modifications done, so skip (also bugs shit out if you do it again)
    if (not workspace.has_fullscreen) then  
        -- If there are other workspace rules in workspace that give gaps, they might take precedence over f[1] so we need to overwrite those rules first.
        -- This is the rule that is used to remove gaps from workspaces in scrolling related (and possibly more in the fuuture) scripts
        sharedScripts.workspaceRule_RemoveGaps(workspace, true)
    end
    
    -- Make workspace rule apply immediately
    hl.exec_scheduled_prop_refresh_immediately()

        -- Avoid viewport move
    if isWorkspaceLayoutScrolling then
        hl.dispatch(hl.dsp.layout("inhibit_scroll false"))
    end

    
    hl.dispatch(hl.dsp.window.fullscreen({
                    mode = mode_string,
                    action = "toggle",
                    window = "activewindow",
                    layout_aware = layoutAware,
                })
    )


end



-- Maximised - Default Handled
hl.bind(mainMod .. " + F", function ()
    toggleFs(1, false)
end)

-- Fullscreen - Default Handled
hl.bind(mainMod .. " + SHIFT + F", function ()
    toggleFs(2, false)
end)

-- Maximised - Layout Handled
hl.bind(mainMod .. " + CTRL + F", function ()
    toggleFs(1, true)
end)

-- Fullscreen - Layout Handled
hl.bind(mainMod .. " + CTRL + SHIFT + F", function ()
    toggleFs(2, true)
end)




-- Minimise Script
hl.bind(mainMod .. " + M", minimiseScripts.minimiseKeybinding)
hl.bind(mainMod .. " + SHIFT + M", minimiseScripts.minimiseGoToMinimisedWorkspace)


-- Move window to the workspace I was on when I opened the special workspace
hl.bind(mainMod .. " + ALT_L", hl.dsp.window.move({ workspace = "e+0" , follow = false}))

-- Cycle through workspaces with keyboard
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.focus({ workspace = "r+1" , on_current_monitor = true}), {repeating = true})
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.focus({ workspace = "r-1" , on_current_monitor = true}), {repeating = true})


-- If currently focused on a floating window, change focus to the last focused tiling window and vice versa
hl.bind("CTRL + ALT + TAB", function ()
    local activewindow = hl.get_active_window()

    if not activewindow then
        hl.notification.create({ text = "Active Window is nil - This is an error!", timeout = 1500, icon = "error" })
    end

    if activewindow.floating then
        -- focus on the last focused tiling window
        hl.dispatch(hl.dsp.focus({
            window = sharedScripts.getLastTiledOrFloatingWindowInWorkspace(true)
        }))
    else
        -- focus on the last focused floating window
        hl.dispatch(hl.dsp.focus({
            window = sharedScripts.getLastTiledOrFloatingWindowInWorkspace(false)
        }))
    end


end)




-- swap two windows (swap with a window in that direction) with keyboard
-- This doesn't preserve a window's size, and the window that was swapped to a position takes the size of the window it just replaces.
-- This can be used in scrolling to move a col all the way left/right since I made it repeating, as long as the above property doesn't get in the way
hl.bind(mainMod .. " + CTRL + left", hl.dsp.window.swap({ direction = "left" }), {repeating = true})
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.swap({ direction = "right" }), {repeating = true})
hl.bind(mainMod .. " + CTRL + up", hl.dsp.window.swap({ direction = "up" }), {repeating = true})
hl.bind(mainMod .. " + CTRL + down", hl.dsp.window.swap({ direction = "down" }), {repeating = true})




-- move window in a direction with keyboard
hl.bind(mainMod .. " + CTRL + ALT + left", hl.dsp.window.move({ direction = "left" }), {repeating = true})
hl.bind(mainMod .. " + CTRL + ALT + right", hl.dsp.window.move({ direction = "right" }), {repeating = true})
hl.bind(mainMod .. " + CTRL + ALT + up", hl.dsp.window.move({ direction = "up" }), {repeating = true})
hl.bind(mainMod .. " + CTRL + ALT + down", hl.dsp.window.move({ direction = "down" }), {repeating = true})


-- Center the active floating window
hl.bind(mainMod .. " + CTRL + ALT + END", hl.dsp.window.center())


-- Resize active window with keyboard
hl.bind(mainMod .. " + CTRL + ALT + SHIFT + left", hl.dsp.window.resize({x = -10, y = 0, relative = true, window = "activewindow"}), {repeating = true})
hl.bind(mainMod .. " + CTRL + ALT + SHIFT + right", hl.dsp.window.resize({x = 10, y = 0, relative = true, window = "activewindow"}), {repeating = true})
hl.bind(mainMod .. " + CTRL + ALT + SHIFT + up", hl.dsp.window.resize({x = 0, y = -10, relative = true, window = "activewindow"}), {repeating = true})
hl.bind(mainMod .. " + CTRL + ALT + SHIFT + down", hl.dsp.window.resize({x = 0, y = 10, relative = true, window = "activewindow"}), {repeating = true})




-- ----- Groups -----

-- toggle group
hl.bind(mainMod .. " + W", hl.dsp.group.toggle({window = "activewindow"}))

-- Switch between tabs in a group
hl.bind(mainMod .. " + BRACKETRIGHT", hl.dsp.group.next(), {repeating = true})
hl.bind(mainMod .. " + BRACKETLEFT", hl.dsp.group.prev(), {repeating = true})

-- Reorder windows inside a group
hl.bind(mainMod .. " + SHIFT + BRACKETRIGHT", hl.dsp.group.move_window({forward = true, window = "activewindow"}), {repeating = true})
hl.bind(mainMod .. " + SHIFT + BRACKETLEFT", hl.dsp.group.move_window({forward = false, window = "activewindow"}), {repeating = true})

-- Lock group - toggle
hl.bind(mainMod .. " + L", hl.dsp.group.lock_active({action = "toggle"}))

-- Move a window in/out of a group if a group exists in that direction, otherwise just move it in that direction
hl.bind(mainMod .. " + CTRL + SHIFT + left", hl.dsp.window.move({ direction = "left", group_aware = true }), {repeating = true})
hl.bind(mainMod .. " + CTRL + SHIFT + right", hl.dsp.window.move({ direction = "right", group_aware = true }), {repeating = true})
hl.bind(mainMod .. " + CTRL + SHIFT + up", hl.dsp.window.move({ direction = "up", group_aware = true }), {repeating = true})
hl.bind(mainMod .. " + CTRL + SHIFT + down", hl.dsp.window.move({ direction = "down", group_aware = true }), {repeating = true})







-- Laptop multimedia keys for volume and LCD brightness

-- Control playing media volume with media shortcuts (with knob set to dispatch XF86AudioRaise/LowerVolume)
-- NOTE: I changed the default step: I made it 1%!
-- -l -> limit. 1.5 -> 150% | 1.0 -> 100% --- I made it 150% (default pulse audio config allows audio amplification)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 1%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 1%-"),      { locked = true, repeating = true })

-- Control playing media position with media shortcuts (with knob set to dispatch XF86AudioRaise/LowerVolume)
hl.bind(mainMod .. " + XF86AudioRaiseVolume", hl.dsp.exec_cmd("playerctl position 2+"), { locked = true, repeating = true })
hl.bind(mainMod .. " + XF86AudioLowerVolume", hl.dsp.exec_cmd("playerctl position 2-"),      { locked = true, repeating = true })

-- This is because the aula f75 has the knob press bound to mute. Instead or remappign the keyboard's buttons in its software, I assign the mute dispatch to pause here
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("playerctl play-pause"),     { locked = true })

-- Due to the the above note and keybind, this is different from the defaults (default is without the $mainMod)
hl.bind(mainMod .. " + XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })


hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true })

-- (relevant to the above header) Don't wanna play with my monitor's brightness levels
-- hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
-- hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })




-----------------------
-- Scrolling Layout ---
-----------------------





-- change the layout of the currently active workspace to Scrolling
hl.bind(mainMod .. " + F9", function()

    local activeWorkspace = sharedScripts.getActiveWorkspace()
    
    hl.workspace_rule({
        workspace = activeWorkspace.name,
        layout = "scrolling"
    })
end)



-- toggle focus_fit_method between Center and Fit
hl.bind(mainMod .. " + SHIFT + F9", function()
    
    local focusfitMethodValue = hl.get_config("scrolling.focus_fit_method")
    
    if focusfitMethodValue == 1 then
        hl.config({
            scrolling = {focus_fit_method = 0}
        })
    else
        hl.config({
            scrolling = {focus_fit_method = 1}
        })
    end
end)



hl.bind(mainMod .. " + Z", scrollingScripts.scroll_focusLeft, {repeating = true})
hl.bind(mainMod .. " + X", scrollingScripts.scroll_focusRight, {repeating = true})

hl.bind(mainMod .. " + C", scrollingScripts.scroll_scrollSpecificMaximse)
-- TODO: full script for restoring the modifications regardless of if the window takes up the entire workarea or not. might be redundant if i can prevent workspace rule problem in alwaysActive script
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.layout("colresize 0.5"))

hl.bind(mainMod .. " + G", hl.dsp.layout("promote"))

-- TODO: a script/binds to move a column long distances horizontally without looping around - repeating.

hl.bind(mainMod .. " + SHIFT + Z", hl.dsp.layout("swapcol l"), {repeating = true})
hl.bind(mainMod .. " + SHIFT + X", hl.dsp.layout("swapcol r"), {repeating = true})



hl.bind(mainMod .. " + CTRL + Z", hl.dsp.layout("colresize -0.1"), {repeating = true})
hl.bind(mainMod .. " + CTRL + X", hl.dsp.layout("colresize +0.1"), {repeating = true})











-------------------
-- Dwindle Layout--
-------------------

-- change the layout of the currently active workspace to Dwindle
hl.bind(mainMod .. " + F10", function()

    local activeWorkspace = sharedScripts.getActiveWorkspace()
    
    hl.workspace_rule({
        workspace = activeWorkspace.name,
        layout = "dwindle"
    })
end)



-- toggle split (top/side) of the current window
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))    -- dwindle only




-------------------
-- Master Layout --
-------------------

-- change the layout of the currently active workspace to Master
hl.bind(mainMod .. " + F11", function()

    local activeWorkspace = sharedScripts.getActiveWorkspace()
    
    hl.workspace_rule({
        workspace = activeWorkspace.name,
        layout = "master"
    })
end)


-- swap currently focused window with master - keep focus on prev focused window
hl.bind(mainMod .. " + SHIFT + F11", hl.dsp.layout("swapwithmaster auto ignoremaster"))

-- change the location of the master window (left<->right)
hl.bind(mainMod .. " + CTRL + F11", hl.dsp.layout("orientationcycle left right"))



-------------------
-- Monocle Layout--
-------------------

-- change the layout of the currently active workspace to Monocle
hl.bind(mainMod .. " + F12", function()

    local activeWorkspace = sharedScripts.getActiveWorkspace()
    
    hl.workspace_rule({
        workspace = activeWorkspace.name,
        layout = "monocle"
    })
end)

-- moving windows in monocle uses mainMod + z/x. The keybind for that is set in the scrolling section. Look there for the section for monocle











--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/



-- ---- Window Rules ----


-- kitty
hl.window_rule({
    name = "kitty floats with certain size",
    match = {
        class = "kitty",
    },
    float = true,
    size = {950, 500},
})


-- clipse
hl.window_rule({
    name = "clipse floats with certain size",
    match = {
        class = "clipse",
    },
    float = true,
    size = {950, 500},
})


-- xdg-desktop-portal-gtk
hl.window_rule({
    name = "xdg-desktop-portal-gtk floats with certain size",
    match = {
        class = "xdg-desktop-portal-gtk",
    },
    float = true,
    size = {1000, 700},
})

-- satty - screenshots
hl.window_rule({
    name = "satty floats",
    match = {
        class = "com.gabm.satty",
    },
    float = true,
})


-- Dolphin
hl.window_rule({
    name = "Dolphin floats with certain size",
    match = {
        class = "org.kde.dolphin",
    },
    float = true,
    size = {1100, 700},

})

-- Konsole - Part of Dolpin in Flatpak (Should be non-functional If I prevent dolphin flatpak from accessing host shell)
hl.window_rule({
    name = "Konsole floats with certain size",
    match = {
        class = "org.kde.konsole",
    },
    float = true,
    size = {700, 500},

})

-- Kate
hl.window_rule({
    name = "Kate floats with certain size",
    match = {
        class = "org.kde.kate",
    },
    float = true,
    size = {1100, 700},

})

-- Firefox Picture-in-Picture
hl.window_rule({
    name = "Firefox Picture-in-Picture floats with certain size at a certain place",
    match = {
        class = "org.mozilla.firefox",
        title = "Picture-in-Picture",
    },
    float = true,
    -- These are monitor specific.
    -- Move's coords are tied to size as it is left corner
    size = {623, 351},
    move = {1936, 31},

})

-- Anki - Create Card
hl.window_rule({
    name = "Anki - Create Card window floats with certain size",
    match = {
        class = "net.ankiweb.Anki",
        title = "Add"
    },
    float = true,
    size = {1100, 700},

})

-- If maximised, have no borders and have no rounding - gaps_out is done via workspace rule as it doesn't exist as a windowrule for now
hl.window_rule({
    name = "maximised: no rounding and borders",
    match = {
        fullscreen_state_internal = 1,
    },
    border_size = 0,
    rounding = 0,
})



-- Example window rules that are useful


local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
suppressMaximizeRule:set_enabled(true)



hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})



-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})




-- ---- Workspace Rules ----


-- make maximised windows have no gaps_out and gaps_in - the border and rounding tweaks are done as a windowrule cuz they stick after a floating window is un-maximised if done here
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })





-- ---Layer Rules---


-- Blur and alpha adjustments for Rofi
hl.layer_rule ({
    match = { namespace = "rofi" },
    blur = true,
    ignore_alpha = 0,
})


-- Blur for waybar
hl.layer_rule({
    match = { namespace = "waybar" },
    blur = true
})


-- Blur and alpha adjustments for swaync
hl.layer_rule({
    match = { namespace = "swaync-control-center" },
    blur = true,
    ignore_alpha = 0.5,
})
hl.layer_rule({
    match = { namespace = "swaync-notification-window" },
    blur = true,
    ignore_alpha = 0.5,
})


-- Prevent borders from showing on screenshots with script -- makes "selection" layers not have animations
local overlayLayerRule = hl.layer_rule({
    name  = "no_anim_for_selection",
    match = { namespace = "selection" },
    no_anim = true,
})







-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)



