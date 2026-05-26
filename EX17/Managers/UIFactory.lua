-- Managers/UIFactory.lua
-- UI Factory: прозрачные фреймы с UICorner, тумблеры, слайдеры, дропдауны, цвет, клавиши

local UIFactory = {}
local Services = require(script.Parent.Parent.Core.Services)
local Utils = require(script.Parent.Parent.Core.Utils)
local State = require(script.Parent.Parent.Core.State)
local ColorPicker = nil -- Загрузим позже чтобы избежать циклической зависимости

-- ========================================
-- FUNCTION FRAME (прозрачный + UICorner)
-- ========================================
function UIFactory.createFunctionFrame(parent, funcName, layoutOrder)
    local frame = Instance.new("Frame")
    frame.Name = funcName .. "Frame"
    frame.Size = UDim2.new(1, -8, 0, 55)
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame.BackgroundTransparency = 0.92
    frame.BorderSizePixel = 0
    frame.LayoutOrder = layoutOrder or 0
    frame.Parent = parent
    Utils.removeSelection(frame)
    Utils.addCorner(frame, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 140, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 3)
    label.BackgroundTransparency = 1
    label.Text = funcName
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Oswald
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    Utils.removeSelection(label)

    return frame
end

-- ========================================
-- TUMBLER (переключатель)
-- ========================================
function UIFactory.addThumbler(parent, default, callback)
    local tumbler = Instance.new("TextButton")
    tumbler.Name = "Tumbler"
    tumbler.Size = UDim2.new(0, 44, 0, 22)
    tumbler.Position = UDim2.new(1, -54, 0, 2)
    tumbler.BackgroundColor3 = default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 50, 50)
    tumbler.Text = ""
    tumbler.BorderSizePixel = 0
    tumbler.Parent = parent
    Utils.removeSelection(tumbler)
    Utils.addCorner(tumbler, 11)

    local ball = Instance.new("Frame")
    ball.Size = UDim2.new(0, 16, 0, 16)
    ball.Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    ball.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ball.BorderSizePixel = 0
    ball.Parent = tumbler
    Utils.removeSelection(ball)
    Utils.addCorner(ball, 8)

    local enabled = default

    local function setToggle(newState, animate)
        enabled = newState
        local pos = enabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        local col = enabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 50, 50)
        if animate == false then
            ball.Position = pos
            tumbler.BackgroundColor3 = col
        else
            Utils.tween(ball, {Position = pos}, 0.2)
            Utils.tween(tumbler, {BackgroundColor3 = col}, 0.2)
        end
        if callback then callback(enabled) end
    end

    tumbler.MouseButton1Click:Connect(function()
        Utils.playClickSound(State.clickSound, State.clickVolume)
        setToggle(not enabled, true)
    end)

    return setToggle
end

-- ========================================
-- SLIDER (Integer) с TextBox
-- ========================================
function UIFactory.addSlider(parent, min, max, default, callback)
    local value = default

    local valueBox = Instance.new("TextBox")
    valueBox.Size = UDim2.new(0, 50, 0, 18)
    valueBox.Position = UDim2.new(1, -58, 0, 34)
    valueBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    valueBox.Text = tostring(value)
    valueBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueBox.Font = Enum.Font.Oswald
    valueBox.TextSize = 11
    valueBox.Parent = parent
    Utils.removeSelection(valueBox)
    Utils.addCorner(valueBox, 4)

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -16, 0, 6)
    sliderBg.Position = UDim2.new(0, 10, 0, 30)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    sliderBg.BorderSizePixel = 0
    sliderBg.Active = true
    sliderBg.Parent = parent
    Utils.removeSelection(sliderBg)
    Utils.addCorner(sliderBg, 3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(70, 70, 200)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    Utils.removeSelection(fill)
    Utils.addCorner(fill, 3)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((value - min) / (max - min), -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = sliderBg
    Utils.removeSelection(knob)
    Utils.addCorner(knob, 7)

    local dragging = false

    local function update(inputPos)
        local relX = math.clamp((inputPos.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * relX + 0.5)
        fill.Size = UDim2.new(relX, 0, 1, 0)
        knob.Position = UDim2.new(relX, -7, 0.5, -7)
        valueBox.Text = tostring(value)
        callback(value)
    end

    valueBox.FocusLost:Connect(function()
        local n = tonumber(valueBox.Text)
        if n then
            value = math.clamp(math.floor(n + 0.5), min, max)
            valueBox.Text = tostring(value)
            local relX = (value - min) / (max - min)
            fill.Size = UDim2.new(relX, 0, 1, 0)
            knob.Position = UDim2.new(relX, -7, 0.5, -7)
            callback(value)
        end
    end)

    sliderBg.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(i.Position)
        end
    end)

    Services.UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            update(i.Position)
        end
    end)

    Services.UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            Utils.playClickSound(State.clickSound, State.clickVolume)
        end
    end)
end

-- ========================================
-- FLOAT SLIDER с TextBox
-- ========================================
function UIFactory.addFloatSlider(parent, min, max, default, callback)
    local value = default

    local valueBox = Instance.new("TextBox")
    valueBox.Size = UDim2.new(0, 50, 0, 18)
    valueBox.Position = UDim2.new(1, -58, 0, 34)
    valueBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    valueBox.Text = string.format("%.2f", value)
    valueBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueBox.Font = Enum.Font.Oswald
    valueBox.TextSize = 11
    valueBox.Parent = parent
    Utils.removeSelection(valueBox)
    Utils.addCorner(valueBox, 4)

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -16, 0, 6)
    sliderBg.Position = UDim2.new(0, 10, 0, 30)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    sliderBg.BorderSizePixel = 0
    sliderBg.Active = true
    sliderBg.Parent = parent
    Utils.removeSelection(sliderBg)
    Utils.addCorner(sliderBg, 3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(70, 70, 200)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    Utils.removeSelection(fill)
    Utils.addCorner(fill, 3)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((value - min) / (max - min), -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = sliderBg
    Utils.removeSelection(knob)
    Utils.addCorner(knob, 7)

    local dragging = false

    local function update(inputPos)
        local relX = math.clamp((inputPos.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        value = min + (max - min) * relX
        fill.Size = UDim2.new(relX, 0, 1, 0)
        knob.Position = UDim2.new(relX, -7, 0.5, -7)
        valueBox.Text = string.format("%.2f", value)
        callback(value)
    end

    valueBox.FocusLost:Connect(function()
        local n = tonumber(valueBox.Text)
        if n then
            value = math.clamp(n, min, max)
            valueBox.Text = string.format("%.2f", value)
            local relX = (value - min) / (max - min)
            fill.Size = UDim2.new(relX, 0, 1, 0)
            knob.Position = UDim2.new(relX, -7, 0.5, -7)
            callback(value)
        end
    end)

    sliderBg.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(i.Position)
        end
    end)

    Services.UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            update(i.Position)
        end
    end)

    Services.UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            Utils.playClickSound(State.clickSound, State.clickVolume)
        end
    end)
end

-- ========================================
-- DROPDOWN
-- ========================================
function UIFactory.addDropdown(parent, options, default, callback)
    local selected = Instance.new("TextButton")
    selected.Size = UDim2.new(0, 100, 0, 22)
    selected.Position = UDim2.new(0, 10, 0, 28)
    selected.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    selected.Text = default
    selected.TextColor3 = Color3.fromRGB(255, 255, 255)
    selected.Font = Enum.Font.Oswald
    selected.TextSize = 13
    selected.BorderSizePixel = 0
    selected.Parent = parent
    Utils.removeSelection(selected)
    Utils.addCorner(selected, 5)

    local dropdown = Instance.new("Frame")
    dropdown.Size = UDim2.new(0, 100, 0, #options * 28)
    dropdown.Position = UDim2.new(0, 10, 0, 50)
    dropdown.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    dropdown.BorderSizePixel = 0
    dropdown.Visible = false
    dropdown.ZIndex = 10
    dropdown.Parent = parent
    Utils.removeSelection(dropdown)
    Utils.addCorner(dropdown, 5)

    local layout = Instance.new("UIListLayout")
    layout.Parent = dropdown

    for _, opt in ipairs(options) do
        local ob = Instance.new("TextButton")
        ob.Size = UDim2.new(1, 0, 0, 28)
        ob.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        ob.Text = opt
        ob.TextColor3 = Color3.fromRGB(255, 255, 255)
        ob.Font = Enum.Font.Oswald
        ob.TextSize = 13
        ob.BorderSizePixel = 0
        ob.ZIndex = 11
        ob.Parent = dropdown
        Utils.removeSelection(ob)
        ob.MouseButton1Click:Connect(function()
            Utils.playClickSound(State.clickSound, State.clickVolume)
            selected.Text = opt
            dropdown.Visible = false
            callback(opt)
        end)
    end

    selected.MouseButton1Click:Connect(function()
        Utils.playClickSound(State.clickSound, State.clickVolume)
        dropdown.Visible = not dropdown.Visible
    end)
end

-- ========================================
-- COLOR SLIDER (RGB полоски + превью для ColorPicker)
-- ========================================
function UIFactory.addColorSlider(parent, text, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -8, 0, 100)
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame.BackgroundTransparency = 0.92
    frame.BorderSizePixel = 0
    frame.Parent = parent
    Utils.removeSelection(frame)
    Utils.addCorner(frame, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 140, 0, 18)
    label.Position = UDim2.new(0, 10, 0, 2)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Oswald
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    Utils.removeSelection(label)

    local rv, gv, bv = 255, 50, 50

    local preview = Instance.new("TextButton")
    preview.Size = UDim2.new(0, 40, 0, 20)
    preview.Position = UDim2.new(1, -50, 0, 2)
    preview.BackgroundColor3 = Color3.fromRGB(rv, gv, bv)
    preview.BorderSizePixel = 0
    preview.Text = ""
    preview.Parent = frame
    Utils.removeSelection(preview)
    Utils.addCorner(preview, 4)

    -- При клике открываем ColorPicker
    preview.MouseButton1Click:Connect(function()
        if not ColorPicker then
            ColorPicker = require(script.Parent.ColorPicker)
        end
        ColorPicker.open(function(color)
            rv = math.floor(color.R * 255)
            gv = math.floor(color.G * 255)
            bv = math.floor(color.B * 255)
            preview.BackgroundColor3 = Color3.fromRGB(rv, gv, bv)
            rFill.Size = UDim2.new(rv / 255, 0, 1, 0)
            gFill.Size = UDim2.new(gv / 255, 0, 1, 0)
            bFill.Size = UDim2.new(bv / 255, 0, 1, 0)
            callback(Color3.fromRGB(rv, gv, bv))
        end, Color3.fromRGB(rv, gv, bv))
    end)

    local function makeRGB(char, color, yPos, setVal)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0, 15, 0, 16)
        lbl.Position = UDim2.new(0, 7, 0, yPos)
        lbl.BackgroundTransparency = 1
        lbl.Text = char
        lbl.TextColor3 = color
        lbl.Font = Enum.Font.Oswald
        lbl.TextSize = 12
        lbl.Parent = frame
        Utils.removeSelection(lbl)

        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(1, -30, 0, 5)
        slider.Position = UDim2.new(0, 24, 0, yPos + 6)
        slider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        slider.BorderSizePixel = 0
        slider.Active = true
        slider.Parent = frame
        Utils.removeSelection(slider)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(1, 0, 1, 0)
        fill.BackgroundColor3 = color
        fill.BorderSizePixel = 0
        fill.Parent = slider
        Utils.removeSelection(fill)

        local dragging = false

        local function update(inputPos)
            local relX = math.clamp((inputPos.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            local val = math.floor(255 * relX)
            setVal(val)
            fill.Size = UDim2.new(relX, 0, 1, 0)
            preview.BackgroundColor3 = Color3.fromRGB(rv, gv, bv)
            callback(Color3.fromRGB(rv, gv, bv))
        end

        slider.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                update(i.Position)
            end
        end)

        Services.UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                update(i.Position)
            end
        end)

        Services.UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                Utils.playClickSound(State.clickSound, State.clickVolume)
            end
        end)

        return fill
    end

    local rFill = makeRGB("R", Color3.fromRGB(255, 0, 0), 24, function(v) rv = v end)
    local gFill = makeRGB("G", Color3.fromRGB(0, 255, 0), 48, function(v) gv = v end)
    local bFill = makeRGB("B", Color3.fromRGB(0, 0, 255), 72, function(v) bv = v end)
end

-- ========================================
-- KEYBIND BUTTON
-- ========================================
function UIFactory.addKeybindButton(parent, actionName, currentKey)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -16, 0, 30)
    frame.Position = UDim2.new(0, 10, 0, 25)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    Utils.removeSelection(frame)
    Utils.addCorner(frame, 5)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 120, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = actionName
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Oswald
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    Utils.removeSelection(label)

    local keyBtn = Instance.new("TextButton")
    keyBtn.Size = UDim2.new(0, 75, 1, -4)
    keyBtn.Position = UDim2.new(1, -79, 0, 2)
    keyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    keyBtn.Text = currentKey
    keyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBtn.Font = Enum.Font.Oswald
    keyBtn.TextSize = 11
    keyBtn.BorderSizePixel = 0
    keyBtn.Parent = frame
    Utils.removeSelection(keyBtn)
    Utils.addCorner(keyBtn, 4)

    keyBtn.MouseButton1Click:Connect(function()
        Utils.playClickSound(State.clickSound, State.clickVolume)
        keyBtn.Text = "..."
        Utils.tween(keyBtn, {BackgroundColor3 = Color3.fromRGB(200, 150, 0)}, 0.2)
        State.waitingForKeybind = actionName
    end)

    return keyBtn
end

return UIFactory
