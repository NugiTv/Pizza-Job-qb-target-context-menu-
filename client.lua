
---------------
-- Functions --
---------------

local QBCore = exports[Config.CoreName]:GetCoreObject()
local InJob = false
local HasJob = true
local BlipSell = nil
local BlipEnd = nil
local BlipCancel = nil
local HasPizza = false
local LastDelivery = 0
local DeliveriesCount = 0
local DeliveredPizza = false
local x = nil
local y = nil
local z = nil
local Blip = {}
local PizzaDelivered = false
local HasPizzaCar = false
local pedspawned = false
---BLIP-----
Citizen.CreateThread(function()

    PizzaBoyBlip = AddBlipForCoord(Config.Positions.Vehicle.x,
                                   Config.Positions.Vehicle.y,
                                   Config.Positions.Vehicle.z)
    SetBlipSprite(PizzaBoyBlip, 267)
    SetBlipColour(PizzaBoyBlip, 1)
    SetBlipDisplay(PizzaBoyBlip, 4)
    SetBlipScale(PizzaBoyBlip, 0.8)
    SetBlipAsShortRange(PizzaBoyBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Pizza Boy')
    EndTextCommandSetBlipName(PizzaBoyBlip)

end)

function AddJobBlip(coords)
    Blip['job'] = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipRoute(Blip['job'], true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Customer')
    EndTextCommandSetBlipName(Blip['job'])
    local Randomped = Config.PedList[math.random(1, #Config.PedList)]
    print(Randomped)
    RequestModel(Randomped)
    while not HasModelLoaded(Randomped) do Wait(50) end
    pednpc = CreatePed(0, GetHashKey(Randomped), coords.x, coords.y, coords.z,
                       coords.w, false, false)
    FreezeEntityPosition(pednpc, true)
    SetEntityInvincible(pednpc, true)
    SetBlockingOfNonTemporaryEvents(pednpc, true)
end

function SetJobFunction()

    local RandomJob = Config.DeliveryLocations[math.random(1,
                                                           #Config.DeliveryLocations)]
    if DeliveriesCount == 10 then
        QBCore.Functions.Notify("All Pizzas have been delivered", "success")
        RemoveCancelBlip()
        SetBlipRoute(BlipSell, false)
        FinishBlip()
        DeliveredPizza = true
        x = nil
        y = nil
        z = nil
    else
        local pizza = 10 - DeliveriesCount
        if pizza == 1 then
            QBCore.Functions.Notify("You have one pizza left to deliver",
                                    "success")
        end
        if LastDelivery == RandomJob then
            SetJobFunction()
        else
            print(RandomJob)
            AddJobBlip(RandomJob)
            x = RandomJob.x
            y = RandomJob.y
            z = RandomJob.z
            LastDelivery = RandomJob

            QBCore.Functions.Notify("Deliver the Pizza to the Customer",
                                    "success")
        end
    end
end

function TakePizza()
    local player = PlayerPedId()
    if not IsPedInAnyVehicle(player, false) then
        local ad = "anim@heists@box_carry@"
        local prop_name = 'prop_pizza_box_01'
        if (DoesEntityExist(player) and not IsEntityDead(player)) then
            loadAnimDict(ad)
            if HasPizza then
                FreezeEntityPosition(PlayerPedId(), true)
                local x, y, z = table.unpack(GetEntityCoords(pednpc))
                DetachEntity(prop, 1, 1)
                DeleteObject(prop)
                TaskPlayAnim(player, ad, "exit", 3.0, 1.0, -1, 49, 0, 0, 0, 0)
                prop2 = CreateObject(GetHashKey(prop_name), x, y, z + 0.2, true,
                                     true, true)
                AttachEntityToEntity(prop2, pednpc,
                                     GetPedBoneIndex(pednpc, 60309), 0.2, 0.08,
                                     0.2, -45.0, 290.0, 0.0, true, true, false,
                                     true, 1, true)
                TaskPlayAnim(pednpc, ad, "idle", 3.0, -8, -1, 63, 0, 0, 0, 0)
                exports.rprogress:Start("Delivering Pizza..", 2500)
                TaskPlayAnim(pednpc, ad, "exit", 3.0, 1.0, -1, 49, 0, 0, 0, 0)

                DetachEntity(prop2, 1, 1)
                DeleteObject(prop2)
                Wait(1000)
                while not HasAnimDictLoaded("mp_safehouselost@") do
                    RequestAnimDict("mp_safehouselost@")
                    Wait(100)
                end
                TaskPlayAnim(pednpc, 'mp_safehouselost@', 'package_dropoff',
                             5.0, 1.5, 1.0, 48, 0.0, 0, 0, 0)
                Wait(800)
                ClearPedTasks(pednpc)

                while not HasAnimDictLoaded("mp_safehouselost@") do
                    RequestAnimDict("mp_safehouselost@")
                    Wait(100)
                end
                TaskPlayAnim(PlayerPedId(), 'mp_safehouselost@',
                             'package_dropoff', 5.0, 1.5, 1.0, 48, 0.0, 0, 0, 0)
                Wait(800)
                ClearPedTasks(PlayerPedId())
                if DoesEntityExist(pednpc) then
                    DeleteEntity(pednpc)
                else
                    print("Ped does not exist.")
                end
                freeze = false

                ClearPedSecondaryTask(PlayerPedId())
                FreezeEntityPosition(PlayerPedId(), false)
                HasPizza = false
            else

                freeze = true
                exports.rprogress:Start("Getting Pizza..", 2500)
                local x, y, z = table.unpack(GetEntityCoords(player))
                prop = CreateObject(GetHashKey(prop_name), x, y, z + 0.2, true,
                                    true, true)
                AttachEntityToEntity(prop, player,
                                     GetPedBoneIndex(player, 60309), 0.2, 0.08,
                                     0.2, -45.0, 290.0, 0.0, true, true, false,
                                     true, 1, true)
                TaskPlayAnim(player, ad, "idle", 3.0, -8, -1, 63, 0, 0, 0, 0)
                HasPizza = true
            end
        end
    end
end

function DeliverPizza()
    if not PizzaDelivered then
        PizzaDelivered = true
        DeliveriesCount = DeliveriesCount + 1
        RemoveBlipObj()
        SetBlipRoute(BlipSell, false)
        HasPizza = false
        NextDelivery()
        Wait(2500)
        PizzaDelivered = false
    end
end

function EndOfWork()
    RemoveAllBlips()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local Van = GetVehiclePedIsIn(ped, false)
        if IsVehicleModel(Van, GetHashKey(Config.Car)) then
            QBCore.Functions.DeleteVehicle(Van)
            if DeliveredPizza == true then
                TriggerServerEvent("yamiepizzaboy-ReturnDeposit", 'end')
            end
            if DoesEntityExist(pednpc) then
                DeleteEntity(pednpc)
            else
                print("Ped does not exist.")
            end
            InJob = false
            BlipSell = nil
            BlipEnd = nil
            BlipCancel = nil
            HasPizza = false
            LastDelivery = nil
            DeliveriesCount = 0
            x = nil
            y = nil
            z = nil
            HasPizzaCar = false
            DeliveredPizza = false
        else
            QBCore.Functions.Notify("You must return to pizza panto!", "error")
            QBCore.Functions.Notify(
                "If you lost the panto cancel the job on foot", "error")
        end
    else

        if DoesEntityExist(pednpc) then
            DeleteEntity(pednpc)
        else
            print("Ped does not exist.")
        end
        InJob = false
        BlipSell = nil
        BlipEnd = nil
        BlipCancel = nil
        HasPizza = false
        LastDelivery = nil
        DeliveriesCount = 0
        x = nil
        y = nil
        z = nil
        HasPizzaCar = false
        DeliveredPizza = false
    end
end

function NextDelivery()
    TriggerServerEvent('yamiepizzaboy-Payment')
    Wait(1000)
    SetJobFunction()
end

function PullOutVehicle()
    if HasPizzaCar == true then
        QBCore.Functions.Notify(
            "You already have a van! Go and collect it or end your job.",
            "error")
    elseif HasPizzaCar == false then
        local modelcar = GetHashKey(Config.Car)
        RequestModel(modelcar)
        while not HasModelLoaded(modelcar) do Wait(10) end

        local veh = CreateVehicle(modelcar, Config.Positions.Spawn, true, false)
        local netid = NetworkGetNetworkIdFromEntity(veh)

        SetVehicleHasBeenOwnedByPlayer(veh, true)
        SetNetworkIdCanMigrate(netid, true)
        SetVehicleNeedsToBeHotwired(veh, false)
        SetVehRadioStation(veh, "OFF")
        SetVehicleNumberPlateText(veh,
                                  "PIZZA" .. tostring(math.random(1000, 9999)))
        exports['LegacyFuel']:SetFuel(veh, 100.0)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        TriggerEvent("vehiclekeys:client:SetOwner",
                     GetVehicleNumberPlateText(veh))
        SetVehicleEngineOn(veh, true, true)
        SetModelAsNoLongerNeeded(modelcar)
        SetJobFunction()
        CancelBlip()
        InJob = true
        HasPizzaCar = true
        Wait(1000)
        TriggerServerEvent("yamiepizzaboy-TakeDeposit")
    end
end

-------------------
-- DELIVERY AREA --
-------------------

RegisterNetEvent('caroptionmenu', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local Vehicle = GetClosestVehicle(pos, 6.0, 0, 70)
    if IsVehicleModel(Vehicle, GetHashKey(Config.Car)) then
        local myMenu = {
            {id = 1, header = 'PIZZA', txt = 'Pizza Job'}, {
                id = 2,
                header = 'Take Pizza',
                txt = 'Pizza For Delivery',
                params = {event = 'pizzajob:takepizza', args = {amount = 500}}
            }
        }
        exports['zf_context']:openMenu(myMenu)
    end

end)

 ---------------------EVENT TO TAKE PIZZA JOB!!!
RegisterNetEvent('takepizzajob', function()
    if HasJob and not InJob then
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local dist = GetDistanceBetweenCoords(pos, Config.Positions.Vehicle.x,
                                              Config.Positions.Vehicle.y,
                                              Config.Positions.Vehicle.z, true)
        if dist <= 2.5 then
            local GaragePos = {
                ["x"] = Config.Positions.Vehicle.x,
                ["y"] = Config.Positions.Vehicle.y,
                ["z"] = Config.Positions.Vehicle.z + 1
            }
            if dist <= 3.0 then PullOutVehicle() end
        end
    elseif HasJob and InJob then
        EndOfWork()
    end

end)

---------------------EVENT TO TAKE PIZZA OUT OF THE CAR & DELIVER!!!
RegisterNetEvent('pizzajob:takepizza', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local dist = GetDistanceBetweenCoords(pos, x, y, z, true)
    if dist >= 3.0 and dist <= 20.0 and HasJob and (not HasPizza) then
        local Vehicle = GetClosestVehicle(pos, 6.0, 0, 70)
        if IsVehicleModel(Vehicle, GetHashKey(Config.Car)) then
            TakePizza()
        end
    elseif dist <= 3 and HasPizza and HasJob then

        if dist <= 2 then

            TakePizza()
            DeliverPizza()

        end
    end

end)

function CancelBlip()
    Blip['cancel'] = AddBlipForCoord(-373.58, 1889.29, 9.96)
    SetBlipColour(Blip['cancel'], 59)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('cancel orders')
    EndTextCommandSetBlipName(Blip['cancel'])
end

function FinishBlip()
    Blip['end'] = AddBlipForCoord(-352.36, 1896.56, 9.91)
    SetBlipColour(Blip['end'], 2)
    SetBlipRoute(Blip['end'], true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('finnish job')
    EndTextCommandSetBlipName(Blip['end'])
end

function RemoveBlipObj() RemoveBlip(Blip['job']) end

function RemoveCancelBlip() RemoveBlip(Blip['cancel']) end

function RemoveAllBlips()
    RemoveBlip(Blip['job'])
    RemoveBlip(Blip['cancel'])
    RemoveBlip(Blip['end'])
end
function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(0)
    end
end

