-------------------------------------------------------------------
-- 🍬 FULL SYSTEM BY NQHSAN
-- ANTI AFK + ANTI LAG + AUTO REJOIN + NEW SERVER BUTTON
-------------------------------------------------------------------

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local REJOIN_INTERVAL = 7200 -- 2 saat
local LAG_THRESHOLD = 15 -- FPS
local LAG_DURATION = 300 -- 5 dakika
local PING_THRESHOLD = 200 -- ms

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

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 300, 0, 140)
Frame.Position = UDim2.new(1, -320, 1, -160)
Frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
Frame.BorderSizePixel = 0
Frame.ClipsDescendants = true

local UICorner = Instance.new("UICorner")
UICorner.Parent = Frame
UICorner.CornerRadius = UDim.new(0,12)

local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.Size = UDim2.new(1,0,0,25)
Title.Position = UDim2.new(0,0,0,8)
Title.BackgroundTransparency = 1
Title.Text = "🟢 Anti AFK açık! | by NQHSAN"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255,255,255)

local FpsLabel = Instance.new("TextLabel")
FpsLabel.Parent = Frame
FpsLabel.Size = UDim2.new(1,0,0,20)
FpsLabel.Position = UDim2.new(0,0,0,35)
FpsLabel.BackgroundTransparency = 1
FpsLabel.Text = "🎮 FPS: hesaplanıyor..."
FpsLabel.Font = Enum.Font.SourceSansBold
FpsLabel.TextSize = 16
FpsLabel.TextColor3 = Color3.fromRGB(255,255,255)

local PingLabel = Instance.new("TextLabel")
PingLabel.Parent = Frame
PingLabel.Size = UDim2.new(1,0,0,20)
PingLabel.Position = UDim2.new(0,0,0,60)
PingLabel.BackgroundTransparency = 1
PingLabel.Text = "📶 Ping: hesaplanıyor..."
PingLabel.Font = Enum.Font.SourceSansBold
PingLabel.TextSize = 16
PingLabel.TextColor3 = Color3.fromRGB(255,255,0)

local RejoinLabel = Instance.new("TextLabel")
RejoinLabel.Parent = Frame
RejoinLabel.Size = UDim2.new(1,0,0,20)
RejoinLabel.Position = UDim2.new(0,0,0,85)
RejoinLabel.BackgroundTransparency = 1
RejoinLabel.Text = "⏳ Rejoin: hazırlanıyor..."
RejoinLabel.Font = Enum.Font.SourceSansBold
RejoinLabel.TextSize = 16
RejoinLabel.TextColor3 = Color3.fromRGB(255,215,0)

local NewServerButton = Instance.new("TextButton")
NewServerButton.Parent = Frame
NewServerButton.Size = UDim2.new(1,-20,0,25)
NewServerButton.Position = UDim2.new(0,10,0,110)
NewServerButton.Text = "🌐 Yeni Servera Git"
NewServerButton.Font = Enum.Font.SourceSansBold
NewServerButton.TextSize = 16
NewServerButton.TextColor3 = Color3.fromRGB(255,255,255)
NewServerButton.BackgroundColor3 = Color3.fromRGB(70,70,70)
local ButtonCorner = Instance.new("UICorner", NewServerButton)

-- GUI Animasyon
TweenService:Create(Frame,TweenInfo.new(1,Enum.EasingStyle.Quad),{Position=UDim2.new(1,-320,1,-160)}):Play()

-- GUI Drag
local dragging=false
local dragInput,mousePos,framePos

Frame.InputBegan:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseButton1 then
		dragging=true
		mousePos=input.Position
		framePos=Frame.Position
		input.Changed:Connect(function()
			if input.UserInputState==Enum.UserInputState.End then dragging=false end
		end)
	end
end)
Frame.InputChanged:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseMovement then dragInput=input end
end)
UserInputService.InputChanged:Connect(function(input)
	if input==dragInput and dragging then
		local delta=input.Position-mousePos
		Frame.Position=UDim2.new(framePos.X.Scale,framePos.X.Offset+delta.X,framePos.Y.Scale,framePos.Y.Offset+delta.Y)
	end
end)

-- FPS & Ping Güncelleme
local lastTime = tick()
local lagCounter = 0
RunService.Heartbeat:Connect(function()
	local currentTime = tick()
	local dt = currentTime-lastTime
	lastTime=currentTime
	local fps = 1/dt
	FpsLabel.Text = string.format("🎮 FPS: %d", math.floor(fps))
	local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
	PingLabel.Text = string.format("📶 Ping: %d ms", math.floor(ping))
	
	-- Lag veya yüksek ping kontrolü
	if fps<LAG_THRESHOLD or ping>PING_THRESHOLD then
		lagCounter=lagCounter+dt
	else
		lagCounter=0
	end
	if lagCounter>=LAG_DURATION then
		RejoinLabel.Text="⚠️ Sunucu çok kasıyor, yeni servera gidiliyor..."
		task.wait(2)
		local PlaceID=game.PlaceId
		local success,servers=pcall(function()
			return game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceID.."/servers/Public?sortOrder=Asc&limit=100"))
		end)
		if success and servers and #servers.data>0 then
			local list={}
			for _,v in pairs(servers.data) do
				if v.playing<v.maxPlayers then table.insert(list,v.id) end
			end
			if #list>0 then
				local serverID=list[math.random(1,#list)]
				TeleportService:TeleportToPlaceInstance(PlaceID,serverID,Player)
			else
				TeleportService:Teleport(PlaceID,Player)
			end
		else
			TeleportService:Teleport(PlaceID,Player)
		end
	end
end)

-- Rejoin Timer
task.spawn(function()
	local remaining=REJOIN_INTERVAL
	while remaining>0 do
		local hours=math.floor(remaining/3600)
		local minutes=math.floor((remaining%3600)/60)
		local seconds=remaining%60
		RejoinLabel.Text=string.format("⏳ Rejoin: %02dh %02dm %02ds kaldı",hours,minutes,seconds)
		task.wait(1)
		remaining=remaining-1
	end
	RejoinLabel.Text="🔁 Rejoin atılıyor..."
	task.wait(2)
	TeleportService:Teleport(game.PlaceId,Player)
end)

-- Yeni Server Butonu
NewServerButton.MouseButton1Click:Connect(function()
	RejoinLabel.Text="🌐 Yeni Servera gidiliyor..."
	task.wait(1)
	local PlaceID=game.PlaceId
	local success,servers=pcall(function()
		return game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceID.."/servers/Public?sortOrder=Asc&limit=100"))
	end)
	if success and servers and #servers.data>0 then
		local list={}
		for _,v in pairs(servers.data) do
			if v.playing<v.maxPlayers then table.insert(list,v.id) end
		end
		if #list>0 then
			local serverID=list[math.random(1,#list)]
			TeleportService:TeleportToPlaceInstance(PlaceID,serverID,Player)
		else
			TeleportService:Teleport(PlaceID,Player)
		end
	else
		TeleportService:Teleport(PlaceID,Player)
	end
end)
