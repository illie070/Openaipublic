
RegisterNetEvent('rsx_weapons:updateAimstyle', function(style)
    if style == "default" or style == nil then
        SetWeaponAnimationOverride(PlayerPedId(), GetHashKey('Default'))
    elseif style == "hillbilly" then
        SetWeaponAnimationOverride(PlayerPedId(), GetHashKey('Hillbilly'))
    elseif style == "gang" then
        SetWeaponAnimationOverride(PlayerPedId(), GetHashKey("Gang1H"))
    end
end)
