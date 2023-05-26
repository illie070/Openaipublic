
RegisterCommand("weaponholster", function()
    RemoveGears()
    SetNuiFocus(true, true)
    SendNUIMessage({
        show = true,
    })

end)

RegisterNUICallback('exit', function()
    SetNuiFocus(false, false)
end)

RegisterNUICallback('aimStyle', function(data)
    TriggerEvent('rsx_weapons:updateAimstyle', data.current)
end)

RegisterNUICallback('weaponPos', function(data)
    TriggerEvent("rsx_weapons:changePos", data.current)
end)


