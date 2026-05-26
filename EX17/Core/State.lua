-- Core/State.lua

local State = {}

function State.init()
    State.guiSize = _G.Experiment17.guiScale
    State.panicMode = false
    State.currentTab = "Legit"
    State.bodyGyro = nil
    State.bodyVelocity = nil
    State.musicPlayer = nil
    State.espObjects = {}
    State.tracersList = {}
    State.wireframeObjects = {}
    State.worldOutlines = {}
    State.waitingForKeybind = nil
    State.npcList = {}
    State.notifications = {}
    State.toggleSetters = {}
    State.keybindButtons = {}
    State.savedCharacterSize = {}
    State.cachedCoins = {}
    State.musicPlaylist = {}
    State.musicCurrentIndex = 1
    State.musicPlaying = false

    State.airStrafe = false; State.airStrafeSpeed = 0; State.airStrafeMaxSpeed = 150
    State.jumpPower = 50; State.antiAFK = false; State.antiAFKMode = "Micro"; State.antiAFKFrequency = 10
    State.chatSpam = false; State.chatSpamMode = 1; State.chatSpamMinDelay = 2; State.chatSpamMaxDelay = 5
    State.chatSpamMessages = "Hello!|GL HF|Nice!|Good luck!"
    State.safeWalk = false; State.fastInteract = false; State.autoTool = false; State.quickTurn = false
    State.wallHop = false; State.wallHopPower = 150; State.step = false; State.stepHeight = 3
    State.rocketJump = false; State.rocketJumpPower = 200; State.rocketJumpMode = "Velocity"
    State.glide = false; State.glideSpeed = 0.95

    State.speedBoost = false; State.speedMultiplier = 2; State.microTP = false; State.microTPDistance = 10
    State.fly = false; State.flySpeed = 50; State.flyMode = "CFrame"; State.noClip = false
    State.spinBot = false; State.spinSpeed = 10; State.gravity = 196.2; State.jumpPowerRage = 50
    State.infiniteJump = false; State.speedBurst = false; State.speedBurstPower = 100
    State.phase = false; State.phaseDistance = 5; State.reverseWalk = false; State.noSlowdown = false
    State.antiRagdoll = false; State.autoRespawn = false; State.antiFreeze = false; State.antiTeleport = false
    State.fastLadder = false; State.fastLadderSpeed = 3; State.noCollision = false
    State.walkOnWater = false; State.noFallDamage = false; State.fastSwim = false; State.fastSwimSpeed = 3
    State.noLavaDamage = false; State.infiniteStamina = false; State.noPush = false
    State.autoRotate = false; State.autoRotateSpeed = 5; State.characterSize = 1
    State.autoCollisionPush = false; State.pushRotateSpeed = 15; State.pushDirection = 1; State.bodyFacing = false

    State.safeFunctions = false; State.safeFOV = 70; State.safeSpeed = 16; State.safeJump = 50
    State.valueUnlocker = false

    State.autoFarm = false; State.coinName = "Coin"; State.farmType = "TP"; State.farmSpeed = 2
    State.farmUseSpawns = false; State.farmSpawnMin = 1; State.farmSpawnMax = 10; State.farmSpawnPrefix = "Spawn"

    State.teleportTarget = nil; State.teleportDistance = 3; State.teleportPosition = "Behind"; State.tpCameraSmooth = 0

    State.firstPerson = false; State.thirdPerson = true; State.cameraDistance = 10
    State.fov = 70; State.mouseUnlocked = false; State.cameraShake = true
    State.cameraSpin = false; State.cameraSpinSpeed = 5; State.freecam = false; State.freecamSpeed = 50
    State.cameraRoll = 0; State.removeUI = false; State.nightMode = false; State.noCameraClip = false
    State.forceView = false; State.transparentUI = false

    State.espEnabled = false; State.espMode = "Highlight"; State.espColor = Color3.fromRGB(255,50,50)
    State.espTransparency = 0.3; State.espThickness = 2; State.espShowName = true
    State.espShowDistance = true; State.espShowHealth = true; State.tracers = false
    State.tracerColor = Color3.fromRGB(255,255,255); State.tracerThickness = 0.1; State.espNPC = false
    State.wireframe = false; State.wireframeTransparency = 0.8; State.textureTransparency = 0
    State.outlineWorld = false; State.outlineWorldColor = Color3.fromRGB(255,0,0)
    State.playerMaterial = "Default"; State.playerColor = false
    State.playerColorValue = Color3.fromRGB(255,0,0); State.rainbowPlayers = false

    State.highlightHead = false; State.headColor = Color3.fromRGB(255,50,50); State.headTransparency = 0.3
    State.highlightTorso = false; State.torsoColor = Color3.fromRGB(50,255,50); State.torsoTransparency = 0.3
    State.highlightArms = false; State.armsColor = Color3.fromRGB(50,50,255); State.armsTransparency = 0.3
    State.highlightLegs = false; State.legsColor = Color3.fromRGB(255,255,50); State.legsTransparency = 0.3
    State.skeletonESP = false; State.skeletonColor = Color3.fromRGB(255,255,255)
    State.highlightOutline = true; State.highlightOutlineColor = Color3.fromRGB(255,255,255)
    State.highlightFillColor = Color3.fromRGB(255,50,50)

    State.aimbotEnabled = false; State.aimbotFOV = 90; State.aimbotSmoothness = 1
    State.aimbotTargetPart = "Head"; State.aimbotMode = "Crosshair"; State.aimbotLockTarget = nil
    State.aimbotMaxDistance = 500; State.aimbotIgnoreSpawn = true; State.aimbotIgnoreTeam = true
    State.aimbotTargetNPC = true; State.aimbotTargetPlayers = true
    State.aimbotPlayerList = {}; State.aimbotListMode = "Blacklist"
    State.aimAssist = false; State.aimAssistStrength = 0.5; State.silentAim = false
    State.silentAimFOV = 90; State.silentAimTargetPart = "Head"; State.triggerBotEnabled = false
    State.triggerBotDelay = 0.1; State.triggerBotTargetPart = "Head"

    State.worldBrightness = 3; State.worldAmbient = Color3.fromRGB(128,128,128)
    State.worldOutdoorAmbient = Color3.fromRGB(128,128,128); State.worldExposureCompensation = 0
    State.worldEnvDiffuseScale = 1; State.worldEnvSpecularScale = 1; State.worldShadowSoftness = 0.5
    State.worldGlobalShadows = true; State.worldClockTime = 14; State.worldAtmosphereEnabled = true
    State.worldAtmosphereDensity = 0.3; State.worldAtmosphereOffset = 0
    State.worldAtmosphereColor = Color3.fromRGB(200,200,255); State.worldAtmosphereGlare = 0
    State.worldAtmosphereHaze = 0; State.disableFog = false; State.noTextures = false

    State.toggleGuiKey = "RightShift"; State.unlockMouseKey = "LeftAlt"; State.flyKey = "F"
    State.noClipKey = "N"; State.airStrafeKey = "V"; State.speedBoostKey = "B"
    State.aimbotKey = "T"; State.silentAimKey = "Y"; State.triggerBotKey = "G"
    State.teleportSelectKey = "L"; State.teleportExecuteKey = "Slash"; State.panicKey = "F8"
    State.quickTurnKey = "Q"; State.rocketJumpKey = "X"; State.freecamKey = "P"

    State.guiOpen = true; State.guiBackgroundColor = Color3.fromRGB(0,0,0)
    State.guiStrokeColor = Color3.fromRGB(255,255,255); State.guiFrameColor = Color3.fromRGB(5,5,5)
    State.showNotifications = true; State.notificationDuration = 3; State.musicEnabled = false
    State.musicURL = ""; State.musicVolume = 0.5; State.musicLoop = false
    State.clickSound = "None"; State.clickVolume = 0.5

    State.colorPickerOpen = false; State.colorPickerCallback = nil
    State.colorPickerHue = 0; State.colorPickerSat = 1; State.colorPickerVal = 1; State.colorPickerFrame = nil

    print("[State] Initialized")
end

return State
