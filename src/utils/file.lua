local io = require 'io'
local json = require 'lib.json'

local function readFile(path)
  local file = io.open(path, 'r')
  if file == nil then
    return nil
  end
  local content = file:read('*a')
  file:close()
  return content
end

local function readJson(path)
  return json.decode(readFile(path))
end

return {
  readFile = readFile,
  readJson = readJson
}

