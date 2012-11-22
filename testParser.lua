-- See LICENSE file for copyright and license details

local Parser = require('parser')
local Misc = require('misc')
local Assert = require('assert')
local udump = require('udump')

local suite = {}

suite.testConstructor = function()
  local parser = Parser.new()
  Assert.isTrue(parser ~= nil)
end

return suite
