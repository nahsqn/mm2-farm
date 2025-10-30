-------------------------------------------------------------------
-- 🍬 FULL SYSTEM BY NQHSAN
-- AUTO RESET + ANTI AFK + ANTI LAG + AUTO REJOIN + AUTO LOAD
-------------------------------------------------------------------

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local autoResetEnabled = true
local resetting = false
local bag_full = false
local REJOIN_INTERVAL = 7200 -- 2 saat (saniye)
local totalCollected = 0 -- toplam toplama sayısı

-------------------------------------------------------------------
-- 💤 ANTI AFK
-------------------------------------------------------------------
Player.Idled:Connect(function()
	VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
	task.wait(1)
	VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-------------------------------------------------------------------
-- 💨 ANTI LAG / OPTIMIZE
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
-- 💬 GUI PANEL
-------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SystemStatus_Panel"
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0,270,0,140)
Frame.Position = UDim2.new(1,-290,1,140)
Frame.BackgroundColor3 = Color3.fromRGB(50,50,50)
Frame.BorderSizePixel = 0
Frame.BackgroundTransparency = 0.15
Frame.ZIndex = 10
Frame.ClipsDescendants = true
Frame.Rotation = 1

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0,12)
UICorner.Parent = Frame

local Stroke = Instance.new("UIStroke")
Stroke.Parent = Frame
Stroke.Thickness = 2
Stroke.Color = Color3.fromRGB(0,150,50)

-- Başlıklar
local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.Size = UDim2.new(1,0,0,25)
Title.Position = UDim2.new(0,0,0,8)
Title.BackgroundTransparency = 1
Title.Text = "Anti AFK açık"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.ZIndex = 11

local Sub1 = Instance.new("TextLabel")
Sub1.Parent = Frame
Sub1.Size = UDim2.new(1,0,0,22)
Sub1.Position = UDim2.new(0,0,0,35)
Sub1.BackgroundTransparency = 1
Sub1.Text = "Anti Lag aktif"
Sub1.Font = Enum.Font.SourceSansBold
Sub1.TextSize = 18
Sub1.TextColor3 = Color3.fromRGB(255,255,255)
Sub1.ZIndex = 11

local CollectedLabel = Instance.new("TextLabel")
CollectedLabel.Parent = Frame
CollectedLabel.Size = UDim2.new(1,0,0,22)
CollectedLabel.Position = UDim2.new(0,0,0,60)
CollectedLabel.BackgroundTransparency = 1
CollectedLabel.Text = "Toplanan: 0"
CollectedLabel.Font = Enum.Font.SourceSansBold
CollectedLabel.TextSize = 17
CollectedLabel.TextColor3 = Color3.fromRGB(255,215,0)
CollectedLabel.ZIndex = 11

local RejoinLabel = Instance.new("TextLabel")
RejoinLabel.Parent = Frame
RejoinLabel.Size = UDim2.new(1,0,0,22)
RejoinLabel.Position = UDim2.new(0,0,0,85)
RejoinLabel.BackgroundTransparency = 1
RejoinLabel.Text = "Rejoin: hazırlanıyor..."
RejoinLabel.Font = Enum.Font.SourceSansBold
RejoinLabel.TextSize = 17
RejoinLabel.TextColor3 = Color3.fromRGB(255,215,0)
RejoinLabel.ZIndex = 11

local FPSLabel = Instance.new("TextLabel")
FPSLabel.Parent = Frame
FPSLabel.Size = UDim2.new(0.5,0,0,22)
FPSLabel.Position = UDim2.new(0,5,0,110)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Text = "FPS: 0"
FPSLabel.Font = Enum.Font.SourceSansBold
FPSLabel.TextSize = 16
FPSLabel.TextColor3 = Color3.fromRGB(255,255,255)

local PingLabel = Instance.new("TextLabel")
PingLabel.Parent = Frame
PingLabel.Size = UDim2.new(0.5,0,0,22)
PingLabel.Position = UDim2.new(0.5,0,0,110)
PingLabel.BackgroundTransparency = 1
PingLabel.Text = "Ping: 0ms"
PingLabel.Font = Enum.Font.SourceSansBold
PingLabel.TextSize = 16
PingLabel.TextColor3 = Color3.fromRGB(255,255,255)

-- Sıfırlama butonu
local ResetBtn = Instance.new("TextButton")
ResetBtn.Parent = Frame
ResetBtn.Size = UDim2.new(0,80,0,20)
ResetBtn.Position = UDim2.new(0,190,0,110)
ResetBtn.Text = "Sıfırla"
ResetBtn.Font = Enum.Font.SourceSansBold
ResetBtn.TextSize = 14
ResetBtn.TextColor3 = Color3.fromRGB(255,255,255)
ResetBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
ResetBtn.AutoButtonColor = true
ResetBtn.MouseButton1Click:Connect(function()
	totalCollected = 0
	CollectedLabel.Text = "Toplanan: 0"
end)

-- GUI Animasyon
TweenService:Create(Frame,TweenInfo.new(1.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
	Position = UDim2.new(1,-290,1,-180),
	Rotation = 0
}):Play()

-- GUI sürüklenebilirlik
local dragging = false
local dragInput, mousePos, framePos

Frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		mousePos = input.Position
		framePos = Frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

Frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - mousePos
		Frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset+delta.X, framePos.Y.Scale, framePos.Y.Offset+delta.Y)
	end
end)

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

CoinCollected.OnClientEvent:Connect(function(_,current,max)
	if current == max and not resetting and autoResetEnabled then
		resetting = true
		bag_full = true
		local hrp = getHRP()
		if start_position then
			local tween = TweenService:Create(hrp,TweenInfo.new(2,Enum.EasingStyle.Linear),{CFrame=start_position})
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
	
	-- Sadece kendi topladıklarımızı ekle
	if current > 0 then
		totalCollected = totalCollected + current
		CollectedLabel.Text = "Toplanan: "..totalCollected
	end
end)

-------------------------------------------------------------------
-- 🚀 AUTO LOAD FARM SCRIPT
-------------------------------------------------------------------
task.spawn(function()
	pcall(function()
		loadstring(game:HttpGet('https://raw.githubusercontent.com/nahsqn/mm2-farm/refs/heads/main/test'))()
	end)
end)

-------------------------------------------------------------------
-- ⏱️ REJOIN GERİ SAYIM + TELEPORT
-------------------------------------------------------------------
local smoothFPS = 0
task.spawn(function()
	local remaining = REJOIN_INTERVAL
	while remaining > 0 do
		local hours = math.floor(remaining/3600)
		local minutes = math.floor((remaining%3600)/60)
		local seconds = remaining % 60

		-- FPS ve Ping yavaşça
		local ping = math.floor(Player:GetNetworkPing()*1000)
		PingLabel.Text = "Ping: "..ping.."ms"
		smoothFPS = smoothFPS + (1/RunService.RenderStepped:Wait() - smoothFPS) * 0.1
		FPSLabel.Text = "FPS: "..math.floor(smoothFPS)

		RejoinLabel.Text = string.format("Rejoin: %02dh %02dm %02ds kaldı", hours, minutes, seconds)
		task.wait(1)
		remaining -= 1
	end
	RejoinLabel.Text = "Rejoin atılıyor..."
	task.wait(2)
	pcall(function()
		TeleportService:Teleport(game.PlaceId, Player)
	end)
end)

-------------------------------------------------------------------
-- ⚠️ AŞIRI LAG / YÜKSEK PING REJOIN
-------------------------------------------------------------------
local LAG_THRESHOLD = 15
local PING_THRESHOLD = 250
local LAG_DURATION = 300 -- 5 dakika
local lagCounter = 0

RunService.Heartbeat:Connect(function(dt)
	local fps = 1/dt
	smoothFPS = smoothFPS + (fps - smoothFPS) * 0.1
	FPSLabel.Text = "FPS: "..math.floor(smoothFPS)
	local ping = math.floor(Player:GetNetworkPing()*1000)
	PingLabel.Text = "Ping: "..ping.."ms"

	if fps < LAG_THRESHOLD or ping > PING_THRESHOLD then
		lagCounter = lagCounter + dt
	else
		lagCounter = 0
	end

	if lagCounter >= LAG_DURATION then
		CollectedLabel.Text = "Aşırı lag, yeni servera geçiliyor..."
		task.wait(2)
		TeleportService:TeleportToPlaceInstance(game.PlaceId, nil, Player)
	end
end)
