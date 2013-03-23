-- See LICENSE file for copyright and license details

local prettyPrint = require('prettyPrint')

local M = {}

M.newModule = function()
  return {}
end

M.newType = function()
  local M = {}
  M.__index = M
  return M
end

-- http://lua-users.org/wiki/SimpleRound
M.round = function(num, idp)
  local mult = 10 ^ (idp or 0)
  if num >= 0 then
    return math.floor(num * mult + 0.5) / mult
  else
    return math.ceil(num * mult - 0.5) / mult
  end
end

M.distance = function(from, to)
  local dx = math.abs(to.x - from.x)
  local dy = math.abs(to.y - from.y)
  local n = math.sqrt(dx ^ 2 + dy ^ 2)
  return M.round(n)
end

M.clamp = function(value, min, max)
  assert(value)
  assert(min)
  assert(max)
  if min > max then
    return nil
  end
  if value < min then
    value = min
  elseif value > max then
    value = max
  end
  return value
end

M.intToChar = function(n)
  return string.char(n)
end

-- TODO: test!
M.idToKey = function(table, id)
  assert(table)
  assert(id)
  for k, v in pairs(table) do
    assert(v.id)
    if v.id == id then
      return k, v
    end
  end
  return nil
end

-- This function recursively copies a table's contents,
-- and ensures that metatables are preserved.
-- That is, it will correctly clone a pure Lua object.
M.copy = function(t)
  if type(t) ~= 'table' then
    return t
  end
  local mt = getmetatable(t)
  local res = {}
  for k, v in pairs(t) do
    if type(v) == 'table' then
      v = M.copy(v)
    end
    res[k] = v
  end
  return setmetatable(res, mt)
end

-- This will compare two Lua values, and recursively
-- compare the values of any tables encountered.
-- By default, it will respect metamethods - that is,
-- if two objects of the same type support __eq this
-- will be used. If the third parameter is true then
-- metatables are ignored in the comparison.
M.compare = function(t1, t2, ignoreMT)
  if type(t1) ~= type(t2) then
    return false
  end
  -- non-table types can be directly compared
  if type(t1) ~= 'table' and type(t2) ~= 'table' then
    return t1 == t2
  end
  -- as well as tables which have the metamethod __eq
  local mt = getmetatable(t1)
  if not ignoreMT and mt and mt.__eq then
    return t1 == t2
  end
  for k1, v1 in pairs(t1) do
    local v2 = t2[k1]
    if v2 == nil or not M.compare(v1, v2) then
      return false
    end
  end
  for k2, v2 in pairs(t2) do
    local v1 = t1[k2]
    if v1 == nil or not M.compare(v1, v2) then
      return false
    end
  end
  return true
end

-- This creates a string representation of a table,
-- in a form like {[1]=10, [2]=20, ["name"]="alice"}.
-- Not very efficient, because of all the string
-- concatentations, and will freak if given a table
-- with cycles, i.e. with recursive references.
M.dump = function(o)
  if type(o) == 'table' then
    return prettyPrint(o)
  else
    return tostring(o)
  end
end

M.forEach = function(list, func)
  for key, value in pairs(list) do
    func(value)
  end
end

-------------------------------------------------

local findFirstDifferentLineIndex = function(lines1, lines2)
  assert(lines1 ~= nil)
  assert(type(lines1) == 'table', type(lines1))
  assert(lines2 ~= nil)
  assert(type(lines2) == 'table')
  for i = 1, math.min(#lines1, #lines2) do
    if lines1[i] ~= lines2[i] then
      return i
    end
  end
  return nil
end

local findLastDifferentLineIndex = function(lines1, lines2)
  assert(lines1 ~= nil)
  assert(type(lines1) == 'table')
  assert(lines2 ~= nil)
  assert(type(lines2) == 'table')
  local lastIndex = math.min(#lines1, #lines2)
  for i = 0, lastIndex - 1 do
    local index1 = #lines1 - i
    local index2 = #lines2 - i
    if lines1[index1] ~= lines2[index2] then
      return i
    end
  end
  return nil
end

M.split = function(self, sep)
  assert(self ~= nil)
  assert(type(self) == 'string')
  assert(sep ~= nil)
  assert(type(sep) == 'string')
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  self:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end

M.diffTables = function(table1, table2)
  assert(type(table1) == 'table')
  assert(type(table2) == 'table')
  local ss1 = M.dump(table1) .. '\n'
  local ss2 = M.dump(table2) .. '\n'
  return M.diffStrings(ss1, ss2)
end

M.diffStrings = function(ss1, ss2)
  local out = ''
  local s1 = M.split(ss1, '\n')
  local s2 = M.split(ss2, '\n')
  local firstIndex = findFirstDifferentLineIndex(s1, s2)
  local lastIndex = findLastDifferentLineIndex(s1, s2)
  if firstIndex ~= nil and lastIndex ~= nil then
    local lastIndex1 = #s1 - lastIndex
    local lastIndex2 = #s2 - lastIndex
    for i = 1, firstIndex - 1 do
      out = out .. '| ' .. s1[i] .. '\n'
    end
    for i = firstIndex, lastIndex1 do
      out = out .. '1 ' .. s1[i] .. '\n'
    end
    for i = firstIndex, lastIndex2 do
      out = out .. '2 ' .. s2[i] .. '\n'
    end
    for i = lastIndex1 + 1, #s1 do
      out = out .. '| ' .. s1[i] .. '\n'
    end
  else
    out = '[[ THEY ARE EQUAL ]]\n'
  end

  return out
end


-------------------------------------------------

return M
