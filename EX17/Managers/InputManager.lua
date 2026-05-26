-- Managers/InputManager.lua
-- Клавиши, хоткеи, мобильная квадратная кнопка с обводкой

local InputManager = {}
local Services = require(script.Parent.Parent.Core.Services)
local Utils = require(script.Parent.Parent.Core.Utils)
local State = require(script.Parent.Parent.Core.State)
local GUIManager = require(script.Parent.GUIManager)
local NotificationManager = require(script.Parent.NotificationManager)

-- Мобильная кнопка
local mobileBtn

function InputManager.init()
    -- ========================================
    -- MOBILE BUTTON (квадратная + обводка)
    -- ========================================
    if _G.Experiment17.isMobile then
        local scale = State.guiSize

        local mobileGui = Instance.new("ScreenGui")
        mobileGui.Name = "MobileBtnGui"
        mobileGui.ResetOnSpawn = false
        mobileGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        mobileGui.Parent = Services.playerGui
        Utils.removeSelection(mobileGui)

        mobileBtn = Instance.new("TextButton")
        mobileBtn.Name = "MobileToggle"
        mobileBtn.Size = UDim2.new(0, 52 * scale, 0, 52 * scale)
        mobileBtn.Position = UDim2.new(1, -70 * scale, 1, -200 * scale)
        mobileBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 200)
        mobileBtn.Text = "GUI"
        mobileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        mobileBtn.Font = Enum.Font.Oswald
        mobileBtn.TextSize = 12 * scale
        mobileBtn.ZIndex = 200
        mobileBtn.Parent = mobileGui
        Utils.removeSelection(mobileBtn)
        Utils.addCorner(mobileBtn, 10)
        Utils.addStroke(mobileBtn, 2, Color3.fromRGB(255, 255, 255))

        local btnDragging = false
        local dragStart, btnStartPos

        mobileBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                btnDragging = true
                dragStart = input.Position
                btnStartPos = mobileBtn.Position
            end
        end)

        mobileBtn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                local dist = (input.Position - dragStart).Magnitude
                if dist < 10 then
                    GUIManager.toggleGUI()
                end
                btnDragging = false
            end
        end)

        Services.UserInputService.TouchMoved:Connect(function(input, processed)
            if btnDragging and not processed then
                local delta = input.Position - dragStart
                mobileBtn.Position = UDim2.new(
                    btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X,
                    btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y
                )
            end
        end)
    end

    -- ========================================
    -- INPUT BEGAN (клавиатура)
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
                -- Обновляем все кнопки клавиш
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
            local Panic = require(script.Parent.Parent.Features.Panic)
            Panic.shutdown()
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
            local AimbotManager = require(script.Parent.AimbotManager)
            local target = AimbotManager.getClosestToCrosshair(300)
            if target and target.plr then
                State.teleportTarget = target.plr
                NotificationManager.show("Target: " .. target.plr.Name, Color3.fromRGB(255, 255, 0))
            else
                NotificationManager.show("No target found", Color3.fromRGB(255, 100, 100))
            end
            if State.aimbotMode == "Lock" and target and target.plr then
                State.aimbotLockTarget = target.plr
            end
            return
        end

        -- TP Execute
        if keyName == State.teleportExecuteKey then
            local target = State.teleportTarget
            if not target then
                local AimbotManager = require(script.Parent.AimbotManager)
                local closest = AimbotManager.getClosestToCrosshair(300)
                if closest and closest.plr then target = closest.plr end
            end
            if target then
                local Teleport = require(script.Parent.Parent.Features.Teleport)
                Teleport.teleportToPlayer(target)
                NotificationManager.show("Teleported to " .. target.Name, Color3.fromRGB(0, 255, 0))
            else
                NotificationManager.show("No target", Color3.fromRGB(255, 100, 100))
            end
            return
        end

        -- Toggle GUI
        if keyName == State.toggleGuiKey then
            GUIManager.toggleGUI()
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

        -- Toggle Functions (Fly, NoClip, AirStrafe, Speed, Aimbot, Silent, Trigger)
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
            -- SafeFunctions блокировка
            if State.safeFunctions and (toggle == "fly" or toggle == "noClip" or toggle == "speedBoost") then
                NotificationManager.show("Blocked by Safe Functions!", Color3.fromRGB(255, 100, 100))
                return
            end

            State[toggle] = not State[toggle]

            -- Обновляем тумблер в GUI
            if State.toggleSetters[toggle] then
                State.toggleSetters[toggle](State[toggle])
            end

            -- Очистка Fly
            if toggle == "fly" and not State.fly then
                if State.bodyGyro then State.bodyGyro:Destroy(); State.bodyGyro = nil end
                if State.bodyVelocity then State.bodyVelocity:Destroy(); State.bodyVelocity = nil end
                if Services.player.Character then
                    local h = Services.player.Character:FindFirstChildOfClass("Humanoid")
                    if h then h.PlatformStand = false end
                end
            end

            -- Сброс AirStrafe
            if toggle == "airStrafe" and not State.airStrafe then
                State.airStrafeSpeed = 0
            end

            NotificationManager.show(
                (State[toggle] and "ON" or "OFF") .. ": " .. toggle,
                State[toggle] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
            )
            return
        end

        -- Freecam колёсико
        if State.freecam and input.UserInputType == Enum.UserInputType.MouseWheel then
            State.freecamSpeed = math.clamp(State.freecamSpeed + (input.Position.Z > 0 and 10 or -10), 10, 500)
        end
    end)

    -- ========================================
    -- JUMP REQUEST (AirStrafe разгон)
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

    print("[InputManager] Initialized")
end

return InputManager
