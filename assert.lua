-- See LICENSE file for copyright and license details

local Misc = require('misc')

local M = {}

M.isEqual = function(real, expected)
  assert(real, 'real is nil!')
  assert(expected)
  assert(Misc.compare(real, expected),
      'Expected <<< ' .. Misc.dump(expected) .. ' >>>, ' ..
      'but got <<< ' .. Misc.dump(real) .. ' >>>')
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
