function Editor_CommandObjectSpeed(player, speed)
  if not IsValidPlayer(player) then return end
  if speed == nil then return AddPlayerChat(player, 'Usage: /objectspeed <speed>') end

  speed = tonumber(speed)
  if (speed < 0 or speed > 200) then return AddPlayerChat(player, 'Object speed must be between 0 and 200.') end

  AddPlayerChat(player, 'Object speed set to ' .. speed .. '.')
  CallRemoteEvent(player, 'SetEditorSpeed', speed)
end
AddCommand('objectspeed', Editor_CommandObjectSpeed)

function Editor_CommandMassSelect(player, objectID, radius)
  if objectID == nil then return AddPlayerChat(player, 'Usage: /select <objectID> [radius]') end
  if radius == nil then
    radius = 1000000000
  end

  CallRemoteEvent(player, 'MassSelect', objectID, radius)
end
AddCommand('select', Editor_CommandMassSelect)

function Editor_CommandSchematic(player, subcommand, name, check)
  if subcommand == nil then return AddPlayerChat(player, '/schematic <save|load|list> <name>') end

  if subcommand == 'save' then
    if name == nil then return AddPlayerChat(player, 'Invalid name.') end
    if check ~= nil then return AddPlayerChat(player, 'Names cannot contain spaces.') end

    CallRemoteEvent(player, 'RequestSchematicSave', name)
  elseif subcommand == 'load' then
    if name == nil then return AddPlayerChat(player, 'Invalid name.') end
    if check ~= nil then return AddPlayerChat(player, 'Names cannot contain spaces.') end
    if EditorSchematics[name] == nil then return AddPlayerChat(player, 'Schematic doesn\'t exist.') end
    
    CallRemoteEvent(player, 'SchematicLoad', name, EditorSchematics[name]['selected'], EditorSchematics[name]['extra'])    
  elseif subcommand == 'list' then
    local _str = ''
    for k, v in pairs(EditorSchematics) do
      if _str == '' then
        _str = k
      else
        _str = _str .. ', ' .. k
      end
    end

    AddPlayerChat(player, 'Schematic List: ' .. _str)
  end
end
AddCommand('schematic', Editor_CommandSchematic)

function Editor_OnSchematicSave(player, name, _selected, _extra)
  EditorSchematics[name] = {
    selected = _selected,
    extra = _extra
  }

  AddPlayerChat(player, 'Schematic ' .. name .. ' has been saved.')
  Editor_SaveSchematics()
end
AddRemoteEvent('SchematicSave', Editor_OnSchematicSave)