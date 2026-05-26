-- Main.lua
-- Experiment17 v5.3 - All-in-One Loader
-- Сервисы передаются глобально, модули не требуют Services.lua
--
-- ========================================
-- СЕРВИСЫ
-- ========================================
local Services = {
    Players = game:GetService("Players"),
    UserInputService = game:GetService("UserInputService"),
    RunService = game:GetService("RunService"),
    TweenService = game:GetService("TweenService"),
    Lighting = game:GetService("Lighting"),
    StarterGui = game:GetService("StarterGui"),
    SoundService = game:GetService("SoundService"),
    PathfindingService = game:GetService("PathfindingService"),
    HttpService = game:GetService("HttpService"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    TextChatService = game:GetService("TextChatService"),
    player = game:GetService("Players").LocalPlayer,
    camera = workspace.CurrentCamera,
    mouse = nil,
    playerGui = nil,
}
Services.mouse = Services.player:GetMouse()
Services.playerGui = Services.player:WaitForChild("PlayerGui")

local isMobile = Services.UserInputService.TouchEnabled
local viewport = Services.camera.ViewportSize
local screenWidth = viewport.X
local screenHeight = viewport.Y
local guiScale = math.clamp(screenWidth / 1920, 0.6, 1.4)
if screenWidth < 1000 then guiScale = math.clamp(screenWidth / 900, 0.55, 1.1) end

-- Глобальный доступ
_G.Experiment17 = {
    guiScale = guiScale,
    screenWidth = screenWidth,
    screenHeight = screenHeight,
    isMobile = isMobile,
    Services = Services,
}

print("=" .. string.rep("=", 50))
print("Experiment17 v5.3 - Initializing...")
print("Screen: " .. math.floor(screenWidth) .. "x" .. math.floor(screenHeight))
print("Scale: " .. string.format("%.2f", guiScale))
print("=" .. string.rep("=", 50))

-- ========================================
-- ФУНКЦИЯ ЗАГРУЗКИ МОДУЛЕЙ
-- ========================================
local function fetchModule(url)
    local ok, data = pcall(game.HttpGet, game, url)
    if not ok then warn("Download failed: " .. url); return nil end
    local fn, err = loadstring(data)
    if not fn then warn("Parse: " .. err); return nil end
    local ok2, mod = pcall(fn)
    if not ok2 then warn("Execute: " .. tostring(mod)); return nil end
    return mod
end

local B = "https://raw.githubusercontent.com/maxgg994-art/Experiment17/refs/heads/main/EX17/"

print("[EX17] Loading modules...")

local State = fetchModule(B .. "Core/State.lua")
if State and State.init then State.init() end

local Utils = fetchModule(B .. "Core/Utils.lua")
local NotificationManager = fetchModule(B .. "Managers/NotificationManager.lua")
local GUIManager = fetchModule(B .. "Managers/GUIManager.lua")
local ESPManager = fetchModule(B .. "Managers/ESPManager.lua")
local WorldManager = fetchModule(B .. "Managers/WorldManager.lua")
local AimbotManager = fetchModule(B .. "Managers/AimbotManager.lua")
local FarmManager = fetchModule(B .. "Managers/FarmManager.lua")
local InputManager = fetchModule(B .. "Managers/InputManager.lua")
local MusicManager = fetchModule(B .. "Managers/MusicManager.lua")
local ColorPicker = fetchModule(B .. "Managers/ColorPicker.lua")
local Heartbeat = fetchModule(B .. "Features/Heartbeat.lua")
local Stepped = fetchModule(B .. "Features/Stepped.lua")
local Panic = fetchModule(B .. "Features/Panic.lua")
local SwitchContent = fetchModule(B .. "Tabs/SwitchContent.lua")

print("[EX17] All modules loaded!")

-- ========================================
-- ИНИЦИАЛИЗАЦИЯ
-- ========================================
if GUIManager and GUIManager.create then GUIManager.create() end
if InputManager and InputManager.init then InputManager.init() end
if SwitchContent and SwitchContent.init then SwitchContent.init(); SwitchContent.switch("Legit") end
if WorldManager and WorldManager.readCurrentSettings then WorldManager.readCurrentSettings(); WorldManager.applyWorldSettings() end
if Heartbeat and Heartbeat.start then Heartbeat.start() end
if Stepped and Stepped.start then Stepped.start() end

-- Нотификация
local function notify(text, color)
    local gui = Services.playerGui:FindFirstChild("Experiment17") or Services.playerGui
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

notify("Experiment17 loaded! RightShift - GUI", Color3.fromRGB(0, 255, 0))
print("[EX17] Ready!")-- Main.lua
-- Experiment17 v5.3 - All-in-One Loader
-- Сервисы передаются глобально, модули не требуют Services.lua

-- ========================================
-- СЕРВИСЫ
-- ========================================
local Services = {
    Players = game:GetService("Players"),
    UserInputService = game:GetService("UserInputService"),
    RunService = game:GetService("RunService"),
    TweenService = game:GetService("TweenService"),
    Lighting = game:GetService("Lighting"),
    StarterGui = game:GetService("StarterGui"),
    SoundService = game:GetService("SoundService"),
    PathfindingService = game:GetService("PathfindingService"),
    HttpService = game:GetService("HttpService"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    TextChatService = game:GetService("TextChatService"),
    player = game:GetService("Players").LocalPlayer,
    camera = workspace.CurrentCamera,
    mouse = nil,
    playerGui = nil,
}
Services.mouse = Services.player:GetMouse()
Services.playerGui = Services.player:WaitForChild("PlayerGui")

local isMobile = Services.UserInputService.TouchEnabled
local viewport = Services.camera.ViewportSize
local screenWidth = viewport.X
local screenHeight = viewport.Y
local guiScale = math.clamp(screenWidth / 1920, 0.6, 1.4)
if screenWidth < 1000 then guiScale = math.clamp(screenWidth / 900, 0.55, 1.1) end

-- Глобальный доступ
_G.Experiment17 = {
    guiScale = guiScale,
    screenWidth = screenWidth,
    screenHeight = screenHeight,
    isMobile = isMobile,
    Services = Services,
}

print("=" .. string.rep("=", 50))
print("Experiment17 v5.3 - Initializing...")
print("Screen: " .. math.floor(screenWidth) .. "x" .. math.floor(screenHeight))
print("Scale: " .. string.format("%.2f", guiScale))
print("=" .. string.rep("=", 50))

-- ========================================
-- ФУНКЦИЯ ЗАГРУЗКИ МОДУЛЕЙ
-- ========================================
local function fetchModule(url)
    local ok, data = pcall(game.HttpGet, game, url)
    if not ok then warn("Download failed: " .. url); return nil end
    local fn, err = loadstring(data)
    if not fn then warn("Parse: " .. err); return nil end
    local ok2, mod = pcall(fn)
    if not ok2 then warn("Execute: " .. tostring(mod)); return nil end
    return mod
end

local B = "https://raw.githubusercontent.com/maxgg994-art/Experiment17/refs/heads/main/EX17/"

print("[EX17] Loading modules...")

local State = fetchModule(B .. "Core/State.lua")
if State and State.init then State.init() end

local Utils = fetchModule(B .. "Core/Utils.lua")
local NotificationManager = fetchModule(B .. "Managers/NotificationManager.lua")
local GUIManager = fetchModule(B .. "Managers/GUIManager.lua")
local ESPManager = fetchModule(B .. "Managers/ESPManager.lua")
local WorldManager = fetchModule(B .. "Managers/WorldManager.lua")
local AimbotManager = fetchModule(B .. "Managers/AimbotManager.lua")
local FarmManager = fetchModule(B .. "Managers/FarmManager.lua")
local InputManager = fetchModule(B .. "Managers/InputManager.lua")
local MusicManager = fetchModule(B .. "Managers/MusicManager.lua")
local ColorPicker = fetchModule(B .. "Managers/ColorPicker.lua")
local Heartbeat = fetchModule(B .. "Features/Heartbeat.lua")
local Stepped = fetchModule(B .. "Features/Stepped.lua")
local Panic = fetchModule(B .. "Features/Panic.lua")
local SwitchContent = fetchModule(B .. "Tabs/SwitchContent.lua")

print("[EX17] All modules loaded!")

-- ========================================
-- ИНИЦИАЛИЗАЦИЯ
-- ========================================
if GUIManager and GUIManager.create then GUIManager.create() end
if InputManager and InputManager.init then InputManager.init() end
if SwitchContent and SwitchContent.init then SwitchContent.init(); SwitchContent.switch("Legit") end
if WorldManager and WorldManager.readCurrentSettings then WorldManager.readCurrentSettings(); WorldManager.applyWorldSettings() end
if Heartbeat and Heartbeat.start then Heartbeat.start() end
if Stepped and Stepped.start then Stepped.start() end

-- Нотификация
local function notify(text, color)
    local gui = Services.playerGui:FindFirstChild("Experiment17") or Services.playerGui
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

notify("Experiment17 loaded! RightShift - GUI", Color3.fromRGB(0, 255, 0))
print("[EX17] Ready!")
