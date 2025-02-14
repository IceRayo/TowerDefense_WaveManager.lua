-- Sistema de Oleadas + DataStore + UI (Ejemplo para Portafolio)
-- Autor: [Tu nombre de usuario]
-- Enlace: [Pega aquí tu link de GitHub Gist/Pastebin]

----- Configuración inicial -----
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local waveDataStore = DataStoreService:GetDataStore("WaveProgress")

----- Variables -----
local waveManager = {
    CurrentWave = 1,
    EnemiesAlive = 0,
    MaxWaves = 20,
    SpawnLocations = workspace.SpawnPoints:GetChildren(),
    EnemyTypes = {"Zombie", "FastZombie", "TankZombie"}
}

----- UI Elements -----
local waveGUI = script.Parent.WaveFrame
local waveText = waveGUI.WaveLabel
local enemiesText = waveGUI.EnemiesLabel

----- Funciones principales -----
function waveManager:StartWave()
    -- Lógica de spawn de enemigos
    local enemiesToSpawn = math.min(5 + (self.CurrentWave * 2), 30)
    self.EnemiesAlive = enemiesToSpawn
    
    for i = 1, enemiesToSpawn do
        local enemyType = self.EnemyTypes[math.random(1, #self.EnemyTypes)]
        self:SpawnEnemy(enemyType)
        task.wait(1)
    end
    
    self:UpdateUI()
end

function waveManager:SpawnEnemy(enemyType)
    -- Mock: Crea un enemigo y configura su IA
    local enemy = Instance.new("Part")
    enemy.Name = enemyType
    enemy.Parent = workspace.Enemies
    enemy.Position = self.SpawnLocations[math.random(1, #self.SpawnLocations)].Position
    
    enemy.Touched:Connect(function(_, hit)
        if hit.Parent and hit.Parent:FindFirstChild("Humanoid") then
            self.EnemiesAlive -= 1
            enemy:Destroy()
            self:UpdateUI()
        end
    end)
end

function waveManager:SaveProgress(player)
    -- Guarda la oleada actual en DataStore
    pcall(function()
        waveDataStore:SetAsync("Wave_" .. player.UserId, self.CurrentWave)
    end)
end

function waveManager:UpdateUI()
    -- Animación de UI con TweenService
    waveText.Text = "Wave: " .. self.CurrentWave
    enemiesText.Text = "Enemies Left: " .. self.EnemiesAlive
    
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad)
    local tween = TweenService:Create(waveGUI, tweenInfo, {Position = UDim2.new(0.5, 0, 0.95, 0)})
    tween:Play()
end

----- Conexión a eventos -----
game.Players.PlayerAdded:Connect(function(player)
    -- Cargar progreso guardado
    local success, savedWave = pcall(function()
        return waveDataStore:GetAsync("Wave_" .. player.UserId)
    end)
    
    if success and savedWave then
        waveManager.CurrentWave = savedWave
    end
end)

game.Players.PlayerRemoving:Connect(function(player)
    waveManager:SaveProgress(player)
end)

----- Iniciar sistema -----
waveManager:StartWave()