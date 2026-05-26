-- Core/Utils.lua

local Services = _G.Experiment17.Services
local Utils = {}

function Utils.removeSelection(obj)
    pcall(function() obj.SelectionImageObject = nil end)
end

function Utils.addCorner(obj, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = obj
    return corner
end

function Utils.addStroke(obj, thickness, color)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness or 1
    stroke.Color = color or Color3.fromRGB(255, 255, 255)
    stroke.Parent = obj
    return stroke
end

function Utils.tween(obj, properties, duration)
    local tweenInfo = TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    Services.TweenService:Create(obj, tweenInfo, properties):Play()
end

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

function Utils.mouse1click()
    if Services.mouse then
        Services.mouse.Button1Down:Fire()
        task.wait(0.05)
        Services.mouse.Button1Up:Fire()
    end
end

local clickSoundIds = {
    None = nil,
    Click = "rbxassetid://9119264549",
    Pop = "rbxassetid://9120383196",
    Tap = "rbxassetid://9120383436",
    Swoosh = "rbxassetid://9120383660",
}

function Utils.playClickSound(name, volume)
    if name == "None" then return end
    local id = clickSoundIds[name]
    if id then
        local sound = Instance.new("Sound")
        sound.SoundId = id
        sound.Volume = volume or 0.5
        sound.Parent = Services.playerGui:FindFirstChild("Experiment17") or Services.playerGui
        sound:Play()
        game.Debris:AddItem(sound, 1)
    end
end

function Utils.lockMouse()
    Services.UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
end

function Utils.unlockMouse()
    Services.UserInputService.MouseBehavior = Enum.MouseBehavior.Default
end

function Utils.hexToColor(hex)
    hex = hex:gsub("#", "")
    local r = tonumber("0x" .. hex:sub(1, 2))
    local g = tonumber("0x" .. hex:sub(3, 4))
    local b = tonumber("0x" .. hex:sub(5, 6))
    if r and g and b then
        return Color3.fromRGB(r, g, b)
    end
    return Color3.fromRGB(255, 255, 255)
end

function Utils.colorToHex(color)
    return "#" .. string.format("%02X%02X%02X",
        math.floor(color.R * 255),
        math.floor(color.G * 255),
        math.floor(color.B * 255)
    )
end

function Utils.updateNPCList(list)
    table.clear(list)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and obj:FindFirstChild("Head") then
            if not Services.Players:GetPlayerFromCharacter(obj) then
                table.insert(list, obj)
            end
        end
    end
end

function Utils.updateCoinCache(name, list)
    table.clear(list)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:lower():find(name:lower()) then
            local part = obj:IsA("BasePart") and obj or (obj:IsA("Model") and obj.PrimaryPart)
            if part and part:IsA("BasePart") then
                table.insert(list, part)
            end
        end
    end
end

return Utils
