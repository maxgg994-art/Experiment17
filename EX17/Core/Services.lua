-- Core/Services.lua
-- Подключение всех сервисов и базовых переменных

local Services = {}

function Services.init()
    -- Сервисы Roblox
    local success, err = pcall(function()
        Services.Players = game:GetService("Players")
        Services.UserInputService = game:GetService("UserInputService")
        Services.RunService = game:GetService("RunService")
        Services.TweenService = game:GetService("TweenService")
        Services.Lighting = game:GetService("Lighting")
        Services.StarterGui = game:GetService("StarterGui")
        Services.SoundService = game:GetService("SoundService")
        Services.PathfindingService = game:GetService("PathfindingService")
        Services.HttpService = game:GetService("HttpService")
        Services.VirtualInputManager = game:GetService("VirtualInputManager")
        Services.TextChatService = game:GetService("TextChatService")

        -- Локальный игрок
        Services.player = Services.Players.LocalPlayer
        Services.camera = workspace.CurrentCamera
        Services.mouse = Services.player:GetMouse()
        Services.playerGui = Services.player:WaitForChild("PlayerGui")
    end)
    
    if not success then
        warn("[Services] Init error: " .. tostring(err))
        return
    end

    -- Мобильное устройство?
    _G.Experiment17.isMobile = Services.UserInputService.TouchEnabled

    -- Размер экрана
    local viewport = Services.camera.ViewportSize
    _G.Experiment17.screenWidth = viewport.X
    _G.Experiment17.screenHeight = viewport.Y

    -- Масштаб GUI
    local sw = viewport.X
    local scale = math.clamp(sw / 1920, 0.6, 1.4)
    if sw < 1000 then
        scale = math.clamp(sw / 900, 0.55, 1.1)
    end
    _G.Experiment17.guiScale = scale

    print("[Services] OK - Scale: " .. string.format("%.2f", scale))
end

return Services
