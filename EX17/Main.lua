-- Main.lua
-- Experiment17 v5.3 - Проверка модулей

local camera = workspace.CurrentCamera

print("=" .. string.rep("=", 50))
print("Experiment17 v5.3 - Starting...")
print("=" .. string.rep("=", 50))

-- Проверяем, есть ли модули локально (в script)
local function findModule(name)
    -- Ищем среди детей скрипта
    for _, child in ipairs(script:GetChildren()) do
        if child:IsA("ModuleScript") and child.Name == name then
            return require(child)
        end
    end
    -- Ищем по пути
    local success, result = pcall(function()
        return require(script:FindFirstChild(name))
    end)
    if success and result then return result end
    
    -- Ищем в Core
    local core = script:FindFirstChild("Core")
    if core then
        success, result = pcall(function()
            return require(core:FindFirstChild(name))
        end)
        if success and result then return result end
    end
    
    return nil
end

-- Пробуем загрузить
local Services = findModule("Services")
if not Services then
    warn("Services not found, trying HTTP...")
    local data = game:HttpGet("https://raw.githubusercontent.com/maxgg994-art/Experiment17/refs/heads/main/EX17/Core/Services.lua")
    Services = loadstring(data)()
end

-- Если Services всё ещё nil, создаём руками
if not Services then
    warn("Creating Services manually...")
    Services = {
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
        player = game.Players.LocalPlayer,
        camera = workspace.CurrentCamera,
        mouse = game.Players.LocalPlayer:GetMouse(),
        playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui"),
    }
end

Services.init = Services.init or function() 
    _G.Experiment17.isMobile = Services.UserInputService.TouchEnabled
    print("[Services] Manual init OK")
end
Services.init()

print("Services loaded: " .. tostring(Services ~= nil))
print("Player: " .. Services.player.Name)
