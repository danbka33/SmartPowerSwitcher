--[[ Copyright (c) 2021 danbka33
 * Part of Smart Power Switcher
 *
 * See LICENSE.md in the project directory for license information.
--]]

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

    if global.tick_state == 1 then
        -- update switchers

        for i = 1, updates_per_tick, 1 do
            if global.tick_switcher_index and not global.SmartSwitchers[global.tick_switcher_index] then
                global.tick_state = 0
                RemoveSmartSwitcher(global.tick_switcher_index)
                return
            end

            local switcherID, switcher = next(global.SmartSwitchers, global.tick_switcher_index)
            if switcherID then
                global.tick_switcher_index = switcherID
                UpdateSmartSwitcher(switcherID, switcher, tick)
            else
                -- switcher updates complete, moving on
                global.tick_switcher_index = nil
                global.tick_state = 0
                return
            end
        end
    else
        global.tick_switcher_index = nil
        global.tick_state = 1
    end

end

function turnOnSwitcher(switcher)
    switcher.power_on_started = nil;

    switcher.enabled = true;
    if switcher.hack and switcher.hack.valid then
        switcher.hack.get_control_behavior().parameters = { { index = 1, signal = { type = "virtual", name = smart_switcher_enable_signal }, count = 1 } }
    end
end

function turnOffSwitcher(switcher)
    switcher.power_off_started = nil;

    switcher.enabled = false;
    if switcher.hack and switcher.hack.valid then
        switcher.hack.get_control_behavior().parameters = { { index = 1, signal = { type = "virtual", name = smart_switcher_enable_signal }, count = 0 } }
    end
end

function CreateSmartSwitcher(entity)
    if global.SmartSwitchers[entity.unit_number] then
        return
    end
    local switcher_offset = smart_switcher_entity_names[entity.name]
    local posIn, posOut, rotOut, search_area

    posIn = { entity.position.x + switcher_offset, entity.position.y }
    posOut = { entity.position.x - 1 + switcher_offset, entity.position.y }
    rotOut = 0
    search_area = {
        { entity.position.x + 0.001 - 1 + switcher_offset, entity.position.y + 0.001 - 1 },
        { entity.position.x - 0.001 + 1 + switcher_offset, entity.position.y - 0.001 + 1 }
    }

    local input, settingInput, lampctrl, hack
    local ghosts = entity.surface.find_entities(search_area)
    for _, ghost in pairs(ghosts) do
        if ghost.valid then
            if ghost.name == "entity-ghost" then
                if ghost.ghost_name == smart_switcher_settings then
                    _, settingInput = ghost.revive()
                elseif ghost.ghost_name == smart_switcher_input then
                    _, input = ghost.revive()
                elseif ghost.ghost_name == smart_switcher_lamp_control then
                    _, lampctrl = ghost.revive()
                elseif ghost.ghost_name == smart_switcher_hack then
                    _, hack = ghost.revive()
                end
            elseif ghost.name == smart_switcher_settings then
                settingInput = ghost
            elseif ghost.name == smart_switcher_input then
                input = ghost
            elseif ghost.name == smart_switcher_lamp_control then
                lampctrl = ghost
            elseif ghost.name == smart_switcher_hack then
                hack = ghost
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
    input.operable = false
    input.minable = false
    input.destructible = false

    if settingInput == nil then
        settingInput = entity.surface.create_entity {
            name = smart_switcher_settings,
            position = posOut,
            force = entity.force
        }
    end
    settingInput.operable = false
    settingInput.minable = false
    settingInput.destructible = false

    if lampctrl == nil then
        lampctrl = entity.surface.create_entity {
            name = smart_switcher_lamp_control,
            position = { input.position.x + 0.45, input.position.y + 0.45 },
            force = entity.force
        }
    end
    lampctrl.operable = false
    lampctrl.minable = false
    lampctrl.destructible = false

    if hack == nil then
        hack = entity.surface.create_entity {
            name = smart_switcher_hack,
            position = { input.position.x - 0.45, input.position.y + 0.45 },
            force = entity.force
        }
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

    entity.get_or_create_control_behavior().connect_to_logistic_network = false;
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
        global.tick_state = 0;
        global.tick_stop_index = nil

        -- unregister events
        script.on_nth_tick(nil)
    end
end

function UpdateSmartSwitcher(smartSwitcherID, switcher, tick)
    if debug_log then
        log('Update switcher ' .. smartSwitcherID)
    end

    local disabled = false;

    if not switcher or not switcher.entity.valid or not switcher.input.valid or not switcher.settingInput.valid or not switcher.lamp_control.valid or not switcher.hack.valid then
        RemoveSmartSwitcher(smartSwitcherID)
        return
    end

    -- Disconnect all wires from Smart Power Switcher
    local k = 0;
    for _, redc in pairs(switcher.entity.circuit_connected_entities.red) do
        if k == 1 then
            switcher.entity.disconnect_neighbour(({ target_entity = redc, wire = defines.wire_type.red }))
        end
        k = k + 1;
    end
    k = 0;
    for _, grennc in pairs(switcher.entity.circuit_connected_entities.green) do
        if k == 1 then
            switcher.entity.disconnect_neighbour(({ target_entity = grennc, wire = defines.wire_type.green }))
        end
        k = k + 1;
    end

    local limitedSignals = {}
    local signals_filtered = {}

    if detectShortCircuit(switcher) then
        if debug_log then
            log('Short Circuit')
        end
        turnOffSwitcher(switcher)
        setLamp(switcher, "red", 1)
        goto continue
    end

    local foundEnableSignal = nil;
    local foundPlusInverseSignal = false;
    local foundMinusInverseSignal = false;

    local settingSignals = switcher.settingInput.get_merged_signals()
    if not settingSignals then
        if debug_log then
            log('no settings input signals')
        end
        turnOffSwitcher(switcher)
        setLamp(switcher, "red", 1)
        goto continue
    end

    local foundThresholdSignal = false
    local foundTurnOffSignal = false
    local foundTurnOnSignal = false

    for _, v in pairs(settingSignals) do
        if v.signal.name and v.signal.type then
            if v.signal.name == smart_switcher_threshold_signal and v.count > 0 then
                switcher.delta = v.count
                foundThresholdSignal = true
            elseif v.signal.name == smart_switcher_enable_signal then
                foundEnableSignal = v.count
            elseif v.signal.name == smart_switcher_off_delay_signal and v.count > 0 then
                switcher.power_off_delay = v.count
                foundTurnOffSignal = true
            elseif v.signal.name == smart_switcher_on_delay_signal and v.count > 0 then
                switcher.power_on_delay = v.count
                foundTurnOnSignal = true
            elseif v.signal.name == smart_switcher_enable_minus_inverse and v.count > 0 then
                foundMinusInverseSignal = true
            elseif v.signal.name == smart_switcher_enable_plus_inverse and v.count > 0 then
                foundPlusInverseSignal = true
            else

                if v.signal.name and v.count > 0 then
                    limitedSignals[v.signal.name] = v.count
                else
                    signals_filtered[v.signal] = v.count
                end
            end
        end
    end

    if foundEnableSignal and foundEnableSignal > 0 then
        turnOnSwitcher(switcher)
        setLamp(switcher, "green", 1)
        goto continue
    end

    if foundEnableSignal and foundEnableSignal < 0 then
        turnOffSwitcher(switcher)
        setLamp(switcher, "yellow", 1)
        goto continue
    end

    if (not next(limitedSignals) and not next(signals_filtered)) then
        disabled = true
        turnOffSwitcher(switcher)
        setLamp(switcher, "red", 1)
        if (debug_log) then
            log('no settings input signals 2')
        end
    end

    if not foundThresholdSignal then
        switcher.delta = default_threshold
    end

    if not foundTurnOffSignal then
        switcher.power_off_delay = power_off_delay
    end

    if not foundTurnOnSignal then
        switcher.power_on_delay = power_on_delay
    end

    local signals = switcher.input.get_merged_signals()

    local filtered_object_signals = {}

    for _, v in pairs(signals) do
        if not (v.signal.name == smart_switcher_threshold_signal or v.signal.name == smart_switcher_enable_signal
                or v.signal.name == smart_switcher_off_delay_signal or v.signal.name == smart_switcher_on_delay_signal
                or v.signal.name == smart_switcher_enable_minus_inverse or v.signal.name == smart_switcher_enable_plus_inverse) then
            filtered_object_signals[v.signal] = v.count
        end
    end

    if next(signals_filtered) then
        local foundAllObjects = true;

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

                if (foundMinusInverseSignal == true) then
                    if not foundedObject or foundedObject.count < math.abs(count) then
                        foundAllObjects = false
                    end
                else
                    if not foundedObject then
                        disabled = true
                        if debug_log then
                            log(signal.name .. " not found ")
                        end
                    else
                        if foundedObject.count < math.abs(count) then
                            disabled = true
                            if debug_log then
                                log(foundedObject.signal.name .. " less than " .. tostring(math.abs(count)))
                            end
                        end
                    end
                end
            end
        end

        if (foundMinusInverseSignal == true and foundAllObjects == true) then
            disabled = true
        end
    end

    if next(limitedSignals) then
        local foundAnyObject = false;
        for name, count in pairs(limitedSignals) do

            if name then

                local bottom = count - switcher.delta;

                if (switcher.delta >= count or math.abs(bottom) >= count) then
                    turnOffSwitcher(switcher)
                    setLamp(switcher, "red", 1)
                    if debug_log then
                        log('disabled because bottom limit more or equals top limit')
                    end
                    goto continue
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

                if switcher.limitedSignalsGain[name] == nil then
                    switcher.limitedSignalsGain[name] = false
                end

                if foundedObject and foundedObject.count >= count and switcher.limitedSignalsGain[name] == false then
                    switcher.limitedSignalsGain[name] = true
                end

                if switcher.limitedSignalsGain[name] == true and foundedObject and foundedObject.count <= bottom then
                    switcher.limitedSignalsGain[name] = false
                end

                if switcher.limitedSignalsGain[name] == true and foundPlusInverseSignal == false then
                    disabled = true
                    if debug_log then
                        log("gain resource")
                    end
                elseif switcher.limitedSignalsGain[name] == false and foundPlusInverseSignal == true then
                    disabled = true
                end
            end
        end

        if foundAnyObject == false and next(switcher.limitedSignalsGain) then
            for name, _ in pairs(switcher.limitedSignalsGain) do
                switcher.limitedSignalsGain[name] = false
            end
        end
    end

    if switcher.power_off_started and tick > switcher.power_off_started then

        turnOffSwitcher(switcher)
        setLamp(switcher, "yellow", 1)

        if debug_log then
            log("Set power OFF")
        end
    elseif switcher.power_on_started and tick > switcher.power_on_started then

        turnOnSwitcher(switcher)
        setLamp(switcher, "green", 1)

        if debug_log then
            log("Set power ON")
        end
    else
        for _, parameter in pairs(switcher.lamp_control.get_control_behavior().parameters) do
            if parameter.signal and parameter.signal.type and parameter.signal.name
                    and parameter.signal.type == 'virtual' and parameter.signal.name == 'signal-red'
                    and disabled == true then
                setLamp(switcher, "yellow", 1)
            end
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

    :: continue ::
end

function OnSurfaceRemoved(event)
    local surfaceID = event.surface_index
    if debug_log then
        log("removing SPS switcher on surface " .. tostring(surfaceID))
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
