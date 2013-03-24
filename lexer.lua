-- See LICENSE file for copyright and license details

local Misc = require('misc')
local LexerHelp = require('lexerHelp')
local Assert = require('assert')

-- shortcuts
local isLetterOrDigit = LexerHelp.isLetterOrDigit
local isNameOrNumber = LexerHelp.isNameOrNumber
local isDigit = LexerHelp.isDigit
local isLetter = LexerHelp.isLetter
local isNumber = LexerHelp.isNumber
local isName = LexerHelp.isName
local nthChar = LexerHelp.nthChar

local M = Misc.newType()

M.new = function()
  local self = {}
  self._lexems = {}
  self._currentLexem = ''
  setmetatable(self, M)
  return self
end

-- разбивает строку на прелексемы
M.parseString = function(source)
  local lexems = {}
  local appendCharToLastLexem = function(char)
    lexems[#lexems] = lexems[#lexems] .. char
  end
  for i = 1, #source do
    local char = nthChar(source, i)
    local lastLexem = lexems[#lexems]
    if i == 1 then
      table.insert(lexems, char)
    elseif isNumber(lastLexem) and isDigit(char) then
      appendCharToLastLexem(char)
    elseif isName(lastLexem) and isLetterOrDigit(char) then
      appendCharToLastLexem(char)
    elseif lastLexem == '=' and char == '=' then
      appendCharToLastLexem(char)
    else
      table.insert(lexems, char)
    end
  end
  return lexems
end

local keywords = {
  'func',
  'struct',
  'type',
  'var',
  'if',
  '==',
  ';',
  ':',
  '(',
  ')',
  '[',
  ']',
  '{',
  '}',
  ',',
  '.',
}

local isKeyword = function(prelexem)
  for _, keyword in pairs(keywords) do
    if prelexem == keyword then
      return true
    end
  end
  return false
end

local popLexem = function(prelexemsList)
  if prelexemsList ~= nil and #prelexemsList > 0 then
    return table.remove(prelexemsList, 1)
  else
    return nil
  end
end

local readString = function(prelexems)
  local node = {}
  node.tag = 'string'
  local prelexem = popLexem(prelexems)
  local value = ''
  while prelexem ~= nil and prelexem ~= '\'' do
    -- print('inside string: [' .. prelexem .. ']')
    value = value .. prelexem
    prelexem = popLexem(prelexems)
  end
  node.value = value
  return node
end

M.incDecIndent = function(prelexems)
  local newLexemsList = {}
  local prevIndentLevel = 0
  local prelexem = popLexem(prelexems)
  -- while #prelexems > 0 do
  while prelexem ~= nil do
    if prelexem == '\'' then
      local stringNode = readString(prelexems)
      prelexem = popLexem(prelexems) -- remove closing '\''
      table.insert(newLexemsList, stringNode)
    elseif prelexem == '\n' then
      table.insert(newLexemsList, {tag = 'endOfLine'})
      local spacesCount = 0
      prelexem = popLexem(prelexems)
      while prelexem == ' ' do
        spacesCount = spacesCount + 1
        prelexem = popLexem(prelexems)
      end
      indentLevel = spacesCount / 2
      local diff = prevIndentLevel - indentLevel
      prevIndentLevel = indentLevel
      if diff == 0 and indentLevel ~= 0 then
        -- table.insert(newLexemsList, {tag = 'samIndent'})
      else
        while diff < 0 do
          table.insert(newLexemsList, {tag = 'incIndent'})
          diff = diff + 1
        end
        while diff > 0 do
          table.insert(newLexemsList, {tag = 'decIndent'})
          diff = diff - 1
        end
      end
    else
      if prelexem == ' ' then
        table.insert(newLexemsList, {tag = ' '})
      elseif prelexem == '\t' then
        print('ERROR!')
      elseif isKeyword(prelexem) then
        table.insert(newLexemsList, {tag = prelexem})
      elseif isName(prelexem) then
        table.insert(newLexemsList, {
          tag = 'name',
          value = prelexem,
        })
      elseif isNumber(prelexem) then
        table.insert(newLexemsList, {
          tag = 'number',
          value = tonumber(prelexem),
        })
      else
        -- TODO: error!
        -- table.insert(newLexemsList, Misc.copy(prelexem))
      end
      prelexem = popLexem(prelexems)
    end
  end
  return newLexemsList
end

-- TODO: rename!
M.processString = function(self, str)
  self._lexems = M.incDecIndent(M.parseString(str))
  self._currentLexem = self._lexems[1]
  assert(#self._lexems > 0)
end

M.next = function(self)
  assert(#self._lexems >= 1)
  table.remove(self._lexems, 1)
  self._currentLexem = self._lexems[1]
end

M.noMoreLexemsLeft = function(self)
  return (#self._lexems == 0)
end

-- TODO: what to do in case of errors?
M.eat = function(self, expectedLexem)
  Assert.isEqual(self:lexem(), expectedLexem)
  self:next()
end

-- TODO: peek

M.lexem = function(self)
  return self._currentLexem
end

return M
