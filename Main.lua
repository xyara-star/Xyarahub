-- [[ HANA HUB: TRUE UNIVERSAL SEPARATION ]]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- CEK APAKAH INI BLOX FRUIT (Sea 1, 2, atau 3)
if PlaceId == 2753915549 or PlaceId == 4442272183 or PlaceId == 7449423635 then
    -- [[ ========================================== ]]
    -- [[ BAGIAN BLOX FRUIT (DISTANCE FIX)          ]]
    -- [[ ========================================== ]]
    
    local RunService = game:GetService("RunService")
    local Camera = workspace.CurrentCamera
    local OwnerID = "player_new1126"
    local IsOwner = (LocalPlayer.Name == OwnerID)

    getgenv().SpeedOn = false
    getgenv().AimOn = false
    getgenv().HitOn = false
    getgenv().InfoOn = false
    getgenv().FruitOn = false
    getgenv().SpeedVal = 20

    local PlayerLabels = {}
    local LockedTarget = nil

    if game.CoreGui:FindFirstChild("HanaDistanceFix") then game.CoreGui.HanaDistanceFix:Destroy() end
    local ScreenGui = Instance.new("ScreenGui", game.CoreGui); ScreenGui.Name = "HanaDistanceFix"

    local ToggleBtn = Instance.new("TextButton", ScreenGui)
    ToggleBtn.Size = UDim2.new(0, 45, 0, 45); ToggleBtn.Position = UDim2.new(0.02, 0, 0.45, 0)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 150); ToggleBtn.BackgroundTransparency = 0.4; ToggleBtn.Text = "H"; ToggleBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1,0)

    local MainFrame = Instance.new("ScrollingFrame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 240, 0, 420); MainFrame.Position = UDim2.new(0.5, -120, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0); MainFrame.BackgroundTransparency = 0.6; MainFrame.Visible = false; MainFrame.ScrollBarThickness = 0; Instance.new("UICorner", MainFrame)
    Instance.new("UIListLayout", MainFrame).Padding = UDim.new(0, 8); Instance.new("UIPadding", MainFrame).PaddingTop = UDim.new(0, 5)

    local Prof = Instance.new("Frame", MainFrame); Prof.Size = UDim2.new(0.9, 0, 0, 85); Prof.BackgroundTransparency = 0.5; Prof.BackgroundColor3 = Color3.fromRGB(30,30,30); Instance.new("UICorner", Prof)
    local Img = Instance.new("ImageLabel", Prof); Img.Size = UDim2.new(0, 55, 0, 55); Img.Position = UDim2.new(0.05, 0, 0.15, 0); Img.Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150"; Instance.new("UICorner", Img).CornerRadius = UDim.new(1,0)
    local LRole = Instance.new("TextLabel", Prof); LRole.Size = UDim2.new(0.6, 0, 0.3, 0); LRole.Position = UDim2.new(0.38, 0, 0.2, 0); LRole.Text = IsOwner and "Owner: Xyara" or "Member"; LRole.TextColor3 = IsOwner and Color3.fromRGB(255, 0, 150) or Color3.new(1,1,1); LRole.Font = "SourceSansBold"; LRole.TextSize = 16; LRole.BackgroundTransparency = 1; LRole.TextXAlignment = "Left"

    ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

    local function AddToggle(name, var)
        local b = Instance.new("TextButton", MainFrame); b.Size = UDim2.new(0.9, 0, 0, 35); b.BackgroundColor3 = Color3.new(0,0,0); b.BackgroundTransparency = 0.6; b.Text = name..": OFF"; b.TextColor3 = Color3.new(1,1,1); b.Font = "SourceSansBold"; Instance.new("UICorner", b)
        b.MouseButton1Click:Connect(function()
            getgenv()[var] = not getgenv()[var]
            b.Text = name..": "..(getgenv()[var] and "ON" or "OFF")
            b.BackgroundColor3 = getgenv()[var] and Color3.fromRGB(255, 0, 150) or Color3.new(0,0,0)
        end)
    end

    AddToggle("SPEED BOOST", "SpeedOn"); AddToggle("STICKY AIMLOCK", "AimOn"); AddToggle("HITBOX PLAYER", "HitOn"); AddToggle("PLAYER INFO FULL", "InfoOn"); AddToggle("FRUIT ESP", "FruitOn")

    RunService.RenderStepped:Connect(function()
        pcall(function()
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if getgenv().SpeedOn and myRoot then
                local hum = LocalPlayer.Character.Humanoid
                if hum.MoveDirection.Magnitude > 0 then LocalPlayer.Character:TranslateBy(hum.MoveDirection * (getgenv().SpeedVal / 18)) end
            end
            if getgenv().AimOn then
                if not LockedTarget or not LockedTarget:FindFirstChild("Humanoid") or LockedTarget.Humanoid.Health <= 0 then
                    local dMin = 1000
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local d = (myRoot.Position - p.Character.HumanoidRootPart.Position).Magnitude
                            if d < dMin then dMin = d; LockedTarget = p.Character end
                        end
                    end
                end
                if LockedTarget then Camera.CFrame = CFrame.new(Camera.CFrame.Position, LockedTarget.HumanoidRootPart.Position) end
            end
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    p.Character.HumanoidRootPart.Size = getgenv().HitOn and Vector3.new(16,16,16) or Vector3.new(2,2,1)
                    p.Character.HumanoidRootPart.Transparency = getgenv().HitOn and 0.75 or 1
                end
            end
        end)
    end)

else
    -- [[ ========================================== ]]
    -- [[ BAGIAN FPS (V19 GOD MODE)                 ]]
    -- [[ ========================================== ]]
    
    local RunService = game:GetService("RunService")
    local OwnerName = "Hana"
    local IsOwner = (LocalPlayer.Name == OwnerName or LocalPlayer.DisplayName == OwnerName)

    getgenv().HitboxExpander = false
    getgenv().NoRecoil = false
    getgenv().SpeedBoost = false
    getgenv().RapidFire = false 
    getgenv().InfAmmo = false 

    if game.CoreGui:FindFirstChild("HanaV19") then game.CoreGui.HanaV19:Destroy() end
    local sg = Instance.new("ScreenGui", game.CoreGui); sg.Name = "HanaV19"

    local openBtn = Instance.new("TextButton", sg)
    openBtn.Size = UDim2.new(0, 50, 0, 50); openBtn.Position = UDim2.new(0.02, 0, 0.15, 0)
    openBtn.Text = "H"; openBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 150); Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)

    local Main = Instance.new("Frame", sg)
    Main.Size = UDim2.new(0, 420, 0, 280); Main.Position = UDim2.new(0.5, -210, 0.5, -140)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Main.Visible = false; Instance.new("UICorner", Main)
    openBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

    local Scroll = Instance.new("ScrollingFrame", Main)
    Scroll.Size = UDim2.new(0, 260, 0, 240); Scroll.Position = UDim2.new(0.35, 10, 0.08, 0); Scroll.BackgroundTransparency = 1; Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 8)

    local function AddToggle(name, var)
        local b = Instance.new("TextButton", Scroll); b.Size = UDim2.new(0.95, 0, 0, 40); b.Text = name..": OFF"; b.BackgroundColor3 = Color3.fromRGB(45, 45, 45); b.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", b)
        b.MouseButton1Click:Connect(function()
            getgenv()[var] = not getgenv()[var]
            b.Text = name..": "..(getgenv()[var] and "ON" or "OFF")
            b.BackgroundColor3 = getgenv()[var] and Color3.fromRGB(255, 0, 150) or Color3.fromRGB(45, 45, 45)
        end)
    end

    AddToggle("HITBOX EXPANDER", "HitboxExpander"); AddToggle("SPEED BOOST", "SpeedBoost"); AddToggle("NO RECOIL", "NoRecoil")
    if IsOwner then AddToggle("3X RAPID FIRE", "RapidFire"); AddToggle("INFINITE AMMO", "InfAmmo") end

    RunService.RenderStepped:Connect(function()
        pcall(function()
            if getgenv().SpeedBoost then LocalPlayer.Character.Humanoid.WalkSpeed = IsOwner and 100 or 32 else LocalPlayer.Character.Humanoid.WalkSpeed = 16 end
        end)
    end)
end
