-- Experiment17 v5.3 - MONOLITH
-- Все функции в одном файле

-- ========================================
-- СЕРВИСЫ
-- ========================================
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local SG = game:GetService("StarterGui")
local SS = game:GetService("SoundService")
local PS = game:GetService("PathfindingService")
local VIM = game:GetService("VirtualInputManager")
local TCS = game:GetService("TextChatService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()
local playerGui = player:WaitForChild("PlayerGui")
local isMobile = UIS.TouchEnabled

local vp = camera.ViewportSize
local sw, sh = vp.X, vp.Y
local gs = math.clamp(sw / 1920, 0.6, 1.4)
if sw < 1000 then gs = math.clamp(sw / 900, 0.55, 1.1) end

print("Experiment17 v5.3 - " .. sw .. "x" .. sh)

-- ========================================
-- STATE (сокращённый, только нужное для теста)
-- ========================================
local State = {
    guiSize = gs, panicMode = false,
    airStrafe = false, fly = false, flySpeed = 50, noClip = false,
    speedBoost = false, speedMultiplier = 2, espEnabled = false,
    fov = 70, freecam = false, freecamSpeed = 50,
    safeFunctions = false, autoFarm = false,
    aimbotEnabled = false, silentAim = false,
    guiOpen = true, showNotifications = true, notificationDuration = 3,
    toggleGuiKey = "RightShift", unlockMouseKey = "LeftAlt",
    flyKey = "F", noClipKey = "N", panicKey = "F8",
    guiBackgroundColor = Color3.fromRGB(0,0,0),
    guiStrokeColor = Color3.fromRGB(255,255,255),
    guiFrameColor = Color3.fromRGB(5,5,5),
    bodyGyro = nil, bodyVelocity = nil, musicPlayer = nil,
    espObjects = {}, tracersList = {}, toggleSetters = {}, keybindButtons = {},
    lastStrafeTime = 0, lastAFKTime = 0, lastTracerUpdate = 0,
    antiTeleportPos = nil,
}

-- ========================================
-- UTILS
-- ========================================
local function removeSel(o) pcall(function() o.SelectionImageObject = nil end) end
local function addCorner(o, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 6); c.Parent = o end
local function addStroke(o, t, col) local s = Instance.new("UIStroke"); s.Thickness = t or 1; s.Color = col or Color3.fromRGB(255,255,255); s.Parent = o end
local function tween(o, p, d) TS:Create(o, TweenInfo.new(d or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p):Play() end
local function notify(text, color)
    if not State.showNotifications then return end
    local gui = playerGui:FindFirstChild("Experiment17") or playerGui
    local l = Instance.new("TextLabel"); l.Size = UDim2.new(0, 280, 0, 24); l.Position = UDim2.new(1, -290, 1, -36)
    l.BackgroundColor3 = Color3.fromRGB(0,0,0); l.BackgroundTransparency = 0.3
    l.Text = text; l.TextColor3 = color or Color3.fromRGB(255,255,255)
    l.Font = Enum.Font.Oswald; l.TextSize = 13; l.ZIndex = 300; l.Parent = gui
    task.delay(3, function() pcall(function() l:Destroy() end) end)
end
local function lockMouse() UIS.MouseBehavior = Enum.MouseBehavior.LockCenter end
local function unlockMouse() UIS.MouseBehavior = Enum.MouseBehavior.Default end

-- ========================================
-- GUI FACTORY (базовый)
-- ========================================
local function createFrame(parent, name, order)
    local f = Instance.new("Frame"); f.Size = UDim2.new(1, -8, 0, 55)
    f.BackgroundColor3 = Color3.fromRGB(255,255,255); f.BackgroundTransparency = 0.92
    f.BorderSizePixel = 0; f.LayoutOrder = order or 0; f.Parent = parent
    addCorner(f, 8)
    local l = Instance.new("TextLabel"); l.Size = UDim2.new(0, 140, 0, 20); l.Position = UDim2.new(0, 10, 0, 3)
    l.BackgroundTransparency = 1; l.Text = name; l.TextColor3 = Color3.fromRGB(200,200,200)
    l.Font = Enum.Font.Oswald; l.TextSize = 13; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = f
    return f
end

local function addThumbler(parent, default, callback)
    local tb = Instance.new("TextButton"); tb.Size = UDim2.new(0, 44, 0, 22); tb.Position = UDim2.new(1, -54, 0, 2)
    tb.BackgroundColor3 = default and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,50,50)
    tb.Text = ""; tb.BorderSizePixel = 0; tb.Parent = parent
    addCorner(tb, 11)
    local ball = Instance.new("Frame"); ball.Size = UDim2.new(0, 16, 0, 16)
    ball.Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    ball.BackgroundColor3 = Color3.fromRGB(255,255,255); ball.BorderSizePixel = 0; ball.Parent = tb
    addCorner(ball, 8)
    local enabled = default
    local function setToggle(new, anim)
        enabled = new
        local pos = enabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        local col = enabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,50,50)
        if anim == false then ball.Position = pos; tb.BackgroundColor3 = col
        else tween(ball, {Position = pos}, 0.2); tween(tb, {BackgroundColor3 = col}, 0.2) end
        if callback then callback(enabled) end
    end
    tb.MouseButton1Click:Connect(function() setToggle(not enabled, true) end)
    return setToggle
end

-- ========================================
-- MAIN GUI
-- ========================================
local screenGui = Instance.new("ScreenGui"); screenGui.Name = "Experiment17"; screenGui.ResetOnSpawn = false; screenGui.Parent = playerGui
local MainFrame = Instance.new("Frame"); MainFrame.Size = UDim2.new(0, 800*gs, 0, 480*gs); MainFrame.Position = UDim2.new(0.5, -400*gs, 0, 50)
MainFrame.BackgroundColor3 = State.guiBackgroundColor; MainFrame.BorderSizePixel = 0; MainFrame.Visible = true; MainFrame.Parent = screenGui
addCorner(MainFrame, 10); addStroke(MainFrame, 2, State.guiStrokeColor)

-- TopBar
local topBar = Instance.new("Frame"); topBar.Size = UDim2.new(1, 0, 0, 26); topBar.BackgroundColor3 = Color3.fromRGB(70,70,200); topBar.Parent = MainFrame
addCorner(topBar, 10)
local topLabel = Instance.new("TextLabel"); topLabel.Size = UDim2.new(1, 0, 1, 0); topLabel.BackgroundTransparency = 1
topLabel.Text = "Experiment17"; topLabel.TextColor3 = Color3.fromRGB(255,255,255); topLabel.Font = Enum.Font.Oswald; topLabel.TextSize = 14; topLabel.Parent = topBar

-- Hint
local hint = Instance.new("TextLabel"); hint.Size = UDim2.new(1, -130, 0, 20); hint.Position = UDim2.new(0, 65, 0, 28)
hint.BackgroundTransparency = 1; hint.Text = "RightShift - GUI | LeftAlt - Mouse | L - TP | / - Teleport"
hint.TextColor3 = Color3.fromRGB(150,150,150); hint.Font = Enum.Font.Oswald; hint.TextSize = 10; hint.TextXAlignment = Enum.TextXAlignment.Right; hint.Parent = MainFrame

-- Categories
local leftCat = Instance.new("ScrollingFrame"); leftCat.Size = UDim2.new(0, 63, 1, -28); leftCat.Position = UDim2.new(0, 0, 0, 28)
leftCat.BackgroundColor3 = State.guiBackgroundColor; leftCat.ScrollBarThickness = 3; leftCat.Parent = MainFrame
local catLayout = Instance.new("UIListLayout"); catLayout.Padding = UDim.new(0, 2); catLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; catLayout.SortOrder = Enum.SortOrder.LayoutOrder; catLayout.Parent = leftCat

local catBtns = {}
for i, name in ipairs({"Legit","Rage","Aimbot","Visual","Body","TP","View","World","Farm","Keys","Set"}) do
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(0, 55, 0, 38); btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    btn.Text = name; btn.TextColor3 = Color3.fromRGB(255,255,255); btn.Font = Enum.Font.Oswald; btn.TextSize = 9
    btn.LayoutOrder = i; btn.Parent = leftCat; addCorner(btn, 8); catBtns[name] = btn
end
leftCat.CanvasSize = UDim2.new(0, 0, 0, 11 * 42)

-- Content
local contentFrame = Instance.new("Frame"); contentFrame.Size = UDim2.new(1, -63, 1, -28); contentFrame.Position = UDim2.new(0, 63, 0, 28)
contentFrame.BackgroundColor3 = State.guiBackgroundColor; contentFrame.Parent = MainFrame

local sf1 = Instance.new("ScrollingFrame"); sf1.Size = UDim2.new(0.5, -8, 1, -10); sf1.Position = UDim2.new(0, 5, 0, 5)
sf1.BackgroundColor3 = State.guiFrameColor; sf1.ScrollBarThickness = 4; sf1.CanvasSize = UDim2.new(0, 0, 0, 480); sf1.Parent = contentFrame
local l1 = Instance.new("UIListLayout"); l1.Padding = UDim.new(0, 8); l1.HorizontalAlignment = Enum.HorizontalAlignment.Center; l1.SortOrder = Enum.SortOrder.LayoutOrder; l1.Parent = sf1

local sf2 = Instance.new("ScrollingFrame"); sf2.Size = UDim2.new(0.5, -8, 1, -10); sf2.Position = UDim2.new(0.5, 3, 0, 5)
sf2.BackgroundColor3 = State.guiFrameColor; sf2.ScrollBarThickness = 4; sf2.CanvasSize = UDim2.new(0, 0, 0, 480); sf2.Parent = contentFrame
local l2 = Instance.new("UIListLayout"); l2.Padding = UDim.new(0, 8); l2.HorizontalAlignment = Enum.HorizontalAlignment.Center; l2.SortOrder = Enum.SortOrder.LayoutOrder; l2.Parent = sf2

-- Перетаскивание GUI
local dragging, dragStart, frameStart = false, nil, nil
MainFrame.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        local mp = UIS:GetMouseLocation(); local fp = MainFrame.AbsolutePosition; local fs = MainFrame.AbsoluteSize
        if mp.X >= fp.X and mp.X <= fp.X + fs.X and mp.Y >= fp.Y and mp.Y <= fp.Y + 28 then
            dragging = true; dragStart = mp; frameStart = MainFrame.Position
        end
    end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = UIS:GetMouseLocation() - dragStart
        MainFrame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + d.X, frameStart.Y.Scale, frameStart.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- ========================================
-- ТЕСТОВАЯ КНОПКА LEGIT
-- ========================================
local o = 1
State.toggleSetters.airStrafe = addThumbler(createFrame(sf1, "AirStrafe", o), false, function(s) State.airStrafe = s; notify("AirStrafe: " .. (s and "ON" or "OFF")) end)
o = o + 1
State.toggleSetters.fly = addThumbler(createFrame(sf1, "Fly", o), false, function(s) State.fly = s; notify("Fly: " .. (s and "ON" or "OFF")) end)

-- ========================================
-- TOGGLE GUI (RightShift)
-- ========================================
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode.Name == State.toggleGuiKey then
        State.guiOpen = not State.guiOpen
        if State.guiOpen then
            MainFrame.Visible = true; MainFrame.Size = UDim2.new(0, 0, 0, 480*gs)
            tween(MainFrame, {Size = UDim2.new(0, 800*gs, 0, 480*gs)}, 0.3)
        else
            tween(MainFrame, {Size = UDim2.new(0, 0, 0, 480*gs)}, 0.2)
            task.wait(0.2); MainFrame.Visible = false
        end
    end
end)

-- ========================================
-- HEARTBEAT (Fly)
-- ========================================
RS.Heartbeat:Connect(function()
    if State.panicMode then return end
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    camera.FieldOfView = State.fov

    -- Fly
    if State.fly then
        hum.PlatformStand = true
        local move = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move = move + Vector3.new(0, -1, 0) end
        if move.Magnitude > 0 then root.CFrame = root.CFrame + move.Unit * State.flySpeed * 0.05 end
        root.AssemblyLinearVelocity = Vector3.zero
    else
        if hum.PlatformStand then hum.PlatformStand = false end
    end

    -- AirStrafe
    if State.airStrafe and hum.FloorMaterial == Enum.Material.Air then
        local md = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then md = md + root.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then md = md - root.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then md = md + root.CFrame.RightVector end
        if md.Magnitude > 0 then root.AssemblyLinearVelocity = Vector3.new(md.Unit.X * 50, root.AssemblyLinearVelocity.Y, md.Unit.Z * 50) end
    end
end)

-- ========================================
-- ГОТОВО
-- ========================================
lockMouse()
notify("Experiment17 loaded! RightShift - GUI", Color3.fromRGB(0, 255, 0))
print("Experiment17 v5.3 - Ready!")
