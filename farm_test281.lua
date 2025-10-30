-------------------------------------------------------------------
-- 🍬 FULL SYSTEM BY NQHSAN
-- AUTO RESET + ANTI AFK + ANTI LAG + AUTO REJOIN + AUTO LOAD + NEW SERVER (PING BASED)
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
local NetworkClient = game:GetService("NetworkClient")

local autoResetEnabled = true
local resetting = false
local bag_full = false
local REJOIN_INTERVAL = 7200 -- 2 saat
local MAX_PING = 150 -- ms, üstünde server değiştir
local LAG_THRESHOLD = 15 -- FPS
local LAG_DURATION = 300 -- saniye (5 dakika)

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
Frame.Size = UDim2.new(0,270,0,160)
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

local function createLabel(parent,text,posY,color,size,emoji)
	local lbl = Instance.new("TextLabel")
	lbl.Parent = parent
	lbl.Size = UDim2.new(1,0,0,22)
	lbl.Position = UDim2.new(0,0,0,posY)
	lbl.BackgroundTransparency = 1
	lbl.Text = (emoji or "").." "..text
	lbl.Font = Enum.Font.SourceSansBold
	lbl.TextSize = size
	lbl.TextColor3 = color
	lbl.ZIndex = 11
	return lbl
end

local Title = createLabel(Frame,"Anti AFK açık!",8,Color3.fromRGB(255,255,255),20,"🟢")
local Sub1 = createLabel(Frame,"Anti Lag aktif!",35,Color3.fromRGB(255,255,255),18,"💨")
local RejoinLabel = createLabel(Frame,"Rejoin: hazırlanıyor...",60,Color3.fromRGB(255,215,0),17,"⏳")

local NewServerButton = Instance.new("TextButton")
NewServerButton.Parent = Frame
NewServerButton.Size = UDim2.new(1, -20, 0, 25)
NewServerButton.Position = UDim2.new(0,10,0,90)
NewServerButton.BackgroundColor3 = Color3.fromRGB(80,80,80)
NewServerButton.Text = "Yeni Sunucuya Geç"
NewServerButton.Font = Enum.Font.SourceSansBold
NewServerButton.TextSize = 16
NewServerButton.TextColor3 = Color3.fromRGB(255,255,255)
NewServerButton.ZIndex = 11
local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0,8)
BtnCorner.Parent = NewServerButton

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
-- ⏱️ REJOIN GERİ SAYIM + TELEPORT
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
	pcall(function()
		TeleportService:Teleport(game.PlaceId, Player)
	end)
end)

-------------------------------------------------------------------
-- 🌐 YENİ SUNUCUYA GEÇ BUTONU
-------------------------------------------------------------------
local function goToNewServer()
	RejoinLabel.Text = "🌐 Yeni sunucu aranıyor..."
	task.wait(1)
	local PlaceID = game.PlaceId
	local success, response = pcall(function()
		return game:HttpGet("https://games.roblox.com/v1/games/"..PlaceID.."/servers/Public?sortOrder=Asc&limit=100")
	end)
	if success then
		local data = HttpService:JSONDecode(response)
		local servers = data.data
