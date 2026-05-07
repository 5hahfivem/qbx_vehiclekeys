local sharedConfig = require 'config.shared'
local plateUtil = require 'shared.plate'

---Gets Citizen Id based on source
---@param source number ID of the player
---@return string? citizenid The player CitizenID, nil otherwise.
local function getCitizenId(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    return player.PlayerData.citizenid
end

---@param vehicle number
---@return string?
local function getPlateFromVehicle(vehicle)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return end
    return plateUtil.normalizePlate(qbx.getVehiclePlate(vehicle))
end

---@param source number
---@param plate string
---@return boolean
local function playerHasKeyItem(source, plate)
    return exports.ox_inventory:GetItemCount(source, sharedConfig.keyItem, { plate = plate }, false) > 0
end

--- Removing the vehicle keys from the user
---@param source number ID of the player
---@param vehicle number
---@param skipNotification? boolean
---@return boolean?
function RemoveKeys(source, vehicle, skipNotification)
    if not getCitizenId(source) then return end

    local plate = getPlateFromVehicle(vehicle)
    if not plate then return end

    local removed = exports.ox_inventory:RemoveItem(source, sharedConfig.keyItem, 1, { plate = plate })
    if not removed then return end

    TriggerClientEvent('qbx_vehiclekeys:client:OnLostKeys', source)
    if not skipNotification then
        exports.qbx_core:Notify(source, locale('notify.keys_removed'))
    end

    return true
end

exports('RemoveKeys', RemoveKeys)

--- Removing the vehicle keys from the user by plate (e.g. when the vehicle is not spawned).
---@param source number ID of the player
---@param plate string
---@param skipNotification? boolean
---@return boolean?
function RemoveKeysByPlate(source, plate, skipNotification)
    if not getCitizenId(source) then return end

    local normalized = plateUtil.normalizePlate(plate)
    if not normalized then return end

    local removed = exports.ox_inventory:RemoveItem(source, sharedConfig.keyItem, 1, { plate = normalized })
    if not removed then return end

    TriggerClientEvent('qbx_vehiclekeys:client:OnLostKeys', source)
    if not skipNotification then
        exports.qbx_core:Notify(source, locale('notify.keys_removed'))
    end

    return true
end

exports('RemoveKeysByPlate', RemoveKeysByPlate)

---@param source number
---@param vehicle number
---@param skipNotification? boolean
---@return boolean?
function GiveKeys(source, vehicle, skipNotification)
    local citizenid = getCitizenId(source)
    if not citizenid then return end

    local plate = getPlateFromVehicle(vehicle)
    if not plate then return end

    if playerHasKeyItem(source, plate) then return end

    local added = exports.ox_inventory:AddItem(source, sharedConfig.keyItem, 1, { plate = plate })
    if not added then return end

    if not skipNotification then
        exports.qbx_core:Notify(source, locale('notify.keys_taken'))
    end
    return true
end

exports('GiveKeys', GiveKeys)

--- Gives keys to the player by plate (e.g. when the vehicle is not spawned).
---@param source number
---@param plate string
---@param skipNotification? boolean
---@return boolean?
function GiveKeysByPlate(source, plate, skipNotification)
    local citizenid = getCitizenId(source)
    if not citizenid then return end

    local normalized = plateUtil.normalizePlate(plate)
    if not normalized then return end

    if playerHasKeyItem(source, normalized) then return end

    local added = exports.ox_inventory:AddItem(source, sharedConfig.keyItem, 1, { plate = normalized })
    if not added then return end

    if not skipNotification then
        exports.qbx_core:Notify(source, locale('notify.keys_taken'))
    end
    return true
end

exports('GiveKeysByPlate', GiveKeysByPlate)

---@param src number
---@param vehicle number
---@return boolean
function HasKeys(src, vehicle)
    local plate = getPlateFromVehicle(vehicle)
    if not plate then return false end

    if playerHasKeyItem(src, plate) then
        return true
    end

    local owner = Entity(vehicle).state.owner
    if owner and getCitizenId(src) == owner then
        GiveKeys(src, vehicle)
        return true
    end

    return false
end

exports('HasKeys', HasKeys)

---@param src number
---@param plate string
---@return boolean
function HasKeysByPlate(src, plate)
    local normalized = plateUtil.normalizePlate(plate)
    if not normalized then return false end

    return playerHasKeyItem(src, normalized)
end

exports('HasKeysByPlate', HasKeysByPlate)

lib.callback.register('qbx_vehiclekeys:server:giveKeys', function(source, netId)
    GiveKeys(source, NetworkGetEntityFromNetworkId(netId))
end)

AddStateBagChangeHandler('vehicleid', '', function(bagName, _, vehicleId)
    local vehicle = GetEntityFromStateBagName(bagName)
    if not vehicle or vehicle == 0 then return end
    local owner = exports.qbx_vehicles:GetPlayerVehicle(vehicleId)?.citizenid
    if not owner then return end
    Entity(vehicle).state:set('owner', owner, true)
end)
