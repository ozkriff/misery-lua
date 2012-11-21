local Misc = require 'misc'
local udump = require 'udump'

-- var e := (m * c) ^ 2
-- var e := pow(mul(m, c), 2)

function isNumber(str)
  -- TODO: different number representation formats
  return not string.find(str, '[^%d]+')
end

function isDigit(char)
  local n = string.byte(char)
  return n >= string.byte('0') and n <= string.byte('9')
end

function isLetter(char)
  local n = string.byte(string.lower(char))
  return n >= string.byte('a') and n <= string.byte('z')
end

-- TODO: test coverage in separate file
--[[
print('a = ', isDigit('a'))
print('0 = ', isDigit('0'))
print('1 = ', isDigit('1'))
print('9 = ', isDigit('9'))

print('9 = ', isLetter('9'))
print('a = ', isLetter('a'))
print('A = ', isLetter('A'))
print('_ = ', isLetter('_'))
]]--

function nthChar(str, n)
  assert(#str >= n)
  return string.sub(str, n, n)
end

function isLetterOrUnderscore(char)
  return isLetter(char) or char == '_'
end

function isName(str)
  if not isLetterOrUnderscore(nthChar(str, 1)) then
    return false
  end
  for i = 2, #str do
    local char = nthChar(str, i)
    if not (isLetterOrUnderscore(char) or isDigit(char)) then
      return false
    end
  end
  return true
end

function isNameOrNumber(str)
  return isNumber(str) or isName(str)
end

-- тупо разбиваем все на куски
-- TODO: удалить дублирующиеся пробелы?
function basicParse(source)
  local words = {''}
  local i = 1
  while i <= #source do
    local char = nthChar(source, i)
    if char == '#' then
      -- skip comments
      repeat
        i = i + 1
      until nthChar(source, i) == '\n'
    elseif isNameOrNumber(char) and i > 1
        and isNameOrNumber(words[#words])
    then
      words[#words] = words[#words] .. char
    else
      table.insert(words, char)
    end
    i = i + 1
  end
  return words
end

-- TODO: implement
function indentationTo_XXX(pretokenList)
end

-- Тут я уже формирую полноценные токены
function getTokens(pretokenList)
  local isBeginigOfLine = true
  local spaceCount = 0
  local lastIndent = 0
  local currentIndent = 0
  local tokenList = {}
  for _, pretoken in ipairs(pretokenList) do
    if isBeginigOfLine
        and pretoken == '\n'
        or isName(pretoken)
        or isNumber(pretoken)
    then
      local indentDiff = currentIndent - lastIndent
      lastIndent = currentIndent
      isBeginigOfLine = false
      while indentDiff > 0 do
        table.insert(tokenList, {tag = 'indentInc'})
        indentDiff = indentDiff - 1
      end
      while indentDiff < 0 do
        table.insert(tokenList, {tag = 'indentDec'})
        indentDiff = indentDiff + 1
      end
    end
    if isNumber(pretoken) then
      table.insert(tokenList, {tag = 'number', value = pretoken})
    elseif isName(pretoken) then
      -- TODO: Check for other keywords
      if pretoken == 'def' then
        table.insert(tokenList, {tag = 'def'})
      elseif pretoken == 'if' then
        table.insert(tokenList, {tag = 'if'})
      elseif pretoken == 'else' then
        table.insert(tokenList, {tag = 'else'})
      else
        table.insert(tokenList, {tag = 'name', value = pretoken})
      end
    elseif pretoken == ' ' then
      if isBeginigOfLine then
        spaceCount = spaceCount + 1
        if spaceCount == 2 then
          currentIndent = currentIndent + 1
          spaceCount = 0
        end
      end
    elseif pretoken == ',' then
      table.insert(tokenList, {tag = ','})
    elseif pretoken == '(' then
      table.insert(tokenList, {tag = '('})
    elseif pretoken == ')' then
      table.insert(tokenList, {tag = ')'})
    elseif pretoken == '\n' then
      table.insert(tokenList, {tag = 'endOfLine'})
      isBeginigOfLine = true
      currentIndent = 0
      spaceCount = 0
    end
  end
  return tokenList
end

-- tokenizer.set_file("filename")
-- tokenizer.currentToken()
-- tokenizer.peekNextToken()
-- tokenizer.nextToken()
-- tokenizer.consume()

function getNextToken(tokenList)
  if #tokenList == 0 then
    return nil
  else
    return table.remove(tokenList, 1)
  end
end

local parseFunctionBody = function(tokenList)
  -- ...
end

local parseFunctionArguments = function(tokenList)
  -- ...
end

local parseFunction = function(tokenList)
  local funcName = getNextToken(tokenList).value
  assert(getNextToken(tokenList).tag == '(')
  -- TODO: список параметров с типами
  assert(getNextToken(tokenList).tag == ')')
  assert(getNextToken(tokenList).tag == 'endOfLine')
  assert(getNextToken(tokenList).tag == 'indentInc')
  local body = {}
  token = getNextToken(tokenList)
  while token.tag ~= 'indentDec' do
    if token.tag == 'name' then
      local funcName = token.value
      table.insert(body, {tag = 'call', name = funcName})
      assert(getNextToken(tokenList).tag == '(')
      local arguments = {} -- TODO: add peek() and consume()
      while true do
        local arg = getNextToken(tokenList)
        table.insert(arguments, {tag = 'arg', name = arg.value})
        local commaOrParen = getNextToken(tokenList)
        if commaOrParen.tag == ')' then
          break
        else
          assert(commaOrParen.tag == ',', Misc.dump(commaOrPren))
        end
      end
      assert(getNextToken(tokenList).tag == 'endOfLine')
      token = getNextToken(tokenList)
    end
  end
  table.insert(ast, {
    tag = 'functionDeclaration',
    name = funcName,
    arguments = arguments,
    body = body,
  })
end

-- главная функция парсинга
function buildAST(tokenList)
  local ast = {}
  while true do
    local token = getNextToken(tokenList)
    if token == nil then
      return ast
    end
    if token.tag == 'def' then
      parseFunction(tokenList)
    end
  end
  return ast
end

local testSourceString = [[
# def tf1()
#   f1(1)
#   f2(11)
#   f3(111, 613)
# 
def tf2()
  # f1(var1)
  f1()
  f2()

]]

io.write('SOURCE:\n', testSourceString, '\n')

local pretokenList = basicParse(testSourceString)
io.write('\n')
io.write('PRETOKENS:\n', Misc.dump(pretokenList), '\n')

local tokenList = getTokens(pretokenList)
io.write('\n')
-- io.write('TOKEN_LIST:\n', udump(tokenList), '\n')

local abstractSyntaxTree = buildAST(tokenList)
io.write('\n')
-- io.write('AST:\n', Misc.dump(abstractSyntaxTree), '\n')
io.write('AST:\n', udump(abstractSyntaxTree), '\n')

-- generateCCode(abstractSyntaxTree)
