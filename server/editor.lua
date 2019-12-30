EditorDoorData = {}

local DoorConfig = {
  [6]=180,
  [17]=180,
  [18]=180,
  [19]=180,
  [26]=180,
  [27]=180,
  [28]=180,
  [29]=180,
  [30]=180,
  [31]=180,
  [32]=180,
  [33]=180,
  [34]=180,
  [35]=0,
  [36]=270,
  [37]=270,
  [38]=270,
  [39]=270
}

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

function Editor_CreateObject(player, objectID, x, y, z, rx, ry, rz, sx, sy, sz)
  local _object = CreateObject(objectID, x, y, z)
  if _object then
    if (rx ~= nil and sx ~= nil) then
      SetObjectRotation(_object, rx, ry, rz)
      SetObjectScale(_object, sx, sy, sz)
    end

    table.insert(EditorObjects, _object)
    if player ~= nil then
      CallRemoteEvent(player, 'OnServerObjectCreate', _object)
    end
  end
end
AddRemoteEvent('CreateObject', Editor_CreateObject)

function Editor_DeleteObject(player, object)
  local _index = 0
  for i,v in pairs(EditorObjects) do
    if v == object then
      _index = i
    end
  end

  if _index > 0 then
    table.remove(EditorObjects, _index)
  end

  DestroyObject(object)
end
AddRemoteEvent('DeleteObject', Editor_DeleteObject)

function Editor_SyncObject(player, object, x, y, z, rx, ry, rz, sx, sy, sz)
  if not IsValidObject(object) then return end

  SetObjectLocation(object, x, y, z)
  SetObjectRotation(object, rx, ry, rz)

  if (sx ~= nil and sx ~= 0.0 and sy ~= nil and sy ~= 0.0 and sz ~= nil and sz ~= 0.0) then
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

function Editor_CreateDoorObject(player, objectID, doorID, x, y, z, yaw)
  local _object = CreateObject(objectID, x, y, z)

  if yaw ~= nil then
    local rx, ry, rz = GetObjectRotation(_object)
    SetObjectRotation(_object, rx, yaw, rz)
  end

  SetObjectPropertyValue(_object, 'doorID', doorID, true)
  CallRemoteEvent(player, 'OnServerObjectCreate', _object)
end
AddRemoteEvent('CreateDoorObject', Editor_CreateDoorObject)

function Editor_CreateDoor(doorID, x, y, z, yaw)
  local _AddYaw = DoorConfig[tonumber(doorID)]
  if _AddYaw == nil then
    _AddYaw = 90
  end

  local _door = CreateDoor(doorID, x, y, z, yaw + _AddYaw)

  local _data = {}
  _data['modelID'] = 767
  _data['yaw'] = yaw
  EditorDoorData[_door] = _data

  table.insert(EditorDoors, _door)
end

function Editor_SetObjectToDoor(player, object, doorID, x, y, z, yaw)
  if not IsValidObject(object) then return end

  local _AddYaw = DoorConfig[tonumber(doorID)]
  if _AddYaw == nil then
    _AddYaw = 90
  end

  local _door = CreateDoor(doorID, x, y, z, yaw + _AddYaw, true)

  local _data = {}
  _data['modelID'] = GetObjectModel(object)
  _data['yaw'] = yaw
  EditorDoorData[_door] = _data

  table.insert(EditorDoors, _door)
  DestroyObject(object)
end
AddRemoteEvent('SetObjectToDoor', Editor_SetObjectToDoor)

function Editor_SetDoorToObject(player, door)
  if not IsValidDoor(door) then return end

  local _data = EditorDoorData[door]
  local _objectID = _data['modelID']
  local yaw = _data['yaw']

  local _doorID = GetDoorModel(door)
  local x, y, z = GetDoorLocation(door)

  -- Remove door from table
  local _index = 0
  for i,v in pairs(EditorDoors) do
    if v == door then
      _index = i
    end
  end

  if _index > 0 then
    table.remove(EditorDoors, _index)
  end

  Editor_CreateDoorObject(player, _objectID, _doorID, x, y, z, yaw)
  DestroyDoor(door)
end
AddRemoteEvent('SetDoorToObject', Editor_SetDoorToObject)

function Editor_CreateFirework(player, x, y, z)
  local _fireworkID = Random(1, 13)
  for _,v in pairs(GetAllPlayers()) do
    CallRemoteEvent(v, 'OnServerFireworkCreate', _fireworkID, x, y, z)
  end
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