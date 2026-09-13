-- =============================================================================
-- Hyprland Developer Configuration
-- Compositor: Hyprland 0.55+ (Native Lua config)
-- Shell: Noctalia Shell
-- =============================================================================

------------------
---- MONITORS ----
------------------
-- Scale 1.0 for pixel-perfect developer displays
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1.0,
})

---------------------
---- MY PROGRAMS ----
---------------------
local terminal    = "kitty"
local terminalAlt = "ghostty"
local fileManager = "pcmanfm"
local terminalFM  = "kitty -e lf"
local browser     = "firefox"
local monitorApp  = "kitty -e btop"
local ipc         = "noctalia msg "

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function ()
    hl.exec_cmd("noctalia")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("WLR_RENDERER_ALLOW_SOFTWARE", "1")
hl.env("LIBGL_ALWAYS_SOFTWARE", "1")
hl.env("EDITOR", "nvim")
hl.env("VISUAL", "nvim")

-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
    general = {
        gaps_in     = 5,
        gaps_out    = 10,
        border_size = 2,

        col = {
            active_border   = { colors = {"rgba(7aa2f7ee)", "rgba(bb9af7ee)"}, angle = 45 },
            inactive_border = "rgba(414868aa)",
        },

        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 0.95,

        shadow = {
            enabled      = true,
            range        = 6,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled  = true,
            size     = 4,
            passes   = 2,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Animations & Curves
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}    } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}  } })
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  spring = "easy", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

-- Dwindle Layout
hl.config({
    dwindle = {
        preserve_split = true,
    },
    master = {
        new_status = "master",
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
})

---------------
---- INPUT ----
---------------
hl.config({
    input = {
        kb_layout    = "us",
        kb_variant   = "",
        kb_model     = "",
        kb_options   = "",
        follow_mouse = 1,
        sensitivity  = 0,
    },
})

---------------------
---- KEYBINDINGS ----
---------------------
local mainMod = "SUPER"

-- Developer Terminal bindings
hl.bind(mainMod .. " + Return",         hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q",              hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + Return",   hl.dsp.exec_cmd(terminalAlt))

-- Window close & layout control
hl.bind(mainMod .. " + C",              hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q",      hl.dsp.window.close())
hl.bind(mainMod .. " + F",              hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + V",              hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + Space",  hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P",              hl.dsp.window.pseudo())
hl.bind(mainMod .. " + T",              hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + M",              hl.dsp.exit())

-- Application Launchers
hl.bind(mainMod .. " + B",              hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + E",              hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SHIFT + E",      hl.dsp.exec_cmd(terminalFM))
hl.bind(mainMod .. " + Escape",         hl.dsp.exec_cmd(monitorApp))

-- Noctalia Shell Binds
hl.bind(mainMod .. " + Space",          hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))
hl.bind(mainMod .. " + D",              hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))
hl.bind(mainMod .. " + R",              hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))
hl.bind(mainMod .. " + N",              hl.dsp.exec_cmd(ipc .. "panel-toggle control-center"))
hl.bind(mainMod .. " + comma",          hl.dsp.exec_cmd(ipc .. "settings-toggle"))
hl.bind(mainMod .. " + W",          hl.dsp.exec_cmd(ipc .. "wallpaper-random"))
hl.bind(mainMod .. " + CTRL + L",       hl.dsp.exec_cmd(ipc .. "session lock"))
hl.bind("CTRL + ALT + L",               hl.dsp.exec_cmd(ipc .. "session lock"))
hl.bind("ALT + Tab",                    hl.dsp.exec_cmd(ipc .. "window-switcher"))

-- Screenshot
hl.bind("Print",                        hl.dsp.exec_cmd(ipc .. "screenshot-region"))
hl.bind(mainMod .. " + Print",          hl.dsp.exec_cmd(ipc .. "screenshot-fullscreen"))
hl.bind(mainMod .. " + SHIFT + S",      hl.dsp.exec_cmd(ipc .. "screenshot-region"))

-- Focus Window (Vim keys + Arrows)
hl.bind(mainMod .. " + H",              hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L",              hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K",              hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J",              hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + left",           hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right",          hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",             hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",           hl.dsp.focus({ direction = "down" }))

-- Move Window (Vim keys + Arrows - native dispatchers)
hl.bind(mainMod .. " + SHIFT + H",      hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L",      hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K",      hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J",      hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + left",   hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right",  hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",     hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",   hl.dsp.window.move({ direction = "down" }))

-- Resize Window (Vim keys + Arrows - native dispatchers)
hl.bind(mainMod .. " + ALT + H",        hl.dsp.window.resize({ x = -30, y = 0 }))
hl.bind(mainMod .. " + ALT + L",        hl.dsp.window.resize({ x = 30, y = 0 }))
hl.bind(mainMod .. " + ALT + K",        hl.dsp.window.resize({ x = 0, y = -30 }))
hl.bind(mainMod .. " + ALT + J",        hl.dsp.window.resize({ x = 0, y = 30 }))
hl.bind(mainMod .. " + ALT + left",     hl.dsp.window.resize({ x = -30, y = 0 }))
hl.bind(mainMod .. " + ALT + right",    hl.dsp.window.resize({ x = 30, y = 0 }))
hl.bind(mainMod .. " + ALT + up",       hl.dsp.window.resize({ x = 0, y = -30 }))
hl.bind(mainMod .. " + ALT + down",     hl.dsp.window.resize({ x = 0, y = 30 }))

-- Workspaces 1-10
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,           hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,   hl.dsp.window.move({ workspace = i }))
end

-- Special Scratchpad Workspace
hl.bind(mainMod .. " + S",              hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + Z",      hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through workspaces with mouse wheel
hl.bind(mainMod .. " + mouse_down",     hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",       hl.dsp.focus({ workspace = "e-1" }))

-- Move & Resize with mouse
hl.bind(mainMod .. " + mouse:272",       hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273",       hl.dsp.window.resize(), { mouse = true })

-- Media keys
hl.bind("XF86AudioRaiseVolume",         hl.dsp.exec_cmd(ipc .. "volume-up"),   { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",         hl.dsp.exec_cmd(ipc .. "volume-down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",                hl.dsp.exec_cmd(ipc .. "volume-mute"), { locked = true })
hl.bind("XF86MonBrightnessUp",          hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",        hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

------------------------------------
---- NOCTALIA RULES & WORKSPACES ---
------------------------------------
-- Persistent workspaces
for i = 1, 5 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "Virtual-1", persistent = true, default_name = tostring(i) })
end

-- Layer rules and blur for Noctalia surfaces
hl.layer_rule({
    name = "noctalia",
    match = {
        namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
    },
    no_anim = true,
    ignore_alpha = 0.5,
    blur = true,
    blur_popups = true,
})

-- Noctalia Settings window rule
hl.window_rule({
    name  = "noctalia-settings",
    match = { class = "dev.noctalia.Noctalia" },
    float = true,
    size  = { 1080, 920 },
})
