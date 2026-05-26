-- Managers/AimbotManager.lua
-- Aimbot, Silent Aim, Trigger Bot, Aim Assist, Team Check, Player List

local AimbotManager = {}
local Services = require(script.Parent.Parent.Core.Services)
local State = require(script.Parent.Parent.Core.State)

-- Получение всех целей
function AimbotManager.getTargets()
    local targets = {}
    local myTeam = Services.player.Team

    -- Игроки
    if State.aimbotTargetPlayers then
        for _, plr in ipairs(Services.Players:GetPlayers()) do
            if plr ~= Services.player and plr.Character then
                local head = plr.Character:FindFirstChild("Head")
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if not head or not hum then continue end

                -- Team Check
                if State.aimbotIgnoreTeam and myTeam and plr.Team == myTeam then
                    continue
                end

                -- Ignore Spawn
                if State.aimbotIgnoreSpawn and hum.Health <= 0 then
                    continue
                end

                -- Player List
                if #State.aimbotPlayerList > 0 then
                    local inList = false
                    for _, name in ipairs(State.aimbotPlayerList) do
                        if plr.Name == name or plr.DisplayName == name then
                            inList = true
                            break
                        end
                    end
                    if State.aimbotListMode == "Blacklist" and inList then continue end
                    if State.aimbotListMode == "Whitelist" and not inList then continue end
                end

                -- Distance
                if Services.player.Character then
                    local dist = (head.Position - Services.player.Character:GetPivot().Position).Magnitude
                    if dist <= State.aimbotMaxDistance then
                        table.insert(targets, {plr = plr, char = plr.Character, isNPC = false})
                    end
                end
            end
        end
    end

    -- NPC
    if State.aimbotTargetNPC then
        for _, npc in ipairs(State.npcList) do
            if npc and npc.Parent then
                local head = npc:FindFirstChild("Head")
                local hum = npc:FindFirstChildOfClass("Humanoid")
                if head and hum and hum.Health > 0 and Services.player.Character then
                    local dist = (head.Position - Services.player.Character:GetPivot().Position).Magnitude
                    if dist <= State.aimbotMaxDistance then
                        table.insert(targets, {plr = nil, char = npc, isNPC = true})
                    end
                end
            end
        end
    end

    return targets
end

-- Ближайший к курсору
function AimbotManager.getClosestToCursor(maxDist)
    local closest, closestDist = nil, maxDist or math.huge
    for _, t in ipairs(AimbotManager.getTargets()) do
        local h = t.char:FindFirstChild("Head")
        if h then
            local sp, on = Services.camera:WorldToViewportPoint(h.Position)
            if on then
                local d = (Vector2.new(sp.X, sp.Y) - Vector2.new(Services.mouse.X, Services.mouse.Y)).Magnitude
                if d < closestDist then closestDist = d; closest = t end
            end
        end
    end
    return closest
end

-- Ближайший к перекрестию
function AimbotManager.getClosestToCrosshair(maxFOV)
    local closest, closestAngle = nil, maxFOV or math.huge
    local sc = Vector2.new(Services.camera.ViewportSize.X / 2, Services.camera.ViewportSize.Y / 2)
    for _, t in ipairs(AimbotManager.getTargets()) do
        local tp = t.char:FindFirstChild(State.aimbotTargetPart) or t.char:FindFirstChild("Head")
        if tp then
            local sp, on = Services.camera:WorldToViewportPoint(tp.Position)
            if on then
                local d = (Vector2.new(sp.X, sp.Y) - sc).Magnitude
                if d < closestAngle then closestAngle = d; closest = t end
            end
        end
    end
    return closest
end

-- Ближайший к персонажу
function AimbotManager.getClosestToCharacter()
    if not Services.player.Character then return nil end
    local closest, closestDist = nil, math.huge
    local mp = Services.player.Character:GetPivot().Position
    for _, t in ipairs(AimbotManager.getTargets()) do
        local tp = t.char:FindFirstChild(State.aimbotTargetPart) or t.char:FindFirstChild("Head")
        if tp then
            local d = (tp.Position - mp).Magnitude
            if d < closestDist then closestDist = d; closest = t end
        end
    end
    return closest
end

-- Основная цель
function AimbotManager.getTarget()
    if State.aimbotMode == "Lock" and State.aimbotLockTarget and State.aimbotLockTarget.Character then
        local tp = State.aimbotLockTarget.Character:FindFirstChild(State.aimbotTargetPart)
            or State.aimbotLockTarget.Character:FindFirstChild("Head")
        if tp and Services.player.Character then
            local dist = (tp.Position - Services.player.Character:GetPivot().Position).Magnitude
            if dist <= State.aimbotMaxDistance then
                return {plr = State.aimbotLockTarget, char = State.aimbotLockTarget.Character, isNPC = false}
            end
        end
        State.aimbotLockTarget = nil
    end

    if State.aimbotMode == "Crosshair" or State.aimbotMode == "Lock" then
        return AimbotManager.getClosestToCrosshair(State.aimbotFOV)
    elseif State.aimbotMode == "Cursor" then
        return AimbotManager.getClosestToCursor(State.aimbotFOV)
    elseif State.aimbotMode == "Closest" then
        return AimbotManager.getClosestToCharacter()
    end
    return nil
end

-- Silent Aim
function AimbotManager.silentAim()
    local t = AimbotManager.getTarget()
    if not t or not t.char then return end
    local tp = t.char:FindFirstChild(State.silentAimTargetPart) or t.char:FindFirstChild("Head")
    if not tp then return end

    local sp, on = Services.camera:WorldToViewportPoint(tp.Position)
    local sc = Vector2.new(Services.camera.ViewportSize.X / 2, Services.camera.ViewportSize.Y / 2)
    if on and (Vector2.new(sp.X, sp.Y) - sc).Magnitude <= State.silentAimFOV then
        Services.camera.CFrame = CFrame.new(Services.camera.CFrame.Position, tp.Position)
    end
end

-- Normal Aimbot
function AimbotManager.normalAimbot()
    local t = AimbotManager.getTarget()
    if not t or not t.char then return end
    local tp = t.char:FindFirstChild(State.aimbotTargetPart) or t.char:FindFirstChild("Head")
    if not tp then return end

    local la = CFrame.new(Services.camera.CFrame.Position, tp.Position)
    if State.aimbotSmoothness > 1 then
        Services.camera.CFrame = Services.camera.CFrame:Lerp(la, 1 / State.aimbotSmoothness)
    else
        Services.camera.CFrame = la
    end
end

-- Aim Assist
function AimbotManager.aimAssist()
    local md = Services.UserInputService:GetMouseDelta()
    if md.Magnitude <= 0 then return end
    if tick() - State.lastAimAssistTime <= 0.05 then return end

    local t = AimbotManager.getTarget()
    if t and t.char then
        local tp = t.char:FindFirstChild(State.aimbotTargetPart) or t.char:FindFirstChild("Head")
        if tp then
            local la = CFrame.new(Services.camera.CFrame.Position, tp.Position)
            Services.camera.CFrame = Services.camera.CFrame:Lerp(la, State.aimAssistStrength * 0.1)
        end
    end
    State.lastAimAssistTime = tick()
end

-- Trigger Bot
function AimbotManager.triggerBot()
    if tick() - State.lastTriggerTime < State.triggerBotDelay then return end

    local t = AimbotManager.getClosestToCursor(200)
    if t and t.char then
        local tp = t.char:FindFirstChild(State.triggerBotTargetPart) or t.char:FindFirstChild("Head")
        if tp then
            local sp, on = Services.camera:WorldToViewportPoint(tp.Position)
            if on and (Vector2.new(sp.X, sp.Y) - Vector2.new(Services.mouse.X, Services.mouse.Y)).Magnitude < 200 then
                local Utils = require(script.Parent.Parent.Core.Utils)
                Utils.mouse1click()
                State.lastTriggerTime = tick()
            end
        end
    end
end

print("[AimbotManager] Loaded")
return AimbotManager
