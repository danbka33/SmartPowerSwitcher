local function detectShortCircuit(smartSwitcher)
    local scdetected = false
    local networks = {}
    local entities = { smartSwitcher.entity, smartSwitcher.settingInput, smartSwitcher.input }

    for k, entity in pairs(entities) do
        local greenWire = entity.get_circuit_network(defines.wire_type.green)
        if greenWire then
            if networks[greenWire.network_id] then
                scdetected = true
            else
                networks[greenWire.network_id] = entity.unit_number
            end
        end
        local redWire = entity.get_circuit_network(defines.wire_type.red)
        if redWire then
            if networks[redWire.network_id] then
                scdetected = true
            else
                networks[redWire.network_id] = entity.unit_number
            end
        end
    end

    return scdetected
end

function OnTick(event)
    local tick = event.tick

    for i = 1, updates_per_tick, 1 do
        global.SmartSwitchers = global.SmartSwitchers or {}
        -- remove invalidated stops
        for switcherID, switcher in pairs(global.SmartSwitchers) do

            local limitedSignals = {}
            local signals_filtered = {}

            if detectShortCircuit(switcher) then
                if debug_log then
                    log('Short Circuit')
                end
                setLamp(switcher, "red", 1)
                return
            end

            if switcher.input and switcher.input.valid and switcher.settingInput and switcher.settingInput.valid then
                local signals = switcher.settingInput.get_merged_signals()
                if not signals then
                    if debug_log then
                        log('no settings input signals')
                    end
                    setLamp(switcher, "red", 1)
                    return
                end -- either lamp and lampctrl are not connected or lampctrl has no output signal

                local signal_type_virtual = "virtual"

                for _, v in pairs(signals) do
                    if v.signal.name and v.signal.type then
                        if v.signal.type ~= signal_type_virtual then
                            -- add item and fluid signals to new array

                            if v.count > 0 then
                                if not limitedSignals[v.signal.name] then
                                    limitedSignals[v.signal.name] = v.count
                                    switcher.limitedSignalsGain[v.signal.name] = false
                                else
                                    limitedSignals[v.signal.name] = v.count
                                end
                            else
                                signals_filtered[v.signal] = v.count
                            end

                        end

                        if v.signal.name == smart_switcher_threshold_signal and v.count > 0 then
                            switcher.delta = v.count
                        end

                        if v.signal.name == smart_switcher_off_delay_signal and v.count > 0 then
                            switcher.power_off_delay = v.count
                        end

                        if v.signal.name == smart_switcher_off_delay_signal and v.count > 0 then
                            switcher.power_on_delay = v.count
                        end
                    end
                end

                if next(switcher.limitedSignalsGain) then
                    for name, _ in pairs(switcher.limitedSignalsGain) do
                        if not limitedSignals[name] then
                            switcher.limitedSignalsGain[name] = nil
                        end
                    end
                end
            end

            local signals = switcher.input.get_merged_signals()
            if not signals then
                if debug_log then
                    log('no input signals')
                end
                setLamp(switcher, "red", 1)
                return
            end -- either lamp and lampctrl are not connected or lampctrl has no output signal

            local filtered_object_signals = {}

            for _, v in pairs(signals) do
                if v.signal.name and v.signal.type and v.signal.type ~= signal_type_virtual then
                    filtered_object_signals[v.signal] = v.count
                end
            end

            local disabled = false;

            if next(signals_filtered) then

                for signal, count in pairs(signals_filtered) do
                    if count < 0 then
                        local foundedObject = nil;
                        for objectSignal, objectCount in pairs(filtered_object_signals) do
                            if objectSignal.name == signal.name then
                                foundedObject = {
                                    signal = signal,
                                    count = objectCount
                                }
                            end
                        end

                        if not foundedObject then
                            disabled = true
                            if debug_log then
                                log(signal.name .. " not found ")
                            end
                        else
                            if foundedObject.count <= math.abs(count) then
                                disabled = true
                                if debug_log then
                                    log(foundedObject.signal.name .. " less than " .. tostring(count))
                                end
                            end
                        end
                    end
                end
            end

            if next(limitedSignals) then
                local foundAnyObject = false;
                for name, count in pairs(limitedSignals) do
                    local bottom = count - switcher.delta;

                    if (bottom >= count) then
                        disabled = true
                        setLamp(switcher, "red", 1)
                        if debug_log then
                            log('disabled because bottom limit more or equals top limit')
                        end
                    end

                    local foundedObject = nil;
                    for objectSignal, objectCount in pairs(filtered_object_signals) do
                        if objectSignal.name == name then
                            foundedObject = {
                                signal = name,
                                count = objectCount
                            }
                        end
                    end

                    if foundedObject then
                        foundAnyObject = true
                    end

                    if not switcher.limitedSignalsGain[name] then
                        switcher.limitedSignalsGain[name] = false
                    end

                    if foundedObject and foundedObject.count >= count then
                        switcher.limitedSignalsGain[name] = true
                    end

                    if switcher.limitedSignalsGain[name] == true and foundedObject and foundedObject.count <= bottom then
                        switcher.limitedSignalsGain[name] = false
                    end

                    if switcher.limitedSignalsGain[name] == true then
                        disabled = true
                        if debug_log then
                            log("gain resource")
                        end
                    end
                end

                if foundAnyObject == false and next(switcher.limitedSignalsGain) then
                    for name, _ in pairs(switcher.limitedSignalsGain) do
                        switcher.limitedSignalsGain[name] = false
                    end
                end
            end

            log("Enabled: " .. tostring(switcher.enabled))
            --log(switcher.entity.get_or_create_control_behavior().help());

            if switcher.power_off_started and tick > switcher.power_off_started then
                --switcher.entity.power_switch_state = false;
                --switcher.entity.active = false;
                switcher.power_off_started = nil;

                switcher.enabled = false;
                if switcher.hack and switcher.hack.valid then
                    switcher.hack.get_control_behavior().parameters = { { index = 1, signal = { type = "virtual", name = smart_switcher_enable_signal }, count = 0 } }
                end

                setLamp(switcher, "yellow", 1)
                if debug_log then
                    log("Set power OFF")
                end
            elseif switcher.power_on_started and tick > switcher.power_on_started then
                --switcher.entity.power_switch_state = true;
                --switcher.entity.active = true;
                switcher.power_on_started = nil;

                switcher.enabled = true;
                if switcher.hack and switcher.hack.valid then
                    switcher.hack.get_control_behavior().parameters = { { index = 1, signal = { type = "virtual", name = smart_switcher_enable_signal }, count = 1 } }
                end

                setLamp(switcher, "green", 1)
                if debug_log then
                    log("Set power ON")
                end
            end

            if (switcher.power_off_started and tick < switcher.power_off_started)
                    or (switcher.power_on_started and tick < switcher.power_on_started) then
                setLamp(switcher, "pink", 1)
                if debug_log then
                    log("Power switch in action")
                    if switcher.power_off_started then
                        log(tostring(tick) .. " | OFF wait | " .. switcher.power_off_started)
                    end
                    if switcher.power_on_started then
                        log(tostring(tick) .. " | ON wait | " .. switcher.power_on_started)
                    end
                end
            else
                if switcher.enabled == true and disabled == true and switcher.power_off_started == nil then
                    switcher.power_off_started = game.tick + switcher.power_off_delay;
                    if debug_log then
                        log("Set power stared OFF: " .. tostring(switcher.power_off_started))
                    end
                elseif switcher.enabled == false and disabled == false and switcher.power_on_started == nil then
                    switcher.power_on_started = game.tick + switcher.power_on_delay;
                    if debug_log then
                        log("Set power stared ON: " .. tostring(switcher.power_on_started))
                    end
                end
            end



            --switcher.entity.get_or_create_control_behavior().connect_to_logistic_network = true;

            --if disabled == true then

            --else
            --    switcher.entity.get_or_create_control_behavior().circuit_condition = { condition = { comparator = "=",
            --                                                                                         first_signal = { type = "virtual", name = "signal-everything" },
            --                                                                                         constant = 0 } }
            --end

        end

    end
end

function CreateSmartSwitcher(entity)
    if global.SmartSwitchers[entity.unit_number] then
        return
    end
    local switcher_offset = smart_switcher_entity_names[entity.name]
    local posIn, posOut, rotOut, search_area
    --log("Stop created at "..entity.position.x.."/"..entity.position.y..", orientation "..entity.direction)
    if entity.direction == 0 then
        --SN
        posIn = { entity.position.x + switcher_offset, entity.position.y - 1 }
        posOut = { entity.position.x - 1 + switcher_offset, entity.position.y - 1 }
        rotOut = 0
        search_area = {
            { entity.position.x + 0.001 - 1 + switcher_offset, entity.position.y + 0.001 - 1 },
            { entity.position.x - 0.001 + 1 + switcher_offset, entity.position.y - 0.001 }
        }
    elseif entity.direction == 2 then
        --WE
        posIn = { entity.position.x, entity.position.y + switcher_offset }
        posOut = { entity.position.x, entity.position.y - 1 + switcher_offset }
        rotOut = 2
        search_area = {
            { entity.position.x + 0.001, entity.position.y + 0.001 - 1 + switcher_offset },
            { entity.position.x - 0.001 + 1, entity.position.y - 0.001 + 1 + switcher_offset }
        }
    elseif entity.direction == 4 then
        --NS
        posIn = { entity.position.x - 1 - switcher_offset, entity.position.y }
        posOut = { entity.position.x - switcher_offset, entity.position.y }
        rotOut = 4
        search_area = {
            { entity.position.x + 0.001 - 1 - switcher_offset, entity.position.y + 0.001 },
            { entity.position.x - 0.001 + 1 - switcher_offset, entity.position.y - 0.001 + 1 }
        }
    elseif entity.direction == 6 then
        --EW
        posIn = { entity.position.x - 1, entity.position.y - 1 - switcher_offset }
        posOut = { entity.position.x - 1, entity.position.y - switcher_offset }
        rotOut = 6
        search_area = {
            { entity.position.x + 0.001 - 1, entity.position.y + 0.001 - 1 - switcher_offset },
            { entity.position.x - 0.001, entity.position.y - 0.001 + 1 - switcher_offset }
        }
    else
        --invalid orientation
        --if message_level >= 1 then printmsg({"ltn-message.error-stop-orientation", tostring(entity.direction)}, entity.force) end
        --if debug_log then log("(CreateStop) invalid train stop orientation "..tostring(entity.direction) ) end
        entity.destroy()
        return
    end

    local input, settingInput, lampctrl, hack
    local ghosts = entity.surface.find_entities(search_area)
    for _, ghost in pairs(ghosts) do
        if ghost.valid then
            if ghost.name == "entity-ghost" then
                if ghost.ghost_name == smart_switcher_settings then
                    -- log("reviving ghost input at "..ghost.position.x..", "..ghost.position.y)
                    _, settingInput = ghost.revive()
                elseif ghost.ghost_name == smart_switcher_input then
                    -- log("reviving ghost output at "..ghost.position.x..", "..ghost.position.y)
                    _, input = ghost.revive()
                elseif ghost.ghost_name == smart_switcher_lamp_control then
                    -- log("reviving ghost lamp-control at "..ghost.position.x..", "..ghost.position.y)
                    _, lampctrl = ghost.revive()
                elseif ghost.ghost_name == smart_switcher_hack then
                    -- log("reviving ghost lamp-control at "..ghost.position.x..", "..ghost.position.y)
                    _, hack = ghost.revive()
                end
                -- something has built I/O already (e.g.) Creative Mode Instant Blueprint
            elseif ghost.name == smart_switcher_settings then
                settingInput = ghost
                -- log("Found existing input at "..ghost.position.x..", "..ghost.position.y)
            elseif ghost.name == smart_switcher_input then
                input = ghost
            elseif ghost.name == smart_switcher_lamp_control then
                lampctrl = ghost
            elseif ghost.name == smart_switcher_hack then
                hack = ghost
                -- log("Found existing output at "..ghost.position.x..", "..ghost.position.y)
            end
        end
    end

    if input == nil then
        -- create new
        input = entity.surface.create_entity {
            name = smart_switcher_input,

            position = posIn,
            force = entity.force
        }
    end
    input.operable = false -- disable gui
    input.minable = false
    input.destructible = false -- don't bother checking if alive

    if settingInput == nil then
        settingInput = entity.surface.create_entity {
            name = smart_switcher_settings,
            position = posOut, -- slight offset so adjacent lamps won't connect
            force = entity.force
        }
        -- log("building lamp-control at "..lampctrl.position.x..", "..lampctrl.position.y)
    end
    settingInput.operable = false -- disable gui
    settingInput.minable = false
    settingInput.destructible = false -- don't bother checking if alive

    if lampctrl == nil then
        lampctrl = entity.surface.create_entity {
            name = smart_switcher_lamp_control,
            position = { input.position.x + 0.45, input.position.y + 0.45 }, -- slight offset so adjacent lamps won't connect
            force = entity.force
        }
        -- log("building lamp-control at "..lampctrl.position.x..", "..lampctrl.position.y)
    end
    lampctrl.operable = false -- disable gui
    lampctrl.minable = false
    lampctrl.destructible = false -- don't bother checking if alive

    if hack == nil then
        hack = entity.surface.create_entity {
            name = smart_switcher_hack,
            position = { input.position.x - 0.45, input.position.y + 0.45 }, -- slight offset so adjacent lamps won't connect
            force = entity.force
        }
        -- log("building lamp-control at "..lampctrl.position.x..", "..lampctrl.position.y)
    end
    hack.operable = false -- disable gui
    hack.minable = false
    hack.destructible = false -- don't bother checking if alive

    lampctrl.get_control_behavior().parameters = { { index = 1, signal = { type = "virtual", name = "signal-white" }, count = 1 } }
    input.connect_neighbour({ target_entity = lampctrl, wire = defines.wire_type.green })
    input.connect_neighbour({ target_entity = lampctrl, wire = defines.wire_type.red })
    input.get_or_create_control_behavior().use_colors = true
    input.get_or_create_control_behavior().circuit_condition = { condition = { comparator = ">", first_signal = { type = "virtual", name = "signal-anything" } } }

    entity.connect_neighbour({ target_entity = hack, wire = defines.wire_type.red })
    entity.connect_neighbour({ target_entity = hack, wire = defines.wire_type.green })

    entity.get_or_create_control_behavior().circuit_condition = { condition = { comparator = ">",
                                                                                first_signal = { type = "virtual", name = smart_switcher_enable_signal },
                                                                                constant = 0 } }
    entity.get_or_create_control_behavior().logistic_condition = { condition = { comparator = ">",
                                                                                 first_signal = { type = "virtual", name = smart_switcher_enable_signal },
                                                                                 constant = 0 } }

    entity.operable = false;

    global.SmartSwitchers[entity.unit_number] = {
        entity = entity,
        input = input,
        settingInput = settingInput,
        lamp_control = lampctrl,
        hack = hack,
        limitedSignalsGain = {},
        delta = default_threshold,
        power_on_delay = power_on_delay,
        power_off_delay = power_off_delay,
        power_off_started = nil,
        power_off_started = nil,
        enabled = false
    }
    --UpdateSmartSwitcher(global.SmartSwitchers[entity.unit_number])

    script.on_nth_tick(nil)
    script.on_nth_tick(nth_tick, OnTick)
end

function OnEntityCreated(event)
    local entity = event.created_entity or event.entity
    if not entity or not entity.valid then
        return
    end

    if smart_switcher_entity_names[entity.name] then
        CreateSmartSwitcher(entity)
    end
end

function OnEntityRemoved(event)
    local entity = event.entity
    if not entity or not entity.valid then
        return
    end

    if smart_switcher_entity_names[entity.name] then
        RemoveSmartSwitcher(entity.unit_number)
    end
end

function setLamp(smartSwitcher, color, count)
    -- skip invalid switcher and colors
    if smartSwitcher and smartSwitcher.lamp_control.valid and ColorLookup[color] then
        smartSwitcher.lamp_control.get_control_behavior().parameters = { { index = 1, signal = { type = "virtual", name = ColorLookup[color] }, count = count } }
        return true
    end
    return false
end

function RemoveSmartSwitcher(smartSwitcherID)
    local smartSwitcher = global.SmartSwitchers[smartSwitcherID]

    if smartSwitcher then
        if smartSwitcher.input and smartSwitcher.input.valid then
            smartSwitcher.input.destroy()
        end
        if smartSwitcher.settingInput and smartSwitcher.settingInput.valid then
            smartSwitcher.settingInput.destroy()
        end
        if smartSwitcher.lamp_control and smartSwitcher.lamp_control.valid then
            smartSwitcher.lamp_control.destroy()
        end
        if smartSwitcher.hack and smartSwitcher.hack.valid then
            smartSwitcher.hack.destroy()
        end
    end

    global.SmartSwitchers[smartSwitcherID] = nil

    if not next(global.SmartSwitchers) then
        -- reset tick indexes
        global.tick_state = 0
        global.tick_stop_index = nil
        global.tick_request_index = nil

        -- unregister events
        script.on_nth_tick(nil)
    end
end

function UpdateSmartSwitcher(smartSwitcher)

end

function OnSurfaceRemoved(event)
    local surfaceID = event.surface_index
    if debug_log then
        log("removing SPS stops on surface " .. tostring(surfaceID))
    end
    local surface = game.surfaces[surfaceID]
    if surface then
        local smart_switchers = surface.find_entities_filtered { type = "power-switch" }
        for _, entity in pairs(smart_switchers) do
            if smart_switcher_entity_names[entity.name] then
                RemoveSmartSwitcher(entity.unit_number)
            end
        end
    end
end
