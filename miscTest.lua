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

suite.testSplit3 = function()
  local input = '!!!!!'
  local expectedOutput = {}
  local output = Misc.split(input, '!')
  Assert.isEqual(output, expectedOutput)
end

suite.testForEach = function() end -- TODO: implement

suite.testDump1 = function()
  Assert.isEqual(Misc.dump(nil), 'nil')
  Assert.isEqual(Misc.dump(''), '')
  Assert.isEqual(Misc.dump('abc'), 'abc')
  Assert.isEqual(Misc.dump(5), '5')
  Assert.isEqual(Misc.dump({}), '{\n}')
  -- TODO: remove this ### space!
  Assert.isEqual(Misc.dump({{}}), '{\n  {} \n}')
  Assert.isEqual(Misc.dump({1}), '{\n  1 \n}')
  Assert.isEqual(Misc.dump({x = 1}), '{\n  x = 1 \n}')
  Assert.isEqual(Misc.dump('x'), 'x')
end

suite.testDiffStrings = function()
  local s1 =
      '1\n' ..
      '1.5\n' ..
      '2\n' ..
      '3\n' ..
      '4\n'
  local s2 =
      '1\n' ..
      '1.5\n' ..
      '2X\n' ..
      '3X\n' ..
      '4\n'
  local realDiff = Misc.diffStrings(s1, s2)
  local expectedDiff =
      '| 1\n' ..
      '| 1.5\n' ..
      '1 2\n' ..
      '1 3\n' ..
      '2 2X\n' ..
      '2 3X\n' ..
      '| 4\n'
  Assert.isEqual(realDiff, expectedDiff)
end

return suite
