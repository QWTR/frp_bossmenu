local RegisteredSocieties = {}
local Jobs = setmetatable({}, {__index = function(_, key)
    return ESX.GetJobs()[key]
end})

local GetSociety = function(name)
    local found = nil
    for i = 1, #(RegisteredSocieties) do
        if RegisteredSocieties[i].name == name then
            found = RegisteredSocieties[i]
            break
        end
    end

    return found
end

exports("GetSociety", GetSociety)

local RegisterSociety = function(name, label, account, datastore, inventory, data)
    if GetSociety(name) then
        print(('[^3WARNING^7] society already registered, name: ^5%s^7'):format(name))
        return
    end

    local society = {
        name = name,
        label = label,
        account = account,
        datastore = datastore,
        inventory = inventory,
        data = data
    }

    table.insert(RegisteredSocieties, society)
end

exports("RegisterSociety", RegisterSociety)

ESX.RegisterServerCallback("frp_bossmenu:getSociety", function(source, cb, name, isOrg)
    local xPlayer = ESX.GetPlayerFromId(source)

    local Society = GetSociety(name)

    if not Society then
        cb(false)
        return
    end

    if (isOrg and xPlayer.job2.name or xPlayer.job.name) ~= name then
        cb(false)
        return
    end
    
    if xPlayer.job.grade_name ~='wlasciciel' then
        cb(false)
        return
    end
    
    local money = 0
    TriggerEvent('esx_addonaccount:getSharedAccount', Society.account, function(account)
        money = ESX.Math.Round(account.money)
    end)

    local employees = {}

    -- JOB
    local xPlayers = (isOrg and ESX.GetExtendedPlayers('job2', name) or ESX.GetExtendedPlayers('job', name))
    for i=1, #(xPlayers) do 
        local xPlayer = xPlayers[i]
        local name = xPlayer.get("firstname") .. " " .. xPlayer.get("lastname")

        table.insert(employees, {
            firstname = xPlayer.get("firstname"),
            lastname = xPlayer.get("lastname"),
            ssn = xPlayer.ssn,
            job = {
                name = (isOrg and xPlayer.job2.name or xPlayer.job.name),
                label = (isOrg and xPlayer.job2.label or xPlayer.job.label),
                grade = (isOrg and xPlayer.job2.grade or xPlayer.job.grade),
                grade_name = (isOrg and xPlayer.job2.grade_name or xPlayer.job.grade_name),
                grade_label = (isOrg and xPlayer.job2.grade_label or xPlayer.job.grade_label),
                badge = (isOrg and '' or xPlayer.get("badge")),
            },
        })
    end

    -- DB JOB
    MySQL.query("SELECT ssn, job_grade, firstname, lastname, job_badge FROM `users` WHERE `job`= ? ORDER BY job_grade DESC", {name}, function(result)
        for i = 1, #(result) do
            local xPlayer = result[i]
            local alreadyInTable = false
            local ssn = xPlayer.ssn
            for k, v in pairs(employees) do
                if v.ssn == ssn then
                    alreadyInTable = true
                end
            end

            if not alreadyInTable then
                if (isOrg and xPlayer.job2 or xPlayer.job) == name then
                    table.insert(employees, {
                        firstname = xPlayer.firstname,
                        lastname = xPlayer.lastname,
                        ssn = xPlayer.ssn,
                        job = {
                            name = name,
                            label = Jobs[name].label,
                            grade = (isOrg and xPlayer.job2_grade or xPlayer.job_grade),
                            grade_name = (isOrg and Jobs[name].grades[tostring(xPlayer.job2_grade)].name or Jobs[name].grades[tostring(xPlayer.job_grade)].name),
                            grade_label = (isOrg and Jobs[name].grades[tostring(xPlayer.job2_grade)].label or Jobs[name].grades[tostring(xPlayer.job_grade)].label),
                            badge = (isOrg and '' or xPlayer.job_badge)
                        }
                    })
                end
            end
        end

        local ranks = Jobs[name].grades

        cb(true, money, employees, ranks)
    end)
end)

RegisterNetEvent("frp_bossmenu:withdrawMoney", function(name, count, isOrg)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.job.grade_name == 'wlasciciel' then
        if not name then
            name = (isOrg and xPlayer.job2.name or xPlayer.job.name)
        end
        local Society = GetSociety(name)
        if not Society then
            return
        end
        if (isOrg and xPlayer.job2.name or xPlayer.job.name) ~= name then
            return
        end
        count = ESX.Math.Round(count)
        TriggerEvent('esx_addonaccount:getSharedAccount', Society.account, function(account)
            if count > 0 and account.money >= count then
                account.removeMoney(count)
                xPlayer.addMoney(count)
                xPlayer.showNotification("Wypłacono "..count.."$")
            else
                xPlayer.showNotification("Nieprawidłowa ilość!")
            end
        end)
    else
        DropPlayer(source, 'wypierdalaj')
    end
end)

RegisterNetEvent("frp_bossmenu:depositMoney", function(name, count, isOrg)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.job.grade_name == 'wlasciciel' then
        if not name then
            name = (isOrg and xPlayer.job2.name or xPlayer.job.name)
        end
        local Society = GetSociety(name)
        if not Society then
            return
        end
        if (isOrg and xPlayer.job2.name or xPlayer.job.name) ~= name then
            return
        end
        count = ESX.Math.Round(count)
        if count > 0 and xPlayer.getMoney() >= count then
            TriggerEvent('esx_addonaccount:getSharedAccount', Society.account, function(account)
                xPlayer.removeMoney(count)
                account.addMoney(count)
                xPlayer.showNotification("Wpłacono "..count.."$")
            end)
        else
            xPlayer.showNotification("Nieprawidłowa ilość!")
        end
    else
        DropPlayer(source, 'wypierdalaj')
    end
end)

exports["frp_tokenizer"]:RegisterEvent('frp_bossmenu:hire',function(source,name,id,isOrg)
    local xPlayer = ESX.GetPlayerFromId(source)
   
    if not name then
        name = (isOrg and xPlayer.job2.name or xPlayer.job.name)
    end
    local Society = GetSociety(name)
    if not Society then
        return
    end
    if (isOrg and xPlayer.job2.name or xPlayer.job.name) ~= name then
        return
    end

    if xPlayer.job.grade_name == 'wlasciciel' then 
        local xTarget = ESX.GetPlayerFromId(id)
        xTarget.setJob(xPlayer.job.name, 0)
        xPlayer.showNotification('Zatrudniłeś nowego pracownika')
        xTarget.showNotification('Zostałeś zatrudniony w '..xPlayer.job.label)
    else
        DropPlayer(source, 'wypierdalaj')
    end
end)

exports["frp_tokenizer"]:RegisterEvent('frp_bossmenu:dhire',function(source,name,id,isOrg)
    local xPlayer = ESX.GetPlayerFromId(source)
   
    if not name then
        name = (isOrg and xPlayer.job2.name or xPlayer.job.name)
    end
    local Society = GetSociety(name)
    if not Society then
        return
    end
    if (isOrg and xPlayer.job2.name or xPlayer.job.name) ~= name then
        return
    end

    if xPlayer.job.grade_name == 'wlasciciel' then 
        local xTarget = ESX.GetPlayerFromId(id)
        xTarget.setJob('unemployed', 0)
        xPlayer.showNotification('Zwolniłeś pracownika')
        xTarget.showNotification('Zostałeś zwolniony z '..xPlayer.job.label)
    else
        DropPlayer(source, 'wypierdalaj')
    end
end)

RegisterNetEvent("frp_bossmenu:changeExtras", function(job, targetssn, type, has)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.job.name ~= job then
        return
    end

    local xTarget = nil
    local xTargets = ESX.GetExtendedPlayers("ssn", targetssn)
    for i = 1, #(xTargets) do
        xTarget = xTargets[i]
        break
    end

    if not xTarget then
        xTarget = MySQL.scalar.await('SELECT job_extras FROM users WHERE ssn = ?', {targetssn})
        xTarget = json.decode(xTarget)
        xTarget[type] = has
        MySQL.prepare('UPDATE `users` SET `job_extras` = ? WHERE `ssn` = ?', {
            json.encode(xTarget),
            targetssn,
        })
        return
    end

    xTarget.updateJobExtras(type, has)
end)

-- ESX.RegisterServerCallback("frp_bossmenu:updateGrade", function(source, cb, job, targetssn, grade)
--     local xPlayer = ESX.GetPlayerFromId(source)
--     if xPlayer.job.name ~= job then
--         return
--     end
--     local xTarget = nil
--     local xTargets = ESX.GetExtendedPlayers("ssn", targetssn)
--     for i = 1, #(xTargets) do
--         xTarget = xTargets[i]
--         break
--     end
--     if not xTarget then
--         xTarget = MySQL.scalar.await('SELECT job, job_grade FROM users WHERE ssn = ?', {targetssn})
--         if xTarget.job ~= xPlayer.job.name or xTarget.job_grade >= xPlayer.job.grade then
--             return
--         end
--         MySQL.prepare('UPDATE `users` SET `job_grade` = ? WHERE `ssn` = ?', {
--             grade,
--             targetssn,
--         })
--         return
--     end
--     if xTarget.job.name ~= xPlayer.job.name or xTarget.job.grade >= xPlayer.job.grade then
--         return
--     end

--     xTarget.setJob(xTarget.job.name, grade)
-- end)

ESX.RegisterServerCallback("frp_bossmenu:updateGrade", function(source, cb, job, targetssn, grade)
    local xPlayer = ESX.GetPlayerFromId(source)
    local success = false
    if xPlayer.job.name ~= job then
        return
    end
    local xTarget = ESX.GetPlayerFromSSN(targetssn)

    if not xTarget then
        xTarget = MySQL.scalar.await('SELECT job, job_grade FROM users WHERE ssn = ?', {targetssn})
        if xTarget.job ~= xPlayer.job.name or xTarget.job_grade >= xPlayer.job.grade then
            success = false
            return
        end
        MySQL.prepare('UPDATE `users` SET `job_grade` = ? WHERE `ssn` = ?', {
            grade,
            targetssn,
        })
        success = true
    else
        if xTarget.job.name ~= xPlayer.job.name or xTarget.job.grade >= xPlayer.job.grade then
            success = false
            return
        end
        xTarget.setJob(xTarget.job.name, grade)
        success = true
    end
    cb(success)
end)

RegisterNetEvent("esx:playerLoaded", function(source, xPlayer)
    local badge = MySQL.prepare.await('SELECT job_badge FROM users WHERE ssn = ?', {xPlayer.ssn})
    xPlayer.set("badge", badge)
end)

AddEventHandler('playerDropped', function(reason)
	local playerId = source
	local xPlayer = ESX.GetPlayerFromId(playerId)

    if not xPlayer then
		return print(('[^3WARNING^7] xPlayer for %s'):format(playerId))
	end

    MySQL.prepare('UPDATE `users` SET `job_badge` = ? WHERE `ssn` = ?', {
        xPlayer.get("badge"),
        xPlayer.ssn
    })
end)

RegisterCommand('nadajodznake', function(source, args)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if xPlayer.job.name == 'police' and xPlayer.job.grade >= 5 then
        gracz = tonumber(args[1])
        odznaka = tonumber(args[2])
        if gracz then
            if odznaka then
                local xTarget = ESX.GetPlayerFromSSN(gracz)
                if xTarget then
                    xTarget.set('badge', odznaka)
                    xPlayer.showNotification('Nadano numer odznaki: '..odznaka..' dla SSN: '..gracz)
                else
                    xPlayer.showNotification('Nie ma takiego gracza')
                end
            else
                xPlayer.showNotification('Podaj numer odznaki')
            end
        else
            xPlayer.showNotification('Podaj SSN')
        end
    end
end)