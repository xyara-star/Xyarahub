-- XYARA HUB V34 - ENHANCED UI (MODERN & BETTER DESIGN)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

if not LocalPlayer.Character then LocalPlayer.CharacterAdded:Wait() end

-- SETTINGS
getgenv().Xyara = {
    AimOn = false, HitOn = false, SpeedOn = false, EspOn = false,
    HitSize = 15, SpeedVal = 80, CurrentTarget = nil,
    Smoothness = 0, AimFOV = 80, Locked = false,
    AimPart = "HumanoidRootPart", Flying = false,
    FlySpeedMode = "Normal", TPSpawnPoint = nil,
    IsTeleporting = false, TeamCheck = true,
    WallCheck = false, MaxAimDistance = 500,
    InfJump = false, NoClip = false, GodMode = false,
    AirWalk = false, FullBright = false,
    EspBoxColor = Color3.fromRGB(150, 0, 255),
    EspTeamColor = Color3.fromRGB(0, 255, 0),
    EspTextSize = 14,
    EspMaxDistance = 1000
}

local SpeedValues = {Normal = 80, Fast = 200, Extreme = 800, Insane = 2000}
local ActiveConnections = {}
local ESPDrawings = {}
local lastHitState = false
local lastHitSize = getgenv().Xyara.HitSize
local lastTargetSwitch = tick()
local BV, BG = Instance.new("BodyVelocity"), Instance.new("BodyGyro")
BV.MaxForce, BG.MaxTorque = Vector3.new(0,0,0), Vector3.new(0,0,0)
BG.P = 12000
local AirWalkPart = nil

pcall(function() if game.CoreGui:FindFirstChild("XyaraHub") then game.CoreGui.XyaraHub:Destroy() end end)

-- ========== ENHANCED UI SYSTEM ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XyaraHub"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Color Scheme (Modern Dark Theme)
local Colors = {
    Primary = Color3.fromRGB(138, 43, 226),      -- Vibrant Purple
    Secondary = Color3.fromRGB(75, 0, 130),      -- Dark Purple
    Background = Color3.fromRGB(15, 15, 20),     -- Very Dark
    SurfaceLight = Color3.fromRGB(25, 25, 35),   -- Light Dark
    Text = Color3.fromRGB(255, 255, 255),        -- White
    Accent = Color3.fromRGB(0, 200, 255),        -- Cyan
    Success = Color3.fromRGB(0, 255, 100),       -- Green
    Danger = Color3.fromRGB(255, 50, 50)         -- Red
}

local function MakeDraggable(obj)
    local dragging, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
        end
    end)
    local conn = UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    local endConn = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    table.insert(ActiveConnections, conn)
    table.insert(ActiveConnections, endConn)
end

-- MAIN PANEL
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 700, 0, 600)
Main.Position = UDim2.new(0.5, -350, 0.5, -300)
Main.BackgroundColor3 = Colors.Background
Main.BackgroundTransparency = 0.05
Main.Visible = false
Main.Parent = ScreenGui
local mainCorner = Instance.new("UICorner", Main)
mainCorner.CornerRadius = UDim.new(0, 15)
local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Color = Colors.Primary
mainStroke.Thickness = 3
MakeDraggable(Main)

-- HEADER
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 80)
Header.BackgroundColor3 = Colors.Primary
Header.BackgroundTransparency = 0.1
Header.BorderSizePixel = 0
local headerCorner = Instance.new("UICorner", Header)
headerCorner.CornerRadius = UDim.new(0, 15)
local headerStroke = Instance.new("UIStroke", Header)
headerStroke.Color = Colors.Primary
headerStroke.Thickness = 2

-- Profile Section
local ProfileImg = Instance.new("ImageLabel", Header)
ProfileImg.Size = UDim2.new(0, 50, 0, 50)
ProfileImg.Position = UDim2.new(0, 15, 0.5, -25)
ProfileImg.Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150"
ProfileImg.BackgroundTransparency = 1
local profileCorner = Instance.new("UICorner", ProfileImg)
profileCorner.CornerRadius = UDim.new(1, 0)
local profileStroke = Instance.new("UIStroke", ProfileImg)
profileStroke.Color = Colors.Primary
profileStroke.Thickness = 2

-- Title & Info
local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(0, 300, 0, 30)
Title.Position = UDim2.new(0, 75, 0, 10)
Title.Text = "⚡ XYARA HUB V34"
Title.TextColor3 = Colors.Text
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24

local Subtitle = Instance.new("TextLabel", Header)
Subtitle.Size = UDim2.new(0, 300, 0, 20)
Subtitle.Position = UDim2.new(0, 75, 0, 40)
Subtitle.Text = "Modern UI | "..LocalPlayer.DisplayName
Subtitle.TextColor3 = Colors.Accent
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.BackgroundTransparency = 1
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 13

-- Close Button
local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -45, 0, 15)
CloseBtn.Text = "✕"
CloseBtn.BackgroundColor3 = Colors.Danger
CloseBtn.BackgroundTransparency = 0.7
CloseBtn.TextColor3 = Colors.Text
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
local closeCorner = Instance.new("UICorner", CloseBtn)
closeCorner.CornerRadius = UDim.new(0, 8)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)
CloseBtn.MouseEnter:Connect(function() CloseBtn.BackgroundTransparency = 0.5 end)
CloseBtn.MouseLeave:Connect(function() CloseBtn.BackgroundTransparency = 0.7 end)

-- TABS SIDEBAR
local TabsContainer = Instance.new("Frame", Main)
TabsContainer.Size = UDim2.new(0, 150, 1, -80)
TabsContainer.Position = UDim2.new(0, 0, 0, 80)
TabsContainer.BackgroundColor3 = Colors.SurfaceLight
TabsContainer.BorderSizePixel = 0
local tabsCorner = Instance.new("UICorner", TabsContainer)
tabsCorner.CornerRadius = UDim.new(0, 15)

local TabsList = Instance.new("UIListLayout", TabsContainer)
TabsList.Padding = UDim.new(0, 8)
TabsList.FillDirection = Enum.FillDirection.Vertical
local TabsPadding = Instance.new("UIPadding", TabsContainer)
TabsPadding.PaddingTop = UDim.new(0, 12)
TabsPadding.PaddingLeft = UDim.new(0, 10)
TabsPadding.PaddingRight = UDim.new(0, 10)

-- CONTENT AREA
local ContentArea = Instance.new("Frame", Main)
ContentArea.Size = UDim2.new(1, -170, 1, -80)
ContentArea.Position = UDim2.new(0, 160, 0, 80)
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0

-- Tabs Dictionary
local Tabs = {}
local tabNames = {"⚔ Combat", "🏃 Movement", "🌍 Teleport", "👁 Visual", "⚙ Extra"}
local tabIcons = {"⚔", "🏃", "🌍", "👁", "⚙"}

-- Create Tab Content Frames
for i, name in ipairs(tabNames) do
    local tab = Instance.new("ScrollingFrame", ContentArea)
    tab.Name = name
    tab.Size = UDim2.new(1, 0, 1, 0)
    tab.BackgroundTransparency = 1
    tab.Visible = false
    tab.ScrollBarThickness = 6
    tab.ScrollBarImageColor3 = Colors.Primary
    tab.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
    
    local tabLayout = Instance.new("UIListLayout", tab)
    tabLayout.Padding = UDim.new(0, 12)
    tabLayout.FillDirection = Enum.FillDirection.Vertical
    
    local tabPadding = Instance.new("UIPadding", tab)
    tabPadding.PaddingTop = UDim.new(0, 12)
    tabPadding.PaddingLeft = UDim.new(0, 12)
    tabPadding.PaddingRight = UDim.new(0, 12)
    
    Tabs[name] = tab
end

local function ShowTab(name)
    for tabName, tabFrame in pairs(Tabs) do
        tabFrame.Visible = (tabName == name)
    end
end

-- Create Tab Buttons
local function CreateTabButton(index, name)
    local btn = Instance.new("TextButton", TabsContainer)
    btn.Name = name
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.Text = tabIcons[index] .. "\n" .. name:gsub("^%S ", ""):sub(1, 10)
    btn.BackgroundColor3 = Colors.SurfaceLight
    btn.BackgroundTransparency = 1
    btn.TextColor3 = Colors.Text
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 10)
    
    btn.MouseButton1Click:Connect(function()
        ShowTab(name)
        -- Update button styling
        for _, child in pairs(TabsContainer:GetChildren()) do
            if child:IsA("TextButton") then
                local childStroke = child:FindFirstChildOfClass("UIStroke")
                if childStroke then childStroke:Destroy() end
                child.BackgroundTransparency = 1
                child.TextColor3 = Colors.Text
            end
        end
        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = Colors.Primary
        stroke.Thickness = 2
        btn.BackgroundTransparency = 0
        btn.BackgroundColor3 = Colors.Secondary
        btn.TextColor3 = Colors.Accent
    end)
    
    btn.MouseEnter:Connect(function()
        if not btn:FindFirstChildOfClass("UIStroke") then
            btn.BackgroundTransparency = 0.5
            btn.BackgroundColor3 = Colors.Secondary
        end
    end)
    
    btn.MouseLeave:Connect(function()
        if not btn:FindFirstChildOfClass("UIStroke") then
            btn.BackgroundTransparency = 1
        end
    end)
    
    return btn
end

for i, name in ipairs(tabNames) do
    CreateTabButton(i, name)
end

-- ========== UI COMPONENTS ==========

local function AddToggle(parent, name, var, description)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, 0, 0, 45)
    container.BackgroundColor3 = Colors.SurfaceLight
    container.BorderSizePixel = 0
    container.LayoutOrder = 1
    local containerCorner = Instance.new("UICorner", container)
    containerCorner.CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Text = name .. (description and " • " .. description or "")
    label.TextColor3 = Colors.Text
    label.TextSize = 12
    label.Font = Enum.Font.GothamSemibold
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggle = Instance.new("TextButton", container)
    toggle.Size = UDim2.new(0, 35, 0, 22)
    toggle.Position = UDim2.new(1, -47, 0.5, -11)
    toggle.BackgroundColor3 = getgenv().Xyara[var] and Colors.Success or Colors.SurfaceLight
    toggle.BorderSizePixel = 0
    toggle.Text = ""
    local toggleCorner = Instance.new("UICorner", toggle)
    toggleCorner.CornerRadius = UDim.new(1, 0)
    
    local toggleCircle = Instance.new("Frame", toggle)
    toggleCircle.Size = UDim2.new(0, 18, 0, 18)
    toggleCircle.Position = getgenv().Xyara[var] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    toggleCircle.BackgroundColor3 = Colors.Text
    toggleCircle.BorderSizePixel = 0
    local circleCorner = Instance.new("UICorner", toggleCircle)
    circleCorner.CornerRadius = UDim.new(1, 0)
    
    toggle.MouseButton1Click:Connect(function()
        getgenv().Xyara[var] = not getgenv().Xyara[var]
        local tween = TweenService:Create(toggleCircle, TweenInfo.new(0.2), {
            Position = getgenv().Xyara[var] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        })
        local bgTween = TweenService:Create(toggle, TweenInfo.new(0.2), {
            BackgroundColor3 = getgenv().Xyara[var] and Colors.Success or Colors.SurfaceLight
        })
        tween:Play()
        bgTween:Play()
    end)
end

local function AddSlider(parent, name, var, min, max)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, 0, 0, 70)
    container.BackgroundTransparency = 1
    container.LayoutOrder = 2
    
    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Text = name .. ": " .. tostring(math.floor(getgenv().Xyara[var]))
    label.TextColor3 = Colors.Text
    label.TextSize = 12
    label.Font = Enum.Font.GothamSemibold
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local track = Instance.new("Frame", container)
    track.Size = UDim2.new(1, 0, 0, 8)
    track.Position = UDim2.new(0, 0, 0, 28)
    track.BackgroundColor3 = Colors.SurfaceLight
    track.BorderSizePixel = 0
    local trackCorner = Instance.new("UICorner", track)
    trackCorner.CornerRadius = UDim.new(0, 4)
    
    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new((getgenv().Xyara[var] - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Colors.Primary
    fill.BorderSizePixel = 0
    local fillCorner = Instance.new("UICorner", fill)
    fillCorner.CornerRadius = UDim.new(0, 4)
    
    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new((getgenv().Xyara[var] - min) / (max - min), -9, 0.5, -9)
    knob.BackgroundColor3 = Colors.Accent
    knob.BorderSizePixel = 0
    local knobCorner = Instance.new("UICorner", knob)
    knobCorner.CornerRadius = UDim.new(1, 0)
    local knobStroke = Instance.new("UIStroke", knob)
    knobStroke.Color = Colors.Text
    knobStroke.Thickness = 1
    
    local button = Instance.new("TextButton", track)
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    
    local dragging = false
    
    local function update(input)
        local trackAbs = track.AbsolutePosition.X
        local trackSize = track.AbsoluteSize.X
        local mouseX = input.Position.X
        
        local scale = math.clamp((mouseX - trackAbs) / trackSize, 0, 1)
        local val = min + (scale * (max - min))
        
        if max - min > 100 then
            val = math.floor(val)
        else
            val = math.floor(val * 100) / 100
        end
        
        getgenv().Xyara[var] = val
        fill.Size = UDim2.new(scale, 0, 1, 0)
        knob.Position = UDim2.new(scale, -9, 0.5, -9)
        label.Text = name .. ": " .. tostring(math.floor(val))
    end
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    
    local moveConn = UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    
    local endConn = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    table.insert(ActiveConnections, moveConn)
    table.insert(ActiveConnections, endConn)
end

local function AddButton(parent, name, callback, style)
    style = style or "normal"
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Text = name
    btn.LayoutOrder = 3
    
    local bgColor = style == "danger" and Colors.Danger or style == "success" and Colors.Success or Colors.Primary
    btn.BackgroundColor3 = bgColor
    btn.BackgroundTransparency = 0.2
    btn.TextColor3 = Colors.Text
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 8)
    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Color = bgColor
    btnStroke.Thickness = 2
    
    btn.MouseButton1Click:Connect(callback)
    btn.MouseEnter:Connect(function() btn.BackgroundTransparency = 0.4 end)
    btn.MouseLeave:Connect(function() btn.BackgroundTransparency = 0.2 end)
    
    return btn
end

-- ========== POPULATE TABS ==========

-- COMBAT TAB
AddToggle(Tabs["⚔ Combat"], "🎯 AIM LOCK", "AimOn")
AddToggle(Tabs["⚔ Combat"], "📦 HITBOX EXPAND", "HitOn")
AddToggle(Tabs["⚔ Combat"], "👥 TEAM CHECK", "TeamCheck")
AddToggle(Tabs["⚔ Combat"], "👁 WALL CHECK", "WallCheck")
AddSlider(Tabs["⚔ Combat"], "FOV", "AimFOV", 10, 180)
AddSlider(Tabs["⚔ Combat"], "Max Distance", "MaxAimDistance", 50, 1000)

local lockBtn = AddButton(Tabs["⚔ Combat"], "🔒 LOCK TARGET", function()
    if getgenv().Xyara.CurrentTarget then
        getgenv().Xyara.Locked = not getgenv().Xyara.Locked
        lockBtn.Text = getgenv().Xyara.Locked and "🔓 UNLOCK" or "🔒 LOCK TARGET"
    end
end)

local aimPartBtn = AddButton(Tabs["⚔ Combat"], "🎯 AIM: BODY", function()
    if getgenv().Xyara.AimPart == "HumanoidRootPart" then
        getgenv().Xyara.AimPart = "Head"
        aimPartBtn.Text = "🎯 AIM: HEAD"
    else
        getgenv().Xyara.AimPart = "HumanoidRootPart"
        aimPartBtn.Text = "🎯 AIM: BODY"
    end
end)

-- MOVEMENT TAB
AddToggle(Tabs["🏃 Movement"], "✈ FLIGHT", "Flying")
local flyModeBtn = AddButton(Tabs["🏃 Movement"], "⚡ FLY SPEED: Normal", function()
    local modes = {"Normal", "Fast", "Extreme", "Insane"}
    local current = getgenv().Xyara.FlySpeedMode
    local nextIdx = 1
    for i, m in ipairs(modes) do if m == current then nextIdx = (i % #modes) + 1; break end end
    getgenv().Xyara.FlySpeedMode = modes[nextIdx]
    flyModeBtn.Text = "⚡ FLY SPEED: " .. modes[nextIdx]
end)

AddToggle(Tabs["🏃 Movement"], "💨 SPEED", "SpeedOn")
AddSlider(Tabs["🏃 Movement"], "Speed Value", "SpeedVal", 16, 500)
AddToggle(Tabs["🏃 Movement"], "♾ INFINITE JUMP", "InfJump")
AddToggle(Tabs["🏃 Movement"], "🚫 NO CLIP", "NoClip")
AddToggle(Tabs["🏃 Movement"], "🛡 GOD MODE", "GodMode")
AddToggle(Tabs["🏃 Movement"], "☁ AIR WALK", "AirWalk")

-- TELEPORT TAB
AddButton(Tabs["🌍 Teleport"], "📍 SET SPAWN", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        getgenv().Xyara.TPSpawnPoint = LocalPlayer.Character.HumanoidRootPart.CFrame
    end
end)

AddButton(Tabs["🌍 Teleport"], "🏠 TP SPAWN", function()
    if not getgenv().Xyara.TPSpawnPoint or not LocalPlayer.Character then return end
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then root.CFrame = getgenv().Xyara.TPSpawnPoint end
end)

AddButton(Tabs["🌍 Teleport"], "🎯 TP ENEMY", function()
    if not LocalPlayer.Character then return end
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local closest, minDist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 and (not getgenv().Xyara.TeamCheck or p.Team ~= LocalPlayer.Team) then
                local dist = (p.Character.HumanoidRootPart.Position - myRoot.Position).Magnitude
                if dist < minDist then minDist = dist; closest = p end
            end
        end
    end
    if closest then myRoot.CFrame = closest.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5) end
end)

-- VISUAL TAB
AddToggle(Tabs["👁 Visual"], "👁 ESP", "EspOn")
AddSlider(Tabs["👁 Visual"], "Hitbox Size", "HitSize", 2, 300)
AddToggle(Tabs["👁 Visual"], "☀ FULL BRIGHT", "FullBright")

-- EXTRA TAB
AddButton(Tabs["⚙ Extra"], "🔄 REJOIN", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end, "normal")

AddButton(Tabs["⚙ Extra"], "🌐 SERVER HOP", function()
    local HttpService = game:GetService("HttpService")
    local TS = game:GetService("TeleportService")
    local ok, res = pcall(function() return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")) end)
    if ok and res and res.data then
        for _, s in ipairs(res.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then TS:TeleportToPlaceInstance(game.PlaceId, s.id); break end
        end
    end
end, "success")

AddButton(Tabs["⚙ Extra"], "❌ DESTROY", function()
    ScreenGui:Destroy()
    for _, c in pairs(ActiveConnections) do pcall(function() c:Disconnect() end) end
    for _, esp in pairs(ESPDrawings) do pcall(function() esp:Destroy() end) end
    if AirWalkPart then AirWalkPart:Destroy() end
    BV:Destroy(); BG:Destroy()
    getgenv().Xyara = nil
end, "danger")

-- TOGGLE BUTTON (Floating Button)
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 60, 0, 60)
ToggleBtn.Position = UDim2.new(0, 20, 0.5, -30)
ToggleBtn.Text = "⚡"
ToggleBtn.BackgroundColor3 = Colors.Primary
ToggleBtn.BackgroundTransparency = 0.2
ToggleBtn.TextColor3 = Colors.Text
ToggleBtn.TextSize = 28
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.BorderSizePixel = 0
local toggleCorner = Instance.new("UICorner", ToggleBtn)
toggleCorner.CornerRadius = UDim.new(1, 0)
local toggleStroke = Instance.new("UIStroke", ToggleBtn)
toggleStroke.Color = Colors.Primary
toggleStroke.Thickness = 3
MakeDraggable(ToggleBtn)

ToggleBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)
ToggleBtn.MouseEnter:Connect(function() ToggleBtn.BackgroundTransparency = 0.3 end)
ToggleBtn.MouseLeave:Connect(function() ToggleBtn.BackgroundTransparency = 0.2 end)

-- Show first tab by default
ShowTab("⚔ Combat")
local firstTabBtn = TabsContainer:FindFirstChildOfClass("TextButton")
if firstTabBtn then
    local stroke = Instance.new("UIStroke", firstTabBtn)
    stroke.Color = Colors.Primary
    stroke.Thickness = 2
    firstTabBtn.BackgroundTransparency = 0
    firstTabBtn.BackgroundColor3 = Colors.Secondary
    firstTabBtn.TextColor3 = Colors.Accent
end

-- ========== CORE MECHANICS (SAME AS BEFORE) ==========

-- ANTI AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

local function IsEnemy(p)
    if not getgenv().Xyara.TeamCheck then return true end
    if not LocalPlayer.Team then return true end
    return p.Team ~= LocalPlayer.Team
end

local function IsVisible(part)
    if not getgenv().Xyara.WallCheck then return true end
    if not part then return false end
    local r = RaycastParams.new()
    r.FilterDescendantsInstances = {LocalPlayer.Character, part.Parent}
    r.FilterType = Enum.RaycastFilterType.Blacklist
    return workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000, r) == nil
end

-- ESP DRAWING
local function GetPlayerLevel(p)
    local level = "?"
    local leaderstats = p:FindFirstChild("leaderstats")
    if leaderstats then
        for _, v in pairs(leaderstats:GetChildren()) do
            if v:IsA("IntValue") and (v.Name:lower():find("level") or v.Name:lower():find("lvl")) then
                level = tostring(v.Value)
                break
            end
        end
    end
    return level
end

local function GetPVPStatus(p)
    local pvpValue = p:FindFirstChild("PVP")
    if pvpValue and pvpValue:IsA("BoolValue") then
        return pvpValue.Value
    end
    return false
end

local function CreateESPForPlayer(p)
    if p == LocalPlayer then return end
    
    local esp = {}
    
    esp.Tracer = Drawing.new("Line")
    esp.Tracer.Visible = false
    esp.Tracer.Thickness = 2
    
    esp.Box = Drawing.new("Square")
    esp.Box.Visible = false
    esp.Box.Thickness = 2
    esp.Box.Filled = false
    
    esp.Name = Drawing.new("Text")
    esp.Name.Visible = false
    esp.Name.Size = getgenv().Xyara.EspTextSize
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Font = 2
    
    esp.Info = Drawing.new("Text")
    esp.Info.Visible = false
    esp.Info.Size = getgenv().Xyara.EspTextSize - 2
    esp.Info.Center = true
    esp.Info.Outline = true
    esp.Info.Font = 2
    
    esp.HealthBar = Drawing.new("Square")
    esp.HealthBar.Visible = false
    esp.HealthBar.Filled = true
    esp.HealthBar.Thickness = 1
    
    ESPDrawings[p] = esp
end

local function UpdateESP()
    if not getgenv().Xyara.EspOn then
        for _, esp in pairs(ESPDrawings) do
            if esp.Tracer then esp.Tracer.Visible = false end
            if esp.Box then esp.Box.Visible = false end
            if esp.Name then esp.Name.Visible = false end
            if esp.Info then esp.Info.Visible = false end
            if esp.HealthBar then esp.HealthBar.Visible = false end
        end
        return
    end
    
    for p, esp in pairs(ESPDrawings) do
        if not p or not p.Character then
            if esp.Tracer then esp.Tracer.Visible = false end
            if esp.Box then esp.Box.Visible = false end
            if esp.Name then esp.Name.Visible = false end
            if esp.Info then esp.Info.Visible = false end
            if esp.HealthBar then esp.HealthBar.Visible = false end
            continue
        end
        
        local char = p.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        local hum = char:FindFirstChild("Humanoid")
        
        if not hrp or not head or not hum or hum.Health <= 0 or not IsEnemy(p) then
            if esp.Tracer then esp.Tracer.Visible = false end
            if esp.Box then esp.Box.Visible = false end
            if esp.Name then esp.Name.Visible = false end
            if esp.Info then esp.Info.Visible = false end
            if esp.HealthBar then esp.HealthBar.Visible = false end
            continue
        end
        
        local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
        if dist > getgenv().Xyara.EspMaxDistance then
            if esp.Tracer then esp.Tracer.Visible = false end
            if esp.Box then esp.Box.Visible = false end
            if esp.Name then esp.Name.Visible = false end
            if esp.Info then esp.Info.Visible = false end
            if esp.HealthBar then esp.HealthBar.Visible = false end
            continue
        end
        
        local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local footPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
        
        if not onScreen then
            if esp.Tracer then esp.Tracer.Visible = false end
            if esp.Box then esp.Box.Visible = false end
            if esp.Name then esp.Name.Visible = false end
            if esp.Info then esp.Info.Visible = false end
            if esp.HealthBar then esp.HealthBar.Visible = false end
            continue
        end
        
        local boxHeight = math.abs(headPos.Y - footPos.Y)
        local boxWidth = boxHeight * 0.6
        local boxPos = Vector2.new(hrpPos.X - boxWidth/2, footPos.Y - boxHeight)
        
        local pvp = GetPVPStatus(p)
        local color = pvp and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 150, 255)
        local pvpText = pvp and "[PVP]" or "[SAFE]"
        
        if esp.Box then
            esp.Box.Visible = true
            esp.Box.Color = color
            esp.Box.Position = boxPos
            esp.Box.Size = Vector2.new(boxWidth, boxHeight)
        end
        
        if esp.HealthBar then
            local hpPercent = hum.Health / hum.MaxHealth
            local barHeight = boxHeight * hpPercent
            esp.HealthBar.Visible = true
            esp.HealthBar.Size = Vector2.new(4, barHeight)
            esp.HealthBar.Position = Vector2.new(hrpPos.X - boxWidth/2 - 8, footPos.Y - barHeight)
            esp.HealthBar.Color = Color3.fromRGB(255 - (hpPercent * 255), hpPercent * 255, 0)
        end
        
        if esp.Name then
            esp.Name.Visible = true
            esp.Name.Color = Color3.new(1, 1, 1)
            esp.Name.Position = Vector2.new(hrpPos.X, footPos.Y - boxHeight - 20)
            esp.Name.Text = p.Name
        end
        
        if esp.Info then
            esp.Info.Visible = true
            esp.Info.Color = color
            esp.Info.Position = Vector2.new(hrpPos.X, footPos.Y - boxHeight - 5)
            esp.Info.Text = "[Lv." .. GetPlayerLevel(p) .. "] " .. math.floor(dist) .. "m " .. pvpText
        end
        
        if esp.Tracer then
            esp.Tracer.Visible = true
            esp.Tracer.Color = color
            esp.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            esp.Tracer.To = Vector2.new(hrpPos.X, footPos.Y)
        end
    end
end

local function RemoveESP(p)
    if ESPDrawings[p] then
        if ESPDrawings[p].Tracer then ESPDrawings[p].Tracer:Remove() end
        if ESPDrawings[p].Box then ESPDrawings[p].Box:Remove() end
        if ESPDrawings[p].Name then ESPDrawings[p].Name:Remove() end
        if ESPDrawings[p].Info then ESPDrawings[p].Info:Remove() end
        if ESPDrawings[p].HealthBar then ESPDrawings[p].HealthBar:Remove() end
        ESPDrawings[p] = nil
    end
end

for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        CreateESPForPlayer(p)
    end
end

Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then
        CreateESPForPlayer(p)
    end
end)

Players.PlayerRemoving:Connect(function(p)
    RemoveESP(p)
end)

table.insert(ActiveConnections, RunService.RenderStepped:Connect(UpdateESP))

-- HITBOX PERMANEN
table.insert(ActiveConnections, RunService.RenderStepped:Connect(function()
    if getgenv().Xyara.HitOn then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                pcall(function()
                    hrp.Size = Vector3.new(getgenv().Xyara.HitSize, getgenv().Xyara.HitSize, getgenv().Xyara.HitSize)
                    hrp.Transparency = 0.7
                end)
            end
        end
    else
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                pcall(function()
                    hrp.Size = Vector3.new(2, 2, 1)
                    hrp.Transparency = 1
                end)
            end
        end
    end
end))

LocalPlayer.CharacterAdded:Connect(function() 
    for p, _ in pairs(ESPDrawings) do RemoveESP(p) end
    getgenv().Xyara.CurrentTarget = nil
    getgenv().Xyara.Locked = false
    if getgenv().Xyara.AirWalk and not AirWalkPart then
        task.wait(1)
        AirWalkPart = Instance.new("Part")
        AirWalkPart.Size = Vector3.new(10, 1, 10)
        AirWalkPart.Anchored = true
        AirWalkPart.CanCollide = true
        AirWalkPart.Transparency = 1
        AirWalkPart.Parent = workspace
    end
end)

local function GetClosestTarget()
    local closest, dist = nil, getgenv().Xyara.MaxAimDistance
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(getgenv().Xyara.AimPart) then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 and IsEnemy(p) then
                local part = p.Character[getgenv().Xyara.AimPart]
                local d = (part.Position - Camera.CFrame.Position).Magnitude
                if d > getgenv().Xyara.MaxAimDistance then continue end
                local dot = (part.Position - Camera.CFrame.Position).Unit:Dot(Camera.CFrame.LookVector)
                local angle = math.deg(math.acos(math.clamp(dot, -1, 1)))
                if angle < getgenv().Xyara.AimFOV / 2 and d < dist and IsVisible(part) then dist = d; closest = p end
            end
        end
    end
    return closest
end

-- MAIN LOOP
table.insert(ActiveConnections, RunService.RenderStepped:Connect(function()
    -- SPEED
    if getgenv().Xyara.SpeedOn and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hum and hrp and hum.MoveDirection.Magnitude > 0 then hrp.CFrame = hrp.CFrame + (hum.MoveDirection * getgenv().Xyara.SpeedVal * 0.016) end
    end
    
    -- AIM LOCK
    if getgenv().Xyara.AimOn then
        if getgenv().Xyara.CurrentTarget and getgenv().Xyara.Locked then
            local t = getgenv().Xyara.CurrentTarget
            if t and t.Character and t.Character:FindFirstChild(getgenv().Xyara.AimPart) then
                local hum = t.Character:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 and IsEnemy(t) and IsVisible(t.Character[getgenv().Xyara.AimPart]) then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Character[getgenv().Xyara.AimPart].Position)
                else getgenv().Xyara.Locked = false; getgenv().Xyara.CurrentTarget = nil end
            else getgenv().Xyara.Locked = false; getgenv().Xyara.CurrentTarget = nil end
        else
            if tick() - lastTargetSwitch > 0.1 then
                local c = GetClosestTarget()
                if c then getgenv().Xyara.CurrentTarget = c; getgenv().Xyara.Locked = true; lastTargetSwitch = tick(); lockBtn.Text = "🔓 UNLOCK" end
            end
        end
    else if getgenv().Xyara.Locked or getgenv().Xyara.CurrentTarget then getgenv().Xyara.Locked = false; getgenv().Xyara.CurrentTarget = nil; lockBtn.Text = "🔒 LOCK TARGET" end end
    
    -- NO CLIP
    if getgenv().Xyara.NoClip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    
    -- GOD MODE
    if getgenv().Xyara.GodMode and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false; hum.Sit = false end
    end
    
    -- FULL BRIGHT
    if getgenv().Xyara.FullBright then
        Lighting.Brightness = 10
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
    end
    
    -- AIR WALK
    if getgenv().Xyara.AirWalk and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        if not AirWalkPart or not AirWalkPart.Parent then
            AirWalkPart = Instance.new("Part")
            AirWalkPart.Size = Vector3.new(10, 1, 10)
            AirWalkPart.Anchored = true
            AirWalkPart.CanCollide = true
            AirWalkPart.Transparency = 1
            AirWalkPart.Parent = workspace
        end
        local hrp = LocalPlayer.Character.HumanoidRootPart
        AirWalkPart.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 3.5, hrp.Position.Z)
    elseif AirWalkPart then AirWalkPart:Destroy(); AirWalkPart = nil end
end))

-- FLY SYSTEM
table.insert(ActiveConnections, RunService.RenderStepped:Connect(function()
    if getgenv().Xyara.Flying and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local HRP = LocalPlayer.Character.HumanoidRootPart
        local Hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        local Cam = workspace.CurrentCamera
        local MoveDir = Hum and Hum.MoveDirection or Vector3.new(0,0,0)
        local currentSpeed = SpeedValues[getgenv().Xyara.FlySpeedMode] or 80
        
        if not BV.Parent then
            BV.Parent = HRP
            BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            BG.Parent = HRP
            BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            if Hum then Hum.PlatformStand = true end
        end
        
        if MoveDir.Magnitude > 0 then
            BG.CFrame = Cam.CFrame * CFrame.Angles(math.rad(-80), 0, 0)
            BV.Velocity = Cam.CFrame.LookVector * (MoveDir.Magnitude * currentSpeed)
        else
            BG.CFrame = CFrame.new(HRP.Position, HRP.Position + Cam.CFrame.LookVector * Vector3.new(1, 0, 1))
            BV.Velocity = Vector3.new(0, 0.5, 0)
        end
    elseif BV.Parent then
        BV.Parent = nil
        BG.Parent = nil
        if LocalPlayer.Character then
            local Hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if Hum then Hum.PlatformStand = false end
        end
    end
end))

-- INFINITE JUMP
table.insert(ActiveConnections, UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Space and getgenv().Xyara.InfJump then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end))

-- HOTKEYS
table.insert(ActiveConnections, UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then getgenv().Xyara.AimOn = not getgenv().Xyara.AimOn
    elseif input.KeyCode == Enum.KeyCode.Q then getgenv().Xyara.SpeedOn = not getgenv().Xyara.SpeedOn
    elseif input.KeyCode == Enum.KeyCode.G then
        if getgenv().Xyara.CurrentTarget then getgenv().Xyara.Locked = not getgenv().Xyara.Locked else local c = GetClosestTarget(); if c then getgenv().Xyara.CurrentTarget = c; getgenv().Xyara.Locked = true end end
        lockBtn.Text = getgenv().Xyara.Locked and "🔓 UNLOCK" or "🔒 LOCK TARGET"
    elseif input.KeyCode == Enum.KeyCode.V then getgenv().Xyara.Flying = not getgenv().Xyara.Flying
    elseif input.KeyCode == Enum.KeyCode.Y then if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then getgenv().Xyara.TPSpawnPoint = LocalPlayer.Character.HumanoidRootPart.CFrame end
    elseif input.KeyCode == Enum.KeyCode.T then if not getgenv().Xyara.IsTeleporting and getgenv().Xyara.TPSpawnPoint and LocalPlayer.Character then local r = LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if r then r.CFrame = getgenv().Xyara.TPSpawnPoint end end
    elseif input.KeyCode == Enum.KeyCode.Insert then Main.Visible = not Main.Visible
    elseif input.KeyCode == Enum.KeyCode.N then getgenv().Xyara.NoClip = not getgenv().Xyara.NoClip
    elseif input.KeyCode == Enum.KeyCode.B then getgenv().Xyara.AirWalk = not getgenv().Xyara.AirWalk end
end))

ScreenGui.Destroying:Connect(function() 
    for _, c in pairs(ActiveConnections) do pcall(function() c:Disconnect() end) end
    for _, esp in pairs(ESPDrawings) do pcall(function() esp:Destroy() end) end
    if AirWalkPart then AirWalkPart:Destroy() end
    BV:Destroy(); BG:Destroy()
    getgenv().Xyara = nil 
end)

print("⚡ XYARA HUB V34 - ENHANCED UI LOADED")
print("✨ Press ⚡ button or INSERT to toggle UI")
print("🎮 Hotkeys: F(Aim) Q(Speed) G(Lock) V(Fly) N(NoClip) B(AirWalk)")
