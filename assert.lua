-- See LICENSE file for copyright and license details

local Misc = require('misc')

local M = Misc.newModule()

local printStacktrace = function()
  -- print("ASSERT: 1")
  local stacktarce = Misc.split(debug.traceback(), '\n')
  -- table.remove(stacktarce, 1) -- remove 'traceback:..'
  -- table.remove(stacktarce) -- remove 'in C[?]'
  for i = 1, #stacktarce do
    if not string.find(stacktarce[i], 'runTests.lua') 
        and not string.find(stacktarce[i], 'assert.lua') 
    then
      print(stacktarce[i])
    end
  end
end

M.isEqual = function(real, expected)
  assert(real, 'real is nil!')
  assert(expected)
  if false then
    assert(Misc.compare(real, expected),
        'Expected <<< ' .. Misc.dump(expected) .. ' >>>, ' ..
        'but got <<< ' .. Misc.dump(real) .. ' >>>')
  else
    if not Misc.compare(real, expected) then
      printStacktrace()
      -- print("ASSERT: 2")
      if type(expected) == 'table' then
        print(Misc.diffTables(expected, real))
      else
        print(
            'Expected <<< ' ..
            Misc.dump(expected) ..
            ' >>> but got <<< ' ..
            Misc.dump(real) ..
            ' >>>')
      end
      os.exit() -- TODO: optional?
    end
  end
end

M.isTrue = function(real)
  assert(real)
end

M.isFalse = function(real)
  assert(not real)
end

M.isNil = function(real)
  assert(real == nil, 'Expected nil but got ' .. (real or 'nil'))
end

return M
