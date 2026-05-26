-- Managers/GUIManager.lua
-- Главный GUI: MainFrame, категории, скроллфреймы, перетаскивание, тоггл

local GUIManager = {}
local Services = _G.Experiment17.Services
local Utils = require(script.Parent.Parent.Core.Utils)
local State = require(script.Parent.Parent.Core.State)

-- Внешние ссылки для других модулей
local screenGui
local MainFrame
local MainFrameStroke
local ScrollingFrame1
local ScrollingFrame2
local LeftCategoriesFrame
local catBtns = {}
local isDraggingGUI = false
local guiDragStart, guiFrameStart

function GUIManager.create()
    local scale = State.guiSize

    -- ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Experiment17"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Services.playerGui
    Utils.removeSelection(screenGui)

    -- MainFrame
    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 800 * scale, 0, 480 * scale)
    MainFrame.Position = UDim2.new(0.5, -400 * scale, 0, 50)
    MainFrame.BackgroundColor3 = State.guiBackgroundColor
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = false
    MainFrame.Draggable = false
    MainFrame.Visible = State.guiOpen
    MainFrame.Parent = screenGui
    Utils.removeSelection(MainFrame)
    Utils.addCorner(MainFrame, 10)
    MainFrameStroke = Utils.addStroke(MainFrame, 2, State.guiStrokeColor)

    -- TopBar "Experiment17"
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 26)
    topBar.Position = UDim2.new(0, 0, 0, 0)
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

    -- Hint Label
    local hintLabel = Instance.new("TextLabel")
    hintLabel.Size = UDim2.new(1, -130, 0, 20)
    hintLabel.Position = UDim2.new(0, 65, 0, 28)
    hintLabel.BackgroundTransparency = 1
    hintLabel.Text = "RightShift - GUI | LeftAlt - Mouse | L - Select TP | / - Teleport"
    hintLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    hintLabel.Font = Enum.Font.Oswald
    hintLabel.TextSize = 10
    hintLabel.TextXAlignment = Enum.TextXAlignment.Right
    hintLabel.Parent = MainFrame
    Utils.removeSelection(hintLabel)

    -- Left Categories Frame
    LeftCategoriesFrame = Instance.new("ScrollingFrame")
    LeftCategoriesFrame.Name = "LeftCategories"
    LeftCategoriesFrame.Size = UDim2.new(0, 63, 1, -28)
    LeftCategoriesFrame.Position = UDim2.new(0, 0, 0, 28)
    LeftCategoriesFrame.BackgroundColor3 = State.guiBackgroundColor
    LeftCategoriesFrame.BorderSizePixel = 0
    LeftCategoriesFrame.ScrollBarThickness = 3
    LeftCategoriesFrame.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 200)
    LeftCategoriesFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    LeftCategoriesFrame.Parent = MainFrame
    Utils.removeSelection(LeftCategoriesFrame)
    Utils.addCorner(LeftCategoriesFrame, 10)

    local leftLayout = Instance.new("UIListLayout")
    leftLayout.Padding = UDim.new(0, 2)
    leftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    leftLayout.Parent = LeftCategoriesFrame

    -- Content Frame
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -63, 1, -28)
    ContentFrame.Position = UDim2.new(0, 63, 0, 28)
    ContentFrame.BackgroundColor3 = State.guiBackgroundColor
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Parent = MainFrame
    Utils.removeSelection(ContentFrame)
    Utils.addCorner(ContentFrame, 10)

    -- ScrollingFrame 1
    ScrollingFrame1 = Instance.new("ScrollingFrame")
    ScrollingFrame1.Name = "Column1"
    ScrollingFrame1.Size = UDim2.new(0.5, -8, 1, -10)
    ScrollingFrame1.Position = UDim2.new(0, 5, 0, 5)
    ScrollingFrame1.BackgroundColor3 = State.guiFrameColor
    ScrollingFrame1.BorderSizePixel = 0
    ScrollingFrame1.ScrollBarThickness = 4
    ScrollingFrame1.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollingFrame1.BottomImage = ""
    ScrollingFrame1.TopImage = ""
    ScrollingFrame1.Parent = ContentFrame
    Utils.removeSelection(ScrollingFrame1)

    local layout1 = Instance.new("UIListLayout")
    layout1.Padding = UDim.new(0, 8)
    layout1.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout1.SortOrder = Enum.SortOrder.LayoutOrder
    layout1.Parent = ScrollingFrame1

    -- ScrollingFrame 2
    ScrollingFrame2 = Instance.new("ScrollingFrame")
    ScrollingFrame2.Name = "Column2"
    ScrollingFrame2.Size = UDim2.new(0.5, -8, 1, -10)
    ScrollingFrame2.Position = UDim2.new(0.5, 3, 0, 5)
    ScrollingFrame2.BackgroundColor3 = State.guiFrameColor
    ScrollingFrame2.BorderSizePixel = 0
    ScrollingFrame2.ScrollBarThickness = 4
    ScrollingFrame2.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollingFrame2.BottomImage = ""
    ScrollingFrame2.TopImage = ""
    ScrollingFrame2.Parent = ContentFrame
    Utils.removeSelection(ScrollingFrame2)

    local layout2 = Instance.new("UIListLayout")
    layout2.Padding = UDim.new(0, 8)
    layout2.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout2.SortOrder = Enum.SortOrder.LayoutOrder
    layout2.Parent = ScrollingFrame2

    -- Создание кнопок категорий
    local catNames = {"Legit","Rage","Aimbot","Visual","Body","TP","View","World","Farm","Keys","Set"}
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
        btn.Parent = LeftCategoriesFrame
        Utils.removeSelection(btn)
        Utils.addCorner(btn, 8)
        catBtns[name] = btn
    end

    LeftCategoriesFrame.CanvasSize = UDim2.new(0, 0, 0, #catNames * 42)

    -- Перетаскивание GUI
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = Services.UserInputService:GetMouseLocation()
            local framePos = MainFrame.AbsolutePosition
            local frameSize = MainFrame.AbsoluteSize
            if mousePos.X >= framePos.X and mousePos.X <= framePos.X + frameSize.X and
               mousePos.Y >= framePos.Y and mousePos.Y <= framePos.Y + 28 then
                isDraggingGUI = true
                guiDragStart = mousePos
                guiFrameStart = MainFrame.Position
            end
        end
    end)

    Services.UserInputService.InputChanged:Connect(function(input)
        if isDraggingGUI and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = Services.UserInputService:GetMouseLocation() - guiDragStart
            MainFrame.Position = UDim2.new(
                guiFrameStart.X.Scale, guiFrameStart.X.Offset + delta.X,
                guiFrameStart.Y.Scale, guiFrameStart.Y.Offset + delta.Y
            )
        end
    end)

    Services.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingGUI = false
        end
    end)

    print("[GUIManager] Created")
end

-- Тоггл GUI
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

-- Обновление цветов GUI
function GUIManager.updateColors()
    MainFrame.BackgroundColor3 = State.guiBackgroundColor
    MainFrameStroke.Color = State.guiStrokeColor
    ScrollingFrame1.BackgroundColor3 = State.guiFrameColor
    ScrollingFrame2.BackgroundColor3 = State.guiFrameColor
    LeftCategoriesFrame.BackgroundColor3 = State.guiBackgroundColor
end

-- Геттеры
function GUIManager.getScreenGui() return screenGui end
function GUIManager.getMainFrame() return MainFrame end
function GUIManager.getScrollingFrame1() return ScrollingFrame1 end
function GUIManager.getScrollingFrame2() return ScrollingFrame2 end
function GUIManager.getCatBtns() return catBtns end

return GUIManager
