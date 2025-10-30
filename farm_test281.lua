-- farm_test281.lua
-- NQHSAN ALL-IN-ONE SCRIPT
-- Anti-AFK, Anti-Lag, GUI, Auto Reset (bag full), mm2-farm loader, rejoin döngüsü

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")

-- AYARLAR
local REJOIN_INTERVAL = 120 -- test: 120s, production: 7200s
local SCRIPT_URL = "https://raw.githubusercontent.com/nahsqn/mm2-farm/refs/heads/main/test"

-- Durum değişkenleri
local autoResetEnabled = true
local resetting = false
local bag_full = false

-- Güvenli remote alma
local CoinCollected
pcall(function() CoinCollected = ReplicatedStorage.Remotes.Gameplay.CoinCollected end)

-- ANTI AFK
pcall(function()
    Player.Idled:Connect(function()
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(0.5)
            VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    end)
end)

-- ANTI LAG
local function optimizePerformance()
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
    pcall(function() workspace.FallenPartsDestroyHeight = -500 end)
    pcall(function() workspace.StreamingEnabled = true end)
    pcall(function() Lighting.GlobalShadows = false end)
    pcall(function() Lighting.FogEnd = 100000 end)
    pcall(function() Lighting.Brightness = 2 end)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
            pcall(function() v.Enabled = false end)
        end
    end
end
pcall(optimizePerformance)

-- GUI panel
local function createPanel()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NQHSAN_SystemStatus"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("CoreGui")

    local Frame = Instance.new("Frame")
    Frame.Parent = ScreenGui
    Frame.Size = UDim2.new(0, 300, 0, 120)
    Frame.Position = UDim2.new(1, -320, 1, 160)
    Frame.BackgroundColor3 = Color3.fromRGB(35,255,90)
    Frame.BackgroundTransparency = 0.12
    Frame.BorderSizePixel = 0
    Frame.ZIndex = 999
    Frame.ClipsDescendants = true

    local UICorner = Instance.new("UICorner", Frame)
    UICorner.CornerRadius = UDim.new(0,12)

    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Thickness = 2
    Stroke.Color = Color3.fromRGB(0,150,50)

    local Title = Instance.new("TextLabel", Frame)
    Title.Size = UDim2.new(1, -20, 0, 28)
    Title.Position = UDim2.new(0, 10, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Text = "🟢 Anti AFK açık!"
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 20
    Title.TextColor3 = Color3.fromRGB(0,0,0)

    local Sub1 = Instance.new("TextLabel", Frame)
    Sub1.Size = UDim2.new(1, -20, 0, 22)
    Sub1.Position = UDim2.new(0, 10, 0, 40)
    Sub1.BackgroundTransparency = 1
    Sub1.Text = "💨 Anti Lag aktif!"
    Sub1.Font = Enum.Font.SourceSansBold
    Sub1.TextSize = 17
    Sub1.TextColor3 = Color3.fromRGB(0,0,0)

    local RejoinLabel = Instance.new("TextLabel", Frame)
    RejoinLabel.Size = UDim2.new(1, -20, 0, 22)
    RejoinLabel.Position = UDim2.new(0, 10, 0, 66)
    RejoinLabel.BackgroundTransparency = 1
    RejoinLabel.Text = "⏳ Rejoin: hazırlanıyor..."
    RejoinLabel.Font = Enum.Font.SourceSansBold
    RejoinLabel.TextSize = 16
    RejoinLabel.TextColor3 = Color3.fromRGB(0,0,0)

    local Credit = Instance.new("TextLabel", Frame)
    Credit.Size = UDim2.new(1, -14, 0, 14)
    Credit.Position = UDim2.new(0, 7, 1, -20)
    Credit.BackgroundTransparency = 1
    Credit.Text = "by NQHSAN"
    Credit.Font = Enum.Font.SourceSansItalic
    Credit.TextSize = 11
    Credit.TextColor3 = Color3.fromRGB(60,60,60)
    Credit.TextXAlignment = Enum.TextXAlignment.Left

    pcall(function()
        Frame.Position = UDim2.new(1, -320, 1, 220)
        TweenService:Create(Frame, TweenInfo.new(1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -320, 1, -160)
        }):Play()
    end)

    return RejoinLabel
end

local RejoinLabel = createPanel()

-- BAG FULL auto reset (varsa)
if CoinCollected then
    CoinCollected.OnClientEvent:Connect(function(_, current, max)
        if current == max and not resetting and autoResetEnabled then
            resetting = true
            bag_full = true
            task.wait(0.5)
            pcall(function() if Player.Character and Player.Character:FindFirstChild("Humanoid") then Player.Character.Humanoid.Health = 0 end end)
            Player.CharacterAdded:Wait()
            task.wait(1.5)
            resetting = false
            bag_full = false
        end
    end)
end

-- mm2-farm otomatik yükle
task.spawn(function()
    pcall(function()
        if SCRIPT_URL and SCRIPT_URL ~= "" then
            loadstring(game:HttpGet(SCRIPT_URL))()
        end
    end)
end)

-- REJOIN döngüsü & geri sayım
task.spawn(function()
    while true do
        local remaining = REJOIN_INTERVAL
        while remaining > 0 do
            local h = math.floor(remaining / 3600)
            local m = math.floor((remaining % 3600) / 60)
            local s = remaining % 60
            pcall(function()
                RejoinLabel.Text = string.format("⏳ Rejoin: %02dh %02dm %02ds kaldı", h, m, s)
            end)
            task.wait(1)
            remaining -= 1
        end
        pcall(function() RejoinLabel.Text = "🔁 Rejoin atılıyor..." end)
        task.wait(2)
        pcall(function()
            TeleportService:Teleport(game.PlaceId, Player)
        end)
        task.wait(10)
    end
end)
