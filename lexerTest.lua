-- See LICENSE file for copyright and license details

local Misc = require('misc')
local Assert = require('assert')
local Lexer = require('lexer')

local suite = Misc.newModule()

suite.testConstructor = function()
  local lexer = Lexer.new()
  Assert.isTrue(lexer ~= nil)
end

-- concatenate, parse and compare
-- TODO: Rename!
local doSimpleParseTest = function(lexemsList)
  local concatenatedLexems = table.concat(lexemsList)
  local parsedLexemsList = Lexer.parseString(concatenatedLexems)
  Assert.isEqual(#parsedLexemsList, #lexemsList)
  for i = 1, #parsedLexemsList do
    Assert.isEqual(parsedLexemsList[i], lexemsList[i])
  end
end

suite.testParseString = function()
  doSimpleParseTest{'a'}
  doSimpleParseTest{'ab', ' ', 'c'}
  doSimpleParseTest{'ab', ' ', ' ', ' ', 'c', ' '}
  doSimpleParseTest{'ab', ' ', '1', ' ', 'c'}
  doSimpleParseTest{'ab', ' ', '123', ' ', 'c'}
  doSimpleParseTest{'a', ' ', '==', ' ', 'b'}
  doSimpleParseTest{'a', '==', 'b'}
  doSimpleParseTest{'a', ' ', '==', ' ', 'b'}
  doSimpleParseTest{
      'func', '(', 'arg1', ',', ' ', 'argC', ',', ' ', '4', ')'}
  doSimpleParseTest{
      'f', '(', 'a', ',', ' ', 'b', ')', ';', '\n', 'f', '(', ')'}
end

-- lexer:lexem() -- get current lexem
-- lexer:peek(number) -- peek following lexems
-- lexer:next() -- go to next lexems
-- lexer:eat() -- consume that lexem

-- TODO: Rename
suite.testParse1 = function()
  local lexer = Lexer.new()
  local lexems = {'func1', '(', 'a2', ',', ' ', 'b2', ')'}
  lexer:processString(table.concat(lexems))
  Assert.isFalse(lexer:noMoreLexemsLeft())
  Assert.isEqual(lexer:lexem(), {tag = 'name', value = 'func1'})
  lexer:next()
  Assert.isEqual(lexer:lexem(), {tag = '('})
  lexer:next()
  Assert.isEqual(lexer:lexem(), {tag = 'name', value = 'a2'})
  lexer:next()
  Assert.isEqual(lexer:lexem(), {tag = ','})
  lexer:next()
  Assert.isEqual(lexer:lexem(), {tag = ' '})
  lexer:next()
  Assert.isEqual(lexer:lexem(), {tag = 'name', value = 'b2'})
  lexer:next()
  Assert.isEqual(lexer:lexem(), {tag = ')'})
  lexer:next()
  Assert.isTrue(lexer:noMoreLexemsLeft())
end

suite.testEat = function()
  local lexer = Lexer.new()
  local lexems = {'func1', '(', 'a2', ',', ' ', 'b2', ')'}
  lexer:processString(table.concat(lexems))
  lexer:eat{tag = 'name', value = 'func1'}
  lexer:eat{tag = '('}
  lexer:eat{tag = 'name', value = 'a2'}
  lexer:eat{tag = ','}
  lexer:eat{tag = ' '}
  lexer:eat{tag = 'name', value = 'b2'}
  lexer:eat{tag = ')'}
  Assert.isTrue(lexer:noMoreLexemsLeft())
end

suite.testMultipleStrings = function()
  local lexer = Lexer.new()
  local lexems = {{'a1', ' '}, {'a2', ' ', '\n'}, {'a3'}}
  -- line 1
  lexer:processString(table.concat(lexems[1]))
  Assert.isFalse(lexer:noMoreLexemsLeft())
  Assert.isEqual(lexer:lexem(), {tag = 'name', value = 'a1'})
  lexer:next()
  Assert.isEqual(lexer:lexem(), {tag = ' '})
  lexer:next()
  Assert.isTrue(lexer:noMoreLexemsLeft())
  -- line 2
  lexer:processString(table.concat(lexems[2]))
  Assert.isFalse(lexer:noMoreLexemsLeft())
  Assert.isEqual(lexer:lexem(), {tag = 'name', value = 'a2'})
  lexer:next()
  Assert.isEqual(lexer:lexem(), {tag = ' '})
  lexer:next()
  Assert.isEqual(lexer:lexem(), {tag = 'endOfLine'})
  lexer:next()
  Assert.isTrue(lexer:noMoreLexemsLeft())
  -- line 3
  lexer:processString(table.concat(lexems[3]))
  Assert.isFalse(lexer:noMoreLexemsLeft())
  Assert.isEqual(lexer:lexem(), {tag = 'name', value = 'a3'})
  lexer:next()
  Assert.isTrue(lexer:noMoreLexemsLeft())
end

suite.testIndent = function()
  local input = 
      "func x\n" ..
      "  if b == 10:\n" ..
      "    c.f()\n" ..
      "d()\n"
  local parsedPrelexemsList = Lexer.parseString(input)
  local parsedLexemsList = Lexer.incDecIndent(parsedPrelexemsList)
  local expected = {
    {tag = 'func'},
    {tag = ' '},
    {tag = 'name' , value = 'x'},
    {tag = 'endOfLine'},
    {tag = 'incIndent'},
    {tag = 'if'},
    {tag = ' '},
    {tag = 'name' , value = 'b'},
    {tag = ' '},
    {tag = '=='},
    {tag = ' '},
    {tag = 'number' , value = 10},
    {tag = ':'},
    {tag = 'endOfLine'},
    {tag = 'incIndent'},
    {tag = 'name' , value = 'c'},
    {tag = '.'},
    {tag = 'name' , value = 'f'},
    {tag = '('},
    {tag = ')'},
    {tag = 'endOfLine'},
    {tag = 'decIndent'},
    {tag = 'decIndent'},
    {tag = 'name' , value = 'd'},
    {tag = '('},
    {tag = ')'},
    {tag = 'endOfLine'},
  }
  -- print(Misc.dump(parsedLexemsList))
  Assert.isEqual(parsedLexemsList, expected)
end

suite.testString = function()
  local input = 
      "x.\'kill me\' y"
  local parsedPrelexemsList = Lexer.parseString(input)
  local parsedLexemsList = Lexer.incDecIndent(parsedPrelexemsList)
  local expected = {
    {tag = 'name' , value = 'x'},
    {tag = '.'},
    {tag = 'string' , value = 'kill me'},
    {tag = ' '},
    {tag = 'name' , value = 'y'},
  }
  Assert.isEqual(parsedLexemsList, expected)
end

return suite
