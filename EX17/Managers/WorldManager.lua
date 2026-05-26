-- Managers/WorldManager.lua
-- Визуальные настройки мира: Wireframe, Outline, текстуры, освещение, погода, пресеты

local WorldManager = {}
local Services = require(script.Parent.Parent.Core.Services)
local Utils = require(script.Parent.Parent.Core.Utils)
local State = require(script.Parent.Parent.Core.State)

-- Применение проволочного режима
function WorldManager.applyWireframe(on)
    -- Очистка старых
    for _, obj in ipairs(State.wireframeObjects) do
        pcall(function() obj:Destroy() end)
    end
    table.clear(State.wireframeObjects)

    if not on then return end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Transparency < 0.9 then
            local skip = false
            local parent = obj.Parent
            while parent do
                if parent:IsA("Model") and Services.Players:GetPlayerFromCharacter(parent) then
                    skip = true
                    break
                end
                parent = parent.Parent
            end
            if not skip then
                local hl = Instance.new("Highlight")
                hl.FillTransparency = 1
                hl.OutlineTransparency = 0.1
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = obj
                table.insert(State.wireframeObjects, hl)
            end
        end
    end
end

-- Прозрачность текстур
function WorldManager.applyTextureTransparency(val)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Decal") or obj:IsA("Texture") then
            local skip = false
            local parent = obj.Parent
            while parent do
                if parent:IsA("Model") and Services.Players:GetPlayerFromCharacter(parent) then
                    skip = true
                    break
                end
                parent = parent.Parent
            end
            if not skip then
                pcall(function() obj.Transparency = val / 100 end)
            end
        end
    end
end

-- Обводка мира
function WorldManager.applyOutlineWorld(on)
    for _, obj in ipairs(State.worldOutlines) do
        pcall(function() obj:Destroy() end)
    end
    table.clear(State.worldOutlines)

    if not on then return end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Transparency < 0.9 then
            local skip = false
            local parent = obj.Parent
            while parent do
                if parent:IsA("Model") and Services.Players:GetPlayerFromCharacter(parent) then
                    skip = true
                    break
                end
                parent = parent.Parent
            end
            if not skip then
                local hl = Instance.new("Highlight")
                hl.FillTransparency = 1
                hl.OutlineColor = State.outlineWorldColor
                hl.OutlineTransparency = 0
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = obj
                table.insert(State.worldOutlines, hl)
            end
        end
    end
end

-- Нет текстур
function WorldManager.applyNoTextures()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Decal") or obj:IsA("Texture") then
            local skip = false
            local parent = obj.Parent
            while parent do
                if parent:IsA("Model") and Services.Players:GetPlayerFromCharacter(parent) then
                    skip = true
                    break
                end
                parent = parent.Parent
            end
            if not skip then
                pcall(function() obj.Transparency = 1 end)
            end
        end
    end
end

-- Применение всех настроек мира
function WorldManager.applyWorldSettings()
    local L = Services.Lighting

    L.Brightness = State.worldBrightness
    L.Ambient = State.worldAmbient
    L.OutdoorAmbient = State.worldOutdoorAmbient
    L.ExposureCompensation = State.worldExposureCompensation
    L.EnvironmentDiffuseScale = State.worldEnvDiffuseScale
    L.EnvironmentSpecularScale = State.worldEnvSpecularScale
    L.ShadowSoftness = State.worldShadowSoftness
    L.GlobalShadows = State.worldGlobalShadows
    L.ClockTime = State.worldClockTime

    -- Atmosphere
    local atm = L:FindFirstChild("Atmosphere") or Instance.new("Atmosphere")
    atm.Name = "Atmosphere"
    atm.Parent = L
    atm.Visible = State.worldAtmosphereEnabled
    atm.Density = State.worldAtmosphereDensity
    atm.Offset = State.worldAtmosphereOffset
    atm.Color = State.worldAtmosphereColor
    atm.Glare = State.worldAtmosphereGlare
    atm.Haze = State.worldAtmosphereHaze

    -- Fog
    if State.disableFog then
        local fog = L:FindFirstChild("Fog") or Instance.new("Fog")
        fog.Name = "Fog"
        fog.Parent = L
        fog.FogEnd = 99999
        fog.FogStart = 99999
    end

    -- No Textures
    if State.noTextures then
        WorldManager.applyNoTextures()
    end
end

-- Чтение текущих настроек
function WorldManager.readCurrentSettings()
    local L = Services.Lighting
    State.worldBrightness = L.Brightness
    State.worldAmbient = L.Ambient
    State.worldOutdoorAmbient = L.OutdoorAmbient
    State.worldExposureCompensation = L.ExposureCompensation
    State.worldEnvDiffuseScale = L.EnvironmentDiffuseScale
    State.worldEnvSpecularScale = L.EnvironmentSpecularScale
    State.worldShadowSoftness = L.ShadowSoftness
    State.worldGlobalShadows = L.GlobalShadows
    State.worldClockTime = L.ClockTime

    local atm = L:FindFirstChild("Atmosphere")
    if atm then
        State.worldAtmosphereEnabled = atm.Visible
        State.worldAtmosphereDensity = atm.Density
        State.worldAtmosphereOffset = atm.Offset
        State.worldAtmosphereColor = atm.Color
        State.worldAtmosphereGlare = atm.Glare
        State.worldAtmosphereHaze = atm.Haze
    end
end

-- Пресеты
function WorldManager.applyPreset(name)
    local presets = {
        Potato = {2, Color3.fromRGB(50,50,50), Color3.fromRGB(50,50,50), 0, 0.5, 0.5, 0, false, 14, false, 0.1, 0, Color3.fromRGB(200,200,255), 0, 0},
        Realistic = {4, Color3.fromRGB(100,100,100), Color3.fromRGB(130,140,160), 0.5, 1, 1, 0.5, true, 14, true, 0.3, 0, Color3.fromRGB(200,220,255), 0.1, 0.5},
        Surreal = {8, Color3.fromRGB(180,150,200), Color3.fromRGB(200,180,255), 1.5, 2, 2, 1, true, 18, true, 0.5, 0.2, Color3.fromRGB(255,180,200), 0.5, 2},
        Default = {3, Color3.fromRGB(128,128,128), Color3.fromRGB(128,128,128), 0, 1, 1, 0.5, true, 14, true, 0.3, 0, Color3.fromRGB(200,200,255), 0, 0},
        Horror = {0.5, Color3.fromRGB(20,20,30), Color3.fromRGB(10,10,20), -1, 0.3, 0.3, 0, false, 0, true, 0.8, 0, Color3.fromRGB(100,0,0), 0, 3},
        Fullbright = {10, Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255), 0, 1, 1, 0, false, 14, false, 0, 0, Color3.fromRGB(200,200,255), 0, 0},
    }

    local p = presets[name]
    if not p then return end

    State.worldBrightness = p[1]
    State.worldAmbient = p[2]
    State.worldOutdoorAmbient = p[3]
    State.worldExposureCompensation = p[4]
    State.worldEnvDiffuseScale = p[5]
    State.worldEnvSpecularScale = p[6]
    State.worldShadowSoftness = p[7]
    State.worldGlobalShadows = p[8]
    State.worldClockTime = p[9]
    State.worldAtmosphereEnabled = p[10]
    State.worldAtmosphereDensity = p[11]
    State.worldAtmosphereOffset = p[12]
    State.worldAtmosphereColor = p[13]
    State.worldAtmosphereGlare = p[14]
    State.worldAtmosphereHaze = p[15]

    WorldManager.applyWorldSettings()
end

print("[WorldManager] Loaded")
return WorldManager
