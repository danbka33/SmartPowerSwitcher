--[[ Copyright (c) 2021 danbka33
 * Part of Smart Power Switcher
 *
 * See LICENSE.md in the project directory for license information.
--]]

data:extend({
    {
        type = "int-setting",
        name = "spw-nth-tick",
        order = "ab",
        setting_type = "runtime-global",
        default_value = 2,
        minimum_value = 1,
        maximum_value = 60, -- one stop per second
    },
    {
        type = "int-setting",
        name = "spw-updates-per-tick",
        order = "ac",
        setting_type = "runtime-global",
        default_value = 1,
        minimum_value = 1,
        maximum_value = 100, -- processing too many stops/requests per tick will produce lag spikes
    },
    {
        type = "int-setting",
        name = "spw-on-delay",
        order = "ad",
        setting_type = "runtime-global",
        default_value = 60, -- sec
        minimum_value = 1, -- 1 tick
        maximum_value = 3600, -- 60 sec
    },
    {
        type = "int-setting",
        name = "spw-off-delay",
        order = "ae",
        setting_type = "runtime-global",
        default_value = 60, -- 1 sec
        minimum_value = 1, -- 1 tick
        maximum_value = 3600, -- 60 sec
    },
    {
        type = "int-setting",
        name = "spw-default-threshold",
        order = "af",
        setting_type = "runtime-global",
        default_value = 5000,
        minimum_value = 1,
        maximum_value = 2147483647,
    },
    {
        type = "bool-setting",
        name = "spw-interface-debug-logfile",
        order = "ah",
        setting_type = "runtime-global",
        default_value = false
    },
})