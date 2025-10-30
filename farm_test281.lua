-------------------------------------------------------------------
-- 🍬 AUTO RESET + ANTI AFK + ANTI LAG + AUTO REJOIN + AUTO LOAD
-- ✨ by NQHSAN
-------------------------------------------------------------------

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")

local autoResetEnabled = true
local resetting = false
local bag_full = false
local REJOIN_INTERVAL = 7200 -- 2 saat (saniye)

-------------------------------------------------------------------
-- 💤 ANTI AFK
-------------------------------------------------------------------
Player.Idled:Connect(function()
	VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
	task.wait(1)
	VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

-------------------------------------------------------------------
-- 💨 ANTI LAG
-------------------------------------------------------------------
local function optimizePerformance()
	settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
	pcall(function() workspace.FallenPartsDestroyHeight = -500 end)
	pcall(function() workspace.StreamingEnabled = true end)
	pcall(function() Lighting.GlobalShadows = false end)
	pcall(function() Lighting.FogEnd = 100000 end)
	pcall(function() Lighting.Brightness = 2 end)
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
			v.Enabled = false
		end
	end
end
optimizePerformance()

-------------------------------------------------------------------
-- 💬 PANEL (ANİMASYONLU + GERİ SAYIM)
-------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SystemStatus_Panel"
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 270, 0, 110)
Frame.Position = UDim2.new(1, -290, 1, 140)
Frame.BackgroundColor3 = Color3.fromRGB(35, 255, 90)
Frame.BorderSizePixel = 0
Frame.BackgroundTransparency = 0.15
Frame.ZIndex = 10
Frame.ClipsDescendants = true
Frame.Rotation = 1

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Frame

local Stroke = Instance.new("UIStroke")
Stroke.Parent = Frame
Stroke.Thickness = 2
Stroke.Color = Color3.fromRGB(0, 150, 50)

local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Position = UDim2.new(0, 0, 0, 8)
Title.BackgroundTransparency = 1
Title.Text = "🟢 Anti AFK açık!"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.TextColor3 = Color3.fromRGB(0, 0, 0)
Title.ZIndex = 11

local Sub1 = Instance.new("TextLabel")
Sub1.Parent = Frame
Sub1.Size = UDim2.new(1, 0, 0, 22)
Sub1.Position = UDim2.new(0, 0, 0, 35)
Sub1.BackgroundTransparency = 1
Sub1.Text = "💨 Anti Lag aktif!"
Sub1.Font = Enum.Font.SourceSansBold
Sub1.TextSize = 18
Sub1.TextColor3 = Color3.fromRGB(0, 0, 0)
Sub1.ZIndex = 11

local RejoinLabel = Instance.new("TextLabel")
RejoinLabel.Parent = Frame
RejoinLabel.Size = UDim2.new(1, 0, 0, 22)
RejoinLabel.Position = UDim2.new(0, 0, 0, 60)
RejoinLabel.BackgroundTransparency = 1
RejoinLabel.Text = "⏳ Rejoin: hazırlanıyor..."
RejoinLabel.Font = Enum.Font.SourceSansBold
RejoinLabel.TextSize = 17
RejoinLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
RejoinLabel.ZIndex = 11

local Credit = Instance.new("TextLabel")
Credit.Parent = Frame
Credit.Size = UDim2.new(1, -10, 0, 15)
Credit.Position = UDim2.new(0, 5, 1, -20)
Credit.BackgroundTransparency = 1
Credit.Text = "by NQHSAN"
Credit.Font = Enum.Font.SourceSansItalic
Credit.TextSize = 11
Credit.TextColor3 = Color3.fromRGB(60, 60, 60)
Credit.TextXAlignment = Enum.TextXAlignment.Left
Credit.ZIndex = 11

TweenService:Create(Frame, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
	Position = UDim2.new(1, -290, 1, -140),
	Rotation = 0
}):Play()

-------------------------------------------------------------------
-- 🪣 AUTO RESET (Bag Full)
-------------------------------------------------------------------
local function getCharacter()
	return Player.Character or Player.CharacterAdded:Wait()
end
local function getHRP()
	return getCharacter():WaitForChild("HumanoidRootPart")
end

local start_position = getHRP().CFrame
local CoinCollected = ReplicatedStorage.Remotes.Gameplay.CoinCollected

CoinCollected.OnClientEvent:Connect(function(_, current, max)
	if current == max and not resetting and autoResetEnabled then
		resetting = true
		bag_full = true
		local hrp = getHRP()
		if start_position then
			local tween = TweenService:Create(hrp, TweenInfo.new(2, Enum.EasingStyle.Linear), {CFrame = start_position})
			tween:Play()
			tween.Completed:Wait()
		end
		task.wait(0.5)
		Player.Character.Humanoid.Health = 0
		Player.CharacterAdded:Wait()
		task.wait(1.5)
		resetting = false
		bag_full = false
	end
end)

-------------------------------------------------------------------
-- 🚀 AUTO LOAD (mm2-farm)
-------------------------------------------------------------------
task.spawn(function()
	pcall(function()
		loadstring(game:HttpGet('https://raw.githubusercontent.com/nahsqn/mm2-farm/refs/heads/main/test'))()
	end)
end)

-------------------------------------------------------------------
-- ⏱️ REJOIN GERİ SAYIM + TELEPORT
-------------------------------------------------------------------
task.spawn(function()
	local remaining = REJOIN_INTERVAL
	while remaining > 0 do
		local hours = math.floor(remaining / 3600)
		local minutes = math.floor((remaining % 3600) / 60)
		local seconds = remaining % 60
		RejoinLabel.Text = string.format("⏳ Rejoin: %02ds %02dm %02ds kaldı", hours, minutes, seconds)
		task.wait(1)
		remaining -= 1
	end
	RejoinLabel.Text = "🔁 Rejoin atılıyor..."
	task.wait(2)
	pcall(function()
		TeleportService:Teleport(game.PlaceId, Player)
	end)
end)
