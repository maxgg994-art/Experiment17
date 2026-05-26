-- Main.lua - Experiment17 v5.3

local Services = {
    Players = game:GetService("Players"), UserInputService = game:GetService("UserInputService"),
    RunService = game:GetService("RunService"), TweenService = game:GetService("TweenService"),
    Lighting = game:GetService("Lighting"), StarterGui = game:GetService("StarterGui"),
    SoundService = game:GetService("SoundService"), PathfindingService = game:GetService("PathfindingService"),
    HttpService = game:GetService("HttpService"), VirtualInputManager = game:GetService("VirtualInputManager"),
    TextChatService = game:GetService("TextChatService"),
    player = game:GetService("Players").LocalPlayer, camera = workspace.CurrentCamera,
}
Services.mouse = Services.player:GetMouse()
Services.playerGui = Services.player:WaitForChild("PlayerGui")

local isMobile = Services.UserInputService.TouchEnabled
local vp = Services.camera.ViewportSize
local sw, sh = vp.X, vp.Y
local gs = math.clamp(sw / 1920, 0.6, 1.4)
if sw < 1000 then gs = math.clamp(sw / 900, 0.55, 1.1) end

_G.Experiment17 = { guiScale = gs, screenWidth = sw, screenHeight = sh, isMobile = isMobile, Services = Services }

print("=" .. string.rep("=", 50))
print("Experiment17 v5.3 - Loading...")
print("Screen: " .. sw .. "x" .. sh .. " | Scale: " .. string.format("%.2f", gs))
print("=" .. string.rep("=", 50))

local function fetch(url)
    local ok, data = pcall(game.HttpGet, game, url)
    if not ok then warn("Download: " .. url); return nil end
    local fn, err = loadstring(data)
    if not fn then warn("Parse: " .. err); return nil end
    local ok2, mod = pcall(fn)
    if not ok2 then warn("Execute: " .. tostring(mod)); return nil end
    return mod
end

local B = "https://raw.githubusercontent.com/maxgg994-art/Experiment17/refs/heads/main/EX17/"

local State = fetch(B .. "Core/State.lua"); if State and State.init then State.init() end; _G.Experiment17.State = State
local Utils = fetch(B .. "Core/Utils.lua"); _G.Experiment17.Utils = Utils
_G.Experiment17.NotificationManager = fetch(B .. "Managers/NotificationManager.lua")
_G.Experiment17.GUIManager = fetch(B .. "Managers/GUIManager.lua")
_G.Experiment17.UIFactory = fetch(B .. "Managers/UIFactory.lua")
_G.Experiment17.ESPManager = fetch(B .. "Managers/ESPManager.lua")
_G.Experiment17.WorldManager = fetch(B .. "Managers/WorldManager.lua")
_G.Experiment17.AimbotManager = fetch(B .. "Managers/AimbotManager.lua")
_G.Experiment17.FarmManager = fetch(B .. "Managers/FarmManager.lua")
_G.Experiment17.InputManager = fetch(B .. "Managers/InputManager.lua")
_G.Experiment17.MusicManager = fetch(B .. "Managers/MusicManager.lua")
_G.Experiment17.ColorPicker = fetch(B .. "Managers/ColorPicker.lua")
_G.Experiment17.Heartbeat = fetch(B .. "Features/Heartbeat.lua")
_G.Experiment17.Stepped = fetch(B .. "Features/Stepped.lua")
_G.Experiment17.Panic = fetch(B .. "Features/Panic.lua")
_G.Experiment17.SwitchContent = fetch(B .. "Tabs/SwitchContent.lua")

print("[EX17] All modules loaded!")

local GUIManager = _G.Experiment17.GUIManager
local InputManager = _G.Experiment17.InputManager
local SwitchContent = _G.Experiment17.SwitchContent
local WorldManager = _G.Experiment17.WorldManager
local Heartbeat = _G.Experiment17.Heartbeat
local Stepped = _G.Experiment17.Stepped

if GUIManager then GUIManager.create() end
if InputManager then InputManager.init() end
if SwitchContent then SwitchContent.init(); SwitchContent.switch("Legit") end
if WorldManager then WorldManager.readCurrentSettings(); WorldManager.applyWorldSettings() end
if Heartbeat then Heartbeat.start() end
if Stepped then Stepped.start() end

local function notify(t, c)
    local gui = Services.playerGui:FindFirstChild("Experiment17") or Services.playerGui
    local l = Instance.new("TextLabel"); l.Size = UDim2.new(0, 280, 0, 24); l.Position = UDim2.new(1, -290, 1, -36)
    l.BackgroundColor3 = Color3.fromRGB(0, 0, 0); l.BackgroundTransparency = 0.3
    l.Text = t; l.TextColor3 = c or Color3.fromRGB(255, 255, 255)
    l.Font = Enum.Font.Oswald; l.TextSize = 13; l.ZIndex = 300; l.Parent = gui
    task.delay(3, function() pcall(function() l:Destroy() end) end)
end

notify("Experiment17 loaded! RightShift - GUI", Color3.fromRGB(0, 255, 0))
print("[EX17] Ready!")
