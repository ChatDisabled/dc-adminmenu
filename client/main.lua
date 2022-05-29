QBCore = exports['qb-core']:GetCoreObject()
PlayerDetails = nil
menuLocation = 'topright' -- e.g. topright (default), topleft, bottomright, bottomleft
menuSize = 'size-125' -- e.g. 'size-100', 'size-110', 'size-125', 'size-150', 'size-175', 'size-200'
r, g, b = 20, 255, 236 -- red, green, blue values for the menu background

MainMenu = MenuV:CreateMenu(false, Lang:t("menu.admin_menu"), menuLocation, r, g, b, menuSize, 'qbcore', 'menuv', 'qb-admin:mainmenu')
SelfMenu = MenuV:CreateMenu(false, Lang:t("menu.admin_options"), menuLocation, r, g, b, menuSize, 'qbcore', 'menuv', 'qb-admin:selfmenu')
PlayerMenu = MenuV:CreateMenu(false, Lang:t("menu.online_players"), menuLocation, r, g, b, menuSize, 'qbcore', 'menuv', 'qb-admin:playermenu')
PlayerDetailMenu = MenuV:CreateMenu(false, Lang:t("info.options"), menuLocation, r, g, b, menuSize, 'qbcore', 'menuv', 'qb-admin:playerdetailmenu')
PlayerGeneralMenu = MenuV:CreateMenu(false, Lang:t("menu.player_general"), menuLocation, r, g, b, menuSize, 'qbcore', 'menuv', 'qb-admin:playergeneral')
PlayerAdminMenu = MenuV:CreateMenu(false, Lang:t("menu.player_administration"), menuLocation, r, g, b, menuSize, 'qbcore', 'menuv', 'qb-admin:playeradministration')
PlayerExtraMenu = MenuV:CreateMenu(false, Lang:t("menu.player_extra"), menuLocation, r, g, b, menuSize, 'qbcore', 'menuv', 'qb-admin:playerextra')
BanMenu = MenuV:CreateMenu(false, Lang:t("menu.ban"), menuLocation, r, g, b, menuSize, 'qbcore', 'menuv', 'qb-admin:banmenu')
KickMenu = MenuV:CreateMenu(false, Lang:t("menu.kick"), menuLocation, r, g, b, menuSize, 'qbcore', 'menuv', 'qb-admin:kickmenu')
PermsMenu = MenuV:CreateMenu(false, Lang:t("menu.permissions"), menuLocation, r, g, b, menuSize, 'qbcore', 'menuv', 'qb-admin:permsmenu')
GiveItemMenu = MenuV:CreateMenu(false, Lang:t("menu.give_item_menu"), menuLocation, r, g, b, menuSize, 'qbcore', 'menuv', 'qb-admin:giveitemmenu')
SoundMenu = MenuV:CreateMenu(false, Lang:t("menu.play_sound"), menuLocation, r, g, b, menuSize, 'qbcore', 'menuv', 'qb-admin:soundmenu')
ServerMenu = MenuV:CreateMenu(false, Lang:t("menu.manage_server"), menuLocation, r, g, b, menuSize, 'qbcore', 'menuv', 'qb-admin:servermenu')
WeatherMenu = MenuV:CreateMenu(false, Lang:t("menu.weather_conditions"), menuLocation, r, g, b, menuSize, 'qbcore', 'menuv', 'qb-admin:weathermenu')
VehicleMenu = MenuV:CreateMenu(false, Lang:t("menu.vehicle_options"), menuLocation, r, g, b, menuSize, 'qbcore', 'menuv', 'qb-admin:vehiclemenu')
VehCategorieMenu = MenuV:CreateMenu(false, Lang:t("menu.vehicle_categories"), menuLocation, r, g, b, menuSize, 'qbcore', 'menuv', 'qb-admin:vehcategoriemenu')
VehNameMenu = MenuV:CreateMenu(false, Lang:t("menu.vehicle_models"), menuLocation, r, g, b, menuSize, 'qbcore', 'menuv', 'qb-admin:vehnamemenu')
DealerMenu = MenuV:CreateMenu(false, Lang:t("menu.dealer_list"), menuLocation, r, g, b, menuSize, 'qbcore', 'menuv', 'qb-admin:dealermenu')
DevMenu = MenuV:CreateMenu(false, Lang:t("menu.developer_options"), menuLocation, r, g, b, menuSize, 'qbcore', 'menuv', 'qb-admin:devmenu')

MainMenu:AddButton({
    icon = '😃',
    label = Lang:t("menu.admin_options"),
    value = SelfMenu,
    description = Lang:t("desc.admin_options_desc")
})
MainMenu:AddButton({
    icon = '🙍‍♂️',
    label = Lang:t("menu.player_management"),
    value = PlayerMenu,
    description = Lang:t("desc.player_management_desc"),
    select = function()
        PlayerMenu:ClearItems()
        QBCore.Functions.TriggerCallback('qb-adminmenu:callback:getplayers', function(players)
            for _, v in pairs(players) do
                PlayerMenu:AddButton({
                    label = Lang:t("info.id") .. v["id"] .. ' | ' .. v["name"],
                    value = v,
                    description = Lang:t("info.player_name"),
                    select = function(btn)
                        PlayerDetails = btn.Value
                        OpenPlayerMenus()
                    end
                })
            end
        end)
    end
})
MainMenu:AddButton({
    icon = '🎮',
    label = Lang:t("menu.server_management"),
    value = ServerMenu,
    description = Lang:t("desc.server_management_desc")
})
MainMenu:AddButton({
    icon = '🚗',
    label = Lang:t("menu.vehicles"),
    value = VehicleMenu,
    description = Lang:t("desc.vehicles_desc")
})
MainMenu:AddButton({
    icon = '🔧',
    label = Lang:t("menu.developer_options"),
    value = DevMenu,
    description = Lang:t("desc.developer_desc")
})

RegisterNetEvent('qb-admin:client:openMenu', function()
    MenuV:OpenMenu(MainMenu)
    TriggerServerEvent('qb-admin:server:check')
end)

RegisterNetEvent('qb-admin:client:playsound', function(name, volume, radius)
    TriggerServerEvent('InteractSound_SV:PlayWithinDistance', radius, name, volume)
end)

local blockedPeds = {
    "mp_m_freemode_01",
    "mp_f_freemode_01",
    "tony",
    "g_m_m_chigoon_02_m",
    "u_m_m_jesus_01",
    "a_m_y_stbla_m",
    "ig_terry_m",
    "a_m_m_ktown_m",
    "a_m_y_skater_m",
    "u_m_y_coop",
    "ig_car3guy1_m",
}

local lastSpectateCoord = nil
local isSpectating = false

AddEventHandler('qb-admin:client:inventory', function(targetPed)
    TriggerServerEvent('qb-admin:server:check')
    TriggerServerEvent("inventory:server:OpenInventory", "otherplayer", targetPed)
end)

RegisterNetEvent('qb-admin:client:spectate', function(targetPed, coords)
    local myPed = PlayerPedId()
    local targetplayer = GetPlayerFromServerId(targetPed)
    local target = GetPlayerPed(targetplayer)
    if not isSpectating then
        isSpectating = true
        SetEntityVisible(myPed, false) -- Set invisible
        SetEntityInvincible(myPed, true) -- set godmode
        lastSpectateCoord = GetEntityCoords(myPed) -- save my last coords
        SetEntityCoords(myPed, coords) -- Teleport To Player
        NetworkSetInSpectatorMode(true, target) -- Enter Spectate Mode
    else
        isSpectating = false
        NetworkSetInSpectatorMode(false, target) -- Remove From Spectate Mode
        SetEntityCoords(myPed, lastSpectateCoord) -- Return Me To My Coords
        SetEntityVisible(myPed, true) -- Remove invisible
        SetEntityInvincible(myPed, false) -- Remove godmode
        lastSpectateCoord = nil -- Reset Last Saved Coords
    end
end)

RegisterNetEvent('qb-admin:client:SendReport', function(name, src, msg)
    TriggerServerEvent('qb-admin:server:SendReport', name, src, msg)
end)

RegisterNetEvent('qb-admin:client:SaveCar', function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped)

    if veh ~= nil and veh ~= 0 then
        local plate = QBCore.Functions.GetPlate(veh)
        local props = QBCore.Functions.GetVehicleProperties(veh)
        local hash = props.model
        local vehname = GetDisplayNameFromVehicleModel(hash):lower()
        if QBCore.Shared.Vehicles[vehname] ~= nil and next(QBCore.Shared.Vehicles[vehname]) ~= nil then
            TriggerServerEvent('qb-admin:server:SaveCar', props, QBCore.Shared.Vehicles[vehname], plate)
        else
            QBCore.Functions.Notify(Lang:t("error.no_store_vehicle_garage"), 'error')
        end
    else
        QBCore.Functions.Notify(Lang:t("error.no_vehicle"), 'error')
    end
end)

local function LoadPlayerModel(skin)
    RequestModel(skin)
    while not HasModelLoaded(skin) do
      Wait(0)
    end
end

local function isPedAllowedRandom(skin)
    local retval = false
    for _, v in pairs(blockedPeds) do
        if v ~= skin then
            retval = true
        end
    end
    return retval
end

RegisterNetEvent('qb-admin:client:SetModel', function(skin)
    local ped = PlayerPedId()
    local model = GetHashKey(skin)
    SetEntityInvincible(ped, true)

    if IsModelInCdimage(model) and IsModelValid(model) then
        LoadPlayerModel(model)
        SetPlayerModel(PlayerId(), model)

        if isPedAllowedRandom(skin) then
            SetPedRandomComponentVariation(ped, true)
        end

		SetModelAsNoLongerNeeded(model)
	end
	SetEntityInvincible(ped, false)
end)

RegisterNetEvent('qb-admin:client:SetSpeed', function(speed)
    local ped = PlayerId()
    if speed == "fast" then
        SetRunSprintMultiplierForPlayer(ped, 1.49)
        SetSwimMultiplierForPlayer(ped, 1.49)
    else
        SetRunSprintMultiplierForPlayer(ped, 1.0)
        SetSwimMultiplierForPlayer(ped, 1.0)
    end
end)

RegisterNetEvent('qb-weapons:client:SetWeaponAmmoManual', function(Weapon, ammo)
    local ped = PlayerPedId()
    if Weapon ~= "current" then
        local CurrentWeapon = Weapon:upper()
        SetPedAmmo(ped, GetHashKey(CurrentWeapon), ammo)
        QBCore.Functions.Notify(Lang:t("info.ammoforthe", {value = ammo, CurrentWeapon = QBCore.Shared.Weapons[CurrentWeapon]["label"]}), 'success')
    else
        local CurrentWeapon = GetSelectedPedWeapon(ped)
        if CurrentWeapon ~= nil then
            SetPedAmmo(ped, CurrentWeapon, ammo)
            QBCore.Functions.Notify(Lang:t("info.ammoforthe", {value = ammo, CurrentWeapon = QBCore.Shared.Weapons[CurrentWeapon]["label"]}), 'success')
        else
            QBCore.Functions.Notify(Lang:t("error.no_weapon"), 'error')
        end
    end
end)

RegisterNetEvent('qb-admin:client:GiveNuiFocus', function(focus, mouse)
    SetNuiFocus(focus, mouse)
end)

RegisterNetEvent('qb-admin:client:getsounds', function(sounds)
    local soundMenu = {
        {
            header = Lang:t('menu.choose_sound'),
            isMenuHeader = true
        }
    }

    for i = 1, #sounds do
        soundMenu[#soundMenu + 1] = {
            header = sounds[i],
            txt = "",
            params = {
                event = "qb-admin:client:openSoundMenu",
                args = {
                    name = sounds[i]
                }
            }
        }
    end

    exports['qb-menu']:openMenu(soundMenu)
end)
