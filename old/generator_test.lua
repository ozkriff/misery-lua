-- See LICENSE file for copyright and license details

local Misc = require('misc')

local generateFunctionHeader = function(outFile, node)
  outFile:write('void ', node.name, '(')
  for index, parameterNode in ipairs(node.parameters) do
    outFile:write(parameterNode.type, ' ', parameterNode.name)
    if index ~= #node.parameters then
      outFile:write(', ')
    end
  end
  outFile:write(') {\n')
end

local generateFunctionCall = function(outFile, node)
  outFile:write('  ', node.name, '(')
  if node.parameters then
    for index, parameterNode in ipairs(node.parameters) do
      outFile:write(parameterNode.name)
      if index ~= #node.parameters then
        outFile:write(', ')
      end
    end
  end
  outFile:write(');\n')
end

local generateVariableDeclaration = function(outFile, node)
  assert(node.type ~= nil)
  assert(node.name ~= nil)
  outFile:write('  ', node.type, ' ', node.name, ';\n')
end

local generateFunctionBody = function(outFile, node)
  if node.tag == 'variableDeclaration' then
    generateVariableDeclaration(outFile, node)
  elseif node.tag == 'functionCall' then
    generateFunctionCall(outFile, node)
  end
end

local generateFunctionDeclaration = function(outFile, node)
  generateFunctionHeader(outFile, node)
  for _, bodyNode in ipairs(node.body) do
    generateFunctionBody(outFile, bodyNode)
  end
  outFile:write('}\n')
  outFile:write('\n')
end

local generateCIncludes = function(outFile)
  outFile:write('#include <stdio.h>\n')
end

local generateMainFunction = function(outFile, node)
  -- outFile:write('int main(void) {\n')
  outFile:write('int main(int argc, char *argv[]) {\n')
  for _, bodyNode in ipairs(node.body) do
    generateFunctionBody(outFile, bodyNode)
  end
  outFile:write('  return 0;\n')
  outFile:write('}\n')
end

local generateTypeDeclartion = function(outFile, node)
  outFile:write('typedef struct {\n')
  for _, fieldNode in ipairs(node.fields) do
    outFile:write(
        '  ', fieldNode.type, ' ', fieldNode.name, ';\n')
  end
  outFile:write('} ', node.name, ';\n')
  outFile:write('\n')
end

local generateTypeAlias = function(outFile, node)
  outFile:write(
      'typedef ', node.newName, ' ', node.originalName, ';\n')
  outFile:write('\n')
end

local generateCodeForASTNode = function(outFile, node)
  if node.tag == 'functionDeclaration' then
    generateFunctionDeclaration(outFile, node)
  elseif node.tag == 'typeDeclaration' then
    generateTypeDeclartion(outFile, node)
  elseif node.tag == 'typeAlias' then
    generateTypeAlias(outFile, node)
  elseif node.tag == 'main' then
    generateMainFunction(outFile, node)
  end
end

local generate = function(outFileName, abstractSyntaxTree)
  local outFile = io.open(outFileName, 'w')
  generateCIncludes(outFile)
  outFile:write('\n')
  for _, node in ipairs(abstractSyntaxTree) do
    generateCodeForASTNode(outFile, node)
  end
  outFile:close()
end

local abstractSyntaxTree = {
  {
    tag = 'typeAlias',
    originalName = 'Type1',
    newName = 'int',
  },
  {
    tag = 'typeDeclaration',
    name = 'Type2',
    fields = {
      {name = 'field1', type = 'float'},
      {name = 'field2', type = 'int'},
    },
  },
  {
    tag = 'functionDeclaration',
    name = 'func1',
    parameters = {
      {name = 'parameter1', type = 'Type1'},
      {name = 'parameter2', type = 'Type1'},
    },
    body = {
      {
        tag = 'variableDeclaration',
        name = 'variable1',
        type = 'Type1',
	value = '3'
      },
      {
        tag = 'functionCall',
        name = 'someUselessFunction',
        parameters = {
          {
            tag = 'variable',
            name = 'parameter1',
            type = 'Type1'
          },
        },
      },
    }, -- body
  }, -- functionDeclaration
  {
    tag = 'main',
    body = {
      {
        tag = 'functionCall',
        name = 'func1',
        parameters = {
          {
            tag = 'variable',
            name = 'parameter1',
            type = 'Type1'
          },
        },
      },
      {
        tag = 'functionCall',
        name = 'puts',
        parameters = {
          {
            tag = 'constant',
            name = '\"kill me\"',
            type = 'string',
          },
        },
      },
    }, -- body
  }, -- main
}

generate('out.c', abstractSyntaxTree)
