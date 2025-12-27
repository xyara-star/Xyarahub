-- [[ HANA HUB: V50 - IMMORTAL FPS & FULL OWNER FEATURES ]]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- VALIDASI OWNER
local isOwner = (LocalPlayer.Name == "player_new1126")

getgenv().HitboxExpander = false
getgenv().EspPlayer = false
getgenv().SpeedBoost = false
getgenv().JumpBoost = false
getgenv().NoRecoil = false
getgenv().RapidFire = false
getgenv().InfAmmo = false

-- [[ 1. SISTEM FPS ABADI (TERPISAH) ]]
local function CreateImmortalFPS()
    local Target = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    if Target:FindFirstChild("HanaFPS_V50") then return end

    local sgFPS = Instance.new("ScreenGui", Target); sgFPS.Name = "HanaFPS_V50"; sgFPS.DisplayOrder = 99999
    
    local fpsLabel = Instance.new("TextLabel", sgFPS)
    fpsLabel.Size = UDim2.new(0, 100, 0, 30); fpsLabel.Position = UDim2.new(0.5, -50, 0.01, 0)
    fpsLabel.BackgroundTransparency = 1; fpsLabel.TextColor3 = Color3.new(0, 0, 0) -- HITAM PEKAT
    fpsLabel.Font = "SourceSansBold"; fpsLabel.TextSize = 22; fpsLabel.ZIndex = 1000
    
    local lastUpdate = tick(); local count = 0
    RunService.RenderStepped:Connect(function()
        count = count + 1
        if tick() - lastUpdate >= 1 then
            fpsLabel.Text = "FPS: " .. count
            count = 0; lastUpdate = tick()
        end
    end)
end

-- [[ 2. UI MENU UTAMA ]]
local function CreateHanaUI()
    local Target = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    if Target:FindFirstChild("HanaV50") then return end

    local sg = Instance.new("ScreenGui", Target); sg.Name = "HanaV50"; sg.ResetOnSpawn = false; sg.DisplayOrder = 10000

    -- TOMBOL "H" PINK
    local hBtn = Instance.new("TextButton", sg)
    hBtn.Size = UDim2.new(0, 50, 0, 50); hBtn.Position = UDim2.new(0.02, 0, 0.3, 0)
    hBtn.Text = "H"; hBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 150); hBtn.TextColor3 = Color3.new(1,1,1); hBtn.Font = "SourceSansBold"; hBtn.TextSize = 25
    Instance.new("UICorner", hBtn).CornerRadius = UDim.new(1, 0)

    -- PANEL BLOX FRUIT STYLE
    local Main = Instance.new("Frame", sg)
    Main.Size = UDim2.new(0, 350, 0, 420); Main.Position = UDim2.new(0.5, -175, 0.5, -210)
    Main.BackgroundColor3 = Color3.new(0,0,0); Main.BackgroundTransparency = 0.25; Main.Visible = true
    Instance.new("UICorner", Main); Instance.new("UIStroke", Main).Color = Color3.fromRGB(255, 0, 150)

    hBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

    -- PROFILE & ROLE
    local Side = Instance.new("Frame", Main); Side.Size = UDim2.new(0, 120, 1, 0); Side.BackgroundTransparency = 1
    local Ava = Instance.new("ImageLabel", Side)
    Ava.Size = UDim2.new(0, 80, 0, 80); Ava.Position = UDim2.new(0.5, -45, 0.08, 0)
    Ava.Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150"
    Instance.new("UICorner", Ava).CornerRadius = UDim.new(1, 0)

    local Role = Instance.new("TextLabel", Side); Role.Size = UDim2.new(1, 0, 0, 20); Role.Position = UDim2.new(0,0,0.3,0)
    Role.Text = isOwner and "OWNER: HANA" or "MEMBER"; Role.TextColor3 = Color3.fromRGB(255, 0, 150); Role.Font = "SourceSansBold"

    -- LIST BUTTONS
    local Scroll = Instance.new("ScrollingFrame", Main); Scroll.Size = UDim2.new(0, 220, 0, 360); Scroll.Position = UDim2.new(0.35, 0, 0.08, 0); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 0
    Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 10)

    local function AddToggle(text, var, lock)
        local btn = Instance.new("TextButton", Scroll); btn.Size = UDim2.new(1, 0, 0, 42); btn.Text = text..": OFF"
        btn.BackgroundColor3 = Color3.new(0,0,0); btn.BackgroundTransparency = 0.4; btn.TextColor3 = Color3.new(1,1,1); btn.Font = "SourceSansBold"
        Instance.new("UICorner", btn); Instance.new("UIStroke", btn).Color = Color3.fromRGB(120, 120, 120)

        if lock and not isOwner then btn.Text = text.." (LOCKED)"; btn.TextColor3 = Color3.new(0.4, 0.4, 0.4) end

        btn.MouseButton1Click:Connect(function()
            if lock and not isOwner then return end
            getgenv()[var] = not getgenv()[var]
            btn.Text = text..": "..(getgenv()[var] and "ON" or "OFF")
            btn.TextColor3 = getgenv()[var] and Color3.fromRGB(255, 0, 150) or Color3.new(1,1,1)
        end)
    end

    AddToggle("Hitbox Expander", "HitboxExpander", false)
    AddToggle("ESP Player", "EspPlayer", true)
    AddToggle("Speed Boost", "SpeedBoost", true)
    AddToggle("Jump Boost", "JumpBoost", true)
    AddToggle("No Recoil", "NoRecoil", true)
    AddToggle("50x Rapid Fire", "RapidFire", true)
    AddToggle("Infinite Ammo", "InfAmmo", true)
end

-- JALANKAN SEMUA SYSTEM
task.spawn(function()
    while task.wait(1) do 
        pcall(CreateImmortalFPS) 
        pcall(CreateHanaUI) 
    end 
end)

-- [[ ENGINE ]]
RunService.Stepped:Connect(function()
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().SpeedBoost and 65 or 16
            LocalPlayer.Character.Humanoid.JumpPower = getgenv().JumpBoost and 100 or 50
        end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                if getgenv().HitboxExpander then
                    p.Character.HumanoidRootPart.Size = Vector3.new(15,15,15); p.Character.HumanoidRootPart.Transparency = 0.7
                end
                if getgenv().EspPlayer and isOwner then
                    local h = p.Character:FindFirstChild("HanaESP") or Instance.new("Highlight", p.Character)
                    h.Name = "HanaESP"; h.Enabled = true; h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                end
            end
        end
    end)
end)
