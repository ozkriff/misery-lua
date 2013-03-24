-- See LICENSE file for copyright and license details

local Generator = require('generator')
local Misc = require('misc')
local Assert = require('assert')

local suite = Misc.newModule()

suite.testSimple = function()
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
      '#include <stdio.h>\n' ..
      '\n' ..
      'typedef int Int;\n' ..
      'typedef float Float;\n' ..
      '\n' ..
      'typedef struct {\n' ..
      '  Int field1;\n' ..
      '  Float field2;\n' ..
      '} Type1;\n' ..
      '\n'
  Assert.isEqual(codeInAnsiC, expectedCodeInAnsiC)
end

suite.testFunc1 = function()
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
      '#include <stdio.h>\n' ..
      '\n' ..
      'typedef int Int;\n' ..
      'typedef float Float;\n' ..
      '\n' ..
      'Int x1() {\n' ..
      '  Int var1;\n' ..
      '}\n' ..
      '\n'
  Assert.isEqual(codeInAnsiC, expectedCodeInAnsiC)
end

-- TODO: write to some file
-- local outFile = io.open('out.c', 'w')
-- outFile:write(codeInAnsiC)
-- outFile:close()

return suite
