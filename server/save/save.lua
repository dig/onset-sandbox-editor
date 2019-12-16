EditorObjects = {}
EditorWorldLoaded = false

function Editor_SaveWorld()
  local _table = {}

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
  for _,v in pairs(_table) do
    Editor_CreateObject(nil, v['modelID'], v['x'], v['y'], v['z'], v['rx'], v['ry'], v['rz'], v['sx'], v['sy'], v['sz'])
  end

  print('Server: World loaded!')
end
AddEvent('OnPackageStart', Editor_LoadWorld)
