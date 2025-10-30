-------------------------------------------------------------------
-- 🍬 FULL SYSTEM BY NQHSAN
-- AUTO RESET + ANTI AFK + ANTI LAG + AUTO REJOIN + AUTO LOAD + PING/FPS + KALICI TOPLAM
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
local LAG_THRESHOLD = 15
local LAG_DURATION = 300
local PING_THRESHOLD = 200 -- ms

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
-- 🪣 KALICI TOPLAM DOSYASI
-------------------------------------------------------------------
local saveFile = "NQHSAN_ItemCounts.txt"
local collectedItems = 0

-- Dosyayı oku
if isfile and isfile(saveFile) then
	local content = readfile(saveFile)
	collectedItems = tonumber(content) or 0
end

local function saveCollected()
	if writefile then
		writefile(saveFile, tostring(collectedItems))
	end
end

-------------------------------------------------------------------
-- 💬 GUI PANEL
-------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SystemStatus_Panel"
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 300, 0, 150)
Frame.Position = UDim2.new(1,-320,1,160)
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

local function createLabel(parent, posY, text, textColor, size)
	local lbl = Instance.new("TextLabel")
	lbl.Parent = parent
	lbl.Size = UDim2.new(1,0,0,size or 22)
	lbl.Position = UDim2.new(0,0,0,posY)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.Font = Enum.Font.SourceSansBold
	lbl.TextSize = 18
	lbl.TextColor3 = textColor
	lbl.ZIndex = 11
	return lbl
end

local Title = createLabel(Frame,8,"Anti AFK: Açık",Color3.fromRGB(255,255,255),22)
local Sub1 = createLabel(Frame,35,"Anti Lag: Aktif",Color3.fromRGB(255,255,255),18)
local CollectedLabel = createLabel(Frame,62,"Toplanan: "..collectedItems,Color3.fromRGB(255,255,0),18)
local FPSLabel = createLabel(Frame,90,"FPS: 0",Color3.fromRGB(0,255,255),18)
local PingLabel = createLabel(Frame,115,"Ping: 0ms",Color3.fromRGB(0,255,255),18)

-- Sıfırla butonu
local ResetBtn = Instance.new("TextButton")
ResetBtn.Parent = Frame
ResetBtn.Size = UDim2.new(0,70,0,20)
ResetBtn.Position = UDim2.new(1,-75,0,125)
ResetBtn.Text = "Sıfırla"
ResetBtn.Font = Enum.Font.SourceSansBold
ResetBtn.TextSize = 14
ResetBtn.TextColor3 = Color3.fromRGB(255,255,255)
ResetBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
ResetBtn.ZIndex = 11
ResetBtn.AutoButtonColor = true
ResetBtn.MouseButton1Click:Connect(function()
	collectedItems = 0
	saveCollected()
	CollectedLabel.Text = "Toplanan: "..collectedItems
end)

-- GUI Animasyon
TweenService:Create(Frame,TweenInfo.new(1.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
	Position = UDim2.new(1,-320,1,-160),
	Rotation = 0
}):Play()

-- GUI sürüklenebilirlik
local dragging, dragInput, mousePos, framePos = false,nil,nil,nil
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
	-- Toplananları güncelle
	collectedItems = collectedItems + current
	CollectedLabel.Text = "Toplanan: "..collectedItems
	saveCollected()
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
task.spawn(function()
	local remaining = REJOIN_INTERVAL
	while remaining > 0 do
		local hours = math.floor(remaining/3600)
		local minutes = math.floor((remaining%3600)/60)
		local seconds = remaining % 60
		-- FPS ve Ping göstergesi
		local ping = math.floor(Player:GetNetworkPing()*1000)
		PingLabel.Text = "Ping: "..ping.."ms"
		FPSLabel.Text = "FPS: "..math.floor(1/(RunService.RenderStepped:Wait() or 0)) 
		task.wait(1)
		remaining -= 1
	end
	-- Rejoin
	task.wait(2)
	pcall(function()
		TeleportService:TeleportToPlaceInstance(game.PlaceId, nil, Player)
	end)
end)

-------------------------------------------------------------------
-- ⚠️ AŞIRI LAG / YÜKSEK PING REJOIN
-------------------------------------------------------------------
local lagCounter = 0
RunService.Heartbeat:Connect(function(dt)
	local fps = 1/dt
	FPSLabel.Text = "FPS: "..math.floor(fps)
	local ping = math.floor(Player:GetNetworkPing()*1000)
	PingLabel.Text = "Ping: "..ping.."ms"

	if fps < LAG_THRESHOLD or ping > PING_THRESHOLD then
		lagCounter = lagCounter + dt
	else
		lagCounter = 0
	end

	if lagCounter >= LAG_DURATION then
		CollectedLabel.Text = "⚠️ Aşırı lag, yeni servera geçiliyor..."
		task.wait(2)
		-- Yeni servera teleport
		local success, servers = pcall(function()
			return game:GetService("TeleportService"):GetServersAsync(game.PlaceId)
		end)
		if success and servers then
			for _, s in pairs(servers) do
				if s.playing < s.maxPlayers then
					TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, Player)
					break
				end
			end
		else
			TeleportService:Teleport(game.PlaceId, Player)
		end
	end
end)
