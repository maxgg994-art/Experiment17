-- Main.lua
-- Experiment17 v5.3 - All-in-One Loader
-- ВСЕ модули в одном файле, работает через loadstring без доп. файлов

-- ========================================
-- РАСЧЁТ МАСШТАБА
-- ========================================
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
print("Screen: " .. math.floor(screenWidth) .. "x" .. math.floor(screenHeight))
print("Scale: " .. string.format("%.2f", guiScale))
print("=" .. string.rep("=", 50))

-- ========================================
-- ЗАГРУЗКА МОДУЛЕЙ С ПРОВЕРКОЙ
-- ========================================
local function loadModule(url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if not success then
        warn("Download failed: " .. url)
        return nil
    end
    
    local f, err = loadstring(result)
    if not f then
        warn("Parse failed: " .. url .. " - " .. err)
        return nil
    end
    
    local ok, mod = pcall(f)
    if not ok then
        warn("Execute failed: " .. url .. " - " .. tostring(mod))
        return nil
    end
    
    if type(mod) ~= "table" then
        warn("Module returned non-table: " .. url .. " - " .. type(mod))
        return nil
    end
    
    return mod
end

local BASE = "https://raw.githubusercontent.com/maxgg994-art/Experiment17/refs/heads/main/EX17/"

print("Loading modules...")

local Services = loadModule(BASE .. "Core/Services.lua")
Services.init()

local State = loadModule(BASE .. "Core/State.lua")
State.init()

local Utils = loadModule(BASE .. "Core/Utils.lua")

local NotificationManager = loadModule(BASE .. "Managers/NotificationManager.lua")
local GUIManager = loadModule(BASE .. "Managers/GUIManager.lua")
local ESPManager = loadModule(BASE .. "Managers/ESPManager.lua")
local WorldManager = loadModule(BASE .. "Managers/WorldManager.lua")
local AimbotManager = loadModule(BASE .. "Managers/AimbotManager.lua")
local FarmManager = loadModule(BASE .. "Managers/FarmManager.lua")
local InputManager = loadModule(BASE .. "Managers/InputManager.lua")
local MusicManager = loadModule(BASE .. "Managers/MusicManager.lua")
local ColorPicker = loadModule(BASE .. "Managers/ColorPicker.lua")
local Heartbeat = loadModule(BASE .. "Features/Heartbeat.lua")
local Stepped = loadModule(BASE .. "Features/Stepped.lua")
local Panic = loadModule(BASE .. "Features/Panic.lua")
local SwitchContent = loadModule(BASE .. "Tabs/SwitchContent.lua")

print("All modules loaded!")

-- ========================================
-- ИНИЦИАЛИЗАЦИЯ
-- ========================================
GUIManager.create()
InputManager.init()
SwitchContent.init()
WorldManager.readCurrentSettings()
WorldManager.applyWorldSettings()
SwitchContent.switch("Legit")
Heartbeat.start()
Stepped.start()

Utils.lockMouse()
Utils.updateNPCList(State.npcList)
NotificationManager.show("Experiment17 loaded! RightShift - GUI", Color3.fromRGB(0, 255, 0))

print("=" .. string.rep("=", 50))
print("Experiment17 v5.3 - Ready!")
print("=" .. string.rep("=", 50))
