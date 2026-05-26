-- Managers/FarmManager.lua

local Services = _G.Experiment17.Services
local State = _G.Experiment17.State
local Utils = _G.Experiment17.Utils
local FarmManager = {}

function FarmManager.updateCache()
    Utils.updateCoinCache(State.coinName, State.cachedCoins)
    State.lastCoinCache = tick()
end

function FarmManager.farm()
    if not State.autoFarm then return end
    if tick() - State.lastFarmTime < 0.2 then return end

    local char = Services.player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    if tick() - State.lastCoinCache > 3 then
        FarmManager.updateCache()
    end

    local nearest = nil
    local nearestDist = math.huge

    -- Поиск по спавнам
    if State.farmUseSpawns then
        for i = State.farmSpawnMin, State.farmSpawnMax do
            local sp = workspace:FindFirstChild(State.farmSpawnPrefix .. i)
            if sp then
                local part = sp:IsA("BasePart") and sp or (sp:IsA("Model") and sp.PrimaryPart)
                if part and part:IsA("BasePart") then
                    local d = (part.Position - root.Position).Magnitude
                    if d < nearestDist then nearestDist = d; nearest = part end
                end
            end
        end
    end

    -- Поиск по кэшу
    if not nearest then
        for _, coin in ipairs(State.cachedCoins) do
            if coin and coin.Parent then
                local d = (coin.Position - root.Position).Magnitude
                if d < nearestDist then nearestDist = d; nearest = coin end
            end
        end
    end

    -- Перемещение
    if nearest and nearestDist > 2 then
        if State.farmType == "TP" then
            root.CFrame = CFrame.new(nearest.Position + Vector3.new(0, 3, 0))
        elseif State.farmType == "Pathfind" then
            if not State.farmPathfind then
                local path = Services.PathfindingService:CreatePath({
                    AgentRadius = 2, AgentHeight = 5, AgentCanJump = true,
                })
                path:ComputeAsync(root.Position, nearest.Position + Vector3.new(0, 3, 0))
                if path.Status == Enum.PathStatus.Success then
                    State.farmPathfind = path
                end
            end
            if State.farmPathfind then
                local wps = State.farmPathfind:GetWaypoints()
                if #wps > 0 then
                    hum:MoveTo(wps[1].Position)
                    if (root.Position - wps[1].Position).Magnitude < 3 then
                        table.remove(wps, 1)
                    end
                else
                    State.farmPathfind = nil
                end
            end
        end
    elseif State.farmPathfind then
        State.farmPathfind = nil
    end

    State.lastFarmTime = tick()
end

function FarmManager.cleanup()
    if not State.autoFarm and State.farmPathfind then
        State.farmPathfind = nil
    end
end

return FarmManager
