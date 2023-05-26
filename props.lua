
local Weapons = {}

local QBCore = exports['qb-core']:GetCoreObject()

local Loaded = true
local ShowWeapons = Config.ShowWeapons
local handgunFlag = 'backhandgun'
local rifleFlag = 'assault'
local offsetCoords = nil
local weaponCategoryOffsets = {}
local showPistol = true
local showKnife = true
local holstered  = true
local blocked = false
local PlayerData = {}
local switched = false

SearchWeapons = {}
BodyWeapon = {}

function table.removekey(table, key)
	local element = table[key]
	table[key] = nil
	return element
end

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(2000)
        PlayerData = QBCore.Functions.GetPlayerData()
        if PlayerData and PlayerData.items then
            for k,v in pairs(PlayerData.items) do 
                v.name = string.upper(v.name)
                if SearchWeapons[v.name] ~= nil then 
                    SearchWeapons[v.name].haveWeapon = true 
                    BodyWeapon[v.name] = SearchWeapons[v.name]
                end
            end
            Citizen.Wait(2000)
            for k,v in pairs(BodyWeapon) do 
                found = false
                for k2,v2 in pairs(PlayerData.items) do 
                    if v2.name == v.name then 
                        found = true
                    end
                end
                if not found then 
                    table.removekey(BodyWeapon, k)
                    RemoveGear(v.name)
                end
            end
        end
    end
end)


RegisterCommand("hideweapon", function(source)
	local ped = PlayerPedId()
	local PlayerData = QBCore.Functions.GetPlayerData()
    if showPistol and showKnife then
        local _canHide = true
        for k,v in pairs(SearchWeapons) do
			for k2,v2 in pairs(PlayerData.items) do 
				if v2.name == v.name then 
					if(not SearchWeapons[string.upper(k)].canHide) then
						_canHide = false
					end
				end
			end
        end
        if _canHide then
            SetCurrentPedWeapon(ped, GetHashKey('WEAPON_UNARMED'), true)
			SetPedCanSwitchWeapon(ped, false)
            showPistol = false
            showKnife = false 
			RemoveGears()
		else
			ShowNotification("!You can't keep this gun¡")
        end
    else
        showPistol = true
        showKnife = true
		SpawnWeapon()
		SetPedCanSwitchWeapon(ped, true)
    end
end)

ShowNotification = function(msg)
	SetTextFont(fontId)
	SetNotificationTextEntry('STRING')
	AddTextComponentSubstringPlayerName(msg)
	DrawNotification(false, true)
end

SearchWeapons = {}
BodyWeapon = {}
function table.removekey(table, key)
	local element = table[key]
	table[key] = nil
	return element
 end
 Citizen.CreateThread(function()
    for k,v in pairs(Config.ShowWeapons) do 
        SearchWeapons[v.name] = Config.ShowWeapons[k]
        SearchWeapons[v.name].haveWeapon = false
    end
    while true do 
        Citizen.Wait(2000)
        PlayerData = QBCore.Functions.GetPlayerData()
        if PlayerData and PlayerData.items then -- add this check
            for k,v in pairs(PlayerData.items) do 
                v.name = string.upper(v.name)
                if SearchWeapons[v.name] ~= nil then 
                    SearchWeapons[v.name].haveWeapon = true 
                    BodyWeapon[v.name] = SearchWeapons[v.name]
                end
            end
        end
    end
end)


Citizen.CreateThread(function()


	while not Loaded do
		Citizen.Wait(500)
	end

	local playerPed = PlayerPedId()
	SetPedCanSwitchWeapon(playerPed, true)
	ShowWeapons = Config.ShowWeapons
	weaponCategoryOffsets = Config.WeaponCategoryOffsets


	while true do
		Citizen.Wait(1500)
		playerPed = PlayerPedId()

		for k,v in pairs(BodyWeapon) do
			local weaponHash = GetHashKey(v.name)
			local onPlayer = false
			if showPistol then 
				for weaponName, entity in pairs(Weapons) do
					if weaponName == v.name then
						onPlayer = true
						break
					end
				end
				if onPlayer == false and weaponHash ~= GetSelectedPedWeapon(playerPed) then 
					if (v.category == 'handguns' or v.category == 'revolver' or v.category == 'bighandgun' or v.category == 'smallmelee') then
						if (showPistol) then
							SpawnWeapon(v.name)
						else
							RemoveGear(v.name)
						end
					elseif v.model ~= nil then
						RemoveGear(v.name)
						Citizen.Wait(200)
						SpawnWeapon(v.name)
					end
					
				elseif onPlayer and weaponHash == GetSelectedPedWeapon(playerPed) then
					RemoveGear(v.name)
				end
			else
			 	RemoveGear(v.name)
		    end
		end
	end
end)



function RemoveGears()
	for weaponName, entity in pairs(Weapons) do
		while DoesEntityExist(entity) do
			SetEntityAsMissionEntity(entity,  false,  true)
			DeleteObject(entity)
		end
	end
	Weapons = {}
end

function GetCoords(cat)

	for i=1, #weaponCategoryOffsets, 1 do
		if weaponCategoryOffsets[i].category == cat then
			return weaponCategoryOffsets[i].bone, weaponCategoryOffsets[i].x, weaponCategoryOffsets[i].y, weaponCategoryOffsets[i].z, weaponCategoryOffsets[i].xRot, weaponCategoryOffsets[i].yRot, weaponCategoryOffsets[i].zRot
		end
	end
	
end
function RemoveGear(weapon)
	local _Weapons = {}
	for weaponName, entity in pairs(Weapons) do
		if weaponName ~= weapon then
			_Weapons[weaponName] = entity
		else
			SetEntityAsMissionEntity(entity,  false,  true)
			DeleteObject(entity)
		end
	end

	Weapons = _Weapons
end

function SpawnWeapon(weapon)
	local bone       = nil
	local boneX      = 0.0
	local boneY      = 0.0
	local boneZ      = 0.0
	local boneXRot   = 0.0
	local boneYRot   = 0.0
	local boneZRot   = 0.0
	local playerPed  = PlayerPedId()
	local model      = nil


	for i=1, #ShowWeapons, 1 do
		if ShowWeapons[i].name == weapon then
			if ShowWeapons[i].category == 'handguns' or ShowWeapons[i].category == 'revolver' then

				offsetCoords = handgunFlag

			elseif ShowWeapons[i].category == 'machine' or ShowWeapons[i].category == 'assault' or ShowWeapons[i].category == 'shotgun' or ShowWeapons[i].category == 'sniper' or ShowWeapons[i].category == 'heavy' then
				offsetCoords = rifleFlag
			else
				offsetCoords = ShowWeapons[i].category
			end
			

			bone, boneX, boneY, boneZ, boneXRot, boneYRot, boneZRot = GetCoords(offsetCoords)
			model      = ShowWeapons[i].model
		
			break
		
		end	
	end

	GameSpawnObject(model, {
		x = x,
		y = y,
		z = z
	}, function(object)
		local boneIndex = GetPedBoneIndex(playerPed, bone)
		local bonePos 	= GetWorldPositionOfEntityBone(playerPed, boneIndex)
		AttachEntityToEntity(object, playerPed, boneIndex, boneX, boneY, boneZ, boneXRot, boneYRot, boneZRot, false, false, false, false, 2, true)
		Weapons[weapon] = object
	end)
end

GameSpawnObject = function(model, coords, cb)
	local model = (type(model) == 'number' and model or GetHashKey(model))

	Citizen.CreateThread(function()
  
	  RequestModel(model)
  
	  while not HasModelLoaded(model) do
		Citizen.Wait(0)
	  end
	  local obj = CreateObject(model, coords.x, coords.y, coords.z, true, true, true)
  
	  if cb ~= nil then
		cb(obj)
	  end
  
	end)
end






RegisterNetEvent('rsx_weapons:changePos', function(current)
	RemoveGears()
	if current == 'handguns' or current == 'waisthandgun' then
		handgunFlag = current
	elseif current == 'backhandgun' then 
		handgunFlag = current
	elseif current == 'leghandgun' or current == 'hiphandgun' or current == 'handguns2' then
		handgunFlag = current
	elseif current == 'chesthandgun' then
		handgunFlag = current
	elseif current == 'boxers' then
		handgunFlag = current
	elseif current == 'assault' then
		rifleFlag = current
	elseif current == 'frontrifle' then
		rifleFlag = current
	end
	switched = true
end)

function loadAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Citizen.Wait(100)
	end
end

function CheckWeapon(ped, newWeap)
	if IsEntityDead(ped) then
		blocked = false
			return false
		else
			for i = 1, #ShowWeapons do
				if GetHashKey(ShowWeapons[i].name) == GetSelectedPedWeapon(ped) then
					return true
				end
			end
		return false
	end
end


function loadAnimDict2(dict)
	while ( not HasAnimDictLoaded(dict)) do
		RequestAnimDict(dict)
		Citizen.Wait(0)
	end
end

Citizen.CreateThread(function()
	loadAnimDict("rcmjosh4")
    loadAnimDict("reaction@intimidation@cop@unarmed")
    loadAnimDict("reaction@intimidation@1h")
	loadAnimDict2("combat@combat_reactions@pistol_1h_gang")
	loadAnimDict2("combat@combat_reactions@pistol_1h_hillbilly")
	loadAnimDict2("reaction@male_stand@big_variations@d")
	local rot = 0
	local wepCat
	local lastWep

	Citizen.Wait(0)

	while (true) do
		local ped = PlayerPedId()
		Citizen.Wait(50)
		
		rot = GetEntityHeading(ped)
		if not IsPedInAnyVehicle(ped, true) then
			if (GetPedParachuteState(ped) == -1 or GetPedParachuteState(ped) == 0) and not IsPedInParachuteFreeFall(ped) then
				wepCat = GetWeapontypeGroup(GetSelectedPedWeapon(ped))
				if CheckWeapon(ped) then
					if(wepCat == 416676503 or wepCat == 690389602) then
						if holstered then
							if handgunFlag == 'backhandgun' then
								blocked   = true
								SetPedCurrentWeaponVisible(ped, 1, 1, 1, 1)
								TaskPlayAnimAdvanced(ped, "reaction@intimidation@1h", "intro", GetEntityCoords(ped, true), 0, 0, rot, 8.0, 3.0, -1, 50, 0.325, 0, 0)
								Citizen.Wait(700)
								ClearPedTasks(ped)
								holstered = false
								lastWep = GetSelectedPedWeapon(ped)
							elseif handgunFlag == 'boxers' then
								blocked   = true
								SetPedCurrentWeaponVisible(ped, 1, 1, 1, 1)
								TaskPlayAnimAdvanced(ped, "combat@combat_reactions@pistol_1h_gang", "0", GetEntityCoords(ped, true), 0, 0, rot, 8.0, 3.0, -1, 50, 0.325, 0, 0)
								Citizen.Wait(700)
								ClearPedTasks(ped)
								holstered = false
								lastWep = GetSelectedPedWeapon(ped)
							elseif handgunFlag == 'chesthandgun' then
								blocked   = true
								SetPedCurrentWeaponVisible(ped, 1, 1, 1, 1)
								TaskPlayAnimAdvanced(ped, "combat@combat_reactions@pistol_1h_gang", "0", GetEntityCoords(ped, true), 0, 0, rot, 8.0, 3.0, -1, 50, 0.325, 0, 0)
								Citizen.Wait(700)
								ClearPedTasks(ped)
								holstered = false
								lastWep = GetSelectedPedWeapon(ped)
							elseif handgunFlag == 'leghandgun' then
								blocked   = true
								SetPedCurrentWeaponVisible(ped, 1, 1, 1, 1)
								TaskPlayAnimAdvanced(ped, "reaction@male_stand@big_variations@d", "react_big_variations_m", GetEntityCoords(ped, true), 0, 0, rot, 8.0, 3.0, -1, 50, 0.325, 0, 0)
								Citizen.Wait(700)
								ClearPedTasks(ped)
								holstered = false
								lastWep = GetSelectedPedWeapon(ped)
							else
								blocked   = true
								SetPedCurrentWeaponVisible(ped, 0, 1, 1, 1)
								SetPedCurrentWeaponVisible(ped, 1, 1, 1, 1)
								TaskPlayAnim(ped, "rcmjosh4", "josh_leadout_cop2", 8.0, 2.0, -1, 48, 10, 0, 0, 0 )
								Citizen.Wait(700)
								ClearPedTasks(ped)
								holstered = false
								lastWep = GetSelectedPedWeapon(ped)
							end
						else
							blocked = false
						end
					else
						if holstered then
							if rifleFlag == 'frontrifle' then
								blocked   = true
								SetPedCurrentWeaponVisible(ped, 1, 1, 1, 1)
								TaskPlayAnimAdvanced(ped, "combat@combat_reactions@pistol_1h_hillbilly", "0", GetEntityCoords(ped, true), 0, 0, rot, 8.0, 3.0, -1, 50, 0.325, 0, 0)
								Citizen.Wait(700)
								ClearPedTasks(ped)
								holstered = false
								lastWep = GetSelectedPedWeapon(ped)
							else 
								blocked   = true
								SetPedCurrentWeaponVisible(ped, 1, 1, 1, 1)
								TaskPlayAnimAdvanced(ped, "reaction@intimidation@1h", "intro", GetEntityCoords(ped, true), 0, 0, rot, 8.0, 3.0, -1, 50, 0.325, 0, 0)
								Citizen.Wait(700)
								ClearPedTasks(ped)
								holstered = false
								lastWep = GetSelectedPedWeapon(ped)
							end
						else
							blocked = false
						end
					end
				else
					if (GetWeapontypeGroup(lastWep) == 416676503 or GetWeapontypeGroup(lastWep) == 690389602) then
						if not holstered then
							if handgunFlag == 'backhandgun' then
								TaskPlayAnimAdvanced(ped, "reaction@intimidation@1h", "outro", GetEntityCoords(ped, true), 0, 0, rot, 8.0, 3.0, -1, 50, 0.125, 0, 0) -- Change 50 to 30 if you want to stand still when holstering weapon
								Citizen.Wait(700)
								ClearPedTasks(ped)
								holstered = true
							elseif handgunFlag == 'boxers' then
								TaskPlayAnimAdvanced(ped, "combat@combat_reactions@pistol_1h_gang", "0", GetEntityCoords(ped, true), 0, 0, rot, 8.0, 3.0, -1, 50, 0.125, 0, 0) -- Change 50 to 30 if you want to stand still when holstering weapon
								Citizen.Wait(700)
								ClearPedTasks(ped)
								holstered = true
							elseif handgunFlag == 'leghandgun' then
								TaskPlayAnimAdvanced(ped, "reaction@male_stand@big_variations@d", "react_big_variations_m", GetEntityCoords(ped, true), 0, 0, rot, 8.0, 3.0, -1, 50, 0.125, 0, 0) -- Change 50 to 30 if you want to stand still when holstering weapon
								Citizen.Wait(700)
								ClearPedTasks(ped)
								holstered = true
							elseif handgunFlag == 'chesthandgun' then
								TaskPlayAnimAdvanced(ped, "combat@combat_reactions@pistol_1h_gang", "0", GetEntityCoords(ped, true), 0, 0, rot, 8.0, 3.0, -1, 50, 0.125, 0, 0)
								Citizen.Wait(700)
								ClearPedTasks(ped)
								holstered = true
							else
								TaskPlayAnimAdvanced(ped, "reaction@intimidation@cop@unarmed", "outro", GetEntityCoords(ped, true), 0, 0, rot, 8.0, 3.0, -1, 50, 0.125, 0, 0) -- Change 50 to 30 if you want to stand still when holstering weapon
								Citizen.Wait(700)
								ClearPedTasks(ped)
								holstered = true
							end
						end
					else 
						if not holstered then
							if rifleFlag == 'frontrifle' then
								TaskPlayAnimAdvanced(ped, "combat@combat_reactions@pistol_1h_gang", "0", GetEntityCoords(ped, true), 0, 0, rot, 8.0, 3.0, -1, 50, 0.125, 0, 0) -- Change 50 to 30 if you want to stand still when holstering weapon
								Citizen.Wait(700)
								ClearPedTasks(ped)
								holstered = true
							else
								TaskPlayAnimAdvanced(ped, "reaction@intimidation@1h", "outro", GetEntityCoords(ped, true), 0, 0, rot, 8.0, 3.0, -1, 50, 0.125, 0, 0) -- Change 50 to 30 if you want to stand still when holstering weapon
								Citizen.Wait(700)
								ClearPedTasks(ped)
								holstered = true
							end
						end
					end
				end
			elseif (GetVehiclePedIsTryingToEnter (ped) == 0) then
				holstered = false
			else
				SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)
			end
		else
			holstered = true
		end
	end
end)