-- [[ XYARA HUB: V30.2 - PI LOGO & STATUS SYSTEM ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ CONFIGURATION ]] --
local MY_USER_ID = LocalPlayer.UserId -- Otomatis deteksi ID kamu, atau ganti dengan ID spesifik
getgenv().Xyara = {
    AimOn = false, 
    HitOn = false, 
    SpeedOn = false, 
    EspOn = false,
    HitSize = 15, 
    SpeedVal = 80,
    CurrentTarget = nil,
    Smoothness = 0.2, -- Smoothness aim lock
    AimFOV = 80, -- Field of View untuk lock-on
    Locked = false, -- Status lock
    AimPart = "HumanoidRootPart" -- Bisa ganti: "Head", "UpperTorso"
}

-- [[ UI CLEANUP ]] --
if game.CoreGui:FindFirstChild("XyaraHub") then game.CoreGui.XyaraHub:Destroy() end
local ScreenGui = Instance.new("ScreenGui", game.CoreGui); ScreenGui.Name = "XyaraHub"

local function MakeDraggable(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = obj.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    obj.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- [[ MAIN UI ]] --
local Main = Instance.new("Frame", ScreenGui); Main.Size = UDim2.new(0, 400, 0, 320); Main.Position = UDim2.new(0.5, -200, 0.5, -160); Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10); Main.BackgroundTransparency = 0.1; Main.Visible = false; Instance.new("UICorner", Main)
local Stroke = Instance.new("UIStroke", Main); Stroke.Color = Color3.fromRGB(150, 0, 255); Stroke.Thickness = 2
MakeDraggable(Main)

-- [[ PROFILE SECTION ]] --
local ProfileFrame = Instance.new("Frame", Main); ProfileFrame.Size = UDim2.new(1, 0, 0, 60); ProfileFrame.BackgroundTransparency = 1
local PImg = Instance.new("ImageLabel", ProfileFrame); PImg.Size = UDim2.new(0, 45, 0, 45); PImg.Position = UDim2.new(0, 15, 0, 10); PImg.Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150"; Instance.new("UICorner", PImg).CornerRadius = UDim.new(1,0)
local PName = Instance.new("TextLabel", ProfileFrame); PName.Size = UDim2.new(0.6, 0, 0.5, 0); PName.Position = UDim2.new(0, 70, 0, 12); PName.Text = LocalPlayer.DisplayName; PName.TextColor3 = Color3.new(1,1,1); PName.TextXAlignment = "Left"; PName.BackgroundTransparency = 1; PName.Font = "SourceSansBold"; PName.TextSize = 16

-- Premium Detector
local PStatus = Instance.new("TextLabel", ProfileFrame); PStatus.Size = UDim2.new(0.6, 0, 0.5, 0); PStatus.Position = UDim2.new(0, 70, 0, 28); PStatus.TextXAlignment = "Left"; PStatus.BackgroundTransparency = 1; PStatus.Font = "SourceSans"; PStatus.TextSize = 11
if LocalPlayer.UserId == MY_USER_ID then
    PStatus.Text = "XYARA HUB PREMIUM USER"; PStatus.TextColor3 = Color3.fromRGB(150, 0, 255)
else
    PStatus.Text = "XYARA HUB FREE USER"; PStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
end

-- [[ TABS SYSTEM ]] --
local Sidebar = Instance.new("Frame", Main); Sidebar.Size = UDim2.new(0, 100, 1, -70); Sidebar.Position = UDim2.new(0, 10, 0, 65); Sidebar.BackgroundTransparency = 1
local Layout = Instance.new("UIListLayout", Sidebar); Layout.Padding = UDim.new(0, 5)

local Content = Instance.new("Frame", Main); Content.Size = UDim2.new(1, -130, 1, -80); Content.Position = UDim2.new(0, 120, 0, 70); Content.BackgroundTransparency = 1
local Tabs = {
    Combat = Instance.new("ScrollingFrame", Content), 
    Speed = Instance.new("ScrollingFrame", Content), 
    Setting = Instance.new("ScrollingFrame", Content)
}

for name, frame in pairs(Tabs) do
    frame.Size = UDim2.new(1, 0, 1, 0); frame.BackgroundTransparency = 1; frame.Visible = false; frame.ScrollBarThickness = 0
    Instance.new("UIListLayout", frame).Padding = UDim.new(0, 8)
end

local function ShowTab(name)
    for tName, frame in pairs(Tabs) do frame.Visible = (tName == name) end
end

-- [[ ESP LOGIC ]] --
local function GetPlayerLevel(p)
    local possibleNames = {"leaderstats", "Data", "Stats", "PlayerStats"}
    for _, name in pairs(possibleNames) do
        local folder = p:FindFirstChild(name)
        if folder then
            local lvl = folder:FindFirstChild("Level") or folder:FindFirstChild("Lvl") or folder:FindFirstChild("Rank")
            if lvl then return tostring(lvl.Value) end
        end
    end
    return "1"
end

local function ApplyESP(p)
    if not p.Character or not p.Character:FindFirstChild("Head") or p.Character.Head:FindFirstChild("XyaraTag") then return end
    local Billboard = Instance.new("BillboardGui", p.Character.Head); Billboard.Name = "XyaraTag"; Billboard.Size = UDim2.new(0, 150, 0, 60); Billboard.StudsOffset = Vector3.new(0, 3, 0); Billboard.AlwaysOnTop = true
    local Tag = Instance.new("TextLabel", Billboard); Tag.Size = UDim2.new(1, 0, 1, 0); Tag.BackgroundTransparency = 1; Tag.TextColor3 = Color3.fromRGB(0, 255, 100); Tag.TextSize = 12; Tag.Font = "SourceSansBold"; Tag.TextStrokeTransparency = 0.5
    
    local conn; conn = RunService.RenderStepped:Connect(function()
        if not p or not p.Parent or not getgenv().Xyara.EspOn then Billboard.Enabled = false; return end
        if p.Character and p.Character:FindFirstChild("Humanoid") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            Billboard.Enabled = true
            local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude)
            Tag.Text = string.format("%s [Lv.%s]\nHP: %d | Dist: %dm", p.DisplayName, GetPlayerLevel(p), p.Character.Humanoid.Health, dist)
        else Billboard.Enabled = false end
    end)
end

-- [[ AIM LOCK FIXED SYSTEM ]] --
local function GetClosestTarget()
    local closest, dist = nil, getgenv().Xyara.AimFOV
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") 
           and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            
            local targetPos = p.Character.HumanoidRootPart.Position
            local cameraPos = Camera.CFrame.Position
            local distance = (targetPos - cameraPos).Magnitude
            
            -- Cek apakah target dalam jangkauan
            local direction = (targetPos - cameraPos).Unit
            local lookVector = Camera.CFrame.LookVector
            local dot = direction:Dot(lookVector)
            local angle = math.deg(math.acos(dot))
            
            -- Target harus di depan kamera (angle kecil)
            if angle < getgenv().Xyara.AimFOV / 2 and distance < dist then
                dist = distance
                closest = p
            end
        end
    end
    
    return closest
end

local lastTargetSwitch = tick()

-- [[ MAIN LOOP ]] --
RunService.RenderStepped:Connect(function()
    -- Speed Hack
    if getgenv().Xyara.SpeedOn and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hum = LocalPlayer.Character.Humanoid
        if hum.MoveDirection.Magnitude > 0 then
            LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + (hum.MoveDirection * (getgenv().Xyara.SpeedVal / 60))
        end
    end

    -- Hitbox Expander & ESP
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            p.Character.HumanoidRootPart.Size = getgenv().Xyara.HitOn and Vector3.new(getgenv().Xyara.HitSize, getgenv().Xyara.HitSize, getgenv().Xyara.HitSize) or Vector3.new(2,2,1)
            p.Character.HumanoidRootPart.Transparency = getgenv().Xyara.HitOn and 0.8 or 1
            if getgenv().Xyara.EspOn then ApplyESP(p) end
        end
    end

    -- AIM LOCK FIXED VERSION
    if getgenv().Xyara.AimOn then
        -- Jika sudah ada target yang di-lock
        if getgenv().Xyara.CurrentTarget and getgenv().Xyara.Locked then
            local target = getgenv().Xyara.CurrentTarget
            
            -- Cek apakah target masih valid
            if target and target.Character and target.Character:FindFirstChild(getgenv().Xyara.AimPart) 
               and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0 then
                
                local aimPart = target.Character[getgenv().Xyara.AimPart]
                
                -- SUPER LOCK: Camera selalu nempel ke target
                local targetPosition = aimPart.Position
                
                -- Prediksi pergerakan jika target bergerak
                if aimPart:IsA("BasePart") and aimPart.Velocity.Magnitude > 5 then
                    targetPosition = targetPosition + (aimPart.Velocity * 0.1)
                end
                
                -- Tambah offset untuk view yang lebih bagus
                targetPosition = targetPosition + Vector3.new(0, 1.5, 0)
                
                -- Smooth camera movement
                local currentCFrame = Camera.CFrame
                local lookVector = (targetPosition - currentCFrame.Position).Unit
                local smoothFactor = getgenv().Xyara.Smoothness * 3
                local newLookVector = currentCFrame.LookVector:Lerp(lookVector, smoothFactor)
                
                Camera.CFrame = CFrame.lookAt(currentCFrame.Position, currentCFrame.Position + newLookVector)
                
            else
                -- Target mati/hilang, release lock
                getgenv().Xyara.Locked = false
                getgenv().Xyara.CurrentTarget = nil
            end
        else
            -- Cari target baru (cooldown 0.3 detik untuk ganti target)
            if tick() - lastTargetSwitch > 0.3 then
                local closest = GetClosestTarget()
                if closest then
                    getgenv().Xyara.CurrentTarget = closest
                    getgenv().Xyara.Locked = true
                    lastTargetSwitch = tick()
                end
            end
        end
    else
        -- Reset jika aim dimatikan
        getgenv().Xyara.Locked = false
        getgenv().Xyara.CurrentTarget = nil
    end
end)

-- [[ UI BUILDER ]] --
local function AddToggle(parent, name, var)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(1, 0, 0, 32); b.Text = name; b.BackgroundColor3 = Color3.fromRGB(25, 25, 25); b.TextColor3 = Color3.new(1,1,1); b.TextSize = 12; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        getgenv().Xyara[var] = not getgenv().Xyara[var]
        b.BackgroundColor3 = getgenv().Xyara[var] and Color3.fromRGB(150, 0, 255) or Color3.fromRGB(25, 25, 25)
    end)
end

local function AddSlider(parent, name, var, min, max)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(1,0,0,38); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1,0,0,15); l.Text = name..": "..getgenv().Xyara[var]; l.TextColor3 = Color3.new(1,1,1); l.TextSize = 11; l.BackgroundTransparency = 1
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(0.9,0,0,8); b.Position = UDim2.new(0.05,0,0.6,0); b.Text = ""; b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    local fill = Instance.new("Frame", b); fill.Size = UDim2.new((getgenv().Xyara[var]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
    
    b.MouseButton1Down:Connect(function()
        local move = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local pos = math.clamp((input.Position.X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(pos, 0, 1, 0); local val = math.floor(min + (pos * (max - min)))
                getgenv().Xyara[var] = val; l.Text = name..": "..val
            end
        end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then move:Disconnect() end end)
    end)
end

local function CreateTabBtn(name)
    local b = Instance.new("TextButton", Sidebar); b.Size = UDim2.new(1, 0, 0, 35); b.Text = name; b.BackgroundColor3 = Color3.fromRGB(20, 20, 20); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() ShowTab(name) end)
end

-- SETUP TABS
CreateTabBtn("Combat"); CreateTabBtn("Speed"); CreateTabBtn("Setting")

-- COMBAT TAB
AddToggle(Tabs.Combat, "AIM LOCK", "AimOn")
AddToggle(Tabs.Combat, "HITBOX EXPANDER", "HitOn")
AddSlider(Tabs.Combat, "Aim Smoothness", "Smoothness", 0.01, 1)
AddSlider(Tabs.Combat, "Aim FOV", "AimFOV", 10, 180)

-- Tombol untuk toggle lock target
local lockBtn = Instance.new("TextButton", Tabs.Combat)
lockBtn.Size = UDim2.new(1, 0, 0, 32)
lockBtn.Text = "LOCK CURRENT TARGET"
lockBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
lockBtn.TextColor3 = Color3.new(1,1,1)
lockBtn.TextSize = 12
Instance.new("UICorner", lockBtn)

lockBtn.MouseButton1Click:Connect(function()
    if getgenv().Xyara.CurrentTarget then
        getgenv().Xyara.Locked = not getgenv().Xyara.Locked
        lockBtn.BackgroundColor3 = getgenv().Xyara.Locked and Color3.fromRGB(255, 0, 100) or Color3.fromRGB(25, 25, 25)
        lockBtn.Text = getgenv().Xyara.Locked and "UNLOCK TARGET" or "LOCK CURRENT TARGET"
    end
end)

-- SPEED TAB
AddToggle(Tabs.Speed, "POWER SPEED", "SpeedOn")
AddSlider(Tabs.Speed, "Speed Value", "SpeedVal", 16, 350)

-- SETTING TAB
AddToggle(Tabs.Setting, "INFO ESP (GREEN)", "EspOn")
AddSlider(Tabs.Setting, "Hitbox Size", "HitSize", 2, 300)

-- Select Aim Part
local aimPartFrame = Instance.new("Frame", Tabs.Combat)
aimPartFrame.Size = UDim2.new(1, 0, 0, 32)
aimPartFrame.BackgroundTransparency = 1

local aimPartLabel = Instance.new("TextLabel", aimPartFrame)
aimPartLabel.Size = UDim2.new(0.5, 0, 1, 0)
aimPartLabel.Text = "Aim Part:"
aimPartLabel.TextColor3 = Color3.new(1,1,1)
aimPartLabel.BackgroundTransparency = 1
aimPartLabel.TextSize = 12

local aimPartDropdown = Instance.new("TextButton", aimPartFrame)
aimPartDropdown.Size = UDim2.new(0.5, 0, 1, 0)
aimPartDropdown.Position = UDim2.new(0.5, 0, 0, 0)
aimPartDropdown.Text = getgenv().Xyara.AimPart
aimPartDropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
aimPartDropdown.TextColor3 = Color3.new(1,1,1)
aimPartDropdown.TextSize = 12
Instance.new("UICorner", aimPartDropdown)

aimPartDropdown.MouseButton1Click:Connect(function()
    -- Toggle antara Head dan HumanoidRootPart
    if getgenv().Xyara.AimPart == "HumanoidRootPart" then
        getgenv().Xyara.AimPart = "Head"
    else
        getgenv().Xyara.AimPart = "HumanoidRootPart"
    end
    aimPartDropdown.Text = getgenv().Xyara.AimPart
end)

-- [[ PI LOGO TOGGLE ]] --
local HBtn = Instance.new("TextButton", ScreenGui); HBtn.Size = UDim2.new(0, 50, 0, 50); HBtn.Position = UDim2.new(0, 20, 0.5, -25); HBtn.Text = "π"; HBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10); HBtn.TextColor3 = Color3.new(1,1,1); HBtn.TextSize = 30; Instance.new("UICorner", HBtn).CornerRadius = UDim.new(1,0)
local HStroke = Instance.new("UIStroke", HBtn); HStroke.Color = Color3.fromRGB(150, 0, 255); HStroke.Thickness = 2
MakeDraggable(HBtn)
HBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

ShowTab("Combat")

-- [[ HOTKEYS ]] --
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- F untuk toggle Aim Lock
    if input.KeyCode == Enum.KeyCode.F then
        getgenv().Xyara.AimOn = not getgenv().Xyara.AimOn
    end
    
    -- Q untuk toggle Speed
    if input.KeyCode == Enum.KeyCode.Q then
        getgenv().Xyara.SpeedOn = not getgenv().Xyara.SpeedOn
    end
    
    -- G untuk force lock/unlock target
    if input.KeyCode == Enum.KeyCode.G then
        if getgenv().Xyara.CurrentTarget then
            getgenv().Xyara.Locked = not getgenv().Xyara.Locked
        else
            -- Cari target terdekat
            local closest = GetClosestTarget()
            if closest then
                getgenv().Xyara.CurrentTarget = closest
                getgenv().Xyara.Locked = true
            end
        end
    end
end)

print("XYARA HUB V30.2 LOADED! | F = Aim | Q = Speed | G = Lock Target")
