--[[ Copyright (c) 2021 danbka33
 * Part of Smart Power Switcher
 *
 * See LICENSE.md in the project directory for license information.
--]]

data:extend({
    {
        type = "technology",
        name = "smart-power-switcher",
        localised_description = {"technology-description.smart-power-switcher"},
        icon = "__base__/graphics/icons/power-switch.png",
        icon_size = 64,
        prerequisites = {"circuit-network"},
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "smart-power-switcher"
            }
        },
        unit =
        {
            count = 100,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1}
            },
            time = 15
        },
        order = "c-g-c"
    }
})
