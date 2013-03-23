-- See LICENSE file for copyright and license details

local Generator = require('generator')
local Parser = require('parser')
local Lexer = require('lexer')
local Misc = require('misc')
local Assert = require('assert')
local prettyPrint = require('prettyPrint')

local suite = Misc.newModule()

suite.testSimple = function()
  local input =
      'type Type1 struct:\n' ..
      '  field1 Int\n' ..
      '  field2 Float\n' ..
      '\n' ..
      'func f1(arg2 Int):\n' ..
      '  var tmp Type1\n' ..
      '\n' ..
      'func x(arg1 Int, arg2 Float):\n' ..
      '  var var1 Int\n' ..
      '  f1(arg1)\n' ..
      '\n' ..
      'func main() Int:\n' ..
      '  var var2i Int\n' ..
      '  var var2f Float\n' ..
      '  x(var2i, var2f)\n' ..
      ''

  local parser = Parser.new()
  local lexer = Lexer.new()
  lexer:processString(input)
  parser:setLexer(lexer)
  local realAST = parser:parse()

  local codeInAnsiC = Generator.generate(realAST)
  -- print(codeInAnsiC)

  -- Assert.isEqual(realAST, expectedAST)

  local outFile = io.open('out.c', 'w')
  outFile:write(codeInAnsiC)
  outFile:close()
end

return suite
