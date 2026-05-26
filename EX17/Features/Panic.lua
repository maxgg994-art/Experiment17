-- Features/Panic.lua
-- Panic Mode + Safe Functions

local Panic = {}
local Services = _G.Experiment17.Services
local State = require(script.Parent.Parent.Core.State)
local ESPManager = require(script.Parent.Parent.Managers.ESPManager)
local WorldManager = require(script.Parent.Parent.Managers.WorldManager)
local MusicManager = require(script.Parent.Parent.Managers.MusicManager)
local NotificationManager = require(script.Parent.Parent.Managers.NotificationManager)

function Panic.shutdown()
    -- Отключаем все булевы функции
    for k, v in pairs(State) do
        if type(v) == "boolean" and k ~= "guiOpen" and k ~= "showNotifications" and k ~= "safeFunctions" then
            State[k] = false
        end
    end

    -- Сбрасываем числовые значения
    State.gravity = 196.2
    State.characterSize = 1
    State.jumpPower = 50
    State.jumpPowerRage = 50
    State.freecamSpeed = 50
    State.cameraRoll = 0
    State.speedMultiplier = 2
    State.flySpeed = 50
    State.spinSpeed = 10
    State.speedBurstPower = 100
    State.phaseDistance = 5
    State.fastLadderSpeed = 3
    State.fastSwimSpeed = 3
    State.autoRotateSpeed = 5
    State.pushRotateSpeed = 15
    State.cameraDistance = 10
    State.fov = 70
    State.teleportDistance = 3
    State.aimbotFOV = 90
    State.aimbotSmoothness = 1
    State.aimbotMaxDistance = 500
    State.aimAssistStrength = 0.5
    State.silentAimFOV = 90
    State.triggerBotDelay = 0.1
    State.musicVolume = 0.5
    State.guiSize = _G.Experiment17.guiScale
    State.clickVolume = 0.5
    State.textureTransparency = 0
    State.wireframeTransparency = 0.8
    State.farmSpeed = 2

    -- Сбрасываем цвета
    State.espColor = Color3.fromRGB(255, 50, 50)
    State.tracerColor = Color3.fromRGB(255, 255, 255)
    State.outlineWorldColor = Color3.fromRGB(255, 0, 0)
    State.playerColorValue = Color3.fromRGB(255, 0, 0)
    State.headColor = Color3.fromRGB(255, 50, 50)
    State.torsoColor = Color3.fromRGB(50, 255, 50)
    State.armsColor = Color3.fromRGB(50, 50, 255)
    State.legsColor = Color3.fromRGB(255, 255, 50)
    State.skeletonColor = Color3.fromRGB(255, 255, 255)
    State.highlightOutlineColor = Color3.fromRGB(255, 255, 255)
    State.highlightFillColor = Color3.fromRGB(255, 50, 50)
    State.worldAmbient = Color3.fromRGB(128, 128, 128)
    State.worldOutdoorAmbient = Color3.fromRGB(128, 128, 128)
    State.worldAtmosphereColor = Color3.fromRGB(200, 200, 255)
    State.guiStrokeColor = Color3.fromRGB(255, 255, 255)
    State.guiBackgroundColor = Color3.fromRGB(0, 0, 0)
    State.guiFrameColor = Color3.fromRGB(5, 5, 5)
    State.clickSound = "None"
    State.aimbotPlayerList = {}
    State.aimbotListMode = "Blacklist"
    State.coinName = "Coin"
    State.farmType = "TP"
    State.farmUseSpawns = false
    State.farmSpawnMin = 1
    State.farmSpawnMax = 10
    State.farmSpawnPrefix = "Spawn"
    table.clear(State.cachedCoins)
    table.clear(State.musicPlaylist)
    State.musicCurrentIndex = 1
    State.musicPlaying = false

    -- Удаляем физические объекты
    if State.bodyGyro then State.bodyGyro:Destroy(); State.bodyGyro = nil end
    if State.bodyVelocity then State.bodyVelocity:Destroy(); State.bodyVelocity = nil end
    if State.farmPathfind then State.farmPathfind = nil end

    -- Останавливаем музыку
    MusicManager.stop()

    -- Очищаем ESP и Wireframe
    ESPManager.clearAll()
    WorldManager.applyWireframe(false)
    WorldManager.applyOutlineWorld(false)

    -- Сбрасываем камеру и гравитацию
    Services.camera.FieldOfView = 70
    workspace.Gravity = 196.2

    -- Сбрасываем персонажа
    if Services.player.Character then
        local hum = Services.player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
            hum.PlatformStand = false
        end
    end

    -- Включаем стандартный GUI
    Services.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
    Services.playerGui.Enabled = true

    -- Обновляем все тумблеры в GUI
    for name, setter in pairs(State.toggleSetters) do
        if setter then setter(false) end
    end

    NotificationManager.show("PANIC MODE - All disabled", Color3.fromRGB(255, 0, 0))
end

function Panic.applySafeFunctions()
    if not State.safeFunctions then return end

    State.fly = false
    State.noClip = false
    State.speedBoost = false
    State.speedMultiplier = 2
    State.reverseWalk = false
    State.noSlowdown = false
    State.phase = false
    State.microTP = false
    State.spinBot = false
    State.infiniteJump = false
    State.speedBurst = false
    State.antiRagdoll = false
    State.antiFreeze = false
    State.noCollision = false
    State.walkOnWater = false
    State.autoRotate = false
    State.characterSize = 1
    State.autoCollisionPush = false
    State.bodyFacing = false

    if State.bodyGyro then State.bodyGyro:Destroy(); State.bodyGyro = nil end
    if State.bodyVelocity then State.bodyVelocity:Destroy(); State.bodyVelocity = nil end

    if Services.player.Character then
        local hum = Services.player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = State.safeSpeed
            hum.JumpPower = State.safeJump
        end
    end

    Services.camera.FieldOfView = State.safeFOV
    State.fov = State.safeFOV
    workspace.Gravity = 196.2
    State.gravity = 196.2

    for name, setter in pairs(State.toggleSetters) do
        if setter then setter(false) end
    end

    NotificationManager.show("Safe Functions: ON", Color3.fromRGB(0, 255, 0))
end

return Panic
