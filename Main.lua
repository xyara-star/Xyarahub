-- [[ HANA HUB: V88 - FIXED TOGGLE BUTTON ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ OWNER WHITELIST SYSTEM ]]
local OwnerID = "player_new1126"
local IsOwner = (LocalPlayer.Name == OwnerID or LocalPlayer.UserId == 7586812833)
local UserRole = IsOwner and "Owner: Xyara" or "Member"
local RoleColor = IsOwner and Color3.fromRGB(255, 0, 150) or Color3.fromRGB(255, 255, 255)

-- [[ GLOBAL SETTINGS ]]
getgenv().AimOn = false
getgenv().HitOn = false
getgenv().InfoOn = false
getgenv().FruitOn = true

local PlayerLabels = {}
local FruitLabels = {}
local LockedTarget = nil

-- [[ UI CLEANUP ]]
if game.CoreGui:FindFirstChild("HanaV88") then game.CoreGui.HanaV88:Destroy() end
local ScreenGui = Instance.new("ScreenGui", game.CoreGui); ScreenGui.Name = "HanaV88"

-- 1. TOMBOL H (OPEN/CLOSE) - BALIK LAGI
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Name = "HanaToggle"
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(0, 10, 0.5, -22)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 150)
ToggleBtn.Text = "H"
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.Font = "SourceSansBold"
ToggleBtn.TextSize = 20
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1,0)

-- FPS & FRUIT STATUS BOX (TRANSPARENT)
local TopRight = Instance.new("Frame", ScreenGui)
TopRight.Size = UDim2.new(0, 180, 0, 60); TopRight.Position = UDim2.new(1, -190, 0.05, 0)
TopRight.BackgroundColor3 = Color3.new(0,0,0); TopRight.BackgroundTransparency = 0.7; Instance.new("UICorner", TopRight)

local FpsText = Instance.new("TextLabel", TopRight); FpsText.Size = UDim2.new(1,0,0.5,0); FpsText.TextColor3 = Color3.new(1,1,1); FpsText.Font = "SourceSansBold"; FpsText.Text = "FPS: --"; FpsText.BackgroundTransparency = 1
local FruitStatus = Instance.new("TextLabel", TopRight); FruitStatus.Size = UDim2.new(1,0,0.5,0); FruitStatus.Position = UDim2.new(0,0,0.5,0); FruitStatus.TextColor3 = Color3.new(1,1,0); FruitStatus.Font = "SourceSansBold"; FruitStatus.Text = "Fruit: Waiting..."; FruitStatus.BackgroundTransparency = 1

-- MAIN MENU WITH PROFILE
local Main = Instance.new("ScrollingFrame", ScreenGui); Main.Size = UDim2.new(0, 240, 0, 380); Main.Position = UDim2.new(0.5, -120, 0.5, -190); Main.BackgroundColor3 = Color3.new(0,0,0); Main.BackgroundTransparency = 0.5; Main.ScrollBarThickness = 0; Main.Visible = false; Instance.new("UICorner", Main)
local UIList = Instance.new("UIListLayout", Main); UIList.Padding = UDim.new(0, 10); UIList.HorizontalAlignment = "Center"
Instance.new("UIPadding", Main).PaddingTop = UDim.new(0, 10)

-- KLIK H BUAT BUKA
ToggleBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- PROFILE HEADER
local Prof = Instance.new("Frame", Main); Prof.Size = UDim2.new(0.9, 0, 0, 80); Prof.BackgroundTransparency = 0.6; Prof.BackgroundColor3 = Color3.fromRGB(30,30,30); Instance.new("UICorner", Prof)
local Img = Instance.new("ImageLabel", Prof); Img.Size = UDim2.new(0, 50, 0, 50); Img.Position = UDim2.new(0.05, 0, 0.15, 0); Img.Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150"; Instance.new("UICorner", Img).CornerRadius = UDim.new(1,0)
local LRole = Instance.new("TextLabel", Prof); LRole.Size = UDim2.new(0.6, 0, 0.3, 0); LRole.Position = UDim2.new(0.35, 0, 0.2, 0); LRole.Text = UserRole; LRole.TextColor3 = RoleColor; LRole.Font = "SourceSansBold"; LRole.TextSize = 14; LRole.BackgroundTransparency = 1; LRole.TextXAlignment = "Left"
local LName = Instance.new("TextLabel", Prof); LName.Size = UDim2.new(0.6, 0, 0.3, 0); LName.Position = UDim2.new(0.35, 0, 0.5, 0); LName.Text = "User: "..LocalPlayer.Name; LName.TextColor3 = Color3.new(1,1,1); LName.Font = "SourceSans"; LName.TextSize = 12; LName.BackgroundTransparency = 1; LName.TextXAlignment = "Left"

-- TOGGLE BUTTONS (PINK ON / BLACK OFF)
local function AddBtn(name, var)
    local b = Instance.new("TextButton", Main); b.Size = UDim2.new(0.9, 0, 0, 45); b.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1); b.Text = name..": OFF"; b.TextColor3 = Color3.new(1,1,1); b.Font = "SourceSansBold"; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        getgenv()[var] = not getgenv()[var]
        if var == "AimOn" then LockedTarget = nil end
        b.Text = name..": "..(getgenv()[var] and "ON" or "OFF")
        b.BackgroundColor3 = getgenv()[var] and Color3.fromRGB(255, 0, 150) or Color3.new(0.1, 0.1, 0.1)
    end)
end

AddBtn("STICKY AIMLOCK", "AimOn")
AddBtn("HITBOX PLAYER", "HitOn")
AddBtn("PLAYER INFO FULL", "InfoOn")
AddBtn("FRUIT ESP", "FruitOn")

-- [[ ENGINE ]]
task.spawn(function()
    local lastU = tick(); local cnt = 0
    RunService.RenderStepped:Connect(function()
        cnt = cnt + 1; if tick() - lastU >= 1 then FpsText.Text = "FPS: " .. cnt; cnt = 0; lastU = tick() end
        pcall(function()
            local myRoot = LocalPlayer.Character.HumanoidRootPart
            
            -- FRUIT ENGINE (LENGKAP DENGAN JARAK)
            local naturalFound = false
            for _, v in pairs(workspace:GetChildren()) do
                if v:IsA("Tool") and (v.Name:find("Fruit") or v:FindFirstChild("Handle")) then
                    local isNatural = (v.Parent == workspace) and not v:FindFirstChild("OnDropped")
                    local pos, onS = Camera:WorldToViewportPoint(v.Handle.Position)
                    if not FruitLabels[v] then
                        local l = Instance.new("TextLabel", ScreenGui); l.Size = UDim2.new(0, 120, 0, 30); l.Font = "SourceSansBold"; l.TextSize = 11; FruitLabels[v] = l
                    end
                    FruitLabels[v].Visible = (onS and getgenv().FruitOn)
                    if onS then
                        if isNatural then naturalFound = true end
                        local dist = math.floor((myRoot.Position - v.Handle.Position).Magnitude)
                        FruitLabels[v].Position = UDim2.new(0, pos.X - 60, 0, pos.Y)
                        FruitLabels[v].TextColor3 = isNatural and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                        FruitLabels[v].Text = string.format("%s %s\n[%dm]", (isNatural and "[NATURAL]" or "[DROP]"), v.Name, dist)
                    end
                end
            end
            for f, lbl in pairs(FruitLabels) do if not f.Parent then lbl:Destroy(); FruitLabels[f] = nil end end
            FruitStatus.Text = naturalFound and "Fruit: SPAWNED!" or "Fruit: Waiting..."

            -- AIMLOCK ENGINE
            if getgenv().AimOn and IsOwner then
                if not LockedTarget or not LockedTarget.Parent or LockedTarget.Humanoid.Health <= 0 then
                    local dMin = 400; local m = UIS:GetMouseLocation()
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local pos, onS = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                            if onS and (Vector2.new(pos.X, pos.Y) - m).Magnitude < dMin then
                                dMin = (Vector2.new(pos.X, pos.Y) - m).Magnitude; LockedTarget = p.Character
                            end
                        end
                    end
                end
                if LockedTarget then Camera.CFrame = CFrame.new(Camera.CFrame.Position, LockedTarget.HumanoidRootPart.Position) end
            end

            -- HITBOX & INFO (LENGKAP)
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    p.Character.HumanoidRootPart.Size = getgenv().HitOn and Vector3.new(18,18,18) or Vector3.new(2,2,1)
                    p.Character.HumanoidRootPart.Transparency = getgenv().HitOn and 0.7 or 1
                    if getgenv().InfoOn then
                        local head = p.Character:FindFirstChild("Head")
                        local pos, onS = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 4, 0))
                        if not PlayerLabels[p] then
                            local l = Instance.new("TextLabel", ScreenGui); l.Size = UDim2.new(0, 150, 0, 60); l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.Font = "SourceSansBold"; l.TextSize = 12; PlayerLabels[p] = l
                        end
                        PlayerLabels[p].Visible = onS
                        if onS then
                            local d = math.floor((myRoot.Position - p.Character.HumanoidRootPart.Position).Magnitude)
                            PlayerLabels[p].Position = UDim2.new(0, pos.X - 75, 0, pos.Y)
                            PlayerLabels[p].Text = string.format("%s\nHP: %d | Dist: %dm\nTeam: %s", p.Name, math.floor(p.Character.Humanoid.Health), d, tostring(p.Team or "None"))
                        end
                    elseif PlayerLabels[p] then PlayerLabels[p].Visible = false end
                end
            end
        end)
    end)
end)
