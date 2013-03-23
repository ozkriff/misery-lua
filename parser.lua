-- See LICENSE file for copyright and license details

local Misc = require('misc')
local Assert = require('assert')

local M = Misc.newType()

M.new = function()
  local self = {}
  setmetatable(self, M)
  return self
end

M.setLexer = function(self, lexer)
  assert(lexer)
  self._lexer = lexer
end

local parseTypeField = function(lexer)
  local fieldNode = {}
  fieldNode.name = lexer:lexem().value
  lexer:next()
  lexer:eat{tag = ' '}
  fieldNode.type = lexer:lexem().value
  lexer:next()
  lexer:eat{tag = 'endOfLine'}
  return fieldNode
end

local parseTypeDeclaration = function(lexer)
  local typeDeclarationNode = {}
  typeDeclarationNode.tag = 'typeDeclaration'
  lexer:eat{tag = 'type'}
  lexer:eat{tag = ' '}
  typeDeclarationNode.name = lexer:lexem().value
  lexer:next()
  lexer:eat{tag = ' '}
  lexer:eat{tag = 'struct'}
  lexer:eat{tag = ':'}
  lexer:eat{tag = 'endOfLine'}
  lexer:eat{tag = 'incIndent'}

  typeDeclarationNode.fields = {}
  while lexer:lexem().tag ~= 'decIndent' do
    local fieldNode = parseTypeField(lexer)
    table.insert(typeDeclarationNode.fields, fieldNode)
  end
  return typeDeclarationNode
end

local parseFuncCallParameters = function(lexer)
  local parametersNode = {}
  local isArgRequired = false
  while lexer:lexem().tag ~= ')' do
    local parameterNode = {}
    if isArgRequired and lexer:lexem().tag ~= 'name' then
      assert(false)
    end
    parameterNode.name = lexer:lexem().value
    table.insert(parametersNode, parameterNode)
    lexer:next()
    if lexer:lexem().tag == ',' then
      lexer:eat{tag = ','}
      lexer:eat{tag = ' '}
      isArgRequired = true
    end
  end
  return parametersNode
end

local parseFuncCall = function(lexer)
  local callNode = {}
  callNode.tag = 'functionCall'
  callNode.name = lexer:lexem().value
  lexer:next()
  lexer:eat{tag = '('}
  callNode.parameters = parseFuncCallParameters(lexer)
  lexer:eat{tag = ')'}
  lexer:eat{tag = 'endOfLine'}
  return callNode
end

local parseVarDeclaration = function(lexer)
  local varNode = {}
  lexer:eat{tag = 'var'}
  lexer:eat{tag = ' '}
  varNode.tag = 'variableDeclaration'
  varNode.name = lexer:lexem().value
  lexer:next()
  lexer:eat{tag = ' '}
  varNode.type = lexer:lexem().value
  lexer:next()
  lexer:eat{tag = 'endOfLine'}
  return varNode
end

local parseFuncBody = function(lexer)
  local funcBodyNode = {}
  while lexer:lexem().tag ~= 'decIndent' do
    if lexer:lexem().tag == 'var' then
      local varNode = parseVarDeclaration(lexer)
      table.insert(funcBodyNode, varNode)
    end
    if lexer:lexem().tag == 'name' then
      local callNode = parseFuncCall(lexer)
      table.insert(funcBodyNode, callNode)
    end
  end
  return funcBodyNode
end

local parseFuncParameters = function(lexer)
  local parametersNode = {}
  local parameterExpected = false
  while lexer:lexem().tag ~= ')' do
    local parameterNode = {}
    if parameterExpected and lexer:lexem().type ~= 'name' then
      assert(false) -- func x(parameter1 Int,) ??
    end
    parameterNode.name = lexer:lexem().value
    lexer:next()
    lexer:eat{tag = ' '}
    parameterNode.type = lexer:lexem().value
    lexer:next()
    table.insert(parametersNode, parameterNode)
    if lexer:lexem().tag == ',' then
      lexer:eat{tag = ','}
      lexer:eat{tag = ' '}
    end
  end
  return parametersNode
end

local parseFuncReturnValue = function(lexer)
  lexer:eat{tag = ' '}
  local returnValueNode = {}
  Assert.isEqual(lexer:lexem().tag, 'name')
  returnValueNode.type = lexer:lexem().value
  lexer:next()
  return returnValueNode
end

local parseFuncDeclaration = function(lexer)
  local funcDeclarationNode = {}
  funcDeclarationNode.tag = 'functionDeclaration'
  lexer:next()
  lexer:eat{tag = ' '}
  assert(lexer:lexem().tag == 'name')
  funcDeclarationNode.name = lexer:lexem().value
  lexer:next()
  lexer:eat{tag = '('}
  funcDeclarationNode.parameters = parseFuncParameters(lexer)
  lexer:eat{tag = ')'}
  funcDeclarationNode.returnValue = {}
  if lexer:lexem().tag ~= ':' then
    local returnValueNode = parseFuncReturnValue(lexer)
    table.insert(funcDeclarationNode.returnValue,
        returnValueNode)
  end
  lexer:eat{tag = ':'}
  lexer:eat{tag = 'endOfLine'}
  lexer:eat{tag = 'incIndent'}
  funcDeclarationNode.body = parseFuncBody(lexer)
  return funcDeclarationNode
end

M.parse = function(self)
  local ast = {}
  local lexer = self._lexer
  -- print(Misc.dump(self._lexer))
  -- assert(not lexer:noMoreLexemsLeft())
  while not lexer:noMoreLexemsLeft() do
    if lexer:lexem().tag == 'type' then
      local typeDeclarationNode = parseTypeDeclaration(lexer)
      table.insert(ast, typeDeclarationNode)
    elseif lexer:lexem().tag == 'func' then
      local funcDeclarationNode = parseFuncDeclaration(lexer)
      table.insert(ast, funcDeclarationNode)
    end
    lexer:next()
  end
  return ast
end

return M
