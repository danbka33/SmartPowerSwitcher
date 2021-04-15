
data:extend({
    {
        type = "technology",
        name = "smart-power-switcher",
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
            count = 300,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1}
            },
            time = 30
        },
        order = "c-g-c"
    }
})
