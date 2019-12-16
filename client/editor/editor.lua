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
local EditorPendingData = {}
local EditorPendingPlacement = false

local EditorSelectedObject = 0
local EditorSelectedObjectEdited = false
local EditorSelectedObjectMode = EDIT_LOCATION
local EditorHighlightedObjects = {}

local EditorLastSyncData = {}
local EditorLastClick = 0
local EditorLastChatState = false

local TOTAL_VEHICLES = 25
local TOTAL_WEAPONS = 21
local TOTAL_CLOTHING = 30

function Editor_OnPackageStart()
  -- Load bottom left information
  EditorInfoUI = CreateWebUI(0.0, 0.0, 0.0, 0.0, 1, 60)
  SetWebAnchors(EditorInfoUI, 0.0, 0.6, 0.4, 1.0)
  LoadWebFile(EditorInfoUI, 'http://asset/' .. GetPackageName() .. '/client/editor/files/information.html')
  SetWebVisibility(EditorInfoUI, WEB_HITINVISIBLE)

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

function Editor_HandleCreateObject(x, y, z)
  -- Create object
  if (EditorPendingData['rx'] ~= nil and EditorPendingData['sx'] ~= nil) then
    CallRemoteEvent('CreateObject', EditorPendingID, x, y, z, EditorPendingData['rx'], EditorPendingData['ry'], EditorPendingData['rz'], EditorPendingData['sx'], EditorPendingData['sy'], EditorPendingData['sz'])
  else
    CallRemoteEvent('CreateObject', EditorPendingID, x, y, z)
  end

  -- Extra
  if (EditorPendingData['extra'] ~= nil) then
    for _, v in ipairs(EditorPendingData['extra']) do
      CallRemoteEvent('CreateObject', v['modelID'], x + v['relx'], y + v['rely'], z + v['relz'], v['rx'], v['ry'], v['rz'], v['sx'], v['sy'], v['sz'])
    end
  end
end

function Editor_OnKeyRelease(key)
  EditorLastClick = GetTimeSeconds()

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
      Editor_HandleCreateObject(x, y, z)
    elseif EditorPendingType == EDITOR_TYPE_VEHICLE then
      CallRemoteEvent('CreateVehicle', EditorPendingID, x, y, z)
    elseif EditorPendingType == EDITOR_TYPE_WEAPON then
      CallRemoteEvent('CreatePickup', EditorPendingID, EditorPendingData['weaponID'], x, y, z + 70)
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

      -- Delete highlighted
      if #EditorHighlightedObjects > 0 then
        for _,v in ipairs(EditorHighlightedObjects) do
          CallRemoteEvent('DeleteObject', v)
        end
      end

      EditorSelectedObjectEdited = false
      Editor_SelectObject(0)
    end
  elseif (key == 'C' and IsCtrlPressed() and EditorState == EDITOR_OPEN) then 
    if (EditorSelectedObject ~= 0) then
      local _objectID = GetObjectModel(EditorSelectedObject)
      local rx, ry, rz = GetObjectRotation(EditorSelectedObject)
      local sx, sy, sz = GetObjectScale(EditorSelectedObject)

      Editor_CreateObjectPlacement(_objectID, rx, ry, rz, sx, sy, sz)

      -- Save highlighted objects
      if #EditorHighlightedObjects > 0 then
        local x, y, z = GetObjectLocation(EditorSelectedObject)
        local _extra = {}

        for _, v in ipairs(EditorHighlightedObjects) do
          local vx, vy, vz = GetObjectLocation(v)
          local vrx, vry, vrz = GetObjectRotation(v)
          local vsx, vsy, vsz = GetObjectScale(v)

          local _object = {}
          _object['modelID'] = GetObjectModel(v)
          
          -- Relative position
          _object['relx'] = vx - x
          _object['rely'] = vy - y
          _object['relz'] = vz - z

          -- Rotation
          _object['rx'] = vrx
          _object['ry'] = vry
          _object['rz'] = vrz

          -- Scale
          _object['sx'] = vsx
          _object['sy'] = vsy
          _object['sz'] = vsz

          table.insert(_extra, _object)
        end

        EditorPendingData['extra'] = _extra
      end
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
      SetWebVisibility(EditorInfoUI, WEB_HITINVISIBLE)

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

function Editor_OnKeyPress(key)
  -- Check for double click
  local bDoubleClick = GetTimeSeconds() <= (EditorLastClick + 0.25)

  if (key == 'Left Mouse Button' and bDoubleClick and EditorState == EDITOR_OPEN) then 
    local EntityType, EntityId = GetMouseHitEntity()
    if (EntityType == HIT_OBJECT and EntityId ~= 0 and EditorSelectedObject ~= EntityId) then
      Editor_SelectObject(EntityId)
    end
  end
end
AddEvent('OnKeyPress', Editor_OnKeyPress)

function Editor_OnServerChangeEditor(bEnabled)
  ShowMouseCursor(bEnabled)
  ShowWeaponHUD(not bEnabled)
  ShowHealthHUD(not bEnabled)

  if bEnabled then
    SetWebVisibility(EditorObjectsUI, WEB_VISIBLE)
    SetInputMode(INPUT_GAMEANDUI)

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

function Editor_CreateObjectPlacement(objectID, rx, ry, rz, sx, sy, sz)
  objectID = tonumber(objectID)
  if not EditorState == EDITOR_OPEN then return end
  if (objectID <= 0 or objectID > GetObjectModelCount()) then return end

  EditorPendingType = EDITOR_TYPE_OBJECT
  EditorPendingID = objectID
  EditorPendingData = {}
  EditorPendingPlacement = true

  -- Save rotation and scale
  if (rx ~= nil and sx ~= nil) then
    EditorPendingData['rx'] = rx
    EditorPendingData['ry'] = ry
    EditorPendingData['rz'] = rz

    EditorPendingData['sx'] = sx
    EditorPendingData['sy'] = sy
    EditorPendingData['sz'] = sz
  end
end
AddEvent('CreateObjectPlacement', Editor_CreateObjectPlacement)

function Editor_CreateVehiclePlacement(vehicleID)
  vehicleID = tonumber(vehicleID)
  if not EditorState == EDITOR_OPEN then return end
  if (vehicleID <= 0 or vehicleID > TOTAL_VEHICLES) then return end

  EditorPendingType = EDITOR_TYPE_VEHICLE
  EditorPendingID = vehicleID
  EditorPendingData = {}
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
  EditorPendingData['weaponID'] = weaponID
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
  if EditorPendingPlacement then
    EditorPendingPlacement = false
  
    if EditorPendingType == EDITOR_TYPE_OBJECT then
      Delay(100, function(object)
        Editor_SelectObject(object)
      end, object)
    end
  else
    -- Add to highlight
    Delay(100, function(object)
      SetObjectOutline(object, true)
      table.insert(EditorHighlightedObjects, object)
    end, object)
  end
end
AddRemoteEvent('OnServerObjectCreate', Editor_OnServerObjectCreate)

function table.contains(table, value)
  for _, v in ipairs(table) do
    if value == v then
        return true
    end
  end

  return false
end

function Editor_SelectObject(object)
  if ((IsCtrlPressed() or IsShiftPressed()) and IsValidObject(object)) then
    if not table.contains(EditorHighlightedObjects, object) then
      SetObjectOutline(object, true)
      table.insert(EditorHighlightedObjects, object)
    end
  else
    -- Unhighlight objects
    for _, v in ipairs(EditorHighlightedObjects) do
      SetObjectOutline(v, false)
    end
    EditorHighlightedObjects = {}

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

      Editor_UpdateSyncData(object)
    end
  end
end

function Editor_UpdateSyncData(object)
  if not IsValidObject(object) then return end

  local x, y, z = GetObjectLocation(object)
  local rx, ry, rz = GetObjectRotation(object)
  local sx, sy, sz = GetObjectScale(object)

  EditorLastSyncData['x'] = x
  EditorLastSyncData['y'] = y
  EditorLastSyncData['z'] = z

  EditorLastSyncData['rx'] = rx
  EditorLastSyncData['ry'] = ry
  EditorLastSyncData['rz'] = rz

  EditorLastSyncData['sx'] = sx
  EditorLastSyncData['sy'] = sy
  EditorLastSyncData['sz'] = sz
end

function Editor_SyncObject(object)
  if not IsValidObject(object) then return end

  local lx = EditorLastSyncData['x']
  local ly = EditorLastSyncData['y']
  local lz = EditorLastSyncData['z']

  local lrx = EditorLastSyncData['rx']
  local lry = EditorLastSyncData['ry']
  local lrz = EditorLastSyncData['rz']

  local lsx = EditorLastSyncData['sx']
  local lsy = EditorLastSyncData['sy']
  local lsz = EditorLastSyncData['sz']

  local x, y, z = GetObjectLocation(object)
  local rx, ry, rz = GetObjectRotation(object)
  local sx, sy, sz = GetObjectScale(object)

  if sx == 1.0 and sy == 1.0 and sz == 1.0 then
    CallRemoteEvent('SyncObject', object, x, y, z, rx, ry, rz)
  else
    CallRemoteEvent('SyncObject', object, x, y, z, rx, ry, rz, sx, sy, sz)
  end

  -- Update highlighted objects on edit
  if (#EditorHighlightedObjects > 0 and lx ~= nil and lrx ~= nil and lsx ~= nil) then
    for _,v in pairs(EditorHighlightedObjects) do
      local vx, vy, vz = GetObjectLocation(v)
      local vrx, vry, vrz = GetObjectRotation(v)
      local vsx, vsy, vsz = GetObjectScale(v)

      CallRemoteEvent('SyncObject', v, vx + (x - lx), vy + (y - ly), vz + (z - lz), vrx + (rx - lrx), vry + (ry - lry), vrz + (rz - lrz), vsx + (sx - lsx), vsy + (sy - lsy), vsz + (sz - lsz))
    end
  end

  Editor_UpdateSyncData(object)
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

function Editor_OnPlayerSpawn()
  local player = GetPlayerId()
  local _clothingID = GetPlayerPropertyValue(player, 'clothingID')
  if (_clothingID ~= nil and _clothingID ~= 0) then
    SetPlayerClothingPreset(player, _clothingID)
  end
end
AddEvent('OnPlayerSpawn', Editor_OnPlayerSpawn)
AddRemoteEvent('SetEditorSpeed', SetObjectEditorSpeed)

function Editor_OnPlayerChatWindow(bEnabled)
  if (not bEnabled and EditorState == EDITOR_OPEN) then
    ShowMouseCursor(true)
    SetInputMode(INPUT_GAMEANDUI)
  end
end
AddEvent('OnPlayerChatWindow', Editor_OnPlayerChatWindow)

function Editor_CallChatWindowEvent()
  if IsChatFocus() ~= EditorLastChatState then
    CallEvent('OnPlayerChatWindow', IsChatFocus())
    EditorLastChatState = IsChatFocus()
  end
end
CreateTimer(Editor_CallChatWindowEvent, 100)