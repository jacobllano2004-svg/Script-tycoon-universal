-- =====================================================================
-- MANTENIMIENTO - MEGA HUB UNIVERSAL DE TYCOONS
-- =====================================================================
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("HubMaintenanceGui") then
	playerGui["HubMaintenanceGui"]:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HubMaintenanceGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 160)
frame.Position = UDim2.new(0.5, -160, 0.5, -80)
frame.BackgroundColor3 = Color3.fromRGB(180, 30, 30) -- Color rojo
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 15)
title.BackgroundTransparency = 1
title.Text = "¡EN MANTENIMIENTO!"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = frame

local desc = Instance.new("TextLabel")
desc.Size = UDim2.new(1, -20, 0, 80)
desc.Position = UDim2.new(0, 10, 0, 55)
desc.BackgroundTransparency = 1
desc.Text = "El script se encuentra en mantenimiento temporal para añadir el sistema de keys. Volveremos a abrir muy pronto.\n\nEste aviso se cerrará en 10 segundos..."
desc.TextColor3 = Color3.fromRGB(240, 240, 240)
desc.Font = Enum.Font.SourceSans
desc.TextSize = 13
desc.TextWrapped = true
desc.Parent = frame

-- Esperar 10 segundos y destruir el aviso
task.delay(10, function()
	if screenGui then
		screenGui:Destroy()
	end
end)
