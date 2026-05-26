-- Managers/NotificationManager.lua

local Services = _G.Experiment17.Services
local State = _G.Experiment17.State
local Utils = _G.Experiment17.Utils
local NotificationManager = {}
local notifications = {}

function NotificationManager.show(text, color)
    if not State.showNotifications then return end

    local gui = Services.playerGui:FindFirstChild("Experiment17") or Services.playerGui

    -- Удаляем лишние
    while #notifications >= 5 do
        local old = table.remove(notifications, 1)
        pcall(function() old:Destroy() end)
    end

    local label = Instance.new("TextLabel")
    label.Name = "Notification"
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
    Utils.removeSelection(label)
    Utils.addCorner(label, 6)

    table.insert(notifications, label)

    task.delay(State.notificationDuration or 3, function()
        pcall(function()
            for i, notif in ipairs(notifications) do
                if notif == label then
                    table.remove(notifications, i)
                    break
                end
            end
            label:Destroy()
        end)
    end)
end

return NotificationManager
