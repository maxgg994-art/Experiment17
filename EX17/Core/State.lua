-- Core/State.lua
-- Центральная таблица состояния всего чита

local State = {}
local Services = _G.Experiment17.Services

-- Значения по умолчанию для сброса
local defaults = {
    -- System
    panicMode = false,
    currentTab = "Legit",
    bodyGyro = nil,
    bodyVelocity = nil,
    musicPlayer = nil,
    espObjects = {},
    tracersList = {},
    wireframeObjects = {},
    worldOutlines = {},
    waitingForKeybind = nil,
    npcList = {},
    notifications = {},
    toggleSetters = {},
    keybindButtons = {},
    savedCharacterSize = {},
    cachedCoins = {},
    musicPlaylist = {},
    musicCurrentIndex = 1,
    musicPlaying = false,

    -- Timers
    lastStrafeTime = 0,
    lastTriggerTime = 0,
    lastMicroTPTime = 0,
    lastAFKTime = 0,
    lastChatSpamTime = 0,
    lastWallHopTime = 0,
    lastRocketJumpTime = 0,
    lastSpeedBurstTime = 0,
    lastPhaseTime = 0,
    lastRespawnTime = 0,
    lastESPUpdate = 0,
    lastAimAssistTime = 0,
    lastTracerUpdate = 0,
    lastNPCUpdate = 0,
    lastFarmTime = 0,
    lastCoinCache = 0,

    -- Legit
    airStrafe = false,
    airStrafeSpeed = 0,
    airStrafeMaxSpeed = 150,
    jumpPower = 50,
    antiAFK = false,
    antiAFKMode = "Micro",
    antiAFKFrequency = 10,
    noProximityDelay = false,
    antiStaff = false,
    chatSpam = false,
    chatSpamMode = 1,
    chatSpamMinDelay = 2,
    chatSpamMaxDelay = 5,
    chatSpamMessages = "Hello!|GL HF|Nice!|Good luck!",
    safeWalk = false,
    fastInteract = false,
    autoTool = false,
    quickTurn = false,
    wallHop = false,
    wallHopPower = 150,
    step = false,
    stepHeight = 3,
    rocketJump = false,
    rocketJumpPower = 200,
    rocketJumpMode = "Velocity",
    glide = false,
    glideSpeed = 0.95,

    -- Rage
    speedBoost = false,
    speedMultiplier = 2,
    microTP = false,
    microTPDistance = 10,
    fly = false,
    flySpeed = 50,
    flyMode = "CFrame",
    noClip = false,
    spinBot = false,
    spinSpeed = 10,
    gravity = 196.2,
    jumpPowerRage = 50,
    infiniteJump = false,
    speedBurst = false,
    speedBurstPower = 100,
    phase = false,
    phaseDistance = 5,
    reverseWalk = false,
    noSlowdown = false,
    antiRagdoll = false,
    autoRespawn = false,
    antiFreeze = false,
    antiTeleport = false,
    fastLadder = false,
    fastLadderSpeed = 3,
    noCollision = false,
    walkOnWater = false,
    noFallDamage = false,
    fastSwim = false,
    fastSwimSpeed = 3,
    noLavaDamage = false,
    infiniteStamina = false,
    noPush = false,
    autoRotate = false,
    autoRotateSpeed = 5,
    characterSize = 1,
    autoCollisionPush = false,
    pushRotateSpeed = 15,
    pushDirection = 1,
    bodyFacing = false,

    -- Safe
    safeFunctions = false,
    safeFOV = 70,
    safeSpeed = 16,
    safeJump = 50,
    valueUnlocker = false,

    -- Farm
    autoFarm = false,
    coinName = "Coin",
    farmType = "TP",
    farmSpeed = 2,
    farmUseSpawns = false,
    farmSpawnMin = 1,
    farmSpawnMax = 10,
    farmSpawnPrefix = "Spawn",

    -- TP
    teleportTarget = nil,
    teleportDistance = 3,
    teleportPosition = "Behind",
    tpCameraSmooth = 0,

    -- View
    firstPerson = false,
    thirdPerson = true,
    cameraDistance = 10,
    fov = 70,
    mouseUnlocked = false,
    cameraShake = true,
    cameraSpin = false,
    cameraSpinSpeed = 5,
    freecam = false,
    freecamSpeed = 50,
    cameraRoll = 0,
    removeUI = false,
    nightMode = false,
    noCameraClip = false,
    forceView = false,
    transparentUI = false,

    -- Visual
    espEnabled = false,
    espMode = "Highlight",
    espColor = Color3.fromRGB(255, 50, 50),
    espTransparency = 0.3,
    espThickness = 2,
    espShowName = true,
    espShowDistance = true,
    espShowHealth = true,
    tracers = false,
    tracerColor = Color3.fromRGB(255, 255, 255),
    tracerThickness = 0.1,
    espNPC = false,
    wireframe = false,
    wireframeTransparency = 0.8,
    textureTransparency = 0,
    outlineWorld = false,
    outlineWorldColor = Color3.fromRGB(255, 0, 0),
    playerMaterial = "Default",
    playerColor = false,
    playerColorValue = Color3.fromRGB(255, 0, 0),
    rainbowPlayers = false,

    -- Body
    highlightHead = false,
    headColor = Color3.fromRGB(255, 50, 50),
    headTransparency = 0.3,
    highlightTorso = false,
    torsoColor = Color3.fromRGB(50, 255, 50),
    torsoTransparency = 0.3,
    highlightArms = false,
    armsColor = Color3.fromRGB(50, 50, 255),
    armsTransparency = 0.3,
    highlightLegs = false,
    legsColor = Color3.fromRGB(255, 255, 50),
    legsTransparency = 0.3,
    skeletonESP = false,
    skeletonColor = Color3.fromRGB(255, 255, 255),
    highlightOutline = true,
    highlightOutlineColor = Color3.fromRGB(255, 255, 255),
    highlightFillColor = Color3.fromRGB(255, 50, 50),

    -- Aimbot
    aimbotEnabled = false,
    aimbotFOV = 90,
    aimbotSmoothness = 1,
    aimbotTargetPart = "Head",
    aimbotMode = "Crosshair",
    aimbotLockTarget = nil,
    aimbotMaxDistance = 500,
    aimbotIgnoreSpawn = true,
    aimbotIgnoreTeam = true,
    aimbotTargetNPC = true,
    aimbotTargetPlayers = true,
    aimbotPlayerList = {},
    aimbotListMode = "Blacklist",
    aimAssist = false,
    aimAssistStrength = 0.5,
    silentAim = false,
    silentAimFOV = 90,
    silentAimTargetPart = "Head",
    triggerBotEnabled = false,
    triggerBotDelay = 0.1,
    triggerBotTargetPart = "Head",

    -- World
    worldBrightness = 3,
    worldAmbient = Color3.fromRGB(128, 128, 128),
    worldOutdoorAmbient = Color3.fromRGB(128, 128, 128),
    worldExposureCompensation = 0,
    worldEnvDiffuseScale = 1,
    worldEnvSpecularScale = 1,
    worldShadowSoftness = 0.5,
    worldGlobalShadows = true,
    worldClockTime = 14,
    worldAtmosphereEnabled = true,
    worldAtmosphereDensity = 0.3,
    worldAtmosphereOffset = 0,
    worldAtmosphereColor = Color3.fromRGB(200, 200, 255),
    worldAtmosphereGlare = 0,
    worldAtmosphereHaze = 0,
    disableFog = false,
    noTextures = false,

    -- Keys
    toggleGuiKey = "RightShift",
    unlockMouseKey = "LeftAlt",
    flyKey = "F",
    noClipKey = "N",
    airStrafeKey = "V",
    speedBoostKey = "B",
    aimbotKey = "T",
    silentAimKey = "Y",
    triggerBotKey = "G",
    teleportSelectKey = "L",
    teleportExecuteKey = "Slash",
    panicKey = "F8",
    quickTurnKey = "Q",
    rocketJumpKey = "X",
    freecamKey = "P",

    -- Settings
    guiSize = 1,
    guiOpen = true,
    guiBackgroundColor = Color3.fromRGB(0, 0, 0),
    guiStrokeColor = Color3.fromRGB(255, 255, 255),
    guiFrameColor = Color3.fromRGB(5, 5, 5),
    showNotifications = true,
    notificationDuration = 3,
    musicEnabled = false,
    musicURL = "",
    musicVolume = 0.5,
    musicLoop = false,
    clickSound = "None",
    clickVolume = 0.5,

    -- Color Picker
    colorPickerOpen = false,
    colorPickerCallback = nil,
    colorPickerHue = 0,
    colorPickerSat = 1,
    colorPickerVal = 1,
    colorPickerFrame = nil,
}

function State.init()
    -- Копируем все значения по умолчанию
    for k, v in pairs(defaults) do
        if type(v) == "table" then
            State[k] = {}
            for kk, vv in pairs(v) do
                State[k][kk] = vv
            end
        else
            State[k] = v
        end
    end

    -- Особые значения
    State.guiSize = _G.Experiment17.guiScale
    State.fov = 70

    print("[State] Initialized with " .. tostring(#defaults) .. " fields")
end

-- Сброс к значениям по умолчанию
function State.resetToDefaults()
    for k, v in pairs(defaults) do
        if type(v) ~= "table" and type(v) ~= "function" and type(v) ~= "userdata" then
            if State[k] ~= nil then
                State[k] = v
            end
        end
    end
    print("[State] Reset to defaults")
end

-- Быстрое уведомление
function State.notify(text, color)
    local NotificationManager = require(script.Parent.Parent.Managers.NotificationManager)
    NotificationManager.show(text, color)
end

return State
