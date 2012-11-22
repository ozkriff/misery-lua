-- See LICENSE file for copyright and license details

local Misc = require('misc')
local LexerHelp = require('lexerHelp')

-- shortcuts
local isLetterOrDigit = LexerHelp.isLetterOrDigit
local isNameOrNumber = LexerHelp.isNameOrNumber
local isDigit = LexerHelp.isDigit
local isLetter = LexerHelp.isLetter
local isNumber = LexerHelp.isNumber
local isName = LexerHelp.isName
local nthChar = LexerHelp.nthChar

-- lexer:lexem() -- get current lexem
-- lexer:peek(number) -- peek following lexems
-- lexer:next() -- go to next lexems
-- lexer:eat() -- сожрать определенную лексему

local M = {}
M.__index = M

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
    else
      table.insert(lexems, char)
    end
  end
  return lexems
end

M.incDecIndent = function(prelexems)
  local newLexemsList = {}
  local prevIndentLevel = 0
  local i = 1
  while i <= #prelexems do
    if prelexems[i] == '\n' then
      table.insert(newLexemsList, {tag = 'endOfLine'})
      i = i + 1
      local spacesCount = 0
      while prelexems[i] == ' ' do
        spacesCount = spacesCount + 1
        i = i + 1
      end
      indentLevel = spacesCount / 2
      local diff = prevIndentLevel - indentLevel
      prevIndentLevel = indentLevel
      if diff == 0 then
        table.insert(newLexemsList, {tag = 'samIndent'})
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
      -- local keywords = {
      --   'procedure',
      --   'if',
      --   'else',
      --   'while',
      --   'case',
      --   'of',
      --   'do',
      -- }
      -- for _, keyword in pairs(keywords) do
      --   if prelexems[i] == keyword then
      --     table.insert(newLexemsList, {tag = keyword})
      --   end
      -- end
      if prelexems[i] == ' ' then
        table.insert(newLexemsList, {tag = 'space'})
      elseif prelexems[i] == '\t' then
        print('ERROR!')
      elseif isName(prelexems[i]) then
        table.insert(newLexemsList, {tag = 'name', value = prelexems[i]})
      elseif isNumber(prelexems[i]) then
        table.insert(newLexemsList, {tag = 'number', value = tonumber(prelexems[i])})
      else
        -- TODO: error!
        -- table.insert(newLexemsList, Misc.copy(prelexems[i]))
      end
      i = i + 1
    end
  end
  return newLexemsList
end

-- TODO: rename!
M.processString = function(self, str)
  self._lexems = M.parseString(str)
  self._currentLexem = self._lexems[1]
  assert(#self._lexems > 0)
end

M.next = function(self)
  assert(#self._lexems >= 1)
  table.remove(self._lexems, 1)
  self._currentLexem = self._lexems[1]
end

M.eat = function(self, expectedLexem)
  -- TODO: ...
end

M.lexem = function(self)
  return self._currentLexem
end

return M
