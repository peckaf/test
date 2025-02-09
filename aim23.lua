cheat.EspLibrary = {}; LPH_NO_VIRTUALIZE(function)()
    local esp_table = {}
    local workspace = cloneref(game:GetService("Workspace"))
    local rservice = cloneref(game:GetService("RunService"))
    local plrs = cloneref(game:GetService("Players"))
    local lplr = plrs.LocalPlayer
    local container = Instance.new("Folder", game:GetService("CoreGui").RobloxGui)
    esp_table = {
        __loaded = false,
        main_settings = {
            textSize = 15,
            textFont = Drawing.Fonts.Monospace,
            distancelimit = false,
            maxdistance = 1000,
            useteamcolor = false,
            teamcheck = true,
            sleepcheck = true,
            simplecalc = false
        },
        main_object_settings = {
            textSize = 15,
            textFont = Drawing.Fonts.Monospace,
            distancelimit = false,
            maxdistance = 1000,
            useteamcolor = false,
            teamcheck = true,
            sleepcheck = true,
            allowed = {}
        },
        settings = {
            enemy = {
                enabled = false,
    
                box = false,
                box_fill = false,
                realname = false,
                dist = false,
                weapon = false,
                skeleton = false,
    
                box_outline = false,
                realname_outline = false,
                dist_outline = false,
                weapon_outline = false,
    
                box_color = { Color3.new(1, 1, 1), 1 },
                box_fill_color = { Color3.new(1, 0, 0), 0.3 },
                realname_color = { Color3.new(1, 1, 1), 1 },
                dist_color = { Color3.new(1, 1, 1), 1 },
                weapon_color = { Color3.new(1, 1, 1), 1 },
                skeleton_color = { Color3.new(1, 1, 1), 1 },
    
                box_outline_color = { Color3.new(), 1 },
                realname_outline_color = Color3.new(),
                dist_outline_color = Color3.new(),
                weapon_outline_color = Color3.new(),
    
                chams = false,
                chams_visible_only = false,
                chams_fill_color = { Color3.new(1, 1, 1), 0.5 },
                chamsoutline_color = { Color3.new(1, 1, 1), 0 }
            },
            object = {
                enabled = false,

                realname = false,
                realname_outline = false,

                realname_color = { Color3.new(1, 1, 1), 1 },
                realname_outline_color = Color3.new(),

                chams = true,
                chams_visible_only = false,
                chams_fill_color = { Color3.new(1, 1, 1), 0.5 },
                chamsoutline_color = { Color3.new(1, 1, 1), 0 }
            }
        }
    }
