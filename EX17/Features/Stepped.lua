-- Features/Stepped.lua

local Services = _G.Experiment17.Services
local State = _G.Experiment17.State
local Stepped = {}

function Stepped.start()
    local ESPManager = _G.Experiment17.ESPManager
    local FarmManager = _G.Experiment17.FarmManager
    local Utils = _G.Experiment17.Utils

    -- ========================================
    -- STEPPED - NoClip
    -- ========================================
    Services.RunService.Stepped:Connect(function()
        if State.noClip and Services.player.Character then
            for _, part in ipairs(Services.player.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
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
                if hum and hum.Health <= 0 and tick() - State.lastRespawnTime > 2 then
                    pcall(function()
                        Services.VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, nil)
                        task.wait(0.1)
                        Services.VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, nil)
                    end)
                    State.lastRespawnTime = tick()
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
    -- ANTI TELEPORT
    -- ========================================
    task.spawn(function()
        while true do
            if State.antiTeleport and Services.player.Character then
                local root = Services.player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    if State.antiTeleportPos and (root.Position - State.antiTeleportPos).Magnitude > 50 then
                        root.CFrame = CFrame.new(State.antiTeleportPos)
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
            if FarmManager then FarmManager.cleanup() end
            task.wait(0.5)
        end
    end)

    -- ========================================
    -- ESP AUTO UPDATE
    -- ========================================
    task.spawn(function()
        while true do
            if State.espEnabled and tick() - State.lastESPUpdate > 5 then
                if ESPManager then ESPManager.refreshAll() end
                State.lastESPUpdate = tick()
            end
            task.wait(1)
        end
    end)

    -- ========================================
    -- NPC LIST UPDATE
    -- ========================================
    task.spawn(function()
        while true do
            if Utils then Utils.updateNPCList(State.npcList) end
            task.wait(5)
        end
    end)

    -- ========================================
    -- PLAYER EVENTS
    -- ========================================
    Services.Players.PlayerAdded:Connect(function(plr)
        plr.CharacterAdded:Connect(function()
            if State.espEnabled and ESPManager then
                task.wait(0.3)
                ESPManager.createESP(plr, false)
            end
        end)
    end)

    Services.Players.PlayerRemoving:Connect(function(plr)
        if State.espEnabled and ESPManager then
            ESPManager.refreshAll()
        end
        if State.aimbotLockTarget == plr then
            State.aimbotLockTarget = nil
        end
    end)

    -- ========================================
    -- ANTI STAFF
    -- ========================================
    task.spawn(function()
        while true do
            if State.antiStaff then
                local blacklist = {}
                for _, plr in ipairs(Services.Players:GetPlayers()) do
                    if plr ~= Services.player then
                        for _, name in ipairs(blacklist) do
                            if plr.Name == name or plr.DisplayName == name then
                                local Panic = _G.Experiment17.Panic
                                if Panic then Panic.shutdown() end
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
