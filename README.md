# jit-keyboard
Keyboard module for LuaJIT and Luvit.

 # Working on Lua
Also you can use with this packages like [cffi-lua](https://github.com/q66/cffi-lua).Just change `ffi` to `cffi` and you are ready to use.

# Dependencies
`FFI`, [keys.lua](https://github.com/zeykatecool/jit-keyboard/blob/main/keys.lua).

# Example of Usage
```lua
local Keyboard = require("mainKeyboard")

local MyKeyboard = Keyboard:new()

local IsWorking = MyKeyboard:test()

if IsWorking then
    print("Working!")
else
    print("Not Working!")
end

local Keys = MyKeyboard.keys

MyKeyboard:onPressed(function(key)
    print("Pressed " .. key.." !")
    if key == "LMB" then
        MyKeyboard:SimulateKeyPress({
            key = "LMB",
        })
        print("Double Click LMB!")
    end
end)

MyKeyboard:onReleased(function(key, timeholded)
    print("Released " .. key.." !")
    print("Timeholded: " .. timeholded)
    if key == Keys.CAPSLOCK then
        print("Caps Lock!")
    end
end)

MyKeyboard:update()
```
