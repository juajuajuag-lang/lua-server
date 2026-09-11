-- ============================================================
-- ESP + SKILL CHECK V5
-- Menu data-driven: palettes, toggles and submenus are generated
-- automatically to keep the script compact and easy to customize.
-- ============================================================

local Palettes = {
    Killer = {
        {"Rojo intenso", Color3.fromRGB(255, 0, 0)},
        {"Azul marino", Color3.fromRGB(0, 35, 110)},
        {"Verde militar", Color3.fromRGB(70, 90, 45)},
        {"Amarillo mostaza", Color3.fromRGB(220, 170, 30)},
        {"Naranja vibrante", Color3.fromRGB(255, 105, 0)},
        {"Morado oscuro", Color3.fromRGB(75, 0, 120)},
        {"Fucsia", Color3.fromRGB(255, 0, 170)},
        {"Negro", Color3.fromRGB(20, 20, 20)},
        {"Marrón oscuro", Color3.fromRGB(85, 45, 20)},
        {"Turquesa oscuro", Color3.fromRGB(0, 105, 105)}
    },
    Survivor = {
        {"Blanco", Color3.fromRGB(255, 255, 255)},
        {"Azul pastel", Color3.fromRGB(155, 205, 255)},
        {"Rosa pastel", Color3.fromRGB(255, 180, 205)},
        {"Verde menta", Color3.fromRGB(155, 240, 195)},
        {"Amarillo lavanda", Color3.fromRGB(225, 220, 155)},
        {"Durazno", Color3.fromRGB(255, 205, 165)},
        {"Lila", Color3.fromRGB(205, 175, 255)},
        {"Azul cielo", Color3.fromRGB(120, 210, 255)},
        {"Crema", Color3.fromRGB(255, 245, 205)},
        {"Salmón claro", Color3.fromRGB(255, 165, 145)},
        {"Verde pistacho", Color3.fromRGB(185, 225, 135)}
    },
    Generator = {
        {"Amarillo limón", Color3.fromRGB(225, 255, 55)},
        {"Turquesa claro", Color3.fromRGB(100, 235, 225)},
        {"Rosa chicle", Color3.fromRGB(255, 155, 205)},
        {"Verde manzana", Color3.fromRGB(120, 235, 90)},
        {"Naranja coral", Color3.fromRGB(255, 125, 85)},
        {"Azul eléctrico suave", Color3.fromRGB(105, 180, 255)},
        {"Mandarina claro", Color3.fromRGB(255, 180, 95)},
        {"Verde lima pastel", Color3.fromRGB(180, 240, 105)},
        {"Frambuesa suave", Color3.fromRGB(235, 110, 170)},
        {"Violeta radiante", Color3.fromRGB(190, 100, 255)}
    },
    Neon = {
        {"Blanco neon", Color3.fromRGB(245, 255, 255)},
        {"Rosa neon", Color3.fromRGB(255, 60, 180)},
        {"Naranja neon", Color3.fromRGB(255, 120, 25)},
        {"Rojo neon", Color3.fromRGB(255, 40, 55)},
        {"Amarillo neon", Color3.fromRGB(240, 255, 45)},
        {"Verde neon", Color3.fromRGB(60, 255, 90)},
        {"Ciano neon", Color3.fromRGB(30, 245, 255)},
        {"Azul neon", Color3.fromRGB(40, 125, 255)},
        {"Marrón neon", Color3.fromRGB(170, 95, 45)},
        {"Roxo neon", Color3.fromRGB(180, 55, 255)}
    }
}

local Config = {
    ESPGeneral = true,
    Killer = {
        Color = Palettes.Killer[1][2],
        Outline = true,
        Fill = true,
        Name = true,
        Distance = true,
        Warning = true
    },
    Survivor = {
        Outline = true,
        Fill = true,
        Name = true,
        Distance = true,
        States = {
            Normal = {Enabled = true, Color = Palettes.Survivor[2][2]},
            Injured = {Enabled = true, Color = Palettes.Survivor[5][2]},
            Knocked = {Enabled = true, Color = Palettes.Survivor[6][2]},
            Hooked = {Enabled = true, Color = Palettes.Survivor[3][2]}
        }
    },
    Generator = {
        Enabled = true,
        Color = Palettes.Generator[5][2],
        Fill = true,
        Outline = true,
        Distance = false,
        Percentage = true
    },
    Objects = {
        Hooks = {Enabled = true, Color = Palettes.Neon[1][2]},
        Pallets = {Enabled = true, Color = Palettes.Neon[3][2]},
        Windows = {Enabled = true, Color = Palettes.Neon[7][2]},
        Gates = {Enabled = true, Color = Palettes.Neon[8][2]}
    }
}

local MaskNames = {
    ["Richard"] = "Rooster",
    ["Tony"] = "Tiger",
    ["Brandon"] = "Panther",
    ["Cobra"] = "Cobra",
    ["Richter"] = "Rat",
    ["Rabbit"] = "Rabbit",
    ["Alex"] = "Chainsaw"
}

local MaskColors = {
    ["Richard"] = Color3.fromRGB(255, 0, 0),
    ["Tony"] = Color3.fromRGB(255, 255, 0),
    ["Brandon"] = Color3.fromRGB(160, 32, 240),
    ["Cobra"] = Color3.fromRGB(0, 255, 0),
    ["Richter"] = Color3.fromRGB(0, 0, 0),
    ["Rabbit"] = Color3.fromRGB(255, 105, 180),
    ["Alex"] = Color3.fromRGB(255, 255, 255)
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ActiveGenerators = {}
local TrackedESPObjects = {}
local TrackedESPSet = {}
local LastUpdateTick = 0
local LastPlayerESPUpdate = 0
local LastGeneratorUpdate = 0
local LastKillerDisplayUpdate = 0
local LastFullESPRefresh = 0
local ESPInitialized = false

local TouchID = 8822
local ActionPath = "Survivor-mob.Controls.action.check"
local HeartbeatConnection = nil
local VisibilityConnection = nil
local IndicatorGui = nil

-- Perfect Skill settings
local AutoSkillEnabled = true
local AutoSkillMode = "SUCCESS"
local MenuGui = nil
local MinimizedButton = nil
local AutoSkillVisibilityConnection = nil
local AutoSkillHeartbeatConnection = nil

local function SetupGui()
    if PlayerGui:FindFirstChild("ChasedInds") then 
        PlayerGui:FindFirstChild("ChasedInds"):Destroy() 
    end
    IndicatorGui = Instance.new("ScreenGui")
    IndicatorGui.Name = "ChasedInds"
    IndicatorGui.IgnoreGuiInset = true
    IndicatorGui.DisplayOrder = 999
    IndicatorGui.Parent = PlayerGui
end

local function GetGameValue(obj, name)
    if not obj then return nil end
    local attr = obj:GetAttribute(name)
    if attr ~= nil then return attr end
    
    local child = obj:FindFirstChild(name)
    if child then
        local success, val = pcall(function() return child.Value end)
        if success then return val end
    end
    return nil
end

local function ApplyHighlight(object, color, fillEnabled, outlineEnabled)
    if not object then return end
    local h = object:FindFirstChild("H")
    if not fillEnabled and not outlineEnabled then
        if h then h:Destroy() end
        return
    end
    h = h or Instance.new("Highlight")
    h.Name = "H"
    h.Adornee = object
    h.FillColor = color
    h.OutlineColor = color
    h.FillTransparency = fillEnabled and 0.8 or 1
    h.OutlineTransparency = outlineEnabled and 0.3 or 1
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = object
end

local function CreateBillboardTag(text, color, size, textSize)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "BitchHook"
    billboard.AlwaysOnTop = true
    billboard.Size = size or UDim2.new(0, 120, 0, 30)
    
    local label = Instance.new("TextLabel")
    label.Name = "BitchHook"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextSize = textSize or 10
    label.TextWrapped = true
    label.RichText = true 
    label.Parent = billboard
    
    return billboard
end

local function DestroyPlayerESP(player)
    if not player then return end
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")

    if root then
        for _, name in ipairs({"BitchHook", "MaskHook"}) do
            local gui = root:FindFirstChild(name)
            if gui then gui:Destroy() end
        end
    end

    if char then
        local h = char:FindFirstChild("H")
        if h then h:Destroy() end
        local warn = char:FindFirstChild("KillerWarn")
        if warn then warn:Destroy() end
    end

    if IndicatorGui then
        for _, suffix in ipairs({"_Chased", "_Killer"}) do
            local gui = IndicatorGui:FindFirstChild(player.Name .. suffix)
            if gui then gui:Destroy() end
        end
    end
end

local function updatePlayerNametag(player)
    if not IndicatorGui or not IndicatorGui.Parent then return end

    if not Config.ESPGeneral then
        local m = IndicatorGui:FindFirstChild(player.Name) if m then m:Destroy() end
        local c = IndicatorGui:FindFirstChild(player.Name .. "_Chased") if c then c:Destroy() end
        local k = IndicatorGui:FindFirstChild(player.Name .. "_Killer") if k then k:Destroy() end
        if player.Character then
            local h = player.Character:FindFirstChild("H")
            if h then h:Destroy() end
        end
        return
    end

    if not player.Character then
        local m = IndicatorGui:FindFirstChild(player.Name) if m then m:Destroy() end
        local c = IndicatorGui:FindFirstChild(player.Name .. "_Chased") if c then c:Destroy() end
        local k = IndicatorGui:FindFirstChild(player.Name .. "_Killer") if k then k:Destroy() end
        return
    end

    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not rootPart then return end

    local teamName = (player.Team and player.Team.Name:lower()) or ""
    local selectedKillerAttr = GetGameValue(player, "SelectedKiller")
    local rawMask = GetGameValue(player, "Mask") or GetGameValue(player.Character, "Mask")
    local isKnocked = GetGameValue(player.Character, "Knocked")
    local isHooked = GetGameValue(player.Character, "IsHooked")
    local isChased = GetGameValue(player.Character, "IsChased")
    local isKiller = teamName:find("killer") ~= nil

    local group = isKiller and Config.Killer or Config.Survivor
    local color = isKiller and Config.Killer.Color or Config.Survivor.States.Normal.Color

    if not isKiller then
        if isHooked then
            color = Config.Survivor.States.Hooked.Color
        elseif humanoid and humanoid.Health < humanoid.MaxHealth then
            color = isKnocked and Config.Survivor.States.Knocked.Color or Config.Survivor.States.Injured.Color
        end
    end

    local distance = 0
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        distance = math.floor((rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
    end

    local showName = isKiller and Config.Killer.Name or Config.Survivor.Name
    local showDistance = isKiller and Config.Killer.Distance or Config.Survivor.Distance

    if not showName and not showDistance then
        local old = rootPart:FindFirstChild("BitchHook")
        if old then old:Destroy() end
    else
        local selectedName = (isKiller and selectedKillerAttr and tostring(selectedKillerAttr) ~= "")
            and tostring(selectedKillerAttr) or player.Name
        local parts = {}
        if showName then table.insert(parts, selectedName) end
        if showDistance then table.insert(parts, "[" .. distance .. " studs]") end
        local nameText = table.concat(parts, "\n")

        local billboard = rootPart:FindFirstChild("BitchHook")
        if not billboard then
            billboard = CreateBillboardTag(nameText, color)
            billboard.Adornee = rootPart
            billboard.Parent = rootPart
        else
            local lbl = billboard:FindFirstChild("BitchHook") or billboard:FindFirstChildOfClass("TextLabel")
            if lbl then
                lbl.Text = nameText
                lbl.TextColor3 = color
            end
        end
    end

    if isKiller then
        ApplyHighlight(player.Character, color, Config.Killer.Fill, Config.Killer.Outline)
    else
        local stateEnabled = Config.Survivor.States.Normal.Enabled
        if isHooked then
            stateEnabled = Config.Survivor.States.Hooked.Enabled
        elseif humanoid and humanoid.Health < humanoid.MaxHealth then
            stateEnabled = isKnocked and Config.Survivor.States.Knocked.Enabled or Config.Survivor.States.Injured.Enabled
        end
        if stateEnabled then
            ApplyHighlight(player.Character, color, Config.Survivor.Fill, Config.Survivor.Outline)
        else
            local h = player.Character:FindFirstChild("H")
            if h then h:Destroy() end
        end
    end

    -- Mask label remains available for killers when the game exposes a mask value.
    local hasMask = false
    if isKiller and string.match(tostring(selectedKillerAttr):lower(), "masked") and rawMask then
        local searchMask = tostring(rawMask):lower()
        for key, name in pairs(MaskNames) do
            if key:lower() == searchMask then
                hasMask = true
                local maskBillboard = rootPart:FindFirstChild("MaskHook")
                if not maskBillboard then
                    maskBillboard = CreateBillboardTag(name, MaskColors[key] or Color3.new(1,1,1), UDim2.new(0, 100, 0, 20), 12)
                    maskBillboard.Name = "MaskHook"
                    maskBillboard.StudsOffset = Vector3.new(0, 3, 0)
                    maskBillboard.Adornee = rootPart
                    maskBillboard.Parent = rootPart
                else
                    local lbl = maskBillboard:FindFirstChild("BitchHook") or maskBillboard:FindFirstChildOfClass("TextLabel")
                    if lbl then
                        lbl.Text = name
                        lbl.TextColor3 = MaskColors[key] or Color3.new(1,1,1)
                    end
                end
                break
            end
        end
    end
    if not hasMask then
        local maskBillboard = rootPart:FindFirstChild("MaskHook")
        if maskBillboard then maskBillboard:Destroy() end
    end

    -- Chase indicator is shown only when the survivor ESP is enabled.
    local chasedLabel2D = IndicatorGui:FindFirstChild(player.Name .. "_Chased")
    if not isKiller and isChased and Config.Survivor.States.Normal.Enabled then
        local billboard = rootPart:FindFirstChild("BitchHook")
        if billboard then
            local ct3 = billboard:FindFirstChild("ChasedLabel")
            if not ct3 then
                ct3 = Instance.new("TextLabel", billboard)
                ct3.Name = "ChasedLabel"
                ct3.Size, ct3.Position, ct3.BackgroundTransparency = UDim2.new(1,0,1,0), UDim2.new(0,0,-1.2,0), 1
                ct3.Font, ct3.TextSize = Enum.Font.GothamBold, 24
            end
            ct3.Text, ct3.TextColor3, ct3.TextStrokeTransparency = "!!", color, 0
        end

        if not chasedLabel2D then
            chasedLabel2D = Instance.new("TextLabel", IndicatorGui)
            chasedLabel2D.Name, chasedLabel2D.BackgroundTransparency = player.Name .. "_Chased", 1
            chasedLabel2D.Font, chasedLabel2D.TextSize, chasedLabel2D.TextStrokeTransparency = Enum.Font.GothamBold, 24, 0
            chasedLabel2D.AnchorPoint = Vector2.new(0.5, 0.5)
        end
        chasedLabel2D.Text, chasedLabel2D.TextColor3 = "!!", color

        local screenPos, onScreen = workspace.CurrentCamera:WorldToScreenPoint(rootPart.Position)
        if onScreen then
            chasedLabel2D.Visible = false
        else
            chasedLabel2D.Visible = true
            local viewportCenter = workspace.CurrentCamera.ViewportSize / 2
            local direction = Vector2.new(screenPos.X, screenPos.Y) - viewportCenter
            if screenPos.Z < 0 then direction = -direction end
            local maxScale = math.max(math.abs(direction.X) / math.max(viewportCenter.X - 30, 1), math.abs(direction.Y) / math.max(viewportCenter.Y - 30, 1))
            chasedLabel2D.Position = UDim2.new(0, viewportCenter.X + direction.X / (maxScale == 0 and 1 or maxScale), 0, viewportCenter.Y + direction.Y / (maxScale == 0 and 1 or maxScale))
        end
    else
        if chasedLabel2D then chasedLabel2D:Destroy() end
        local billboard = rootPart:FindFirstChild("BitchHook")
        if billboard then
            local ct3 = billboard:FindFirstChild("ChasedLabel")
            if ct3 then ct3:Destroy() end
        end
    end

    local killerLabel2D = IndicatorGui:FindFirstChild(player.Name .. "_Killer")
    if isKiller and Config.Killer.Warning then
        if not killerLabel2D then
            killerLabel2D = Instance.new("TextLabel", IndicatorGui)
            killerLabel2D.Name, killerLabel2D.BackgroundTransparency = player.Name .. "_Killer", 1
            killerLabel2D.Font, killerLabel2D.TextSize, killerLabel2D.TextStrokeTransparency = Enum.Font.GothamBold, 10, 0
            killerLabel2D.Size, killerLabel2D.RichText, killerLabel2D.AnchorPoint = UDim2.new(0, 120, 0, 30), true, Vector2.new(0.5, 0.5)
        end
        killerLabel2D.Text, killerLabel2D.TextColor3 = (tostring(selectedKillerAttr or player.Name) .. "\n[" .. distance .. " studs]"), color

        local screenPos, onScreen = workspace.CurrentCamera:WorldToScreenPoint(rootPart.Position)
        if not onScreen then
            killerLabel2D.Visible = true
            local viewportCenter = workspace.CurrentCamera.ViewportSize / 2
            local direction = Vector2.new(screenPos.X, screenPos.Y) - viewportCenter
            if screenPos.Z < 0 then direction = -direction end
            local maxScale = math.max(math.abs(direction.X) / math.max(viewportCenter.X - 30, 1), math.abs(direction.Y) / math.max(viewportCenter.Y - 30, 1))
            killerLabel2D.Position = UDim2.new(0, viewportCenter.X + direction.X / (maxScale == 0 and 1 or maxScale), 0, viewportCenter.Y + direction.Y / (maxScale == 0 and 1 or maxScale))
        else
            killerLabel2D.Visible = false
        end
    elseif killerLabel2D then
        killerLabel2D:Destroy()
    end
end

local function updateGeneratorProgress(generator)
    if not generator or not generator.Parent or not Config.ESPGeneral or not Config.Generator.Enabled then
        if generator then
            local b = generator:FindFirstChild("GenBitchHook")
            if b then b:Destroy() end
            local h = generator:FindFirstChild("H")
            if h then h:Destroy() end
        end
        return true
    end

    local percent = GetGameValue(generator, "RepairProgress") or GetGameValue(generator, "Progress") or 0
    if percent >= 100 then
        local billboard = generator:FindFirstChild("GenBitchHook")
        if billboard then billboard:Destroy() end
        local h = generator:FindFirstChild("H")
        if h then h:Destroy() end
        return true
    end

    ApplyHighlight(generator, Config.Generator.Color, Config.Generator.Fill, Config.Generator.Outline)

    local textParts = {}
    if Config.Generator.Percentage then
        table.insert(textParts, string.format("%.2f%%", percent))
    end
    if Config.Generator.Distance and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local target = generator:FindFirstChild("defaultMaterial", true) or generator
        local part = target:IsA("BasePart") and target or generator:FindFirstChildWhichIsA("BasePart", true)
        if part then
            local d = math.floor((part.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
            table.insert(textParts, "[" .. d .. " studs]")
        end
    end

    local billboard = generator:FindFirstChild("GenBitchHook")
    if #textParts == 0 then
        if billboard then billboard:Destroy() end
        return false
    end

    local percentStr = table.concat(textParts, "\n")
    if not billboard then
        billboard = CreateBillboardTag(percentStr, Config.Generator.Color)
        billboard.Name, billboard.StudsOffset = "GenBitchHook", Vector3.new(0, 2, 0)
        billboard.Adornee = generator:FindFirstChild("defaultMaterial", true) or generator
        billboard.Parent = generator
    else
        local lbl = billboard:FindFirstChild("BitchHook") or billboard:FindFirstChildOfClass("TextLabel")
        if lbl then
            lbl.Text = percentStr
            lbl.TextColor3 = Config.Generator.Color
        end
    end
    return false
end

local function updateNextKillerDisplay()
    if not IndicatorGui or not IndicatorGui.Parent then return end
    local label = IndicatorGui:FindFirstChild("NextKillerDisplay")
    local teamName = (LocalPlayer.Team and LocalPlayer.Team.Name:lower()) or ""
    if teamName:find("spectator") or teamName:find("lobby") then
        if not label then
            label = Instance.new("TextLabel", IndicatorGui)
            label.Name, label.Size, label.Position = "NextKillerDisplay", UDim2.new(0, 220, 0, 30), UDim2.new(0.5, 0, 0, 45)
            label.AnchorPoint, label.BackgroundTransparency, label.BackgroundColor3 = Vector2.new(0.5, 0), 0.5, Color3.new(0, 0, 0)
            label.TextColor3, label.Font, label.TextSize, label.RichText = Color3.new(1, 1, 1), Enum.Font.GothamBold, 14, true
            label.Text = "Next Killer: Calculating..."
        end
        local players = Players:GetPlayers()
        
        table.sort(players, function(a, b)
            local aA = GetGameValue(a, "AllowKiller") or false
            local bA = GetGameValue(b, "AllowKiller") or false
            if aA ~= bA then
                return aA == true
            end
            return (GetGameValue(a, "KillerChance") or 0) > (GetGameValue(b, "KillerChance") or 0)
        end)
        
        local nk = players[1]
        if nk then
            label.Text = "Next Killer: <font color=\"rgb(255,0,0)\">" .. (nk == LocalPlayer and "YOU" or tostring(GetGameValue(nk, "SelectedKiller") or nk.Name)) .. "</font>"
        end
    elseif label then label:Destroy() end
end

local function ClearAllESPVisuals()
    for _, obj in ipairs(TrackedESPObjects) do
        if obj and obj.Parent then
            local h = obj:FindFirstChild("H")
            if h then h:Destroy() end

            if obj.Name == "Hook" then
                local model = obj:FindFirstChild("Model")
                if model then
                    for _, part in ipairs(model:GetDescendants()) do
                        local ph = part:FindFirstChild("H")
                        if ph then ph:Destroy() end
                    end
                end
            end
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        DestroyPlayerESP(player)
    end

    ActiveGenerators = {}
end

local function RegisterESPObject(obj)
    if not obj or TrackedESPSet[obj] then return end

    local n = obj.Name
    if n ~= "Window" and n ~= "Generator" and n ~= "Hook"
        and n ~= "Pallet" and n ~= "Palletwrong" and n ~= "Gate" then
        return
    end

    TrackedESPSet[obj] = true
    table.insert(TrackedESPObjects, obj)
end

local function ScanESPObjects()
    TrackedESPObjects = {}
    TrackedESPSet = {}

    local map = workspace:FindFirstChild("Map")
    if map then
        for _, obj in ipairs(map:GetDescendants()) do
            RegisterESPObject(obj)
        end
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "Window" then
            RegisterESPObject(obj)
        end
    end
end

local function ApplyObjectESP(obj)
    if not obj or not obj.Parent or not Config.ESPGeneral then return end

    if obj.Name == "Window" then
        if Config.Objects.Windows.Enabled then
            ApplyHighlight(obj, Config.Objects.Windows.Color, true, true)
        end
    elseif obj.Name == "Generator" then
        if Config.Generator.Enabled then
            ApplyHighlight(obj, Config.Generator.Color, Config.Generator.Fill, Config.Generator.Outline)
            table.insert(ActiveGenerators, obj)
        end
    elseif obj.Name == "Hook" then
        if Config.Objects.Hooks.Enabled then
            local model = obj:FindFirstChild("Model")
            if model then
                for _, part in ipairs(model:GetDescendants()) do
                    if part:IsA("MeshPart") then
                        ApplyHighlight(part, Config.Objects.Hooks.Color, true, true)
                    end
                end
            end
        end
    elseif obj.Name == "Pallet" or obj.Name == "Palletwrong" then
        if Config.Objects.Pallets.Enabled then
            ApplyHighlight(obj, Config.Objects.Pallets.Color, true, true)
        end
    elseif obj.Name == "Gate" and Config.Objects.Gates.Enabled then
        ApplyHighlight(obj, Config.Objects.Gates.Color, true, true)
    end
end

local function RefreshESP()
    if not ESPInitialized then
        ScanESPObjects()
        ESPInitialized = true
    end

    ClearAllESPVisuals()
    if not Config.ESPGeneral then return end

    for _, obj in ipairs(TrackedESPObjects) do
        if obj and obj.Parent then
            ApplyObjectESP(obj)
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            updatePlayerNametag(player)
        end
    end
end

local function GetActionTarget()
    local current = PlayerGui
    for segment in string.gmatch(ActionPath, "[^%.]+") do current = current and current:FindFirstChild(segment) end
    return current
end

local function TriggerMobileButton()
    local b = GetActionTarget()
    if b and b:IsA("GuiObject") then
        local p, s, i = b.AbsolutePosition, b.AbsoluteSize, GuiService:GetGuiInset()
        local cx, cy = p.X + (s.X/2) + i.X, p.Y + (s.Y/2) + i.Y
        pcall(function() VirtualInputManager:SendTouchEvent(TouchID, 0, cx, cy) task.wait(0.01) VirtualInputManager:SendTouchEvent(TouchID, 2, cx, cy) end)
    end
end

local function GetActionButton()
    local b = GetActionTarget()
    if b and b:IsA("GuiObject") then return b end
    return nil
end

local function TriggerOriginalAction()
    local b = GetActionButton()
    if not b then return false end
    local p, s, i = b.AbsolutePosition, b.AbsoluteSize, GuiService:GetGuiInset()
    local cx, cy = p.X + s.X/2 + i.X, p.Y + s.Y/2 + i.Y
    local ok = pcall(function()
        VirtualInputManager:SendTouchEvent(TouchID, 0, cx, cy)
        task.wait(0.01)
        VirtualInputManager:SendTouchEvent(TouchID, 2, cx, cy)
    end)
    return ok
end

local SkillCheckConfig = {
    SUCCESS = {Min = 102, Max = 116},
    NEUTRAL = {Min = 116, Max = 159},
    INSTANT = {Center = 109}
}

local SkillCheckBusy = false
local LastSkillAction = 0
local SkillActionCooldown = 0.10

local function StopAutoSkillLoop()
    if AutoSkillHeartbeatConnection then
        AutoSkillHeartbeatConnection:Disconnect()
        AutoSkillHeartbeatConnection = nil
    end
    SkillCheckBusy = false
end

local function IsAngleInRange(angle, minAngle, maxAngle)
    angle = angle % 360
    return angle >= minAngle and angle <= maxAngle
end

local function GetSkillCheckParts(check)
    if not check or not check.Parent then return nil, nil end
    local line = check:FindFirstChild("Line")
    local goal = check:FindFirstChild("Goal")
    if not line or not goal then return nil, nil end
    return line, goal
end

local function TrySkillAction()
    local now = tick()
    if now - LastSkillAction < SkillActionCooldown then
        return false
    end

    local ok = TriggerOriginalAction()
    if ok then
        LastSkillAction = now
    end
    return ok
end

local function StartAutoSkillForCheck(check)
    if not AutoSkillEnabled or not check or not check.Visible then return end

    local line, goal = GetSkillCheckParts(check)
    if not line or not goal then return end

    StopAutoSkillLoop()
    SkillCheckBusy = true

    -- INSTANT: coloca la línea en el centro de SUCCESS y pulsa inmediatamente.
    if AutoSkillMode == "INSTANT" then
        task.defer(function()
            if not SkillCheckBusy
                or not AutoSkillEnabled
                or AutoSkillMode ~= "INSTANT"
                or not check.Parent
                or not check.Visible then
                return
            end

            local currentLine, currentGoal = GetSkillCheckParts(check)
            if not currentLine or not currentGoal then
                StopAutoSkillLoop()
                return
            end

            pcall(function()
                currentLine.Rotation = ((currentGoal.Rotation or 0) + SkillCheckConfig.INSTANT.Center) % 360
            end)

            TrySkillAction()

            task.delay(0.08, function()
                if AutoSkillMode == "INSTANT" then
                    StopAutoSkillLoop()
                end
            end)
        end)
        return
    end

    -- SUCCESS / NEUTRAL: vigila la rotación hasta entrar en la zona elegida.
    AutoSkillHeartbeatConnection = RunService.Heartbeat:Connect(function()
        if not SkillCheckBusy
            or not AutoSkillEnabled
            or not check.Parent
            or not check.Visible then
            StopAutoSkillLoop()
            return
        end

        local currentLine, currentGoal = GetSkillCheckParts(check)
        if not currentLine or not currentGoal then
            StopAutoSkillLoop()
            return
        end

        local relative = (currentLine.Rotation - currentGoal.Rotation) % 360
        local range = SkillCheckConfig[AutoSkillMode] or SkillCheckConfig.SUCCESS

        if IsAngleInRange(relative, range.Min, range.Max) then
            if TrySkillAction() then
                StopAutoSkillLoop()
            end
        end
    end)
end

local function CreateAutoSkillMenu()
    if MenuGui and MenuGui.Parent then return end

    MenuGui = Instance.new("ScreenGui")
    MenuGui.Name = "PerfectSkillTestMenu"
    MenuGui.ResetOnSpawn = false
    MenuGui.IgnoreGuiInset = true
    MenuGui.DisplayOrder = 1000
    MenuGui.Parent = PlayerGui

    local UI = {}
    local main
    local activePage = "ESP"
    local currentSubmenu = nil

    local function corner(obj, radius)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius or 8)
        c.Parent = obj
    end

    local function stroke(obj, transparency)
        local s = Instance.new("UIStroke")
        s.Color = Color3.fromRGB(0, 145, 255)
        s.Transparency = transparency or 0.35
        s.Thickness = 1
        s.Parent = obj
    end

    local function button(parent, text, size, position)
        local b = Instance.new("TextButton")
        b.Size, b.Position = size, position
        b.BackgroundColor3 = Color3.fromRGB(8, 31, 55)
        b.BackgroundTransparency = 0.08
        b.Text = text
        b.TextColor3 = Color3.new(1,1,1)
        b.Font = Enum.Font.Gotham
        b.TextSize = 12
        b.AutoButtonColor = true
        b.Parent = parent
        corner(b, 7)
        return b
    end

    local function label(parent, text, size, position, textSize)
        local l = Instance.new("TextLabel")
        l.Size, l.Position = size, position
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = Color3.new(1,1,1)
        l.Font = Enum.Font.Gotham
        l.TextSize = textSize or 12
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = parent
        return l
    end

    local function setToggleVisual(b, enabled)
        b.Text = enabled and "ON" or "OFF"
        b.BackgroundColor3 = enabled and Color3.fromRGB(15, 135, 235) or Color3.fromRGB(20, 45, 68)
    end

    local function addToggle(parent, text, getter, setter, y)
        local row = button(parent, text, UDim2.new(1, -12, 0, 34), UDim2.new(0, 6, 0, y))
        local t = button(row, "", UDim2.new(0, 48, 0, 25), UDim2.new(1, -55, 0.5, -12))
        t.TextSize = 10
        setToggleVisual(t, getter())
        row.TextXAlignment = Enum.TextXAlignment.Left
        row.Text = "   " .. text
        row.MouseButton1Click:Connect(function()
            setter(not getter())
            setToggleVisual(t, getter())
            RefreshESP()
        end)
        t.MouseButton1Click:Connect(function()
            setter(not getter())
            setToggleVisual(t, getter())
            RefreshESP()
        end)
        return row
    end

    local function makePalette(parent, palette, selectedGetter, selectedSetter, yStart)
        local holder = Instance.new("ScrollingFrame")
        holder.Size = UDim2.new(1, -12, 1, -(yStart + 8))
        holder.Position = UDim2.new(0, 6, 0, yStart)
        holder.BackgroundTransparency = 1
        holder.BorderSizePixel = 0
        holder.ScrollBarThickness = 3
        holder.CanvasSize = UDim2.new(0,0,0,0)
        holder.Parent = parent

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 5)
        layout.Parent = holder

        for _, item in ipairs(palette) do
            local b = button(holder, "●  " .. item[1], UDim2.new(1, -4, 0, 30), UDim2.new())
            b.TextColor3 = item[2]
            b.MouseButton1Click:Connect(function()
                selectedSetter(item[2])
                currentSubmenu.Visible = false
                RefreshESP()
            end)
        end
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            holder.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 8)
        end)
        holder.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 8)
        return holder
    end

    local function clearSubmenu()
        if currentSubmenu then
            currentSubmenu:Destroy()
            currentSubmenu = nil
        end
    end

    local function showSubmenu(titleText, builder)
        clearSubmenu()
        local sub = Instance.new("Frame")
        sub.Size = UDim2.new(0, 245, 0, 350)
        sub.Position = UDim2.new(0, 335, 0.5, -175)
        sub.BackgroundColor3 = Color3.fromRGB(3, 22, 42)
        sub.BackgroundTransparency = 0.08
        sub.Parent = MenuGui
        corner(sub, 10)
        stroke(sub, 0.15)
        currentSubmenu = sub

        label(sub, titleText, UDim2.new(1, -45, 0, 36), UDim2.new(0, 12, 0, 2), 15)
        local x = button(sub, "×", UDim2.new(0, 32, 0, 30), UDim2.new(1, -38, 0, 4))
        x.TextSize = 20
        x.MouseButton1Click:Connect(clearSubmenu)

        builder(sub)
        return sub
    end

    local function showKiller()
        showSubmenu("ESP KILLER", function(sub)
            local y = 42
            local colorBtn = button(sub, "●  Color del killer", UDim2.new(1,-12,0,34), UDim2.new(0,6,0,y))
            colorBtn.TextColor3 = Config.Killer.Color
            colorBtn.MouseButton1Click:Connect(function()
                showSubmenu("Colores del killer", function(p)
                    makePalette(p, Palettes.Killer, function() return Config.Killer.Color end,
                        function(c) Config.Killer.Color = c end, 42)
                end)
            end)
            y += 39
            addToggle(sub, "Killer contorno", function() return Config.Killer.Outline end, function(v) Config.Killer.Outline=v end, y); y += 39
            addToggle(sub, "Killer relleno", function() return Config.Killer.Fill end, function(v) Config.Killer.Fill=v end, y); y += 39
            addToggle(sub, "Mostrar nombre de killer", function() return Config.Killer.Name end, function(v) Config.Killer.Name=v end, y); y += 39
            addToggle(sub, "Mostrar distancia del killer", function() return Config.Killer.Distance end, function(v) Config.Killer.Distance=v end, y); y += 39
            addToggle(sub, "Advertencia de killer", function() return Config.Killer.Warning end, function(v) Config.Killer.Warning=v end, y)
        end)
    end

    local function showSurvivor()
        showSubmenu("ESP SURVI", function(sub)
            local y = 42
            local states = button(sub, "Estado de los supervivientes  ›", UDim2.new(1,-12,0,34), UDim2.new(0,6,0,y))
            states.MouseButton1Click:Connect(function()
                showSubmenu("Colores de estado", function(p)
                    local yy = 42
                    local entries = {
                        {"Normal", "Normal"},
                        {"Recibe daño", "Injured"},
                        {"Derribado", "Knocked"},
                        {"Enganchado", "Hooked"}
                    }
                    for _, e in ipairs(entries) do
                        local b = button(p, "●  " .. e[1] .. "  ›", UDim2.new(1,-12,0,34), UDim2.new(0,6,0,yy))
                        b.TextColor3 = Config.Survivor.States[e[2]].Color
                        b.MouseButton1Click:Connect(function()
                            showSubmenu("Color: " .. e[1], function(pp)
                                makePalette(pp, Palettes.Survivor, function() return Config.Survivor.States[e[2]].Color end,
                                    function(c) Config.Survivor.States[e[2]].Color=c end, 42)
                            end)
                        end)
                        yy += 39
                    end
                end)
            end)
            y += 39
            addToggle(sub, "Survi contorno", function() return Config.Survivor.Outline end, function(v) Config.Survivor.Outline=v end, y); y += 39
            addToggle(sub, "Survi relleno", function() return Config.Survivor.Fill end, function(v) Config.Survivor.Fill=v end, y); y += 39
            addToggle(sub, "Mostrar nombre de survi", function() return Config.Survivor.Name end, function(v) Config.Survivor.Name=v end, y); y += 39
            addToggle(sub, "Mostrar distancia de survi", function() return Config.Survivor.Distance end, function(v) Config.Survivor.Distance=v end, y)
        end)
    end

    local function showGenerator()
        showSubmenu("ESP GENERADOR", function(sub)
            local y = 42
            local colorBtn = button(sub, "●  Color ESP Gen", UDim2.new(1,-12,0,34), UDim2.new(0,6,0,y))
            colorBtn.TextColor3 = Config.Generator.Color
            colorBtn.MouseButton1Click:Connect(function()
                showSubmenu("Colores generador", function(p)
                    makePalette(p, Palettes.Generator, function() return Config.Generator.Color end,
                        function(c) Config.Generator.Color=c end, 42)
                end)
            end)
            y += 39
            addToggle(sub, "Generador relleno", function() return Config.Generator.Fill end, function(v) Config.Generator.Fill=v end, y); y += 39
            addToggle(sub, "Generador contorno", function() return Config.Generator.Outline end, function(v) Config.Generator.Outline=v end, y); y += 39
            addToggle(sub, "Distancia", function() return Config.Generator.Distance end, function(v) Config.Generator.Distance=v end, y); y += 39
            addToggle(sub, "Porcentaje", function() return Config.Generator.Percentage end, function(v) Config.Generator.Percentage=v end, y)
        end)
    end

    local function showObjects()
        showSubmenu("ESP OBJETOS", function(sub)
            local y = 42
            local entries = {
                {"ESP Hooks", "Hooks"},
                {"ESP Pallets", "Pallets"},
                {"ESP Windows", "Windows"},
                {"ESP Gates", "Gates"}
            }
            for _, e in ipairs(entries) do
                local obj = Config.Objects[e[2]]
                local row = button(sub, "●  " .. e[1] .. "  ›", UDim2.new(1,-12,0,34), UDim2.new(0,6,0,y))
                row.TextColor3 = obj.Color
                row.MouseButton1Click:Connect(function()
                    showSubmenu(e[1], function(p)
                        addToggle(p, "Activar", function() return obj.Enabled end, function(v) obj.Enabled=v end, 42)
                        local colorBtn = button(p, "●  Cambiar color", UDim2.new(1,-12,0,34), UDim2.new(0,6,0,81))
                        colorBtn.TextColor3 = obj.Color
                        colorBtn.MouseButton1Click:Connect(function()
                            showSubmenu("Colores neon", function(pp)
                                makePalette(pp, Palettes.Neon, function() return obj.Color end,
                                    function(c) obj.Color=c end, 42)
                            end)
                        end)
                    end)
                end)
                y += 39
            end
        end)
    end

    local function addSubmenuFeature(parent, text, getter, setter, openFn, y, icon)
        local row = button(parent, (icon or "•") .. "  " .. text .. "  ›", UDim2.new(1,-12,0,38), UDim2.new(0,6,0,y))
        local t = button(row, "", UDim2.new(0,48,0,25), UDim2.new(1,-55,0.5,-12))
        setToggleVisual(t, getter())
        row.MouseButton1Click:Connect(function()
            setter(not getter())
            setToggleVisual(t, getter())
            RefreshESP()
        end)
        t.MouseButton1Click:Connect(function()
            setter(not getter())
            setToggleVisual(t, getter())
            RefreshESP()
        end)
        local arrow = button(row, "›", UDim2.new(0,24,0,25), UDim2.new(1,-82,0.5,-12))
        arrow.BackgroundTransparency = 1
        arrow.MouseButton1Click:Connect(openFn)
        return row
    end

    local function buildESPPage(content)
        addToggle(content, "ESP General", function() return Config.ESPGeneral end, function(v)
            Config.ESPGeneral = v
            if v then
                RefreshESP()
            else
                ClearAllESPVisuals()
            end
        end, 6)

        local b1 = button(content, "🔴  ESP Killer  ›", UDim2.new(1,-12,0,38), UDim2.new(0,6,0,48))
        b1.MouseButton1Click:Connect(showKiller)

        local b2 = button(content, "🔵  ESP Survi  ›", UDim2.new(1,-12,0,38), UDim2.new(0,6,0,91))
        b2.MouseButton1Click:Connect(showSurvivor)

        addSubmenuFeature(content, "ESP Generador", function() return Config.Generator.Enabled end,
            function(v) Config.Generator.Enabled=v end, showGenerator, 134, "🟠")

        addSubmenuFeature(content, "ESP Objetos", function()
            return Config.Objects.Hooks.Enabled or Config.Objects.Pallets.Enabled or Config.Objects.Windows.Enabled or Config.Objects.Gates.Enabled
        end, function(v)
            Config.Objects.Hooks.Enabled=v
            Config.Objects.Pallets.Enabled=v
            Config.Objects.Windows.Enabled=v
            Config.Objects.Gates.Enabled=v
        end, showObjects, 177, "⬡")
    end

    local function buildSkillPage(content)
        local status = label(content, "Estado: " .. (AutoSkillEnabled and "ACTIVO" or "APAGADO"),
            UDim2.new(1,-12,0,28), UDim2.new(0,6,0,0), 13)
        status.TextColor3 = AutoSkillEnabled and Color3.fromRGB(90,255,140) or Color3.fromRGB(255,110,110)

        addToggle(content, "Perfect Gen", function() return AutoSkillEnabled end, function(v)
            AutoSkillEnabled = v
            if not v then
                StopAutoSkillLoop()
            else
                local prompt = PlayerGui:FindFirstChild("SkillCheckPromptGui")
                local check = prompt and prompt:FindFirstChild("Check")
                if check and check.Visible then
                    StartAutoSkillForCheck(check)
                end
            end
            status.Text = "Estado: " .. (AutoSkillEnabled and "ACTIVO" or "APAGADO")
            status.TextColor3 = AutoSkillEnabled and Color3.fromRGB(90,255,140) or Color3.fromRGB(255,110,110)
        end, 30)

        local mode = button(content, "MODE: " .. AutoSkillMode .. "  ▾",
            UDim2.new(1,-12,0,38), UDim2.new(0,6,0,77))
        mode.MouseButton1Click:Connect(function()
            showSubmenu("Perfect Gen • MODE", function(sub)
                local modes = {"SUCCESS", "NEUTRAL", "INSTANT"}
                for i, m in ipairs(modes) do
                    local b = button(sub,
                        (m == AutoSkillMode and "◉  " or "○  ") .. m,
                        UDim2.new(1,-12,0,40),
                        UDim2.new(0,6,0,42 + (i-1)*46))
                    b.MouseButton1Click:Connect(function()
                        AutoSkillMode = m
                        StopAutoSkillLoop()
                        clearSubmenu()

                        if AutoSkillEnabled then
                            local prompt = PlayerGui:FindFirstChild("SkillCheckPromptGui")
                            local check = prompt and prompt:FindFirstChild("Check")
                            if check and check.Visible then
                                StartAutoSkillForCheck(check)
                            end
                        end
                    end)
                end
            end)
        end)

        local info = label(content,
            "SUCCESS = zona perfecta\nNEUTRAL = zona normal\nINSTANT = acción inmediata",
            UDim2.new(1,-20,0,68), UDim2.new(0,10,0,128), 11)
        info.TextWrapped = true
        info.TextYAlignment = Enum.TextYAlignment.Top
        info.TextColor3 = Color3.fromRGB(185,205,225)
    end

    main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 315, 0, 405)
    main.Position = UDim2.new(0, 18, 0.5, -202)
    main.BackgroundColor3 = Color3.fromRGB(3, 22, 42)
    main.BackgroundTransparency = 0.12
    main.Active = true
    main.Parent = MenuGui
    corner(main, 11)
    stroke(main, 0.1)

    local top = Instance.new("Frame")
    top.Size = UDim2.new(1,0,0,40)
    top.BackgroundTransparency = 1
    top.Parent = main

    label(top, "◉  ESP + SKILL", UDim2.new(1,-90,1,0), UDim2.new(0,12,0,0), 16)

    local minimize = button(top, "−", UDim2.new(0,30,0,30), UDim2.new(1,-70,0,5))
    minimize.TextSize = 20
    local close = button(top, "×", UDim2.new(0,30,0,30), UDim2.new(1,-35,0,5))
    close.TextSize = 20

    local tabs = Instance.new("Frame")
    tabs.Size = UDim2.new(1,-16,0,38)
    tabs.Position = UDim2.new(0,8,0,43)
    tabs.BackgroundTransparency = 1
    tabs.Parent = main

    local espTab = button(tabs, "ESP", UDim2.new(0.5,-3,1,0), UDim2.new(0,0,0,0))
    local skillTab = button(tabs, "Skill Check", UDim2.new(0.5,-3,1,0), UDim2.new(0.5+0.01,0,0,0))

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1,-16,1,-132)
    content.Position = UDim2.new(0,8,0,87)
    content.BackgroundColor3 = Color3.fromRGB(4, 27, 48)
    content.BackgroundTransparency = 0.18
    content.Parent = main
    corner(content, 8)
    stroke(content, 0.45)

    local function rebuildPage(page)
        for _, c in ipairs(content:GetChildren()) do c:Destroy() end
        activePage = page
        if page == "ESP" then
            espTab.BackgroundColor3 = Color3.fromRGB(15, 110, 220)
            skillTab.BackgroundColor3 = Color3.fromRGB(8, 31, 55)
            buildESPPage(content)
        else
            espTab.BackgroundColor3 = Color3.fromRGB(8, 31, 55)
            skillTab.BackgroundColor3 = Color3.fromRGB(15, 110, 220)
            buildSkillPage(content)
        end
    end

    espTab.MouseButton1Click:Connect(function() rebuildPage("ESP") end)
    skillTab.MouseButton1Click:Connect(function() rebuildPage("SKILL") end)

    local transparency = Instance.new("TextLabel")
    transparency.Size = UDim2.new(1,-90,0,22)
    transparency.Position = UDim2.new(0,12,1,-31)
    transparency.BackgroundTransparency = 1
    transparency.Text = "Transparencia: 88%"
    transparency.TextColor3 = Color3.new(1,1,1)
    transparency.Font = Enum.Font.Gotham
    transparency.TextSize = 11
    transparency.TextXAlignment = Enum.TextXAlignment.Left
    transparency.Parent = main

    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(0, 150, 0, 5)
    slider.Position = UDim2.new(1,-162,1,-22)
    slider.BackgroundColor3 = Color3.fromRGB(25, 65, 95)
    slider.Text = ""
    slider.Parent = main
    corner(slider, 4)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,12,0,12)
    knob.Position = UDim2.new(0.88,-6,0.5,-6)
    knob.BackgroundColor3 = Color3.fromRGB(30, 155, 255)
    knob.Parent = slider
    corner(knob, 8)

    local function setTransparencyFromX(x)
        local rel = math.clamp((x - slider.AbsolutePosition.X) / math.max(slider.AbsoluteSize.X, 1), 0, 1)
        knob.Position = UDim2.new(rel,-6,0.5,-6)
        main.BackgroundTransparency = 0.05 + rel * 0.8
        transparency.Text = "Transparencia: " .. math.floor(rel * 100) .. "%"
    end

    slider.MouseButton1Click:Connect(function(x)
        setTransparencyFromX(x)
    end)

    minimize.MouseButton1Click:Connect(function()
        main.Visible = false
        if MinimizedButton then MinimizedButton.Visible = true end
    end)

    close.MouseButton1Click:Connect(function()
        local confirm = Instance.new("Frame")
        confirm.Size = UDim2.new(0,230,0,130)
        confirm.Position = UDim2.new(0,40,0.5,-65)
        confirm.BackgroundColor3 = Color3.fromRGB(3,22,42)
        confirm.Parent = MenuGui
        corner(confirm,10)
        stroke(confirm,0.1)
        label(confirm,"¿Eliminar menú?",UDim2.new(1,-20,0,30),UDim2.new(0,10,0,12),15)
        label(confirm,"Se cerrará la interfaz y sus ajustes.",UDim2.new(1,-20,0,35),UDim2.new(0,10,0,42),11)
        local cancel = button(confirm,"Cancelar",UDim2.new(0,95,0,32),UDim2.new(0,10,1,-42))
        local remove = button(confirm,"Eliminar",UDim2.new(0,95,0,32),UDim2.new(1,-105,1,-42))
        remove.BackgroundColor3 = Color3.fromRGB(190,45,60)
        cancel.MouseButton1Click:Connect(function() confirm:Destroy() end)
        remove.MouseButton1Click:Connect(function()
            clearSubmenu()
            if MinimizedButton then MinimizedButton:Destroy(); MinimizedButton=nil end
            MenuGui:Destroy()
            MenuGui=nil
        end)
    end)

    MinimizedButton = button(MenuGui, "◉", UDim2.new(0,52,0,52), UDim2.new(0,18,0.5,-26))
    MinimizedButton.Visible = false
    MinimizedButton.TextSize = 21
    MinimizedButton.Active = true
    MinimizedButton.Draggable = true
    corner(MinimizedButton, 26)
    stroke(MinimizedButton, 0.1)
    MinimizedButton.MouseButton1Click:Connect(function()
        main.Visible = true
        MinimizedButton.Visible = false
    end)

    main.Draggable = true
    rebuildPage("ESP")
end

local function InitializeAutobuy()
    task.spawn(function()
        local prompt = PlayerGui:WaitForChild("SkillCheckPromptGui", 10)
        local check = prompt and prompt:WaitForChild("Check", 10)
        if not check then return end

        if AutoSkillVisibilityConnection then
            AutoSkillVisibilityConnection:Disconnect()
            AutoSkillVisibilityConnection = nil
        end

        AutoSkillVisibilityConnection = check:GetPropertyChangedSignal("Visible"):Connect(function()
            if LocalPlayer.Team
                and LocalPlayer.Team.Name == "Survivors"
                and check.Visible
                and AutoSkillEnabled then
                StartAutoSkillForCheck(check)
            else
                StopAutoSkillLoop()
            end
        end)

        if LocalPlayer.Team
            and LocalPlayer.Team.Name == "Survivors"
            and check.Visible
            and AutoSkillEnabled then
            StartAutoSkillForCheck(check)
        end
    end)
end

workspace.ChildAdded:Connect(function(c)
    if c.Name == "Map" then
        task.wait(1)
        ScanESPObjects()
        ESPInitialized = true
        RefreshESP()
    end
end)

workspace.DescendantAdded:Connect(function(obj)
    if not ESPInitialized then return end
    local n = obj.Name
    if n == "Window" or n == "Generator" or n == "Hook"
        or n == "Pallet" or n == "Palletwrong" or n == "Gate" then
        RegisterESPObject(obj)
        if Config.ESPGeneral then
            task.defer(function()
                if obj.Parent then ApplyObjectESP(obj) end
            end)
        end
    end
end)

workspace.DescendantRemoving:Connect(function(obj)
    TrackedESPSet[obj] = nil
end)

LocalPlayer.CharacterAdded:Connect(function()
    SetupGui()
    task.wait(1)
    InitializeAutobuy()
    if Config.ESPGeneral then RefreshESP() end
end)

RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - LastUpdateTick < 0.05 then return end
    LastUpdateTick = now

    -- Lighting only once; these values do not need per-frame writes.
    if not ESPInitialized then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
    end

    -- No hacemos un escaneo/reconstrucción periódica: los objetos nuevos
    -- se registran mediante DescendantAdded, evitando picos de uso.
    if now - LastFullESPRefresh > 60 then
        LastFullESPRefresh = now
        if Config.ESPGeneral and not ESPInitialized then RefreshESP() end
    end

    if not Config.ESPGeneral then return end

    -- Next-killer calculation only once per second.
    if now - LastKillerDisplayUpdate > 1 then
        LastKillerDisplayUpdate = now
        updateNextKillerDisplay()
    end

    -- Player ESP at 5 Hz instead of 20 Hz.
    if now - LastPlayerESPUpdate > 0.20 then
        LastPlayerESPUpdate = now

        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local killerNearby = false

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                updatePlayerNametag(player)

                local team = player.Team and player.Team.Name:lower() or ""
                local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if team:find("killer") and myRoot and root then
                    if (root.Position - myRoot.Position).Magnitude < 99 then
                        killerNearby = true
                    end
                end
            end
        end

        if myRoot then
            local warn = myRoot:FindFirstChild("KillerWarn")
            if Config.Killer.Warning and killerNearby then
                if not warn then
                    warn = CreateBillboardTag("!", Color3.fromRGB(255, 0, 0), UDim2.new(0, 50, 0, 50), 40)
                    warn.Name = "KillerWarn"
                    warn.StudsOffset = Vector3.new(0, 4, 0)
                    warn.Adornee = myRoot
                    warn.Parent = myRoot
                end
            elseif warn then
                warn:Destroy()
            end
        end
    end

    -- Generator progress/distance at 5 Hz instead of every heartbeat.
    if now - LastGeneratorUpdate > 0.20 then
        LastGeneratorUpdate = now
        for i = #ActiveGenerators, 1, -1 do
            local generator = ActiveGenerators[i]
            if generator and generator.Parent then
                if updateGeneratorProgress(generator) then
                    table.remove(ActiveGenerators, i)
                end
            else
                table.remove(ActiveGenerators, i)
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    DestroyPlayerESP(p)
end)

SetupGui()
ScanESPObjects()
ESPInitialized = true
RefreshESP()
CreateAutoSkillMenu()
InitializeAutobuy()
