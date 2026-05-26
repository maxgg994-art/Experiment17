-- Managers/ESPManager.lua
-- ESP, Tracers, Highlights, Body Highlights, Player Info

local ESPManager = {}
local Services = _G.Experiment17.Services
local Utils = require(script.Parent.Parent.Core.Utils)
local State = require(script.Parent.Parent.Core.State)

function ESPManager.clearAll()
    for _, obj in ipairs(State.espObjects) do
        pcall(function() obj:Destroy() end)
    end
    table.clear(State.espObjects)

    for _, obj in ipairs(State.tracersList) do
        pcall(function() obj:Destroy() end)
    end
    table.clear(State.tracersList)
end

function ESPManager.createESP(target, isNPC)
    local char, displayName

    if isNPC then
        char = target
        displayName = target.Name
    else
        if target == Services.player or not target.Character then return end
        char = target.Character
        displayName = target.Name
    end

    local head = char:FindFirstChild("Head")
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not head or not root or not hum then return end

    -- Tracers
    if State.tracers then
        local cp = Instance.new("Part")
        cp.Name = "TracerCam"
        cp.Size = Vector3.new(0.05, 0.05, 0.05)
        cp.Transparency = 1
        cp.Anchored = true
        cp.CanCollide = false
        cp.CFrame = Services.camera.CFrame
        cp.Parent = Services.camera

        local a0 = Instance.new("Attachment"); a0.Parent = cp
        local a1 = Instance.new("Attachment"); a1.Parent = root

        local beam = Instance.new("Beam")
        beam.Attachment0 = a0
        beam.Attachment1 = a1
        beam.Width0 = State.tracerThickness * 5
        beam.Width1 = State.tracerThickness * 5
        beam.Color = ColorSequence.new(State.tracerColor)
        beam.Transparency = NumberSequence.new(0.2)
        beam.Texture = "rbxassetid://0"
        beam.TextureMode = Enum.TextureMode.Static
        beam.LightEmission = 1
        beam.Parent = cp

        table.insert(State.tracersList, cp)
        table.insert(State.tracersList, a0)
        table.insert(State.tracersList, a1)
        table.insert(State.tracersList, beam)
    end

    -- Player Material
    if not isNPC and State.playerMaterial ~= "Default" then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                pcall(function() part.Material = Enum.Material[State.playerMaterial] end)
            end
        end
    end

    -- Player Color
    if not isNPC and State.playerColor then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Color = State.playerColorValue
            end
        end
    end

    -- Rainbow
    if not isNPC and State.rainbowPlayers then
        task.spawn(function()
            local hue = 0
            while char and char.Parent and State.rainbowPlayers do
                hue = (hue + 0.003) % 1
                local c = Color3.fromHSV(hue, 1, 1)
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.Color = c
                    end
                end
                task.wait(0.1)
            end
        end)
    end

    if not State.espEnabled or (isNPC and not State.espNPC) then return end

    -- Highlight
    if State.espMode == "Highlight" or State.espMode == "Both" then
        local hl = Instance.new("Highlight")
        hl.Name = "ESP_Highlight"
        hl.FillColor = isNPC and Color3.fromRGB(255, 255, 0) or State.highlightFillColor
        hl.FillTransparency = State.espTransparency
        hl.OutlineColor = State.highlightOutline and State.highlightOutlineColor or Color3.fromRGB(0, 0, 0)
        hl.OutlineTransparency = State.highlightOutline and 0 or 1
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char
        table.insert(State.espObjects, hl)
    end

    -- Box
    if (State.espMode == "Box" or State.espMode == "Both") and root then
        local box = Instance.new("BillboardGui")
        box.Name = "ESP_Box"
        box.Size = UDim2.new(0, 4, 0, 6)
        box.AlwaysOnTop = true
        box.Adornee = root
        box.StudsOffset = Vector3.new(0, 2, 0)
        box.Parent = root

        local bf = Instance.new("Frame")
        bf.BackgroundTransparency = 1
        bf.Size = UDim2.new(1, 0, 1, 0)
        bf.Parent = box

        local st = Instance.new("UIStroke")
        st.Thickness = State.espThickness
        st.Color = State.espColor
        st.Parent = bf

        table.insert(State.espObjects, box)
    end

    -- Body Highlights
    if not isNPC then
        local function addHL(part, color, trans)
            if part then
                local h = Instance.new("Highlight")
                h.FillColor = color
                h.FillTransparency = trans
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                h.Parent = part
                table.insert(State.espObjects, h)
            end
        end

        if State.highlightHead then addHL(head, State.headColor, State.headTransparency) end
        if State.highlightTorso then
            local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
            addHL(torso, State.torsoColor, State.torsoTransparency)
        end
        if State.highlightArms then
            for _, n in ipairs({"LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm","LeftHand","RightHand"}) do
                addHL(char:FindFirstChild(n), State.armsColor, State.armsTransparency)
            end
        end
        if State.highlightLegs then
            for _, n in ipairs({"LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg","LeftFoot","RightFoot"}) do
                addHL(char:FindFirstChild(n), State.legsColor, State.legsTransparency)
            end
        end
    end

    -- Player Info (Name, Distance, Health)
    if State.espShowName or State.espShowDistance or State.espShowHealth then
        local info = Instance.new("BillboardGui")
        info.Name = "ESP_Info"
        info.Size = UDim2.new(0, 100, 0, 60)
        info.StudsOffset = Vector3.new(0, 2.5, 0)
        info.AlwaysOnTop = true
        info.Parent = head

        local il = Instance.new("TextLabel")
        il.Size = UDim2.new(1, 0, 1, 0)
        il.BackgroundTransparency = 1
        il.Font = Enum.Font.Oswald
        il.TextSize = 11
        il.TextColor3 = isNPC and Color3.fromRGB(255, 255, 0) or State.espColor
        il.Text = displayName
        il.Parent = info

        table.insert(State.espObjects, info)

        task.spawn(function()
            while info and info.Parent and char and char.Parent do
                local txt = ""
                if State.espShowName then txt = displayName end
                if State.espShowDistance and Services.player.Character then
                    local d = math.floor((root.Position - Services.player.Character:GetPivot().Position).Magnitude)
                    txt = txt ~= "" and txt .. " | " .. d .. "m" or d .. "m"
                end
                if State.espShowHealth and hum then
                    local hp = math.floor(hum.Health)
                    txt = txt ~= "" and txt .. " | " .. hp .. " HP" or hp .. " HP"
                end
                il.Text = txt
                task.wait(0.2)
            end
        end)
    end
end

function ESPManager.refreshAll()
    ESPManager.clearAll()
    Utils.updateNPCList(State.npcList)

    if State.espEnabled then
        for _, plr in ipairs(Services.Players:GetPlayers()) do
            ESPManager.createESP(plr, false)
        end
        if State.espNPC then
            for _, npc in ipairs(State.npcList) do
                ESPManager.createESP(npc, true)
            end
        end
    end
end

print("[ESPManager] Loaded")
return ESPManager
