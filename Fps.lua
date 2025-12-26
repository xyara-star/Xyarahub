-- [[ HANA HUB: V21 - FPS GLASS EDITION ]]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- CONFIGURATION
local OWNER_NAME = "Hana" 
getgenv().HitboxExpander = false
getgenv().NoRecoil = false
getgenv().SpeedBoost = false
getgenv().RapidFire = false 
getgenv().InfAmmo = false 

-- [[ UI CONSTRUCTION ]]
if game.CoreGui:FindFirstChild("HanaFPS") then game.CoreGui.HanaFPS:Destroy() end
local sg = Instance.new("ScreenGui", game.CoreGui); sg.Name = "HanaFPS"; sg.DisplayOrder = 999

-- TOMBOL BUKA (PINK TRANSPARENT)
local openBtn = Instance.new("TextButton", sg)
openBtn.Size = UDim2.new(0, 50, 0, 50); openBtn.Position = UDim2.new(0.02, 0, 0.15, 0)
openBtn.Text = "H"; openBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 150)
openBtn.BackgroundTransparency = 0.4; openBtn.TextColor3 = Color3.new(1,1,1); openBtn.ZIndex = 1010
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)

-- MAIN FRAME (GLASS LOOK)
local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 420, 0, 280); Main.Position = UDim2.new(0.5, -210, 0.5, -140)
Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0); Main.BackgroundTransparency = 0.5 -- Efek Transparan
Main.Visible = false; Main.ZIndex = 1000
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 15)

openBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- [[ SIDE PROFILE - SOLID FOR VISIBILITY ]]
local ProfileSide = Instance.new("Frame", Main)
ProfileSide.Size = UDim2.new(0, 130, 1, 0); ProfileSide.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ProfileSide.BackgroundTransparency = 0.2; ProfileSide.ZIndex = 1001
Instance.new("UICorner", ProfileSide).CornerRadius = UDim.new(0, 15)

local AvatarImg = Instance.new("ImageLabel", ProfileSide)
AvatarImg.Size = UDim2.new(0, 80, 0, 80); AvatarImg.Position = UDim2.new(0.5, -40, 0.1, 0)
AvatarImg.Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150"
AvatarImg.BackgroundTransparency = 1; AvatarImg.ZIndex = 1002
Instance.new("UICorner", AvatarImg).CornerRadius = UDim.new(1, 0)

local isOwner = (LocalPlayer.Name == OWNER_NAME or LocalPlayer.DisplayName == OWNER_NAME)
local RoleLabel = Instance.new("TextLabel", ProfileSide)
RoleLabel.Size = UDim2.new(1, 0, 0, 30); RoleLabel.Position = UDim2.new(0, 0, 0.5, 0)
RoleLabel.Text = isOwner and "OWNER: HANA" or "ROLE: MEMBER"
RoleLabel.TextColor3 = Color3.fromRGB(255, 0, 150); RoleLabel.Font = "SourceSansBold"
RoleLabel.BackgroundTransparency = 1; RoleLabel.ZIndex = 1002; RoleLabel.TextSize = 14

-- [[ LIST FITUR - GLASS BUTTONS ]]
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(0, 260, 0, 240); Scroll.Position = UDim2.new(0.35, 10, 0.08, 0)
Scroll.BackgroundTransparency = 1; Scroll.ZIndex = 1001; Scroll.ScrollBarThickness = 0
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 8)

local function AddToggle(name, var)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(0.95, 0, 0, 40); b.Text = name..": OFF"
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 45); b.BackgroundTransparency = 0.4 -- Tombol Transparan
    b.TextColor3 = Color3.new(1, 1, 1); b.ZIndex = 1002; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        getgenv()[var] = not getgenv()[var]
        b.Text = name..": "..(getgenv()[var] and "ON" or "OFF")
        b.BackgroundColor3 = getgenv()[var] and Color3.fromRGB(255, 0, 150) or Color3.fromRGB(45, 45, 45)
        b.BackgroundTransparency = getgenv()[var] and 0.2 or 0.4
    end)
end

AddToggle("HITBOX EXPANDER", "HitboxExpander")
AddToggle("SPEED BOOST", "SpeedBoost")
AddToggle("NO RECOIL", "NoRecoil")
if isOwner then
    AddToggle("3X RAPID FIRE", "RapidFire")
    AddToggle("INFINITE AMMO", "InfAmmo")
end

-- [[ ENGINE LOGIC ]]
RunService.RenderStepped:Connect(function()
    pcall(function()
        -- 1. Hitbox Kasta
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp and getgenv().HitboxExpander then
                    hrp.Size = isOwner and Vector3.new(20, 20, 20) or Vector3.new(10, 10, 10)
                    hrp.Transparency = 0.7; hrp.CanCollide = false
                end
            end
        end

        -- 2. Speed Boost Kasta
        if getgenv().SpeedBoost then
            LocalPlayer.Character.Humanoid.WalkSpeed = isOwner and 100 or 32
        else
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end

        -- 3. Owner Only Weapon Mods
        if isOwner then
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("GunSettings") then
                local s = require(tool.GunSettings)
                if getgenv().RapidFire then s.FireRate = 0.05 end
                if getgenv().InfAmmo then s.Ammo = 999 end
            end
        end

        -- 4. No Recoil
        if getgenv().NoRecoil then
            workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * CFrame.Angles(0,0,0)
        end
    end)
end)
