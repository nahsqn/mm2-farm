-------------------------------------------------------------------
-- 🍬 FULL SYSTEM BY NQHSAN (DÜZENLENMİŞ)
-- AUTO RESET + ANTI AFK + ANTI LAG + YENİ SERVER + AUTO LOAD + LOW PING SWITCH + FPS/PING
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
local UserInputService = game:GetService("UserInputService")

local autoResetEnabled = true
local resetting = false
local bag_full = false
local REJOIN_INTERVAL = 140000
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
Frame.Size = UDim2.new(0,270,0,160)
Frame.Position = UDim2.new(1,-290,1,140)
Frame.BackgroundColor3 = Color3.fromRGB(50,50,50)
Frame.BorderSizePixel = 0
Frame.BackgroundTransparency = 0.15
Frame.ZIndex = 10

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0,12)
UICorner.Parent = Frame

local Stroke = Instance.new("UIStroke")
Stroke.Parent = Frame
Stroke.Thickness = 2
Stroke.Color = Color3.fromRGB(0,150,50)

local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.Size = UDim2.new(1,0,0,25)
Title.Position = UDim2.new(0,0,0,8)
Title.BackgroundTransparency = 1
Title.Text = "🟢 Anti AFK açık!"
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

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Parent = Frame
fpsLabel.Size = UDim2.new(1,0,0,22)
fpsLabel.Position = UDim2.new(0,0,0,115)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: -- | Ping: --"
fpsLabel.Font = Enum.Font.SourceSansBold
fpsLabel.TextSize = 16
fpsLabel.TextColor3 = Color3.fromRGB(255,255,255)
fpsLabel.ZIndex = 11

local NewServerButton = Instance.new("TextButton")
NewServerButton.Parent = Frame
NewServerButton.Size = UDim2.new(1,-20,0,30)
NewServerButton.Position = UDim2.new(0,10,0,90)
NewServerButton.BackgroundColor3 = Color3.fromRGB(0,150,50)
NewServerButton.Text = "🚀 Yeni Servera Git"
NewServerButton.TextColor3 = Color3.new(1,1,1)
NewServerButton.Font = Enum.Font.SourceSansBold
NewServerButton.TextSize = 18

local UICorner2 = Instance.new("UICorner")
UICorner2.Parent = NewServerButton

local Credit = Instance.new("TextLabel")
Credit.Parent = Frame
Credit.Size = UDim2.new(1,-10,0,15)
Credit.Position = UDim2.new(0,5,1,-20)
Credit.BackgroundTransparency = 1
Credit.Text = "by NQHSAN ✨"
Credit.Font = Enum.Font.SourceSansItalic
Credit.TextSize = 11
Credit.TextColor3 = Color3.fromRGB(200,200,200)
Credit.TextXAlignment = Enum.TextXAlignment.Left
Credit.ZIndex = 11

TweenService:Create(Frame,TweenInfo.new(1.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
	Position = UDim2.new(1,-290,1,-140)
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
-- ⏱️ YENİ SERVER BUTONU & REJOIN YENİ SERVER
-------------------------------------------------------------------
NewServerButton.MouseButton1Click:Connect(function()
    NewServerButton.Text = "🔍 Server aranıyor..."
    NewServerButton.BackgroundColor3 = Color3.fromRGB(255,165,0)
    
    local servers = getServerList()
    local triedServers = {}
    while #servers > 0 do
        local newServer = servers[1]
        table.remove(servers, 1)
        if not triedServers[newServer.id] then
            local success, err = pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, newServer.id, Player)
            end)
            if success then return end
            triedServers[newServer.id] = true
        end
        task.wait(1)
    end
    
    NewServerButton.Text = "❌ Uygun server yok!"
    NewServerButton.BackgroundColor3 = Color3.fromRGB(200,50,50)
    task.wait(2)
    NewServerButton.BackgroundColor3 = Color3.fromRGB(0,150,50)
    NewServerButton.Text = "🚀 Yeni Servera Git"
end)

-------------------------------------------------------------------
-- ⏱️ FPS + PING GÖSTERGESİ
-------------------------------------------------------------------
task.spawn(function()
    local lastTime = tick()
    while true do
        local now = tick()
        local fps = math.floor(1 / (now - lastTime))
        lastTime = now
        local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        fpsLabel.Text = string.format("FPS: %d | Ping: %d ms", fps, ping)
        task.wait(2.5)
    end
end)

-------------------------------------------------------------------
-- ⏱️ LAG ALGILAMA & LOW PING SERVER GEÇİŞ
-------------------------------------------------------------------
local lagCounter = 0
local lastFrame = tick()
local lagStartTime = nil

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
	local fps = 1 / (now - lastFrame)
	lastFrame = now

	if fps < LAG_FPS then
		if not lagStartTime then lagStartTime = now end
		lagCounter = now - lagStartTime
		RejoinLabel.Text = string.format("⚠️ Düşük FPS tespit edildi! %.0f saniye lag devam ediyor...", lagCounter)
	else
		lagCounter = 0
		lagStartTime = nil
	end

	if lagCounter >= LAG_TIME then
		RejoinLabel.Text = "⚠️ yeni sunucu aranıyor..."
		task.wait(2)
		rejoinToLowPingServer()
	end
end)
