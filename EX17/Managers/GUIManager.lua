-- Managers/GUIManager.lua

local Services = _G.Experiment17.Services
local State = _G.Experiment17.State
local Utils = _G.Experiment17.Utils
local GUIManager = {}

local screenGui, MainFrame, MainFrameStroke, sf1, sf2, catBtns = nil, nil, nil, nil, nil, {}
local isDragging, dragStart, frameStart = false, nil, nil

function GUIManager.create()
    local s = State.guiSize

    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Experiment17"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Services.playerGui

    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 800 * s, 0, 480 * s)
    MainFrame.Position = UDim2.new(0.5, -400 * s, 0, 50)
    MainFrame.BackgroundColor3 = State.guiBackgroundColor
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = State.guiOpen
    MainFrame.Parent = screenGui
    Utils.removeSelection(MainFrame)
    Utils.addCorner(MainFrame, 10)
    MainFrameStroke = Utils.addStroke(MainFrame, 2, State.guiStrokeColor)

    -- TopBar "Experiment17"
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 26)
    topBar.BackgroundColor3 = Color3.fromRGB(70, 70, 200)
    topBar.BorderSizePixel = 0
    topBar.Parent = MainFrame
    Utils.removeSelection(topBar)
    Utils.addCorner(topBar, 10)

    local topLabel = Instance.new("TextLabel")
    topLabel.Size = UDim2.new(1, 0, 1, 0)
    topLabel.BackgroundTransparency = 1
    topLabel.Text = "Experiment17"
    topLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    topLabel.Font = Enum.Font.Oswald
    topLabel.TextSize = 14
    topLabel.Parent = topBar
    Utils.removeSelection(topLabel)

    -- Hint
    local hintLabel = Instance.new("TextLabel")
    hintLabel.Size = UDim2.new(1, -130, 0, 20)
    hintLabel.Position = UDim2.new(0, 65, 0, 28)
    hintLabel.BackgroundTransparency = 1
    hintLabel.Text = "RightShift - GUI | LeftAlt - Mouse | L - TP | / - Teleport"
    hintLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    hintLabel.Font = Enum.Font.Oswald
    hintLabel.TextSize = 10
    hintLabel.TextXAlignment = Enum.TextXAlignment.Right
    hintLabel.Parent = MainFrame
    Utils.removeSelection(hintLabel)

    -- Left Categories
    local leftCat = Instance.new("ScrollingFrame")
    leftCat.Size = UDim2.new(0, 63, 1, -28)
    leftCat.Position = UDim2.new(0, 0, 0, 28)
    leftCat.BackgroundColor3 = State.guiBackgroundColor
    leftCat.BorderSizePixel = 0
    leftCat.ScrollBarThickness = 3
    leftCat.Parent = MainFrame
    Utils.removeSelection(leftCat)

    local leftLayout = Instance.new("UIListLayout")
    leftLayout.Padding = UDim.new(0, 2)
    leftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    leftLayout.Parent = leftCat

    local catNames = {"Legit", "Rage", "Aimbot", "Visual", "Body", "TP", "View", "World", "Farm", "Keys", "Set"}
    for i, name in ipairs(catNames) do
        local btn = Instance.new("TextButton")
        btn.Name = name .. "Btn"
        btn.Size = UDim2.new(0, 55, 0, 38)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Oswald
        btn.TextSize = 9
        btn.BorderSizePixel = 0
        btn.LayoutOrder = i
        btn.Parent = leftCat
        Utils.removeSelection(btn)
        Utils.addCorner(btn, 8)
        catBtns[name] = btn
    end
    leftCat.CanvasSize = UDim2.new(0, 0, 0, #catNames * 42)

    -- Content Frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -63, 1, -28)
    contentFrame.Position = UDim2.new(0, 63, 0, 28)
    contentFrame.BackgroundColor3 = State.guiBackgroundColor
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = MainFrame
    Utils.removeSelection(contentFrame)

    -- ScrollingFrame 1
    sf1 = Instance.new("ScrollingFrame")
    sf1.Name = "Column1"
    sf1.Size = UDim2.new(0.5, -8, 1, -10)
    sf1.Position = UDim2.new(0, 5, 0, 5)
    sf1.BackgroundColor3 = State.guiFrameColor
    sf1.BorderSizePixel = 0
    sf1.ScrollBarThickness = 4
    sf1.CanvasSize = UDim2.new(0, 0, 0, 0)
    sf1.BottomImage = ""
    sf1.TopImage = ""
    sf1.Parent = contentFrame
    Utils.removeSelection(sf1)

    local layout1 = Instance.new("UIListLayout")
    layout1.Padding = UDim.new(0, 8)
    layout1.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout1.SortOrder = Enum.SortOrder.LayoutOrder
    layout1.Parent = sf1

    -- ScrollingFrame 2
    sf2 = Instance.new("ScrollingFrame")
    sf2.Name = "Column2"
    sf2.Size = UDim2.new(0.5, -8, 1, -10)
    sf2.Position = UDim2.new(0.5, 3, 0, 5)
    sf2.BackgroundColor3 = State.guiFrameColor
    sf2.BorderSizePixel = 0
    sf2.ScrollBarThickness = 4
    sf2.CanvasSize = UDim2.new(0, 0, 0, 0)
    sf2.BottomImage = ""
    sf2.TopImage = ""
    sf2.Parent = contentFrame
    Utils.removeSelection(sf2)

    local layout2 = Instance.new("UIListLayout")
    layout2.Padding = UDim.new(0, 8)
    layout2.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout2.SortOrder = Enum.SortOrder.LayoutOrder
    layout2.Parent = sf2

    -- Drag handling
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = Services.UserInputService:GetMouseLocation()
            local framePos = MainFrame.AbsolutePosition
            local frameSize = MainFrame.AbsoluteSize
            if mousePos.X >= framePos.X and mousePos.X <= framePos.X + frameSize.X and
               mousePos.Y >= framePos.Y and mousePos.Y <= framePos.Y + 28 then
                isDragging = true
                dragStart = mousePos
                frameStart = MainFrame.Position
            end
        end
    end)

    Services.UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = Services.UserInputService:GetMouseLocation() - dragStart
            MainFrame.Position = UDim2.new(
                frameStart.X.Scale, frameStart.X.Offset + delta.X,
                frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
            )
        end
    end)

    Services.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)

    print("[GUIManager] Created")
end

function GUIManager.toggleGUI()
    State.guiOpen = not State.guiOpen
    if State.guiOpen then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 480 * State.guiSize)
        Utils.tween(MainFrame, {Size = UDim2.new(0, 800 * State.guiSize, 0, 480 * State.guiSize)}, 0.3)
    else
        Utils.tween(MainFrame, {Size = UDim2.new(0, 0, 0, 480 * State.guiSize)}, 0.2)
        task.wait(0.2)
        MainFrame.Visible = false
    end
end

function GUIManager.updateColors()
    MainFrame.BackgroundColor3 = State.guiBackgroundColor
    MainFrameStroke.Color = State.guiStrokeColor
    if sf1 then sf1.BackgroundColor3 = State.guiFrameColor end
    if sf2 then sf2.BackgroundColor3 = State.guiFrameColor end
end

function GUIManager.getScreenGui() return screenGui end
function GUIManager.getMainFrame() return MainFrame end
function GUIManager.getScrollingFrame1() return sf1 end
function GUIManager.getScrollingFrame2() return sf2 end
function GUIManager.getCatBtns() return catBtns end

return GUIManager
