-- [[ HANA HUB: XYARA FIX DISTANCE & WHITELIST + BLACK FPS ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ OWNER WHITELIST SYSTEM ]]
local OwnerID = "player_new1126"
local IsOwner = (LocalPlayer.Name == OwnerID)
local UserRole = IsOwner and "Owner: Xyara" or "Member"
local RoleColor = IsOwner and Color3.fromRGB(255, 0, 150) or Color3.fromRGB(255, 255, 255)

-- [[ GLOBAL SETTINGS ]]
getgenv().SpeedOn = false
getgenv().AimOn = false
getgenv().HitOn = false
getgenv().InfoOn = false
getgenv().FruitOn = false
getgenv().SpeedVal = 20

local PlayerLabels = {}
local FruitLabels = {}
local LockedTarget = nil

-- [[ UI: GLASS TRANSPARENT ]]
if game.CoreGui:FindFirstChild("HanaDistanceFix") then game.CoreGui.HanaDistanceFix:Destroy() end
local ScreenGui = Instance.new("ScreenGui", game.CoreGui); ScreenGui.Name = "HanaDistanceFix"

-- [[ TAMBAHAN: BLACK FPS INDICATOR ]] --
local fpsLabel = Instance.new("TextLabel", ScreenGui)
fpsLabel.Size = UDim2.new(0, 100, 0, 30); fpsLabel.Position = UDim2.new(0.5, -50, 0.01, 0)
fpsLabel.BackgroundTransparency = 1; fpsLabel.TextColor3 = Color3.new(0, 0, 0); -- WARNA HITAM
fpsLabel.Font = "SourceSansBold"; fpsLabel.TextSize = 22; fpsLabel.ZIndex = 1000

task.spawn(function()
    local lastUpdate = tick(); local count = 0
    RunService.RenderStepped:Connect(function()
        count = count + 1
        if tick() - lastUpdate >= 1 then
            fpsLabel.Text = "FPS: " .. count
            count = 0; lastUpdate = tick()
        end
    end)
end)
---------------------------------------

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 45, 0, 45); ToggleBtn.Position = UDim2.new(0.02, 0, 0.45, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 150); ToggleBtn.BackgroundTransparency = 0.4; ToggleBtn.Text = "H"; ToggleBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1,0)

local MainFrame = Instance.new("ScrollingFrame", ScreenGui)
MainFrame.Size = UDim2.new(0, 240, 0, 420); MainFrame.Position = UDim2.new(0.5, -120, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0); MainFrame.BackgroundTransparency = 0.6; MainFrame.Visible = false; MainFrame.ScrollBarThickness = 0; Instance.new("UICorner", MainFrame)
Instance.new("UIListLayout", MainFrame).Padding = UDim.new(0, 8); Instance.new("UIPadding", MainFrame).PaddingTop = UDim.new(0, 5)

-- [[ PROFILE SECTION ]]
local Prof = Instance.new("Frame", MainFrame); Prof.Size = UDim2.new(0.9, 0, 0, 85); Prof.BackgroundTransparency = 0.5; Prof.BackgroundColor3 = Color3.fromRGB(30,30,30); Instance.new("UICorner", Prof)
local Img = Instance.new("ImageLabel", Prof); Img.Size = UDim2.new(0, 55, 0, 55); Img.Position = UDim2.new(0.05, 0, 0.15, 0); Img.Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150"; Instance.new("UICorner", Img).CornerRadius = UDim.new(1,0)
local LRole = Instance.new("TextLabel", Prof); LRole.Size = UDim2.new(0.6, 0, 0.3, 0); LRole.Position = UDim2.new(0.38, 0, 0.2, 0); LRole.Text = UserRole; LRole.TextColor3 = RoleColor; LRole.Font = "SourceSansBold"; LRole.TextSize = 16; LRole.BackgroundTransparency = 1; LRole.TextXAlignment = "Left"
local LName = Instance.new("TextLabel", Prof); LName.Size = UDim2.new(0.6, 0, 0.3, 0); LName.Position = UDim2.new(0.38, 0, 0.5, 0); LName.Text = "User: "..LocalPlayer.Name; LName.TextColor3 = Color3.new(1,1,1); LName.Font = "SourceSans"; LName.TextSize = 12; LName.BackgroundTransparency = 1; LName.TextXAlignment = "Left"

-- [[ TOGGLE ENGINE ]]
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local function AddToggle(name, var)
    local b = Instance.new("TextButton", MainFrame); b.Size = UDim2.new(0.9, 0, 0, 35); b.BackgroundColor3 = Color3.new(0,0,0); b.BackgroundTransparency = 0.6; b.Text = name..": OFF"; b.TextColor3 = Color3.new(1,1,1); b.Font = "SourceSansBold"; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        getgenv()[var] = not getgenv()[var]
        b.Text = name..": "..(getgenv()[var] and "ON" or "OFF")
        b.BackgroundColor3 = getgenv()[var] and Color3.fromRGB(255, 0, 150) or Color3.new(0,0,0)
    end)
end

AddToggle("SPEED BOOST", "SpeedOn")
AddToggle("STICKY AIMLOCK", "AimOn")
AddToggle("HITBOX PLAYER", "HitOn")
AddToggle("PLAYER INFO FULL", "InfoOn")
AddToggle("FRUIT ESP", "FruitOn")

-- [[ MAIN ENGINE FIX ]]
RunService.RenderStepped:Connect(function()
    pcall(function()
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if getgenv().SpeedOn and myRoot then
            local hum = LocalPlayer.Character.Humanoid
            if hum.MoveDirection.Magnitude > 0 then
                LocalPlayer.Character:TranslateBy(hum.MoveDirection * (getgenv().SpeedVal / 18))
            end
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
                
                if getgenv().InfoOn then
                    local sPos, onS = Camera:WorldToViewportPoint(p.Character.Head.Position + Vector3.new(0, 13, 0))
                    if not PlayerLabels[p] then
                        local l = Instance.new("TextLabel", ScreenGui); l.Size = UDim2.new(0, 160, 0, 80); l.BackgroundTransparency = 1; l.TextColor3 = Color3.new(1,1,1); l.Font = "SourceSansBold"; l.TextSize = 12; PlayerLabels[p] = l
                    end
                    PlayerLabels[p].Visible = onS
                    if onS then
                        local dist = myRoot and math.floor((myRoot.Position - p.Character.HumanoidRootPart.Position).Magnitude) or 0
                        local lvl = p:FindFirstChild("Data") and p.Data:FindFirstChild("Level") and p.Data.Level.Value or "???"
                        PlayerLabels[p].Position = UDim2.new(0, sPos.X - 80, 0, sPos.Y)
                        PlayerLabels[p].Text = string.format("%s [Lv. %s]\nDist: %dm\nHP: %d", p.Name, lvl, dist, math.floor(p.Character.Humanoid.Health))
                    end
                elseif PlayerLabels[p] then PlayerLabels[p].Visible = false end
            end
        end
    end)
end)
