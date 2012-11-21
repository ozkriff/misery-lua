-- See LICENSE file for copyright and license details

-- TODO: Move to misc.lua

function tablePrint(tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == 'table' then
    local sb = {}
    for key, value in pairs(tt) do
      table.insert(sb, string.rep(' ', indent)) -- indent it
      if type(value) == 'table' and not done[value] then
        done [value] = true
        table.insert(sb, '{\n');
        table.insert(sb, tablePrint(value, indent + 2, done))
        table.insert(sb, string.rep(' ', indent)) -- indent it
        table.insert(sb, '}\n');
      elseif 'number' == type(key) then
        table.insert(sb, string.format('\"%s\"\n', tostring(value)))
      else
        table.insert(
            sb, string.format(
                '%s = \"%s\"\n', tostring(key), tostring(value)
            )
        )
      end
    end
    return table.concat(sb)
  else
    return tt .. '\n'
  end
end

local toString = function(table)
  if type(table) == 'nil' then
    return tostring(nil)
  elseif type(table) == 'table' then
    return tablePrint(table)
  elseif type(table) == 'string' then
    return table
  else
    return tostring(table)
  end
end

return toString
