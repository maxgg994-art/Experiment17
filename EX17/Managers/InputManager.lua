-- Managers/InputManager.lua

local Services = _G.Experiment17.Services
local State = _G.Experiment17.State
local Utils = _G.Experiment17.Utils
local InputManager = {}

function InputManager.init()
    -- ========================================
    -- MOBILE BUTTON
    -- ========================================
    if _G.Experiment17.isMobile then
        local scale = State.guiSize

        local mobileGui = Instance.new("ScreenGui")
        mobileGui.Name = "MobileBtnGui"
        mobileGui.ResetOnSpawn = false
        mobileGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        mobileGui.Parent = Services.playerGui
        Utils.removeSelection(mobileGui)

        local mb = Instance.new("TextButton")
        mb.Name = "MobileToggle"
        mb.Size = UDim2.new(0, 52 * scale, 0, 52 * scale)
        mb.Position = UDim2.new(1, -70 * scale, 1, -200 * scale)
        mb.BackgroundColor3 = Color3.fromRGB(70, 70, 200)
        mb.Text = "GUI"
        mb.TextColor3 = Color3.fromRGB(255, 255, 255)
        mb.Font = Enum.Font.Oswald
        mb.TextSize = 12 * scale
        mb.ZIndex = 200
        mb.Parent = mobileGui
        Utils.removeSelection(mb)
        Utils.addCorner(mb, 10)
        Utils.addStroke(mb, 2, Color3.fromRGB(255, 255, 255))

        local btnDragging = false
        local dragStart, btnStartPos

        mb.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                btnDragging = true
                dragStart = input.Position
                btnStartPos = mb.Position
            end
        end)

        mb.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                local dist = (input.Position - dragStart).Magnitude
                if dist < 10 then
                    local GUIManager = _G.Experiment17.GUIManager
                    if GUIManager then GUIManager.toggleGUI() end
                end
                btnDragging = false
            end
        end)

        Services.UserInputService.TouchMoved:Connect(function(input, processed)
            if btnDragging and not processed then
                local delta = input.Position - dragStart
                mb.Position = UDim2.new(
                    btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X,
                    btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y
                )
            end
        end)
    end

    -- ========================================
    -- INPUT BEGAN
    -- ========================================
    Services.UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end

        local keyName = input.KeyCode.Name

        -- Keybind waiting
        if State.waitingForKeybind then
            if keyName ~= "Unknown" then
                local map = {
                    ["Toggle GUI"] = "toggleGuiKey", ["Unlock Mouse"] = "unlockMouseKey",
                    ["Fly"] = "flyKey", ["NoClip"] = "noClipKey",
                    ["AirStrafe"] = "airStrafeKey", ["Speed Boost"] = "speedBoostKey",
                    ["Aimbot"] = "aimbotKey", ["Silent Aim"] = "silentAimKey",
                    ["Trigger Bot"] = "triggerBotKey", ["TP Select"] = "teleportSelectKey",
                    ["TP Execute"] = "teleportExecuteKey", ["Panic Key"] = "panicKey",
                    ["Quick Turn"] = "quickTurnKey", ["Rocket Jump"] = "rocketJumpKey",
                    ["Freecam"] = "freecamKey",
                }
                local stateName = map[State.waitingForKeybind]
                if stateName then State[stateName] = keyName end
                State.waitingForKeybind = nil
                for k, btn in pairs(State.keybindButtons) do
                    if btn and State[k] then
                        btn.Text = State[k]
                        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    end
                end
            end
            return
        end

        -- Panic
        if keyName == State.panicKey then
            local Panic = _G.Experiment17.Panic
            if Panic then Panic.shutdown() end
            return
        end

        -- Quick Turn
        if keyName == State.quickTurnKey and State.quickTurn then
            if Services.player.Character then
                local root = Services.player.Character:FindFirstChild("HumanoidRootPart")
                if root then root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(180), 0) end
            end
            return
        end

        -- TP Select
        if keyName == State.teleportSelectKey then
            local AimbotManager = _G.Experiment17.AimbotManager
            if AimbotManager then
                local target = AimbotManager.getClosestToCrosshair(300)
                local NotificationManager = _G.Experiment17.NotificationManager
                if target and target.plr then
                    State.teleportTarget = target.plr
                    if NotificationManager then NotificationManager.show("Target: " .. target.plr.Name, Color3.fromRGB(255, 255, 0)) end
                else
                    if NotificationManager then NotificationManager.show("No target found", Color3.fromRGB(255, 100, 100)) end
                end
                if State.aimbotMode == "Lock" and target and target.plr then
                    State.aimbotLockTarget = target.plr
                end
            end
            return
        end

        -- TP Execute
        if keyName == State.teleportExecuteKey then
            local target = State.teleportTarget
            if not target then
                local AimbotManager = _G.Experiment17.AimbotManager
                if AimbotManager then
                    local closest = AimbotManager.getClosestToCrosshair(300)
                    if closest and closest.plr then target = closest.plr end
                end
            end
            local NotificationManager = _G.Experiment17.NotificationManager
            if target then
                -- Teleport logic
                if target.Character and Services.player.Character then
                    local tr = target.Character:FindFirstChild("HumanoidRootPart")
                    local mr = Services.player.Character:FindFirstChild("HumanoidRootPart")
                    if tr and mr then
                        local off = Vector3.zero
                        if State.teleportPosition == "Behind" then off = -tr.CFrame.LookVector * State.teleportDistance
                        elseif State.teleportPosition == "Front" then off = tr.CFrame.LookVector * State.teleportDistance
                        elseif State.teleportPosition == "Above" then off = Vector3.new(0, State.teleportDistance, 0)
                        elseif State.teleportPosition == "Below" then off = Vector3.new(0, -State.teleportDistance, 0) end
                        mr.CFrame = tr.CFrame + off
                    end
                end
                if NotificationManager then NotificationManager.show("Teleported to " .. target.Name, Color3.fromRGB(0, 255, 0)) end
            else
                if NotificationManager then NotificationManager.show("No target", Color3.fromRGB(255, 100, 100)) end
            end
            return
        end

        -- Toggle GUI
        if keyName == State.toggleGuiKey then
            local GUIManager = _G.Experiment17.GUIManager
            if GUIManager then GUIManager.toggleGUI() end
            return
        end

        -- Unlock Mouse
        if keyName == State.unlockMouseKey then
            State.mouseUnlocked = not State.mouseUnlocked
            if State.mouseUnlocked then Utils.unlockMouse() else Utils.lockMouse() end
            if State.toggleSetters.mouseUnlocked then
                State.toggleSetters.mouseUnlocked(State.mouseUnlocked)
            end
            return
        end

        -- Toggle Functions
        local toggleMap = {
            [State.flyKey] = "fly",
            [State.noClipKey] = "noClip",
            [State.airStrafeKey] = "airStrafe",
            [State.speedBoostKey] = "speedBoost",
            [State.aimbotKey] = "aimbotEnabled",
            [State.silentAimKey] = "silentAim",
            [State.triggerBotKey] = "triggerBotEnabled",
        }

        local toggle = toggleMap[keyName]
        if toggle then
            if State.safeFunctions and (toggle == "fly" or toggle == "noClip" or toggle == "speedBoost") then
                local NotificationManager = _G.Experiment17.NotificationManager
                if NotificationManager then NotificationManager.show("Blocked by Safe Functions!", Color3.fromRGB(255, 100, 100)) end
                return
            end

            State[toggle] = not State[toggle]

            if State.toggleSetters[toggle] then
                State.toggleSetters[toggle](State[toggle])
            end

            if toggle == "fly" and not State.fly then
                if State.bodyGyro then State.bodyGyro:Destroy(); State.bodyGyro = nil end
                if State.bodyVelocity then State.bodyVelocity:Destroy(); State.bodyVelocity = nil end
                if Services.player.Character then
                    local h = Services.player.Character:FindFirstChildOfClass("Humanoid")
                    if h then h.PlatformStand = false end
                end
            end

            if toggle == "airStrafe" and not State.airStrafe then
                State.airStrafeSpeed = 0
            end

            local NotificationManager = _G.Experiment17.NotificationManager
            if NotificationManager then
                NotificationManager.show(
                    (State[toggle] and "ON" or "OFF") .. ": " .. toggle,
                    State[toggle] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
                )
            end
            return
        end

        -- Freecam колесико
        if State.freecam and input.UserInputType == Enum.UserInputType.MouseWheel then
            State.freecamSpeed = math.clamp(State.freecamSpeed + (input.Position.Z > 0 and 10 or -10), 10, 500)
        end
    end)

    -- ========================================
    -- JUMP REQUEST
    -- ========================================
    Services.UserInputService.JumpRequest:Connect(function()
        if State.airStrafe and Services.player.Character then
            local hum = Services.player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.FloorMaterial ~= Enum.Material.Air then
                local ct = tick()
                State.airStrafeSpeed = (ct - State.lastStrafeTime < 0.5)
                    and math.min(State.airStrafeSpeed + 5, State.airStrafeMaxSpeed) or 20
                State.lastStrafeTime = ct
                hum.Jump = true
            end
        end
    end)
end

return InputManager
