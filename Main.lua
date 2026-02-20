local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

if not LocalPlayer.Character then LocalPlayer.CharacterAdded:Wait() end

getgenv().Xyara = {
    AimOn = false, HitOn = false, SpeedOn = false, EspOn = false,
    HitSize = 15, SpeedVal = 80, CurrentTarget = nil,
    Smoothness = 0, AimFOV = 80, Locked = false,
    AimPart = "HumanoidRootPart", Flying = false,
    FlySpeedMode = "Normal", TPSpawnPoint = nil,
    IsTeleporting = false, TeamCheck = true,
    WallCheck = false, MaxAimDistance = 500,
    -- FITUR BARU
    InfJump = false,
    NoClip = false,
    GodMode = false,
    AirWalk = false,
    FullBright = false
}

local SpeedValues = {Normal = 80, Fast = 200, Extreme = 800, Insane = 2000}
local ActiveConnections = {}
local ESPObjects = {}
local lastHitState = false
local lastTargetSwitch = tick()
local BV, BG = Instance.new("BodyVelocity"), Instance.new("BodyGyro")
BV.MaxForce, BG.MaxTorque = Vector3.new(0,0,0), Vector3.new(0,0,0)
BG.P = 12000
local AirWalkPart = nil

pcall(function() if game.CoreGui:FindFirstChild("XyaraHub") then game.CoreGui.XyaraHub:Destroy() end end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XyaraHub"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

local function MakeDraggable(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = obj.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    obj.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
    local conn = UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    table.insert(ActiveConnections, conn)
end

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 400, 0, 350)
Main.Position = UDim2.new(0.5, -200, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.BackgroundTransparency = 0.1
Main.Visible = false
Main.Parent = ScreenGui
Instance.new("UICorner").Parent = Main
local stroke = Instance.new("UIStroke", Main)
stroke.Color = Color3.fromRGB(150, 0, 255)
stroke.Thickness = 2
MakeDraggable(Main)

local ProfileFrame = Instance.new("Frame", Main)
ProfileFrame.Size = UDim2.new(1, 0, 0, 60)
ProfileFrame.BackgroundTransparency = 1

local PImg = Instance.new("ImageLabel", ProfileFrame)
PImg.Size = UDim2.new(0, 45, 0, 45)
PImg.Position = UDim2.new(0, 15, 0, 10)
PImg.Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150"
PImg.BackgroundTransparency = 1
Instance.new("UICorner", PImg).CornerRadius = UDim.new(1, 0)

local PName = Instance.new("TextLabel", ProfileFrame)
PName.Size = UDim2.new(0.6, 0, 0.5, 0)
PName.Position = UDim2.new(0, 70, 0, 12)
PName.Text = LocalPlayer.DisplayName
PName.TextColor3 = Color3.new(1, 1, 1)
PName.TextXAlignment = Enum.TextXAlignment.Left
PName.BackgroundTransparency = 1
PName.Font = Enum.Font.SourceSansBold
PName.TextSize = 16

local PStatus = Instance.new("TextLabel", ProfileFrame)
PStatus.Size = UDim2.new(0.6, 0, 0.5, 0)
PStatus.Position = UDim2.new(0, 70, 0, 28)
PStatus.TextXAlignment = Enum.TextXAlignment.Left
PStatus.BackgroundTransparency = 1
PStatus.Font = Enum.Font.SourceSans
PStatus.TextSize = 11
PStatus.Text = "XYARA HUB V33"
PStatus.TextColor3 = Color3.fromRGB(150, 0, 255)

local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 100, 1, -70)
Sidebar.Position = UDim2.new(0, 10, 0, 65)
Sidebar.BackgroundTransparency = 1
Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 5)

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -130, 1, -80)
Content.Position = UDim2.new(0, 120, 0, 70)
Content.BackgroundTransparency = 1

local Tabs = {}
local tabNames = {"Combat", "Movement", "Teleport", "Visual", "Extra"}
for _, name in ipairs(tabNames) do
    local tab = Instance.new("ScrollingFrame", Content)
    tab.Size = UDim2.new(1, 0, 1, 0)
    tab.BackgroundTransparency = 1
    tab.Visible = false
    tab.ScrollBarThickness = 2
    tab.ScrollBarImageColor3 = Color3.fromRGB(150, 0, 255)
    Instance.new("UIListLayout", tab).Padding = UDim.new(0, 8)
    Tabs[name] = tab
end

local function ShowTab(name) for n, t in pairs(Tabs) do t.Visible = (n == name) end end

-- FIXED SLIDER
local SliderRefs = {}
local function AddSlider(parent, name, var, min, max)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 50)
    frame.Position = UDim2.new(0, 5, 0, 0)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Text = name..": "..tostring(getgenv().Xyara[var])
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 12
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSansBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local track = Instance.new("Frame", frame)
    track.Name = "Track"
    track.Size = UDim2.new(1, 0, 0, 10)
    track.Position = UDim2.new(0, 0, 0, 28)
    track.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, 5)
    
    local fill = Instance.new("Frame", track)
    fill.Name = "Fill"
    fill.Size = UDim2.new((getgenv().Xyara[var] - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 5)
    
    local knob = Instance.new("Frame", track)
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new((getgenv().Xyara[var] - min) / (max - min), -8, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    local button = Instance.new("TextButton", track)
    button.Name = "ClickArea"
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
        knob.Position = UDim2.new(scale, -8, 0.5, -8)
        label.Text = name..": "..tostring(val)
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
    
    SliderRefs[var] = {Frame = frame, Label = label, Fill = fill, Knob = knob, Min = min, Max = max}
end

local function AddToggle(parent, name, var)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.Position = UDim2.new(0, 5, 0, 0)
    btn.Text = name
    btn.BackgroundColor3 = getgenv().Xyara[var] and Color3.fromRGB(150, 0, 255) or Color3.fromRGB(25, 25, 25)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 12
    btn.Font = Enum.Font.SourceSans
    Instance.new("UICorner").Parent = btn
    btn.MouseButton1Click:Connect(function()
        getgenv().Xyara[var] = not getgenv().Xyara[var]
        btn.BackgroundColor3 = getgenv().Xyara[var] and Color3.fromRGB(150, 0, 255) or Color3.fromRGB(25, 25, 25)
    end)
    return btn
end

local function AddButton(parent, name, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.Position = UDim2.new(0, 5, 0, 0)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 12
    btn.Font = Enum.Font.SourceSans
    Instance.new("UICorner").Parent = btn
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function CreateTabBtn(name)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSans
    Instance.new("UICorner").Parent = btn
    btn.MouseButton1Click:Connect(function() ShowTab(name) end)
end

for _, name in ipairs(tabNames) do CreateTabBtn(name) end

-- COMBAT TAB
AddToggle(Tabs.Combat, "AIM LOCK", "AimOn")
AddToggle(Tabs.Combat, "HITBOX EXPAND", "HitOn")
AddToggle(Tabs.Combat, "TEAM CHECK", "TeamCheck")
AddToggle(Tabs.Combat, "WALL CHECK", "WallCheck")
AddSlider(Tabs.Combat, "FOV", "AimFOV", 10, 180)
AddSlider(Tabs.Combat, "Max Dist", "MaxAimDistance", 50, 1000)

local lockBtn = AddButton(Tabs.Combat, "LOCK TARGET", function()
    if getgenv().Xyara.CurrentTarget then
        getgenv().Xyara.Locked = not getgenv().Xyara.Locked
        lockBtn.BackgroundColor3 = getgenv().Xyara.Locked and Color3.fromRGB(255, 0, 100) or Color3.fromRGB(25, 25, 25)
        lockBtn.Text = getgenv().Xyara.Locked and "UNLOCK" or "LOCK TARGET"
    end
end)

local aimPartBtn = AddButton(Tabs.Combat, "AIM: BODY", function()
    if getgenv().Xyara.AimPart == "HumanoidRootPart" then
        getgenv().Xyara.AimPart = "Head"
        aimPartBtn.Text = "AIM: HEAD"
    else
        getgenv().Xyara.AimPart = "HumanoidRootPart"
        aimPartBtn.Text = "AIM: BODY"
    end
end)

-- MOVEMENT TAB (BARU)
AddToggle(Tabs.Movement, "FLIGHT", "Flying")
local flyModeBtn = AddButton(Tabs.Movement, "FLY SPEED: Normal", function()
    local modes = {"Normal", "Fast", "Extreme", "Insane"}
    local current = getgenv().Xyara.FlySpeedMode
    local nextIdx = 1
    for i, m in ipairs(modes) do if m == current then nextIdx = (i % #modes) + 1; break end end
    getgenv().Xyara.FlySpeedMode = modes[nextIdx]
    flyModeBtn.Text = "FLY SPEED: "..modes[nextIdx]
end)

AddToggle(Tabs.Movement, "SPEED", "SpeedOn")
AddSlider(Tabs.Movement, "Speed Value", "SpeedVal", 16, 500)

-- FITUR BARU MOVEMENT
AddToggle(Tabs.Movement, "INFINITE JUMP", "InfJump")
AddToggle(Tabs.Movement, "NO CLIP", "NoClip")
AddToggle(Tabs.Movement, "GOD MODE", "GodMode")
AddToggle(Tabs.Movement, "AIR WALK", "AirWalk")

-- TELEPORT TAB
AddButton(Tabs.Teleport, "SET SPAWN", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        getgenv().Xyara.TPSpawnPoint = LocalPlayer.Character.HumanoidRootPart.CFrame
    end
end)

AddButton(Tabs.Teleport, "TP SPAWN", function()
    if not getgenv().Xyara.TPSpawnPoint or not LocalPlayer.Character then return end
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then root.CFrame = getgenv().Xyara.TPSpawnPoint end
end)

AddButton(Tabs.Teleport, "TP ENEMY", function()
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

-- VISUAL TAB (BARU)
AddToggle(Tabs.Visual, "ESP", "EspOn")
AddSlider(Tabs.Visual, "Hitbox Size", "HitSize", 2, 300)
AddToggle(Tabs.Visual, "FULL BRIGHT", "FullBright")

-- EXTRA TAB
AddButton(Tabs.Extra, "REJOIN", function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end)
AddButton(Tabs.Extra, "SERVER HOP", function()
    local HttpService = game:GetService("HttpService")
    local TS = game:GetService("TeleportService")
    local ok, res = pcall(function() return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")) end)
    if ok and res and res.data then
        for _, s in ipairs(res.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then TS:TeleportToPlaceInstance(game.PlaceId, s.id); break end
        end
    end
end)
AddButton(Tabs.Extra, "DESTROY", function()
    ScreenGui:Destroy()
    for _, c in pairs(ActiveConnections) do pcall(function() c:Disconnect() end) end
    for p, _ in pairs(ESPObjects) do pcall(function() if ESPObjects[p].Billboard then ESPObjects[p].Billboard:Destroy() end end) end
    if AirWalkPart then AirWalkPart:Destroy() end
    BV:Destroy(); BG:Destroy()
    getgenv().Xyara = nil
end)

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
ToggleBtn.Text = "π"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.TextSize = 30
ToggleBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local tst = Instance.new("UIStroke", ToggleBtn)
tst.Color = Color3.fromRGB(150, 0, 255)
tst.Thickness = 2
MakeDraggable(ToggleBtn)
ToggleBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

ShowTab("Combat")

-- ANTI AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

local function IsEnemy(p) if not getgenv().Xyara.TeamCheck then return true end; if not LocalPlayer.Team then return true end; return p.Team ~= LocalPlayer.Team end
local function IsVisible(part) if not getgenv().Xyara.WallCheck then return true end; if not part then return false end; local r = RaycastParams.new(); r.FilterDescendantsInstances = {LocalPlayer.Character, part.Parent}; r.FilterType = Enum.RaycastFilterType.Blacklist; return workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000, r) == nil end

local function RemoveESP(p)
    if ESPObjects[p] then
        pcall(function() ESPObjects[p].Billboard:Destroy() end)
        pcall(function() ESPObjects[p].Connection:Disconnect() end)
        ESPObjects[p] = nil
    end
end

local function ApplyESP(p)
    RemoveESP(p)
    if not getgenv().Xyara.EspOn or not p or not p.Character or not p.Character:FindFirstChild("Head") or not IsEnemy(p) then return end
    local bb = Instance.new("BillboardGui", p.Character.Head)
    bb.Name = "XyaraESP"; bb.Size = UDim2.new(0, 150, 0, 50); bb.StudsOffset = Vector3.new(0, 2.5, 0); bb.AlwaysOnTop = true
    local lbl = Instance.new("TextLabel", bb)
    lbl.Size = UDim2.new(1, 0, 1, 0); lbl.BackgroundTransparency = 1; lbl.TextColor3 = Color3.fromRGB(0, 255, 100); lbl.TextSize = 11; lbl.Font = Enum.Font.SourceSansBold; lbl.TextStrokeTransparency = 0.5
    ESPObjects[p] = {Billboard = bb}
    ESPObjects[p].Connection = RunService.Heartbeat:Connect(function()
        if not getgenv().Xyara.EspOn or not p or not p.Parent then bb.Enabled = false; return end
        if p.Character and p.Character:FindFirstChild("Humanoid") and p.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            bb.Enabled = true
            local d = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude)
            lbl.Text = p.DisplayName.."\nHP: "..math.floor(p.Character.Humanoid.Health).." | "..d.."m"
        else bb.Enabled = false end
    end)
end

Players.PlayerRemoving:Connect(function(p) RemoveESP(p) end)
LocalPlayer.CharacterAdded:Connect(function() 
    for p, _ in pairs(ESPObjects) do RemoveESP(p) end
    getgenv().Xyara.CurrentTarget = nil
    getgenv().Xyara.Locked = false
    -- RECREATE AIRWALK PART
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
    
        -- HITBOX
    if lastHitState ~= getgenv().Xyara.HitOn then
        lastHitState = getgenv().Xyara.HitOn
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                if getgenv().Xyara.HitOn then hrp.Size = Vector3.new(getgenv().Xyara.HitSize, getgenv().Xyara.HitSize, getgenv().Xyara.HitSize); hrp.Transparency = 0.7
                else hrp.Size = Vector3.new(2, 2, 1); hrp.Transparency = 1 end
            end
        end
    end
    
    -- ESP
    if getgenv().Xyara.EspOn then
        for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and (not ESPObjects[p] or not ESPObjects[p].Billboard or not ESPObjects[p].Billboard.Parent) then ApplyESP(p) end end
    else for p, _ in pairs(ESPObjects) do RemoveESP(p) end end
    
    -- AIM LOCK 100%
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
                if c then getgenv().Xyara.CurrentTarget = c; getgenv().Xyara.Locked = true; lastTargetSwitch = tick(); lockBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 100); lockBtn.Text = "UNLOCK" end
            end
        end
    else if getgenv().Xyara.Locked or getgenv().Xyara.CurrentTarget then getgenv().Xyara.Locked = false; getgenv().Xyara.CurrentTarget = nil; lockBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); lockBtn.Text = "LOCK TARGET" end end
    
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
        lockBtn.BackgroundColor3 = getgenv().Xyara.Locked and Color3.fromRGB(255, 0, 100) or Color3.fromRGB(25, 25, 25)
        lockBtn.Text = getgenv().Xyara.Locked and "UNLOCK" or "LOCK TARGET"
    elseif input.KeyCode == Enum.KeyCode.V then getgenv().Xyara.Flying = not getgenv().Xyara.Flying
    elseif input.KeyCode == Enum.KeyCode.Y then if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then getgenv().Xyara.TPSpawnPoint = LocalPlayer.Character.HumanoidRootPart.CFrame end
    elseif input.KeyCode == Enum.KeyCode.T then if not getgenv().Xyara.IsTeleporting and getgenv().Xyara.TPSpawnPoint and LocalPlayer.Character then local r = LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if r then r.CFrame = getgenv().Xyara.TPSpawnPoint end end
    elseif input.KeyCode == Enum.KeyCode.Insert then Main.Visible = not Main.Visible
    elseif input.KeyCode == Enum.KeyCode.N then getgenv().Xyara.NoClip = not getgenv().Xyara.NoClip
    elseif input.KeyCode == Enum.KeyCode.B then getgenv().Xyara.AirWalk = not getgenv().Xyara.AirWalk end
end))

ScreenGui.Destroying:Connect(function() 
    for _, c in pairs(ActiveConnections) do pcall(function() c:Disconnect() end) end
    for p, _ in pairs(ESPObjects) do RemoveESP(p) end
    if AirWalkPart then AirWalkPart:Destroy() end
    BV:Destroy(); BG:Destroy()
    getgenv().Xyara = nil 
end)
