-- See LICENSE file for copyright and license details

local Misc = require('misc')

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
  lexer:eat{tag = 'space'}
  fieldNode.type = lexer:lexem().value
  lexer:next()
  lexer:eat{tag = 'endOfLine'}
  return fieldNode
end

local parseTypeDeclaration = function(lexer)
  local typeDeclarationNode = {}
  typeDeclarationNode.tag = 'typeDeclaration'
  lexer:eat{tag = 'type'}
  lexer:eat{tag = 'space'}
  typeDeclarationNode.name = lexer:lexem().value
  lexer:next()
  lexer:eat{tag = 'space'}
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


local parseFuncDeclaration = function(lexer)
  local funcDeclarationNode = {}
  funcDeclarationNode.tag = 'functionDeclaration'
  lexer:next()
  lexer:eat{tag = 'space'}
  assert(lexer:lexem().tag == 'name')
  funcDeclarationNode.name = lexer:lexem().value
  lexer:next()
  lexer:eat{tag = '('}

  -- parameters
  funcDeclarationNode.parameters = {}
  -- сейчас точно должен быть аргумент
  local argExpected = false
  while lexer:lexem().tag ~= ')' do
    -- print('{'..lexer:lexem().tag..'}')
    local argNode = {}

    if argExpected
      and lexer:lexem().type ~= 'name'
      then
        -- func x(arg1 Int,) ??
        assert(false)
      end

      argNode.name = lexer:lexem().value
      lexer:next()
      lexer:eat{tag = 'space'}
      argNode.type = lexer:lexem().value
      lexer:next()
      table.insert(funcDeclarationNode.parameters, argNode)

      if lexer:lexem().tag == ',' then
        lexer:eat{tag = ','}
        lexer:eat{tag = 'space'}
      end
    end

    lexer:eat{tag = ')'}

    funcDeclarationNode.returnValue = {}

    -- return value
    if lexer:lexem().tag == 'space' then
      lexer:eat{tag = 'space'}
      local returnValueNode = {}
      returnValueNode.type = lexer:lexem().value
      table.insert(funcDeclarationNode.returnValue, returnValueNode)
      lexer:next()
    end

    lexer:eat{tag = ':'}
    lexer:eat{tag = 'endOfLine'}
    lexer:eat{tag = 'incIndent'}

    funcDeclarationNode.body = {}
    while lexer:lexem().tag ~= 'decIndent' do
      -- print('{'..lexer:lexem().tag..'}')
      if lexer:lexem().tag == 'var' then
        lexer:eat{tag = 'var'}
        lexer:eat{tag = 'space'}
        local varNode = {}
        varNode.tag = 'variableDeclaration'
        varNode.name = lexer:lexem().value
        lexer:next()
        lexer:eat{tag = 'space'}
        varNode.type = lexer:lexem().value
        lexer:next()
        lexer:eat{tag = 'endOfLine'}
        table.insert(funcDeclarationNode.body, varNode)
      end
      if lexer:lexem().tag == 'name' then
        local callNode = {}
        callNode.tag = 'functionCall'
        callNode.name = lexer:lexem().value
        lexer:next()
        lexer:eat{tag = '('}
        -- TODO: parameters
        callNode.parameters = {}
        local isArgRequired = false
        while lexer:lexem().tag ~= ')' do
          local argNode = {}

          if isArgRequired
            and lexer:lexem().tag ~= 'name'
            then
              assert(false)
            end

            argNode.name = lexer:lexem().value
            table.insert(callNode.parameters, argNode)

            lexer:next()
            if lexer:lexem().tag == ',' then
              lexer:eat{tag = ','}
              lexer:eat{tag = 'space'}
              isArgRequired = true
            end

          end
          lexer:eat{tag = ')'}
          lexer:eat{tag = 'endOfLine'}
          table.insert(funcDeclarationNode.body, callNode)
        end
      end
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
