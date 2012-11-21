-- See LICENSE file for copyright and license details

local M = {}

M.isNumber = function(str)
  if not str or #str < 1 then
    return false
  end
  -- TODO: different number representation formats
  return not string.find(str, '[^%d]+')
end

M.isDigit = function(char)
  if not char or #char ~= 1 then
    return false
  end
  local n = string.byte(char)
  return n >= string.byte('0') and n <= string.byte('9')
end

M.isLetter = function(char)
  if not char or #char ~= 1 then
    return false
  end
  local n = string.byte(string.lower(char))
  return n >= string.byte('a') and n <= string.byte('z')
end

M.nthChar = function(str, n)
  if n > #str or n <= 0 then
    return nil
  end
  return string.sub(str, n, n)
end

M.isLetterOrUnderscore = function(char)
  return M.isLetter(char) or char == '_'
end

-- TODO: isCorrectFunctionName, isCorrectVariableName, isCorrectTypeName
-- is correct name
M.isName = function(str)
  if not M.isLetterOrUnderscore(M.nthChar(str, 1)) then
    return false
  end
  for i = 2, #str do
    local char = M.nthChar(str, i)
    if not (M.isLetterOrUnderscore(char) or M.isDigit(char)) then
      return false
    end
  end
  return true
end

M.isNameOrNumber = function(str)
  if not str or #str == 0 then
    return nil
  end
  return M.isNumber(str) or M.isName(str)
end

M.isLetterOrDigit = function(char)
  return M.isLetter(char) or M.isDigit(char)
end

return M
