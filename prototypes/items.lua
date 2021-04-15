--[[ Copyright (c) 2021 danbka33
 * Part of Smart Power Switcher
 *
 * See LICENSE.md in the project directory for license information.
--]]

local smart_switcher = flib.copy_prototype(data.raw["item"]["power-switch"], "smart-power-switcher")
smart_switcher.icon = "__SmartPowerSwitcher__/graphics/icons/smart-power-switch.png"
smart_switcher.icon_size = 64
smart_switcher.icon_mipmaps = 4
smart_switcher.order = smart_switcher.order.."-c"

local smart_switcher_in = flib.copy_prototype(data.raw["item"]["small-lamp"], "smart-power-switcher-input")
smart_switcher_in.flags = { "hidden"}

local smart_switcher_settings = flib.copy_prototype(data.raw["item"]["constant-combinator"],"smart-power-switcher-settings")
smart_switcher_settings.flags = {"hidden"}
smart_switcher_settings.icon = "__SmartPowerSwitcher__/graphics/icons/settings.png"
smart_switcher_settings.icon_size = 32
smart_switcher_settings.icon_mipmaps = nil

local smart_switcher_control = flib.copy_prototype(data.raw["item"]["constant-combinator"],"smart-power-switcher-lamp-control")
smart_switcher_control.flags = { "hidden"}
smart_switcher_control.icon = "__SmartPowerSwitcher__/graphics/icons/empty.png"
smart_switcher_control.icon_size = 32
smart_switcher_control.icon_mipmaps = nil

local smart_switcher_hack = flib.copy_prototype(data.raw["item"]["constant-combinator"],"smart-power-switcher-hack")
smart_switcher_hack.flags = { "hidden"}
smart_switcher_hack.icon = "__SmartPowerSwitcher__/graphics/icons/empty.png"
smart_switcher_hack.icon_size = 32
smart_switcher_hack.icon_mipmaps = nil

data:extend({
    smart_switcher,
    smart_switcher_in,
    smart_switcher_settings,
    smart_switcher_control,
    smart_switcher_hack
})
