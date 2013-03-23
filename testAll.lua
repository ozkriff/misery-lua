local Misc = require('misc')

local runSuiteOLD = function(suite)
  for name, func in pairs(suite) do
    -- io.write(' test \'' .. name .. '\'')
    -- io.write(string.rep(' ', 30 - #name))
    func()
    -- io.write('[ok]\n')
    -- local status, errmsg = pcall(func)  -- TODO: use xpcall
    -- if status == false then
    --   io.write('[FAIL] : ', errmsg,'\n')
    -- else
    --   io.write('[ok]\n')
    -- end
  end
end

local runSuite = function(suite)
  local badTests = {}
  for name, func in pairs(suite) do
    -- local status = pcall(func)
    func()
    if status == false then
      table.insert(badTests, name)
    end
  end
  if #badTests > 0 then
    io.write('FAILS: ', Misc.dump(badTests), '\n')
  end
end

local loadAndRunSuite = function(suiteName)
  -- io.write('suite \'' .. suiteName .. '\'\n')
  local suite = require(suiteName)
  assert(suite ~= nil)
  -- runSuite(suite)
  runSuiteOLD(suite)
end

local runAllTestSuits = function(suits)
  for _, suiteName in ipairs(suits) do
    loadAndRunSuite(suiteName)
  end
end

local main = function()
  runAllTestSuits {
    'testMisc',
    'testLexerHelp',
    'testLexer',
    'testParser',
    'testGenerator',
  }
end

main()
