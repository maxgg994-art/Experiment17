-- Tabs/SwitchContent.lua
-- Все 11 вкладок: Legit, Rage, Aimbot, Visual, Body, TP, View, World, Farm, Keys, Settings

local SwitchContent = {}
local Services = require(script.Parent.Parent.Core.Services)
local State = require(script.Parent.Parent.Core.State)
local Utils = require(script.Parent.Parent.Core.Utils)
local GUIManager = require(script.Parent.Parent.Managers.GUIManager)
local UIFactory = require(script.Parent.Parent.Managers.UIFactory)
local WorldManager = require(script.Parent.Parent.Managers.WorldManager)
local ESPManager = require(script.Parent.Parent.Managers.ESPManager)
local MusicManager = require(script.Parent.Parent.Managers.MusicManager)
local NotificationManager = require(script.Parent.Parent.Managers.NotificationManager)
local Panic = require(script.Parent.Parent.Features.Panic)

local sf1, sf2 -- ScrollingFrames
local catBtns

function SwitchContent.init()
    sf1 = GUIManager.getScrollingFrame1()
    sf2 = GUIManager.getScrollingFrame2()
    catBtns = GUIManager.getCatBtns()

    -- Привязываем категории
    for name, btn in pairs(catBtns) do
        btn.MouseButton1Click:Connect(function()
            State.currentTab = name
            SwitchContent.switch(name)
        end)
    end
end

function SwitchContent.switch(tab)
    -- Очистка
    for _, c in ipairs(sf1:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    for _, c in ipairs(sf2:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end

    table.clear(State.toggleSetters)

    -- Подсветка
    for _, btn in pairs(catBtns) do btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30) end
    if catBtns[tab] then catBtns[tab].BackgroundColor3 = Color3.fromRGB(70, 70, 200) end

    sf2.Visible = true
    sf1.Size = UDim2.new(0.5, -8, 1, -10)
    sf1.Position = UDim2.new(0, 5, 0, 5)

    local function tb(parent, name, key, cb, o)
        State.toggleSetters[key] = UIFactory.addThumbler(
            UIFactory.createFunctionFrame(parent, name, o), State[key],
            cb or function(s) State[key] = s end
        )
        return o + 1
    end

    local function sl(parent, name, min, max, val, cb, o)
        UIFactory.addSlider(UIFactory.createFunctionFrame(parent, name, o), min, max, val, cb or function(v) State[name] = v end)
        return o + 1
    end

    local function fs(parent, name, min, max, val, cb, o)
        UIFactory.addFloatSlider(UIFactory.createFunctionFrame(parent, name, o), min, max, val, cb or function(v) State[name] = v end)
        return o + 1
    end

    -- ========================================
    -- LEGIT
    -- ========================================
    if tab == "Legit" then
        local o = 1
        o = tb(sf1, "AirStrafe", "airStrafe", function(s) State.airStrafe = s; if not s then State.airStrafeSpeed = 0 end end, o)
        o = sl(sf1, "Max Speed", 20, 150, State.airStrafeMaxSpeed, function(v) State.airStrafeMaxSpeed = v end, o)
        o = sl(sf1, "Jump Power", 0, 300, State.jumpPower, function(v) State.jumpPower = v end, o)
        o = tb(sf1, "Anti AFK", "antiAFK", nil, o)
        o = o + 1; UIFactory.addDropdown(UIFactory.createFunctionFrame(sf1, "AFK Mode", o), {"Micro", "Normal"}, State.antiAFKMode, function(v) State.antiAFKMode = v end)
        o = sl(sf1, "AFK Freq (s)", 1, 30, State.antiAFKFrequency, function(v) State.antiAFKFrequency = v end, o)
        o = tb(sf1, "No Prox Delay", "noProximityDelay", nil, o)
        o = tb(sf1, "Anti Staff", "antiStaff", nil, o)
        o = tb(sf1, "Safe Walk", "safeWalk", nil, o)
        o = tb(sf1, "Fast Interact", "fastInteract", nil, o)
        o = tb(sf1, "Auto Tool", "autoTool", nil, o)

        o = 1
        o = tb(sf2, "Chat Spam", "chatSpam", nil, o)
        o = sl(sf2, "Min Delay", 1, 10, State.chatSpamMinDelay, function(v) State.chatSpamMinDelay = v end, o)
        o = sl(sf2, "Max Delay", 1, 30, State.chatSpamMaxDelay, function(v) State.chatSpamMaxDelay = v end, o)
        o = o + 1
        local mf = UIFactory.createFunctionFrame(sf2, "Messages", o)
        local mb = Instance.new("TextBox"); mb.Size = UDim2.new(1, -16, 0, 22); mb.Position = UDim2.new(0, 10, 0, 28)
        mb.BackgroundColor3 = Color3.fromRGB(30, 30, 30); mb.Text = State.chatSpamMessages
        mb.TextColor3 = Color3.fromRGB(255, 255, 255); mb.Font = Enum.Font.Oswald; mb.TextSize = 11
        mb.PlaceholderText = "Msg1|Msg2|Msg3"; mb.Parent = mf
        Utils.removeSelection(mb); Utils.addCorner(mb, 5)
        mb:GetPropertyChangedSignal("Text"):Connect(function() State.chatSpamMessages = mb.Text end)
        o = tb(sf2, "Wall Hop", "wallHop", nil, o)
        o = sl(sf2, "Wall Hop Power", 50, 300, State.wallHopPower, function(v) State.wallHopPower = v end, o)
        o = tb(sf2, "Step", "step", nil, o)
        o = sl(sf2, "Step Height", 1, 10, State.stepHeight, function(v) State.stepHeight = v end, o)
        o = tb(sf2, "Rocket Jump", "rocketJump", nil, o)
        o = o + 1; UIFactory.addDropdown(UIFactory.createFunctionFrame(sf2, "RJ Mode", o), {"Velocity", "CFrame"}, State.rocketJumpMode, function(v) State.rocketJumpMode = v end)
        o = sl(sf2, "Rocket Power", 100, 500, State.rocketJumpPower, function(v) State.rocketJumpPower = v end, o)
        o = tb(sf2, "Glide", "glide", nil, o)
        o = fs(sf2, "Glide Speed", 0.8, 0.99, State.glideSpeed, function(v) State.glideSpeed = v end, o)

    -- ========================================
    -- RAGE
    -- ========================================
    elseif tab == "Rage" then
        local o = 1
        o = tb(sf1, "Speed Boost", "speedBoost", function(s) State.speedBoost = s; if State.safeFunctions and s then Panic.applySafeFunctions() end end, o)
        o = sl(sf1, "Speed Multi", 1, 30, State.speedMultiplier, function(v) State.speedMultiplier = v end, o)
        o = tb(sf1, "Micro TP", "microTP", nil, o)
        o = sl(sf1, "Micro TP Dist", 1, 50, State.microTPDistance, function(v) State.microTPDistance = v end, o)
        o = tb(sf1, "Fly", "fly", function(s) State.fly = s; if State.safeFunctions and s then Panic.applySafeFunctions() end end, o)
        o = o + 1; UIFactory.addDropdown(UIFactory.createFunctionFrame(sf1, "Fly Mode", o), {"BodyVelocity", "CFrame"}, State.flyMode, function(v) State.flyMode = v end)
        o = sl(sf1, "Fly Speed", 20, 200, State.flySpeed, function(v) State.flySpeed = v end, o)
        o = tb(sf1, "NoClip", "noClip", function(s) State.noClip = s; if State.safeFunctions and s then Panic.applySafeFunctions() end end, o)
        o = tb(sf1, "SpinBot", "spinBot", nil, o)
        o = sl(sf1, "Spin Speed", 1, 30, State.spinSpeed, function(v) State.spinSpeed = v end, o)
        o = fs(sf1, "Gravity", 0, 200, State.gravity, function(v) State.gravity = v; workspace.Gravity = v end, o)
        o = sl(sf1, "Jump Power", 0, 1000, State.jumpPowerRage, function(v) State.jumpPowerRage = v end, o)
        o = tb(sf1, "Inf Jump", "infiniteJump", nil, o)
        o = tb(sf1, "Speed Burst", "speedBurst", nil, o)
        o = sl(sf1, "Burst Power", 50, 500, State.speedBurstPower, function(v) State.speedBurstPower = v end, o)
        o = tb(sf1, "Phase", "phase", nil, o)
        o = sl(sf1, "Phase Dist", 1, 20, State.phaseDistance, function(v) State.phaseDistance = v end, o)

        o = 1
        o = tb(sf2, "Reverse Walk", "reverseWalk", function(s) State.reverseWalk = s; if State.safeFunctions and s then Panic.applySafeFunctions() end end, o)
        o = tb(sf2, "No Slowdown", "noSlowdown", nil, o)
        o = tb(sf2, "Anti Ragdoll", "antiRagdoll", nil, o)
        o = tb(sf2, "Auto Respawn", "autoRespawn", nil, o)
        o = tb(sf2, "Anti Freeze", "antiFreeze", nil, o)
        o = tb(sf2, "Anti TP", "antiTeleport", nil, o)
        o = tb(sf2, "Fast Ladder", "fastLadder", nil, o)
        o = sl(sf2, "Ladder Speed", 1, 10, State.fastLadderSpeed, function(v) State.fastLadderSpeed = v end, o)
        o = tb(sf2, "No Collision", "noCollision", nil, o)
        o = tb(sf2, "Walk On Water", "walkOnWater", nil, o)
        o = tb(sf2, "No Fall Dmg", "noFallDamage", nil, o)
        o = tb(sf2, "Fast Swim", "fastSwim", nil, o)
        o = sl(sf2, "Swim Speed", 1, 10, State.fastSwimSpeed, function(v) State.fastSwimSpeed = v end, o)
        o = tb(sf2, "No Lava Dmg", "noLavaDamage", nil, o)
        o = tb(sf2, "Inf Stamina", "infiniteStamina", nil, o)
        o = tb(sf2, "No Push", "noPush", nil, o)
        o = tb(sf2, "Auto Rotate", "autoRotate", nil, o)
        o = sl(sf2, "Rotate Speed", 1, 20, State.autoRotateSpeed, function(v) State.autoRotateSpeed = v end, o)
        o = fs(sf2, "Char Size", 0.5, 3, State.characterSize, function(v) State.characterSize = v end, o)
        o = tb(sf2, "Collision Push", "autoCollisionPush", nil, o)
        o = sl(sf2, "Push Speed", 5, 50, State.pushRotateSpeed, function(v) State.pushRotateSpeed = v end, o)
        o = tb(sf2, "Body Facing", "bodyFacing", nil, o)

    -- ========================================
    -- AIMBOT
    -- ========================================
    elseif tab == "Aimbot" then
        local o = 1
        o = tb(sf1, "Aimbot", "aimbotEnabled", nil, o)
        o = o + 1; UIFactory.addDropdown(UIFactory.createFunctionFrame(sf1, "Mode", o), {"Crosshair","Cursor","Closest","Lock"}, State.aimbotMode, function(v) State.aimbotMode = v end)
        o = sl(sf1, "FOV", 10, 360, State.aimbotFOV, function(v) State.aimbotFOV = v end, o)
        o = sl(sf1, "Smoothness", 1, 20, State.aimbotSmoothness, function(v) State.aimbotSmoothness = v end, o)
        o = o + 1; UIFactory.addDropdown(UIFactory.createFunctionFrame(sf1, "Target Part", o), {"Head","Torso","HumanoidRootPart"}, State.aimbotTargetPart, function(v) State.aimbotTargetPart = v end)
        o = sl(sf1, "Max Distance", 50, 2000, State.aimbotMaxDistance, function(v) State.aimbotMaxDistance = v end, o)
        o = tb(sf1, "Target NPC", "aimbotTargetNPC", nil, o)
        o = tb(sf1, "Target Players", "aimbotTargetPlayers", nil, o)
        o = tb(sf1, "Ignore Spawn", "aimbotIgnoreSpawn", nil, o)
        o = tb(sf1, "Ignore Team", "aimbotIgnoreTeam", nil, o)
        o = o + 1; UIFactory.addDropdown(UIFactory.createFunctionFrame(sf1, "List Mode", o), {"Blacklist","Whitelist"}, State.aimbotListMode, function(v) State.aimbotListMode = v end)
        o = o + 1
        local lf = UIFactory.createFunctionFrame(sf1, "Player List", o)
        local lb = Instance.new("TextBox"); lb.Size = UDim2.new(1, -16, 0, 22); lb.Position = UDim2.new(0, 10, 0, 28)
        lb.BackgroundColor3 = Color3.fromRGB(30, 30, 30); lb.Text = table.concat(State.aimbotPlayerList, ",")
        lb.TextColor3 = Color3.fromRGB(255, 255, 255); lb.Font = Enum.Font.Oswald; lb.TextSize = 11
        lb.PlaceholderText = "Player1,Player2,..."; lb.Parent = lf
        Utils.removeSelection(lb); Utils.addCorner(lb, 5)
        lb.FocusLost:Connect(function()
            table.clear(State.aimbotPlayerList)
            for n in string.gmatch(lb.Text, "[^,]+") do table.insert(State.aimbotPlayerList, n:match("^%s*(.-)%s*$")) end
        end)

        o = 1
        o = tb(sf2, "Aim Assist", "aimAssist", nil, o)
        o = fs(sf2, "Assist Strength", 0.1, 1, State.aimAssistStrength, function(v) State.aimAssistStrength = v end, o)
        o = tb(sf2, "Silent Aim", "silentAim", nil, o)
        o = sl(sf2, "Silent FOV", 10, 360, State.silentAimFOV, function(v) State.silentAimFOV = v end, o)
        o = o + 1; UIFactory.addDropdown(UIFactory.createFunctionFrame(sf2, "Silent Part", o), {"Head","Torso","HumanoidRootPart"}, State.silentAimTargetPart, function(v) State.silentAimTargetPart = v end)
        o = tb(sf2, "Trigger Bot", "triggerBotEnabled", nil, o)
        o = sl(sf2, "Delay (ms)", 0, 500, State.triggerBotDelay * 1000, function(v) State.triggerBotDelay = v / 1000 end, o)
        o = o + 1; UIFactory.addDropdown(UIFactory.createFunctionFrame(sf2, "Trig Part", o), {"Head","Torso","HumanoidRootPart"}, State.triggerBotTargetPart, function(v) State.triggerBotTargetPart = v end)

    -- ========================================
    -- VISUAL
    -- ========================================
    elseif tab == "Visual" then
        local o = 1
        o = tb(sf1, "Enable ESP", "espEnabled", function(s) State.espEnabled = s; if s then ESPManager.refreshAll() else ESPManager.clearAll() end end, o)
        o = o + 1; UIFactory.addDropdown(UIFactory.createFunctionFrame(sf1, "ESP Mode", o), {"Highlight","Box","Both"}, State.espMode, function(v) State.espMode = v; ESPManager.refreshAll() end)
        o = tb(sf1, "ESP NPC", "espNPC", function(s) State.espNPC = s; ESPManager.refreshAll() end, o)
        UIFactory.addColorSlider(sf1, "ESP Color", function(c) State.espColor = c; ESPManager.refreshAll() end); o = o + 1
        o = sl(sf1, "Transparency", 0, 100, State.espTransparency * 100, function(v) State.espTransparency = v / 100; ESPManager.refreshAll() end, o)
        o = sl(sf1, "Box Thickness", 1, 10, State.espThickness, function(v) State.espThickness = v; ESPManager.refreshAll() end, o)
        o = tb(sf1, "Show Name", "espShowName", function(s) State.espShowName = s; ESPManager.refreshAll() end, o)
        o = tb(sf1, "Show Dist", "espShowDistance", function(s) State.espShowDistance = s; ESPManager.refreshAll() end, o)
        o = tb(sf1, "Show Health", "espShowHealth", function(s) State.espShowHealth = s; ESPManager.refreshAll() end, o)

        o = 1
        o = tb(sf2, "Tracers", "tracers", function(s) State.tracers = s; ESPManager.refreshAll() end, o)
        UIFactory.addColorSlider(sf2, "Tracer Color", function(c) State.tracerColor = c; ESPManager.refreshAll() end); o = o + 1
        o = tb(sf2, "Wireframe", "wireframe", function(s) State.wireframe = s; WorldManager.applyWireframe(s) end, o)
        o = sl(sf2, "WF Transp", 0, 100, State.wireframeTransparency * 100, function(v) State.wireframeTransparency = v / 100; if State.wireframe then WorldManager.applyWireframe(true) end end, o)
        o = tb(sf2, "Texture Trans", "textureTransparency", function(s) State.textureTransparency = s and 50 or 0; WorldManager.applyTextureTransparency(State.textureTransparency) end, o)
        o = tb(sf2, "Outline World", "outlineWorld", function(s) State.outlineWorld = s; WorldManager.applyOutlineWorld(s) end, o)
        UIFactory.addColorSlider(sf2, "Outline Color", function(c) State.outlineWorldColor = c; if State.outlineWorld then WorldManager.applyOutlineWorld(true) end end); o = o + 1
        o = o + 1; UIFactory.addDropdown(UIFactory.createFunctionFrame(sf2, "Player Mat", o), {"Default","Glass","ForceField","Neon","SmoothPlastic","Metal","Wood"}, State.playerMaterial, function(v) State.playerMaterial = v; ESPManager.refreshAll() end)
        o = tb(sf2, "Player Color", "playerColor", function(s) State.playerColor = s; ESPManager.refreshAll() end, o)
        UIFactory.addColorSlider(sf2, "P. Color", function(c) State.playerColorValue = c; if State.playerColor then ESPManager.refreshAll() end end); o = o + 1
        o = tb(sf2, "Rainbow", "rainbowPlayers", function(s) State.rainbowPlayers = s; ESPManager.refreshAll() end, o)

    -- ========================================
    -- BODY
    -- ========================================
    elseif tab == "Body" then
        local o = 1
        o = tb(sf1, "Head", "highlightHead", function(s) State.highlightHead = s; ESPManager.refreshAll() end, o)
        UIFactory.addColorSlider(sf1, "Head Color", function(c) State.headColor = c; ESPManager.refreshAll() end); o = o + 1
        o = sl(sf1, "Head Trans", 0, 100, State.headTransparency * 100, function(v) State.headTransparency = v / 100; ESPManager.refreshAll() end, o)
        o = tb(sf1, "Torso", "highlightTorso", function(s) State.highlightTorso = s; ESPManager.refreshAll() end, o)
        UIFactory.addColorSlider(sf1, "Torso Color", function(c) State.torsoColor = c; ESPManager.refreshAll() end); o = o + 1
        o = sl(sf1, "Torso Trans", 0, 100, State.torsoTransparency * 100, function(v) State.torsoTransparency = v / 100; ESPManager.refreshAll() end, o)
        o = tb(sf1, "HL Outline", "highlightOutline", function(s) State.highlightOutline = s; ESPManager.refreshAll() end, o)
        UIFactory.addColorSlider(sf1, "Outline Col", function(c) State.highlightOutlineColor = c; ESPManager.refreshAll() end); o = o + 1
        UIFactory.addColorSlider(sf1, "Fill Color", function(c) State.highlightFillColor = c; ESPManager.refreshAll() end); o = o + 1

        o = 1
        o = tb(sf2, "Arms", "highlightArms", function(s) State.highlightArms = s; ESPManager.refreshAll() end, o)
        UIFactory.addColorSlider(sf2, "Arms Color", function(c) State.armsColor = c; ESPManager.refreshAll() end); o = o + 1
        o = sl(sf2, "Arms Trans", 0, 100, State.armsTransparency * 100, function(v) State.armsTransparency = v / 100; ESPManager.refreshAll() end, o)
        o = tb(sf2, "Legs", "highlightLegs", function(s) State.highlightLegs = s; ESPManager.refreshAll() end, o)
        UIFactory.addColorSlider(sf2, "Legs Color", function(c) State.legsColor = c; ESPManager.refreshAll() end); o = o + 1
        o = sl(sf2, "Legs Trans", 0, 100, State.legsTransparency * 100, function(v) State.legsTransparency = v / 100; ESPManager.refreshAll() end, o)
        UIFactory.addColorSlider(sf2, "Skeleton Col", function(c) State.skeletonColor = c; ESPManager.refreshAll() end); o = o + 1

    -- ========================================
    -- TP
    -- ========================================
    elseif tab == "TP" then
        local o = 1
        o = o + 1; UIFactory.addDropdown(UIFactory.createFunctionFrame(sf1, "TP Position", o), {"Behind","Front","Above","Below"}, State.teleportPosition, function(v) State.teleportPosition = v end)
        o = sl(sf1, "TP Distance", 1, 20, State.teleportDistance, function(v) State.teleportDistance = v end, o)
        o = sl(sf1, "Cam Smooth", 0, 10, State.tpCameraSmooth, function(v) State.tpCameraSmooth = v end, o)

        local tlf = UIFactory.createFunctionFrame(sf1, "Select Player", o); o = o + 1
        local tpd = Instance.new("TextButton"); tpd.Size = UDim2.new(0, 130, 0, 22); tpd.Position = UDim2.new(0, 10, 0, 28)
        tpd.BackgroundColor3 = Color3.fromRGB(30, 30, 30); tpd.Text = "Select Target"
        tpd.TextColor3 = Color3.fromRGB(255, 255, 255); tpd.Font = Enum.Font.Oswald; tpd.TextSize = 13
        tpd.BorderSizePixel = 0; tpd.Parent = tlf; Utils.removeSelection(tpd); Utils.addCorner(tpd, 5)

        local tpls = Instance.new("ScrollingFrame"); tpls.Size = UDim2.new(0, 130, 0, 0); tpls.Position = UDim2.new(0, 10, 0, 50)
        tpls.BackgroundColor3 = Color3.fromRGB(30, 30, 30); tpls.Visible = false; tpls.ZIndex = 10
        tpls.ScrollBarThickness = 3; tpls.Parent = tlf; Utils.removeSelection(tpls); Utils.addCorner(tpls, 5)
        Instance.new("UIListLayout", tpls)

        local function utl()
            for _, c in ipairs(tpls:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
            local pc = 0
            for _, p in ipairs(Services.Players:GetPlayers()) do
                if p ~= Services.player then pc = pc + 1
                    local opt = Instance.new("TextButton"); opt.Size = UDim2.new(1, -6, 0, 28)
                    opt.BackgroundColor3 = Color3.fromRGB(40, 40, 40); opt.Text = p.Name
                    opt.TextColor3 = Color3.fromRGB(255, 255, 255); opt.Font = Enum.Font.Oswald; opt.TextSize = 13
                    opt.BorderSizePixel = 0; opt.ZIndex = 11; opt.Parent = tpls; Utils.removeSelection(opt)
                    opt.MouseButton1Click:Connect(function() State.teleportTarget = p; tpd.Text = p.Name; tpls.Visible = false end)
                end
            end
            tpls.CanvasSize = UDim2.new(0, 0, 0, pc * 28); tpls.Size = UDim2.new(0, 130, 0, math.min(pc * 28, 200))
        end
        tpd.MouseButton1Click:Connect(function() utl(); tpls.Visible = not tpls.Visible end)

        local tf = UIFactory.createFunctionFrame(sf2, "Current Target", 1)
        local tl = Instance.new("TextLabel"); tl.Size = UDim2.new(1, -16, 0, 20); tl.Position = UDim2.new(0, 10, 0, 28)
        tl.BackgroundTransparency = 1; tl.Text = "None selected"; tl.TextColor3 = Color3.fromRGB(0, 255, 0)
        tl.Font = Enum.Font.Oswald; tl.TextSize = 13; tl.TextXAlignment = Enum.TextXAlignment.Left; tl.Parent = tf; Utils.removeSelection(tl)
        task.spawn(function() while tl and tl.Parent do
            tl.Text = State.teleportTarget and State.teleportTarget.Character and "Target: " .. State.teleportTarget.Name or "None selected"
            tl.TextColor3 = State.teleportTarget and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(150, 150, 150)
            task.wait(0.5)
        end end)

    -- ========================================
    -- VIEW
    -- ========================================
    elseif tab == "View" then
        local o = 1
        o = tb(sf1, "First Person", "firstPerson", function(s) State.firstPerson = s; if s then State.thirdPerson = false end end, o)
        o = tb(sf1, "Third Person", "thirdPerson", function(s) State.thirdPerson = s; if s then State.firstPerson = false end end, o)
        o = sl(sf1, "Cam Distance", 1, 30, State.cameraDistance, function(v) State.cameraDistance = v; if State.thirdPerson then Services.player.CameraMaxZoomDistance = v end end, o)
        o = sl(sf1, "FOV", 30, 120, State.fov, function(v) State.fov = v end, o)
        o = tb(sf1, "Unlock Mouse", "mouseUnlocked", function(s) if s then Utils.unlockMouse() else Utils.lockMouse() end end, o)
        o = tb(sf1, "Camera Shake", "cameraShake", nil, o)
        o = tb(sf1, "Camera Spin", "cameraSpin", nil, o)
        o = sl(sf1, "Spin Speed", 1, 20, State.cameraSpinSpeed, function(v) State.cameraSpinSpeed = v end, o)
        o = tb(sf1, "Freecam", "freecam", function(s) State.freecam = s; Services.camera.CameraType = s and Enum.CameraType.Scriptable or Enum.CameraType.Custom end, o)
        o = sl(sf1, "Freecam Spd", 10, 200, State.freecamSpeed, function(v) State.freecamSpeed = v end, o)

        o = 1
        o = sl(sf2, "Cam Roll", -180, 180, State.cameraRoll, function(v) State.cameraRoll = v end, o)
        o = tb(sf2, "Remove UI", "removeUI", function(s) State.removeUI = s; Services.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, not s) end, o)
        o = tb(sf2, "Night Mode", "nightMode", nil, o)
        o = tb(sf2, "No Cam Clip", "noCameraClip", nil, o)
        o = tb(sf2, "Force View", "forceView", nil, o)

    -- ========================================
    -- WORLD
    -- ========================================
    elseif tab == "World" then
        local o = 1
        local pf = UIFactory.createFunctionFrame(sf1, "Presets", o); o = o + 1
        local pd = Instance.new("TextButton"); pd.Size = UDim2.new(0, 130, 0, 22); pd.Position = UDim2.new(0, 10, 0, 28)
        pd.BackgroundColor3 = Color3.fromRGB(30, 30, 30); pd.Text = "Select Preset"
        pd.TextColor3 = Color3.fromRGB(255, 255, 255); pd.Font = Enum.Font.Oswald; pd.TextSize = 13
        pd.BorderSizePixel = 0; pd.Parent = pf; Utils.removeSelection(pd); Utils.addCorner(pd, 5)

        local pl = Instance.new("Frame"); pl.Size = UDim2.new(0, 130, 0, 168); pl.Position = UDim2.new(0, 10, 0, 50)
        pl.BackgroundColor3 = Color3.fromRGB(30, 30, 30); pl.Visible = false; pl.ZIndex = 10; pl.Parent = pf
        Utils.removeSelection(pl); Utils.addCorner(pl, 5); Instance.new("UIListLayout", pl)
        for _, pn in ipairs({"Potato","Realistic","Surreal","Default","Horror","Fullbright"}) do
            local opt = Instance.new("TextButton"); opt.Size = UDim2.new(1, 0, 0, 28)
            opt.BackgroundColor3 = Color3.fromRGB(40, 40, 40); opt.Text = pn
            opt.TextColor3 = Color3.fromRGB(255, 255, 255); opt.Font = Enum.Font.Oswald; opt.TextSize = 13
            opt.BorderSizePixel = 0; opt.ZIndex = 11; opt.Parent = pl; Utils.removeSelection(opt)
            opt.MouseButton1Click:Connect(function() pd.Text = pn; pl.Visible = false; WorldManager.applyPreset(pn) end)
        end
        pd.MouseButton1Click:Connect(function() pl.Visible = not pl.Visible end)

        o = sl(sf1, "Brightness", 0, 10, State.worldBrightness, function(v) State.worldBrightness = v; WorldManager.applyWorldSettings() end, o)
        UIFactory.addColorSlider(sf1, "Ambient Color", function(c) State.worldAmbient = c; WorldManager.applyWorldSettings() end); o = o + 1
        UIFactory.addColorSlider(sf1, "Outdoor Amb", function(c) State.worldOutdoorAmbient = c; WorldManager.applyWorldSettings() end); o = o + 1
        o = fs(sf1, "Exposure", 0, 3, State.worldExposureCompensation, function(v) State.worldExposureCompensation = v; WorldManager.applyWorldSettings() end, o)
        o = fs(sf1, "Env Diffuse", 0, 3, State.worldEnvDiffuseScale, function(v) State.worldEnvDiffuseScale = v; WorldManager.applyWorldSettings() end, o)
        o = fs(sf1, "Env Specular", 0, 3, State.worldEnvSpecularScale, function(v) State.worldEnvSpecularScale = v; WorldManager.applyWorldSettings() end, o)
        o = fs(sf1, "Shadow Soft", 0, 1, State.worldShadowSoftness, function(v) State.worldShadowSoftness = v; WorldManager.applyWorldSettings() end, o)
        o = tb(sf1, "Global Shadows", "worldGlobalShadows", function(s) State.worldGlobalShadows = s; WorldManager.applyWorldSettings() end, o)
        o = fs(sf1, "Clock Time", 0, 24, State.worldClockTime, function(v) State.worldClockTime = v; WorldManager.applyWorldSettings() end, o)
        o = tb(sf1, "Atmosphere", "worldAtmosphereEnabled", function(s) State.worldAtmosphereEnabled = s; WorldManager.applyWorldSettings() end, o)
        o = fs(sf1, "Atm Density", 0, 1, State.worldAtmosphereDensity, function(v) State.worldAtmosphereDensity = v; WorldManager.applyWorldSettings() end, o)
        o = fs(sf1, "Atm Offset", 0, 1, State.worldAtmosphereOffset, function(v) State.worldAtmosphereOffset = v; WorldManager.applyWorldSettings() end, o)
        UIFactory.addColorSlider(sf1, "Atm Color", function(c) State.worldAtmosphereColor = c; WorldManager.applyWorldSettings() end); o = o + 1
        o = fs(sf1, "Atm Glare", 0, 3, State.worldAtmosphereGlare, function(v) State.worldAtmosphereGlare = v; WorldManager.applyWorldSettings() end, o)
        o = fs(sf1, "Atm Haze", 0, 5, State.worldAtmosphereHaze, function(v) State.worldAtmosphereHaze = v; WorldManager.applyWorldSettings() end, o)
        o = tb(sf1, "Disable Fog", "disableFog", function(s) State.disableFog = s; WorldManager.applyWorldSettings() end, o)
        o = tb(sf1, "No Textures", "noTextures", function(s) State.noTextures = s; WorldManager.applyWorldSettings() end, o)

    -- ========================================
    -- AUTO FARM
    -- ========================================
    elseif tab == "AutoFarm" then
        local o = 1
        o = tb(sf1, "Coin Farm", "autoFarm", nil, o)
        o = o + 1
        local cnf = UIFactory.createFunctionFrame(sf1, "Coin Name", o)
        local cnb = Instance.new("TextBox"); cnb.Size = UDim2.new(1, -16, 0, 22); cnb.Position = UDim2.new(0, 10, 0, 28)
        cnb.BackgroundColor3 = Color3.fromRGB(30, 30, 30); cnb.Text = State.coinName
        cnb.TextColor3 = Color3.fromRGB(255, 255, 255); cnb.Font = Enum.Font.Oswald; cnb.TextSize = 13
        cnb.PlaceholderText = "Coin"; cnb.Parent = cnf; Utils.removeSelection(cnb); Utils.addCorner(cnb, 5)
        cnb.FocusLost:Connect(function() State.coinName = cnb.Text; Utils.updateCoinCache(State.coinName, State.cachedCoins) end)
        o = o + 1; UIFactory.addDropdown(UIFactory.createFunctionFrame(sf1, "Farm Type", o), {"TP","Pathfind"}, State.farmType, function(v) State.farmType = v end)
        o = sl(sf1, "Farm Speed", 1, 20, State.farmSpeed, function(v) State.farmSpeed = v end, o)
        o = tb(sf1, "Use Spawns", "farmUseSpawns", nil, o)
        o = o + 1
        local spf = UIFactory.createFunctionFrame(sf1, "Spawn Prefix", o)
        local spb = Instance.new("TextBox"); spb.Size = UDim2.new(1, -16, 0, 22); spb.Position = UDim2.new(0, 10, 0, 28)
        spb.BackgroundColor3 = Color3.fromRGB(30, 30, 30); spb.Text = State.farmSpawnPrefix
        spb.TextColor3 = Color3.fromRGB(255, 255, 255); spb.Font = Enum.Font.Oswald; spb.TextSize = 13
        spb.PlaceholderText = "Spawn"; spb.Parent = spf; Utils.removeSelection(spb); Utils.addCorner(spb, 5)
        spb.FocusLost:Connect(function() State.farmSpawnPrefix = spb.Text end)
        o = o + 1
        local smif = UIFactory.createFunctionFrame(sf1, "Spawn Min", o)
        local sminb = Instance.new("TextBox"); sminb.Size = UDim2.new(1, -16, 0, 22); sminb.Position = UDim2.new(0, 10, 0, 28)
        sminb.BackgroundColor3 = Color3.fromRGB(30, 30, 30); sminb.Text = tostring(State.farmSpawnMin)
        sminb.TextColor3 = Color3.fromRGB(255, 255, 255); sminb.Font = Enum.Font.Oswald; sminb.TextSize = 13
        sminb.Parent = smif; Utils.removeSelection(sminb); Utils.addCorner(sminb, 5)
        sminb.FocusLost:Connect(function() State.farmSpawnMin = tonumber(sminb.Text) or 1 end)
        o = o + 1
        local smaf = UIFactory.createFunctionFrame(sf1, "Spawn Max", o)
        local smaxb = Instance.new("TextBox"); smaxb.Size = UDim2.new(1, -16, 0, 22); smaxb.Position = UDim2.new(0, 10, 0, 28)
        smaxb.BackgroundColor3 = Color3.fromRGB(30, 30, 30); smaxb.Text = tostring(State.farmSpawnMax)
        smaxb.TextColor3 = Color3.fromRGB(255, 255, 255); smaxb.Font = Enum.Font.Oswald; smaxb.TextSize = 13
        smaxb.Parent = smaf; Utils.removeSelection(smaxb); Utils.addCorner(smaxb, 5)
        smaxb.FocusLost:Connect(function() State.farmSpawnMax = tonumber(smaxb.Text) or 10 end)

    -- ========================================
    -- KEYS
    -- ========================================
    elseif tab == "Keys" then
        table.clear(State.keybindButtons)
        local keys = {
            {"Toggle GUI","toggleGuiKey"}, {"Unlock Mouse","unlockMouseKey"}, {"Fly","flyKey"},
            {"NoClip","noClipKey"}, {"AirStrafe","airStrafeKey"}, {"Speed Boost","speedBoostKey"},
            {"Aimbot","aimbotKey"}, {"Silent Aim","silentAimKey"}, {"Trigger Bot","triggerBotKey"},
            {"TP Select","teleportSelectKey"}, {"TP Execute","teleportExecuteKey"},
            {"Panic Key","panicKey"}, {"Quick Turn","quickTurnKey"}, {"Rocket Jump","rocketJumpKey"},
            {"Freecam","freecamKey"},
        }
        local half = math.ceil(#keys / 2)
        for i, kd in ipairs(keys) do
            local p = i <= half and sf1 or sf2
            local f = UIFactory.createFunctionFrame(p, kd[1], i)
            State.keybindButtons[kd[2]] = UIFactory.addKeybindButton(f, kd[1], State[kd[2]])
        end

    -- ========================================
    -- SETTINGS
    -- ========================================
    elseif tab == "Settings" then
        local o = 1
        o = sl(sf1, "GUI Size", 50, 200, State.guiSize * 100, function(v)
            State.guiSize = v / 100
            local mf = GUIManager.getMainFrame()
            mf.Size = UDim2.new(0, 800 * State.guiSize, 0, 480 * State.guiSize)
            mf.Position = UDim2.new(0.5, -400 * State.guiSize, 0, 50)
        end, o)
        UIFactory.addColorSlider(sf1, "Stroke Color", function(c) State.guiStrokeColor = c; GUIManager.updateColors() end); o = o + 1
        UIFactory.addColorSlider(sf1, "BG Color", function(c) State.guiBackgroundColor = c; GUIManager.updateColors() end); o = o + 1
        UIFactory.addColorSlider(sf1, "Frame Color", function(c) State.guiFrameColor = c; GUIManager.updateColors() end); o = o + 1
        o = o + 1; UIFactory.addDropdown(UIFactory.createFunctionFrame(sf1, "Click Sound", o), {"None","Click","Pop","Tap","Swoosh"}, State.clickSound, function(v) State.clickSound = v end)
        o = sl(sf1, "Click Volume", 0, 100, State.clickVolume * 100, function(v) State.clickVolume = v / 100 end, o)
        o = tb(sf1, "Notifications", "showNotifications", nil, o)
        o = sl(sf1, "Notif Duration", 1, 10, State.notificationDuration, function(v) State.notificationDuration = v end, o)
        o = tb(sf1, "Value Unlocker", "valueUnlocker", function(s)
            State.valueUnlocker = s
            if s then NotificationManager.show("Value Unlocker: Not Recommended!", Color3.fromRGB(255, 150, 0)) end
        end, o)
        o = tb(sf1, "Safe Functions", "safeFunctions", function(s) State.safeFunctions = s; if s then Panic.applySafeFunctions() end end, o)
        o = sl(sf1, "Safe FOV", 30, 120, State.safeFOV, function(v) State.safeFOV = v end, o)
        o = sl(sf1, "Safe Speed", 1, 30, State.safeSpeed, function(v) State.safeSpeed = v end, o)
        o = sl(sf1, "Safe Jump", 0, 100, State.safeJump, function(v) State.safeJump = v end, o)

        -- Music
        o = tb(sf1, "Music Player", "musicEnabled", function(s) State.musicEnabled = s; if not s then MusicManager.stop() end end, o)
        o = o + 1
        local muf = UIFactory.createFunctionFrame(sf1, "Music URL", o)
        local mub = Instance.new("TextBox"); mub.Size = UDim2.new(1, -16, 0, 22); mub.Position = UDim2.new(0, 10, 0, 28)
        mub.BackgroundColor3 = Color3.fromRGB(30, 30, 30); mub.Text = State.musicURL
        mub.TextColor3 = Color3.fromRGB(255, 255, 255); mub.Font = Enum.Font.Oswald; mub.TextSize = 11
        mub.PlaceholderText = "rbxassetid://ID"; mub.Parent = muf; Utils.removeSelection(mub); Utils.addCorner(mub, 5)
        mub.FocusLost:Connect(function() State.musicURL = mub.Text; if State.musicEnabled then MusicManager.play(State.musicURL) end end)

        -- Playlist
        local plf = UIFactory.createFunctionFrame(sf1, "Playlist", o); plf.Size = UDim2.new(1, -8, 0, 120); o = o + 1
        local plsf = Instance.new("ScrollingFrame"); plsf.Size = UDim2.new(1, -16, 0, 80); plsf.Position = UDim2.new(0, 10, 0, 28)
        plsf.BackgroundColor3 = Color3.fromRGB(20, 20, 20); plsf.BorderSizePixel = 0; plsf.ScrollBarThickness = 3
        plsf.CanvasSize = UDim2.new(0, 0, 0, 0); plsf.Parent = plf; Utils.removeSelection(plsf); Utils.addCorner(plsf, 4)
        local plLayout = Instance.new("UIListLayout"); plLayout.Padding = UDim.new(0, 2); plLayout.SortOrder = Enum.SortOrder.LayoutOrder; plLayout.Parent = plsf

        local function refreshPlaylist()
            for _, c in ipairs(plsf:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
            for i, url in ipairs(State.musicPlaylist) do
                local item = Instance.new("Frame"); item.Size = UDim2.new(1, -10, 0, 26)
                item.BackgroundColor3 = i == State.musicCurrentIndex and Color3.fromRGB(70, 70, 200) or Color3.fromRGB(40, 40, 40)
                item.BorderSizePixel = 0; item.LayoutOrder = i; item.Parent = plsf
                Utils.removeSelection(item); Utils.addCorner(item, 4)

                local nl = Instance.new("TextLabel"); nl.Size = UDim2.new(0, 20, 1, 0); nl.Position = UDim2.new(0, 4, 0, 0)
                nl.BackgroundTransparency = 1; nl.Text = "#" .. i; nl.TextColor3 = Color3.fromRGB(200, 200, 200)
                nl.Font = Enum.Font.Oswald; nl.TextSize = 11; nl.Parent = item; Utils.removeSelection(nl)

                local sl = Instance.new("TextLabel"); sl.Size = UDim2.new(1, -70, 1, 0); sl.Position = UDim2.new(0, 24, 0, 0)
                sl.BackgroundTransparency = 1; sl.Text = "Song " .. i; sl.TextColor3 = Color3.fromRGB(255, 255, 255)
                sl.Font = Enum.Font.Oswald; sl.TextSize = 11; sl.TextXAlignment = Enum.TextXAlignment.Left; sl.Parent = item; Utils.removeSelection(sl)

                local pb = Instance.new("TextButton"); pb.Size = UDim2.new(0, 22, 0, 22); pb.Position = UDim2.new(1, -26, 0, 2)
                pb.BackgroundColor3 = Color3.fromRGB(0, 180, 0); pb.Text = ">"; pb.TextColor3 = Color3.fromRGB(255, 255, 255)
                pb.Font = Enum.Font.Oswald; pb.TextSize = 10; pb.BorderSizePixel = 0; pb.Parent = item
                Utils.removeSelection(pb); Utils.addCorner(pb, 3)

                local db = Instance.new("TextButton"); db.Size = UDim2.new(0, 22, 0, 22); db.Position = UDim2.new(1, -50, 0, 2)
                db.BackgroundColor3 = Color3.fromRGB(200, 50, 50); db.Text = "X"; db.TextColor3 = Color3.fromRGB(255, 255, 255)
                db.Font = Enum.Font.Oswald; db.TextSize = 10; db.BorderSizePixel = 0; db.Parent = item
                Utils.removeSelection(db); Utils.addCorner(db, 3)

                local idx = i
                pb.MouseButton1Click:Connect(function() MusicManager.playFromPlaylist(idx); refreshPlaylist() end)
                db.MouseButton1Click:Connect(function() MusicManager.removeFromPlaylist(idx); refreshPlaylist() end)
            end
            plsf.CanvasSize = UDim2.new(0, 0, 0, #State.musicPlaylist * 30)
        end

        -- Music Controls
        local mcf = UIFactory.createFunctionFrame(sf1, "Controls", o); mcf.Size = UDim2.new(1, -8, 0, 30); o = o + 1
        local prevB = Instance.new("TextButton"); prevB.Size = UDim2.new(0, 50, 0, 24); prevB.Position = UDim2.new(0, 10, 0, 3)
        prevB.BackgroundColor3 = Color3.fromRGB(60, 60, 60); prevB.Text = "Prev"; prevB.TextColor3 = Color3.fromRGB(255, 255, 255)
        prevB.Font = Enum.Font.Oswald; prevB.TextSize = 11; prevB.BorderSizePixel = 0; prevB.Parent = mcf
        Utils.removeSelection(prevB); Utils.addCorner(prevB, 4)
        prevB.MouseButton1Click:Connect(function() MusicManager.prevTrack(); refreshPlaylist() end)

        local ppB = Instance.new("TextButton"); ppB.Size = UDim2.new(0, 60, 0, 24); ppB.Position = UDim2.new(0, 64, 0, 3)
        ppB.BackgroundColor3 = Color3.fromRGB(0, 180, 0); ppB.Text = "Play"; ppB.TextColor3 = Color3.fromRGB(255, 255, 255)
        ppB.Font = Enum.Font.Oswald; ppB.TextSize = 11; ppB.BorderSizePixel = 0; ppB.Parent = mcf
        Utils.removeSelection(ppB); Utils.addCorner(ppB, 4)
        ppB.MouseButton1Click:Connect(function()
            if State.musicPlaying then MusicManager.pause() else MusicManager.resume() end
            ppB.Text = State.musicPlaying and "Pause" or "Play"
            ppB.BackgroundColor3 = State.musicPlaying and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(200, 150, 0)
        end)

        local nextB = Instance.new("TextButton"); nextB.Size = UDim2.new(0, 50, 0, 24); nextB.Position = UDim2.new(0, 128, 0, 3)
        nextB.BackgroundColor3 = Color3.fromRGB(60, 60, 60); nextB.Text = "Next"; nextB.TextColor3 = Color3.fromRGB(255, 255, 255)
        nextB.Font = Enum.Font.Oswald; nextB.TextSize = 11; nextB.BorderSizePixel = 0; nextB.Parent = mcf
        Utils.removeSelection(nextB); Utils.addCorner(nextB, 4)
        nextB.MouseButton1Click:Connect(function() MusicManager.nextTrack(); refreshPlaylist() end)

        local stopB = Instance.new("TextButton"); stopB.Size = UDim2.new(0, 50, 0, 24); stopB.Position = UDim2.new(0, 182, 0, 3)
        stopB.BackgroundColor3 = Color3.fromRGB(200, 50, 50); stopB.Text = "Stop"; stopB.TextColor3 = Color3.fromRGB(255, 255, 255)
        stopB.Font = Enum.Font.Oswald; stopB.TextSize = 11; stopB.BorderSizePixel = 0; stopB.Parent = mcf
        Utils.removeSelection(stopB); Utils.addCorner(stopB, 4)
        stopB.MouseButton1Click:Connect(function() MusicManager.stop(); refreshPlaylist() end)

        o = sl(sf1, "Volume", 0, 100, State.musicVolume * 100, function(v) State.musicVolume = v / 100; MusicManager.updateVolume() end, o)

        -- Music Loop
        local mlf = UIFactory.createFunctionFrame(sf1, "Music Loop", o); o = o + 1
        local mlb = Instance.new("TextButton"); mlb.Size = UDim2.new(0, 60, 0, 24); mlb.Position = UDim2.new(0, 10, 0, 28)
        mlb.BackgroundColor3 = State.musicLoop and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 50, 50)
        mlb.Text = State.musicLoop and "ON" or "OFF"; mlb.TextColor3 = Color3.fromRGB(255, 255, 255)
        mlb.Font = Enum.Font.Oswald; mlb.TextSize = 12; mlb.BorderSizePixel = 0; mlb.Parent = mlf
        Utils.removeSelection(mlb); Utils.addCorner(mlb, 5)
        mlb.MouseButton1Click:Connect(function() MusicManager.toggleLoop(); mlb.Text = State.musicLoop and "ON" or "OFF"; mlb.BackgroundColor3 = State.musicLoop and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 50, 50) end)

        refreshPlaylist()

        -- Destroy GUI
        local clf = UIFactory.createFunctionFrame(sf1, "Close GUI", o); o = o + 1
        local clb = Instance.new("TextButton"); clb.Size = UDim2.new(0, 120, 0, 30); clb.Position = UDim2.new(0, 10, 0, 28)
        clb.BackgroundColor3 = Color3.fromRGB(200, 50, 50); clb.Text = "Destroy GUI"; clb.TextColor3 = Color3.fromRGB(255, 255, 255)
        clb.Font = Enum.Font.Oswald; clb.TextSize = 15; clb.BorderSizePixel = 0; clb.Parent = clf
        Utils.removeSelection(clb); Utils.addCorner(clb, 6)
        clb.MouseButton1Click:Connect(function()
            if State.bodyGyro then State.bodyGyro:Destroy() end
            if State.bodyVelocity then State.bodyVelocity:Destroy() end
            MusicManager.stop(); ESPManager.clearAll()
            Services.camera.FieldOfView = 70
            Services.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
            Services.playerGui.Enabled = true
            GUIManager.getScreenGui():Destroy()
        end)

        -- Reset Keys
        local rsf = UIFactory.createFunctionFrame(sf1, "Reset Keys", o)
        local rsb = Instance.new("TextButton"); rsb.Size = UDim2.new(0, 120, 0, 30); rsb.Position = UDim2.new(0, 10, 0, 28)
        rsb.BackgroundColor3 = Color3.fromRGB(200, 150, 0); rsb.Text = "Reset Keys"; rsb.TextColor3 = Color3.fromRGB(255, 255, 255)
        rsb.Font = Enum.Font.Oswald; rsb.TextSize = 15; rsb.BorderSizePixel = 0; rsb.Parent = rsf
        Utils.removeSelection(rsb); Utils.addCorner(rsb, 6)
        rsb.MouseButton1Click:Connect(function()
            State.toggleGuiKey = "RightShift"; State.unlockMouseKey = "LeftAlt"
            State.flyKey = "F"; State.noClipKey = "N"; State.airStrafeKey = "V"
            State.speedBoostKey = "B"; State.aimbotKey = "T"; State.silentAimKey = "Y"
            State.triggerBotKey = "G"; State.teleportSelectKey = "L"; State.teleportExecuteKey = "Slash"
            State.panicKey = "F8"; State.quickTurnKey = "Q"; State.rocketJumpKey = "X"; State.freecamKey = "P"
            for k, btn in pairs(State.keybindButtons) do if btn and State[k] then btn.Text = State[k]; btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50) end end
        end)
    end

    -- Обновление Canvas Size
    local c1 = 0; for _, c in ipairs(sf1:GetChildren()) do if c:IsA("Frame") then c1 = c1 + 1 end end
    sf1.CanvasSize = UDim2.new(0, 0, 0, math.max(c1 * 75 + 10, 480))
    local c2 = 0; for _, c in ipairs(sf2:GetChildren()) do if c:IsA("Frame") then c2 = c2 + 1 end end
    sf2.CanvasSize = UDim2.new(0, 0, 0, math.max(c2 * 75 + 10, 480))
end

return SwitchContent
