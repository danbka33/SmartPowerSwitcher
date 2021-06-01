--[[ Copyright (c) 2021 danbka33
 * Part of Smart Power Switcher
 *
 * See LICENSE.md in the project directory for license information.
--]]

data:extend({
    {
        type = "item-subgroup",
        name = "smart-power-switcher-signals",
        group = "signals",
        order = "sps0[SPS-signal]"
    },
    {
        type = "virtual-signal",
        name = "smart-power-switcher-plus-inverse",
        localised_description = {"item-description.smart-power-switcher-plus-inverse"},
        icon = "__SmartPowerSwitcher__/graphics/icons/enabled.png",
        icon_size = 64,
        subgroup = "smart-power-switcher-signals",
        order = "b-d"
    },
    {
        type = "virtual-signal",
        name = "smart-power-switcher-plus-inverse",
        localised_description = {"item-description.smart-power-switcher-plus-inverse"},
        icon = "__SmartPowerSwitcher__/graphics/icons/enabled.png",
        icon_size = 64,
        subgroup = "smart-power-switcher-signals",
        order = "b-d"
    },
    {
        type = "virtual-signal",
        name = "smart-power-switcher-minus-inverse",
        localised_description = {"item-description.smart-power-switcher-minus-inverse"},
        icon = "__SmartPowerSwitcher__/graphics/icons/enabled.png",
        icon_size = 64,
        subgroup = "smart-power-switcher-signals",
        order = "b-d"
    },
    {
        type = "virtual-signal",
        name = "smart-power-switcher-enable",
        localised_description = {"item-description.smart-power-switcher-enable"},
        icon = "__SmartPowerSwitcher__/graphics/icons/enabled.png",
        icon_size = 64,
        subgroup = "smart-power-switcher-signals",
        order = "b-d"
    },
    {
        type = "virtual-signal",
        name = "smart-power-switcher-threshold",
        localised_description = {"item-description.smart-power-switcher-threshold"},
        icon = "__SmartPowerSwitcher__/graphics/icons/threshold.png",
        icon_size = 64,
        subgroup = "smart-power-switcher-signals",
        order = "a-a"
    },
    {
        type = "virtual-signal",
        name = "smart-power-switcher-off-delay",
        localised_description = {"item-description.smart-power-switcher-off-delay"},
        icon = "__SmartPowerSwitcher__/graphics/icons/timeroff.png",
        icon_size = 64,
        subgroup = "smart-power-switcher-signals",
        order = "a-b"
    },
    {
        type = "virtual-signal",
        name = "smart-power-switcher-on-delay",
        localised_description = {"item-description.smart-power-switcher-on-delay"},
        icon = "__SmartPowerSwitcher__/graphics/icons/timeron.png",
        icon_size = 64,
        subgroup = "smart-power-switcher-signals",
        order = "b-c"
    },
})
