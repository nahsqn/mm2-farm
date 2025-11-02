-------------------------------------------------------------------
-- 🍬 FULL SYSTEM BY NQHSAN (TAM ENTEGRE)
-- AUTO RESET + ANTI AFK + ANTI LAG + YENİ SERVER + FPS/PING + TELEPORT SÜRESİ
-------------------------------------------------------------------

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")

local autoResetEnabled = true
local resetting = false
local bag_full = false
local TELEPORT_INTERVAL = 900 -- 15 dakika
local LAG_FPS = 34
local LAG_TIME = 15

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
-- 🌐 SERVER LIST
-------------------------------------------------------------------
local function getServerList()
	local servers = {}
	local cursor = ""
	local success, response
	repeat
		success, response = pcall(function()
			return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"..(cursor ~= "" and "&cursor="..cursor or "")))
		end)
		if success and response and response.data then
			for _, server in pairs(response.data) do
				if type(server.playing) == "number" and type(server.maxPlayers) == "number" and server.playing < server.maxPlayers and server.id ~= game.JobId then
					table.insert(servers, server)
				end
			end
			cursor = response.nextPageCursor or ""
		else
			break
		end
		task.wait(1.5)
	until cursor == "" or not success
	table.sort(servers, function(a,b)
		return (a.maxPlayers - a.playing) > (b.maxPlayers - b.playing)
	end)
	return servers
end

-------------------------------------------------------------------
-- 💬 GUI PANEL
-------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SystemStatus_Panel"
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0,280,0,180)
Frame.Position = UDim2.new(1,-300,1,150)
Frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
Frame.BorderSizePixel = 0
Frame.BackgroundTransparency = 0.1
Frame.ZIndex = 10

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0,14)
UICorner.Parent = Frame

local Stroke = Instance.new("UIStroke")
Stroke.Parent = Frame
Stroke.Thickness = 2
Stroke.Color = Color3.fromRGB(0,180,80)

local function createLabel(text,posY,sizeZ,color)
	local lbl = Instance.new("TextLabel")
	lbl.Parent = Frame
	lbl.Size = UDim2.new(1,0,0,22)
	lbl.Position = UDim2.new(0,0,0,posY)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = sizeZ
	lbl.TextColor3 = color
	lbl.ZIndex = 11
	return lbl
end

local Title = createLabel("🟢 Anti AFK aktif!",8,20,Color3.fromRGB(255,255,255))
local Sub1 = createLabel("💨 Anti Lag aktif!",35,18,Color3.fromRGB(255,255,255))
local RejoinLabel = createLabel("⏳ Server durumu hazırlanıyor...",60,17,Color3.fromRGB(255,215,0))
local fpsLabel = createLabel("FPS: -- | Ping: --",115,16,Color3.fromRGB(255,255,255))

local NewServerButton = Instance.new("TextButton")
NewServerButton.Parent = Frame
NewServerButton.Size = UDim2.new(1,-20,0,30)
NewServerButton.Position = UDim2.new(0,10,0,140)
NewServerButton.BackgroundColor3 = Color3.fromRGB(0,180,80)
NewServerButton.Text = "🚀 Yeni Servera Git"
NewServerButton.TextColor3 = Color3.new(1,1,1)
NewServerButton.Font = Enum.Font.GothamBold
NewServerButton.TextSize = 18
local UICorner2 = Instance.new("UICorner")
UICorner2.Parent = NewServerButton

local Credit = Instance.new("TextLabel")
Credit.Parent = Frame
Credit.Size = UDim2.new(1,-10,0,15)
Credit.Position = UDim2.new(0,5,1,-20)
Credit.BackgroundTransparency = 1
Credit.Text = "by NQHSAN ✨"
Credit.Font = Enum.Font.Gotham
Credit.TextSize = 12
Credit.TextColor3 = Color3.fromRGB(200,200,200)
Credit.TextXAlignment = Enum.TextXAlignment.Left
Credit.ZIndex = 11

TweenService:Create(Frame,TweenInfo.new(1.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
	Position = UDim2.new(1,-300,1,-150)
}):Play()

-------------------------------------------------------------------
-- 🪣 AUTO RESET (Bag Full)
-------------------------------------------------------------------
local function getCharacter() return Player.Character or Player.CharacterAdded:Wait() end
local function getHRP() return getCharacter():WaitForChild("HumanoidRootPart") end
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
-- ⏱️ TELEPORT BUTONU + SÜRE GÖSTERGESİ
-------------------------------------------------------------------
local lastTeleport = 0

task.spawn(function()
	while true do
		local remaining = math.max(0, TELEPORT_INTERVAL - (tick() - lastTeleport))
		if remaining > 0 then
			NewServerButton.Text = "⏱️ Bekle: "..math.floor(remaining).."s"
			NewServerButton.BackgroundColor3 = Color3.fromRGB(255,165,0)
		else
			NewServerButton.Text = "🚀 Yeni Servera Git"
			NewServerButton.BackgroundColor3 = Color3.fromRGB(0,180,80)
		end
		task.wait(0.5)
	end
end)

NewServerButton.MouseButton1Click:Connect(function()
	if tick() - lastTeleport < TELEPORT_INTERVAL then return end
	lastTeleport = tick()
	NewServerButton.Text = "🔍 Server aranıyor..."
	NewServerButton.BackgroundColor3 = Color3.fromRGB(255,165,0)

	local servers = getServerList()
	local triedServers = {}
	while #servers > 0 do
		local newServer = servers[1]
		table.remove(servers,1)
		if not triedServers[newServer.id] then
			local success = pcall(function()
				TeleportService:TeleportToPlaceInstance(game.PlaceId,newServer.id,Player)
			end)
			if success then return end
			triedServers[newServer.id] = true
		end
		task.wait(1)
	end
	NewServerButton.Text = "❌ Uygun server yok!"
	NewServerButton.BackgroundColor3 = Color3.fromRGB(200,50,50)
	task.wait(2)
	NewServerButton.Text = "🚀 Yeni Servera Git"
	NewServerButton.BackgroundColor3 = Color3.fromRGB(0,180,80)
end)

-------------------------------------------------------------------
-- ⏱️ FPS + PING GÖSTERGESİ
-------------------------------------------------------------------
local lastTime = tick()
task.spawn(function()
	while true do
		local now = tick()
		local fps = math.floor(1 / math.max(0.001, now - lastTime))
		lastTime = now
		local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
		fpsLabel.Text = string.format("FPS: %d | Ping: %d ms", fps, ping)
		task.wait(2.5)
	end
end)

-------------------------------------------------------------------
-- ⏱️ LAG ALGILAMA & LOW PING SERVER
-------------------------------------------------------------------
local lagCounter = 0
local lagStartTime = nil
local lastFrame = tick()

local function rejoinToLowPingServer()
	local servers = getServerList()
	if #servers > 0 then
		local newServer = servers[1]
		TeleportService:TeleportToPlaceInstance(game.PlaceId,newServer.id,Player)
	else
		TeleportService:Teleport(game.PlaceId,Player)
	end
end

RunService.Heartbeat:Connect(function()
	local now = tick()
	local fps = 1 / math.max(0.001, now - lastFrame)
	lastFrame = now

	if fps < LAG_FPS then
		if not lagStartTime then lagStartTime = now end
		lagCounter = now - lagStartTime
		RejoinLabel.Text = string.format("⚠️ Düşük FPS! %.0f sn lag...", lagCounter)
	else
		lagCounter = 0
		lagStartTime = nil
	end

	if lagCounter >= LAG_TIME then
		RejoinLabel.Text = "⚠️ yeni server aranıyor..."
		task.wait(2)
		rejoinToLowPingServer()
	end
end)
