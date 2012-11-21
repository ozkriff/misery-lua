-- See LICENSE file for copyright and license details

-- local lexer = Lexer.new("filename")
-- lexer:lexem()
-- lexer:peek(number)
-- lexer:next()
-- lexer:eat()

local Misc = require('misc')
local LexerHelp = require('lexer_help')

local M = {}
M.__index = M

M.new = function(filename)
  local self = {}
  self.file = io.open(filename)
  self._isEndOfFile = false
  self._lexems = {}
  self._currentLexem = ''
  self.lastIndent = 0
  setmetatable(self, M)
  self:next()
  return self
end

local isCorrectNameChar = function(char)
  return LexerHelp.isDigit(char)
      or LexerHelp.isLetterOrUnderscore(char)
end

-- тупо разбиваем все на куски
local basicParse = function(source)
  local lexems = {}
  for i = 1, #source do
    local char = LexerHelp.nthChar(source, i)
    -- if char == '#' then
    --   return lexems
    -- end
    if isCorrectNameChar(char) and i > 1
        and LexerHelp.isNameOrNumber(lexems[#lexems])
    then
      lexems[#lexems] = lexems[#lexems] .. char
    else
      table.insert(lexems, char)
    end
  end
  return lexems
end

local spacesToIndent = function(self, prelexemList, lexemList)
  local spaceCount = 0
  for _, prelexem in ipairs(prelexemList) do
    if prelexem == ' ' then
      spaceCount = spaceCount + 1
    else
      break
    end
  end
  for i = 0, spaceCount do
    table.remove(prelexemList, 1)
  end
  local indentSize = 2
  assert(spaceCount % indentSize == 0, tostring(spaceCount))
  local indent = spaceCount / indentSize
  local indentDiff = indent - self.lastIndent
  self.lastIndent = indent
  while indentDiff > 0 do
    table.insert(lexemList, {tag = 'indentInc'})
    indentDiff = indentDiff - 1
  end
  while indentDiff < 0 do
    table.insert(lexemList, {tag = 'indentDec'})
    indentDiff = indentDiff + 1
  end
end

-- Тут я уже формирую полноценные токены
local lineToLexems = function(self, prelexemList)
  local lexemList = {}
  spacesToIndent(self, prelexemList, lexemList)
  for _, prelexem in ipairs(prelexemList) do
    print('prelexem = ', prelexem)
    if LexerHelp.isNumber(prelexem) then
      table.insert(lexemList, {tag = 'number', value = prelexem})
    -- elseif prelexem == '#' then
    --   break
    -- TODO: other keywords
    elseif prelexem == 'def' then
      table.insert(lexemList, {tag = 'def'})
    elseif prelexem == 'if' then
      table.insert(lexemList, {tag = 'if'})
    elseif prelexem == 'else' then
      table.insert(lexemList, {tag = 'else'})
    elseif LexerHelp.isName(prelexem) then
      -- все ключевые слова уже должны бы были провериться
      table.insert(lexemList, {tag = 'name', value = prelexem})
    elseif prelexem == ',' then
      table.insert(lexemList, {tag = ','})
    elseif prelexem == '(' then
      table.insert(lexemList, {tag = '('})
    elseif prelexem == ')' then
      table.insert(lexemList, {tag = ')'})
    elseif prelexem == '\n' then
      table.insert(lexemList, {tag = 'endOfLine'})
    end
  end
  return lexemList
end

M.lexem = function(self)
  return self._currentLexem
end

local getNextLine = function(self)
  local string = self.file:read('*L')
  if string == nil then
    self._isEndOfFile = true
    return
  else
    self._lexems = lineToLexems(self, basicParse(string))
  end
end

M.next = function(self)
  table.remove(self._lexems, 1)
  if #self._lexems == 0 then
    getNextLine(self)
  else
    self._currentLexem = self._lexems[1]
  end
end

M.isEndOfFile = function(self)
  return self._isEndOfFile
end

M.peekNextLexem = function(self)
  while #self._lexems < 2 and not self:isEndOfFile() do
    getNextLine(self)
  end
  if #self._lexems >= 2 then
    return self._lexems[2]
  else
    return nil
  end
end

return M
