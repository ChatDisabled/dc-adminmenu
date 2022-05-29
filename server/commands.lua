QBCore.Commands.Add('blips', Lang:t("commands.blips_for_player"), {}, false, function(source)
    local src = source
    TriggerClientEvent('qb-admin:client:toggleBlips', src)
end, 'admin')

QBCore.Commands.Add('names', Lang:t("commands.player_name_overhead"), {}, false, function(source)
    local src = source
    TriggerClientEvent('qb-admin:client:toggleNames', src)
end, 'admin')

QBCore.Commands.Add('coords', Lang:t("commands.coords_dev_command"), {}, false, function(source)
    local src = source
    TriggerClientEvent('qb-admin:client:ToggleCoords', src)
end, 'admin')

QBCore.Commands.Add('noclip', Lang:t("commands.toogle_noclip"), {}, false, function(source)
    local src = source
    TriggerClientEvent('qb-admin:client:ToggleNoClip', src)
end, 'admin')

QBCore.Commands.Add('admincar', Lang:t("commands.save_vehicle_garage"), {}, false, function(source)
    TriggerClientEvent('qb-admin:client:SaveCar', source)
end, 'admin')

QBCore.Commands.Add('announce', Lang:t("commands.make_announcement"), {}, false, function(_, args)
    local msg = table.concat(args, ' ')
    if msg == '' then return end
    TriggerClientEvent('chat:addMessage', -1, {
        color = { 255, 0, 0},
        multiline = true,
        args = {"Announcement", msg}
    })
end, 'admin')

QBCore.Commands.Add('admin', Lang:t("commands.open_admin"), {}, false, function(source)
    TriggerClientEvent('qb-admin:client:openMenu', source)
end, 'admin')

QBCore.Commands.Add('report', Lang:t("info.admin_report"), {{name='message', help='Message'}}, true, function(source, args)
    local src = source
    local msg = table.concat(args, ' ')
    local Player = QBCore.Functions.GetPlayer(source)
    TriggerClientEvent('qb-admin:client:SendReport', -1, GetPlayerName(src), src, msg)
    TriggerEvent('qb-log:server:CreateLog', 'report', 'Report', 'green', '**'..GetPlayerName(source)..'** (CitizenID: '..Player.PlayerData.citizenid..' | ID: '..source..') **Report:** ' ..msg, false)
end)

QBCore.Commands.Add('staffchat', Lang:t("commands.staffchat_message"), {{name='message', help='Message'}}, true, function(source, args)
    local msg = table.concat(args, ' ')
    TriggerEvent('qb-admin:server:Staffchat:addMessage', GetPlayerName(source), msg)
end, 'admin')

QBCore.Commands.Add('s', Lang:t("commands.staffchat_message"), {{name='message', help='Message'}}, true, function(source, args)
    local msg = table.concat(args, ' ')
    TriggerEvent('qb-admin:server:Staffchat:addMessage', GetPlayerName(source), msg)
end, 'admin')

QBCore.Commands.Add('givenuifocus', Lang:t("commands.nui_focus"), {{name='id', help='Player id'}, {name='focus', help='Set focus on/off'}, {name='mouse', help='Set mouse on/off'}}, true, function(_, args)
    local playerid = tonumber(args[1])
    local focus = args[2]
    local mouse = args[3]
    TriggerClientEvent('qb-admin:client:GiveNuiFocus', playerid, focus, mouse)
end, 'admin')

QBCore.Commands.Add('warn', Lang:t("commands.warn_a_player"), {{name='ID', help='Player'}, {name='Reason', help='Mention a reason'}}, true, function(source, args)
    local targetPlayer = QBCore.Functions.GetPlayer(tonumber(args[1]))
    local senderPlayer = QBCore.Functions.GetPlayer(source)
    table.remove(args, 1)
    local msg = table.concat(args, ' ')
    local warnId = 'WARN-'..math.random(1111, 9999)
    if targetPlayer ~= nil then
        TriggerClientEvent('chat:addMessage', targetPlayer.PlayerData.source, {
            color = { 255, 0, 0},
            multiline = true,
            args = {Lang:t("info.warning_chat_message")..' '..GetPlayerName(source), msg}
        })
        TriggerClientEvent('chat:addMessage', source, {
            color = { 255, 0, 0},
            multiline = true,
            args = {Lang:t("info.warning_staff_message")..GetPlayerName(targetPlayer.PlayerData.source), msg}
        })
        MySQL.Async.insert('INSERT INTO player_warns (senderIdentifier, targetIdentifier, reason, warnId) VALUES (?, ?, ?, ?)', {
            senderPlayer.PlayerData.license,
            targetPlayer.PlayerData.license,
            msg,
            warnId
        })
    else
        TriggerClientEvent('QBCore:Notify', source, Lang:t("error.not_online"), 'error')
    end
end, 'admin')

QBCore.Commands.Add('checkwarns', Lang:t("commands.check_player_warning"), {{name='id', help='Player'}, {name='Warning', help='Number of warning, (1, 2 or 3 etc..)'}}, false, function(source, args)
    if args[2] == nil then
        local targetPlayer = QBCore.Functions.GetPlayer(tonumber(args[1]))
        local result = MySQL.Sync.fetchAll('SELECT * FROM player_warns WHERE targetIdentifier = ?', { targetPlayer.PlayerData.license })
        TriggerClientEvent('chat:addMessage', source, {
            color = { 255, 0, 0},
            multiline = true,
            args = {'SYSTEM', targetPlayer.PlayerData.name..' has '..#result..' warnings!'}
        })
    else
        local targetPlayer = QBCore.Functions.GetPlayer(tonumber(args[1]))
        local warnings = MySQL.Sync.fetchAll('SELECT * FROM player_warns WHERE targetIdentifier = ?', { targetPlayer.PlayerData.license })
        local selectedWarning = tonumber(args[2])
        if warnings[selectedWarning] ~= nil then
            local sender = QBCore.Functions.GetPlayer(warnings[selectedWarning].senderIdentifier)
            TriggerClientEvent('chat:addMessage', source, {
                color = { 255, 0, 0},
                multiline = true,
                args = {'SYSTEM', targetPlayer.PlayerData.name..' has been warned by '..sender.PlayerData.name..', Reason: '..warnings[selectedWarning].reason}
            })
        end
    end
end, 'admin')

QBCore.Commands.Add('delwarn', Lang:t("commands.delete_player_warning"), {{name='id', help='Player'}, {name='Warning', help='Number of warning, (1, 2 or 3 etc..)'}}, true, function(source, args)
    local targetPlayer = QBCore.Functions.GetPlayer(tonumber(args[1]))
    local warnings = MySQL.Sync.fetchAll('SELECT * FROM player_warns WHERE targetIdentifier = ?', { targetPlayer.PlayerData.license })
    local selectedWarning = tonumber(args[2])
    if warnings[selectedWarning] ~= nil then
        TriggerClientEvent('chat:addMessage', source, {
            color = { 255, 0, 0},
            multiline = true,
            args = {'SYSTEM', 'You have deleted warning ('..selectedWarning..') , Reason: '..warnings[selectedWarning].reason}
        })
        MySQL.Async.execute('DELETE FROM player_warns WHERE warnId = ?', { warnings[selectedWarning].warnId })
    end
end, 'admin')

QBCore.Commands.Add('reportr', Lang:t("commands.reply_to_report"), {{name='id', help='Player'}, {name = 'message', help = 'Message to respond with'}}, false, function(source, args)
    local src = source
    local playerId = tonumber(args[1])
    table.remove(args, 1)
    local msg = table.concat(args, ' ')
    local OtherPlayer = QBCore.Functions.GetPlayer(playerId)
    if msg == '' then return end
    if not OtherPlayer then return TriggerClientEvent('QBCore:Notify', src, 'Player is not online', 'error') end
    if not QBCore.Functions.HasPermission(src, 'admin') or IsPlayerAceAllowed(src, 'command') ~= 1 then return end
    TriggerClientEvent('chat:addMessage', playerId, {
        color = {255, 0, 0},
        multiline = true,
        args = {'Admin Response', msg}
    })
    TriggerClientEvent('chat:addMessage', src, {
        color = {255, 0, 0},
        multiline = true,
        args = {'Report Response ('..playerId..')', msg}
    })
    TriggerClientEvent('QBCore:Notify', src, 'Reply Sent')
    TriggerEvent('qb-log:server:CreateLog', 'report', 'Report Reply', 'red', '**'..GetPlayerName(src)..'** replied on: **'..OtherPlayer.PlayerData.name.. ' **(ID: '..OtherPlayer.PlayerData.source..') **Message:** ' ..msg, false)
end, 'admin')

QBCore.Commands.Add('setmodel', Lang:t("commands.change_ped_model"), {{name='model', help='Name of the model'}, {name='id', help='Id of the Player (empty for yourself)'}}, false, function(source, args)
    local model = args[1]
    local target = tonumber(args[2])
    if model ~= nil or model ~= '' then
        if target == nil then
            TriggerClientEvent('qb-admin:client:SetModel', source, tostring(model))
        else
            local Trgt = QBCore.Functions.GetPlayer(target)
            if Trgt ~= nil then
                TriggerClientEvent('qb-admin:client:SetModel', target, tostring(model))
            else
                TriggerClientEvent('QBCore:Notify', source, Lang:t("error.not_online"), 'error')
            end
        end
    else
        TriggerClientEvent('QBCore:Notify', source, Lang:t("error.failed_set_model"), 'error')
    end
end, 'admin')

QBCore.Commands.Add('setspeed', Lang:t("commands.set_player_foot_speed"), {}, false, function(source, args)
    local speed = args[1]
    if speed ~= nil then
        TriggerClientEvent('qb-admin:client:SetSpeed', source, tostring(speed))
    else
        TriggerClientEvent('QBCore:Notify', source, Lang:t("error.failed_set_speed"), 'error')
    end
end, 'admin')

QBCore.Commands.Add('reporttoggle', Lang:t("commands.report_toggle"), {}, false, function(source)
    local src = source
    QBCore.Functions.ToggleOptin(src)
    if QBCore.Functions.IsOptin(src) then
        TriggerClientEvent('QBCore:Notify', src, Lang:t("success.receive_reports"), 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.no_receive_report"), 'error')
    end
end, 'admin')

QBCore.Commands.Add('kickall', Lang:t("commands.kick_all"), {}, false, function(source, args)
    local src = source
    if src > 0 then
        local reason = table.concat(args, ' ')
        if QBCore.Functions.HasPermission(src, 'god') or IsPlayerAceAllowed(src, 'command') then
            if reason and reason ~= '' then
                for _, v in pairs(QBCore.Functions.GetPlayers()) do
                    local Player = QBCore.Functions.GetPlayer(v)
                    if Player then
                        DropPlayer(Player.PlayerData.source, reason)
                    end
                end
            else
                TriggerClientEvent('QBCore:Notify', src, Lang:t("info.no_reason_specified"), 'error')
            end
        end
    else
        for _, v in pairs(QBCore.Functions.GetPlayers()) do
            local Player = QBCore.Functions.GetPlayer(v)
            if Player then
                DropPlayer(Player.PlayerData.source, Lang:t("info.server_restart") .. QBCore.Config.Server.discord)
            end
        end
    end
end, 'god')

QBCore.Commands.Add('setammo', Lang:t("commands.ammo_amount_set"), {{name='amount', help='Amount of bullets, for example: 20'}, {name='weapon', help='Name of the weapen, for example: WEAPON_VINTAGEPISTOL'}}, false, function(source, args)
    local src = source
    local weapon = args[2]
    local amount = tonumber(args[1])

    if weapon ~= nil then
        TriggerClientEvent('qb-weapons:client:SetWeaponAmmoManual', src, weapon, amount)
    else
        TriggerClientEvent('qb-weapons:client:SetWeaponAmmoManual', src, 'current', amount)
    end
end, 'admin')

--- Uncomment this command if you want to add yourself as God. If this doesn't work honestly just use the original qb-adminmenu. I can't say more
-- RegisterCommand('giveperms', function(source)
--     UpdatePermission(source, 'AdminmenuGod')
-- end)
