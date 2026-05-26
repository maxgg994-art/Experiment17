-- Main.lua
-- Experiment17 v5.3

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
}
Services.mouse = Services.player:GetMouse()
Services.playerGui = Services.player:WaitForChild("PlayerGui")

local isMobile = Services.UserInputService.TouchEnabled
local viewport = Services.camera.ViewportSize
local screenWidth = viewport.X
local screenHeight = viewport.Y
local guiScale = math.clamp(screenWidth / 1920, 0.6, 1.4)
if screenWidth < 1000 then guiScale = math.clamp(screenWidth / 900, 0.55, 1.1) end

_G.Experiment17 = {
    guiScale = guiScale,
    screenWidth = screenWidth,
    screenHeight = screenHeight,
    isMobile = isMobile,
    Services = Services,
}

print("=" .. string.rep("=", 50))
print("Experiment17 v5.3")
print("Screen: " .. math.floor(screenWidth) .. "x" .. math.floor(screenHeight))
print("Scale: " .. string.format("%.2f", guiScale))
print("=" .. string.rep("=", 50))

local function fetch(url)
    local ok, data = pcall(game.HttpGet, game, url)
    if not ok then warn("Download fail: " .. url); return nil end
    local fn, err = loadstring(data)
    if not fn then warn("Parse: " .. err); return nil end
    local ok2, mod = pcall(fn)
    if not ok2 then warn("Execute: " .. tostring(mod)); return nil end
    return mod
end

local B = "https://raw.githubusercontent.com/maxgg994-art/Experiment17/refs/heads/main/EX17/"

print("Loading modules...")

local State = fetch(B .. "Core/State.lua")
if State and State.init then State.init() end
_G.Experiment17.State = State

local Utils = fetch(B .. "Core/Utils.lua")
_G.Experiment17.Utils = Utils

local NotificationManager = fetch(B .. "Managers/NotificationManager.lua")
local GUIManager = fetch(B .. "Managers/GUIManager.lua")
local UIFactory = fetch(B .. "Managers/UIFactory.lua")
local ESPManager = fetch(B .. "Managers/ESPManager.lua")
local WorldManager = fetch(B .. "Managers/WorldManager.lua")
local AimbotManager = fetch(B .. "Managers/AimbotManager.lua")
local FarmManager = fetch(B .. "Managers/FarmManager.lua")
local InputManager = fetch(B .. "Managers/InputManager.lua")
local MusicManager = fetch(B .. "Managers/MusicManager.lua")
local ColorPicker = fetch(B .. "Managers/ColorPicker.lua")
local Heartbeat = fetch(B .. "Features/Heartbeat.lua")
local Stepped = fetch(B .. "Features/Stepped.lua")
local Panic = fetch(B .. "Features/Panic.lua")
local SwitchContent = fetch(B .. "Tabs/SwitchContent.lua")

print("All modules loaded!")

-- Init
if GUIManager and GUIManager.create then GUIManager.create() end
if InputManager and InputManager.init then InputManager.init() end
if SwitchContent and SwitchContent.init then SwitchContent.init(); SwitchContent.switch("Legit") end
if WorldManager and WorldManager.readCurrentSettings then WorldManager.readCurrentSettings(); WorldManager.applyWorldSettings() end
if Heartbeat and Heartbeat.start then Heartbeat.start() end
if Stepped and Stepped.start then Stepped.start() end

-- Notification
local function notify(t, c)
    local gui = Services.playerGui:FindFirstChild("Experiment17") or Services.playerGui
    local l = Instance.new("TextLabel"); l.Size = UDim2.new(0,280,0,24); l.Position = UDim2.new(1,-290,1,-36)
    l.BackgroundColor3 = Color3.fromRGB(0,0,0); l.BackgroundTransparency = 0.3
    l.Text = t; l.TextColor3 = c or Color3.fromRGB(255,255,255)
    l.Font = Enum.Font.Oswald; l.TextSize = 13; l.ZIndex = 300; l.Parent = gui
    task.delay(3, function() pcall(function() l:Destroy() end) end)
end

notify("Experiment17 loaded! RightShift - GUI", Color3.fromRGB(0, 255, 0))
print("[EX17] Ready!")
