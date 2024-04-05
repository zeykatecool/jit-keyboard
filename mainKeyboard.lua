--[[

    Keyboard Module for Lua
    Lua Versions : LuaJIT,Luvit
    Dependencies:
    keys.lua,FFI
    
]]
---@version JIT

local FFI = require("ffi")
local C = FFI.C
local KeysController = require("keys")
local keytonumber = KeysController.keytonumber
local numbertokey = KeysController.numbertokey
local keys = KeysController.keys

local Keyboard = {}
Keyboard.__index = Keyboard


---Get the `keys` table.
---@return table
Keyboard.keys = keys

FFI.cdef[[
    int GetAsyncKeyState(int vKey);
    void keybd_event (int key, int scan, int flags, int exittime);
    void mouse_event (int dwFlags, int dx, int dy, int dwData, int dwExtraInfo);
]]


local function isKeyPressed(key)
    return FFI.C.GetAsyncKeyState(key) ~= 0
end

local function isKeyReleased(key)
    return not isKeyPressed(key)
end


---Create a new `Keyboard` instance.
---@return self
function Keyboard:new()
    self = setmetatable({}, Keyboard)
    self.pressing_keys = {}
    self.key_holding_time = {}
    return self
end

---Set the callback function when a key is `pressed`.
---@param callback function
function Keyboard:onPressed(callback)
    self.onPressedCallback = callback
end

---Set the callback function when a key is `released`.
---@param callback function
function Keyboard:onReleased(callback)
    self.onReleasedCallback = callback
end

---Check if a key is `pressing`.
---@param key string
function Keyboard:isPressing(key)
    if keytonumber[key] ~= nil then
       local sa = keytonumber[key]
        return isKeyPressed(sa)
    else
        return nil
    end
end


---Check if a key is `released`.
---@param key string
function Keyboard:isReleased(key)
    return not self:isPressing(key)
end


---Simulate a `key` press.
---@param tbl table|string
---@return true|nil
function Keyboard:SimulateKeyPress(tbl)
    if type(tbl) ~= "table" then
        if type(tbl) == "string" then
            tbl = {key = tbl}
        end
    end
    if tbl.key == nil then
        return nil
    end
    if type(tbl.scan) ~= "number" then
        tbl.scan = 0
    end
    if type(tbl.flags) ~= "number" then
        tbl.flags = 0
    end
    if type(tbl.exittime) ~= "number" then
        tbl.exittime = 0
    end

    if tbl.scan == nil then
        tbl.scan = 0
    end
    if tbl.flags == nil then
        tbl.flags = 0
    end
    if tbl.exittime == nil then
        tbl.exittime = 0
    end
    if keytonumber[tbl.key] ~= nil then
        tbl.key = tbl.key:upper()
        tbl.key = keytonumber[tbl.key]
    else
        return nil
    end
    if numbertokey[tbl.key] == "LMB" then
        FFI.C.mouse_event(0x0002, 0, 0, 0, 0) --Holding 
        FFI.C.mouse_event(0x0004, 0, 0, 0, 0) --Releasing
        return true
    elseif numbertokey[tbl.key] == "RMB" then
        FFI.C.mouse_event(0x0008, 0, 0, 0, 0) --Holding 
        FFI.C.mouse_event(0x0010, 0, 0, 0, 0) --Releasing
        return true
    elseif numbertokey[tbl.key] == "MMB" then
        FFI.C.mouse_event(0x0020, 0, 0, 0, 0) --Holding 
        FFI.C.mouse_event(0x0040, 0, 0, 0, 0) --Releasing
        return true
    end
    FFI.C.keybd_event(tbl.key, tbl.scan, tbl.flags, tbl.exittime)
    return true
end



---Update the `Keyboard` state.
---@return nil
function Keyboard:update()
    while true do
    for key = 1, 255 do
        if isKeyReleased(key) then
            if numbertokey[key] ~= nil then
            if self.pressing_keys[key] then
                self.pressing_keys[key] = false
                if self.onReleasedCallback then
                    self.onReleasedCallback(numbertokey[key], os.clock() - self.key_holding_time[key])
                end
            end
            end
        end

        if isKeyPressed(key) then
            if numbertokey[key] ~= nil then
            if not self.pressing_keys[key] then
                self.pressing_keys[key] = true
                self.key_holding_time[key] = os.clock()
                if self.onPressedCallback then
                    self.onPressedCallback(numbertokey[key])
                end
                end
            end
        end
    end
end
end


---Test the `Keyboard`.
---@return boolean|nil
function Keyboard:test()
    local success, failure = xpcall(function ()
        print("Simulating LMB.")
        self:SimulateKeyPress("LMB")
        print("Simulating RMB.")
        self:SimulateKeyPress("RMB")
        print("Simulating MMB.")
        self:SimulateKeyPress("MMB")
        print("Simulating A.")
        self:SimulateKeyPress("A")
        print("Simulating Arrow Down.")
        self:SimulateKeyPress("DOWN")

        print("Is LMB pressing?")
        print(self:isPressing("LMB"))
        print("Is RMB pressing?")
        print(self:isPressing("RMB"))
        print("Is MMB pressing?")
        print(self:isPressing("MMB"))

        print("Is A released?")
        print(self:isReleased("A"))

        print("Test passed.")
    end, debug.traceback)
    if not success then
        print("Keyboard test failed:\n" .. failure)
        return false
    end
    if success then
        print("Keyboard test passed")
        return true
    end
end





return Keyboard