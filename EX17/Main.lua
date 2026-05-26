-- Main.lua
-- Experiment17 v5.3 - All-in-One Loader (прямые ссылки)

local camera = workspace.CurrentCamera
local viewport = camera.ViewportSize
local screenWidth = viewport.X
local screenHeight = viewport.Y

local guiScale = math.clamp(screenWidth / 1920, 0.6, 1.4)
if screenWidth < 1000 then
    guiScale = math.clamp(screenWidth / 900, 0.55, 1.1)
end

_G.Experiment17 = {
    guiScale = guiScale,
    screenWidth = screenWidth,
    screenHeight = screenHeight,
    isMobile = false,
}

print("=" .. string.rep("=", 50))
print("Experiment17 v5.3 - Initializing...")
print("=" .. string.rep("=", 50))

local function fetch(url)
    local ok, data = pcall(game.HttpGet, game, url)
    if not ok then error("Download failed: " .. url) end
    local fn, err = loadstring(data)
    if not fn then error("Parse error: " .. err) end
    local ok2, mod = pcall(fn)
    if not ok2 then error("Execute error: " .. tostring(mod)) end
    return mod
end

-- Все модули с прямыми raw URL
local Services     = fetch("https://raw.githubusercontent.com/maxgg994-art/Experiment17/refs/heads/main/EX17/Core/Services.lua")
local State        = fetch("https://raw.githubusercontent.com/maxgg994-art/Experiment17/refs/heads/main/EX17/Core/State.lua")
local Utils        = fetch("https://raw.githubusercontent.com/maxgg994-art/Experiment17/refs/heads/main/EX17/Core/Utils.lua")
local Notification = fetch("https://raw.githubusercontent.com/maxgg994-art/Experiment17/refs/heads/main/EX17/Managers/NotificationManager.lua")
local GUI          = fetch("https://raw.githubusercontent.com/maxgg994-art/Experiment17/refs/heads/main/EX17/Managers/GUIManager.lua")
local ESP          = fetch("https://raw.githubusercontent.com/maxgg994-art/Experiment17/refs/heads/main/EX17/Managers/ESPManager.lua")
local World        = fetch("https://raw.githubusercontent.com/maxgg994-art/Experiment17/refs/heads/main/EX17/Managers/WorldManager.lua")
local Aimbot       = fetch("https://raw.githubusercontent.com/maxgg994-art/Experiment17/refs/heads/main/EX17/Managers/AimbotManager.lua")
local Farm         = fetch("https://raw.githubusercontent.com/maxgg994-art/Experiment17/refs/heads/main/EX17/Managers/FarmManager.lua")
local Input        = fetch("https://raw.githubusercontent.com/maxgg994-art/Experiment17/refs/heads/main/EX17/Managers/InputManager.lua")
local Music        = fetch("https://raw.githubusercontent.com/maxgg994-art/Experiment17/refs/heads/main/EX17/Managers/MusicManager.lua")
local ColorPicker  = fetch("https://raw.githubusercontent.com/maxgg994-art/Experiment17/refs/heads/main/EX17/Managers/ColorPicker.lua")
local Heartbeat    = fetch("https://raw.githubusercontent.com/maxgg994-art/Experiment17/refs/heads/main/EX17/Features/Heartbeat.lua")
local Stepped      = fetch("https://raw.githubusercontent.com/maxgg994-art/Experiment17/refs/heads/main/EX17/Features/Stepped.lua")
local Panic        = fetch("https://raw.githubusercontent.com/maxgg994-art/Experiment17/refs/heads/main/EX17/Features/Panic.lua")
local Switch       = fetch("https://raw.githubusercontent.com/maxgg994-art/Experiment17/refs/heads/main/EX17/Tabs/SwitchContent.lua")

print("All 14 modules loaded!")

Services.init()
State.init()
GUI.create()
Input.init()
Switch.init()
World.readCurrentSettings()
World.applyWorldSettings()
Switch.switch("Legit")
Heartbeat.start()
Stepped.start()
Utils.lockMouse()
Utils.updateNPCList(State.npcList)
Notification.show("Experiment17 loaded! RightShift - GUI", Color3.fromRGB(0, 255, 0))

print("Ready!")
