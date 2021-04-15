
local function initialize(oldVersion, newVersion)
    global.tick_state = 0 -- index determining on_tick update mode 0: init, 1: stop update, 2: sort requests, 3: parse requests, 4: raise API update events
    global.tick_stop_index = nil
    global.tick_request_index = nil
    global.tick_interval_start = nil -- stores tick of last state 0 for on_dispatcher_updated_event.update_interval

    ---- initialize Dispatcher
    global.Dispatcher = global.Dispatcher or {}

    ---- initialize stops
    global.SmartSwitchers = global.SmartSwitchers or {}

end

local function initializeSwitchers()
    global.SmartSwitchers = global.SmartSwitchers or {}
    -- remove invalidated stops
    for switcherID, switcher in pairs (global.SmartSwitchers) do
        if not switcher then
            log("[LTN] removing empty stop entry "..tostring(switcherID) )
            global.SmartSwitchers[switcherID] = nil
        elseif not(switcher.entity and switcher.entity.valid) then
            -- stop entity is corrupt/missing remove I/O entities
            log("[LTN] removing corrupt stop "..tostring(switcherID) )
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

    -- add missing ltn stops
    for _, surface in pairs(game.surfaces) do
        local foundSwitcher = surface.find_entities_filtered{ type="power-switch"}
        if foundSwitcher then
            for k, stop in pairs(foundSwitcher) do
                -- validate global.SmartSwitchers
                if smart_switcher_entity_names[stop.name] then
                    local smart_switcher = global.SmartSwitchers[stop.unit_number]
                    if smart_switcher then
                        if not(smart_switcher.output and smart_switcher.output.valid and smart_switcher.input and smart_switcher.input.valid and smart_switcher.lamp_control and smart_switcher.lamp_control.valid) then
                            -- I/O entities are corrupted
                            --log("[LTN] recreating corrupt stop "..tostring(stop.backer_name) )
                            global.SmartSwitchers[stop.unit_number] = nil
                            CreateSmartSwitcher(stop)
                        end
                    else
                        --log("[LTN] recreating stop missing from global.SmartSwitchers "..tostring(stop.backer_name) )
                        CreateSmartSwitcher(stop) -- recreate LTN stops missing from global.SmartSwitchers
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
        -- script.on_event(defines.events.on_tick, OnTick)
        script.on_nth_tick(nil)
        script.on_nth_tick(nth_tick, OnTick)
    end

    if remote.interfaces["creative-mode"] and remote.interfaces["creative-mode"]["exclude_from_instant_blueprint"] then
        remote.call("creative-mode", "exclude_from_instant_blueprint", smart_switcher_input)
        remote.call("creative-mode", "exclude_from_instant_blueprint", smart_switcher_lamp_control)
        remote.call("creative-mode", "exclude_from_instant_blueprint", smart_switcher_settings)
    end

    -- blacklist LTN entities from picker dollies
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

    --local oldVersion, newVersion = nil
    --local newVersionString = game.active_mods[MOD_NAME]
    --if newVersionString then
    --    newVersion = format("%02d.%02d.%02d", match(newVersionString, "(%d+).(%d+).(%d+)"))
    --end

    initialize(nil, nil)
    initializeSwitchers();
    registerEvents()
end)
