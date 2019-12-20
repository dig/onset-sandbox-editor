EditorObjects = {}
EditorDoors = {}
EditorSchematics = {}
EditorWorldLoaded = false

function Editor_SaveWorld()
  local _table = {}

  -- Save objects
  for _,v in pairs(EditorObjects) do
    local _object = {}

    local x, y, z = GetObjectLocation(v)
    local rx, ry, rz = GetObjectRotation(v)
    local sx, sy, sz = GetObjectScale(v)

    _object['modelID'] = GetObjectModel(v)
    _object['x'] = x
    _object['y'] = y
    _object['z'] = z

    _object['rx'] = rx
    _object['ry'] = ry
    _object['rz'] = rz

    _object['sx'] = sx
    _object['sy'] = sy
    _object['sz'] = sz
  
    table.insert(_table, _object)
  end

  -- Save doors
  for _,v in pairs(EditorDoors) do
    local _door = {}

    local x, y, z = GetDoorLocation(v)
    local yaw = EditorDoorData[v]['yaw']
    if yaw == nil then
      yaw = 0
    end

    _door['doorID'] = GetDoorModel(v)
    _door['x'] = x
    _door['y'] = y
    _door['z'] = z
    _door['yaw'] = yaw
  
    table.insert(_table, _door)
  end
  
  File_SaveJSONTable('world.json', _table)
  AddPlayerChatAll('Server: Saved the world.')
end
CreateTimer(Editor_SaveWorld, 10 * 60 * 1000)
AddCommand('save', Editor_SaveWorld)

function Editor_LoadWorld()
  if EditorWorldLoaded then return end
  EditorWorldLoaded = true

  print('Server: Attempting to load world.')

  local _table = File_LoadJSONTable('world.json')
  if _table ~= nil then
    for _,v in pairs(_table) do
      if v['modelID'] ~= nil then
        Editor_CreateObject(nil, v['modelID'], v['x'], v['y'], v['z'], v['rx'], v['ry'], v['rz'], v['sx'], v['sy'], v['sz'])
      else
        Editor_CreateDoor(v['doorID'], v['x'], v['y'], v['z'], v['yaw'])
      end
    end

    print('Server: World loaded!')
  else
    print('Server: No world.json found in root server directory, one will be made next time the server saves.')
  end
end
AddEvent('OnPackageStart', Editor_LoadWorld)

function Editor_SaveSchematics()
  File_SaveJSONTable('schematics.json', EditorSchematics)
end

function Editor_LoadSchematics()
  local _data = File_LoadJSONTable('schematics.json')
  if _data ~= nil then
    EditorSchematics = _data
    print('Server: Schematics loaded!')
  else
    print('Server: No schematics.json found in root server directory, one will be made next time a schematic is saved.')
  end
end
AddEvent('OnPackageStart', Editor_LoadSchematics)