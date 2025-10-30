-------------------------------------------------------------------
-- 🍬 FULL SYSTEM BY NQHSAN
-- AUTO RESET + ANTI AFK + ANTI LAG + AUTO REJOIN + AUTO LOAD + SERVER SWITCH
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
local HttpService = game:GetService("HttpService")

local autoResetEnabled = true
local resetting = false
local bag_full = false
local REJOIN_INTERVAL = 7200 -- 2 saat
local LAG_THRESHOLD = 15 -- FPS
local LAG_DURATION = 300 -- 5 dakika
local lagCounter = 0
local lastFrameTime = tick()

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
Frame.Size = UDim2.new(0, 300, 0, 140)
Frame.Position = UDim2.new(1, -320, 1, -160)
Frame.BackgroundColor3 = Color3.fromRGB(50,50,50)
Frame.BackgroundTransparency = 0.15
Frame.ZIndex = 10
Frame.ClipsDescendants = true
Frame.Rotation = 1

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0,12)
local Stroke = Instance.new("UIStroke", Frame)
Stroke.Thickness = 2
Stroke.Color = Color3.fromRGB(0,150,50)

local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.Size = UDim2.new(1,0,0,25)
Title.Position = UDim2.new(0,0,0,8)
Title.BackgroundTransparency = 1
Title.Text = "🟢 Anti AFK aktif!"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.ZIndex = 11

local Sub1 = Instance.new("TextLabel")
Sub1.Parent = Frame
Sub1.Size = UDim2.new(1,0,0,22)
Sub1.Position = UDim2.new(0,0,0,35)
Sub1.BackgroundTransparency = 1
Sub1.Text = "💨 Anti Lag aktif!"
Sub1.Font = Enum.Font.SourceSansBold
Sub1.TextSize = 18
Sub1.TextColor3 = Color3.fromRGB(255,255,255)
Sub1.ZIndex = 11

local RejoinLabel = Instance.new("TextLabel")
RejoinLabel.Parent = Frame
RejoinLabel.Size = UDim2.new(1,0,0,22)
RejoinLabel.Position = UDim2.new(0,0,0,60)
RejoinLabel.BackgroundTransparency = 1
RejoinLabel.Text = "⏳ Rejoin: hazırlanıyor..."
RejoinLabel.Font = Enum.Font.SourceSansBold
RejoinLabel.TextSize = 17
RejoinLabel.TextColor3 = Color3.fromRGB(255,215,0)
RejoinLabel.ZIndex = 11

local ServerButton = Instance.new("TextButton")
ServerButton.Parent = Frame
ServerButton.Size = UDim2.new(1, -20, 0, 30)
ServerButton.Position = UDim2.new(0, 10, 0, 90)
ServerButton.BackgroundColor3 = Color3.fromRGB(0,150,50)
ServerButton.TextColor3 = Color3.fromRGB(255,255,255)
ServerButton.Text = "🌐 Yeni Servera Git"
ServerButton.Font = Enum.Font.SourceSansBold
ServerButton.TextSize = 18
ServerButton.ZIndex = 11
local BtnCorner = Instance.new("UICorner", ServerButton)

local Credit = Instance.new("TextLabel")
Credit.Parent = Frame
Credit.Size = UDim2.new(1,-10,0,15)
Credit.Position = UDim2.new(0,5,1,-20)
Credit.BackgroundTransparency = 1
Credit.Text = "by NQHSAN"
Credit.Font = Enum.Font.SourceSansItalic
Credit.TextSize = 11
Credit.TextColor3 = Color3.fromRGB(200,200,200)
Credit.TextXAlignment = Enum.TextXAlignment.Left
Credit.ZIndex = 11

-- GUI sürüklenebilirlik
local dragging, dragInput, mousePos, framePos = false, nil, nil, nil
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
		Frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
	end
end)

-------------------------------------------------------------------
-- 🔁 SERVER SWITCH FUNCTION
-------------------------------------------------------------------
local function teleportNewServer()
	local success, servers = pcall(function()
		return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
	end)
	if success and servers.data then
		for _, s in pairs(servers.data) do
			if s.playing < s.maxPlayers and s.id ~= game.JobId then
				pcall(function()
					TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, Player)
				end)
				return
			end
		end
	end
end

ServerButton.MouseButton1Click:Connect(function()
	teleportNewServer()
end)

-------------------------------------------------------------------
-- ⏱️ REJOIN GERİ SAYIM + TELEPORT (FARKLI SERVER)
-------------------------------------------------------------------
task.spawn(function()
	local remaining = REJOIN_INTERVAL
	while remaining > 0 do
		local hours = math.floor(remaining/3600)
		local minutes = math.floor((remaining%3600)/60)
		local seconds = remaining % 60
		RejoinLabel.Text = string.format("⏳ Rejoin: %02dh %02dm %02ds kaldı", hours, minutes, seconds)
		task.wait(1)
		remaining -= 1
	end
	RejoinLabel.Text = "🔁 Rejoin atılıyor..."
	task.wait(2)
	teleportNewServer()
end)

-------------------------------------------------------------------
-- ⚠️ AŞIRI LAG REJOIN (FPS < 15 5 DAKİKA)
-------------------------------------------------------------------
RunService.Heartbeat:Connect(function()
	local currentTime = tick()
	local dt = currentTime - lastFrameTime
	lastFrameTime = currentTime
	local fps = 1/dt
	if fps < LAG_THRESHOLD then
		lagCounter = lagCounter + dt
	else
		lagCounter = 0
	end
	if lagCounter >= LAG_DURATION then
		RejoinLabel.Text = "⚠️ Oyun aşırı dondu, farklı servera geçiliyor..."
		task.wait(2)
		teleportNewServer()
	end
end)
