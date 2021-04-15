--[[ Copyright (c) 2021 danbka33
 * Part of Smart Power Switcher
 *
 * See LICENSE.md in the project directory for license information.
--]]

local smart_switcher = flib.copy_prototype(data.raw["recipe"]["power-switch"], "smart-power-switcher")
smart_switcher.ingredients = {
    {"power-switch", 1},
    {"constant-combinator", 1},
    {"small-lamp", 1},
    {"green-wire", 2},
    {"red-wire", 2},
}
smart_switcher.enabled = false

data:extend({
    smart_switcher
})