-- Core/Utils.lua
-- Вспомогательные функции

local Utils = {}
local Services = _G.Experiment17.Services

-- Удаление синей обводки выделения
function Utils.removeSelection(obj)
    pcall(function()
        obj.SelectionImageObject = nil
    end)
end

-- Создание UICorner
function Utils.addCorner(obj, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = obj
    return corner
end

-- Создание UIStroke
function Utils.addStroke(obj, thickness, color)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness or 1
    stroke.Color = color or Color3.fromRGB(255, 255, 255)
    stroke.Parent = obj
    return stroke
end

-- Tween анимация
function Utils.tween(obj, properties, duration)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    local tween = Services.TweenService:Create(obj, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Отправка сообщения в чат
function Utils.sendChat(msg)
    if not msg or msg == "" then return end
    pcall(function()
        local tc = Services.TextChatService:FindFirstChild("TextChannels")
        if tc then
            local gen = tc:FindFirstChild("RBXGeneral")
            if gen then gen:SendAsync(msg); return end
        end
        local cs = game:GetService("Chat")
        if cs then
            local head = Services.player.Character and Services.player.Character:FindFirstChild("Head")
            cs:Chat(head or workspace, msg)
        end
    end)
end

-- Симуляция клика мыши
function Utils.mouse1click()
    local mouse = Services.mouse
    if mouse then
        mouse.Button1Down:Fire()
        task.wait(0.05)
        mouse.Button1Up:Fire()
    end
end

-- Клик-звуки
local clickSoundIds = {
    None = nil,
    Click = "rbxassetid://9119264549",
    Pop = "rbxassetid://9120383196",
    Tap = "rbxassetid://9120383436",
    Swoosh = "rbxassetid://9120383660",
}

-- Проигрывание звука клика
function Utils.playClickSound(soundName, volume)
    if soundName == "None" then return end
    local id = clickSoundIds[soundName]
    if id then
        local sound = Instance.new("Sound")
        sound.SoundId = id
        sound.Volume = volume or 0.5
        sound.Parent = Services.playerGui:FindFirstChild("Experiment17") or Services.playerGui
        sound:Play()
        game.Debris:AddItem(sound, 1)
    end
end

-- Блокировка мыши
function Utils.lockMouse()
    Services.UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
end

-- Разблокировка мыши
function Utils.unlockMouse()
    Services.UserInputService.MouseBehavior = Enum.MouseBehavior.Default
end

-- Цвет из HEX строки
function Utils.hexToColor(hex)
    hex = hex:gsub("#", "")
    local r = tonumber("0x" .. hex:sub(1, 2)) / 255
    local g = tonumber("0x" .. hex:sub(3, 4)) / 255
    local b = tonumber("0x" .. hex:sub(5, 6)) / 255
    if r and g and b then
        return Color3.fromRGB(r * 255, g * 255, b * 255)
    end
    return Color3.fromRGB(255, 255, 255)
end

-- Цвет в HEX строку
function Utils.colorToHex(color)
    return "#" .. string.format("%02X%02X%02X",
        math.floor(color.R * 255),
        math.floor(color.G * 255),
        math.floor(color.B * 255)
    )
end

-- Обновление списка NPC
function Utils.updateNPCList(npcList)
    table.clear(npcList)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and obj:FindFirstChild("Head") then
            if not Services.Players:GetPlayerFromCharacter(obj) then
                table.insert(npcList, obj)
            end
        end
    end
end

-- Кэширование монет для фарма
function Utils.updateCoinCache(coinName, cachedCoins)
    table.clear(cachedCoins)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:lower():find(coinName:lower()) then
            local part = obj:IsA("BasePart") and obj or (obj:IsA("Model") and obj.PrimaryPart)
            if part and part:IsA("BasePart") then
                table.insert(cachedCoins, part)
            end
        end
    end
end

print("[Utils] Loaded")
return Utils
