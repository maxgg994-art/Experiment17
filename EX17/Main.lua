-- Main.lua
-- Experiment17 v5.3 - All-in-One Loader
-- Сервисы встроены прямо в Main, модули загружаются через HTTP

-- ========================================
-- СЕРВИСЫ (встроены)
-- ========================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")
local PathfindingService = game:GetService("PathfindingService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TextChatService = game:GetService("TextChatService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()
local playerGui = player:WaitForChild("PlayerGui")
local isMobile = UserInputService.TouchEnabled

-- ========================================
-- РАСЧЁТ МАСШТАБА
-- ========================================
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
    isMobile = isMobile,
}

print("=" .. string.rep("=", 50))
print("Experiment17 v5.3 - Initializing...")
print("Screen: " .. math.floor(screenWidth) .. "x" .. math.floor(screenHeight))
print("Scale: " .. string.format("%.2f", guiScale))
print("Mobile: " .. tostring(isMobile))
print("=" .. string.rep("=", 50))

-- ========================================
-- ФУНКЦИЯ ЗАГРУЗКИ МОДУЛЕЙ
-- ========================================
local function fetchModule(url)
    local success, data = pcall(game.HttpGet, game, url)
    if not success then
        warn("[EX17] Download failed: " .. url)
        return nil
    end
    
    local fn, err = loadstring(data)
    if not fn then
        warn("[EX17] Parse error: " .. url .. " - " .. err)
        return nil
    end
    
    local ok, mod = pcall(fn)
    if not ok then
        warn("[EX17] Execute error: " .. url .. " - " .. tostring(mod))
        return nil
    end
    
    return mod
end

-- ========================================
-- БАЗОВЫЙ URL
-- ========================================
local BASE = "https://raw.githubusercontent.com/maxgg994-art/Experiment17/refs/heads/main/EX17/"

print("[EX17] Loading modules...")

-- ========================================
-- ЗАГРУЗКА МОДУЛЕЙ
-- ========================================
local State = fetchModule(BASE .. "Core/State.lua")
if State and State.init then State.init() end

local Utils = fetchModule(BASE .. "Core/Utils.lua")
local NotificationManager = fetchModule(BASE .. "Managers/NotificationManager.lua")
local GUIManager = fetchModule(BASE .. "Managers/GUIManager.lua")
local ESPManager = fetchModule(BASE .. "Managers/ESPManager.lua")
local WorldManager = fetchModule(BASE .. "Managers/WorldManager.lua")
local AimbotManager = fetchModule(BASE .. "Managers/AimbotManager.lua")
local FarmManager = fetchModule(BASE .. "Managers/FarmManager.lua")
local InputManager = fetchModule(BASE .. "Managers/InputManager.lua")
local MusicManager = fetchModule(BASE .. "Managers/MusicManager.lua")
local ColorPicker = fetchModule(BASE .. "Managers/ColorPicker.lua")
local Heartbeat = fetchModule(BASE .. "Features/Heartbeat.lua")
local Stepped = fetchModule(BASE .. "Features/Stepped.lua")
local Panic = fetchModule(BASE .. "Features/Panic.lua")
local SwitchContent = fetchModule(BASE .. "Tabs/SwitchContent.lua")

print("[EX17] All modules loaded!")

-- ========================================
-- БЫСТРАЯ ФУНКЦИЯ НОТИФИКАЦИЙ (если модуль не загрузился)
-- ========================================
local function quickNotify(text, color)
    local gui = playerGui:FindFirstChild("Experiment17") or playerGui
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 280, 0, 24)
    label.Position = UDim2.new(1, -290, 1, -36)
    label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    label.BackgroundTransparency = 0.3
    label.Text = text
    label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Oswald
    label.TextSize = 13
    label.ZIndex = 300
    label.Parent = gui
    task.delay(3, function() pcall(function() label:Destroy() end) end)
end

-- ========================================
-- ИНИЦИАЛИЗАЦИЯ
-- ========================================
if GUIManager and GUIManager.create then
    GUIManager.create()
end

if InputManager and InputManager.init then
    InputManager.init()
end

if SwitchContent and SwitchContent.init then
    SwitchContent.init()
    SwitchContent.switch("Legit")
end

if WorldManager and WorldManager.readCurrentSettings then
    WorldManager.readCurrentSettings()
    WorldManager.applyWorldSettings()
end

if Heartbeat and Heartbeat.start then
    Heartbeat.start()
end

if Stepped and Stepped.start then
    Stepped.start()
end

-- ========================================
-- ГОТОВО
-- ========================================
quickNotify("Experiment17 loaded! RightShift - GUI", Color3.fromRGB(0, 255, 0))
print("[EX17] Ready!")
