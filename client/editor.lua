local EDITOR_CLOSED = 0
local EDITOR_OPEN = 1

local UI_SHOWN = 0
local UI_HIDDEN = 1

local EDITOR_TYPE_OBJECT = 0
local EDITOR_TYPE_VEHICLE = 1
local EDITOR_TYPE_WEAPON = 2

local EditorState = EDITOR_CLOSED
local UIState = UI_SHOWN

local EditorInfoUI = 0
local EditorObjectsUI = 0

local EditorLastLocation = {}

local EditorPendingType = EDITOR_TYPE_OBJECT
local EditorPendingID = 0
local EditorPendingData = 0
local EditorPendingPlacement = false

local EditorSelectedObject = 0
local EditorSelectedObjectEdited = false
local EditorSelectedObjectMode = EDIT_LOCATION

local TOTAL_VEHICLES = 25
local TOTAL_WEAPONS = 20
local TOTAL_CLOTHING = 30

function Editor_OnPackageStart()
  -- Load bottom left information
  EditorInfoUI = CreateWebUI(0.0, 0.0, 0.0, 0.0, 1, 60)
  SetWebAnchors(EditorInfoUI, 0.0, 0.5, 0.5, 1.0)
  LoadWebFile(EditorInfoUI, 'http://asset/' .. GetPackageName() .. '/client/editor/files/information.html')
  SetWebVisibility(EditorInfoUI, WEB_VISIBLE)

  -- Load objects list
  EditorObjectsUI = CreateWebUI(0.0, 0.0, 0.0, 0.0, 1, 60)
  SetWebAnchors(EditorObjectsUI, 0.8, 0.0, 1.0, 1.0)
  LoadWebFile(EditorObjectsUI, 'http://asset/' .. GetPackageName() .. '/client/editor/files/objects.html')
  SetWebVisibility(EditorObjectsUI, WEB_HIDDEN)
end
AddEvent("OnPackageStart", Editor_OnPackageStart)

function Editor_OnWebLoadComplete(webID)
  if EditorInfoUI == webID then
    -- Update information UI based on location
    local x, y, z = GetPlayerLocation()
    ExecuteWebJS(EditorInfoUI, 'OnLocationUpdate (' .. math.floor(x) .. ', ' .. math.floor(y) .. ', ' .. math.floor(z) .. ')')
  end
end
AddEvent("OnWebLoadComplete", Editor_OnWebLoadComplete)

function Editor_OnKeyRelease(key)
  if key == 'P' then
    CallRemoteEvent('SetPlayerEditor', EditorState == EDITOR_CLOSED)
    
    if EditorState == EDITOR_CLOSED then
      EditorState = EDITOR_OPEN
    else
      EditorState = EDITOR_CLOSED
    end
  elseif (key == 'F' and EditorState == EDITOR_OPEN) then 
    local x, y, z, distance = GetMouseHitLocation()
    CallRemoteEvent('SetPlayerLocation', x, y, z + 100)
  elseif (key == 'Left Mouse Button' and EditorState == EDITOR_OPEN and EditorPendingPlacement) then 
    local x, y, z, distance = GetMouseHitLocation()

    if EditorPendingType == EDITOR_TYPE_OBJECT then
      CallRemoteEvent('CreateObject', EditorPendingID, x, y, z)
    elseif EditorPendingType == EDITOR_TYPE_VEHICLE then
      CallRemoteEvent('CreateVehicle', EditorPendingID, x, y, z)
    elseif EditorPendingType == EDITOR_TYPE_WEAPON then
      CallRemoteEvent('CreatePickup', EditorPendingID, EditorPendingData, x, y, z + 70)
    end
  elseif (key == 'Left Mouse Button' and EditorState == EDITOR_OPEN) then 
    local EntityType, EntityId = GetMouseHitEntity()
    if (EntityType == HIT_OBJECT and EntityId ~= 0 and EditorSelectedObject ~= EntityId) then
      Editor_SelectObject(EntityId)
    end
  elseif (key == 'Left Alt' and EditorState == EDITOR_OPEN and EditorSelectedObject ~= 0) then 
    if EditorSelectedObjectMode == EDIT_LOCATION then
      EditorSelectedObjectMode = EDIT_ROTATION
    elseif EditorSelectedObjectMode == EDIT_ROTATION then
      EditorSelectedObjectMode = EDIT_SCALE
    elseif EditorSelectedObjectMode == EDIT_SCALE then
      EditorSelectedObjectMode = EDIT_LOCATION
    end

    SetObjectEditable(EditorSelectedObject, EditorSelectedObjectMode)
  elseif (key == 'Delete' and EditorState == EDITOR_OPEN) then 
    if (EditorSelectedObject ~= 0) then
      CallRemoteEvent('DeleteObject', EditorSelectedObject)

      EditorSelectedObjectEdited = false
      Editor_SelectObject(0)
    end
  elseif (key == 'C' and IsCtrlPressed() and EditorState == EDITOR_OPEN) then 
    if (EditorSelectedObject ~= 0) then
      Editor_CreateObjectPlacement(GetObjectModel(EditorSelectedObject))
    end
  elseif (key == 'G' and EditorState == EDITOR_OPEN) then 
    local x, y, z, distance = GetMouseHitLocation()
    CallRemoteEvent('CreateFirework', x, y, z)
  elseif key == 'Backspace' then 
    if UIState == UI_SHOWN then
      UIState = UI_HIDDEN

      ShowChat(false)
      ShowHealthHUD(false)
      ShowWeaponHUD(false)

      SetWebVisibility(EditorInfoUI, WEB_HIDDEN)
      SetWebVisibility(EditorObjectsUI, WEB_HIDDEN)
    else
      UIState = UI_SHOWN

      ShowChat(true)
      SetWebVisibility(EditorInfoUI, WEB_VISIBLE)
      
      if EditorState == EDITOR_CLOSED then
        ShowHealthHUD(true)
        ShowWeaponHUD(true)
      end

      if EditorState == EDITOR_OPEN then
        SetWebVisibility(EditorObjectsUI, WEB_VISIBLE)
      end
    end
  end
end
AddEvent('OnKeyRelease', Editor_OnKeyRelease)

function Editor_OnServerChangeEditor(bEnabled)
  ShowMouseCursor(bEnabled)
  ShowWeaponHUD(not bEnabled)
  ShowHealthHUD(not bEnabled)

  if bEnabled then
    SetWebVisibility(EditorObjectsUI, WEB_VISIBLE)

    Delay(500, function()
      ExecuteWebJS(EditorObjectsUI, 'Load (' .. GetObjectModelCount() .. ', ' .. TOTAL_VEHICLES .. ', ' .. TOTAL_WEAPONS .. ', ' .. TOTAL_CLOTHING .. ')')
    end)
  else
    SetWebVisibility(EditorObjectsUI, WEB_HIDDEN)
    SetInputMode(INPUT_GAME)

    EditorPendingPlacement = false
    Editor_SelectObject(0)
  end
end
AddRemoteEvent('OnServerChangeEditor', Editor_OnServerChangeEditor)

function Editor_OnLocationChange()
  local x, y, z = GetPlayerLocation()
  
  -- Only update if location has changed
  if (not (EditorLastLocation[0] == x) or not (EditorLastLocation[1] == y) or not (EditorLastLocation[2] == z)) then
    EditorLastLocation[0] = x
    EditorLastLocation[1] = y
    EditorLastLocation[2] = z

    ExecuteWebJS(EditorInfoUI, 'OnLocationUpdate (' .. math.floor(x) .. ', ' .. math.floor(y) .. ', ' .. math.floor(z) .. ')')
  end
end
CreateTimer(Editor_OnLocationChange, 100)

function Editor_CreateObjectPlacement(objectID)
  objectID = tonumber(objectID)
  if not EditorState == EDITOR_OPEN then return end
  if (objectID <= 0 or objectID > GetObjectModelCount()) then return end

  EditorPendingType = EDITOR_TYPE_OBJECT
  EditorPendingID = objectID
  EditorPendingPlacement = true
end
AddEvent('CreateObjectPlacement', Editor_CreateObjectPlacement)

function Editor_CreateVehiclePlacement(vehicleID)
  vehicleID = tonumber(vehicleID)
  if not EditorState == EDITOR_OPEN then return end
  if (vehicleID <= 0 or vehicleID > TOTAL_VEHICLES) then return end

  EditorPendingType = EDITOR_TYPE_VEHICLE
  EditorPendingID = vehicleID
  EditorPendingPlacement = true
end
AddEvent('CreateVehiclePlacement', Editor_CreateVehiclePlacement)

function Editor_CreateWeaponPlacement(objectID, weaponID)
  objectID = tonumber(objectID)
  weaponID = tonumber(weaponID)

  if not EditorState == EDITOR_OPEN then return end
  if (objectID <= 0 or objectID > GetObjectModelCount()) then return end
  if (weaponID <= 0 or weaponID > TOTAL_WEAPONS) then return end

  EditorPendingType = EDITOR_TYPE_WEAPON
  EditorPendingID = objectID
  EditorPendingData = weaponID
  EditorPendingPlacement = true
end
AddEvent('CreateWeaponPlacement', Editor_CreateWeaponPlacement)

function Editor_OnRenderHUD()
  -- Draw yellow circle for object placement
  if (EditorPendingPlacement and EditorState == EDITOR_OPEN) then
    local x, y, z = GetMouseHitLocation()

    SetDrawColor(RGB(255, 255, 0))
    DrawCircle3D(x, y, z + 10.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 10.0)
  end
end
AddEvent('OnRenderHUD', Editor_OnRenderHUD)

function Editor_OnServerObjectCreate(object)
  EditorPendingPlacement = false
  
  if EditorPendingType == EDITOR_TYPE_OBJECT then
    Delay(100, function(object)
      Editor_SelectObject(object)
    end, object)
  end
end
AddRemoteEvent('OnServerObjectCreate', Editor_OnServerObjectCreate)

function Editor_SelectObject(object)
  -- Update old object
  if EditorSelectedObject ~= 0 then
    SetObjectEditable(EditorSelectedObject, EDIT_NONE)
    SetObjectOutline(EditorSelectedObject, false)

    if EditorSelectedObjectEdited then Editor_SyncObject(EditorSelectedObject) end
    EditorSelectedObject = 0
  end

  -- Select new object
  if IsValidObject(object) then
    SetObjectEditable(object, EditorSelectedObjectMode)
    SetObjectOutline(object, true)

    SetInputMode(INPUT_GAMEANDUI)

    EditorSelectedObjectEdited = false
    EditorSelectedObject = object
  end
end

function Editor_SyncObject(object)
  if not IsValidObject(object) then return end

  local x, y, z = GetObjectLocation(object)
  local rx, ry, rz = GetObjectRotation(object)
  local sx, sy, sz = GetObjectScale(object)

  if sx == 1.0 and sy == 1.0 and sz == 1.0 then
    sx = nil
    sy = nil
    sz = nil
  end

  CallRemoteEvent('SyncObject', object, x, y, z, rx, ry, rz, sx, sy, sz)
end

function Editor_OnPlayerBeginEditObject(object)
  if object == EditorSelectedObject then
    AddPlayerChat('Start sync process.')
		EditorSelectedObjectEdited = true
	end
end
AddEvent('OnPlayerBeginEditObject', Editor_OnPlayerBeginEditObject)

function Editor_OnPlayerEndEditObject(object)
  if (object == EditorSelectedObject and EditorSelectedObjectEdited) then
    AddPlayerChat('Synced object.')
    Editor_SyncObject(object)
    EditorSelectedObjectEdited = false
	end
end
AddEvent('OnPlayerEndEditObject', Editor_OnPlayerEndEditObject)

function Editor_OnServerFireworkCreate(modelID, x, y, z)
  CreateFireworks(modelID, x, y, z, 90.0, 0.0, 0.0)
end
AddRemoteEvent('OnServerFireworkCreate', Editor_OnServerFireworkCreate)

function Editor_OnServerClothingUpdate(target, clothingID)
  SetPlayerClothingPreset(target, clothingID)
end
AddRemoteEvent('OnServerClothingUpdate', Editor_OnServerClothingUpdate)

function Editor_OnPlayerStreamIn(player)
  local _clothingID = GetPlayerPropertyValue(player, 'clothingID')
  if (_clothingID ~= nil and _clothingID ~= 0) then
    SetPlayerClothingPreset(player, _clothingID)
  end
end
AddEvent('OnPlayerStreamIn', Editor_OnPlayerStreamIn)

function Editor_RequestClothingPreset(clothingID)
  CallRemoteEvent('SetClothingPreset', clothingID)
end
AddEvent('RequestClothingPreset', Editor_RequestClothingPreset)