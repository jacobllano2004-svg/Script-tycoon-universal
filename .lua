-- =====================================================================
-- MEGA HUB UNIVERSAL DE TYCOONS (BY JACOBOEU8) - V4.4 ULTIMATE CROWN EDITION
-- =====================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function getCurrentCamera()
	return workspace.CurrentCamera or workspace:FindFirstChildOfClass("Camera")
end

-- =====================================================================
-- 1. SISTEMA DE LIMPIEZA TOTAL IDEMPOTENTE Y BLINDADO (V4.4)
-- =====================================================================
if type(getgenv) == "function" and getgenv().MegaHubCleaner then
	pcall(function()
		getgenv().MegaHubCleaner()
	end)
end

local activeConnections = {}
local activeDrawings = {}
local espChamsConnections = {}
local espNameConnections = {}
local playerChamsConnections = {}
local playerNamesConnections = {}

local initialOriginalLighting = {
	Brightness = Lighting.Brightness,
	ClockTime = Lighting.ClockTime,
	GlobalShadows = Lighting.GlobalShadows,
	Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	ExposureCompensation = Lighting.ExposureCompensation,
}

local cleanupState = {
	originalLighting = initialOriginalLighting,
	modifiedLightingProps = {},
	characterCollisionStates = {},
	respawnToken = 0,
	lastTempPos = nil, -- Resguardo preventivo de posición para cierre en pleno collect
}

local function registerConnection(conn)
	table.insert(activeConnections, conn)
	return conn
end

local function removeConnection(conn)
	local index = table.find(activeConnections, conn)
	if index then
		table.remove(activeConnections, index)
	end
end

local function cleanChamsConnections()
	for _, conn in ipairs(espChamsConnections) do
		pcall(function() conn:Disconnect() end)
	end
	table.clear(espChamsConnections)
	table.clear(playerChamsConnections)
end

local function cleanNameConnections()
	for _, conn in ipairs(espNameConnections) do
		pcall(function() conn:Disconnect() end)
	end
	table.clear(espNameConnections)
	table.clear(playerNamesConnections)
end

local function cleanPlayerChamsConns(userId)
	if playerChamsConnections[userId] then
		for _, conn in ipairs(playerChamsConnections[userId]) do
			pcall(function() conn:Disconnect() end)
		end
		playerChamsConnections[userId] = nil
	end
end

local function cleanPlayerNamesConns(userId)
	if playerNamesConnections[userId] then
		for _, conn in ipairs(playerNamesConnections[userId]) do
			pcall(function() conn:Disconnect() end)
		end
		playerNamesConnections[userId] = nil
	end
end

local function removeAllHubESPObjects()
	for _, p in pairs(Players:GetPlayers()) do
		if p.Character then
			local h = p.Character:FindFirstChild("ESPHighlight")
			if h and h:GetAttribute("HubOwner") == "MegaHub" then h:Destroy() end
			local t = p.Character:FindFirstChild("ESPNameTag")
			if t and t:GetAttribute("HubOwner") == "MegaHub" then t:Destroy() end
		end
	end
end

local function restoreCharacterStates(char)
	if not char then return end
	
	if cleanupState.characterCollisionStates[char] then
		for part, originalState in pairs(cleanupState.characterCollisionStates[char]) do
			if part and part.Parent then
				pcall(function() part.CanCollide = originalState end)
			end
		end
		cleanupState.characterCollisionStates[char] = nil
	end

	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		if hum:GetAttribute("OriginalPlatformStand") ~= nil then
			pcall(function() hum.PlatformStand = hum:GetAttribute("OriginalPlatformStand") end)
			hum:SetAttribute("OriginalPlatformStand", nil)
		end
		if hum:GetAttribute("OriginalWalkSpeed") ~= nil then
			pcall(function() hum.WalkSpeed = hum:GetAttribute("OriginalWalkSpeed") end)
			hum:SetAttribute("OriginalWalkSpeed", nil)
		end
	end
	
	for _, obj in ipairs(char:GetDescendants()) do
		if obj.Name == "FlyBodyVelocity" or obj.Name == "FlyBodyGyro" then
			pcall(function() obj:Destroy() end)
		end
	end
end

local function restoreLighting()
	for prop, origVal in pairs(cleanupState.modifiedLightingProps) do
		pcall(function() Lighting[prop] = origVal end)
	end
	table.clear(cleanupState.modifiedLightingProps)
end

-- Declaraciones globales
local autoCollectActive, mainNoclipActive, fullbrightActive, flyActive, infJumpActive
local collectButton, noclipMainBtn, fullbrightBtn, flyBtn, infJumpBtn, toggleButton, statsWidget
local mainFrame
local noclipConnection = nil
local flyConnection = nil
local infJumpConnection = nil
local noclipOwners = {}

if type(getgenv) == "function" then
	getgenv().MegaHubCleaner = function()
		-- Resguardo de emergencia: si el hub se cierra mientras AutoCollect estaba en curso, devolvemos al personaje inmediatamente
		if autoCollectActive and cleanupState.lastTempPos then
			pcall(function()
				local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if hrp then hrp.CFrame = cleanupState.lastTempPos end
			end)
		end

		cleanupState.respawnToken = cleanupState.respawnToken + 1
		
		autoCollectActive = false
		mainNoclipActive = false
		fullbrightActive = false
		flyActive = false
		infJumpActive = false
		table.clear(noclipOwners)

		if collectButton then collectButton.BackgroundColor3 = Color3.fromRGB(200, 40, 40) end
		if noclipMainBtn then noclipMainBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40) end
		if fullbrightBtn then fullbrightBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40) end
		if flyBtn then flyBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40) end
		if infJumpBtn then infJumpBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40) end
		if toggleButton then toggleButton:Destroy() end
		if statsWidget then statsWidget:Destroy() end

		for _, conn in ipairs(activeConnections) do
			pcall(function() conn:Disconnect() end)
		end
		table.clear(activeConnections)

		cleanChamsConnections()
		cleanNameConnections()
		removeAllHubESPObjects()

		for _, line in pairs(activeDrawings) do
			pcall(function() line:Remove() end)
		end
		table.clear(activeDrawings)

		if player.Character then
			restoreCharacterStates(player.Character)
		end
		for charInstance, _ in pairs(cleanupState.characterCollisionStates) do
			restoreCharacterStates(charInstance)
		end
		table.clear(cleanupState.characterCollisionStates)
		restoreLighting()

		if noclipConnection then
			pcall(function() noclipConnection:Disconnect() end)
			noclipConnection = nil
		end
		if flyConnection then
			pcall(function() flyConnection:Disconnect() end)
			flyConnection = nil
		end
		if infJumpConnection then
			pcall(function() infJumpConnection:Disconnect() end)
			infJumpConnection = nil
		end

		local gui = playerGui:FindFirstChild("Mega Hub Universal De Tycoons (by jacoboeu8)")
		if gui then gui:Destroy() end
	end
end

-- =====================================================================
-- 2. CAPACIDADES Y TRADUCCIONES V4.4
-- =====================================================================
local envFS = {
	hasWrite = type(writefile) == "function",
	hasRead = type(readfile) == "function",
	hasIsFile = type(isfile) == "function"
}

local hasDrawing = type(Drawing) == "table" and type(Drawing.new) == "function"
local safeUnpack = unpack or table.unpack

local currentLang = "EN"
local configFileName = "MegaHubConfig_" .. player.UserId .. ".json"

local translations = {
	EN = {
		Title = "Mega Hub Universal De Tycoons (by jacoboeu8) - V4.4",
		TabMenu = "Menu", TabMain = "Main", TabESP = "ESP", TabTycoon = "Tycoon", TabSettings = "Settings",
		Welcome = "Welcome, ", Executor = "Executor: ", GameTitle = "Game: Loading...",
		FeatList = "• Main: Noclip, Fly, InfJump, TP Player\n• ESP: Blue Body, Names/Dist, Tracers\n• Tycoon: TP Base, Auto Collect\n• Settings: Languages, Themes, UI Lock, Config",
		Noclip = "Noclip", Fullbright = "Fullbright", WalkSpeed = "WalkSpeed (1-200):", Fly = "Fly", FlySpeed = "Fly Speed (1-200):", InfJump = "Infinite Jump",
		Rejoin = "Rejoin Server", ServerHop = "Server Hop", TPPlayerBtn = "TP to Player", SelectPlayer = "Select Player...", JoinNotif = " Joined the server", LeaveNotif = " Left the server",
		ToggleNotifs = "Join/Leave Notifications", ESPChams = "ESP Blue Body (Chams)", ESPName = "ESP Names & Distance", ESPTracers = "ESP Tracers",
		TPTycoon = "TP to Tycoon", SaveBase = "Save Base Position", AutoCollect = "Auto Collect Money", SaveCollector = "Save Money Collector Position",
		LanguageBtn = "Language: English", ThemeBtn = "Theme: ", UILock = "Lock Interface Position", UIUnlock = "Unlock Interface Position",
		SaveConfig = "Save Config", LoadConfig = "Load Config", AutoSaveConfig = "Auto Save Config", AutoLoadConfig = "Auto Load Config",
		BaseSaved = "Base Position Saved!", CollectorSaved = "Collector Position Saved!", FirstSaveBase = "Save Base Position First!", FirstSaveCollector = "Save Collector Position First!",
		NoFS = "File system unsupported!", NoFile = "Config file not found!", CorruptJSON = "Config file corrupted!", TargetNotFound = "Target player or root part missing!", ConfigSavedMsg = "Config Saved!", ConfigLoadedMsg = "Config Loaded!", SaveFailedMsg = "Failed to save config!"
	},
	ES = {
		Title = "Mega Hub Universal De Tycoons (by jacoboeu8) - V4.4",
		TabMenu = "Menú", TabMain = "Principal", TabESP = "ESP", TabTycoon = "Tycoon", TabSettings = "Ajustes",
		Welcome = "Bienvenido, ", Executor = "Ejecutor: ", GameTitle = "Juego: Cargando...",
		FeatList = "• Principal: Noclip, Fly, Salto Inf, TP Jugador\n• ESP: Cuerpo Azul, Nombres/Dist, Líneas\n• Tycoon: TP Base, Auto Recoger\n• Ajustes: Idiomas, Temas, Fijar UI, Config",
		Noclip = "Noclip", Fullbright = "Fullbright", WalkSpeed = "WalkSpeed (1-200):", Fly = "Volar (Fly)", FlySpeed = "Velocidad Vuelo (1-200):", InfJump = "Salto Infinito",
		Rejoin = "Reconectarse", ServerHop = "Cambiar Servidor", TPPlayerBtn = "TP a Jugador", SelectPlayer = "Seleccionar Jugador...", JoinNotif = " Entró al servidor", LeaveNotif = " Salió del servidor",
		ToggleNotifs = "Notificaciones de Entrada/Salida", ESPChams = "ESP Cuerpo Azul (Chams)", ESPName = "ESP Nombres y Distancia", ESPTracers = "ESP Líneas (Tracers)",
		TPTycoon = "TP a Tycoon", SaveBase = "Guardar Posición de Base", AutoCollect = "Auto Recoger Dinero", SaveCollector = "Guardar Posición de Recolector",
		LanguageBtn = "Idioma: Español", ThemeBtn = "Tema: ", UILock = "Fijar Posición de Interfaz", UIUnlock = "Desbloquear Posición de Interfaz",
		SaveConfig = "Guardar Configuración", LoadConfig = "Cargar Configuración", AutoSaveConfig = "Auto Guardar Config", AutoLoadConfig = "Auto Cargar Config",
		BaseSaved = "¡Posición de Base Guardada!", CollectorSaved = "¡Posición de Recolector Guardada!", FirstSaveBase = "¡Primero guarda la base!", FirstSaveCollector = "¡Primero guarda el recolector!",
		NoFS = "¡Sistema de archivos no compatible!", NoFile = "¡Archivo de configuración no encontrado!", CorruptJSON = "¡Archivo de configuración corrupto!", TargetNotFound = "¡Jugador u objetivo no encontrado!", ConfigSavedMsg = "¡Configuración Guardada!", ConfigLoadedMsg = "¡Configuración Cargada!", SaveFailedMsg = "¡Error al guardar configuración!"
	},
	PT = {
		Title = "Mega Hub Universal De Tycoons (by jacoboeu8) - V4.4",
		TabMenu = "Menu", TabMain = "Principal", TabESP = "ESP", TabTycoon = "Tycoon", TabSettings = "Configurações",
		Welcome = "Bem-vindo, ", Executor = "Executor: ", GameTitle = "Jogo: Carregando...",
		FeatList = "• Principal: Noclip, Fly, Pulo Inf, TP Jogador\n• ESP: Corpo Azul, Nomes/Dist, Linhas\n• Tycoon: TP Base, Auto Coletar\n• Configurações: Idiomas, Temas, Travar UI, Config",
		Noclip = "Noclip", Fullbright = "Fullbright", WalkSpeed = "Velocidade (1-200):", Fly = "Voar (Fly)", FlySpeed = "Velocidade Voo (1-200):", InfJump = "Pulo Infinito",
		Rejoin = "Reconectar", ServerHop = "Trocar de Servidor", TPPlayerBtn = "TP para Jogador", SelectPlayer = "Selecionar Jogador...", JoinNotif = " Entrou no servidor", LeaveNotif = " Saiu do servidor",
		ToggleNotifs = "Notificações de Entrada/Saída", ESPChams = "ESP Corpo Azul (Chams)", ESPName = "ESP Nomes e Distância", ESPTracers = "ESP Linhas (Tracers)",
		TPTycoon = "TP para Tycoon", SaveBase = "Salvar Posição da Base", AutoCollect = "Auto Coletar Dinheiro", SaveCollector = "Salvar Posição do Coletor",
		LanguageBtn = "Idioma: Português", ThemeBtn = "Tema: ", UILock = "Travar Posição da Interface", UIUnlock = "Destravar Posição da Interface",
		SaveConfig = "Salvar Configuração", LoadConfig = "Carregar Configuração", AutoSaveConfig = "Auto Salvar Config", AutoLoadConfig = "Auto Carregar Config",
		BaseSaved = "Posição da Base Salva!", CollectorSaved = "Posição do Coletor Salva!", FirstSaveBase = "Salve a base primeiro!", FirstSaveCollector = "Salve o coletor primeiro!",
		NoFS = "Sistema de arquivos não suportado!", NoFile = "Arquivo de configuração não encontrado!", CorruptJSON = "Arquivo de configuração corrompido!", TargetNotFound = "Jogador alvo não encontrado!", ConfigSavedMsg = "Configuração Salva!", ConfigLoadedMsg = "Configuração Carregada!", SaveFailedMsg = "Erro ao salvar!"
	},
	FR = {
		Title = "Mega Hub Universal De Tycoons (by jacoboeu8) - V4.4",
		TabMenu = "Menu", TabMain = "Principal", TabESP = "ESP", TabTycoon = "Tycoon", TabSettings = "Paramètres",
		Welcome = "Bienvenue, ", Executor = "Exécuteur: ", GameTitle = "Jeu: Chargement...",
		FeatList = "• Principal: Noclip, Fly, Saut Inf, TP Joueur\n• ESP: Corps Bleu, Noms/Dist, Lignes\n• Tycoon: TP Base, Auto Collecte\n• Paramètres: Langues, Thèmes, Verrouiller UI, Config",
		Noclip = "Noclip", Fullbright = "Fullbright", WalkSpeed = "Vitesse (1-200):", Fly = "Voler (Fly)", FlySpeed = "Vitesse Vol (1-200):", InfJump = "Saut Infini",
		Rejoin = "Rejoindre", ServerHop = "Changer de Serveur", TPPlayerBtn = "TP au Joueur", SelectPlayer = "Sélectionner Joueur...", JoinNotif = " a rejoint le serveur", LeaveNotif = " a quitté le serveur",
		ToggleNotifs = "Notifications Entrée/Sortie", ESPChams = "ESP Corps Bleu (Chams)", ESPName = "ESP Noms & Distance", ESPTracers = "ESP Lignes (Tracers)",
		TPTycoon = "TP au Tycoon", SaveBase = "Sauvegarder Position Base", AutoCollect = "Auto Collecter Argent", SaveCollector = "Sauvegarder Position Collecteur",
		LanguageBtn = "Langue: Français", ThemeBtn = "Thème: ", UILock = "Verrouiller Position UI", UIUnlock = "Déverrouiller Position UI",
		SaveConfig = "Sauvegarder Config", LoadConfig = "Charger Config", AutoSaveConfig = "Auto Sauvegarder Config", AutoLoadConfig = "Auto Charger Config",
		BaseSaved = "Position Base Sauvegardée!", CollectorSaved = "Position Collecteur Sauvegardée!", FirstSaveBase = "Sauvegardez la base d'abord!", FirstSaveCollector = "Sauvegardez le collecteur d'abord!",
		NoFS = "Système de fichiers non supporté!", NoFile = "Fichier de configuration introuvable!", CorruptJSON = "Fichier de configuration corrompu!", TargetNotFound = "Cible introuvable!", ConfigSavedMsg = "Configuration Sauvegardée!", ConfigLoadedMsg = "Configuration Chargée!", SaveFailedMsg = "Erreur de sauvegarde!"
	},
	DE = {
		Title = "Mega Hub Universal De Tycoons (by jacoboeu8) - V4.4",
		TabMenu = "Menü", TabMain = "Haupt", TabESP = "ESP", TabTycoon = "Tycoon", TabSettings = "Einstellungen",
		Welcome = "Willkommen, ", Executor = "Executor: ", GameTitle = "Spiel: Lädt...",
		FeatList = "• Haupt: Noclip, Fly, Inf Sprung, TP Spieler\n• ESP: Blauer Körper, Namen/Dist, Linien\n• Tycoon: TP Basis, Auto Einsammeln\n• Einstellungen: Sprachen, Themen, UI Sperren, Config",
		Noclip = "Noclip", Fullbright = "Fullbright", WalkSpeed = "Geschwindigkeit (1-200):", Fly = "Fliegen (Fly)", FlySpeed = "Fluggeschwindigkeit (1-200):", InfJump = "Unendlicher Sprung",
		Rejoin = "Neu verbinden", ServerHop = "Server wechseln", TPPlayerBtn = "TP zum Spieler", SelectPlayer = "Spieler auswählen...", JoinNotif = " hat den Server betreten", LeaveNotif = " hat den Server verlassen",
		ToggleNotifs = "Beitritts-/Austritts-Benachrichtigungen", ESPChams = "ESP Blauer Körper (Chams)", ESPName = "ESP Namen & Distanz", ESPTracers = "ESP Linien (Tracers)",
		TPTycoon = "TP zum Tycoon", SaveBase = "Basisposition speichern", AutoCollect = "Auto Geld einsammeln", SaveCollector = "Sammlerposition speichern",
		LanguageBtn = "Sprache: Deutsch", ThemeBtn = "Thema: ", UILock = "UI-Position sperren", UIUnlock = "UI-Position entsperren",
		SaveConfig = "Konfiguration speichern", LoadConfig = "Konfiguration laden", AutoSaveConfig = "Auto-Speichern Config", AutoLoadConfig = "Auto-Laden Config",
		BaseSaved = "Basisposition gespeichert!", CollectorSaved = "Sammlerposition gespeichert!", FirstSaveBase = "Zuerst Basis speichern!", FirstSaveCollector = "Zuerst Sammler speichern!",
		NoFS = "Dateisystem nicht unterstützt!", NoFile = "Konfigurationsdatei nicht gefunden!", CorruptJSON = "Konfigurationsdatei beschädigt!", TargetNotFound = "Zielspieler nicht gefunden!", ConfigSavedMsg = "Konfiguration Gespeichert!", ConfigLoadedMsg = "Konfiguration Geladen!", SaveFailedMsg = "Fehler beim Speichern!"
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
autoCollectActive = false
local espActive = false
local espNameActive = false
local espTracersActive = false
mainNoclipActive = false
fullbrightActive = false
flyActive = false
infJumpActive = false
local uiLocked = false
local joinLeaveNotifsActive = true
local autoSaveConfigActive = false
local autoLoadConfigActive = false

local walkSpeedValue = 16
local flySpeedValue = 50

local collectorPosition = nil
local basePosition = nil
local selectedTpTarget = nil

local function getExecutorName()
	local ok, name = pcall(function()
		if type(identifyexecutor) == "function" then
			return identifyexecutor()
		elseif type(getexecutorname) == "function" then
			return getexecutorname()
		end
		return "Delta"
	end)
	return ok and name or "Delta"
end

local saveConfig, loadConfig

-- =====================================================================
-- 3. NOCLIP Y RESTAURACIÓN SEGURA
-- =====================================================================
local function saveOriginalCollisions(char)
	if not char then return end
	if not cleanupState.characterCollisionStates[char] then
		cleanupState.characterCollisionStates[char] = {}
	end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") and cleanupState.characterCollisionStates[char][part] == nil then
			cleanupState.characterCollisionStates[char][part] = part.CanCollide
		end
	end
end

local function updateNoclipExecution()
	local hasActiveOwners = mainNoclipActive
	if not hasActiveOwners then
		for _, active in pairs(noclipOwners) do
			if active then
				hasActiveOwners = true
				break
			end
		end
	end

	if hasActiveOwners then
		if not noclipConnection then
			noclipConnection = RunService.Stepped:Connect(function()
				local curChar = player.Character
				if curChar then
					saveOriginalCollisions(curChar)
					for _, part in pairs(curChar:GetDescendants()) do
						if part:IsA("BasePart") then
							part.CanCollide = false
						end
					end
				end
			end)
			registerConnection(noclipConnection)
		end
	else
		if noclipConnection then
			removeConnection(noclipConnection)
			noclipConnection:Disconnect()
			noclipConnection = nil
		end
		if player.Character then
			restoreCharacterStates(player.Character)
		end
	end
end

local function setNoclipOwner(ownerKey, state)
	noclipOwners[ownerKey] = state and true or nil
	updateNoclipExecution()
end

local function toggleMainNoclip(state)
	mainNoclipActive = state
	updateNoclipExecution()
end

local function toggleFullbright(state)
	fullbrightActive = state
	if fullbrightActive then
		for _, prop in ipairs({"Brightness", "ClockTime", "GlobalShadows", "Ambient", "OutdoorAmbient", "ExposureCompensation"}) do
			if cleanupState.originalLighting[prop] ~= nil and cleanupState.modifiedLightingProps[prop] == nil then
				cleanupState.modifiedLightingProps[prop] = Lighting[prop]
			end
		end
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.GlobalShadows = false
		Lighting.Ambient = Color3.fromRGB(180, 180, 180)
	else
		restoreLighting()
	end
end

local function toggleFly(state)
	flyActive = state
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	
	if flyActive then
		if not char or not hrp or not hum then
			flyActive = false
			return
		end

		if hum:GetAttribute("OriginalPlatformStand") == nil then
			hum:SetAttribute("OriginalPlatformStand", hum.PlatformStand)
		end

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

		if flyConnection then 
			removeConnection(flyConnection)
			flyConnection:Disconnect() 
			flyConnection = nil 
		end
		
		flyConnection = RunService.RenderStepped:Connect(function()
			local currentCamera = getCurrentCamera()
			local currentChar = player.Character
			local currentHrp = currentChar and currentChar:FindFirstChild("HumanoidRootPart")
			local currentHum = currentChar and currentChar:FindFirstChildOfClass("Humanoid")
			if not flyActive or not currentHrp or not currentHum or not currentCamera then return end
			
			local currentBg = currentHrp:FindFirstChild("FlyBodyGyro")
			local currentBv = currentHrp:FindFirstChild("FlyBodyVelocity")
			if not currentBg or not currentBv then return end

			currentBg.CFrame = currentCamera.CFrame
			
			if currentHum.MoveDirection.Magnitude > 0 then
				local relMove = currentCamera.CFrame:VectorToObjectSpace(currentHum.MoveDirection)
				local flyVector = (currentCamera.CFrame.LookVector * -relMove.Z) + (currentCamera.CFrame.RightVector * relMove.X)
				currentBv.Velocity = flyVector.Magnitude > 0 and (flyVector.Unit * flySpeedValue) or Vector3.zero
			else
				currentBv.Velocity = Vector3.zero
			end
		end)
		registerConnection(flyConnection)
	else
		if flyConnection then 
			removeConnection(flyConnection)
			flyConnection:Disconnect() 
			flyConnection = nil 
		end
		if hrp then
			local bv = hrp:FindFirstChild("FlyBodyVelocity")
			local bg = hrp:FindFirstChild("FlyBodyGyro")
			if bv then bv:Destroy() end
			if bg then bg:Destroy() end
		end
		if hum and hum:GetAttribute("OriginalPlatformStand") ~= nil then
			hum.PlatformStand = hum:GetAttribute("OriginalPlatformStand")
			hum:SetAttribute("OriginalPlatformStand", nil)
		end
	end
end

-- =====================================================================
-- 4. AUTO-COLLECT BLINDADO CON TOKENS ATÓMICOS ESTRICTOS (V4.4)
-- =====================================================================
local activeCollectSession = 0

local function performCollect(mySession)
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	
	local attempts = 0
	while not hrp and autoCollectActive and mySession == activeCollectSession and attempts < 15 do
		task.wait(0.2)
		char = player.Character
		hrp = char and char:FindFirstChild("HumanoidRootPart")
		attempts = attempts + 1
	end

	if not autoCollectActive or not hrp or not collectorPosition then return false end
	if mySession ~= activeCollectSession then return false end
	if player.Character ~= char then return false end

	local tempPos = hrp.CFrame
	cleanupState.lastTempPos = tempPos -- Guardado para resguardo del limpiador global
	setNoclipOwner("AutoCollect_" .. mySession, true)
	
	local success = pcall(function()
		hrp.CFrame = collectorPosition
		hrp.Velocity = Vector3.new(0, -10, 0)

		local elapsed = 0
		while elapsed < 0.8 do
			-- Verificación estricta por sesión en cada milisegundo de espera
			if not autoCollectActive or mySession ~= activeCollectSession or player.Character ~= char or not hrp.Parent then
				error("Session interrupted")
			end
			task.wait(0.1)
			elapsed = elapsed + 0.1
		end
	end)

	-- Retorno atómico garantizado: exige que la sesión siga siendo exactamente la misma que inició el teletransporte
	pcall(function()
		local curChar = player.Character
		local curHrp = curChar and curChar:FindFirstChild("HumanoidRootPart")
		if curChar == char and curHrp and curHrp.Parent and mySession == activeCollectSession then
			curHrp.CFrame = tempPos
		end
	end)

	setNoclipOwner("AutoCollect_" .. mySession, false)
	if cleanupState.lastTempPos == tempPos then
		cleanupState.lastTempPos = nil
	end
	return success
end

local function collectMoneyRoutine()
	activeCollectSession = activeCollectSession + 1
	local mySession = activeCollectSession

	while autoCollectActive and mySession == activeCollectSession do
		pcall(function()
			performCollect(mySession)
		end)

		local waitElapsed = 0
		while waitElapsed < 3 do
			if not autoCollectActive or mySession ~= activeCollectSession then break end
			task.wait(0.2)
			waitElapsed = waitElapsed + 0.2
		end
	end
	setNoclipOwner("AutoCollect_" .. mySession, false)
end

local function setAutoCollectState(state)
	autoCollectActive = state
	if collectButton then
		collectButton.BackgroundColor3 = autoCollectActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	end
	if autoCollectActive then
		task.spawn(collectMoneyRoutine)
	else
		activeCollectSession = activeCollectSession + 1
		setNoclipOwner("AutoCollect", false)
	end
	if autoSaveConfigActive then saveConfig(true) end
end

local function setupCharacter(char)
	cleanupState.respawnToken = cleanupState.respawnToken + 1
	local myRespawnToken = cleanupState.respawnToken

	task.wait(0.2)
	if myRespawnToken ~= cleanupState.respawnToken or player.Character ~= char or not char.Parent then
		return
	end

	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		if hum:GetAttribute("OriginalWalkSpeed") == nil then
			hum:SetAttribute("OriginalWalkSpeed", hum.WalkSpeed)
		end
		-- Aplicamos la velocidad configurada solo si difiere del estándar o si el usuario la ajustó
		if walkSpeedValue ~= 16 then
			hum.WalkSpeed = walkSpeedValue
		end
	end

	if mainNoclipActive then toggleMainNoclip(true) end
	if flyActive then
		toggleFly(false)
		toggleFly(true)
	end
	if autoCollectActive then
		activeCollectSession = activeCollectSession + 1
		task.spawn(collectMoneyRoutine)
	end
end

if player.Character then
	setupCharacter(player.Character)
end

registerConnection(player.CharacterAdded:Connect(setupCharacter))

registerConnection(player.CharacterRemoving:Connect(function(oldChar)
	setNoclipOwner("AutoCollect", false)
	restoreCharacterStates(oldChar)
end))

local function toggleInfJump(state)
	infJumpActive = state
	if infJumpActive then
		if infJumpConnection then 
			removeConnection(infJumpConnection)
			infJumpConnection:Disconnect() 
		end
		infJumpConnection = UserInputService.JumpRequest:Connect(function()
			local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if infJumpActive and hum and hum:GetState() ~= Enum.HumanoidStateType.Dead then
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end)
		registerConnection(infJumpConnection)
	else
		if infJumpConnection then
			removeConnection(infJumpConnection)
			infJumpConnection:Disconnect()
			infJumpConnection = nil
		end
	end
end

-- =====================================================================
-- 5. INTERFAZ GRÁFICA Y CÁMARA DINÁMICA
-- =====================================================================
local function updateViewportMetrics()
	local cam = getCurrentCamera()
	local vp = cam and cam.ViewportSize or Vector2.new(800, 600)
	local w = math.clamp(vp.X * 0.9, 220, 480)
	local h = math.clamp(vp.Y * 0.65, 200, 320)
	return w, h
end

local initW, initH = updateViewportMetrics()

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Mega Hub Universal De Tycoons (by jacoboeu8)"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, initW, 0, initH)
mainFrame.Position = UDim2.new(0.5, -initW/2, 0.4, -initH/2)
mainFrame.BackgroundColor3 = themes.Cyan.Main
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

registerConnection(RunService.RenderStepped:Connect(function()
	local cam = getCurrentCamera()
	if cam then
		local newW, newH = updateViewportMetrics()
		if mainFrame and mainFrame.Parent and (mainFrame.AbsoluteSize.X ~= newW or mainFrame.AbsoluteSize.Y ~= newH) then
			mainFrame.Size = UDim2.new(0, newW, 0, newH)
		end
	end
end))

local function showTopNotification(text)
	local notifLabel = Instance.new("TextLabel")
	notifLabel.Size = UDim2.new(0, 260, 0, 32)
	notifLabel.Position = UDim2.new(0.5, -130, 0.05, 0)
	notifLabel.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
	notifLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	notifLabel.Font = Enum.Font.SourceSansBold
	notifLabel.TextSize = 12
	notifLabel.Text = text
	notifLabel.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = notifLabel

	task.delay(3.5, function()
		if notifLabel and notifLabel.Parent then notifLabel:Destroy() end
	end)
end

local function showRightNotification(text, isJoin)
	if not joinLeaveNotifsActive then return end
	local notifLabel = Instance.new("TextLabel")
	notifLabel.Size = UDim2.new(0, 180, 0, 28)
	notifLabel.Position = UDim2.new(1, -190, 0.45, 0)
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
		if notifLabel and notifLabel.Parent then notifLabel:Destroy() end
	end)
end

registerConnection(Players.PlayerAdded:Connect(function(p)
	showRightNotification("[+] " .. p.Name .. translations[currentLang].JoinNotif, true)
end))

registerConnection(Players.PlayerRemoving:Connect(function(p)
	showRightNotification("[-] " .. p.Name .. translations[currentLang].LeaveNotif, false)
	if selectedTpTarget == p then selectedTpTarget = nil end
	if activeDrawings[p.UserId] then
		pcall(function() activeDrawings[p.UserId]:Remove() end)
		activeDrawings[p.UserId] = nil
	end
	cleanPlayerChamsConns(p.UserId)
	cleanPlayerNamesConns(p.UserId)
end))

-- =====================================================================
-- 6. MÓDULO ESP AISLADO CON PURGA DE CONEXIONES OPTIMIZADA
-- =====================================================================
local function applyESP(targetPlayer)
	if targetPlayer == player then return end
	local userId = targetPlayer.UserId
	cleanPlayerChamsConns(userId)

	local function addHighlight(char)
		if not espActive or not char or char:FindFirstChild("ESPHighlight") then return end
		local highlight = Instance.new("Highlight")
		highlight.Name = "ESPHighlight"
		highlight:SetAttribute("HubOwner", "MegaHub")
		highlight.Adornee = char
		highlight.FillColor = Color3.fromRGB(0, 150, 255)
		highlight.FillTransparency = 0.3
		highlight.OutlineColor = Color3.fromRGB(0, 255, 255)
		highlight.OutlineTransparency = 0
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Parent = char
	end

	if targetPlayer.Character then addHighlight(targetPlayer.Character) end

	local conn = targetPlayer.CharacterAdded:Connect(function(newChar)
		task.wait(0.5)
		if espActive and targetPlayer.Parent and targetPlayer.Character == newChar then
			addHighlight(newChar)
		end
	end)
	playerChamsConnections[userId] = { conn }
	table.insert(espChamsConnections, conn)
end

local function removeESP(targetPlayer)
	if targetPlayer.Character and targetPlayer.Character:FindFirstChild("ESPHighlight") then
		local h = targetPlayer.Character.ESPHighlight
		if h:GetAttribute("HubOwner") == "MegaHub" then h:Destroy() end
	end
	cleanPlayerChamsConns(targetPlayer.UserId)
end

local function toggleESPState(state)
	espActive = state
	if not espActive then
		cleanChamsConnections()
		for _, p in pairs(Players:GetPlayers()) do removeESP(p) end
	else
		for _, p in pairs(Players:GetPlayers()) do applyESP(p) end
	end
end

local function applyNameESP(targetPlayer)
	if targetPlayer == player then return end
	local userId = targetPlayer.UserId
	cleanPlayerNamesConns(userId)

	local function addBillboard(char)
		if not espNameActive or not char or char:FindFirstChild("ESPNameTag") then return end
		local head = char:WaitForChild("Head", 2)
		if not head or not char.Parent then return end

		local bb = Instance.new("BillboardGui")
		bb.Name = "ESPNameTag"
		bb:SetAttribute("HubOwner", "MegaHub")
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

	local conn = targetPlayer.CharacterAdded:Connect(function(newChar)
		task.wait(0.5)
		if espNameActive and targetPlayer.Parent and targetPlayer.Character == newChar then
			addBillboard(newChar)
		end
	end)
	playerNamesConnections[userId] = { conn }
	table.insert(espNameConnections, conn)
end

local function removeNameESP(targetPlayer)
	if targetPlayer.Character and targetPlayer.Character:FindFirstChild("ESPNameTag") then
		local t = targetPlayer.Character.ESPNameTag
		if t:GetAttribute("HubOwner") == "MegaHub" then t:Destroy() end
	end
	cleanPlayerNamesConns(targetPlayer.UserId)
end

local function toggleNameESPState(state)
	espNameActive = state
	if not espNameActive then
		cleanNameConnections()
		for _, p in pairs(Players:GetPlayers()) do removeNameESP(p) end
	else
		for _, p in pairs(Players:GetPlayers()) do applyNameESP(p) end
	end
end

registerConnection(Players.PlayerAdded:Connect(function(p)
	if p ~= player then
		if espActive then applyESP(p) end
		if espNameActive then applyNameESP(p) end
	end
end))

local function toggleTracersState(state)
	if not hasDrawing then
		showTopNotification("Drawing API not supported by executor!")
		espTracersActive = false
		return
	end
	espTracersActive = state
	if not espTracersActive then
		for _, line in pairs(activeDrawings) do
			pcall(function() line:Remove() end)
		end
		activeDrawings = {}
	end
end

registerConnection(RunService.RenderStepped:Connect(function()
	local curCamera = getCurrentCamera()
	local curHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

	if espNameActive then
		local activePlayers = Players:GetPlayers()
		for _, p in pairs(activePlayers) do
			if p ~= player and p.Character then
				local tag = p.Character:FindFirstChild("ESPNameTag")
				local hrpTarget = p.Character:FindFirstChild("HumanoidRootPart")
				if tag and tag:GetAttribute("HubOwner") == "MegaHub" and tag:FindFirstChild("Label") and hrpTarget and curHrp then
					local dist = math.floor((curHrp.Position - hrpTarget.Position).Magnitude)
					tag.Label.Text = p.Name .. " [" .. dist .. "m]"
				end
			end
		end
	end

	if espTracersActive and hasDrawing and curCamera then
		local activePlayers = Players:GetPlayers()
		local currentIds = {}
		for _, p in pairs(activePlayers) do
			if p ~= player then
				currentIds[p.UserId] = true
				if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
					local targetHrp = p.Character.HumanoidRootPart
					local vector, onScreen = curCamera:WorldToViewportPoint(targetHrp.Position)
					if onScreen then
						local success, line = pcall(function()
							local l = activeDrawings[p.UserId] or Drawing.new("Line")
							l.Visible = true
							l.From = Vector2.new(curCamera.ViewportSize.X / 2, curCamera.ViewportSize.Y)
							l.To = Vector2.new(vector.X, vector.Y)
							l.Color = Color3.fromRGB(0, 200, 255)
							l.Thickness = 1.5
							l.Transparency = 0.8
							return l
						end)
						if success then activeDrawings[p.UserId] = line end
					elseif activeDrawings[p.UserId] then
						activeDrawings[p.UserId].Visible = false
					end
				elseif activeDrawings[p.UserId] then
					activeDrawings[p.UserId].Visible = false
				end
			end
		end
		for userId, line in pairs(activeDrawings) do
			if not currentIds[userId] then
				pcall(function() line:Remove() end)
				activeDrawings[userId] = nil
			end
		end
	end
end))

-- =====================================================================
-- 7. INTERFAZ GRÁFICA Y WIDGETS
-- =====================================================================
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 32)
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
titleLabel.TextSize = 11
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 24, 0, 24)
closeButton.Position = UDim2.new(1, -28, 0, 4)
closeButton.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.Parent = topBar

toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 70, 0, 26)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleButton.Text = "Toggle"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.Visible = false
toggleButton.Active = true
toggleButton.Draggable = true
toggleButton.Parent = screenGui

statsWidget = Instance.new("Frame")
statsWidget.Name = "StatsWidget"
statsWidget.Size = UDim2.new(0, 70, 0, 26)
statsWidget.Position = UDim2.new(1, -80, 0, 10)
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
statsText.TextSize = 9
statsText.Parent = statsWidget

local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 100, 1, -32)
sidebar.Position = UDim2.new(0, 0, 0, 32)
sidebar.BackgroundColor3 = themes.Cyan.Top
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -105, 1, -40)
contentFrame.Position = UDim2.new(0, 102, 0, 36)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local menuTab = Instance.new("ScrollingFrame")
menuTab.Size = UDim2.new(1, 0, 1, 0)
menuTab.BackgroundTransparency = 1
menuTab.CanvasSize = UDim2.new(0, 0, 0, 230)
menuTab.ScrollBarThickness = 4
menuTab.Visible = true
menuTab.Parent = contentFrame

local mainTab = Instance.new("ScrollingFrame")
mainTab.Size = UDim2.new(1, 0, 1, 0)
mainTab.BackgroundTransparency = 1
mainTab.CanvasSize = UDim2.new(0, 0, 0, 200)
mainTab.ScrollBarThickness = 4
mainTab.Visible = false
mainTab.Parent = contentFrame

local espTab = Instance.new("ScrollingFrame")
espTab.Size = UDim2.new(1, 0, 1, 0)
espTab.BackgroundTransparency = 1
espTab.CanvasSize = UDim2.new(0, 0, 0, 120)
espTab.ScrollBarThickness = 4
espTab.Visible = false
espTab.Parent = contentFrame

local tycoonTab = Instance.new("ScrollingFrame")
tycoonTab.Size = UDim2.new(1, 0, 1, 0)
tycoonTab.BackgroundTransparency = 1
tycoonTab.CanvasSize = UDim2.new(0, 0, 0, 150)
tycoonTab.ScrollBarThickness = 4
tycoonTab.Visible = false
tycoonTab.Parent = contentFrame

local settingsTab = Instance.new("ScrollingFrame")
settingsTab.Size = UDim2.new(1, 0, 1, 0)
settingsTab.BackgroundTransparency = 1
settingsTab.CanvasSize = UDim2.new(0, 0, 0, 210)
settingsTab.ScrollBarThickness = 4
settingsTab.Visible = false
settingsTab.Parent = contentFrame

-- MENÚ Y WIDGET DE RENDIMIENTO
local profileCard = Instance.new("Frame")
profileCard.Size = UDim2.new(0.95, 0, 0, 55)
profileCard.Position = UDim2.new(0, 0, 0, 5)
profileCard.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
profileCard.BorderSizePixel = 0
profileCard.Parent = menuTab

local avatarImage = Instance.new("ImageLabel")
avatarImage.Size = UDim2.new(0, 42, 0, 42)
avatarImage.Position = UDim2.new(0, 6, 0, 6)
avatarImage.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
avatarImage.BorderSizePixel = 0
avatarImage.Parent = profileCard

task.spawn(function()
	pcall(function()
		local content, isReady = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
		if isReady and content then avatarImage.Image = content end
	end)
end)

local welcomeLabel = Instance.new("TextLabel")
welcomeLabel.Size = UDim2.new(1, -55, 0, 16)
welcomeLabel.Position = UDim2.new(0, 52, 0, 6)
welcomeLabel.BackgroundTransparency = 1
welcomeLabel.Text = translations.EN.Welcome .. player.Name
welcomeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
welcomeLabel.Font = Enum.Font.SourceSansBold
welcomeLabel.TextSize = 11
welcomeLabel.TextXAlignment = Enum.TextXAlignment.Left
welcomeLabel.Parent = profileCard

local executorLabel = Instance.new("TextLabel")
executorLabel.Size = UDim2.new(1, -55, 0, 16)
executorLabel.Position = UDim2.new(0, 52, 0, 26)
executorLabel.BackgroundTransparency = 1
executorLabel.Text = translations.EN.Executor .. getExecutorName()
executorLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
executorLabel.Font = Enum.Font.SourceSans
executorLabel.TextSize = 10
executorLabel.TextXAlignment = Enum.TextXAlignment.Left
executorLabel.Parent = profileCard

local featuresFrame = Instance.new("Frame")
featuresFrame.Size = UDim2.new(0.95, 0, 0, 70)
featuresFrame.Position = UDim2.new(0, 0, 0, 65)
featuresFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
featuresFrame.BorderSizePixel = 0
featuresFrame.Parent = menuTab

local featList = Instance.new("TextLabel")
featList.Size = UDim2.new(1, -8, 1, -8)
featList.Position = UDim2.new(0, 4, 0, 4)
featList.BackgroundTransparency = 1
featList.Text = translations.EN.FeatList
featList.TextColor3 = Color3.fromRGB(200, 200, 200)
featList.Font = Enum.Font.SourceSans
featList.TextSize = 10
featList.TextWrapped = true
featList.TextYAlignment = Enum.TextYAlignment.Top
featList.TextXAlignment = Enum.TextXAlignment.Left
featList.Parent = featuresFrame

local notifsToggleBtn = Instance.new("TextButton")
notifsToggleBtn.Size = UDim2.new(0.95, 0, 0, 25)
notifsToggleBtn.Position = UDim2.new(0, 0, 0, 140)
notifsToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 200, 40)
notifsToggleBtn.Text = translations.EN.ToggleNotifs
notifsToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
notifsToggleBtn.Font = Enum.Font.SourceSansBold
notifsToggleBtn.TextSize = 10
notifsToggleBtn.Parent = menuTab

registerConnection(notifsToggleBtn.MouseButton1Click:Connect(function()
	joinLeaveNotifsActive = not joinLeaveNotifsActive
	notifsToggleBtn.BackgroundColor3 = joinLeaveNotifsActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
end))

local statsWidgetMenu = Instance.new("Frame")
statsWidgetMenu.Size = UDim2.new(0.95, 0, 0, 36)
statsWidgetMenu.Position = UDim2.new(0, 0, 0, 170)
statsWidgetMenu.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
statsWidgetMenu.BorderSizePixel = 0
statsWidgetMenu.Parent = menuTab

local gameIcon = Instance.new("ImageLabel")
gameIcon.Size = UDim2.new(0, 26, 0, 26)
gameIcon.Position = UDim2.new(0, 5, 0.5, -13)
gameIcon.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
gameIcon.BorderSizePixel = 0
gameIcon.Image = "rbxassetid://0"
gameIcon.Parent = statsWidgetMenu

local gameTitleLabel = Instance.new("TextLabel")
gameTitleLabel.Size = UDim2.new(0.55, 0, 1, 0)
gameTitleLabel.Position = UDim2.new(0, 34, 0, 0)
gameTitleLabel.BackgroundTransparency = 1
gameTitleLabel.Text = translations.EN.GameTitle
gameTitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
gameTitleLabel.Font = Enum.Font.SourceSansBold
gameTitleLabel.TextSize = 9
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
pingFpsLabel.TextSize = 9
pingFpsLabel.TextXAlignment = Enum.TextXAlignment.Right
pingFpsLabel.Parent = statsWidgetMenu

task.spawn(function()
	pcall(function()
		local gameInfo = MarketplaceService:GetProductInfo(game.PlaceId)
		if gameInfo then
			gameTitleLabel.Text = "Juego:\n" .. gameInfo.Name
			gameIcon.Image = "rbxassetid://" .. (gameInfo.IconImageAssetId or 0)
		end
	end)
end)

local frameCount = 0
local lastTime = os.clock()

registerConnection(RunService.RenderStepped:Connect(function()
	if not statsWidget.Visible and not (mainFrame.Visible and menuTab.Visible) then return end
	frameCount = frameCount + 1
	local currentTime = os.clock()
	if currentTime - lastTime >= 1 then
		local fps = math.floor(frameCount / (currentTime - lastTime))
		local ping = 0
		pcall(function()
			ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
		end)
		local textString = "Ping: " .. ping .. "ms\nFPS: " .. fps
		pingFpsLabel.Text = textString
		statsText.Text = textString
		frameCount = 0
		lastTime = currentTime
	end
end))

-- NAVEGACIÓN
local function createNavBtn(text, posY)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 90, 0, 26)
	btn.Position = UDim2.new(0, 5, 0, posY)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 11
	btn.Parent = sidebar
	return btn
end

local menuBtn = createNavBtn(translations.EN.TabMenu, 8)
local mainBtn = createNavBtn(translations.EN.TabMain, 38)
local espBtn = createNavBtn(translations.EN.TabESP, 68)
local tycoonBtn = createNavBtn(translations.EN.TabTycoon, 98)
local settingsBtn = createNavBtn(translations.EN.TabSettings, 128)

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

registerConnection(menuBtn.MouseButton1Click:Connect(function() switchTab(menuTab, menuBtn) end))
registerConnection(mainBtn.MouseButton1Click:Connect(function() switchTab(mainTab, mainBtn) end))
registerConnection(espBtn.MouseButton1Click:Connect(function() switchTab(espTab, espBtn) end))
registerConnection(tycoonBtn.MouseButton1Click:Connect(function() switchTab(tycoonTab, tycoonBtn) end))
registerConnection(settingsBtn.MouseButton1Click:Connect(function() switchTab(settingsTab, settingsBtn) end))

-- CONTROLES PRINCIPALES
local function createMainToggle(text, posY, posX)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.46, 0, 0, 25)
	btn.Position = UDim2.new(posX or 0, 0, 0, posY)
	btn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 10
	btn.Parent = mainTab
	return btn
end

local function createMainInput(labelText, defaultVal, posY)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(0.95, 0, 0, 25)
	container.Position = UDim2.new(0, 0, 0, posY)
	container.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	container.BorderSizePixel = 0
	container.Parent = mainTab

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(0.6, 0, 1, 0)
	label.Position = UDim2.new(0, 8, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.SourceSansBold
	label.TextSize = 10
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = container

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0.32, 0, 0.7, 0)
	box.Position = UDim2.new(0.65, 0, 0.15, 0)
	box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	box.Text = tostring(defaultVal)
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.Font = Enum.Font.SourceSansBold
	box.TextSize = 10
	box.Parent = container

	return box
end

noclipMainBtn = createMainToggle(translations.EN.Noclip, 0, 0)
fullbrightBtn = createMainToggle(translations.EN.Fullbright, 0, 0.49)
local walkSpeedBox = createMainInput(translations.EN.WalkSpeed, walkSpeedValue, 28)
flyBtn = createMainToggle(translations.EN.Fly, 56, 0)
infJumpBtn = createMainToggle(translations.EN.InfJump, 56, 0.49)
local flySpeedBox = createMainInput(translations.EN.FlySpeed, flySpeedValue, 84)
local rejoinBtn = createMainToggle(translations.EN.Rejoin, 112, 0)
rejoinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
local serverHopBtn = createMainToggle(translations.EN.ServerHop, 112, 0.49)
serverHopBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

local tpPlayerSelectBtn = Instance.new("TextButton")
tpPlayerSelectBtn.Size = UDim2.new(0.6, 0, 0, 25)
tpPlayerSelectBtn.Position = UDim2.new(0, 0, 0, 140)
tpPlayerSelectBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
tpPlayerSelectBtn.Text = translations.EN.SelectPlayer
tpPlayerSelectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpPlayerSelectBtn.Font = Enum.Font.SourceSansBold
tpPlayerSelectBtn.TextSize = 10
tpPlayerSelectBtn.Parent = mainTab

local tpPlayerActionBtn = Instance.new("TextButton")
tpPlayerActionBtn.Size = UDim2.new(0.33, 0, 0, 25)
tpPlayerActionBtn.Position = UDim2.new(0.62, 0, 0, 140)
tpPlayerActionBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
tpPlayerActionBtn.Text = translations.EN.TPPlayerBtn
tpPlayerActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpPlayerActionBtn.Font = Enum.Font.SourceSansBold
tpPlayerActionBtn.TextSize = 10
tpPlayerActionBtn.Parent = mainTab

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
	if not selectedTpTarget or not table.find(plist, selectedTpTarget) then
		selectedTpTarget = plist[1]
	else
		for i, p in ipairs(plist) do
			if p == selectedTpTarget then
				selectedTpTarget = plist[(i % #plist) + 1]
				break
			end
		end
	end
	tpPlayerSelectBtn.Text = selectedTpTarget.Name
end

registerConnection(tpPlayerSelectBtn.MouseButton1Click:Connect(cycleTpPlayer))

registerConnection(noclipMainBtn.MouseButton1Click:Connect(function()
	toggleMainNoclip(not mainNoclipActive)
	noclipMainBtn.BackgroundColor3 = mainNoclipActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	if autoSaveConfigActive then saveConfig(true) end
end))

registerConnection(fullbrightBtn.MouseButton1Click:Connect(function()
	toggleFullbright(not fullbrightActive)
	fullbrightBtn.BackgroundColor3 = fullbrightActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	if autoSaveConfigActive then saveConfig(true) end
end))

registerConnection(walkSpeedBox.FocusLost:Connect(function()
	local num = tonumber(walkSpeedBox.Text)
	if num and num == num and math.abs(num) ~= math.huge then
		walkSpeedValue = math.clamp(math.floor(num), 1, 200)
		walkSpeedBox.Text = tostring(walkSpeedValue)
		local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = walkSpeedValue end
	else
		walkSpeedBox.Text = tostring(walkSpeedValue)
	end
	if autoSaveConfigActive then saveConfig(true) end
end))

registerConnection(flyBtn.MouseButton1Click:Connect(function()
	toggleFly(not flyActive)
	flyBtn.BackgroundColor3 = flyActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	if autoSaveConfigActive then saveConfig(true) end
end))

registerConnection(infJumpBtn.MouseButton1Click:Connect(function()
	toggleInfJump(not infJumpActive)
	infJumpBtn.BackgroundColor3 = infJumpActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	if autoSaveConfigActive then saveConfig(true) end
end))

registerConnection(flySpeedBox.FocusLost:Connect(function()
	local num = tonumber(flySpeedBox.Text)
	if num and num == num and math.abs(num) ~= math.huge then
		flySpeedValue = math.clamp(math.floor(num), 1, 200)
		flySpeedBox.Text = tostring(flySpeedValue)
	else
		flySpeedBox.Text = tostring(flySpeedValue)
	end
	if autoSaveConfigActive then saveConfig(true) end
end))

registerConnection(rejoinBtn.MouseButton1Click:Connect(function()
	local ok, err = pcall(function() TeleportService:Teleport(game.PlaceId, player) end)
	if not ok then showTopNotification("Rejoin failed: " .. tostring(err)) end
end))

registerConnection(serverHopBtn.MouseButton1Click:Connect(function()
	local ok, err = pcall(function()
		local success, response = pcall(function()
			return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
		end)
		if not success or not response then
			showTopNotification("Server hop query failed!")
			return
		end
		local servers = HttpService:JSONDecode(response)
		local targetServer = nil
		if servers and type(servers.data) == "table" then
			for _, s in pairs(servers.data) do
				if type(s) == "table" and s.id and s.id ~= game.JobId and type(s.playing) == "number" and type(s.maxPlayers) == "number" and s.playing < s.maxPlayers then
					targetServer = s.id
					break
				end
			end
		end
		if targetServer then
			TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServer, player)
		else
			showTopNotification("No alternate server found!")
		end
	end)
	if not ok then showTopNotification("Server hop error!") end
end))

registerConnection(tpPlayerActionBtn.MouseButton1Click:Connect(function()
	if selectedTpTarget and selectedTpTarget.Parent and selectedTpTarget.Character then
		local targetHrp = selectedTpTarget.Character:FindFirstChild("HumanoidRootPart")
		local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if targetHrp and hrp then
			setNoclipOwner("Teleport", true)
			hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 3)
			task.wait(0.1)
			setNoclipOwner("Teleport", false)
		else
			showTopNotification(translations[currentLang].TargetNotFound)
		end
	else
		showTopNotification(translations[currentLang].TargetNotFound)
	end
end))

-- ESP TAB
local function createEspButton(text, posY)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.95, 0, 0, 26)
	btn.Position = UDim2.new(0, 0, 0, posY)
	btn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 11
	btn.Parent = espTab
	return btn
end

local espPlayerBtn = createEspButton(translations.EN.ESPChams, 0)
local espNameBtn = createEspButton(translations.EN.ESPName, 32)
local espTracersBtn = createEspButton(translations.EN.ESPTracers, 64)

registerConnection(espPlayerBtn.MouseButton1Click:Connect(function()
	toggleESPState(not espActive)
	espPlayerBtn.BackgroundColor3 = espActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	if autoSaveConfigActive then saveConfig(true) end
end))

registerConnection(espNameBtn.MouseButton1Click:Connect(function()
	toggleNameESPState(not espNameActive)
	espNameBtn.BackgroundColor3 = espNameActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	if autoSaveConfigActive then saveConfig(true) end
end))

registerConnection(espTracersBtn.MouseButton1Click:Connect(function()
	toggleTracersState(not espTracersActive)
	espTracersBtn.BackgroundColor3 = espTracersActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	if autoSaveConfigActive then saveConfig(true) end
end))

-- TYCOON TAB
local function createTycoonBtn(text, posY, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.95, 0, 0, 26)
	btn.Position = UDim2.new(0, 0, 0, posY)
	btn.BackgroundColor3 = color or Color3.fromRGB(60, 60, 60)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 10
	btn.TextWrapped = true
	btn.Parent = tycoonTab
	return btn
end

local tpTycoonBtn = createTycoonBtn(translations.EN.TPTycoon, 0)
local saveBaseBtn = createTycoonBtn(translations.EN.SaveBase, 32)
collectButton = createTycoonBtn(translations.EN.AutoCollect, 64, Color3.fromRGB(200, 40, 40))
local saveCollectorBtn = createTycoonBtn(translations.EN.SaveCollector, 96)

registerConnection(tpTycoonBtn.MouseButton1Click:Connect(function()
	local dict = translations[currentLang]
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not basePosition then
		tpTycoonBtn.Text = dict.FirstSaveBase
		task.wait(1.5)
		tpTycoonBtn.Text = dict.TPTycoon
		return
	end
	if hrp then 
		setNoclipOwner("Teleport", true)
		hrp.CFrame = basePosition 
		setNoclipOwner("Teleport", false)
	end
end))

registerConnection(saveBaseBtn.MouseButton1Click:Connect(function()
	local dict = translations[currentLang]
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		basePosition = hrp.CFrame
		saveBaseBtn.Text = dict.BaseSaved
		saveBaseBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
		task.wait(1)
		saveBaseBtn.Text = dict.SaveBase
		saveBaseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		if autoSaveConfigActive then saveConfig(true) end
	end
end))

registerConnection(saveCollectorBtn.MouseButton1Click:Connect(function()
	local dict = translations[currentLang]
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		collectorPosition = hrp.CFrame + Vector3.new(0, 0.5, 0)
		saveCollectorBtn.Text = dict.CollectorSaved
		saveCollectorBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
		task.wait(1)
		saveCollectorBtn.Text = dict.SaveCollector
		saveCollectorBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		if autoSaveConfigActive then saveConfig(true) end
	end
end))

registerConnection(collectButton.MouseButton1Click:Connect(function()
	local dict = translations[currentLang]
	if not collectorPosition then
		collectButton.Text = dict.FirstSaveCollector
		task.wait(1.5)
		collectButton.Text = dict.AutoCollect
		return
	end
	setAutoCollectState(not autoCollectActive)
end))

-- CONFIGURACIÓN Y PERSISTENCIA (V4.4)
local function createSettingsBtn(text, posY, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.95, 0, 0, 24)
	btn.Position = UDim2.new(0, 0, 0, posY)
	btn.BackgroundColor3 = color or Color3.fromRGB(60, 60, 60)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 10
	btn.Parent = settingsTab
	return btn
end

local langToggleBtn = createSettingsBtn(translations.EN.LanguageBtn, 0)
local themeToggleBtn = createSettingsBtn(translations.EN.ThemeBtn .. currentThemeName, 26)
local lockUiBtn = createSettingsBtn(translations.EN.UILock, 52)
local saveConfigBtn = createSettingsBtn(translations.EN.SaveConfig, 78, Color3.fromRGB(0, 120, 180))
local loadConfigBtn = createSettingsBtn(translations.EN.LoadConfig, 104, Color3.fromRGB(0, 120, 180))
local autoSaveBtn = createSettingsBtn(translations.EN.AutoSaveConfig, 130, Color3.fromRGB(200, 40, 40))
local autoLoadBtn = createSettingsBtn(translations.EN.AutoLoadConfig, 156, Color3.fromRGB(200, 40, 40))

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
	themeToggleBtn.Text = dict.ThemeBtn .. currentThemeName
	lockUiBtn.Text = uiLocked and dict.UIUnlock or dict.UILock
	saveConfigBtn.Text = dict.SaveConfig
	loadConfigBtn.Text = dict.LoadConfig
	autoSaveBtn.Text = dict.AutoSaveConfig
	autoLoadBtn.Text = dict.AutoLoadConfig
end

local langOrder = {"EN", "ES", "PT", "FR", "DE"}
local currentLangIdx = 1

registerConnection(langToggleBtn.MouseButton1Click:Connect(function()
	currentLangIdx = (currentLangIdx % #langOrder) + 1
	updateLanguage(langOrder[currentLangIdx])
	if autoSaveConfigActive then saveConfig(true) end
end))

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
	themeToggleBtn.Text = translations[currentLang].ThemeBtn .. themeName
end

registerConnection(themeToggleBtn.MouseButton1Click:Connect(function()
	currentThemeIdx = (currentThemeIdx % #themeOrder) + 1
	applyTheme(themeOrder[currentThemeIdx])
	if autoSaveConfigActive then saveConfig(true) end
end))

registerConnection(lockUiBtn.MouseButton1Click:Connect(function()
	uiLocked = not uiLocked
	mainFrame.Draggable = not uiLocked
	toggleButton.Draggable = not uiLocked
	statsWidget.Draggable = not uiLocked
	local dict = translations[currentLang]
	lockUiBtn.Text = uiLocked and dict.UIUnlock or dict.UILock
	lockUiBtn.BackgroundColor3 = uiLocked and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(60, 60, 60)
	if autoSaveConfigActive then saveConfig(true) end
end))

saveConfig = function(isSilent)
	local dict = translations[currentLang]
	if not envFS.hasWrite then
		if not isSilent then showTopNotification(dict.NoFS) end
		return false
	end
	local data = {
		PlaceId = game.PlaceId,
		Lang = currentLang, Theme = currentThemeName, WalkSpeed = walkSpeedValue, FlySpeed = flySpeedValue,
		Noclip = mainNoclipActive, Fullbright = fullbrightActive, Fly = flyActive, InfJump = infJumpActive,
		ESPChams = espActive, ESPName = espNameActive, ESPTracers = espTracersActive, AutoCollect = autoCollectActive,
		JoinNotifs = joinLeaveNotifsActive, UILocked = uiLocked, AutoSave = autoSaveConfigActive, AutoLoad = autoLoadConfigActive,
		BasePos = basePosition and {basePosition:GetComponents()} or nil,
		CollectorPos = collectorPosition and {collectorPosition:GetComponents()} or nil
	}
	local ok, _ = pcall(function() writefile(configFileName, HttpService:JSONEncode(data)) end)
	if ok then
		if not isSilent then showTopNotification(dict.ConfigSavedMsg) end
		return true
	else
		if not isSilent then showTopNotification(dict.SaveFailedMsg) end
		return false
	end
end

loadConfig = function()
	local dict = translations[currentLang]
	if not envFS.hasRead or not envFS.hasIsFile then
		showTopNotification(dict.NoFS)
		return false
	end

	local fileExists = false
	pcall(function() fileExists = isfile(configFileName) end)
	if not fileExists then
		showTopNotification(dict.NoFile)
		return false
	end

	local successRead, fileContent = pcall(function() return readfile(configFileName) end)
	if not successRead or not fileContent then
		showTopNotification(dict.NoFile)
		return false
	end

	local ok, data = pcall(function() return HttpService:JSONDecode(fileContent) end)
	if not ok or type(data) ~= "table" then
		showTopNotification(dict.CorruptJSON)
		return false
	end

	if type(data.Lang) == "string" and translations[data.Lang] then
		for i, l in ipairs(langOrder) do if l == data.Lang then currentLangIdx = i break end end
		updateLanguage(data.Lang)
	end

	dict = translations[currentLang]

	if type(data.Theme) == "string" and themes[data.Theme] then
		for i, t in ipairs(themeOrder) do if t == data.Theme then currentThemeIdx = i break end end
		applyTheme(data.Theme)
	end

	if type(data.WalkSpeed) == "number" and data.WalkSpeed == data.WalkSpeed and math.abs(data.WalkSpeed) ~= math.huge then
		walkSpeedValue = math.clamp(math.floor(data.WalkSpeed), 1, 200)
		walkSpeedBox.Text = tostring(walkSpeedValue)
		local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = walkSpeedValue end
	end

	if type(data.FlySpeed) == "number" and data.FlySpeed == data.FlySpeed and math.abs(data.FlySpeed) ~= math.huge then
		flySpeedValue = math.clamp(math.floor(data.FlySpeed), 1, 200)
		flySpeedBox.Text = tostring(flySpeedValue)
	end

	local isSamePlace = (data.PlaceId == game.PlaceId)
	if isSamePlace then
		if type(data.BasePos) == "table" and #data.BasePos == 12 then
			local valid = true
			for _, v in ipairs(data.BasePos) do
				if type(v) ~= "number" or v ~= v or math.abs(v) == math.huge then valid = false break end
			end
			if valid then
				pcall(function() basePosition = CFrame.new(safeUnpack(data.BasePos)) end)
			end
		end

		if type(data.CollectorPos) == "table" and #data.CollectorPos == 12 then
			local valid = true
			for _, v in ipairs(data.CollectorPos) do
				if type(v) ~= "number" or v ~= v or math.abs(v) == math.huge then valid = false break end
			end
			if valid then
				pcall(function() collectorPosition = CFrame.new(safeUnpack(data.CollectorPos)) end)
			end
		end
	end

	if type(data.Noclip) == "boolean" and data.Noclip ~= mainNoclipActive then
		toggleMainNoclip(data.Noclip)
		noclipMainBtn.BackgroundColor3 = mainNoclipActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	end

	if type(data.Fullbright) == "boolean" and data.Fullbright ~= fullbrightActive then
		toggleFullbright(data.Fullbright)
		fullbrightBtn.BackgroundColor3 = fullbrightActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	end

	if type(data.Fly) == "boolean" and data.Fly ~= flyActive then
		toggleFly(data.Fly)
		flyBtn.BackgroundColor3 = flyActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	end

	if type(data.InfJump) == "boolean" and data.InfJump ~= infJumpActive then
		toggleInfJump(data.InfJump)
		infJumpBtn.BackgroundColor3 = infJumpActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	end

	if type(data.ESPChams) == "boolean" and data.ESPChams ~= espActive then
		toggleESPState(data.ESPChams)
		espPlayerBtn.BackgroundColor3 = espActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	end

	if type(data.ESPName) == "boolean" and data.ESPName ~= espNameActive then
		toggleNameESPState(data.ESPName)
		espNameBtn.BackgroundColor3 = espNameActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	end

	if type(data.ESPTracers) == "boolean" and data.ESPTracers ~= espTracersActive then
		toggleTracersState(data.ESPTracers)
		espTracersBtn.BackgroundColor3 = espTracersActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	end

	if type(data.JoinNotifs) == "boolean" then
		joinLeaveNotifsActive = data.JoinNotifs
		notifsToggleBtn.BackgroundColor3 = joinLeaveNotifsActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	end

	if type(data.UILocked) == "boolean" then
		uiLocked = data.UILocked
		mainFrame.Draggable = not uiLocked
		toggleButton.Draggable = not uiLocked
		statsWidget.Draggable = not uiLocked
		lockUiBtn.Text = uiLocked and dict.UIUnlock or dict.UILock
		lockUiBtn.BackgroundColor3 = uiLocked and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(60, 60, 60)
	end

	if type(data.AutoSave) == "boolean" then
		autoSaveConfigActive = data.AutoSave
		autoSaveBtn.BackgroundColor3 = autoSaveConfigActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	end

	if type(data.AutoLoad) == "boolean" then
		autoLoadConfigActive = data.AutoLoad
		autoLoadBtn.BackgroundColor3 = autoLoadConfigActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	end

	if isSamePlace and type(data.AutoCollect) == "boolean" then
		if data.AutoCollect and collectorPosition then
			setAutoCollectState(true)
		else
			setAutoCollectState(false)
		end
	end

	showTopNotification(dict.ConfigLoadedMsg)
	return true
end

registerConnection(saveConfigBtn.MouseButton1Click:Connect(function()
	saveConfig(false)
end))

registerConnection(loadConfigBtn.MouseButton1Click:Connect(function()
	loadConfig()
end))

registerConnection(autoSaveBtn.MouseButton1Click:Connect(function()
	autoSaveConfigActive = not autoSaveConfigActive
	autoSaveBtn.BackgroundColor3 = autoSaveConfigActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	saveConfig(false)
end))

registerConnection(autoLoadBtn.MouseButton1Click:Connect(function()
	autoLoadConfigActive = not autoLoadConfigActive
	autoLoadBtn.BackgroundColor3 = autoLoadConfigActive and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
	saveConfig(false)
end))

registerConnection(closeButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	toggleButton.Visible = true
end))

registerConnection(toggleButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = true
	toggleButton.Visible = false
end))

task.spawn(function()
	if envFS.hasRead and envFS.hasIsFile then
		local fileExists = false
		pcall(function() fileExists = isfile(configFileName) end)
		if fileExists then
			local ok, data = pcall(function() return HttpService:JSONDecode(readfile(configFileName)) end)
			if ok and type(data) == "table" and data.AutoLoad == true then
				loadConfig()
			end
		end
	end
end)

switchTab(menuTab, menuBtn)
