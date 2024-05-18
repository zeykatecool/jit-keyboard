local Keyboard = require("mainKeyboard"):new()

---Char is number
---Input is string
local test = Keyboard:read(function( char,input )
    print(char,input)
end)
print(test)

while true do
    Keyboard:update()
end
