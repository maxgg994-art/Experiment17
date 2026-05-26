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
local function fetchModule(url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if success then
        return loadstring(result)()
    else
        warn("Failed to load: " .. url)
        return nil
    end
end

-- ========================================
-- БАЗОВЫЙ URL ДЛЯ RAW ФАЙЛОВ
-- ========================================
local BASE_URL = "https://raw.githubusercontent.com/THEMIKEMAN201/Experiment17/main/"

-- ========================================
-- ЗАГРУЗКА МОДУЛЕЙ ЧЕРЕЗ LOADSTRING
-- ========================================
local Services = fetchModule(BASE_URL .. "Core/Services.lua") or require(script.Core.Services)
Services.init()

local State = fetchModule(BASE_URL .. "Core/State.lua") or require(script.Core.State)
State.init()

local Utils = fetchModule(BASE_URL .. "Core/Utils.lua") or require(script.Core.Utils)

-- Менеджеры
local NotificationManager = fetchModule(BASE_URL .. "Managers/NotificationManager.lua") or require(script.Managers.NotificationManager)
local GUIManager = fetchModule(BASE_URL .. "Managers/GUIManager.lua") or require(script.Managers.GUIManager)
local ESPManager = fetchModule(BASE_URL .. "Managers/ESPManager.lua") or require(script.Managers.ESPManager)
local WorldManager = fetchModule(BASE_URL .. "Managers/WorldManager.lua") or require(script.Managers.WorldManager)
local AimbotManager = fetchModule(BASE_URL .. "Managers/AimbotManager.lua") or require(script.Managers.AimbotManager)
local FarmManager = fetchModule(BASE_URL .. "Managers/FarmManager.lua") or require(script.Managers.FarmManager)
local InputManager = fetchModule(BASE_URL .. "Managers/InputManager.lua") or require(script.Managers.InputManager)
local MusicManager = fetchModule(BASE_URL .. "Managers/MusicManager.lua") or require(script.Managers.MusicManager)
local ColorPicker = fetchModule(BASE_URL .. "Managers/ColorPicker.lua") or require(script.Managers.ColorPicker)

-- Функции
local Heartbeat = fetchModule(BASE_URL .. "Features/Heartbeat.lua") or require(script.Features.Heartbeat)
local Stepped = fetchModule(BASE_URL .. "Features/Stepped.lua") or require(script.Features.Stepped)
local Panic = fetchModule(BASE_URL .. "Features/Panic.lua") or require(script.Features.Panic)

-- Вкладки
local SwitchContent = fetchModule(BASE_URL .. "Tabs/SwitchContent.lua") or require(script.Tabs.SwitchContent)

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
