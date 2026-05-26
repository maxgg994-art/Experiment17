-- Managers/ColorPicker.lua
-- HSV Color Picker с HEX-вводом, открывается при клике на превью цвета

local ColorPicker = {}
local Services = _G.Experiment17.Services
local Utils = require(script.Parent.Parent.Core.Utils)
local State = require(script.Parent.Parent.Core.State)
local GUIManager = require(script.Parent.GUIManager)

local pickerFrame
local colorField, colorDot
local hueBar, hueDot
local hexBox

function ColorPicker.open(callback, currentColor)
    State.colorPickerCallback = callback
    local h, s, v = currentColor:ToHSV()
    State.colorPickerHue = h
    State.colorPickerSat = s
    State.colorPickerVal = v

    -- Создать окно если ещё нет
    if not pickerFrame then
        ColorPicker.create()
    end

    pickerFrame.Visible = true
    ColorPicker.updatePreview()
end

function ColorPicker.close()
    pickerFrame.Visible = false
    State.colorPickerOpen = false
end

function ColorPicker.create()
    local frame = Instance.new("Frame")
    frame.Name = "ColorPicker"
    frame.Size = UDim2.new(0, 240, 0, 300)
    frame.Position = UDim2.new(0.5, -120, 0.5, -150)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    frame.ZIndex = 500
    frame.Parent = GUIManager.getScreenGui()
    Utils.removeSelection(frame)
    Utils.addCorner(frame, 10)

    -- Цветовое поле (SV)
    colorField = Instance.new("ImageButton")
    colorField.Name = "ColorField"
    colorField.Size = UDim2.new(0, 180, 0, 180)
    colorField.Position = UDim2.new(0, 10, 0, 30)
    colorField.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    colorField.BorderSizePixel = 0
    colorField.ZIndex = 501
    colorField.Parent = frame
    Utils.removeSelection(colorField)

    -- Кружок на поле
    colorDot = Instance.new("Frame")
    colorDot.Name = "ColorDot"
    colorDot.Size = UDim2.new(0, 12, 0, 12)
    colorDot.Position = UDim2.new(0.5, -6, 0.5, -6)
    colorDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    colorDot.BorderSizePixel = 2
    colorDot.BorderColor3 = Color3.fromRGB(0, 0, 0)
    colorDot.ZIndex = 502
    colorDot.Parent = colorField
    Utils.removeSelection(colorDot)
    Utils.addCorner(colorDot, 6)

    -- Hue полоска
    hueBar = Instance.new("Frame")
    hueBar.Name = "HueBar"
    hueBar.Size = UDim2.new(0, 20, 0, 180)
    hueBar.Position = UDim2.new(0, 200, 0, 30)
    hueBar.BorderSizePixel = 0
    hueBar.ZIndex = 501
    hueBar.Parent = frame

    local hueGradient = Instance.new("UIGradient")
    hueGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
    })
    hueGradient.Parent = hueBar

    -- Hue индикатор
    hueDot = Instance.new("Frame")
    hueDot.Name = "HueDot"
    hueDot.Size = UDim2.new(1, 4, 0, 6)
    hueDot.Position = UDim2.new(0, -2, 0, -3)
    hueDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hueDot.BorderSizePixel = 1
    hueDot.BorderColor3 = Color3.fromRGB(0, 0, 0)
    hueDot.ZIndex = 502
    hueDot.Parent = hueBar
    Utils.removeSelection(hueDot)

    -- HEX поле
    hexBox = Instance.new("TextBox")
    hexBox.Name = "HexBox"
    hexBox.Size = UDim2.new(0, 80, 0, 24)
    hexBox.Position = UDim2.new(0, 10, 0, 220)
    hexBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    hexBox.Text = "#FF0000"
    hexBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    hexBox.Font = Enum.Font.Oswald
    hexBox.TextSize = 14
    hexBox.PlaceholderText = "#FFFFFF"
    hexBox.ZIndex = 501
    hexBox.Parent = frame
    Utils.removeSelection(hexBox)
    Utils.addCorner(hexBox, 4)

    -- OK кнопка
    local okBtn = Instance.new("TextButton")
    okBtn.Size = UDim2.new(0, 60, 0, 24)
    okBtn.Position = UDim2.new(0, 10, 0, 255)
    okBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    okBtn.Text = "OK"
    okBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    okBtn.Font = Enum.Font.Oswald
    okBtn.TextSize = 14
    okBtn.ZIndex = 501
    okBtn.Parent = frame
    Utils.removeSelection(okBtn)
    Utils.addCorner(okBtn, 4)

    -- Cancel кнопка
    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.new(0, 60, 0, 24)
    cancelBtn.Position = UDim2.new(0, 80, 0, 255)
    cancelBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    cancelBtn.Text = "Cancel"
    cancelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelBtn.Font = Enum.Font.Oswald
    cancelBtn.TextSize = 14
    cancelBtn.ZIndex = 501
    cancelBtn.Parent = frame
    Utils.removeSelection(cancelBtn)
    Utils.addCorner(cancelBtn, 4)

    pickerFrame = frame

    -- Обработчики событий
    colorField.MouseButton1Down:Connect(function() ColorPicker.updateColorFromField() end)
    colorField.MouseMoved:Connect(function()
        if Services.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            ColorPicker.updateColorFromField()
        end
    end)

    hueBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            ColorPicker.updateHueFromBar(i.Position)
        end
    end)
    hueBar.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            if Services.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                ColorPicker.updateHueFromBar(i.Position)
            end
        end
    end)

    hexBox.FocusLost:Connect(function()
        local hex = hexBox.Text:gsub("#", "")
        local r = tonumber("0x" .. hex:sub(1, 2))
        local g = tonumber("0x" .. hex:sub(3, 4))
        local b = tonumber("0x" .. hex:sub(5, 6))
        if r and g and b then
            local c = Color3.fromRGB(r, g, b)
            local h, s, v = c:ToHSV()
            State.colorPickerHue = h
            State.colorPickerSat = s
            State.colorPickerVal = v
            ColorPicker.updatePreview()
        end
    end)

    okBtn.MouseButton1Click:Connect(function()
        if State.colorPickerCallback then
            local c = Color3.fromHSV(State.colorPickerHue, State.colorPickerSat, State.colorPickerVal)
            State.colorPickerCallback(c)
        end
        ColorPicker.close()
    end)

    cancelBtn.MouseButton1Click:Connect(function()
        ColorPicker.close()
    end)
end

function ColorPicker.updateColorFromField()
    local mousePos = Services.UserInputService:GetMouseLocation()
    local fp = colorField.AbsolutePosition
    local fs = colorField.AbsoluteSize
    local rx = math.clamp((mousePos.X - fp.X) / fs.X, 0, 1)
    local ry = math.clamp((mousePos.Y - fp.Y) / fs.Y, 0, 1)
    State.colorPickerSat = rx
    State.colorPickerVal = 1 - ry
    ColorPicker.updatePreview()
end

function ColorPicker.updateHueFromBar(inputPos)
    local bp = hueBar.AbsolutePosition
    local bs = hueBar.AbsoluteSize
    local ry = math.clamp((inputPos.Y - bp.Y) / bs.Y, 0, 1)
    State.colorPickerHue = ry
    ColorPicker.updatePreview()
end

function ColorPicker.updatePreview()
    local c = Color3.fromHSV(State.colorPickerHue, State.colorPickerSat, State.colorPickerVal)

    -- Обновить цвет поля
    local fieldC = Color3.fromHSV(State.colorPickerHue, 1, 1)
    colorField.BackgroundColor3 = fieldC

    -- Позиция кружка
    colorDot.Position = UDim2.new(State.colorPickerSat, -6, 1 - State.colorPickerVal, -6)

    -- Позиция Hue индикатора
    hueDot.Position = UDim2.new(0, -2, State.colorPickerHue, -3)

    -- HEX
    hexBox.Text = Utils.colorToHex(c)
end

print("[ColorPicker] Loaded")
return ColorPicker
