local smart_switcher = flib.copy_prototype(data.raw["power-switch"]["power-switch"], "smart-power-switcher")
smart_switcher.icon = "__SmartPowerSwitcher__/graphics/icons/smart-power-switch.png"
smart_switcher.icon_size = 64
smart_switcher.icon_mipmaps = 4
smart_switcher.next_upgrade = nil
smart_switcher.selection_box = { { -0.6, -0.6 }, { 0.6, 0.6 } }
smart_switcher.power_on_animation = {
    layers = {
        {
            filename = "__SmartPowerSwitcher__/graphics/entity/smart-power-switch.png",
            animation_speed = 0.2,
            line_length = 2,
            width = 86,
            height = 70,
            frame_count = 6,
            shift = util.by_pixel(-4, 2),
            hr_version = {
                filename = "__SmartPowerSwitcher__/graphics/entity/hr-smart-power-switch.png",
                animation_speed = 0.2,
                line_length = 2,
                width = 168,
                height = 138,
                frame_count = 6,
                shift = util.by_pixel(-3, 2),
                scale = 0.5
            }
        },
        {
            filename = "__base__/graphics/entity/power-switch/power-switch-shadow.png",
            animation_speed = 0.2,
            line_length = 2,
            width = 84,
            height = 46,
            frame_count = 6,
            shift = util.by_pixel(6, 14),
            draw_as_shadow = true,
            hr_version = {
                filename = "__base__/graphics/entity/power-switch/hr-power-switch-shadow.png",
                animation_speed = 0.2,
                line_length = 2,
                width = 166,
                height = 92,
                frame_count = 6,
                shift = util.by_pixel(6, 14),
                draw_as_shadow = true,
                scale = 0.5
            }
        }
    }
}

local smart_switcher_settings = flib.copy_prototype(data.raw["constant-combinator"]["constant-combinator"], "smart-power-switcher-settings")
smart_switcher_settings.icon = "__SmartPowerSwitcher__/graphics/icons/settings.png"
smart_switcher_settings.icon_size = 32
smart_switcher_settings.icon_mipmaps = nil
smart_switcher_settings.next_upgrade = nil
smart_switcher_settings.minable = nil
smart_switcher_settings.selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } }
smart_switcher_settings.selection_priority = (smart_switcher_settings.selection_priority or 50) + 10 -- increase priority to default + 10
smart_switcher_settings.collision_box = { { -0.15, -0.15 }, { 0.15, 0.15 } }
smart_switcher_settings.collision_mask = { "rail-layer" } -- collide only with rail entities
smart_switcher_settings.item_slot_count = 50
smart_switcher_settings.sprites = make_4way_animation_from_spritesheet(
        { layers = {
            {
                filename = "__SmartPowerSwitcher__/graphics/entity/settings.png",
                width = 58,
                height = 52,
                frame_count = 1,
                shift = util.by_pixel(0, 5),
                hr_version = {
                    scale = 0.5,
                    filename = "__SmartPowerSwitcher__/graphics/entity/hr-settings.png",
                    width = 114,
                    height = 102,
                    frame_count = 1,
                    shift = util.by_pixel(0, 5),
                },
            },
            {
                filename = "__base__/graphics/entity/combinator/constant-combinator-shadow.png",
                width = 50,
                height = 34,
                frame_count = 1,
                shift = util.by_pixel(9, 6),
                draw_as_shadow = true,
                hr_version = {
                    scale = 0.5,
                    filename = "__base__/graphics/entity/combinator/hr-constant-combinator-shadow.png",
                    width = 98,
                    height = 66,
                    frame_count = 1,
                    shift = util.by_pixel(8.5, 5.5),
                    draw_as_shadow = true,
                },
            },
        },
        })

local smart_switcher_in = flib.copy_prototype(data.raw["lamp"]["small-lamp"], "smart-power-switcher-input")
smart_switcher_in.icon = "__base__/graphics/icons/power-switch.png"
smart_switcher_in.icon_size = 64
smart_switcher_in.icon_mipmaps = 4
smart_switcher_in.next_upgrade = nil
smart_switcher_in.minable = nil
smart_switcher_in.selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } }
smart_switcher_in.selection_priority = (smart_switcher_in.selection_priority or 50) + 10 -- increase priority to default + 10
smart_switcher_in.collision_box = { { -0.15, -0.15 }, { 0.15, 0.15 } }
smart_switcher_in.collision_mask = { "rail-layer" } -- collide only with rail entities
smart_switcher_in.energy_usage_per_tick = "10W"
smart_switcher_in.light = { intensity = 1, size = 6 }
smart_switcher_in.energy_source = { type = "void" }

local control_connection_points = {
    red = util.by_pixel(-3, -7),
    green = util.by_pixel(-1, 0)
}
local smart_switcher_hack = flib.copy_prototype(data.raw["constant-combinator"]["constant-combinator"], "smart-power-switcher-hack")
smart_switcher_hack.icon = "__SmartPowerSwitcher__/graphics/icons/empty.png"
smart_switcher_hack.icon_size = 32
smart_switcher_hack.icon_mipmaps = nil
smart_switcher_hack.next_upgrade = nil
smart_switcher_hack.minable = nil
smart_switcher_hack.selection_box = { { -0.0, -0.0 }, { 0.0, 0.0 } }
smart_switcher_hack.collision_box = { { -0.0, -0.0 }, { 0.0, 0.0 } }
smart_switcher_hack.collision_mask = {} -- disable collision
smart_switcher_hack.item_slot_count = 50
smart_switcher_hack.flags = { "not-blueprintable", "not-deconstructable", "placeable-off-grid" }
smart_switcher_hack.sprites = {
    north = {
        filename = "__SmartPowerSwitcher__/graphics/icons/empty.png",
        x = 0,
        y = 0,
        width = 1,
        height = 1,
        frame_count = 1,
        shift = { 0, 0 },
    },
    east = {
        filename = "__SmartPowerSwitcher__/graphics/icons/empty.png",
        x = 0,
        y = 0,
        width = 1,
        height = 1,
        frame_count = 1,
        shift = { 0, 0 },
    },
    south = {
        filename = "__SmartPowerSwitcher__/graphics/icons/empty.png",
        x = 0,
        y = 0,
        width = 1,
        height = 1,
        frame_count = 1,
        shift = { 0, 0 },
    },
    west = {
        filename = "__SmartPowerSwitcher__/graphics/icons/empty.png",
        x = 0,
        y = 0,
        width = 1,
        height = 1,
        frame_count = 1,
        shift = { 0, 0 },
    }
}
smart_switcher_hack.activity_led_sprites = {
    north = {
        filename = "__SmartPowerSwitcher__/graphics/icons/empty.png",
        width = 1,
        height = 1,
        frame_count = 1,
        shift = { 0.0, 0.0 },
    },
    east = {
        filename = "__SmartPowerSwitcher__/graphics/icons/empty.png",
        width = 1,
        height = 1,
        frame_count = 1,
        shift = { 0.0, 0.0 },
    },
    south = {
        filename = "__SmartPowerSwitcher__/graphics/icons/empty.png",
        width = 1,
        height = 1,
        frame_count = 1,
        shift = { 0.0, 0.0 },
    },
    west = {
        filename = "__SmartPowerSwitcher__/graphics/icons/empty.png",
        width = 1,
        height = 1,
        frame_count = 1,
        shift = { 0.0, 0.0 },
    }
}
smart_switcher_hack.activity_led_light = {
    intensity = 0.0,
    size = 0,
}
smart_switcher_hack.circuit_wire_connection_points = {
    {
        shadow = control_connection_points,
        wire = control_connection_points
    },
    {
        shadow = control_connection_points,
        wire = control_connection_points
    },
    {
        shadow = control_connection_points,
        wire = control_connection_points
    },
    {
        shadow = control_connection_points,
        wire = control_connection_points
    },
}

local smart_switcher_control = flib.copy_prototype(data.raw["constant-combinator"]["constant-combinator"], "smart-power-switcher-lamp-control")
smart_switcher_control.icon = "__SmartPowerSwitcher__/graphics/icons/empty.png"
smart_switcher_control.icon_size = 32
smart_switcher_control.icon_mipmaps = nil
smart_switcher_control.next_upgrade = nil
smart_switcher_control.minable = nil
smart_switcher_control.selection_box = { { -0.0, -0.0 }, { 0.0, 0.0 } }
smart_switcher_control.collision_box = { { -0.0, -0.0 }, { 0.0, 0.0 } }
smart_switcher_control.collision_mask = {} -- disable collision
smart_switcher_control.item_slot_count = 50
smart_switcher_control.flags = { "not-blueprintable", "not-deconstructable", "placeable-off-grid" }
smart_switcher_control.sprites = {
    north = {
        filename = "__SmartPowerSwitcher__/graphics/icons/empty.png",
        x = 0,
        y = 0,
        width = 1,
        height = 1,
        frame_count = 1,
        shift = { 0, 0 },
    },
    east = {
        filename = "__SmartPowerSwitcher__/graphics/icons/empty.png",
        x = 0,
        y = 0,
        width = 1,
        height = 1,
        frame_count = 1,
        shift = { 0, 0 },
    },
    south = {
        filename = "__SmartPowerSwitcher__/graphics/icons/empty.png",
        x = 0,
        y = 0,
        width = 1,
        height = 1,
        frame_count = 1,
        shift = { 0, 0 },
    },
    west = {
        filename = "__SmartPowerSwitcher__/graphics/icons/empty.png",
        x = 0,
        y = 0,
        width = 1,
        height = 1,
        frame_count = 1,
        shift = { 0, 0 },
    }
}
smart_switcher_control.activity_led_sprites = {
    north = {
        filename = "__SmartPowerSwitcher__/graphics/icons/empty.png",
        width = 1,
        height = 1,
        frame_count = 1,
        shift = { 0.0, 0.0 },
    },
    east = {
        filename = "__SmartPowerSwitcher__/graphics/icons/empty.png",
        width = 1,
        height = 1,
        frame_count = 1,
        shift = { 0.0, 0.0 },
    },
    south = {
        filename = "__SmartPowerSwitcher__/graphics/icons/empty.png",
        width = 1,
        height = 1,
        frame_count = 1,
        shift = { 0.0, 0.0 },
    },
    west = {
        filename = "__SmartPowerSwitcher__/graphics/icons/empty.png",
        width = 1,
        height = 1,
        frame_count = 1,
        shift = { 0.0, 0.0 },
    }
}
smart_switcher_control.activity_led_light = {
    intensity = 0.0,
    size = 0,
}
smart_switcher_control.circuit_wire_connection_points = {
    {
        shadow = control_connection_points,
        wire = control_connection_points
    },
    {
        shadow = control_connection_points,
        wire = control_connection_points
    },
    {
        shadow = control_connection_points,
        wire = control_connection_points
    },
    {
        shadow = control_connection_points,
        wire = control_connection_points
    },
}

data:extend({
    smart_switcher,
    smart_switcher_settings,
    smart_switcher_in,
    smart_switcher_hack,
    smart_switcher_control
})