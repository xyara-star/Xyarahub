-- [[ HANA HUB: V11.0 - GOD MODE EDITION ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ CONFIG ]] --
getgenv().Hana = {
    AimOn = false,
    HitOn = false,
    SpeedOn = false,
    JumpOn = true,
    HitSize = 15,
    SpeedVal = 80,
    Target = nil
}

-- [[ UI CLEANUP ]] --
if game.CoreGui:FindFirstChild("HanaV11") then game.CoreGui.HanaV11:Destroy() end
local ScreenGui = Instance.new("ScreenGui", game.CoreGui); ScreenGui.Name = "HanaV11"

-- TOMBOL H
local HBtn = Instance.new("TextButton", ScreenGui)
HBtn.Size = UDim2.new(0, 45, 0, 45); HBtn.Position = UDim2.new(0, 10, 0.5, -22)
HBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 150); HBtn.Text = "H"; HBtn.TextColor3 = Color3.new(1,1,1)
HBtn.Draggable = true; Instance.new("UICorner", HBtn).CornerRadius = UDim.new(1,0)

-- TOMBOL JUMP
local JumpBtn = Instance.new("TextButton", ScreenGui)
JumpBtn.Size = UDim2.new(0, 45, 0, 45); JumpBtn.Position = UDim2.new(0.9, 0, 0.02, 0)
JumpBtn.Text = "^"; JumpBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255); JumpBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", JumpBtn)

-- TARGET INFO BOX
local InfoBox = Instance.new("Frame", ScreenGui)
InfoBox.Size = UDim2.new(0, 180, 0, 85); InfoBox.Position = UDim2.new(0.85, -180, 0.1, 0)
InfoBox.BackgroundColor3 = Color3.new(0,0,0); InfoBox.BackgroundTransparency = 0.5; InfoBox.Visible = false
local InfoText = Instance.new("TextLabel", InfoBox); InfoText.Size = UDim2.new(1,-10,1,-10); InfoText.Position = UDim2.new(0,5,0,5); InfoText.BackgroundTransparency = 1; InfoText.TextColor3 = Color3.new(1,1,1); InfoText.TextSize = 13; InfoText.RichText = true; InfoText.TextXAlignment = "Left"
Instance.new("UICorner", InfoBox)

-- MAIN MENU WITH PROFILE
local Main = Instance.new("Frame", ScreenGui); Main.Size = UDim2.new(0, 240, 0, 380); Main.Position = UDim2.new(0.5, -120, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(15,15,15); Main.BackgroundTransparency = 0.1; Main.Visible = false; Instance.new("UICorner", Main)

-- PROFILE HEADER
local Prof = Instance.new("Frame", Main); Prof.Size = UDim2.new(0.9, 0, 0, 80); Prof.Position = UDim2.new(0.05, 0, 0.03, 0); Prof.BackgroundColor3 = Color3.fromRGB(30,30,30); Prof.BackgroundTransparency = 0.5; Instance.new("UICorner", Prof)
local Img = Instance.new("ImageLabel", Prof); Img.Size = UDim2.new(0, 50, 0, 50); Img.Position = UDim2.new(0.05, 0, 0.2, 0); Img.Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150"; Instance.new("UICorner", Img).CornerRadius = UDim.new(1,0)
local LName = Instance.new("TextLabel", Prof); LName.Size = UDim2.new(0.6, 0, 0.5, 0); LName.Position = UDim2.new(0.35, 0, 0.25, 0); LName.Text = "User: "..LocalPlayer.Name; LName.TextColor3 = Color3.new(1,1,1); LName.Font = "SourceSansBold"; LName.BackgroundTransparency = 1; LName.TextXAlignment = "Left"

-- LAYERS
local L1 = Instance.new("ScrollingFrame", Main); L1.Size = UDim2.new(1,0,0.6,0); L1.Position = UDim2.new(0,0,0.25,0); L1.BackgroundTransparency = 1; L1.ScrollBarThickness = 0
local L2 = Instance.new("ScrollingFrame", Main); L2.Size = UDim2.new(1,0,0.6,0); L2.Position = UDim2.new(0,0,0.25,0); L2.BackgroundTransparency = 1; L2.ScrollBarThickness = 0; L2.Visible = false
Instance.new("UIListLayout", L1).Padding = UDim.new(0,8); Instance.new("UIListLayout", L1).HorizontalAlignment = "Center"
Instance.new("UIListLayout", L2).Padding = UDim.new(0,8); Instance.new("UIListLayout", L2).HorizontalAlignment = "Center"

local TabBtn = Instance.new("TextButton", Main); TabBtn.Size = UDim2.new(0.9,0,0,40); TabBtn.Position = UDim2.new(0.05,0,0.88,0); TabBtn.Text = "MENU SETTINGS (L2)"; TabBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 150); TabBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", TabBtn)

-- [[ ENGINE ]] --
local function getClosest()
    local t, d = nil, 400; local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
            local pos, onS = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if onS then
                local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if mag < d then d = mag; t = p end
            end
        end
    end
    return t
end

RunService.RenderStepped:Connect(function()
    -- ZERO DELAY AIMLOCK
    if getgenv().Hana.AimOn then
        if not getgenv().Hana.Target or not getgenv().Hana.Target.Character or getgenv().Hana.Target.Character.Humanoid.Health <= 0 then
            getgenv().Hana.Target = getClosest()
        end
        local tar = getgenv().Hana.Target
        if tar and tar.Character:FindFirstChild("HumanoidRootPart") then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, tar.Character.HumanoidRootPart.Position)
            
            -- INFO DISPLAY
            InfoBox.Visible = true
            local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - tar.Character.HumanoidRootPart.Position).Magnitude)
            InfoText.Text = "<b>Target:</b> "..tar.Name.."\n<b>HP:</b> "..math.floor(tar.Character.Humanoid.Health).."\n<b>Dist:</b> "..dist.."m"
        else InfoBox.Visible = false end
    else InfoBox.Visible = false end

    -- GHOST HITBOX
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local root = p.Character.HumanoidRootPart
            if getgenv().Hana.HitOn then
                root.Size = Vector3.new(getgenv().Hana.HitSize, getgenv().Hana.HitSize, getgenv().Hana.HitSize)
                root.Transparency = 0.7; root.CanCollide = false
            else
                root.Size = Vector3.new(2,2,1); root.Transparency = 1; root.CanCollide = true
            end
        end
    end
    
    if getgenv().Hana.SpeedOn and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().Hana.SpeedVal
    end
    JumpBtn.Visible = getgenv().Hana.JumpOn
end)

-- [[ UI ACTION ]] --
HBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)
TabBtn.MouseButton1Click:Connect(function()
    L1.Visible = not L1.Visible; L2.Visible = not L2.Visible
    TabBtn.Text = L1.Visible and "MENU SETTINGS (L2)" or "BACK TO MAIN (L1)"
end)

JumpBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character.Humanoid then
        LocalPlayer.Character.Humanoid.JumpPower = 120; LocalPlayer.Character.Humanoid:ChangeState(3); task.wait(0.1); LocalPlayer.Character.Humanoid.JumpPower = 50
    end
end)

local function AddToggle(name, var, parent)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(0.9,0,0,45); b.Text = name..": OFF"; b.BackgroundColor3 = Color3.fromRGB(40,40,40); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        getgenv().Hana[var] = not getgenv().Hana[var]
        if var == "AimOn" then getgenv().Hana.Target = nil end
        b.Text = name..": "..(getgenv().Hana[var] and "ON" or "OFF")
        b.BackgroundColor3 = getgenv().Hana[var] and Color3.fromRGB(255, 0, 150) or Color3.fromRGB(40,40,40)
    end)
end

local function AddSlider(name, var, step, max, parent)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(0.9,0,0,55); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1,0,0.4,0); l.Text = name..": "..getgenv().Hana[var]; l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(1,0,0.5,0); b.Position = UDim2.new(0,0,0.4,0); b.Text = "Adjust Value (+ "..step..")"; b.BackgroundColor3 = Color3.fromRGB(60,60,60); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        getgenv().Hana[var] = getgenv().Hana[var] + step
        if getgenv().Hana[var] > max then getgenv().Hana[var] = step end
        l.Text = name..": "..getgenv().Hana[var]
    end)
end

AddToggle("STICKY AIMLOCK", "AimOn", L1)
AddToggle("GHOST HITBOX", "HitOn", L1)
AddToggle("SPEED BOOST", "SpeedOn", L1)
AddToggle("TOMBOL JUMP", "JumpOn", L1)

AddSlider("Hitbox Size", "HitSize", 5, 50, L2)
AddSlider("Walk Speed", "SpeedVal", 20, 250, L2)
