local mainKeyboard = require("mainKeyboard")
local Keyboard = mainKeyboard:new()

Keyboard:onPressed(function(key)
  if key == "C" then
    if Keyboard:isPressing("CTRL") then
      print("Leaving..")
    end
  end
  if key == "A" then
    if Keyboard:isPressing("CTRL") then
      print("CTRL+A")
    end
  end
end)

while true do
  Keyboard:update()
end
