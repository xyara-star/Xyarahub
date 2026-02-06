-- [[ XYARA HUB X HANA: V50 - FPS GOD MODE ]] --
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- VALIDASI OWNER (Ganti "player_new1126" dengan username-mu)
local isOwner = (LocalPlayer.Name == "player_new1126" or LocalPlayer.Name == "your_name_here")

getgenv().Xyara = {
    Hitbox = false,
    Esp = false,
    Speed = false,
    NoRecoil = false,
    RapidFire = false,
    InfAmmo = false,
    InstaReload = false
}

-- [[ 1. FPS COUNTER (BLACK STYLE) ]]
task.spawn(function()
    local sgFPS = Instance.new("ScreenGui", game.CoreGui); sgFPS.Name = "XyaraFPS"
    local fpsLabel = Instance.new("TextLabel", sgFPS)
    fpsLabel.Size = UDim2.new(0, 100, 0, 30); fpsLabel.Position = UDim2.new(0.5, -50, 0.01, 0)
    fpsLabel.BackgroundTransparency = 1; fpsLabel.TextColor3 = Color3.new(0, 0, 0); fpsLabel.Font = "SourceSansBold"; fpsLabel.TextSize = 22
    
    local lastUpdate, count = tick(), 0
    RunService.RenderStepped:Connect(function()
        count = count + 1
        if tick() - lastUpdate >= 1 then
            fpsLabel.Text = "FPS: " .. count
            count = 0; lastUpdate = tick()
        end
    end)
end)

-- [[ 2. UI MENU (π LOGO & BLOX FRUIT STYLE) ]]
local ScreenGui = Instance.new("ScreenGui", game.CoreGui); ScreenGui.Name = "XyaraMenu"
local Main = Instance.new("Frame", ScreenGui); Main.Size = UDim2.new(0, 380, 0, 300); Main.Position = UDim2.new(0.5, -190, 0.5, -150); Main.BackgroundColor3 = Color3.new(0,0,0); Main.BackgroundTransparency = 0.2; Main.Visible = false; Instance.new("UICorner", Main); Instance.new("UIStroke", Main).Color = Color3.fromRGB(150, 0, 255)

-- Logo π Toggle
local hBtn = Instance.new("TextButton", ScreenGui); hBtn.Size = UDim2.new(0, 50, 0, 50); hBtn.Position = UDim2.new(0.02, 0, 0.45, 0); hBtn.Text = "π"; hBtn.BackgroundColor3 = Color3.fromRGB(10,10,10); hBtn.TextColor3 = Color3.new(1,1,1); hBtn.TextSize = 30; Instance.new("UICorner", hBtn).CornerRadius = UDim.new(1,0); Instance.new("UIStroke", hBtn).Color = Color3.fromRGB(150,0,255)
hBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- Sidebar Profile
local Side = Instance.new("Frame", Main); Side.Size = UDim2.new(0, 120, 1, 0); Side.BackgroundTransparency = 1
local Ava = Instance.new("ImageLabel", Side); Ava.Size = UDim2.new(0, 70, 0, 70); Ava.Position = UDim2.new(0.5, -35, 0.1, 0); Ava.Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150"; Instance.new("UICorner", Ava).CornerRadius = UDim.new(1,0)
local Role = Instance.new("TextLabel", Side); Role.Size = UDim2.new(1, 0, 0, 20); Role.Position = UDim2.new(0,0,0.4,0); Role.Text = isOwner and "OWNER: HANA" or "FREE USER"; Role.TextColor3 = Color3.fromRGB(150, 0, 255); Role.Font = "SourceSansBold"; Role.BackgroundTransparency = 1

-- Scroll Content
local Scroll = Instance.new("ScrollingFrame", Main); Scroll.Size = UDim2.new(0, 240, 0, 260); Scroll.Position = UDim2.new(0.35, 0, 0.05, 0); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 0
local Layout = Instance.new("UIListLayout", Scroll); Layout.Padding = UDim.new(0, 8)

local function AddToggle(text, var, lock)
    local btn = Instance.new("TextButton", Scroll); btn.Size = UDim2.new(0.95, 0, 0, 35); btn.Text = text..": OFF"; btn.BackgroundColor3 = Color3.fromRGB(30,30,30); btn.TextColor3 = Color3.new(1,1,1); btn.Font = "SourceSansBold"; Instance.new("UICorner", btn)
    if lock and not isOwner then btn.Text = text.." [LOCKED]"; btn.TextColor3 = Color3.new(0.4, 0.4, 0.4) end
    btn.MouseButton1Click:Connect(function()
        if lock and not isOwner then return end
        getgenv().Xyara[var] = not getgenv().Xyara[var]
        btn.Text = text..": "..(getgenv().Xyara[var] and "ON" or "OFF")
        btn.BackgroundColor3 = getgenv().Xyara[var] and Color3.fromRGB(150, 0, 255) or Color3.fromRGB(30,30,30)
    end)
end

-- Tambah Button (Urutan sesuai request)
AddToggle("Hitbox Expander", "Hitbox", false)
AddToggle("ESP Highlight", "Esp", false)
AddToggle("Speed Boost", "Speed", true)
AddToggle("No Recoil", "NoRecoil", true)
AddToggle("Rapid Fire", "RapidFire", true)
AddToggle("Instant Reload", "InstaReload", true)
AddToggle("Infinite Ammo", "InfAmmo", true)

-- [[ 3. FPS ENGINE (FIXED FEATURES) ]]
RunService.RenderStepped:Connect(function()
    pcall(function()
        -- 4 Fitur yang tadinya mati (Logic Gun)
        for _, v in pairs(game:GetService("Players").LocalPlayer.Character:GetChildren()) do
            if v:IsA("Tool") and v:FindFirstChild("Handle") then -- Deteksi Senjata
                -- No Recoil Logic
                if getgenv().Xyara.NoRecoil then
                    -- Reset Viewmodel recoil (tergantung engine game-nya)
                    if v:FindFirstChild("Recoil") then v.Recoil:Destroy() end 
                end
                
                -- Infinite Ammo & Instant Reload
                -- Mencoba mencari folder Stats/Config di senjata
                local config = v:FindFirstChild("Configuration") or v:FindFirstChild("Stats")
                if config then
                    if getgenv().Xyara.InfAmmo and config:FindFirstChild("Ammo") then
                        config.Ammo.Value = 999
                    end
                    if getgenv().Xyara.InstaReload and config:FindFirstChild("ReloadTime") then
                        config.ReloadTime.Value = 0
                    end
                    if getgenv().Xyara.RapidFire and config:FindFirstChild("FireRate") then
                        config.FireRate.Value = 0.01
                    end
                end
            end
        end

        -- Character Stats
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().Xyara.Speed and 80 or 16
        end

        -- Hitbox & ESP
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = getgenv().Xyara.Hitbox and Vector3.new(15,15,15) or Vector3.new(2,2,1)
                p.Character.HumanoidRootPart.Transparency = getgenv().Xyara.Hitbox and 0.7 or 1
                
                local highlight = p.Character:FindFirstChild("XyaraESP")
                if getgenv().Xyara.Esp then
                    if not highlight then
                        highlight = Instance.new("Highlight", p.Character)
                        highlight.Name = "XyaraESP"
                        highlight.FillColor = Color3.fromRGB(150, 0, 255)
                    end
                elseif highlight then highlight:Destroy() end
            end
        end
    end)
end)
