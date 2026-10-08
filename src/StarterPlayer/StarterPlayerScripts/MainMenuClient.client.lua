--[[
	MainMenuClient
	--------------
	Menu principal d'Anime Legend : image de fond fournie par l'utilisateur
	(a remplacer ci-dessous par le vrai rbxassetid une fois importee dans
	Studio), avec effet "vivant" en overlay :
	- Petales de cerisier qui tombent en continu (TweenService, pas de modele externe)
	- Leger zoom respirant sur le fond (effet Ken Burns)
	- Boutons invisibles poses exactement sur ceux dessines dans l'image

	Les positions des boutons (BUTTON_LAYOUT) sont estimees depuis le visuel
	fourni - ajuste-les a l'oeil dans Studio (proprietes Position/Size de
	chaque TextButton sous MainMenu.Buttons) si elles ne tombent pas pile sur
	le texte dessine.

	LocalScript : tourne automatiquement au demarrage client, pas besoin de
	le requerir depuis init.client.lua.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- A REMPLACER : colle ici l'Asset ID obtenu apres avoir importe MenuPrincipal.png dans Studio.
local BACKGROUND_IMAGE_ID = "rbxassetid://133533293539089"

-- ============================================================
-- ScreenGui racine
-- ============================================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MainMenu"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 10
screenGui.Parent = playerGui

local background = Instance.new("ImageLabel")
background.Name = "Background"
background.Size = UDim2.new(1, 0, 1, 0)
background.Position = UDim2.new(0.5, 0, 0.5, 0)
background.AnchorPoint = Vector2.new(0.5, 0.5)
background.Image = BACKGROUND_IMAGE_ID
background.ScaleType = Enum.ScaleType.Fit
background.BackgroundColor3 = Color3.new(0, 0, 0)
background.BorderSizePixel = 0
background.Parent = screenGui

-- Leger zoom respirant (Ken Burns) : 1.0 -> 1.05 -> 1.0 en boucle, tres lent.
local backgroundScale = Instance.new("UIScale")
backgroundScale.Scale = 1
backgroundScale.Parent = background

local breathingTween = TweenService:Create(
	backgroundScale,
	TweenInfo.new(18, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
	{ Scale = 1.05 }
)
breathingTween:Play()

-- ============================================================
-- Petales de cerisier qui tombent (generes en code, pas d'asset requis)
-- ============================================================

local petalsFolder = Instance.new("Frame")
petalsFolder.Name = "Petals"
petalsFolder.Size = UDim2.new(1, 0, 1, 0)
petalsFolder.BackgroundTransparency = 1
petalsFolder.ClipsDescendants = true
petalsFolder.ZIndex = 2
petalsFolder.Parent = screenGui

local PETAL_COLORS = {
	Color3.fromRGB(255, 192, 214),
	Color3.fromRGB(255, 214, 230),
	Color3.fromRGB(255, 235, 245),
}

local PETAL_COUNT = 18

local function spawnPetal()
	local petal = Instance.new("Frame")
	petal.Size = UDim2.new(0, math.random(8, 16), 0, math.random(6, 12))
	petal.BackgroundColor3 = PETAL_COLORS[math.random(1, #PETAL_COLORS)]
	petal.BorderSizePixel = 0
	petal.AnchorPoint = Vector2.new(0.5, 0.5)
	petal.Rotation = math.random(0, 360)

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = petal

	petal.Parent = petalsFolder

	local function fall()
		local startX = math.random(0, 100) / 100
		local driftX = (math.random(-15, 15)) / 100
		local duration = math.random(8, 16)

		petal.Position = UDim2.new(startX, 0, -0.05, 0)
		petal.Rotation = math.random(0, 360)

		local tween = TweenService:Create(
			petal,
			TweenInfo.new(duration, Enum.EasingStyle.Linear),
			{
				Position = UDim2.new(startX + driftX, 0, 1.05, 0),
				Rotation = petal.Rotation + math.random(180, 540),
			}
		)
		tween:Play()
		tween.Completed:Connect(fall) -- boucle indefiniment
	end

	-- Decale le depart de chaque petale pour eviter qu'elles tombent toutes en meme temps.
	task.delay(math.random(0, 100) / 10, fall)
end

for _ = 1, PETAL_COUNT do
	spawnPetal()
end

-- ============================================================
-- Boutons (invisibles, poses sur le texte dessine dans l'image)
-- POSITIONS ESTIMEES - a ajuster a l'oeil dans Studio si besoin.
-- ============================================================

local buttonsFolder = Instance.new("Frame")
buttonsFolder.Name = "Buttons"
buttonsFolder.Size = UDim2.new(1, 0, 1, 0)
buttonsFolder.BackgroundTransparency = 1
buttonsFolder.ZIndex = 3
buttonsFolder.Parent = screenGui

local BUTTON_LAYOUT = {
	{ Name = "Jouer", Position = UDim2.new(0.039, 0, 0.381, 0), Size = UDim2.new(0.273, 0, 0.063, 0) },
	{ Name = "Boutique", Position = UDim2.new(0.039, 0, 0.473, 0), Size = UDim2.new(0.273, 0, 0.059, 0) },
	{ Name = "Inventaire", Position = UDim2.new(0.039, 0, 0.552, 0), Size = UDim2.new(0.273, 0, 0.059, 0) },
	{ Name = "Parametres", Position = UDim2.new(0.039, 0, 0.630, 0), Size = UDim2.new(0.273, 0, 0.059, 0) },
	{ Name = "Personnaliser", Position = UDim2.new(0.039, 0, 0.708, 0), Size = UDim2.new(0.273, 0, 0.063, 0) },
	{ Name = "Quitter", Position = UDim2.new(0.039, 0, 0.786, 0), Size = UDim2.new(0.273, 0, 0.059, 0) },
}

local buttons = {}

for _, layout in ipairs(BUTTON_LAYOUT) do
	local button = Instance.new("TextButton")
	button.Name = layout.Name
	button.Position = layout.Position
	button.Size = layout.Size
	button.BackgroundTransparency = 1
	button.Text = ""
	button.AutoButtonColor = false
	button.Parent = buttonsFolder
	buttons[layout.Name] = button
end

-- ============================================================
-- Actions des boutons (stubs - a brancher sur le vrai gameplay/UI plus tard)
-- ============================================================

buttons.Jouer.MouseButton1Click:Connect(function()
	screenGui.Enabled = false
	-- TODO: ici, lancer le vrai spawn du joueur dans le monde (il ne spawn
	-- probablement pas tant qu'il est sur ce menu - a coordonner avec
	-- SaveService.LoadPlayer cote serveur si besoin d'un ecran de chargement).
end)

buttons.Boutique.MouseButton1Click:Connect(function()
	print("[MainMenu] Boutique - pas encore implementee")
end)

buttons.Inventaire.MouseButton1Click:Connect(function()
	print("[MainMenu] Inventaire - pas encore implemente")
end)

buttons.Parametres.MouseButton1Click:Connect(function()
	print("[MainMenu] Parametres - pas encore implemente")
end)

buttons.Personnaliser.MouseButton1Click:Connect(function()
	print("[MainMenu] Personnaliser - pas encore implemente")
end)

buttons.Quitter.MouseButton1Click:Connect(function()
	localPlayer:Kick("À bientôt sur Anime Legend !")
end)