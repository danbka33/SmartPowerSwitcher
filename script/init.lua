--[[ Copyright (c) 2021 danbka33
 * Part of Smart Power Switcher
 *
 * See LICENSE.md in the project directory for license information.
--]]

local function initialize()
    ---- initialize stops
    global.SmartSwitchers = global.SmartSwitchers or {}
end

local function initializeSwitchers()
    global.SmartSwitchers = global.SmartSwitchers or {}
    -- remove invalidated switchers
    for switcherID, switcher in pairs (global.SmartSwitchers) do
        if not switcher then
            global.SmartSwitchers[switcherID] = nil
        elseif not(switcher.entity and switcher.entity.valid) then
            if switcher.input and switcher.input.valid then
                switcher.input.destroy()
            end
            if switcher.output and switcher.output.valid then
                switcher.output.destroy()
            end
            if switcher.lamp_control and switcher.lamp_control.valid then
                switcher.lamp_control.destroy()
            end
            global.SmartSwitchers[switcherID] = nil
        end
    end

    for _, surface in pairs(game.surfaces) do
        local foundSwitcher = surface.find_entities_filtered{ type="power-switch"}
        if foundSwitcher then
            for k, stop in pairs(foundSwitcher) do
                -- validate global.SmartSwitchers
                if smart_switcher_entity_names[stop.name] then
                    local smart_switcher = global.SmartSwitchers[stop.unit_number]
                    if smart_switcher then
                        if not(smart_switcher.output and smart_switcher.output.valid and smart_switcher.input and smart_switcher.input.valid and smart_switcher.lamp_control and smart_switcher.lamp_control.valid) then
                            global.SmartSwitchers[stop.unit_number] = nil
                            CreateSmartSwitcher(stop)
                        end
                    else
                        CreateSmartSwitcher(stop)
                    end
                end
            end
        end
    end
end

local function registerEvents()
    script.on_event(defines.events.on_built_entity, OnEntityCreated, filters_on_built)
    script.on_event(defines.events.on_robot_built_entity, OnEntityCreated, filters_on_built)
    script.on_event({ defines.events.script_raised_built, defines.events.script_raised_revive }, OnEntityCreated)

    script.on_event(defines.events.on_pre_player_mined_item, OnEntityRemoved, filters_on_mined)
    script.on_event(defines.events.on_robot_pre_mined, OnEntityRemoved, filters_on_mined)
    script.on_event(defines.events.on_entity_died, OnEntityRemoved, filters_on_mined)
    script.on_event(defines.events.script_raised_destroy, OnEntityRemoved)

    script.on_event({ defines.events.on_pre_surface_deleted, defines.events.on_pre_surface_cleared }, OnSurfaceRemoved)

    if global.SmartSwitchers and next(global.SmartSwitchers) then
        script.on_nth_tick(nil)
        script.on_nth_tick(nth_tick, OnTick)
    end

    if remote.interfaces["creative-mode"] and remote.interfaces["creative-mode"]["exclude_from_instant_blueprint"] then
        remote.call("creative-mode", "exclude_from_instant_blueprint", smart_switcher_input)
        remote.call("creative-mode", "exclude_from_instant_blueprint", smart_switcher_lamp_control)
        remote.call("creative-mode", "exclude_from_instant_blueprint", smart_switcher_settings)
    end

    -- blacklist entities
    if remote.interfaces["PickerDollies"] and remote.interfaces["PickerDollies"]["add_blacklist_name"] then
        for name, offset in pairs(smart_switcher_entity_names) do
            remote.call("PickerDollies", "add_blacklist_name", name, true)
        end
        remote.call("PickerDollies", "add_blacklist_name", smart_switcher_input, true)
        remote.call("PickerDollies", "add_blacklist_name", smart_switcher_settings, true)
        remote.call("PickerDollies", "add_blacklist_name", smart_switcher_lamp_control, true)
    end
end


script.on_load(function()
    registerEvents()
end)

script.on_init(function()
    initialize()
    initializeSwitchers();
    registerEvents()
end)
