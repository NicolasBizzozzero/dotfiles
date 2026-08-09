---@module 'hl'

-- 1. MONITOR
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@144",
    position = "auto",
    scale    = 1.2,
})

-- 2. PROGRAMS
local terminal = "kitty"
local fileManager = "yazi"
local menu = "rofi -show drun -show-icons"
local browser = "firefox"

-- NVIDIA Wayland Environment Variables
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

-- 3. CORE CONFIGURATION
hl.config({
    ecosystem = {
        no_donation_nag = true,   -- <— kills the donation popup
    },

    input = {
        kb_layout = "fr",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
        numlock_by_default = true,
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = false,
            disable_while_typing = true,
            tap_to_click = false,
            clickfinger_behavior = false,
            middle_button_emulation = false,
            scroll_factor = 1.0,
            drag_lock = false,
        }
    },

    cursor = {
        no_hardware_cursors = true,
    },

    general = {
        gaps_in = 2,
        gaps_out = 3,
        border_size = 1,
        layout = "dwindle",
        col = {
            active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
    },

    decoration = {
        rounding = 2,
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
        },
        shadow = {
            enabled = false,
        },
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        middle_click_paste = false,
    },

    xwayland = {
        force_zero_scaling = true,
    }
})

-- Per-device override — this is its OWN call, not nested in hl.config()
hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})

-- Enable global animations
hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })

hl.curve("sharp", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("snappy", { type = "bezier", points = { {0.1, 1.0}, {0.1, 1.0} } })

hl.animation({ leaf = "windows", enabled = true, speed = 1.5, bezier = "sharp" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, bezier = "default"})
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.5, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "snappy" })
hl.animation({ leaf = "fade", enabled = true, speed = 1.5, bezier = "default" })
hl.animation({ leaf = "fadeIn", enabled = false })

-- 4. WINDOW RULES
hl.window_rule({
    name  = "yad_calendar_rule",
    match = {
        class = "^(yad)$",
    },
    float = true,
    move = "40% 35%",   -- added the missing % so it's a percentage on both axes
    pin = true,
})

-- 5. KEYBINDS (Main Modifier = SUPER)
hl.bind("SUPER + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + D", hl.dsp.exec_cmd(menu))
hl.bind("SUPER + R", hl.dsp.exec_cmd(menu))
hl.bind("SUPER + E", hl.dsp.exec_cmd(fileManager))

hl.bind("SUPER + SHIFT + A", hl.dsp.window.close())
hl.bind("SUPER + F", hl.dsp.window.fullscreen())
hl.bind("SUPER + V", hl.dsp.window.float())
hl.bind("SUPER + P", hl.dsp.window.pseudo())
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"))   -- proper dispatcher instead of shelling out to hyprctl
hl.bind("SUPER + M", hl.dsp.exit())

hl.bind("SUPER + left", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "d" }))

hl.bind("SUPER + SHIFT + left", hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind("SUPER + SHIFT + up", hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + SHIFT + down", hl.dsp.window.move({ direction = "d" }))

hl.bind("SUPER + ampersand", hl.dsp.focus({ workspace = "1" }))
hl.bind("SUPER + eacute", hl.dsp.focus({ workspace = "2" }))
hl.bind("SUPER + quotedbl", hl.dsp.focus({ workspace = "3" }))
hl.bind("SUPER + apostrophe", hl.dsp.focus({ workspace = "4" }))
hl.bind("SUPER + parenleft", hl.dsp.focus({ workspace = "5" }))
hl.bind("SUPER + minus", hl.dsp.focus({ workspace = "6" }))
hl.bind("SUPER + egrave", hl.dsp.focus({ workspace = "7" }))
hl.bind("SUPER + underscore", hl.dsp.focus({ workspace = "8" }))
hl.bind("SUPER + ccedilla", hl.dsp.focus({ workspace = "9" }))
hl.bind("SUPER + agrave", hl.dsp.focus({ workspace = "10" }))

hl.bind("SUPER + SHIFT + ampersand", hl.dsp.window.move({ workspace = "1" }))
hl.bind("SUPER + SHIFT + eacute", hl.dsp.window.move({ workspace = "2" }))
hl.bind("SUPER + SHIFT + quotedbl", hl.dsp.window.move({ workspace = "3" }))
hl.bind("SUPER + SHIFT + apostrophe", hl.dsp.window.move({ workspace = "4" }))
hl.bind("SUPER + SHIFT + parenleft", hl.dsp.window.move({ workspace = "5" }))
hl.bind("SUPER + SHIFT + minus", hl.dsp.window.move({ workspace = "6" }))
hl.bind("SUPER + SHIFT + egrave", hl.dsp.window.move({ workspace = "7" }))
hl.bind("SUPER + SHIFT + underscore", hl.dsp.window.move({ workspace = "8" }))
hl.bind("SUPER + SHIFT + ccedilla", hl.dsp.window.move({ workspace = "9" }))
hl.bind("SUPER + SHIFT + agrave", hl.dsp.window.move({ workspace = "10" }))

hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind("SUPER + L", hl.dsp.exec_cmd("hyprlock"))

-- 6. AUTOSTART
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("wako")
    hl.exec_cmd("/home/johnlocke/scripts/ricing/change_wallpaper.sh")
    hl.exec_cmd("[workspace 1 silent] " .. terminal)
    hl.exec_cmd("[workspace 2 silent] " .. browser)
    hl.exec_cmd("[workspace 8 silent] keepassxc")
end)