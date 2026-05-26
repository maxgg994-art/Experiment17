-- Features/Stepped.lua
-- NoClip + все корутины (Respawn, FastSwim, NoLava, InfStamina, AntiTP, ForceView, TransparentUI, ESP, NPC, FarmCleanup)

local Stepped = {}
local Services = require(script.Parent.Parent.Core.Services)
local State = require(script.Parent.Parent.Core.State)
local ESPManager = require(script.Parent.Parent.Managers.ESPManager)
local FarmManager = require(script.Parent.Parent.Managers.FarmManager)
local Utils = require(script.Parent.Parent.Core.Utils)

function Stepped.start()
    -- ========================================
    -- STEPPED - NoClip
    -- ========================================
    Services.RunService.Stepped:Connect(function()
        if State.noClip and Services.player.Character then
            for _, part in ipairs(Services.player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)

    -- ========================================
    -- AUTO RESPAWN
    -- ========================================
    task.spawn(function()
        while true do
            if State.autoRespawn and Services.player.Character then
                local hum = Services.player.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health <= 0 then
                    local ct = tick()
                    if ct - State.lastRespawnTime > 2 then
                        pcall(function()
                            Services.VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, nil)
                            task.wait(0.1)
                            Services.VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, nil)
                        end)
                        State.lastRespawnTime = ct
                    end
                end
            end
            task.wait(1)
        end
    end)

    -- ========================================
    -- FAST SWIM
    -- ========================================
    task.spawn(function()
        while true do
            if State.fastSwim and Services.player.Character then
                local hum = Services.player.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum:GetState() == Enum.HumanoidStateType.Swimming then
                    hum.WalkSpeed = 16 * State.fastSwimSpeed
                end
            end
            task.wait(0.1)
        end
    end)

    -- ========================================
    -- NO LAVA DAMAGE
    -- ========================================
    task.spawn(function()
        while true do
            if State.noLavaDamage and Services.player.Character then
                local hum = Services.player.Character:FindFirstChildOfClass("Humanoid")
                local root = Services.player.Character:FindFirstChild("HumanoidRootPart")
                if hum and root then
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") then
                            local isLava = obj.Material == Enum.Material.Neon
                                or obj.Name:lower():find("lava")
                                or obj.BrickColor == BrickColor.new("Neon orange")
                                or obj.BrickColor == BrickColor.new("Bright red")
                            if isLava and (obj.Position - root.Position).Magnitude < 5 then
                                hum.Health = hum.MaxHealth
                            end
                        end
                    end
                end
            end
            task.wait(0.2)
        end
    end)

    -- ========================================
    -- INFINITE STAMINA
    -- ========================================
    task.spawn(function()
        while true do
            if State.infiniteStamina and Services.player.Character then
                local hum = Services.player.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:SetStateEnabled(Enum.HumanoidStateType.Running, true)
                    hum:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, true)
                    hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
                    hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
                end
            end
            task.wait(1)
        end
    end)

    -- ========================================
    -- ANTI TELEPORT (без дёргания камеры)
    -- ========================================
    task.spawn(function()
        while true do
            if State.antiTeleport and Services.player.Character then
                local root = Services.player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    if State.antiTeleportPos then
                        local dist = (root.Position - State.antiTeleportPos).Magnitude
                        if dist > 50 then
                            root.CFrame = CFrame.new(State.antiTeleportPos)
                        end
                    end
                    State.antiTeleportPos = root.Position
                end
            else
                State.antiTeleportPos = nil
            end
            task.wait(0.05)
        end
    end)

    -- ========================================
    -- FORCE VIEW
    -- ========================================
    task.spawn(function()
        while true do
            if State.forceView then
                if State.firstPerson then
                    Services.player.CameraMode = Enum.CameraMode.LockFirstPerson
                    Services.player.CameraMaxZoomDistance = 0.5
                    Services.player.CameraMinZoomDistance = 0.5
                else
                    Services.player.CameraMode = Enum.CameraMode.Classic
                    Services.player.CameraMaxZoomDistance = State.cameraDistance
                    Services.player.CameraMinZoomDistance = 1
                end
            end
            task.wait(0.3)
        end
    end)

    -- ========================================
    -- TRANSPARENT UI
    -- ========================================
    task.spawn(function()
        while true do
            if State.transparentUI then
                for _, gui in ipairs(Services.playerGui:GetChildren()) do
                    if gui.Name ~= "Experiment17" then
                        for _, obj in ipairs(gui:GetDescendants()) do
                            if obj:IsA("Frame") and obj.BackgroundTransparency < 0.5 then
                                obj.BackgroundTransparency = 0.5
                            end
                            if obj:IsA("TextLabel") and obj.TextTransparency < 0.5 then
                                obj.TextTransparency = 0.5
                            end
                        end
                    end
                end
            end
            task.wait(1)
        end
    end)

    -- ========================================
    -- AUTO FARM CLEANUP
    -- ========================================
    task.spawn(function()
        while true do
            FarmManager.cleanup()
            task.wait(0.5)
        end
    end)

    -- ========================================
    -- ESP AUTO UPDATE
    -- ========================================
    task.spawn(function()
        while true do
            if State.espEnabled then
                local ct = tick()
                if ct - State.lastESPUpdate > 5 then
                    ESPManager.refreshAll()
                    State.lastESPUpdate = ct
                end
            end
            task.wait(1)
        end
    end)

    -- ========================================
    -- NPC LIST UPDATE
    -- ========================================
    task.spawn(function()
        while true do
            Utils.updateNPCList(State.npcList)
            task.wait(5)
        end
    end)

    -- ========================================
    -- PLAYER EVENTS
    -- ========================================
    Services.Players.PlayerAdded:Connect(function(plr)
        plr.CharacterAdded:Connect(function()
            if State.espEnabled then
                task.wait(0.3)
                ESPManager.createESP(plr, false)
            end
        end)

        if State.antiStaff then
            -- Проверка при добавлении игрока
            local blacklist = {}
            for _, name in ipairs(blacklist) do
                if plr.Name == name or plr.DisplayName == name then
                    local Panic = require(script.Parent.Panic)
                    Panic.shutdown()
                    return
                end
            end
        end
    end)

    Services.Players.PlayerRemoving:Connect(function(plr)
        if State.espEnabled then
            ESPManager.refreshAll()
        end
        if State.aimbotLockTarget == plr then
            State.aimbotLockTarget = nil
        end
    end)

    -- ========================================
    -- ANTI STAFF (периодическая)
    -- ========================================
    task.spawn(function()
        while true do
            if State.antiStaff then
                local blacklist = {}
                for _, plr in ipairs(Services.Players:GetPlayers()) do
                    if plr ~= Services.player then
                        for _, name in ipairs(blacklist) do
                            if plr.Name == name or plr.DisplayName == name then
                                local Panic = require(script.Parent.Panic)
                                Panic.shutdown()
                                return
                            end
                        end
                    end
                end
            end
            task.wait(5)
        end
    end)
end

return Stepped
