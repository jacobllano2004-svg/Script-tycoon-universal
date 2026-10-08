-- =====================================================================
-- MEGA HUB UNIVERSAL DE TYCOONS (BY JACOBOEU8) - VERSIÓN BLINDADA INTEGRAL
-- =====================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local function getExecutorName()
	if identifyexecutor then
		local name, _ = identifyexecutor()
		return name or "Delta"
	elseif getexecutorname then
		return getexecutorname() or "Delta"
	end
	return "Delta"
end

local currentLang = "EN"
local configFileName = "MegaHubConfig_" .. player.UserId .. ".json"

local translations = {
	EN = {
		Title = "Mega Hub Universal De Tycoons (by jacoboeu8)",
		TabMenu = "Menu",
		TabMain = "Main",
		TabESP = "ESP",
		TabTycoon = "Tycoon",
		TabSettings = "Settings",
		Welcome = "Welcome, ",
		Executor = "Executor: ",
		GameTitle = "Game: Loading...",
		FeatList = "• Main: Noclip, Fly, InfJump, TP Player\n• ESP: Blue Body, Names/Dist, Tracers\n• Tycoon: TP Base, Auto Collect\n• Settings: Languages, Themes, UI Lock, Config",
		Noclip = "Noclip",
		Fullbright = "Fullbright",
		WalkSpeed = "WalkSpeed (1-200):",
		Fly = "Fly",
		FlySpeed = "Fly Speed (1-200):",
		InfJump = "Infinite Jump",
		Rejoin = "Rejoin Server",
		ServerHop = "Server Hop",
		TPPlayerBtn = "TP to Player",
		SelectPlayer = "Select Player...",
		JoinNotif = " Joined the server",
		LeaveNotif = " Left the server",
		ToggleNotifs = "Join/Leave Notifications",
		ESPChams = "ESP Blue Body (Chams)",
		ESPName = "ESP Names & Distance",
		ESPTracers = "ESP Tracers",
		TPTycoon = "TP to Tycoon",
		SaveBase = "Save Base Position",
		AutoCollect = "Auto Collect Money",
		SaveCollector = "Save Money Collector Position",
		LanguageBtn = "Language: English",
		ThemeBtn = "Theme: ",
		UILock = "Lock Interface Position",
		UIUnlock = "Unlock Interface Position",
		SaveConfig = "Save Config",
		LoadConfig = "Load Config",
		AutoSaveConfig = "Auto Save Config",
		AutoLoadConfig = "Auto Load Config",
		BaseSaved = "Base Position Saved!",
		CollectorSaved = "Collector Position Saved!",
		FirstSaveBase = "Save Base Position First!",
		FirstSaveCollector = "Save Collector Position First!"
	},
	ES = {
		Title = "Mega Hub Universal De Tycoons (by jacoboeu8)",
		TabMenu = "Menu",
		TabMain = "Main",
		TabESP = "ESP",
		TabTycoon = "Tycoon",
		TabSettings = "Ajustes",
		Welcome = "Bienvenido, ",
		Executor = "Ejecutor: ",
		GameTitle = "Juego: Cargando...",
		FeatList = "• Main: Noclip, Fly, Salto Inf, TP Jugador\n• ESP: Cuerpo Azul, Nombres/Dist, Líneas\n• Tycoon: TP Base, Auto Recoger\n• Ajustes: Idiomas, Temas, Fijar UI, Config",
		Noclip = "Noclip",
		Fullbright = "Fullbright",
		WalkSpeed = "WalkSpeed (1-200):",
		Fly = "Volar (Fly)",
		FlySpeed = "Velocidad Vuelo (1-200):",
		InfJump = "Salto Infinito",
		Rejoin = "Reconectarse",
		ServerHop = "Cambiar Servidor",
		TPPlayerBtn = "TP a Jugador",
		SelectPlayer = "Seleccionar Jugador...",
		JoinNotif = " Entró al servidor",
		LeaveNotif = " Salió del servidor",
		ToggleNotifs = "Notificaciones de Entrada/Salida",
		ESPChams = "ESP Cuerpo Azul (Chams)",
		ESPName = "ESP Nombres y Distancia",
		ESPTracers = "ESP Líneas (Tracers)",
		TPTycoon = "TP a Tycoon",
		SaveBase = "Guardar Posición de Base",
		AutoCollect = "Auto Recoger Dinero",
		SaveCollector = "Guardar Posición de Recolector",
		LanguageBtn = "Idioma: Español",
		ThemeBtn = "Tema: ",
		UILock = "Fijar Posición de Interfaz",
		UIUnlock = "Desbloquear Posición de Interfaz",
		SaveConfig = "Guardar Configuración",
		LoadConfig = "Cargar Configuración",
		AutoSaveConfig = "Auto Guardar Config",
		AutoLoadConfig = "Auto Cargar Config",
		BaseSaved = "¡Posición de Base Guardada!",
		CollectorSaved = "¡Posición de Recolector Guardada!",
		FirstSaveBase = "¡Primero guarda la base!",
		FirstSaveCollector = "¡Primero guarda el recolector!"
	},
	PT = {
		Title = "Mega Hub Universal De Tycoons (by jacoboeu8)",
		TabMenu = "Menu",
		TabMain = "Principal",
		TabESP = "ESP",
		TabTycoon = "Tycoon",
		TabSettings = "Configurações",
		Welcome = "Bem-vindo, ",
		Executor = "Executor: ",
		GameTitle = "Jogo: Carregando...",
		FeatList = "• Principal: Noclip, Fly, Pulo Inf, TP Jogador\n• ESP: Corpo Azul, Nomes/Dist, Linhas\n• Tycoon: TP Base, Auto Coletar\n• Configurações: Idiomas, Temas, Travar UI, Config",
		Noclip = "Noclip",
		Fullbright = "Fullbright",
		WalkSpeed = "Velocidade (1-200):",
		Fly = "Voar (Fly)",
		FlySpeed = "Velocidade Voo (1-200):",
		InfJump = "Pulo Infinito",
		Rejoin = "Reconectar",
		ServerHop = "Trocar de Servidor",
		TPPlayerBtn = "TP para Jogador",
		SelectPlayer = "Selecionar Jogador...",
		JoinNotif = " Entrou no servidor",
		LeaveNotif = " Saiu do servidor",
		ToggleNotifs = "Notificações de Entrada/Saída",
		ESPChams = "ESP Corpo Azul (Chams)",
		ESPName = "ESP Nomes e Distância",
		ESPTracers = "ESP Linhas (Tracers)",
		TPTycoon = "TP para Tycoon",
		SaveBase = "Salvar Posição da Base",
		AutoCollect = "Auto Coletar Dinheiro",
		SaveCollector = "Salvar Posição do Coletor",
		LanguageBtn = "Idioma: Português",
		ThemeBtn = "Tema: ",
		UILock = "Travar Posição da Interface",
		UIUnlock = "Destravar Posição da Interface",
		SaveConfig = "Salvar Configuração",
		LoadConfig = "Carregar Configuração",
		AutoSaveConfig = "Auto Salvar Config",
		AutoLoadConfig = "Auto Carregar Config",
		BaseSaved = "Posição da Base Salva!",
		CollectorSaved = "Posição do Coletor Salva!",
		FirstSaveBase = "Salve a base primeiro!",
		FirstSaveCollector = "Salve o coletor primeiro!"
	},
	FR = {
		Title = "Mega Hub Universal De Tycoons (by jacoboeu8)",
		TabMenu = "Menu",
		TabMain = "Principal",
		TabESP = "ESP",
		TabTycoon = "Tycoon",
		TabSettings = "Paramètres",
		Welcome = "Bienvenue, ",
		Executor = "Exécuteur: ",
		GameTitle = "Jeu: Chargement...",
		FeatList = "• Principal: Noclip, Fly, Saut Inf, TP Joueur\n• ESP: Corps Bleu, Noms/Dist, Lignes\n• Tycoon: TP Base, Auto Collecte\n• Paramètres: Langues, Thèmes, Verrouiller UI, Config",
		Noclip = "Noclip",
		Fullbright = "Fullbright",
		WalkSpeed = "Vitesse (1-200):",
		Fly = "Voler (Fly)",
		FlySpeed = "Vitesse Vol (1-200):",
		InfJump = "Saut Infini",
		Rejoin = "Rejoindre",
		ServerHop = "Changer de Serveur",
		TPPlayerBtn = "TP au Joueur",
		SelectPlayer = "Sélectionner Joueur...",
		JoinNotif = " a rejoint le serveur",
		LeaveNotif = " a quitté le serveur",
		ToggleNotifs = "Notifications Entrée/Sortie",
		ESPChams = "ESP Corps Bleu (Chams)",
		ESPName = "ESP Noms & Distance",
		ESPTracers = "ESP Lignes (Tracers)",
		TPTycoon = "TP au Tycoon",
		SaveBase = "Sauvegarder Position Base",
		AutoCollect = "Auto Collecter Argent",
		SaveCollector = "Sauvegarder Position Collecteur",
		LanguageBtn = "Langue: Français",
		ThemeBtn = "Thème: ",
		UILock = "Verrouiller Position UI",
		UIUnlock = "Déverrouiller Position UI",
		SaveConfig = "Sauvegarder Config",
		LoadConfig = "Charger Config",
		AutoSaveConfig = "Auto Sauvegarder Config",
		AutoLoadConfig = "Auto Charger Config",
		BaseSaved = "Position Base Sauvegardée!",
		CollectorSaved = "Position Collecteur Sauvegardée!",
		FirstSaveBase = "Sauvegardez la base d'abord!",
		FirstSaveCollector = "Sauvegardez le collecteur d'abord!"
	},
	DE = {
		Title = "Mega Hub Universal De Tycoons (by jacoboeu8)",
		TabMenu = "Menü",
		TabMain = "Haupt",
		TabESP = "ESP",
		TabTycoon = "Tycoon",
		TabSettings = "Einstellungen",
		Welcome = "Willkommen, ",
		Executor = "Executor: ",
		GameTitle = "Spiel: Lädt...",
		FeatList = "• Haupt: Noclip, Fly, Inf Sprung, TP Spieler\n• ESP: Blauer Körper, Namen/Dist, Linien\n• Tycoon: TP Basis, Auto Einsammeln\n• Einstellungen: Sprachen, Themen, UI Sperren, Config",
		Noclip = "Noclip",
		Fullbright = "Fullbright",
		WalkSpeed = "Geschwindigkeit (1-200):",
		Fly = "Fliegen (Fly)",
		FlySpeed = "Fluggeschwindigkeit (1-200):",
		InfJump = "Unendlicher Sprung",
		Rejoin = "Neu verbinden",
		ServerHop = "Server wechseln",
		TPPlayerBtn = "TP zum Spieler",
		SelectPlayer = "Spieler auswählen...",
		JoinNotif = " hat den Server betreten",
		LeaveNotif = " hat den Server verlassen",
		ToggleNotifs = "Beitritts-/Austritts-Benachrichtigungen",
		ESPChams = "ESP Blauer Körper (Chams)",
		ESPName = "ESP Namen & Distanz",
		ESPTracers = "ESP Linien (Tracers)",
		TPTycoon = "TP zum Tycoon",
		SaveBase = "Basisposition speichern",
		AutoCollect = "Auto Geld einsammeln",
		SaveCollector = "Sammlerposition speichern",
		LanguageBtn = "Sprache: Deutsch",
		ThemeBtn = "Thema: ",
		UILock = "UI-Position sperren",
		UIUnlock = "UI-Position entsperren",
		SaveConfig = "Konfiguration speichern",
		LoadConfig = "Konfiguration laden",
		AutoSaveConfig = "Auto-Speichern Config",
		AutoLoadConfig = "Auto-Laden Config",
		BaseSaved = "Basisposition gespeichert!",
		CollectorSaved = "Sammlerposition gespeichert!",
		FirstSaveBase = "Zuerst Basis speichern!",
		FirstSaveCollector = "Zuerst Sammler speichern!"
	}
}

local themes = {
	Cyan = {Main = Color3.fromRGB(45, 45, 45), Top = Color3.fromRGB(30, 30, 30), Accent = Color3.fromRGB(0, 200, 255)},
	Red = {Main = Color3.fromRGB(45, 35, 35), Top = Color3.fromRGB(30, 20, 20), Accent = Color3.fromRGB(255, 60, 60)},
	Green = {Main = Color3.fromRGB(35, 45, 35), Top = Color3.fromRGB(20, 30, 20), Accent = Color3.fromRGB(60, 255, 60)},
	Purple = {Main = Color3.fromRGB(40, 35, 45), Top = Color3.fromRGB(25, 20, 30), Accent = Color3.fromRGB(200, 60, 255)},
	Dark = {Main = Color3.fromRGB(25, 25, 25), Top = Color3.fromRGB(15, 15, 15), Accent = Color3.fromRGB(150, 150, 150)}
}

local currentThemeName = "Cyan"
local autoCollectActive = false
local espActive = false
local espNameActive = false
local espTracersActive = false
local mainNoclipActive = false
local fullbrightActive = false
local flyActive = false
local infJumpActive = false
local uiLocked = false
local joinLeaveNotifsActive = true
local autoSaveConfigActive = false
local autoLoadConfigActive = false

local walkSpeedValue = 16
local flySpeedValue = 50

local noclipConnection = nil
local flyConnection = nil
local infJumpConnection = nil
local tracerLines = {}

local collectorPosition = nil
local basePosition = nil
local tempPlayerPosition = nil

local selectedTpTarget = nil

local origBrightness = Lighting.Brightness
local origClockTime = Lighting.ClockTime
local origGlobalShadows = Lighting.GlobalShadows
local origAmbient = Lighting.Ambient

local function enableNoclip()
	if noclipConnection then noclipConnection:Disconnect() end
	noclipConnection = RunService.Stepped:Connect(function()
		local char = player.Character
		if char and (mainNoclipActive or autoCollectActive) then
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end)
end

local function disableNoclip()
	if not mainNoclipActive and not autoCollectActive then
		if noclipConnection then
			noclipConnection:Disconnect()
			noclipConnection = nil
		end
		local char = player.Character
		if char then
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
					part.CanCollide = true
				end
			end
		end
	end
end

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

local function toggleFly(state)
	flyActive = state
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	
	if flyActive and char and hrp and hum then
		local bv = hrp:FindFirstChild("FlyBodyVelocity") or Instance.new("BodyVelocity")
		bv.Name = "FlyBodyVelocity"
		bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
		bv.Velocity = Vector3.zero
		bv.Parent = hrp

		local bg = hrp:FindFirstChild("FlyBodyGyro") or Instance.new("BodyGyro")
		bg.Name = "FlyBodyGyro"
		bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
		bg.P = 9e4
		bg.CFrame = hrp.CFrame
		bg.Parent = hrp

		hum.PlatformStand = true

		if flyConnection then flyConnection:Disconnect() end
		flyConnection = RunService.RenderStepped:Connect(function()
			local currentHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			local currentHum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if not flyActive or not currentHrp or not currentHum then return end
			bg.CFrame = camera.CFrame
			
			if currentHum.MoveDirection.Magnitude > 0 then
				local relMove = camera.CFrame:VectorToObjectSpace(currentHum.MoveDirection)
				local flyVector = (camera.CFrame.LookVector * -relMove.Z) + (camera.CFrame.RightVector * relMove.X)
				
				if flyVector.Magnitude > 0 then
					bv.Velocity = flyVector.Unit * flySpeedValue
				else
					bv.Velocity = Vector3.zero
				end
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
		if hum then
			hum.PlatformStand = false
		end
	end
end

local function toggleInfJump(state)
	infJumpActive = state
	if infJumpActive then
		if infJumpConnection then infJumpConnection:Disconnect() end
		infJumpConnection = UserInputService.JumpRequest:Connect(function()
			local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if infJumpActive and hum then
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end)
	else
		if infJumpConnection then
			infJumpConnection:Disconnect()
			infJumpConnection = nil
		end
	end
end

local playerGui = player:WaitForChild("PlayerGui")
if playerGui:FindFirstChild("Mega Hub Universal De Tycoons (by jacoboeu8)") then
	playerGui["Mega Hub Universal De Tycoons (by jacoboeu8)"]:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Mega Hub Universal De Tycoons (by jacoboeu8)"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local function showTopNotification(text)
	local notifLabel = Instance.new("TextLabel")
	notifLabel.Size = UDim2.new(0, 340, 0, 35)
	notifLabel.Position = UDim2.new(0.5, -170, 0.05, 0)
	notifLabel.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
	notifLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	notifLabel.Font = Enum.Font.SourceSansBold
	notifLabel.TextSize = 13
	notifLabel.Text = text
	notifLabel.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = notifLabel

	task.delay(4, function()
		if notifLabel then notifLabel:Destroy() end
	end)
end

local function showRightNotification(text, isJoin)
	if not joinLeaveNotifsActive then return end
	local notifLabel = Instance.new("TextLabel")
	notifLabel.Size = UDim2.new(0, 230, 0, 32)
	notifLabel.Position = UDim2.new(1, -240, 0.45, 0)
	notifLabel.BackgroundColor3 = isJoin and Color3.fromRGB(40, 180, 60) or Color3.fromRGB(200, 50, 50)
	notifLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	notifLabel.Font = Enum.Font.SourceSansBold
	notifLabel.TextSize = 11
	notifLabel.Text = text
	notifLabel.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = notifLabel

	task.delay(3, function()
		if notifLabel then notifLabel:Destroy() end
	end)
end

Players.PlayerAdded:Connect(function(p)
	local dict = translations[currentLang]
	showRightNotification("[+] " .. p.Name .. dict.JoinNotif, true)
end)

Players.PlayerRemoving:Connect(function(p)
	local dict = translations[currentLang]
	showRightNotification("[-] " .. p.Name .. dict.LeaveNotif, false)
	if selectedTpTarget == p then selectedTpTarget = nil end
end)

local function applyESP(targetPlayer)
	if targetPlayer == player then return end
	local function addHighlight(char)
		if not char or char:FindFirstChild("ESPHighlight") then return end
		local highlight = Instance.new("Highlight")
		highlight.Name = "ESPHighlight"
		highlight.Adornee = char
		highlight.FillColor = Color3.fromRGB(0, 150, 255)
		highlight.FillTransparency = 0.3
		highlight.OutlineColor = Color3.fromRGB(0, 255, 255)
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
		txt.TextColor3 = Color3.fromRGB(0, 220, 255)
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

local function toggleTracersState(state)
	espTracersActive = state
	if not espTracersActive then
		for _, line in pairs(tracerLines) do
			line:Remove()
		end
		tracerLines = {}
	end
end

RunService.RenderStepped:Connect(function()
	local curHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

	if espNameActive then
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= player and p.Character then
				local char = p.Character
				local tag = char:FindFirstChild("ESPNameTag")
				local hrpTarget = char:FindFirstChild("HumanoidRootPart")
				if tag and hrpTarget and curHrp then
					local dist = math.floor((curHrp.Position - hrpTarget.Position).Magnitude)
					tag.Label.Text = p.Name .. " [" .. dist .. "m]"
				end
			end
		end
	end

	if espTracersActive then
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				local targetHrp = p.Character.HumanoidRootPart
				local vector, onScreen = camera:WorldToViewportPoint(targetHrp.Position)
				
				if onScreen then
					local line = tracerLines[p.UserId] or Drawing.new("Line")
					line.Visible = true
					line.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
					line.To = Vector2.new(vector.X, vector.Y)
					line.Color = Color3.fromRGB(0, 200, 255)
					line.Thickness = 1.5
					line.Transparency = 0.8
					tracerLines[p.UserId] = line
				elseif tracerLines[p.UserId] then
					tracerLines[p.UserId].Visible = false
				end
			elseif tracerLines[p.UserId] then
				tracerLines[p.UserId].Visible = false
			end
		end
	end
end)

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 470, 0, 310)
mainFrame.Position = UDim2.new(0.5, -235, 0.4, -155)
mainFrame.BackgroundColor3 = themes.Cyan.Main
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
topBar.BackgroundColor3 = themes.Cyan.Top
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = translations.EN.Title
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

local statsWidget = Instance.new("Frame")
statsWidget.Name = "StatsWidget"
statsWidget.Size = UDim2.new(0, 80, 0, 30)
statsWidget.Position = UDim2.new(1, -90, 0, 10)
statsWidget.BackgroundColor3 = themes.Cyan.Top
statsWidget.BorderSizePixel = 0
statsWidget.Active = true
statsWidget.Draggable = true
statsWidget.Parent = screenGui

local statsText = Instance.new("TextLabel")
statsText.Size = UDim2.new(1, 0, 1, 0)
statsText.BackgroundTransparency = 1
statsText.Text = "Ping: 0ms\nFPS: 60"
statsText.TextColor3 = themes.Cyan.Accent
statsText.Font = Enum.Font.SourceSansBold
statsText.TextSize = 10
statsText.Parent = statsWidget

local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 110, 1, -35)
sidebar.Position = UDim2.new(0, 0, 0, 35)
sidebar.BackgroundColor3 = themes.Cyan.Top
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -120, 1, -45)
contentFrame.Position = UDim2.new(0, 115, 0, 40)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

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

local settingsTab = Instance.new("Frame")
settingsTab.Size = UDim2.new(1, 0, 1, 0)
settingsTab.BackgroundTransparency = 1
settingsTab.Visible = false
settingsTab.Parent = contentFrame

-- TARJETA DE PERFIL
local profileCard = Instance.new("Frame")
profileCard.Size = UDim2.new(0.95, 0, 0, 65)
profileCard.Position = UDim2.new(0, 0, 0, 5)
profileCard.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
profileCard.BorderSizePixel = 0
profileCard.Parent = menuTab

local avatarImage = Instance.new("ImageLabel")
avatarImage.Size = UDim2.new(0, 50, 0, 50)
avatarImage.Position = UDim2.new(0, 8, 0, 8)
avatarImage.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
avatarImage.BorderSizePixel = 0
avatarImage.Parent = profileCard

task.spawn(function()
	local content, isReady = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	if isReady and content then avatarImage.Image = content end
end)

local welcomeLabel = Instance.new("TextLabel")
welcomeLabel.Size = UDim2.new(1, -70, 0, 20)
welcomeLabel.Position = UDim2.new(0, 65, 0, 10)
welcomeLabel.BackgroundTransparency = 1
welcomeLabel.Text = translations.EN.Welcome .. player.Name
welcomeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
welcomeLabel.Font = Enum.Font.SourceSansBold
welcomeLabel.TextSize = 13
welcomeLabel.TextXAlignment = Enum.TextXAlignment.Left
welcomeLabel.Parent = profileCard

local executorLabel = Instance.new("TextLabel")
executorLabel.Size = UDim2.new(1, -70, 0, 20)
executorLabel.Position = UDim2.new(0, 65, 0, 32)
executorLabel.BackgroundTransparency = 1
executorLabel.Text = translations.EN.Executor .. getExecutorName()
executorLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
executorLabel.Font = Enum.Font.SourceSans
executorLabel.TextSize = 11
executorLabel.TextXAlignment = Enum.TextXAlignment.Left
executorLabel.Parent = profileCard

local featuresFrame = Instance.new("Frame")
featuresFrame.Size = UDim2.new(0.95, 0, 0, 85)
featuresFrame.Position = UDim2.new(0, 0, 0, 75)
featuresFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
featuresFrame.BorderSizePixel = 0
featuresFrame.Parent = menuTab

local featList = Instance.new("TextLabel")
featList.Size = UDim2.new(1, -10, 1, -10)
featList.Position = UDim2.new(0, 5, 0, 5)
featList.BackgroundTransparency = 1
featList.Text = translations.EN.FeatList
featList.TextColor3 = Color3.fromRGB(200, 200, 200)
featList.Font = Enum.Font.SourceSans
featList.TextSize = 11
featList.TextWrapped = true
featList.TextYAlignment = Enum.TextYAlignment.Top
featList.TextXAlignment = Enum.TextXAlignment.Left
featList.Parent = featuresFrame

local notifsToggleBtn = Instance.new("TextButton")
notifsToggleBtn.Size = UDim2.new(0.95, 0, 0, 30)
notifsToggleBtn.Position = UDim2.new(0, 0, 0, 168)
notifsToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 200, 40)
notifsToggleBtn.Text = translations.EN.ToggleNotifs
notifsToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
notifsToggleBtn.Font = Enum.Font.SourceSansBold
notifsToggleBtn.TextSize = 11
notifsToggleBtn.Parent = menuTab

notifsToggleBtn.MouseButton1Click:Connect(function()
	joinLeaveNotifsActive = not joinLeaveNotifsActive
	notifsToggleBtn.BackgroundColor3 = joinLeaveNotifsActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
end)

-- TARJETA ÚNICA INFERIOR: FOTO Y NOMBRE DEL JUEGO + PING Y FPS
local statsWidgetMenu = Instance.new("Frame")
statsWidgetMenu.Size = UDim2.new(0.95, 0, 0, 42)
statsWidgetMenu.Position = UDim2.new(0, 0, 0, 205)
statsWidgetMenu.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
statsWidgetMenu.BorderSizePixel = 0
statsWidgetMenu.Parent = menuTab

local statsCornerMenu = Instance.new("UICorner")
statsCornerMenu.CornerRadius = UDim.new(0, 6)
statsCornerMenu.Parent = statsWidgetMenu

local gameIcon = Instance.new("ImageLabel")
gameIcon.Size = UDim2.new(0, 32, 0, 32)
gameIcon.Position = UDim2.new(0, 5, 0.5, -16)
gameIcon.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
gameIcon.BorderSizePixel = 0
gameIcon.Image = "rbxassetid://0"
gameIcon.Parent = statsWidgetMenu

local gameIconCorner = Instance.new("UICorner")
gameIconCorner.CornerRadius = UDim.new(0, 4)
gameIconCorner.Parent = gameIcon

local gameTitleLabel = Instance.new("TextLabel")
gameTitleLabel.Size = UDim2.new(0.55, 0, 1, 0)
gameTitleLabel.Position = UDim2.new(0, 42, 0, 0)
gameTitleLabel.BackgroundTransparency = 1
gameTitleLabel.Text = translations.EN.GameTitle
gameTitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
gameTitleLabel.Font = Enum.Font.SourceSansBold
gameTitleLabel.TextSize = 10
gameTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
gameTitleLabel.TextWrapped = true
gameTitleLabel.Parent = statsWidgetMenu

local pingFpsLabel = Instance.new("TextLabel")
pingFpsLabel.Size = UDim2.new(0.38, 0, 1, 0)
pingFpsLabel.Position = UDim2.new(0.60, 0, 0, 0)
pingFpsLabel.BackgroundTransparency = 1
pingFpsLabel.Text = "Ping: 0ms\nFPS: 60"
pingFpsLabel.TextColor3 = themes.Cyan.Accent
pingFpsLabel.Font = Enum.Font.SourceSansBold
pingFpsLabel.TextSize = 10
pingFpsLabel.TextXAlignment = Enum.TextXAlignment.Right
pingFpsLabel.Parent = statsWidgetMenu

task.spawn(function()
	local success, gameInfo = pcall(function()
		return MarketplaceService:GetProductInfo(game.PlaceId)
	end)
	if success and gameInfo then
		gameTitleLabel.Text = "Juego:\n" .. gameInfo.Name
		gameIcon.Image = "rbxassetid://" .. (gameInfo.IconImageAssetId or 0)
	else
		gameTitleLabel.Text = "Juego:\nTycoon"
	end
end)

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

local function createNavBtn(text, posY)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 100, 0, 32)
	btn.Position = UDim2.new(0, 5, 0, posY)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 13
	btn.Parent = sidebar
	return btn
end

local menuBtn = createNavBtn(translations.EN.TabMenu, 10)
local mainBtn = createNavBtn(translations.EN.TabMain, 45)
local espBtn = createNavBtn(translations.EN.TabESP, 80)
local tycoonBtn = createNavBtn(translations.EN.TabTycoon, 115)
local settingsBtn = createNavBtn(translations.EN.TabSettings, 150)

local function switchTab(tabToShow, activeBtn)
	menuTab.Visible = false
	mainTab.Visible = false
	espTab.Visible = false
	tycoonTab.Visible = false
	settingsTab.Visible = false

	menuBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	mainBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	espBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	tycoonBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	settingsBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

	tabToShow.Visible = true
	activeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
end

menuBtn.MouseButton1Click:Connect(function() switchTab(menuTab, menuBtn) end)
mainBtn.MouseButton1Click:Connect(function() switchTab(mainTab, mainBtn) end)
espBtn.MouseButton1Click:Connect(function() switchTab(espTab, espBtn) end)
tycoonBtn.MouseButton1Click:Connect(function() switchTab(tycoonTab, tycoonBtn) end)
settingsBtn.MouseButton1Click:Connect(function() switchTab(settingsTab, settingsBtn) end)

local function createMainToggle(text, posY, posX)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.46, 0, 0, 28)
	btn.Position = UDim2.new(posX or 0, 0, 0, posY)
	btn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 11
	btn.Parent = mainTab
	return btn
end

local function createMainInput(labelText, defaultVal, posY)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(0.95, 0, 0, 28)
	container.Position = UDim2.new(0, 0, 0, posY)
	container.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	container.BorderSizePixel = 0
	container.Parent = mainTab

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(0.6, 0, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.SourceSansBold
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = container

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0.32, 0, 0.7, 0)
	box.Position = UDim2.new(0.65, 0, 0.15, 0)
	box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	box.Text = tostring(defaultVal)
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.Font = Enum.Font.SourceSansBold
	box.TextSize = 11
	box.Parent = container

	return box
end

local noclipMainBtn = createMainToggle(translations.EN.Noclip, 0, 0)
local fullbrightBtn = createMainToggle(translations.EN.Fullbright, 0, 0.49)
local walkSpeedBox = createMainInput(translations.EN.WalkSpeed, walkSpeedValue, 32)
local flyBtn = createMainToggle(translations.EN.Fly, 64, 0)
local infJumpBtn = createMainToggle(translations.EN.InfJump, 64, 0.49)
local flySpeedBox = createMainInput(translations.EN.FlySpeed, flySpeedValue, 96)
local rejoinBtn = createMainToggle(translations.EN.Rejoin, 128, 0)
rejoinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
local serverHopBtn = createMainToggle(translations.EN.ServerHop, 128, 0.49)
serverHopBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

local tpPlayerSelectBtn = Instance.new("TextButton")
tpPlayerSelectBtn.Size = UDim2.new(0.6, 0, 0, 28)
tpPlayerSelectBtn.Position = UDim2.new(0, 0, 0, 160)
tpPlayerSelectBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
tpPlayerSelectBtn.Text = translations.EN.SelectPlayer
tpPlayerSelectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpPlayerSelectBtn.Font = Enum.Font.SourceSansBold
tpPlayerSelectBtn.TextSize = 10
tpPlayerSelectBtn.Parent = mainTab

local tpPlayerActionBtn = Instance.new("TextButton")
tpPlayerActionBtn.Size = UDim2.new(0.33, 0, 0, 28)
tpPlayerActionBtn.Position = UDim2.new(0.62, 0, 0, 160)
tpPlayerActionBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
tpPlayerActionBtn.Text = translations.EN.TPPlayerBtn
tpPlayerActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpPlayerActionBtn.Font = Enum.Font.SourceSansBold
tpPlayerActionBtn.TextSize = 11
tpPlayerActionBtn.Parent = mainTab

local tpPlayerIndex = 1

local function cycleTpPlayer()
	local plist = {}
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player then table.insert(plist, p) end
	end
	if #plist == 0 then
		tpPlayerSelectBtn.Text = translations[currentLang].SelectPlayer
		selectedTpTarget = nil
		return
	end
	tpPlayerIndex = tpPlayerIndex + 1
	if tpPlayerIndex > #plist then tpPlayerIndex = 1 end
	selectedTpTarget = plist[tpPlayerIndex]
	tpPlayerSelectBtn.Text = selectedTpTarget.Name
end

tpPlayerSelectBtn.MouseButton1Click:Connect(cycleTpPlayer)

noclipMainBtn.MouseButton1Click:Connect(function()
	mainNoclipActive = not mainNoclipActive
	if mainNoclipActive then
		noclipMainBtn.BackgroundColor3 = Color3.fromRGB(40, 200, 40)
		enableNoclip()
	else
		noclipMainBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
		disableNoclip()
	end
	if autoSaveConfigActive then saveConfig() end
end)

fullbrightBtn.MouseButton1Click:Connect(function()
	toggleFullbright(not fullbrightActive)
	fullbrightBtn.BackgroundColor3 = fullbrightActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	if autoSaveConfigActive then saveConfig() end
end)

walkSpeedBox.FocusLost:Connect(function()
	local num = tonumber(walkSpeedBox.Text)
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if num then
		walkSpeedValue = math.clamp(num, 1, 200)
		walkSpeedBox.Text = tostring(walkSpeedValue)
		if hum then hum.WalkSpeed = walkSpeedValue end
	else
		walkSpeedBox.Text = tostring(walkSpeedValue)
	end
	if autoSaveConfigActive then saveConfig() end
end)

flyBtn.MouseButton1Click:Connect(function()
	toggleFly(not flyActive)
	flyBtn.BackgroundColor3 = flyActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	if autoSaveConfigActive then saveConfig() end
end)

infJumpBtn.MouseButton1Click:Connect(function()
	toggleInfJump(not infJumpActive)
	infJumpBtn.BackgroundColor3 = infJumpActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	if autoSaveConfigActive then saveConfig() end
end)

flySpeedBox.FocusLost:Connect(function()
	local num = tonumber(flySpeedBox.Text)
	if num then
		flySpeedValue = math.clamp(num, 1, 200)
		flySpeedBox.Text = tostring(flySpeedValue)
	else
		flySpeedBox.Text = tostring(flySpeedValue)
	end
	if autoSaveConfigActive then saveConfig() end
end)

rejoinBtn.MouseButton1Click:Connect(function()
	TeleportService:Teleport(game.PlaceId, player)
end)

serverHopBtn.MouseButton1Click:Connect(function()
	local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
	local targetServer = nil
	for _, s in pairs(servers.data) do
		if s.id ~= game.JobId and s.playing < s.maxPlayers then
			targetServer = s.id
			break
		end
	end
	if targetServer then
		TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServer, player)
	end
end)

tpPlayerActionBtn.MouseButton1Click:Connect(function()
	if selectedTpTarget and selectedTpTarget.Character then
		local targetHrp = selectedTpTarget.Character:FindFirstChild("HumanoidRootPart")
		local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if targetHrp and hrp then
			enableNoclip()
			hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 3)
			task.wait(0.1)
			disableNoclip()
		else
			showTopNotification("Target player has no root part!")
		end
	else
		showTopNotification("Select a player for TP first!")
	end
end)

local function createEspButton(text, posY)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.95, 0, 0, 32)
	btn.Position = UDim2.new(0, 0, 0, posY)
	btn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 12
	btn.Parent = espTab
	return btn
end

local espPlayerBtn = createEspButton(translations.EN.ESPChams, 0)
local espNameBtn = createEspButton(translations.EN.ESPName, 38)
local espTracersBtn = createEspButton(translations.EN.ESPTracers, 76)

espPlayerBtn.MouseButton1Click:Connect(function()
	toggleESPState(not espActive)
	espPlayerBtn.BackgroundColor3 = espActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	if autoSaveConfigActive then saveConfig() end
end)

espNameBtn.MouseButton1Click:Connect(function()
	toggleNameESPState(not espNameActive)
	espNameBtn.BackgroundColor3 = espNameActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	if autoSaveConfigActive then saveConfig() end
end)

espTracersBtn.MouseButton1Click:Connect(function()
	toggleTracersState(not espTracersActive)
	espTracersBtn.BackgroundColor3 = espTracersActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	if autoSaveConfigActive then saveConfig() end
end)

local function createTycoonBtn(text, posY, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.95, 0, 0, 32)
	btn.Position = UDim2.new(0, 0, 0, posY)
	btn.BackgroundColor3 = color or Color3.fromRGB(60, 60, 60)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 11
	btn.TextWrapped = true
	btn.Parent = tycoonTab
	return btn
end

local tpTycoonBtn = createTycoonBtn(translations.EN.TPTycoon, 0)
local saveBaseBtn = createTycoonBtn(translations.EN.SaveBase, 38)
local collectButton = createTycoonBtn(translations.EN.AutoCollect, 76, Color3.fromRGB(200, 40, 40))
local saveCollectorBtn = createTycoonBtn(translations.EN.SaveCollector, 114)

local function performCollect()
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not autoCollectActive or not hrp or not collectorPosition then return end
	tempPlayerPosition = hrp.CFrame
	enableNoclip()
	hrp.CFrame = collectorPosition
	disableNoclip()
	hrp.Velocity = Vector3.new(0, -10, 0)
	task.wait(1)
	enableNoclip()
	if tempPlayerPosition then hrp.CFrame = tempPlayerPosition end
	disableNoclip()
	tempPlayerPosition = nil
end

local function collectMoneyRoutine()
	performCollect()
	while autoCollectActive do
		task.wait(3)
		if autoCollectActive then performCollect() end
	end
end

tpTycoonBtn.MouseButton1Click:Connect(function()
	local dict = translations[currentLang]
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not basePosition then
		tpTycoonBtn.Text = dict.FirstSaveBase
		task.wait(1.5)
		tpTycoonBtn.Text = dict.TPTycoon
		return
	end
	if hrp then enableNoclip() hrp.CFrame = basePosition disableNoclip() end
end)

saveBaseBtn.MouseButton1Click:Connect(function()
	local dict = translations[currentLang]
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		basePosition = hrp.CFrame
		saveBaseBtn.Text = dict.BaseSaved
		saveBaseBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
		task.wait(1)
		saveBaseBtn.Text = dict.SaveBase
		saveBaseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	end
end)

saveCollectorBtn.MouseButton1Click:Connect(function()
	local dict = translations[currentLang]
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		collectorPosition = hrp.CFrame + Vector3.new(0, 0.5, 0)
		saveCollectorBtn.Text = dict.CollectorSaved
		saveCollectorBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
		task.wait(1)
		saveCollectorBtn.Text = dict.SaveCollector
		saveCollectorBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	end
end)

collectButton.MouseButton1Click:Connect(function()
	local dict = translations[currentLang]
	if not collectorPosition and not autoCollectActive then
		collectButton.Text = dict.FirstSaveCollector
		task.wait(1.5)
		collectButton.Text = dict.AutoCollect
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
	if autoSaveConfigActive then saveConfig() end
end)

local function createSettingsBtn(text, posY, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.95, 0, 0, 26)
	btn.Position = UDim2.new(0, 0, 0, posY)
	btn.BackgroundColor3 = color or Color3.fromRGB(60, 60, 60)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 11
	btn.Parent = settingsTab
	return btn
end

local langToggleBtn = createSettingsBtn(translations.EN.LanguageBtn, 0)
local themeToggleBtn = createSettingsBtn("Theme: Cyan", 30)
local lockUiBtn = createSettingsBtn(translations.EN.UILock, 60)
local saveConfigBtn = createSettingsBtn(translations.EN.SaveConfig, 90, Color3.fromRGB(0, 120, 180))
local loadConfigBtn = createSettingsBtn(translations.EN.LoadConfig, 120, Color3.fromRGB(0, 120, 180))
local autoSaveBtn = createSettingsBtn(translations.EN.AutoSaveConfig, 150, Color3.fromRGB(200, 40, 40))
local autoLoadBtn = createSettingsBtn(translations.EN.AutoLoadConfig, 180, Color3.fromRGB(200, 40, 40))

local function updateLanguage(langKey)
	currentLang = langKey
	local dict = translations[langKey]

	titleLabel.Text = dict.Title
	menuBtn.Text = dict.TabMenu
	mainBtn.Text = dict.TabMain
	espBtn.Text = dict.TabESP
	tycoonBtn.Text = dict.TabTycoon
	settingsBtn.Text = dict.TabSettings

	welcomeLabel.Text = dict.Welcome .. player.Name
	executorLabel.Text = dict.Executor .. getExecutorName()
	featList.Text = dict.FeatList
	notifsToggleBtn.Text = dict.ToggleNotifs

	noclipMainBtn.Text = dict.Noclip
	fullbrightBtn.Text = dict.Fullbright
	walkSpeedBox.Parent.Label.Text = dict.WalkSpeed
	flyBtn.Text = dict.Fly
	infJumpBtn.Text = dict.InfJump
	flySpeedBox.Parent.Label.Text = dict.FlySpeed
	rejoinBtn.Text = dict.Rejoin
	serverHopBtn.Text = dict.ServerHop
	tpPlayerActionBtn.Text = dict.TPPlayerBtn

	if not selectedTpTarget then tpPlayerSelectBtn.Text = dict.SelectPlayer end

	espPlayerBtn.Text = dict.ESPChams
	espNameBtn.Text = dict.ESPName
	espTracersBtn.Text = dict.ESPTracers

	tpTycoonBtn.Text = dict.TPTycoon
	saveBaseBtn.Text = dict.SaveBase
	collectButton.Text = dict.AutoCollect
	saveCollectorBtn.Text = dict.SaveCollector

	langToggleBtn.Text = dict.LanguageBtn
	lockUiBtn.Text = uiLocked and dict.UIUnlock or dict.UILock
	saveConfigBtn.Text = dict.SaveConfig
	loadConfigBtn.Text = dict.LoadConfig
	autoSaveBtn.Text = dict.AutoSaveConfig
	autoLoadBtn.Text = dict.AutoLoadConfig
end

local langOrder = {"EN", "ES", "PT", "FR", "DE"}
local currentLangIdx = 1

langToggleBtn.MouseButton1Click:Connect(function()
	currentLangIdx = currentLangIdx + 1
	if currentLangIdx > #langOrder then currentLangIdx = 1 end
	updateLanguage(langOrder[currentLangIdx])
	if autoSaveConfigActive then saveConfig() end
end)

local themeOrder = {"Cyan", "Red", "Green", "Purple", "Dark"}
local currentThemeIdx = 1

local function applyTheme(themeName)
	currentThemeName = themeName
	local t = themes[themeName]
	mainFrame.BackgroundColor3 = t.Main
	topBar.BackgroundColor3 = t.Top
	sidebar.BackgroundColor3 = t.Top
	statsWidget.BackgroundColor3 = t.Top
	statsText.TextColor3 = t.Accent
	pingFpsLabel.TextColor3 = t.Accent
	themeToggleBtn.Text = "Theme: " .. themeName
end

themeToggleBtn.MouseButton1Click:Connect(function()
	currentThemeIdx = currentThemeIdx + 1
	if currentThemeIdx > #themeOrder then currentThemeIdx = 1 end
	applyTheme(themeOrder[currentThemeIdx])
	if autoSaveConfigActive then saveConfig() end
end)

lockUiBtn.MouseButton1Click:Connect(function()
	uiLocked = not uiLocked
	mainFrame.Draggable = not uiLocked
	toggleButton.Draggable = not uiLocked
	statsWidget.Draggable = not uiLocked
	local dict = translations[currentLang]
	lockUiBtn.Text = uiLocked and dict.UIUnlock or dict.UILock
	lockUiBtn.BackgroundColor3 = uiLocked and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(60, 60, 60)
	if autoSaveConfigActive then saveConfig() end
end)

-- SISTEMA DE CONFIGURACIÓN (SAVE & LOAD)
function saveConfig()
	if not writefile then return end
	local data = {
		Lang = currentLang,
		Theme = currentThemeName,
		WalkSpeed = walkSpeedValue,
		FlySpeed = flySpeedValue,
		Noclip = mainNoclipActive,
		Fullbright = fullbrightActive,
		Fly = flyActive,
		InfJump = infJumpActive,
		ESPChams = espActive,
		ESPName = espNameActive,
		ESPTracers = espTracersActive,
		AutoCollect = autoCollectActive,
		JoinNotifs = joinLeaveNotifsActive,
		UILocked = uiLocked,
		AutoSave = autoSaveConfigActive,
		AutoLoad = autoLoadConfigActive
	}
	writefile(configFileName, HttpService:JSONEncode(data))
end

function loadConfig()
	if not readfile or not isfile or not isfile(configFileName) then return end
	local success, data = pcall(function()
		return HttpService:JSONDecode(readfile(configFileName))
	end)
	if not success or not data then return end

	if data.Lang then
		for i, l in ipairs(langOrder) do
			if l == data.Lang then currentLangIdx = i break end
		end
		updateLanguage(data.Lang)
	end

	if data.Theme then
		for i, t in ipairs(themeOrder) do
			if t == data.Theme then currentThemeIdx = i break end
		end
		applyTheme(data.Theme)
	end

	if data.WalkSpeed then
		walkSpeedValue = data.WalkSpeed
		walkSpeedBox.Text = tostring(walkSpeedValue)
		local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = walkSpeedValue end
	end

	if data.FlySpeed then
		flySpeedValue = data.FlySpeed
		flySpeedBox.Text = tostring(flySpeedValue)
	end

	if data.Noclip ~= nil and data.Noclip ~= mainNoclipActive then
		mainNoclipActive = data.Noclip
		noclipMainBtn.BackgroundColor3 = mainNoclipActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
		if mainNoclipActive then enableNoclip() else disableNoclip() end
	end

	if data.Fullbright ~= nil and data.Fullbright ~= fullbrightActive then
		toggleFullbright(data.Fullbright)
		fullbrightBtn.BackgroundColor3 = fullbrightActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	end

	if data.Fly ~= nil and data.Fly ~= flyActive then
		toggleFly(data.Fly)
		flyBtn.BackgroundColor3 = flyActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	end

	if data.InfJump ~= nil and data.InfJump ~= infJumpActive then
		toggleInfJump(data.InfJump)
		infJumpBtn.BackgroundColor3 = infJumpActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	end

	if data.ESPChams ~= nil and data.ESPChams ~= espActive then
		toggleESPState(data.ESPChams)
		espPlayerBtn.BackgroundColor3 = espActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	end

	if data.ESPName ~= nil and data.ESPName ~= espNameActive then
		toggleNameESPState(data.ESPName)
		espNameBtn.BackgroundColor3 = espNameActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	end

	if data.ESPTracers ~= nil and data.ESPTracers ~= espTracersActive then
		toggleTracersState(data.ESPTracers)
		espTracersBtn.BackgroundColor3 = espTracersActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	end

	if data.JoinNotifs ~= nil then
		joinLeaveNotifsActive = data.JoinNotifs
		notifsToggleBtn.BackgroundColor3 = joinLeaveNotifsActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	end

	if data.UILocked ~= nil then
		uiLocked = data.UILocked
		mainFrame.Draggable = not uiLocked
		toggleButton.Draggable = not uiLocked
		statsWidget.Draggable = not uiLocked
		lockUiBtn.Text = uiLocked and translations[currentLang].UIUnlock or translations[currentLang].UILock
		lockUiBtn.BackgroundColor3 = uiLocked and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(60, 60, 60)
	end

	if data.AutoSave ~= nil then
		autoSaveConfigActive = data.AutoSave
		autoSaveBtn.BackgroundColor3 = autoSaveConfigActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	end

	if data.AutoLoad ~= nil then
		autoLoadConfigActive = data.AutoLoad
		autoLoadBtn.BackgroundColor3 = autoLoadConfigActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	end
end

saveConfigBtn.MouseButton1Click:Connect(function()
	saveConfig()
	showTopNotification("Config Saved!")
end)

loadConfigBtn.MouseButton1Click:Connect(function()
	loadConfig()
	showTopNotification("Config Loaded!")
end)

autoSaveBtn.MouseButton1Click:Connect(function()
	autoSaveConfigActive = not autoSaveConfigActive
	autoSaveBtn.BackgroundColor3 = autoSaveConfigActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	if autoSaveConfigActive then saveConfig() end
end)

autoLoadBtn.MouseButton1Click:Connect(function()
	autoLoadConfigActive = not autoLoadConfigActive
	autoLoadBtn.BackgroundColor3 = autoLoadConfigActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	if autoSaveConfigActive then saveConfig() end
end)

closeButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	toggleButton.Visible = true
end)

toggleButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = true
	toggleButton.Visible = false
end)

-- COMPROBACIÓN AUTO-LOAD AL INICIAR
task.spawn(function()
	if isfile and isfile(configFileName) then
		local success, data = pcall(function()
			return HttpService:JSONDecode(readfile(configFileName))
		end)
		if success and data and data.AutoLoad then
			loadConfig()
		end
	end
end)

switchTab(menuTab, menuBtn)
