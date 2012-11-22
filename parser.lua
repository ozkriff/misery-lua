-- See LICENSE file for copyright and license details

local Misc = require('misc')

local M = {}
M.__index = M

M.new = function()
  local self = {}
  setmetatable(self, M)
  return self
end



return M
