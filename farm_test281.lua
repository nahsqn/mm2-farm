-------------------------------------------------------------------
-- 🍬 FULL SYSTEM BY NQHSAN
-- ANTI AFK + ANTI LAG + AUTO REJOIN + FPS/PING + SERVER SWITCH
-------------------------------------------------------------------

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local REJOIN_INTERVAL = 7200 -- 2 saat
local LAG_THRESHOLD = 15 -- FPS
local LAG_DURATION = 300 -- 5 dakika

-- Anti AFK
Player.Idled:Connect(function()
	VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
	task.wait(1)
	VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- Anti Lag / Optimize
local function optimizePerformance()
	settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
	pcall(function() workspace.FallenPartsDestroyHeight = -500 end)
	pcall(function() workspace.StreamingEnabled = true end)
	pcall(function() workspace.GlobalShadows = false end)
	pcall(function() workspace.Lighting.FogEnd = 100000 end)
	pcall(function() workspace.Lighting.Brightness = 2 end)
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
			v.Enabled = false
		end
	end
end
optimizePerformance()

-- GUI PANEL
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SystemStatus_Panel"
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0,280,0,140)
Frame.Position = UDim2.new(1,-300,1,160)
Frame.BackgroundColor3 = Color3.fromRGB(50,50,50)
Frame.BorderSizePixel = 0
Frame.BackgroundTransparency = 0.15
Frame.ZIndex = 10
Frame.ClipsDescendants = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0,12)
UICorner.Parent = Frame

local Stroke = Instance.new("UIStroke")
Stroke.Parent = Frame
Stroke.Thickness = 2
Stroke.Color = Color3.fromRGB(0,150,50)

local function createLabel(text,size,pos,color)
	local lbl = Instance.new("TextLabel")
	lbl.Parent = Frame
	lbl.Size = UDim2.new(1,0,0,size)
	lbl.Position = UDim2.new(0,0,0,pos)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.Font = Enum.Font.SourceSansBold
	lbl.TextSize = 17
	lbl.TextColor3 = color
	lbl.ZIndex = 11
	return lbl
end

local AntiAFKLabel = createLabel("Anti AFK aktif",25,8,Color3.fromRGB(255,255,255))
local AntiLagLabel = createLabel("Anti Lag aktif",22,35,Color3.fromRGB(255,255,255))
local FPSLabel = createLabel("FPS: ...",22,60,Color3.fromRGB(255,255,255))
local PingLabel = createLabel("Ping: ...",22,85,Color3.fromRGB(255,255,255))
local RejoinLabel = createLabel("Rejoin: hazırlanıyor...",22,110,Color3.fromRGB(255,215,0))

-- GUI Animasyon
TweenService:Create(Frame,TweenInfo.new(1.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
	Position = UDim2.new(1,-300,1,-160),
}):Play()

-- GUI Sürükleme
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

-- Rejoin geri sayım
task.spawn(function()
	local remaining = REJOIN_INTERVAL
	while remaining > 0 do
		local hours = math.floor(remaining/3600)
		local minutes = math.floor((remaining%3600)/60)
		local seconds = remaining % 60
		RejoinLabel.Text = string.format("⏳ Rejoin: %02dh %02dm %02ds", hours, minutes, seconds)
		task.wait(1)
		remaining -= 1
	end
	RejoinLabel.Text = "🔁 Rejoin atılıyor..."
	task.wait(2)
	pcall(function()
		TeleportService:Teleport(game.PlaceId, Player)
	end)
end)

-- FPS ve Ping göstergesi
local lastFrame = tick()
local lagCounter = 0
local LAG_THRESHOLD = 15
local LAG_DURATION = 300

RunService.Heartbeat:Connect(function()
	local dt = tick()-lastFrame
	lastFrame = tick()
	local fps = 1/dt
	FPSLabel.Text = string.format("FPS: %d", math.floor(fps))

	local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
	PingLabel.Text = string.format("Ping: %d ms", math.floor(ping))

	if fps < LAG_THRESHOLD then
		lagCounter = lagCounter + dt
	else
		lagCounter = 0
	end

	if lagCounter >= LAG_DURATION then
		RejoinLabel.Text = "⚠️ Sunucu çok kasıyor, yeni sunucu aranıyor..."
		task.wait(2)
		-- Yeni sunucuya git
		local servers = {}
		local PlaceID = game.PlaceId
		local success, response = pcall(function()
			return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceID.."/servers/Public?sortOrder=Asc&limit=100"))
		end)
		if success and response and response.data then
			for _,v in pairs(response.data) do
				if v.playing < v.maxPlayers then
					table.insert(servers,v.id)
				end
			end
		end
		if #servers > 0 then
			local serverID = servers[math.random(1,#servers)]
			TeleportService:TeleportToPlaceInstance(PlaceID, serverID, Player)
		else
			TeleportService:Teleport(PlaceID, Player)
		end
	end
end)

-- Yeni Servera Git butonu
local Button = Instance.new("TextButton")
Button.Parent = Frame
Button.Size = UDim2.new(1,-20,0,25)
Button.Position = UDim2.new(0,10,0,5)
Button.BackgroundColor3 = Color3.fromRGB(60,60,60)
Button.TextColor3 = Color3.fromRGB(255,255,0)
Button.Text = "Yeni Servera Git"
Button.Font = Enum.Font.SourceSansBold
Button.TextSize = 16
Button.ZIndex = 11

Button.MouseButton1Click:Connect(function()
	RejoinLabel.Text = "🔁 Yeni sunucuya gidiliyor..."
	task.wait(1)
	local servers = {}
	local PlaceID = game.PlaceId
	local success, response = pcall(function()
		return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceID.."/servers/Public?sortOrder=Asc&limit=100"))
	end)
	if success and response and response.data then
		for _,v in pairs(response.data) do
			if v.playing < v.maxPlayers then
				table.insert(servers,v.id)
			end
		end
	end
	if #servers > 0 then
		local serverID = servers[math.random(1,#servers)]
		TeleportService:TeleportToPlaceInstance(PlaceID, serverID, Player)
	else
		TeleportService:Teleport(PlaceID, Player)
	end
end)
