-- Features/Heartbeat.lua

local Services = _G.Experiment17.Services
local State = _G.Experiment17.State
local Heartbeat = {}

function Heartbeat.start()
    local AimbotManager = _G.Experiment17.AimbotManager
    local FarmManager = _G.Experiment17.FarmManager
    local Panic = _G.Experiment17.Panic
    local Utils = _G.Experiment17.Utils

    Services.RunService.Heartbeat:Connect(function()
        if State.panicMode then return end

        local char = Services.player.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not hum or not root then return end

        -- Safe Functions
        if State.safeFunctions and (State.fly or State.noClip or State.speedBoost or State.reverseWalk or State.phase or State.microTP or State.spinBot or State.infiniteJump or State.speedBurst) then
            if Panic then Panic.applySafeFunctions() end
        end

        -- FOV
        Services.camera.FieldOfView = math.clamp(State.fov, 30, 120)

        -- Camera Spin
        if State.cameraSpin then
            Services.camera.CFrame = Services.camera.CFrame * CFrame.Angles(0, math.rad(State.cameraSpinSpeed * 0.5), 0)
        end

        -- Freecam
        if State.freecam then
            Services.camera.CameraType = Enum.CameraType.Scriptable
            local move = Vector3.zero
            if Services.UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Services.camera.CFrame.LookVector end
            if Services.UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Services.camera.CFrame.LookVector end
            if Services.UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Services.camera.CFrame.RightVector end
            if Services.UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Services.camera.CFrame.RightVector end
            if Services.UserInputService:IsKeyDown(Enum.KeyCode.E) then move = move + Vector3.new(0, 1, 0) end
            if Services.UserInputService:IsKeyDown(Enum.KeyCode.Q) then move = move + Vector3.new(0, -1, 0) end
            local md = Services.UserInputService:GetMouseDelta()
            Services.camera.CFrame = Services.camera.CFrame * CFrame.Angles(0, -math.rad(md.X) * 0.3, 0) * CFrame.Angles(-math.rad(md.Y) * 0.3, 0, 0)
            Services.camera.CFrame = Services.camera.CFrame + move * State.freecamSpeed * 0.05
        elseif Services.camera.CameraType == Enum.CameraType.Scriptable then
            Services.camera.CameraType = Enum.CameraType.Custom
        end

        -- Camera Roll
        if State.cameraRoll ~= 0 then
            Services.camera.CFrame = Services.camera.CFrame * CFrame.Angles(0, 0, math.rad(State.cameraRoll * 0.01))
        end

        -- Anti AFK
        if State.antiAFK and tick() - State.lastAFKTime >= State.antiAFKFrequency then
            if State.antiAFKMode == "Micro" then
                hum:Move(Vector3.new(math.random(-1, 1) * 0.1, 0, math.random(-1, 1) * 0.1), false)
            else
                hum:MoveTo(root.Position + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5)))
            end
            State.lastAFKTime = tick()
        end

        -- Safe Walk
        if State.safeWalk and hum.MoveDirection.Magnitude > 0 then
            local r = workspace:Raycast(root.Position + hum.MoveDirection.Unit * 3 + Vector3.new(0, 2, 0), Vector3.new(0, -5, 0))
            if not r then hum:Move(Vector3.zero, false) end
        end

        -- Auto Tool
        if State.autoTool then
            for _, t in ipairs(char:GetChildren()) do
                if t:IsA("Tool") and t ~= char:FindFirstChildOfClass("Tool") then
                    pcall(function() hum:EquipTool(t) end)
                    break
                end
            end
        end

        -- Step
        if State.step and hum.MoveDirection.Magnitude > 0 then
            local r = workspace:Raycast(root.Position + hum.MoveDirection.Unit * 2 + Vector3.new(0, 1, 0), Vector3.new(0, -3, 0))
            if r then
                local hd = r.Position.Y - root.Position.Y
                if hd > 0.5 and hd <= State.stepHeight then
                    root.CFrame = root.CFrame + Vector3.new(0, hd + 0.5, 0)
                end
            end
        end

        -- Glide
        if State.glide and hum.FloorMaterial == Enum.Material.Air then
            local v = root.AssemblyLinearVelocity
            if v.Y < 0 then root.AssemblyLinearVelocity = Vector3.new(v.X, v.Y * State.glideSpeed, v.Z) end
        end

        -- Wall Hop
        if State.wallHop and Services.UserInputService:IsKeyDown(Enum.KeyCode.W) and hum.FloorMaterial == Enum.Material.Air and tick() - State.lastWallHopTime > 0.3 then
            local md = hum.MoveDirection.Unit
            if md.Magnitude > 0 and workspace:Raycast(root.Position, md * 3) then
                root.AssemblyLinearVelocity = Vector3.new(0, State.wallHopPower, 0)
                State.lastWallHopTime = tick()
            end
        end

        -- Rocket Jump
        if State.rocketJump and Services.UserInputService:IsKeyDown(Enum.KeyCode[State.rocketJumpKey]) then
            if State.rocketJumpMode == "CFrame" then
                root.CFrame = root.CFrame + Vector3.new(0, State.rocketJumpPower * 0.05, 0)
            elseif tick() - State.lastRocketJumpTime > 0.1 then
                root.AssemblyLinearVelocity = Vector3.new(0, State.rocketJumpPower, 0)
                State.lastRocketJumpTime = tick()
            end
        end

        -- Air Strafe
        if State.airStrafe then
            if hum.FloorMaterial == Enum.Material.Air then
                local md = Vector3.zero
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.W) then md = md + root.CFrame.LookVector end
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.A) then md = md - root.CFrame.RightVector end
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.D) then md = md + root.CFrame.RightVector end
                if md.Magnitude > 0 then
                    md = md.Unit
                    root.AssemblyLinearVelocity = Vector3.new(md.X * State.airStrafeSpeed, root.AssemblyLinearVelocity.Y, md.Z * State.airStrafeSpeed)
                end
            elseif hum.MoveDirection.Magnitude < 0.1 then
                State.airStrafeSpeed = 16
            end
        end

        -- Gravity
        if State.gravity ~= 196.2 then workspace.Gravity = State.gravity end

        -- Jump Power
        hum.JumpPower = State.jumpPowerRage > 0 and State.jumpPowerRage or State.jumpPower

        -- Infinite Jump
        if State.infiniteJump and hum.FloorMaterial == Enum.Material.Air then hum.Jump = true end

        -- Speed Burst
        if State.speedBurst and Services.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and tick() - State.lastSpeedBurstTime > 2 then
            if hum.MoveDirection.Magnitude > 0 then
                root.AssemblyLinearVelocity = hum.MoveDirection.Unit * State.speedBurstPower
                State.lastSpeedBurstTime = tick()
            end
        end

        -- Phase
        if State.phase and Services.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and tick() - State.lastPhaseTime > 0.1 then
            if hum.MoveDirection.Magnitude > 0 then
                root.CFrame = root.CFrame + hum.MoveDirection.Unit * State.phaseDistance
                State.lastPhaseTime = tick()
            end
        end

        -- Speed / Reverse / NoSlow
        if State.reverseWalk then
            hum.WalkSpeed = State.speedBoost and -16 * State.speedMultiplier or -16
        elseif State.speedBoost then
            hum.WalkSpeed = 16 * State.speedMultiplier
        else
            hum.WalkSpeed = 16
        end
        if State.noSlowdown and hum.WalkSpeed < 16 and not State.reverseWalk then
            hum.WalkSpeed = State.speedBoost and 16 * State.speedMultiplier or 16
        end

        -- Anti Ragdoll / Freeze
        if State.antiRagdoll and hum:GetState() == Enum.HumanoidStateType.Physics then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
        if State.antiFreeze and hum:GetState() == Enum.HumanoidStateType.Frozen then hum:ChangeState(Enum.HumanoidStateType.Running) end

        -- Fast Ladder
        if State.fastLadder then pcall(function() hum.ClimbSpeed = State.fastLadderSpeed * 16 end) end

        -- No Collision
        if State.noCollision then for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end

        -- Walk On Water
        if State.walkOnWater then
            for _, o in ipairs(workspace:GetDescendants()) do
                if o:IsA("BasePart") and o.Material == Enum.Material.Water then
                    if root.Position.Y < o.Position.Y + o.Size.Y / 2 and root.Position.Y > o.Position.Y - o.Size.Y / 2 then
                        root.CFrame = root.CFrame + Vector3.new(0, 0.3, 0)
                    end
                end
            end
        end

        -- No Fall / No Push / Auto Rotate
        if State.noFallDamage then hum.FallingDown = false end
        if State.noPush then for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 100, 1, 1) end end end
        if State.autoRotate and hum.MoveDirection.Magnitude < 1 then root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(State.autoRotateSpeed), 0) end

        -- Character Size
        if State.characterSize ~= 1 then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                    if not State.savedCharacterSize[p] then State.savedCharacterSize[p] = p.Size end
                    p.Size = State.savedCharacterSize[p] * State.characterSize
                end
            end
        else
            for p, os in pairs(State.savedCharacterSize) do if p and p.Parent then p.Size = os end end
            table.clear(State.savedCharacterSize)
        end

        -- Collision Push
        if State.autoCollisionPush then
            State.pushDirection = State.pushDirection + 1
            local a = math.rad(State.pushRotateSpeed * 10)
            if State.pushDirection % 2 == 0 then a = -a end
            root.CFrame = root.CFrame * CFrame.Angles(0, a, 0)
            for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true; p.Massless = false; p.CustomPhysicalProperties = PhysicalProperties.new(100, 1, 1, 100, 1, 1) end end
        end

        -- Body Facing
        if State.bodyFacing then
            for _, plr in ipairs(Services.Players:GetPlayers()) do
                if plr ~= Services.player and plr.Character then
                    local th = plr.Character:FindFirstChild("Head")
                    local tr = plr.Character:FindFirstChild("HumanoidRootPart")
                    if th and tr then
                        local ld = th.CFrame.LookVector
                        local tm = (root.Position - th.Position).Unit
                        if ld:Dot(tm) > 0.3 then
                            local la = CFrame.new(th.Position, root.Position)
                            th.CFrame = la
                            tr.CFrame = CFrame.new(tr.Position) * CFrame.Angles(0, math.atan2(la.LookVector.X, la.LookVector.Z), 0)
                        end
                    end
                end
            end
        end

        -- Micro TP
        if State.microTP then
            local md = Vector3.zero
            if Services.UserInputService:IsKeyDown(Enum.KeyCode.W) then md = md + root.CFrame.LookVector end
            if Services.UserInputService:IsKeyDown(Enum.KeyCode.S) then md = md - root.CFrame.LookVector end
            if Services.UserInputService:IsKeyDown(Enum.KeyCode.A) then md = md - root.CFrame.RightVector end
            if Services.UserInputService:IsKeyDown(Enum.KeyCode.D) then md = md + root.CFrame.RightVector end
            if md.Magnitude > 0 and tick() - State.lastMicroTPTime >= 0.05 then
                root.CFrame = CFrame.new(root.Position + md.Unit * State.microTPDistance)
                State.lastMicroTPTime = tick()
            end
        end

        -- SpinBot
        if State.spinBot and hum.MoveDirection.Magnitude < 1 then
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(State.spinSpeed * 10), 0)
        end

        -- Fly
        if State.fly then
            hum.PlatformStand = true
            if State.flyMode == "CFrame" then
                local move = Vector3.zero
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Services.camera.CFrame.LookVector end
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Services.camera.CFrame.LookVector end
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Services.camera.CFrame.RightVector end
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Services.camera.CFrame.RightVector end
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move + Vector3.new(0, -1, 0) end
                if move.Magnitude > 0 then root.CFrame = root.CFrame + move.Unit * State.flySpeed * 0.05 end
                root.AssemblyLinearVelocity = Vector3.zero
            else
                if not State.bodyGyro then
                    State.bodyGyro = Instance.new("BodyGyro"); State.bodyGyro.P = 9e4
                    State.bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9); State.bodyGyro.Parent = root
                    State.bodyVelocity = Instance.new("BodyVelocity")
                    State.bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9); State.bodyVelocity.Parent = root
                end
                State.bodyGyro.CFrame = CFrame.new(root.Position, root.Position + Services.camera.CFrame.LookVector)
                local vel = Vector3.zero
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + Services.camera.CFrame.LookVector * State.flySpeed end
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - Services.camera.CFrame.LookVector * State.flySpeed end
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - Services.camera.CFrame.RightVector * State.flySpeed end
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + Services.camera.CFrame.RightVector * State.flySpeed end
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0, State.flySpeed, 0) end
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vel = vel - Vector3.new(0, State.flySpeed, 0) end
                State.bodyVelocity.Velocity = vel
                root.AssemblyLinearVelocity = Vector3.zero
            end
        else
            if hum.PlatformStand and not State.noClip then hum.PlatformStand = false end
            if State.bodyGyro then State.bodyGyro:Destroy(); State.bodyGyro = nil end
            if State.bodyVelocity then State.bodyVelocity:Destroy(); State.bodyVelocity = nil end
        end

        -- Aimbot
        if State.silentAim and AimbotManager then AimbotManager.silentAim()
        elseif State.aimbotEnabled and AimbotManager then AimbotManager.normalAimbot() end
        if State.aimAssist and not State.aimbotEnabled and not State.silentAim and AimbotManager then AimbotManager.aimAssist() end
        if State.triggerBotEnabled and AimbotManager then AimbotManager.triggerBot() end

        -- Fast Interact
        if State.fastInteract then
            for _, o in ipairs(workspace:GetDescendants()) do
                if o:IsA("ProximityPrompt") and o.Enabled then
                    if (o.Parent.Position - root.Position).Magnitude <= o.MaxActivationDistance then
                        pcall(function() o:InputHoldBegin(); task.wait(0.05); o:InputHoldEnd() end)
                    end
                end
            end
        end

        -- Chat Spam
        if State.chatSpam and tick() - State.lastChatSpamTime >= State.chatSpamMinDelay + math.random() * (State.chatSpamMaxDelay - State.chatSpamMinDelay) then
            local msgs = {}
            for m in string.gmatch(State.chatSpamMessages, "[^|]+") do table.insert(msgs, m) end
            if #msgs > 0 and Utils then
                for _ = 1, State.chatSpamMode do Utils.sendChat(msgs[math.random(#msgs)]) end
            end
            State.lastChatSpamTime = tick()
        end

        -- Night Mode
        if State.nightMode then
            if not Services.Lighting:FindFirstChild("NightModeCC") then
                local cc = Instance.new("ColorCorrectionEffect"); cc.Name = "NightModeCC"
                cc.Brightness = -0.1; cc.Contrast = 0.1; cc.Saturation = -0.1
                cc.TintColor = Color3.fromRGB(20, 20, 60); cc.Parent = Services.Lighting
            end
        else
            local cc = Services.Lighting:FindFirstChild("NightModeCC"); if cc then cc:Destroy() end
        end

        -- No Camera Clip
        Services.camera.NearPlaneZ = State.noCameraClip and 0.01 or 0.5

        -- Camera Shake
        if not State.cameraShake then
            for _, e in ipairs(Services.camera:GetChildren()) do
                if e:IsA("CameraShaker") then e.Enabled = false end
            end
        end

        -- Tracers Update
        if State.tracers and #State.tracersList > 0 and tick() - State.lastTracerUpdate >= 0.01 then
            for i = 1, #State.tracersList, 4 do
                local cp = State.tracersList[i]
                if cp and cp:IsA("Part") and cp.Parent then cp.CFrame = Services.camera.CFrame end
            end
            State.lastTracerUpdate = tick()
        end

        -- Auto Farm
        if FarmManager then FarmManager.farm() end
    end)
end

return Heartbeat
