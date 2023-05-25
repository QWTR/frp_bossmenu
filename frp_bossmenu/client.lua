local OpenBossMenu = function(job, isOrg)
    ESX.TriggerServerCallback("frp_bossmenu:getSociety", function(can, money, employees, ranks)
        if can then
            SendNUIMessage({
                action = "openMenu",
                money = money,
                employees = employees,
                ranks = ranks
            })
            SetNuiFocus(true, true)
        end
    end, job, isOrg)
end

exports("OpenBossMenu", OpenBossMenu)

RegisterNUICallback("NUIFocusOff", function()
    SetNuiFocus(false, false)
end)

RegisterNUICallback("wplac", function(data, cb)
    TriggerServerEvent('frp_bossmenu:depositMoney', nil, tonumber(data.value))
end)

RegisterNUICallback("wyplac", function(data, cb)
    TriggerServerEvent('frp_bossmenu:withdrawMoney', nil, tonumber(data.value))
end)

RegisterNUICallback("zatrudnij", function(data, cb)
    exports["frp_tokenizer"]:TriggerEvent('frp_bossmenu:hire', nil, tonumber(data.value))
end)

RegisterNUICallback("zwolnij", function(data, cb)
    exports["frp_tokenizer"]:TriggerEvent('frp_bossmenu:dhire', nil, tonumber(data.value))
end)

RegisterNUICallback("zmienstopien", function(data, cb)
    ESX.TriggerServerCallback("frp_bossmenu:updateGrade", function(esxcb)
        cb(esxcb)
    end, data.job, data.ssn, data.grade)
end)