-- LocalScript para Roblox (mega hub universal de tycoons (by jacoboeu8))
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

player.CharacterAdded:Connect(function(newChar)
	character = newChar
	hrp = character:WaitForChild("HumanoidRootPart")
	humanoid = character:WaitForChild("Humanoid")
end)

-- DETECCIÓN DE EJECUTOR
local function getExecutorName()
	if identifyexecutor then
		local name, _ = identifyexecutor()
		return name or "Delta"
	elseif getexecutorname then
		return getexecutorname() or "Delta"
	end
	return "Delta"
end

-- ESTADOS Y VARIABLES
local autoCollectActive = false
local espActive = false
local espNameActive = false
local mainNoclipActive = false
local fullbrightActive = false
local flyActive = false

local walkSpeedValue = 16
local flySpeedValue = 50

local noclipConnection = nil
local flyConnection = nil
local collectorPosition = nil
local basePosition = nil
local tempPlayerPosition = nil

-- VALORES ORIGINALES ILUMINACIÓN
local origBrightness = Lighting.Brightness
local origClockTime = Lighting.ClockTime
local origGlobalShadows = Lighting.GlobalShadows
local origAmbient = Lighting.Ambient

-- NOCLIP
local function enableNoclip()
	if noclipConnection then noclipConnection:Disconnect() end
	noclipConnection = RunService.Stepped:Connect(function()
		if character then
			for _, part in pairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end)
end

local function disableNoclip()
	if noclipConnection then
		noclipConnection:Disconnect()
		noclipConnection = nil
	end
	if character then
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				part.CanCollide = true
			end
		end
	end
end

-- FULLBRIGHT
local function toggleFullbright(state)
	fullbrightActive = state
	if fullbrightActive then
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.GlobalShadows = false
		Lighting.Ambient = Color3.fromRGB(180, 180, 180)
	else
		Lighting.Brightness = origBrightness
		Lighting.ClockTime = origClockTime
		Lighting.GlobalShadows = origGlobalShadows
		Lighting.Ambient = origAmbient
	end
end

-- FLY
local function toggleFly(state)
	flyActive = state
	if flyActive and character and hrp and humanoid then
		local bv = Instance.new("BodyVelocity")
		bv.Name = "FlyBodyVelocity"
		bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
		bv.Velocity = Vector3.zero
		bv.Parent = hrp

		local bg = Instance.new("BodyGyro")
		bg.Name = "FlyBodyGyro"
		bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
		bg.P = 9e4
		bg.CFrame = hrp.CFrame
		bg.Parent = hrp

		humanoid.PlatformStand = true

		flyConnection = RunService.RenderStepped:Connect(function()
			if not flyActive or not hrp or not humanoid then return end
			local moveDir = humanoid.MoveDirection
			bg.CFrame = camera.CFrame

			if moveDir.Magnitude > 0 then
				bv.Velocity = camera.CFrame.LookVector * (moveDir.Z < 0 and flySpeedValue or -flySpeedValue)
			else
				bv.Velocity = Vector3.zero
			end
		end)
	else
		if flyConnection then flyConnection:Disconnect() flyConnection = nil end
		if hrp then
			local bv = hrp:FindFirstChild("FlyBodyVelocity")
			local bg = hrp:FindFirstChild("FlyBodyGyro")
			if bv then bv:Destroy() end
			if bg then bg:Destroy() end
		end
		if humanoid then
			humanoid.PlatformStand = false
		end
	end
end

-- ESP CUERPO AZUL
local function applyESP(targetPlayer)
	if targetPlayer == player then return end
	local function addHighlight(char)
		if not char or char:FindFirstChild("ESPHighlight") then return end
		local highlight = Instance.new("Highlight")
		highlight.Name = "ESPHighlight"
		highlight.Adornee = char
		highlight.FillColor = Color3.fromRGB(0, 120, 255)
		highlight.FillTransparency = 0.4
		highlight.OutlineColor = Color3.fromRGB(150, 220, 255)
		highlight.OutlineTransparency = 0
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Parent = char
	end
	if targetPlayer.Character then addHighlight(targetPlayer.Character) end
	targetPlayer.CharacterAdded:Connect(function(newChar)
		if espActive then task.wait(0.5) addHighlight(newChar) end
	end)
end

local function removeESP(targetPlayer)
	if targetPlayer.Character and targetPlayer.Character:FindFirstChild("ESPHighlight") then
		targetPlayer.Character.ESPHighlight:Destroy()
	end
end

local function toggleESPState(state)
	espActive = state
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player then
			if espActive then applyESP(p) else removeESP(p) end
		end
	end
end

-- ESP NOMBRES
local function applyNameESP(targetPlayer)
	if targetPlayer == player then return end
	local function addBillboard(char)
		if not char or char:FindFirstChild("ESPNameTag") then return end
		local head = char:FindFirstChild("Head")
		if not head then return end

		local bb = Instance.new("BillboardGui")
		bb.Name = "ESPNameTag"
		bb.Adornee = head
		bb.Size = UDim2.new(0, 150, 0, 30)
		bb.StudsOffset = Vector3.new(0, 2.5, 0)
		bb.AlwaysOnTop = true
		bb.Parent = char

		local txt = Instance.new("TextLabel")
		txt.Name = "Label"
		txt.Size = UDim2.new(1, 0, 1, 0)
		txt.BackgroundTransparency = 1
		txt.TextColor3 = Color3.fromRGB(0, 200, 255)
		txt.TextStrokeTransparency = 0
		txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		txt.Font = Enum.Font.SourceSansBold
		txt.TextSize = 13
		txt.Parent = bb
	end
	if targetPlayer.Character then addBillboard(targetPlayer.Character) end
	targetPlayer.CharacterAdded:Connect(function(newChar)
		if espNameActive then task.wait(0.5) addBillboard(newChar) end
	end)
end

local function removeNameESP(targetPlayer)
	if targetPlayer.Character and targetPlayer.Character:FindFirstChild("ESPNameTag") then
		targetPlayer.Character.ESPNameTag:Destroy()
	end
end

local function toggleNameESPState(state)
	espNameActive = state
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player then
			if espNameActive then applyNameESP(p) else removeNameESP(p) end
		end
	end
end

RunService.RenderStepped:Connect(function()
	if espNameActive then
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= player and p.Character then
				local char = p.Character
				local tag = char:FindFirstChild("ESPNameTag")
				local hrpTarget = char:FindFirstChild("HumanoidRootPart")
				if tag and hrpTarget and hrp then
					local dist = math.floor((hrp.Position - hrpTarget.Position).Magnitude)
					tag.Label.Text = p.Name .. " [" .. dist .. "m]"
				end
			end
		end
	end
end)

-- INTERFAZ GRÁFICA (GUI)
local playerGui = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("mega hub universal de tycoons (by jacoboeu8)") then
	playerGui["mega hub universal de tycoons (by jacoboeu8)"]:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "mega hub universal de tycoons (by jacoboeu8)"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 470, 0, 280)
mainFrame.Position = UDim2.new(0.5, -235, 0.4, -140)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 35)
topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "mega hub universal de tycoons (by jacoboeu8)"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 13
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -30, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 14
closeButton.Font = Enum.Font.SourceSansBold
closeButton.Parent = topBar

-- BOTÓN TOGGLE
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 80, 0, 30)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleButton.Text = "Toggle"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 14
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.Visible = false
toggleButton.Active = true
toggleButton.Draggable = true
toggleButton.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = toggleButton

-- WIDGET PING / FPS ESQUINA DERECHA
local statsWidget = Instance.new("Frame")
statsWidget.Name = "StatsWidget"
statsWidget.Size = UDim2.new(0, 80, 0, 30)
statsWidget.Position = UDim2.new(1, -90, 0, 10)
statsWidget.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
statsWidget.BorderSizePixel = 0
statsWidget.Active = true
statsWidget.Draggable = true
statsWidget.Parent = screenGui

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 6)
statsCorner.Parent = statsWidget

local statsText = Instance.new("TextLabel")
statsText.Size = UDim2.new(1, 0, 1, 0)
statsText.BackgroundTransparency = 1
statsText.Text = "Ping: 0ms\nFPS: 60"
statsText.TextColor3 = Color3.fromRGB(0, 200, 255)
statsText.Font = Enum.Font.SourceSansBold
statsText.TextSize = 10
statsText.Parent = statsWidget

-- BARRA LATERAL
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 110, 1, -35)
sidebar.Position = UDim2.new(0, 0, 0, 35)
sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -120, 1, -45)
contentFrame.Position = UDim2.new(0, 115, 0, 40)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- PESTAÑAS
local menuTab = Instance.new("Frame")
menuTab.Size = UDim2.new(1, 0, 1, 0)
menuTab.BackgroundTransparency = 1
menuTab.Visible = true
menuTab.Parent = contentFrame

local mainTab = Instance.new("Frame")
mainTab.Size = UDim2.new(1, 0, 1, 0)
mainTab.BackgroundTransparency = 1
mainTab.Visible = false
mainTab.Parent = contentFrame

local espTab = Instance.new("Frame")
espTab.Size = UDim2.new(1, 0, 1, 0)
espTab.BackgroundTransparency = 1
espTab.Visible = false
espTab.Parent = contentFrame

local tycoonTab = Instance.new("Frame")
tycoonTab.Size = UDim2.new(1, 0, 1, 0)
tycoonTab.BackgroundTransparency = 1
tycoonTab.Visible = false
tycoonTab.Parent = contentFrame

-- === PESTAÑA MENU ===
local profileCard = Instance.new("Frame")
profileCard.Size = UDim2.new(0.95, 0, 0, 75)
profileCard.Position = UDim2.new(0, 0, 0, 5)
profileCard.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
profileCard.BorderSizePixel = 0
profileCard.Parent = menuTab

local avatarImage = Instance.new("ImageLabel")
avatarImage.Size = UDim2.new(0, 60, 0, 60)
avatarImage.Position = UDim2.new(0, 8, 0, 8)
avatarImage.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
avatarImage.BorderSizePixel = 0
avatarImage.Parent = profileCard

task.spawn(function()
	local content, isReady = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	if isReady and content then avatarImage.Image = content end
end)

local welcomeLabel = Instance.new("TextLabel")
welcomeLabel.Size = UDim2.new(1, -80, 0, 25)
welcomeLabel.Position = UDim2.new(0, 75, 0, 12)
welcomeLabel.BackgroundTransparency = 1
welcomeLabel.Text = "Welcome, " .. player.Name
welcomeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
welcomeLabel.Font = Enum.Font.SourceSansBold
welcomeLabel.TextSize = 14
welcomeLabel.TextXAlignment = Enum.TextXAlignment.Left
welcomeLabel.Parent = profileCard

local executorLabel = Instance.new("TextLabel")
executorLabel.Size = UDim2.new(1, -80, 0, 20)
executorLabel.Position = UDim2.new(0, 75, 0, 38)
executorLabel.BackgroundTransparency = 1
executorLabel.Text = "Ejecutor: " .. getExecutorName()
executorLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
executorLabel.Font = Enum.Font.SourceSans
executorLabel.TextSize = 12
executorLabel.TextXAlignment = Enum.TextXAlignment.Left
executorLabel.Parent = profileCard

-- ENLISTADO DE FUNCIONES EN MENU
local featuresFrame = Instance.new("Frame")
featuresFrame.Size = UDim2.new(0.95, 0, 0, 95)
featuresFrame.Position = UDim2.new(0, 0, 0, 85)
featuresFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
featuresFrame.BorderSizePixel = 0
featuresFrame.Parent = menuTab

local featCorner = Instance.new("UICorner")
featCorner.CornerRadius = UDim.new(0, 6)
featCorner.Parent = featuresFrame

local featList = Instance.new("TextLabel")
featList.Size = UDim2.new(1, -10, 1, -10)
featList.Position = UDim2.new(0, 5, 0, 5)
featList.BackgroundTransparency = 1
featList.Text = "• Main: Noclip, Fullbright, WalkSpeed, Fly, FlySpeed\n• ESP: Cuerpo Azul, Nombres y Distancia\n• Tycoon: TP to Tycoon, Guardar Base, Auto Recoger"
featList.TextColor3 = Color3.fromRGB(200, 200, 200)
featList.Font = Enum.Font.SourceSans
featList.TextSize = 11
featList.TextWrapped = true
featList.TextYAlignment = Enum.TextYAlignment.Top
featList.TextXAlignment = Enum.TextXAlignment.Left
featList.Parent = featuresFrame

-- TARJETA DE PING Y FPS EN PESTAÑA MENU
local pingFpsCard = Instance.new("Frame")
pingFpsCard.Size = UDim2.new(0.45, 0, 0, 42)
pingFpsCard.Position = UDim2.new(0, 0, 0, 185)
pingFpsCard.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
pingFpsCard.BorderSizePixel = 0
pingFpsCard.Parent = menuTab

local pfCorner = Instance.new("UICorner")
pfCorner.CornerRadius = UDim.new(0, 6)
pfCorner.Parent = pingFpsCard

local pingFpsLabel = Instance.new("TextLabel")
pingFpsLabel.Size = UDim2.new(1, 0, 1, 0)
pingFpsLabel.BackgroundTransparency = 1
pingFpsLabel.Text = "Ping: 0ms\nFPS: 60"
pingFpsLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
pingFpsLabel.Font = Enum.Font.SourceSansBold
pingFpsLabel.TextSize = 11
pingFpsLabel.Parent = pingFpsCard

-- ACTUALIZADOR DE PING Y FPS EN TIEMPO REAL
local frameCount = 0
local lastTime = os.clock()

RunService.RenderStepped:Connect(function()
	frameCount = frameCount + 1
	local currentTime = os.clock()
	if currentTime - lastTime >= 1 then
		local fps = math.floor(frameCount / (currentTime - lastTime))
		local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
		
		local textString = "Ping: " .. ping .. "ms\nFPS: " .. fps
		pingFpsLabel.Text = textString
		statsText.Text = textString

		frameCount = 0
		lastTime = currentTime
	end
end)

-- === PESTAÑA MAIN (ELEMENTOS) ===
local function createMainToggle(text, posY, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.46, 0, 0, 32)
	btn.Position = UDim2.new(0, 0, 0, posY)
	btn.BackgroundColor3 = color or Color3.fromRGB(200, 40, 40)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 12
	btn.Parent = mainTab

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = btn

	return btn
end

local function createMainInput(labelText, defaultVal, posY)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(0.95, 0, 0, 32)
	container.Position = UDim2.new(0, 0, 0, posY)
	container.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	container.BorderSizePixel = 0
	container.Parent = mainTab

	local cCorner = Instance.new("UICorner")
	cCorner.CornerRadius = UDim.new(0, 6)
	cCorner.Parent = container

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6, 0, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.SourceSansBold
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = container

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0.32, 0, 0.7, 0)
	box.Position = UDim2.new(0.65, 0, 0.15, 0)
	box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	box.Text = tostring(defaultVal)
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.Font = Enum.Font.SourceSansBold
	box.TextSize = 12
	box.Parent = container

	local bCorner = Instance.new("UICorner")
	bCorner.CornerRadius = UDim.new(0, 4)
	bCorner.Parent = box

	return box
end

local noclipMainBtn = createMainToggle("Noclip", 0)
local fullbrightBtn = createMainToggle("Fullbright", 0)
fullbrightBtn.Position = UDim2.new(0.49, 0, 0, 0)

local walkSpeedBox = createMainInput("WalkSpeed (1-200):", walkSpeedValue, 38)
local flyBtn = createMainToggle("Fly", 76)
flyBtn.Size = UDim2.new(0.95, 0, 0, 32)

local flySpeedBox = createMainInput("Fly Speed (1-200):", flySpeedValue, 114)

noclipMainBtn.MouseButton1Click:Connect(function()
	mainNoclipActive = not mainNoclipActive
	if mainNoclipActive then
		noclipMainBtn.BackgroundColor3 = Color3.fromRGB(40, 200, 40)
		enableNoclip()
	else
		noclipMainBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
		if not autoCollectActive then disableNoclip() end
	end
end)

fullbrightBtn.MouseButton1Click:Connect(function()
	toggleFullbright(not fullbrightActive)
	fullbrightBtn.BackgroundColor3 = fullbrightActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
end)

walkSpeedBox.FocusLost:Connect(function()
	local num = tonumber(walkSpeedBox.Text)
	if num then
		walkSpeedValue = math.clamp(num, 1, 200)
		walkSpeedBox.Text = tostring(walkSpeedValue)
		if humanoid then humanoid.WalkSpeed = walkSpeedValue end
	else
		walkSpeedBox.Text = tostring(walkSpeedValue)
	end
end)

flyBtn.MouseButton1Click:Connect(function()
	toggleFly(not flyActive)
	flyBtn.BackgroundColor3 = flyActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
end)

flySpeedBox.FocusLost:Connect(function()
	local num = tonumber(flySpeedBox.Text)
	if num then
		flySpeedValue = math.clamp(num, 1, 200)
		flySpeedBox.Text = tostring(flySpeedValue)
	else
		flySpeedBox.Text = tostring(flySpeedValue)
	end
end)

-- NAV BUTTONS
local function createNavBtn(text, posY)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 100, 0, 32)
	btn.Position = UDim2.new(0, 5, 0, posY)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 14
	btn.Parent = sidebar
	return btn
end

local menuBtn = createNavBtn("Menu", 10)
local mainBtn = createNavBtn("Main", 47)
local espBtn = createNavBtn("ESP", 84)
local tycoonBtn = createNavBtn("Tycoon", 121)

local function switchTab(tabToShow, activeBtn)
	menuTab.Visible = false
	mainTab.Visible = false
	espTab.Visible = false
	tycoonTab.Visible = false

	menuBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	mainBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	espBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	tycoonBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

	tabToShow.Visible = true
	activeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
end

menuBtn.MouseButton1Click:Connect(function() switchTab(menuTab, menuBtn) end)
mainBtn.MouseButton1Click:Connect(function() switchTab(mainTab, mainBtn) end)
espBtn.MouseButton1Click:Connect(function() switchTab(espTab, espBtn) end)
tycoonBtn.MouseButton1Click:Connect(function() switchTab(tycoonTab, tycoonBtn) end)

switchTab(menuTab, menuBtn)

-- BOTONES ESP
local function createEspButton(text, posY, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.95, 0, 0, 38)
	btn.Position = UDim2.new(0, 0, 0, posY)
	btn.BackgroundColor3 = color or Color3.fromRGB(200, 40, 40)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 13
	btn.Parent = espTab
	return btn
end

local espPlayerBtn = createEspButton("ESP Cuerpo Azul (Chams)", 0)
local espNameBtn = createEspButton("ESP Nombres y Distancia", 46)

espPlayerBtn.MouseButton1Click:Connect(function()
	local newState = not espActive
	toggleESPState(newState)
	espPlayerBtn.BackgroundColor3 = newState and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
end)

espNameBtn.MouseButton1Click:Connect(function()
	local newState = not espNameActive
	toggleNameESPState(newState)
	espNameBtn.BackgroundColor3 = newState and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
end)

-- BOTONES TYCOON
local function createTycoonBtn(text, posY, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.95, 0, 0, 38)
	btn.Position = UDim2.new(0, 0, 0, posY)
	btn.BackgroundColor3 = color or Color3.fromRGB(60, 60, 60)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 12
	btn.TextWrapped = true
	btn.Parent = tycoonTab
	return btn
end

local tpTycoonBtn = createTycoonBtn("TP to Tycoon", 0)
local saveBaseBtn = createTycoonBtn("guardar posicion de la base", 44)
local collectButton = createTycoonBtn("auto recoger dinero", 88, Color3.fromRGB(200, 40, 40))
local saveCollectorBtn = createTycoonBtn("guardar posicion del recolector de dinero", 132)

-- RECOLECCIÓN
local function performCollect()
	if not autoCollectActive or not character or not hrp or not collectorPosition then return end

	tempPlayerPosition = hrp.CFrame
	enableNoclip()

	hrp.CFrame = collectorPosition
	disableNoclip()
	
	hrp.Velocity = Vector3.new(0, -10, 0)
	task.wait(1)

	enableNoclip()

	if tempPlayerPosition then
		hrp.CFrame = tempPlayerPosition
	end

	disableNoclip()
	tempPlayerPosition = nil
end

local function collectMoneyRoutine()
	performCollect()
	while autoCollectActive do
		task.wait(3)
		if autoCollectActive then
			performCollect()
		end
	end
end

tpTycoonBtn.MouseButton1Click:Connect(function()
	if not basePosition then
		tpTycoonBtn.Text = "¡Primero guarda la posición de la base abajo!"
		task.wait(1.5)
		tpTycoonBtn.Text = "TP to Tycoon"
		return
	end

	if hrp then
		enableNoclip()
		hrp.CFrame = basePosition
		disableNoclip()
	end
end)

saveBaseBtn.MouseButton1Click:Connect(function()
	if hrp then
		basePosition = hrp.CFrame
		saveBaseBtn.Text = "¡Posición de la Base Guardada!"
		saveBaseBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
		task.wait(1)
		saveBaseBtn.Text = "guardar posicion de la base"
		saveBaseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	end
end)

saveCollectorBtn.MouseButton1Click:Connect(function()
	if hrp then
		collectorPosition = hrp.CFrame + Vector3.new(0, 0.5, 0)
		saveCollectorBtn.Text = "¡Posición del Recolector Guardada!"
		saveCollectorBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
		task.wait(1)
		saveCollectorBtn.Text = "guardar posicion del recolector de dinero"
		saveCollectorBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	end
end)

collectButton.MouseButton1Click:Connect(function()
	if not collectorPosition and not autoCollectActive then
		collectButton.Text = "¡Primero guarda la posición del recolector!"
		task.wait(1.5)
		collectButton.Text = "auto recoger dinero"
		return
	end

	autoCollectActive = not autoCollectActive
	if autoCollectActive then
		collectButton.BackgroundColor3 = Color3.fromRGB(40, 200, 40)
		task.spawn(collectMoneyRoutine)
	else
		collectButton.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
		disableNoclip()
	end
end)

-- ABRIR / CERRAR
closeButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	toggleButton.Visible = true
end)

toggleButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = true
	toggleButton.Visible = false
end)
