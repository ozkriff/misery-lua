-- See LICENSE file for copyright and license details

local Parser = require('parser')
local Lexer = require('lexer')
local Misc = require('misc')
local Assert = require('assert')

local suite = Misc.newModule()

suite.testConstructor = function()
  local parser = Parser.new()
  Assert.isTrue(parser ~= nil)
end

suite.testGenerateSimpleAST = function()
  local input =
      'type Type1 struct:\n' ..
      '  field1 Int\n' ..
      '  field2 Float\n' ..
      '\n' ..
      'func x1() Int:\n' ..
      '  var var1 Int\n' ..
      '\n' ..
      'func x(arg1 Int, arg2 Float):\n' ..
      '  var var1 Int\n' ..
      '  f1(arg1)\n' ..
      '  f2()\n' ..
      '  f2(arg1, arg2)\n' ..
      ''
  local parser = Parser.new()
  local lexer = Lexer.new()
  lexer:processString(input)
  parser:setLexer(lexer)
  local realAST = parser:parse()
  local expectedAST = {
    {
      tag = 'typeDeclaration',
      name = 'Type1',
      fields = {
        { name = 'field1', type = 'Int' },
        { name = 'field2', type = 'Float' }
      }
    },
    {
      tag = 'functionDeclaration',
      name = 'x1',
      parameters = {},
      returnValue = { {type = 'Int'} },
      body = {
        {
          tag = 'variableDeclaration',
          name = 'var1',
          type = 'Int',
        }
      }
    },
    {
      tag = 'functionDeclaration',
      name = 'x',
      parameters = {
        { type = 'Int', name = 'arg1' },
        { type = 'Float', name = 'arg2' },
      },
      returnValue = {},
      body = {
        {
          tag = 'variableDeclaration',
          name = 'var1',
          type = 'Int',
        },
        {
          tag = 'functionCall',
          name = 'f1',
          parameters = { { name = 'arg1' } },
        },
        {
          tag = 'functionCall',
          name = 'f2',
          parameters = {},
        },
        {
          tag = 'functionCall', name = 'f2',
          parameters = { { name = 'arg1' }, { name = 'arg2' } }
        },
      },
    },
  }
  Assert.isEqual(realAST, expectedAST)
end

return suite
