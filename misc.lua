-- See LICENSE file for copyright and license details

local M = {}

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
    local s = '{'
    for k, v in pairs(o) do
      -- s = s .. k .. ' = ' .. M.dump(v) .. ', '
      s = s .. k .. '=' .. M.dump(v) .. ', '
    end
    s = string.gsub(s .. '}', ', }', '}')
    return s
  else
    return tostring(o)
  end
end

M.forEach = function(list, func)
  for key, value in pairs(list) do
    func(value)
  end
end

return M
