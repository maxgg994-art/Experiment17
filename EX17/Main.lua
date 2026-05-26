-- Main.lua
-- Experiment17 v5.3 - Точка входа с поддержкой loadstring

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
-- ФУНКЦИЯ ДЛЯ ПОЛУЧЕНИЯ КОДА ИЗ RAW
-- ========================================
local function fetchModule(path)
    local url = "https://raw.githubusercontent.com/maxgg994-art/Experiment17/refs/heads/main/EX17/" .. path
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if not success then
        warn("[Experiment17] Failed to download: " .. url)
        return nil
    end
    
    local func, err = loadstring(result)
    if not func then
        warn("[Experiment17] Failed to parse: " .. path .. " | Error: " .. tostring(err))
        return nil
    end
    
    local ok, module = pcall(func)
    if not ok then
        warn("[Experiment17] Failed to execute: " .. path .. " | Error: " .. tostring(module))
        return nil
    end
    
    return module
end

-- ========================================
-- ЗАГРУЗКА МОДУЛЕЙ
-- ========================================
print("[Experiment17] Loading modules...")

local Services = fetchModule("Core/Services.lua")
if not Services then error("Failed to load Services") end
Services.init()

local State = fetchModule("Core/State.lua")
if not State then error("Failed to load State") end
State.init()

local Utils = fetchModule("Core/Utils.lua")
if not Utils then error("Failed to load Utils") end

-- Менеджеры
local NotificationManager = fetchModule("Managers/NotificationManager.lua")
if not NotificationManager then error("Failed to load NotificationManager") end

local GUIManager = fetchModule("Managers/GUIManager.lua")
if not GUIManager then error("Failed to load GUIManager") end

local UIFactory = fetchModule("Managers/UIFactory.lua")
if not UIFactory then error("Failed to load UIFactory") end

local ESPManager = fetchModule("Managers/ESPManager.lua")
if not ESPManager then error("Failed to load ESPManager") end

local WorldManager = fetchModule("Managers/WorldManager.lua")
if not WorldManager then error("Failed to load WorldManager") end

local AimbotManager = fetchModule("Managers/AimbotManager.lua")
if not AimbotManager then error("Failed to load AimbotManager") end

local FarmManager = fetchModule("Managers/FarmManager.lua")
if not FarmManager then error("Failed to load FarmManager") end

local InputManager = fetchModule("Managers/InputManager.lua")
if not InputManager then error("Failed to load InputManager") end

local MusicManager = fetchModule("Managers/MusicManager.lua")
if not MusicManager then error("Failed to load MusicManager") end

local ColorPicker = fetchModule("Managers/ColorPicker.lua")
if not ColorPicker then error("Failed to load ColorPicker") end

-- Функции
local Heartbeat = fetchModule("Features/Heartbeat.lua")
if not Heartbeat then error("Failed to load Heartbeat") end

local Stepped = fetchModule("Features/Stepped.lua")
if not Stepped then error("Failed to load Stepped") end

local Panic = fetchModule("Features/Panic.lua")
if not Panic then error("Failed to load Panic") end

-- Вкладки
local SwitchContent = fetchModule("Tabs/SwitchContent.lua")
if not SwitchContent then error("Failed to load SwitchContent") end

print("[Experiment17] All modules loaded!")

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

-- ========================================
-- ЗАГРУЗКА ЗАВЕРШЕНА
-- ========================================
Utils.lockMouse()
Utils.updateNPCList(State.npcList)

NotificationManager.show("Experiment17 loaded! RightShift - GUI", Color3.fromRGB(0, 255, 0))

print("=" .. string.rep("=", 50))
print("Experiment17 v5.3 - Ready!")
print("Modules: 14 | Features: 11 tabs | 200+ controls")
print("Mobile: " .. tostring(_G.Experiment17.isMobile))
print("=" .. string.rep("=", 50))
