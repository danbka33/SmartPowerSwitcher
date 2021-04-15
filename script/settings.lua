debug_log = settings.global["spw-interface-debug-logfile"].value
power_on_delay = settings.global["spw-on-delay"].value
power_off_delay = settings.global["spw-off-delay"].value

default_threshold = settings.global['spw-default-threshold'].value

updates_per_tick = settings.global["spw-updates-per-tick"].value
nth_tick = settings.global["spw-nth-tick"].value
if nth_tick > 1 then
    updates_per_tick = 1
end

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    if not event then return end

    if event.setting == "spw-interface-debug-logfile" then
        debug_log = settings.global["spw-interface-debug-logfile"].value
    end
    if event.setting == "spw-on-delay" then
        power_on_delay = settings.global["spw-on-delay"].value
    end
    if event.setting == "spw-off-delay" then
        power_off_delay = settings.global["spw-off-delay"].value
    end
    if event.setting == "spw-default-threshold" then
        default_threshold = settings.global["spw-default-threshold"].value
    end
    if event.setting == "spw-updates-per-tick" then
        updates_per_tick = settings.global["spw-updates-per-tick"].value
    end
    if event.setting == "spw-nth_tick" then
        nth_tick = settings.global["spw-nth_tick"].value
        if nth_tick > 1 then
            updates_per_tick = 1
        end
        script.on_nth_tick(nil)
        if next(global.SmartSwitchers) then
            script.on_nth_tick(dispatcher_nth_tick, OnTick)
        end
    end
end)
