-------------------------------------------------------------------
-- 🌐 FPS & PING DISPLAY
-------------------------------------------------------------------
local FpsLabel = Instance.new("TextLabel")
FpsLabel.Parent = Frame
FpsLabel.Size = UDim2.new(1, 0, 0, 20)
FpsLabel.Position = UDim2.new(0, 10, 0, 115)
FpsLabel.BackgroundTransparency = 1
FpsLabel.Font = Enum.Font.SourceSansBold
FpsLabel.TextSize = 16
FpsLabel.TextColor3 = Color3.fromRGB(0,255,200)
FpsLabel.Text = "FPS: hesaplanıyor..."
FpsLabel.ZIndex = 11

local PingLabel = Instance.new("TextLabel")
PingLabel.Parent = Frame
PingLabel.Size = UDim2.new(1, 0, 0, 20)
PingLabel.Position = UDim2.new(0, 10, 0, 135)
PingLabel.BackgroundTransparency = 1
PingLabel.Font = Enum.Font.SourceSansBold
PingLabel.TextSize = 16
PingLabel.TextColor3 = Color3.fromRGB(255,255,0)
PingLabel.Text = "Ping: hesaplanıyor..."
PingLabel.ZIndex = 11

-- FPS & Ping Yavaş Güncelleme
task.spawn(function()
	local frameTime = tick()
	local lastFpsCheck = tick()
	local updateDelay = 0.5 -- 0.5 saniyede bir güncelle
	while true do
		task.wait(updateDelay)
		-- FPS hesapla
		local now = tick()
		local dt = now - frameTime
		frameTime = now
		local fps = math.floor(1/dt)
		FpsLabel.Text = "FPS: "..fps

		-- Ping hesapla
		local ping = math.floor(Player:GetNetworkPing() * 1000) -- saniyeyi ms çevir
		PingLabel.Text = "Ping: "..ping.." ms"
	end
end)
