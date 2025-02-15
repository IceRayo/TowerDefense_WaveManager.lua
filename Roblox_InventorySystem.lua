-- Sistema de Inventario + UI + DataStore (Ejemplo para Portafolio)
-- Autor: [Tu nombre de usuario]
-- Enlace: [Pega aquí tu link de GitHub Gist/Pastebin]

----- Módulos y Servicios -----
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local TweenService = game:GetService("TweenService")
local inventoryStore = DataStoreService:GetDataStore("PlayerInventory")

----- Configuración del Inventario -----
local MAX_SLOTS = 24
local itemsDatabase = {
    ["Sword"] = { Icon = "rbxassetid://123456", Rarity = "Common" },
    ["HealthPotion"] = { Icon = "rbxassetid://789012", Rarity = "Uncommon" }
}

----- Clase InventoryManager -----
local InventoryManager = {}
InventoryManager.__index = InventoryManager

function InventoryManager.new(player)
    local self = setmetatable({}, InventoryManager)
    self.Player = player
    self.Items = {}
    self.UI = self:CreateUI()
    return self
end

function InventoryManager:CreateUI()
    -- Crear interfaz de inventario (ejemplo simplificado)
    local inventoryFrame = Instance.new("Frame")
    inventoryFrame.Parent = self.Player.PlayerGui:WaitForChild("Inventory")
    inventoryFrame.BackgroundTransparency = 0.8
    -- ... (agregar Grid de slots usando UIGridLayout)
    return inventoryFrame
end

function InventoryManager:LoadData()
    -- Cargar datos guardados
    local success, data = pcall(function()
        return inventoryStore:GetAsync("Inventory_" .. self.Player.UserId)
    end)
    
    if success and data then
        self.Items = data
        self:UpdateUI()
    end
end

function InventoryManager:SaveData()
    -- Guardar datos al salir
    pcall(function()
        inventoryStore:SetAsync("Inventory_" .. self.Player.UserId, self.Items)
    end)
end

function InventoryManager:AddItem(itemId, quantity)
    -- Añadir item al inventario
    if not itemsDatabase[itemId] then return end
    
    if self.Items[itemId] then
        self.Items[itemId].Quantity += quantity
    else
        self.Items[itemId] = { Quantity = quantity, Data = itemsDatabase[itemId] }
    end
    
    self:UpdateUI()
    self:PlayUIFeedback()
end

function InventoryManager:UpdateUI()
    -- Actualizar Grid con items
    for itemId, itemData in pairs(self.Items) do
        local slot = self.UI:FindFirstChild(itemId)
        if not slot then
            slot = Instance.new("ImageButton")
            slot.Name = itemId
            slot.Parent = self.UI
            slot.Image = itemData.Data.Icon
        end
        slot:FindFirstChild("QuantityLabel").Text = itemData.Quantity
    end
end

function InventoryManager:PlayUIFeedback()
    -- Animación al obtener un item
    local tween = TweenService:Create(self.UI, TweenInfo.new(0.3), {
        Position = UDim2.new(0.5, 0, 0.5, math.random(-5, 5))
    })
    tween:Play()
end

----- Conexión a Eventos -----
Players.PlayerAdded:Connect(function(player)
    local inventory = InventoryManager.new(player)
    inventory:LoadData()
    
    -- Ejemplo: Recolectar item al tocar una parte
    workspace.ItemPickups.ChildAdded:Connect(function(item)
        item.Touched:Connect(function(_, hit)
            if hit.Parent == player.Character then
                inventory:AddItem(item.Name, 1)
                item:Destroy()
            end
        end)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    local inventory = InventoryManager.new(player)
    inventory:SaveData()
end)