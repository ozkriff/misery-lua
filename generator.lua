-- See LICENSE file for copyright and license details

local Misc = require('misc')

local M = Misc.newType()

local generateFunctionHeader = function(node)
  local out = ''
  if #node.returnValue == 0 then
    out = out .. 'void '
  else
    out = out .. node.returnValue[1].type .. ' '
  end
  out = out  .. node.name .. '('
  for index, parameterNode in ipairs(node.parameters) do
    out = out .. parameterNode.type
    out = out .. ' ' .. parameterNode.name
    -- if not last parameter
    if index ~= #node.parameters then
      out = out .. ', '
    end
  end
  out = out .. ') {\n'
  return out
end

local generateFunctionCall = function(node)
  local out = '  ' .. node.name ..'('
  if node.parameters then
    for index, parameterNode in ipairs(node.parameters) do
      out = out .. parameterNode.name
      -- if not last parameter
      if index ~= #node.parameters then
        out = out .. ', '
      end
    end
  end
  out = out .. ');\n'
  return out
end

local generateVariableDeclaration = function(node)
  assert(node.type ~= nil)
  assert(node.name ~= nil)
  local out = '  ' .. node.type .. ' ' .. node.name .. ';\n'
  return out
end

local generateFunctionBody = function(node)
  local out = ''
  if node.tag == 'variableDeclaration' then
    out = out .. generateVariableDeclaration(node)
  elseif node.tag == 'functionCall' then
    out = out .. generateFunctionCall(node)
  end
  return out
end

local generateFunctionDeclaration = function(node)
  local out = generateFunctionHeader(node)
  for _, bodyNode in ipairs(node.body) do
    out = out .. generateFunctionBody(bodyNode)
  end
  out = out .. '}\n'
  return out
end

M.generateStandartIncludes = function()
  local out = ''
  out = out .. '#include <stdio.h>\n'
  return out
end

M.generateStandartTypedefs = function()
  local out = ''
  out = out .. 'typedef int Int;\n'
  out = out .. 'typedef float Float;\n'
  return out
end

local generateTypeDeclartion = function(node)
  local out = 'typedef struct {\n'
  for _, fieldNode in ipairs(node.fields) do
    out = out ..
        '  ' ..
        fieldNode.type ..
        ' ' ..
        fieldNode.name ..
        ';\n'
  end
  out = out ..
      '} ' ..
      node.name ..
      ';\n'
  return out
end

local generateTypeAlias = function(node)
  local out =
    'typedef ' ..
    node.newName ..
    ' ' ..
    node.originalName ..
    ';\n' ..
    '\n'
  return out
end

local generateCodeForASTNode = function(node)
  if node.tag == 'functionDeclaration' then
    return generateFunctionDeclaration(node)
  elseif node.tag == 'typeDeclaration' then
    return generateTypeDeclartion(node)
  elseif node.tag == 'typeAlias' then
    return generateTypeAlias(node)
  end
end

M.generate = function(abstractSyntaxTree)
  local out = ''
  for _, node in ipairs(abstractSyntaxTree) do
    out = out .. generateCodeForASTNode(node)
  end
  return out
end

return M

