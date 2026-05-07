if GetConvar('qbx_vehiclekeys:enableBridge', 'true') ~= 'true' then return end

local sharedConfig = require 'config.shared'
local plateUtil = require 'shared.plate'

RegisterNetEvent('qb-vehiclekeys:client:AddKeys', function(plate)
    TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
end)

RegisterNetEvent('qb-vehiclekeys:client:RemoveKeys', function(plate)
    TriggerServerEvent('qb-vehiclekeys:server:removeKeys', plate)
end)

RegisterNetEvent('vehiclekeys:client:SetOwner', function(plate)
    TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
end)

CreateQbExport('HasKeys', function(plate)
    if not plate then return HasKeys(cache.vehicle) end
    local normalized = plateUtil.normalizePlate(plate)
    if not normalized then return false end
    return exports.ox_inventory:GetItemCount(sharedConfig.keyItem, { plate = normalized }, false) > 0
end)
