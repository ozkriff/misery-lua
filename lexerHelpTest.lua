-- See LICENSE file for copyright and license details

local Misc = require('misc')
local Assert = require('assert')
local LexerHelp = require('lexerHelp')

-- shortcuts
local isNameOrNumber = LexerHelp.isNameOrNumber
local isDigit = LexerHelp.isDigit
local isLetter = LexerHelp.isLetter
local isNumber = LexerHelp.isNumber
local isName = LexerHelp.isName
local nthChar = LexerHelp.nthChar
local isLetterOrUnderscore
    = LexerHelp.isLetterOrUnderscore

-- not good idea
local T = Assert.isTrue
local F = Assert.isFalse
local E = Assert.isEqual
local N = Assert.isNil

local suite = Misc.newModule()

suite.testIsDigit = function()
  T(isDigit('0'))
  T(isDigit('1'))
  T(isDigit('9'))
  F(isDigit('a'))
  F(isDigit(' '))
  F(isDigit('+'))
  F(isDigit('01'))
  F(isDigit(''))
  -- TODO: implement
  -- Assert.eachTrue(LexerHelp.isDigit, {'0', '1', '9'})
  -- Assert.eachFalse(LexerHelp.isDigit, {'a', ' ', '+', '01', ''})
  -- Assert.isFalse(isDigit())
end

suite.testIsLetter = function()
  T(isLetter('a'))
  T(isLetter('b'))
  T(isLetter('z'))
  F(isLetter('1'))
  F(isLetter('_'))
  F(isLetter(' '))
  F(isLetter('abc'))
  F(isLetter(''))
  F(isLetter())
end

suite.testNthChar = function()
  local s = 'abc'
  E(nthChar(s, 1), 'a')
  E(nthChar(s, 2), 'b')
  E(nthChar(s, 3), 'c')
  N(nthChar(s, 4))
  N(nthChar(s, -1))
end

suite.testIsNumber = function()
  T(isNumber('11'))
  T(isNumber('1'))
  F(isNumber('11f'))
  F(isNumber('a'))
  F(isNumber(''))
  F(isNumber())
end

suite.testIsLetterOrUnderscore = function()
  T(isLetterOrUnderscore('a'))
  T(isLetterOrUnderscore('_'))
  F(isLetterOrUnderscore('aa'))
  F(isLetterOrUnderscore('a1'))
  F(isLetterOrUnderscore('1'))
  F(isLetterOrUnderscore('11'))
  F(isLetterOrUnderscore(' '))
  F(isLetterOrUnderscore(' _'))
  F(isLetterOrUnderscore(''))
  F(isLetterOrUnderscore())
end

suite.testIsName = function()
  T(isName('a'))
  T(isName('abc'))
  T(isName('abc1'))
  F(isName('a b'))
  F(isName('ab$'))
  F(isName('a%$'))
  F(isName('_ '))
  F(isName('ab '))
end

suite.testIsNameOrNumber = function()
  T(isNameOrNumber('a'))
  T(isNameOrNumber('abc'))
  T(isNameOrNumber('ab_c'))
  T(isNameOrNumber('0'))
  T(isNameOrNumber('1'))
  T(isNameOrNumber('10'))
  T(isNameOrNumber('abc10'))
  T(isNameOrNumber('abc_10'))
  T(isNameOrNumber('abc_10_'))
  F(isNameOrNumber('10a'))
  F(isNameOrNumber(' '))
  F(isNameOrNumber(''))
  F(isNameOrNumber())
end

return suite
