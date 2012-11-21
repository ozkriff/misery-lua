-- See LICENSE file for copyright and license details

local Misc = require('misc')
local Lexer = require('lexer')

local lexer = Lexer.new('in.riff')
while not lexer:isEndOfFile() do
  io.write(
      Misc.dump(lexer:lexem()),
      '    -->    ',
      Misc.dump(lexer:peekNextLexem()),
      '\n')
  -- io.write(
  --     Misc.dump(lexer:lexem()))
  lexer:next()
end
io.write('DONE!\n')
