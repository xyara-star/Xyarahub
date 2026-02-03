-- [[ HANA HUB: V29.0 - PROFILE AT TOP ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

getgenv().Hana = {
    AimOn = false, HitOn = false, SpeedOn = false, EspOn = false,
    AntiStun = false, HitSize = 15, SpeedVal = 80,
    CurrentTarget = nil
}

-- [[ UI CLEANUP ]] --
if game.CoreGui:FindFirstChild("HanaV29") then game.CoreGui.HanaV29:Destroy() end
local ScreenGui = Instance.new("ScreenGui", game.CoreGui); ScreenGui.Name = "HanaV29"

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
local Main = Instance.new("Frame", ScreenGui); Main.Size = UDim2.new(0, 220, 0, 350); Main.Position = UDim2.new(0.5, -110, 0.5, -175); Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10); Main.BackgroundTransparency = 0.2; Main.Visible = false; Instance.new("UICorner", Main)
local Stroke = Instance.new("UIStroke", Main); Stroke.Color = Color3.fromRGB(150, 0, 255); Stroke.Thickness = 2
MakeDraggable(Main)

-- [[ PROFILE SECTION (AT TOP) ]] --
local ProfileFrame = Instance.new("Frame", Main); ProfileFrame.Size = UDim2.new(1, 0, 0, 60); ProfileFrame.BackgroundTransparency = 1
local PImg = Instance.new("ImageLabel", ProfileFrame); PImg.Size = UDim2.new(0, 40, 0, 40); PImg.Position = UDim2.new(0, 10, 0, 10); PImg.Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150"; Instance.new("UICorner", PImg).CornerRadius = UDim.new(1,0)
local PName = Instance.new("TextLabel", ProfileFrame); PName.Size = UDim2.new(0.6, 0, 0.5, 0); PName.Position = UDim2.new(0, 55, 0, 10); PName.Text = LocalPlayer.DisplayName; PName.TextColor3 = Color3.new(1,1,1); PName.TextXAlignment = "Left"; PName.BackgroundTransparency = 1; PName.Font = "SourceSansBold"; PName.TextSize = 14
local PStatus = Instance.new("TextLabel", ProfileFrame); PStatus.Size = UDim2.new(0.6, 0, 0.5, 0); PStatus.Position = UDim2.new(0, 55, 0, 25); PStatus.Text = "HANA HUB USER"; PStatus.TextColor3 = Color3.fromRGB(150, 0, 255); PStatus.TextXAlignment = "Left"; PStatus.BackgroundTransparency = 1; PStatus.Font = "SourceSans"; PStatus.TextSize = 10

local Line = Instance.new("Frame", Main); Line.Size = UDim2.new(0.9, 0, 0, 1); Line.Position = UDim2.new(0.05, 0, 0, 60); Line.BackgroundColor3 = Color3.fromRGB(150, 0, 255); Line.BackgroundTransparency = 0.5; Line.BorderSizePixel = 0

-- [[ SCROLLING CONTAINER ]] --
local Container = Instance.new("ScrollingFrame", Main); Container.Size = UDim2.new(0.9, 0, 0.72, 0); Container.Position = UDim2.new(0.05, 0, 0.2, 0); Container.BackgroundTransparency = 1; Container.ScrollBarThickness = 0
local Layout = Instance.new("UIListLayout", Container); Layout.Padding = UDim.new(0, 6); Layout.HorizontalAlignment = "Center"

-- [[ LOGO π ]] --
local HBtn = Instance.new("TextButton", ScreenGui); HBtn.Size = UDim2.new(0, 45, 0, 45); HBtn.Position = UDim2.new(0, 20, 0.5, -22); HBtn.Text = "π"; HBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0); HBtn.TextColor3 = Color3.new(1,1,1); HBtn.TextSize = 25; Instance.new("UICorner", HBtn).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", HBtn).Color = Color3.fromRGB(150, 0, 255)
MakeDraggable(HBtn)
HBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- [[ ENGINE ]] --
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
    if not p.Character or not p.Character:FindFirstChild("Head") or p.Character.Head:FindFirstChild("HanaTag") then return end
    local Billboard = Instance.new("BillboardGui", p.Character.Head); Billboard.Name = "HanaTag"; Billboard.Size = UDim2.new(0, 150, 0, 60); Billboard.StudsOffset = Vector3.new(0, 3, 0); Billboard.AlwaysOnTop = true
    local Tag = Instance.new("TextLabel", Billboard); Tag.Size = UDim2.new(1, 0, 1, 0); Tag.BackgroundTransparency = 1; Tag.TextColor3 = Color3.fromRGB(0, 255, 100); Tag.TextSize = 12; Tag.Font = "SourceSansBold"; Tag.TextStrokeTransparency = 0.5
    
    local conn; conn = RunService.RenderStepped:Connect(function()
        if not p or not p.Parent or not getgenv().Hana.EspOn then 
            Billboard.Enabled = false 
            if not p or not p.Parent then conn:Disconnect(); Billboard:Destroy() end
            return 
        end
        if p.Character and p.Character:FindFirstChild("Humanoid") then
            Billboard.Enabled = true
            local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude)
            Tag.Text = string.format("%s [Lv.%s]\nHP: %d | Dist: %dm", p.DisplayName, GetPlayerLevel(p), p.Character.Humanoid.Health, dist)
        else
            Billboard.Enabled = false
        end
    end)
end

-- [[ LOOPS ]] --
RunService.RenderStepped:Connect(function()
    -- Speed Bypass CFrame
    if getgenv().Hana.SpeedOn and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hum = LocalPlayer.Character.Humanoid
        local hrp = LocalPlayer.Character.HumanoidRootPart
        if hum.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (getgenv().Hana.SpeedVal / 55))
        end
    end

    -- Aimlock & Hitbox
    if getgenv().Hana.AimOn then
        if not getgenv().Hana.CurrentTarget then
            local closest, dist = nil, 1000
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local pos, onS = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                    if onS then
                        local m = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                        if m < dist then dist = m; closest = p end
                    end
                end
            end
            getgenv().Hana.CurrentTarget = closest
        end
        if getgenv().Hana.CurrentTarget and getgenv().Hana.CurrentTarget.Character then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, getgenv().Hana.CurrentTarget.Character.HumanoidRootPart.Position)
        end
    else getgenv().Hana.CurrentTarget = nil end

    -- Apply Global
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            p.Character.HumanoidRootPart.Size = getgenv().Hana.HitOn and Vector3.new(getgenv().Hana.HitSize, getgenv().Hana.HitSize, getgenv().Hana.HitSize) or Vector3.new(2,2,1)
            p.Character.HumanoidRootPart.Transparency = getgenv().Hana.HitOn and 0.8 or 1
            if getgenv().Hana.EspOn then ApplyESP(p) end
        end
    end
end)

-- [[ UI BUILDER ]] --
local function AddToggle(name, var)
    local b = Instance.new("TextButton", Container); b.Size = UDim2.new(1,0,0,32); b.Text = name; b.BackgroundColor3 = Color3.fromRGB(25,25,25); b.TextColor3 = Color3.new(1,1,1); b.TextSize = 12; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        getgenv().Hana[var] = not getgenv().Hana[var]
        b.BackgroundColor3 = getgenv().Hana[var] and Color3.fromRGB(150, 0, 255) or Color3.fromRGB(25,25,25)
    end)
end

local function AddSlider(name, var, min, max)
    local f = Instance.new("Frame", Container); f.Size = UDim2.new(1,0,0,38); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1,0,0,15); l.Text = name..": "..getgenv().Hana[var]; l.TextColor3 = Color3.new(1,1,1); l.TextSize = 11; l.BackgroundTransparency = 1
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(0.9,0,0,8); b.Position = UDim2.new(0.05,0,0.6,0); b.Text = ""; b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    local fill = Instance.new("Frame", b); fill.Size = UDim2.new((getgenv().Hana[var]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
    
    b.MouseButton1Down:Connect(function()
        local move = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local pos = math.clamp((input.Position.X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(pos, 0, 1, 0); local val = math.floor(min + (pos * (max - min)))
                getgenv().Hana[var] = val; l.Text = name..": "..val
            end
        end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then move:Disconnect() end end)
    end)
end

AddToggle("LOYAL AIMLOCK", "AimOn")
AddToggle("GHOST HITBOX", "HitOn")
AddSlider("Hitbox Size", "HitSize", 2, 50)
AddToggle("INFO ESP (GREEN)", "EspOn")
AddToggle("ANTI-STUN", "AntiStun")
AddToggle("POWER SPEED", "SpeedOn")
AddSlider("Speed Value", "SpeedVal", 10, 350)
