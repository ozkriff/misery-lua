-- See LICENSE file for copyright and license details

local Generator = require('generator')
local Misc = require('misc')
local Assert = require('assert')

local suite = Misc.newModule()

suite.testDeclareStructType = function()
  local ast = {
    {
      tag = 'typeDeclaration',
      name = 'Type1',
      fields = {
        { name = 'field1', type = 'Int' },
        { name = 'field2', type = 'Float' }
      }
    }
  }
  local codeInAnsiC = Generator.generate(ast)
  local expectedCodeInAnsiC =
      'typedef struct {\n' ..
      '  Int field1;\n' ..
      '  Float field2;\n' ..
      '} Type1;\n'
  Assert.isEqual(codeInAnsiC, expectedCodeInAnsiC)
end

suite.testDeclareFuncWithLocalVariable = function()
  local ast = {
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
    }
  }
  local codeInAnsiC = Generator.generate(ast)
  local expectedCodeInAnsiC =
      'Int x1() {\n' ..
      '  Int var1;\n' ..
      '}\n'
  Assert.isEqual(codeInAnsiC, expectedCodeInAnsiC)
end

suite.testSimpleFuncCall = function()
  local ast = {
    {
      tag = 'functionDeclaration',
      name = 'x1',
      parameters = {
        { type = 'Int', name = 'arg1' },
      },
      returnValue = { {type = 'Int'} },
      body = {
        {
          tag = 'functionCall',
          name = 'f1',
          parameters = { { tag = 'name', name = 'arg1' } },
        }
      }
    }
  }
  local codeInAnsiC = Generator.generate(ast)
  local expectedCodeInAnsiC =
      'Int x1(Int arg1) {\n' ..
      '  f1(arg1);\n' ..
      '}\n'
  Assert.isEqual(codeInAnsiC, expectedCodeInAnsiC)
end

suite.testFuncCallIntStringParameters = function()
  local ast = {
    {
      tag = 'functionDeclaration',
      name = 'x1',
      parameters = {
        { type = 'Int', name = 'arg1' },
      },
      returnValue = { {type = 'Int'} },
      body = {
        {
          tag = 'functionCall',
          name = 'f1',
          parameters = {
            { tag = 'number', value = 154 },
            { tag = 'string', value = 'agrh!' },
          },
        }
      }
    }
  }
  local codeInAnsiC = Generator.generate(ast)
  local expectedCodeInAnsiC =
      'Int x1(Int arg1) {\n' ..
      '  f1(154, \"agrh!\");\n' ..
      '}\n'
  Assert.isEqual(codeInAnsiC, expectedCodeInAnsiC)
end

-- TODO: write to some file
-- local outFile = io.open('out.c', 'w')
-- outFile:write(codeInAnsiC)
-- outFile:close()

return suite
