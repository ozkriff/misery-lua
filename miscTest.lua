-- See LICENSE file for copyright and license details

local Misc = require('misc')
local Assert = require('assert')
local math = require('math')

local suite = Misc.newModule()

suite.testDiff = function() end -- TODO: implement

-- TODO: add MORE tests
suite.testSplit = function()
  local input =
      's1\n' ..
      's2\n' ..
      's3\n'
  local output = Misc.split(input, '\n')
  local expectedOutput = { 's1', 's2', 's3' }
  Assert.isEqual(output, expectedOutput)
end

suite.testSplit2 = function()
  local input = 'a!bb!!!b!'
  local expectedOutput = {'a', 'bb', 'b'}
  local output = Misc.split(input, '!')
  Assert.isEqual(output, expectedOutput)
end

suite.testForEach = function() end -- TODO: implement

return suite
