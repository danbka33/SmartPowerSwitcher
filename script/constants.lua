MOD_NAME = "SmartPowerSwitcher"

smart_switcher_settings = "smart-power-switcher-settings"
smart_switcher_input = "smart-power-switcher-input"
smart_switcher_lamp_control = "smart-power-switcher-lamp-control"
smart_switcher_hack = "smart-power-switcher-hack"

smart_switcher_threshold_signal = "smart-power-switcher-threshold"
smart_switcher_on_delay_signal = "smart-power-switcher-on-delay"
smart_switcher_off_delay_signal = "smart-power-switcher-off-delay"
smart_switcher_enable_signal = "smart-power-switcher-enable"

smart_switcher_entity_names = { -- smart switcher entity.name with I/O entity offset away from tracks in tiles
    ["smart-power-switcher"] = 0,
    ["smart-power-switcher-port"] = 1,
}

ColorLookup = {
    red = "signal-red",
    green = "signal-green",
    blue = "signal-blue",
    yellow = "signal-yellow",
    pink = "signal-pink",
    cyan = "signal-cyan",
    white = "signal-white",
    grey = "signal-grey",
    black = "signal-black"
}

logic_colors = {
    ["red"] = 1,
    ["green"] = 2,
    ["blue"] = 3,
    ["yellow"] = 4,
    ["pink"] = 5,
    ["cyan"] = 6,
    ["white"] = 7,
    ["grey"] = 8,
    ["black"] = 9,
}