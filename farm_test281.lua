-------------------------------------------------------------------
-- 🍬 FULL SYSTEM BY NQHSAN (Updated GUI + Auto Button Rejoin)
-- AUTO RESET + ANTI AFK + ANTI LAG + AUTO LOAD + NEW SERVER + LOW PING SWITCH
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

local autoResetEnabled = true
local resetting = false
local bag_full = false
local REJOIN_INTERVAL = 140000 --  ~140 sn örnek
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
-- 🌐 SERVER LIST (LOW PING)
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
		task.wait(1)
	until cursor == "" or not success
	table.sort(servers, function(a,b)
		return (a.maxPlayers - a.playing) > (b.maxPlayers - b.playing)
	end)
	return servers
end

-------------------------------------------------------------------
-- 💬 GUI PANEL (YENİ DÜZEN)
-------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SystemStatus_Panel"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0,270,0,180)
Frame.Position = UDim2.new(1,-290,1,200)
Frame.BackgroundColor3 = Color3.fromRGB(45,45,45)
Frame.BorderSizePixel = 0
Frame.BackgroundTransparency = 0.15
Frame.ZIndex = 10

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0,12)
UICorner.Parent = Frame

local Stroke = Instance.new("UIStroke")
Stroke.Parent = Frame
Stroke.Thickness = 2
Stroke.Color = Color3.fromRGB(0,200,0)

-- Başlık
local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.Size = UDim2.new(1,0,0,30)
Title.Position = UDim2.new(0,0,0,5)
Title.BackgroundTransparency = 1
Title.Text = "🍬 NQHSAN SYSTEM"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 21
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.ZIndex = 11

-- Bilgi satırları
local Info1 = Instance.new("TextLabel")
Info1.Parent = Frame
Info1.Size = UDim2.new(1,0,0,22)
Info1.Position = UDim2.new(0,0,0,40)
Info1.BackgroundTransparency = 1
Info1.Text = "💤 Anti AFK aktif"
Info1.Font = Enum.Font.SourceSansBold
Info1.TextSize = 17
Info1.TextColor3 = Color3.fromRGB(255,255,255)
Info1.ZIndex = 11

local Info2 = Instance.new("TextLabel")
Info2.Parent = Frame
Info2.Size = UDim2.new(1,0,0,22)
Info2.Position = UDim2.new(0,0,0,62)
Info2.BackgroundTransparency = 1
Info2.Text = "💨 Optimize aktif"
Info2.Font = Enum.Font.SourceSansBold
Info2.TextSize = 17
Info2.TextColor3 = Color3.fromRGB(255,255,255)
Info2.ZIndex = 11

local RejoinLabel = Instance.new("TextLabel")
RejoinLabel.Parent = Frame
RejoinLabel.Size = UDim2.new(1,0,0,22)
RejoinLabel.Position = UDim2.new(0,0,0,84)
RejoinLabel.BackgroundTransparency = 1
RejoinLabel.Text = "⏳ Server değişimi: hazırlanıyor..."
RejoinLabel.Font = Enum.Font.SourceSansBold
RejoinLabel.TextSize = 16
RejoinLabel.TextColor3 = Color3.fromRGB(255,215,0)
RejoinLabel.ZIndex = 11

local NewServerButton = Instance.new("TextButton")
NewServerButton.Parent = Frame
NewServerButton.Size = UDim2.new(1,-20,0,35)
NewServerButton.Position = UDim2.new(0,10,0,110)
NewServerButton.BackgroundColor3 = Color3.fromRGB(0,150,50)
NewServerButton.Text = "🚀 Yeni Servera Git"
NewServerButton.TextColor3 = Color3.new(1,1,1)
NewServerButton.Font = Enum.Font.SourceSansBold
NewServerButton.TextSize = 18
NewServerButton.ZIndex = 11

local UICorner2 = Instance.new("UICorner")
UICorner2.Parent = NewServerButton

local Credit = Instance.new("TextLabel")
Credit.Parent = Frame
Credit.Size = UDim2.new(1,0,0,15)
Credit.Position = UDim2.new(0,0,1,-20)
Credit.BackgroundTransparency = 1
Credit.Text = "by NQHSAN ✨"
Credit.Font = Enum.Font.SourceSansItalic
Credit.TextSize = 11
Credit.TextColor3 = Color3.fromRGB(200,200,200)
Credit.TextXAlignment = Enum.TextXAlignment.Center
Credit.ZIndex = 11

TweenService:Create(Frame,TweenInfo.new(1.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
	Position = UDim2.new(1,-290,1,-160)
}):Play()

-------------------------------------------------------------------
-- 🛰️ Yeni Servera Git Butonu
-------------------------------------------------------------------
NewServerButton.MouseButton1Click:Connect(function()
	NewServerButton.Text = "🔍 Server aranıyor..."
	NewServerButton.BackgroundColor3 = Color3.fromRGB(255,165,0)
	local servers = getServerList()
	if #servers > 0 then
		local newServer = servers[1]
		NewServerButton.Text = "🚀 Yeni sunucu bulundu!"
		task.wait(1)
		TeleportService:TeleportToPlaceInstance(game.PlaceId,newServer.id,Player)
	else
		NewServerButton.Text = "❌ Uygun server yok!"
		NewServerButton.BackgroundColor3 = Color3.fromRGB(200,50,50)
		task.wait(2)
		NewServerButton.BackgroundColor3 = Color3.fromRGB(0,150,50)
		NewServerButton.Text = "🚀 Yeni Servera Git"
	end
end)

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
-- ⏱️ ZAMANLAYICI (rejoin yerine butona tıklasın)
-------------------------------------------------------------------
task.spawn(function()
	local remaining = REJOIN_INTERVAL
	while remaining > 0 do
		local h = math.floor(remaining/3600)
		local m = math.floor((remaining%3600)/60)
		local s = remaining % 60
		RejoinLabel.Text = string.format("⏳ Server değişimi: %02dh %02dm %02ds", h, m, s)
		task.wait(1)
		remaining -= 1
	end
	RejoinLabel.Text = "🚀 Süre doldu! Yeni servera geçiliyor..."
	task.wait(1)
	NewServerButton:Activate()
end)

-------------------------------------------------------------------
-- ⚙️ LAG KONTROL (FPS düşükse buton tıklasın)
-------------------------------------------------------------------
local lagCounter = 0
local lastFrame = tick()
local lagStartTime = nil

RunService.Heartbeat:Connect(function()
	local now = tick()
	local fps = 1 / (now - lastFrame)
	lastFrame = now

	if fps < LAG_FPS then
		if not lagStartTime then lagStartTime = now end
		lagCounter = now - lagStartTime
		RejoinLabel.Text = string.format("⚠️ FPS düşük (%.0f sn)...", lagCounter)
	else
		lagCounter = 0
		lagStartTime = nil
	end

	if lagCounter >= LAG_TIME then
		RejoinLabel.Text = "⚠️ Uzun lag! Yeni server aranıyor..."
		task.wait(1)
		NewServerButton:Activate()
	end
end)
