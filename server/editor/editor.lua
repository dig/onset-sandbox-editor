function Editor_SetPlayerEditor(player, bEnable)
  if not IsValidPlayer(player) then return end
  
  if bEnable then 
    AddPlayerChat(player, 'Editor has been enabled.')
  else
    AddPlayerChat(player, 'Editor has been disabled.')
  end

  SetPlayerSpectate(player, bEnable)
  CallRemoteEvent(player, 'OnServerChangeEditor', bEnable)
end
AddRemoteEvent('SetPlayerEditor', Editor_SetPlayerEditor)

function Editor_SetPlayerLocation(player, x, y, z)
  SetPlayerLocation(player, x, y, z)
end
AddRemoteEvent('SetPlayerLocation', Editor_SetPlayerLocation)

function Editor_CreateObject(player, objectID, x, y, z)
  local _object = CreateObject(objectID, x, y, z)
  if _object then CallRemoteEvent(player, 'OnServerObjectCreate', _object) end
end
AddRemoteEvent('CreateObject', Editor_CreateObject)

function Editor_DeleteObject(player, object)
  DestroyObject(object)
end
AddRemoteEvent('DeleteObject', Editor_DeleteObject)

function Editor_SyncObject(player, object, x, y, z, rx, ry, rz, sx, sy, sz)
  if not IsValidObject(object) then return end

  SetObjectLocation(object, x, y, z)
  SetObjectRotation(object, rx, ry, rz)

  if sx ~= nil and sx ~= 0.0 and sy ~= nil and sy ~= 0.0 and sz ~= nil and sz ~= 0.0 then
    SetObjectScale(object, sx, sy, sz)
  end
end
AddRemoteEvent('SyncObject', Editor_SyncObject)

function Editor_CreateVehicle(player, vehicleID, x, y, z)
  local _object = CreateVehicle(vehicleID, x, y, z)
  if _object then CallRemoteEvent(player, 'OnServerObjectCreate', _object) end
end
AddRemoteEvent('CreateVehicle', Editor_CreateVehicle)

function Editor_CreatePickup(player, objectID, weaponID, x, y, z)
  local _object = CreatePickup(objectID, x, y, z)
  SetPickupPropertyValue(_object, 'weaponID', weaponID, false)
  CallRemoteEvent(player, 'OnServerObjectCreate', _object)
end
AddRemoteEvent('CreatePickup', Editor_CreatePickup)

function Editor_CreateFirework(player, x, y, z)
  CallRemoteEvent(player, 'OnServerFireworkCreate', Random(1, 13), x, y, z)
end
AddRemoteEvent('CreateFirework', Editor_CreateFirework)

function Editor_OnPlayerPickupHit(player, pickup)
  local weaponID = GetPickupPropertyValue(pickup, 'weaponID')
  weaponID = tonumber(weaponID)

  if weaponID ~= nil and weaponID ~= 0 then
    SetPlayerWeapon(player, weaponID, 450, true, 1, true)
    DestroyPickup(pickup)
  end
end
AddEvent("OnPlayerPickupHit", Editor_OnPlayerPickupHit)

function Editor_SetClothingPreset(player, clothingID)
  SetPlayerPropertyValue(player, 'clothingID', clothingID, true)
  
  for _, v in pairs(GetAllPlayers()) do
    CallRemoteEvent(v, 'OnServerClothingUpdate', player, clothingID)
  end
end
AddRemoteEvent('SetClothingPreset', Editor_SetClothingPreset)