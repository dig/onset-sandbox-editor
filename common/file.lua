function File_SaveJSONTable(path, table)
  local file = io.open(path, 'w')

  if file then
    local contents = json_encode(table)
    file:write(contents)
    io.close(file)
    return true
  else
    return false
  end
end

function File_LoadJSONTable(path)
  local contents = ''
  local myTable = {}
  local file = io.open(path, 'r')

  if file then
    local contents = file:read("*a")
    myTable = json_decode(contents);
    io.close(file)
    return myTable
  end

  return nil
end