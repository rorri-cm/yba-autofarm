repeat task.wait(1) until game:IsLoaded()

-- Sistema de Banlist Remota
local BanlistURL = "https://raw.githubusercontent.com/rorri-cm/yba-autofarm/refs/heads/main/banlist.txt"
local Player = game:GetService("Players").LocalPlayer

local function CheckBanlist()
    local success, banlist = pcall(function()
        return game:HttpGet(BanlistURL)
    end)
    
    if success and banlist then
        for bannedUser in banlist:gmatch("[^\r\n]+") do
            if bannedUser:lower() == Player.Name:lower() then
                Player:Kick("❌ Has sido expulsado del script por el administrador.")
                return true
            end
        end
    end
    return false
end

-- Verificar banlist al inicio
if CheckBanlist() then
    return
end

-- Verificar banlist cada 30 segundos
task.spawn(function()
    while true do
        task.wait(30)
        CheckBanlist()
    end
end)

print("Script Loading...")
warn("Script Loading...")

wait(6)

print("MoonLight Loaded!")
warn("MoonLight Loaded!")

wait(2)

local BuyLucky = true
local AutoSell = true
local SellItems = {
    ["Gold Coin"] = true,
    ["Rokakaka"] = true,
    ["Pure Rokakaka"] = true,
    ["Mysterious Arrow"] = true,
    ["Diamond"] = true,
    ["Ancient Scroll"] = true,
    ["Caesar's Headband"] = true,
    ["Stone Mask"] = true,
    ["Rib Cage of The Saint's Corpse"] = true,
    ["Quinton's Glove"] = true,
    ["Zeppeli's Hat"] = true,
    ["Lucky Arrow"] = false,
    ["Clackers"] = true,
    ["Steel Ball"] = true,
    ["Dio's Diary"] = true
}

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

game:GetService("CoreGui").DescendantAdded:Connect(function(child)
    if child.Name == "ErrorPrompt" then
        local GrabError = child:FindFirstChild("ErrorMessage",true)
        repeat task.wait() until GrabError.Text ~= "Label"
        local Reason = GrabError.Text
        if Reason:match("kick") or Reason:match("You") or Reason:match("conn") or Reason:match("rejoin") then
            game:GetService("TeleportService"):Teleport(2809202155, game:GetService("Players").LocalPlayer)
        end
    end
end)

local Has2x = MarketplaceService:UserOwnsGamePassAsync(Player.UserId, 14597778)

local oldMagnitude
local hookSuccess = pcall(function()
    oldMagnitude = hookmetamethod(Vector3.new(), "__index", newcclosure(function(self, index)
        local CallingScript = tostring(getcallingscript())
        if not checkcaller() and index == "magnitude" and CallingScript == "ItemSpawn" then
            return 0
        end
        return oldMagnitude(self, index)
    end))
end)

if not hookSuccess then
    warn("Hook falló, continuando sin él...")
end

local ItemSpawnFolder
local folderSuccess = pcall(function()
    ItemSpawnFolder = Workspace:WaitForChild("Item_Spawns", 10):WaitForChild("Items", 10)
end)

if not folderSuccess or not ItemSpawnFolder then
    warn("No se encontró Item_Spawns, reintentando...")
    task.wait(5)
    ItemSpawnFolder = Workspace:FindFirstChild("Item_Spawns")
    if ItemSpawnFolder then
        ItemSpawnFolder = ItemSpawnFolder:FindFirstChild("Items")
    end
    if not ItemSpawnFolder then
        warn("ERROR: No se puede encontrar carpeta de items")
    end
end

local function GetCharacter(Part)
    if Player.Character then
        if not Part then
            return Player.Character
        elseif typeof(Part) == "string" then
            return Player.Character:FindFirstChild(Part) or nil
        end
    end
    return nil
end

local function TeleportTo(Position)
    local HumanoidRootPart = GetCharacter("HumanoidRootPart")
    if HumanoidRootPart then
        local PositionType = typeof(Position)
        if PositionType == "CFrame" then
            HumanoidRootPart.CFrame = Position
        end
    end
end

local function ToggleNoclip(Value)
    local Character = GetCharacter()
    if Character then
        for _, Child in pairs(Character:GetDescendants()) do
            if Child:IsA("BasePart") and Child.CanCollide == not Value then
                Child.CanCollide = Value
            end
        end
    end
end

local MaxItemAmounts = {
    ["Gold Coin"] = 45,
    ["Rokakaka"] = 25,
    ["Pure Rokakaka"] = 10,
    ["Mysterious Arrow"] = 25,
    ["Diamond"] = 30,
    ["Ancient Scroll"] = 10,
    ["Caesar's Headband"] = 10,
    ["Stone Mask"] = 10,
    ["Rib Cage of The Saint's Corpse"] = 20,
    ["Quinton's Glove"] = 10,
    ["Zeppeli's Hat"] = 10,
    ["Lucky Arrow"] = 10,
    ["Clackers"] = 10,
    ["Steel Ball"] = 10,
    ["Dio's Diary"] = 10
}

if Has2x then
    for Index, Max in pairs(MaxItemAmounts) do
        MaxItemAmounts[Index] = Max * 2
    end
end

local function HasMaxItem(Item)
    local Count = 0
    for _, Tool in pairs(Player.Backpack:GetChildren()) do
        if Tool.Name == Item then
            Count += 1
        end
    end
    if MaxItemAmounts[Item] then
        return Count >= MaxItemAmounts[Item]
    else
        return false
    end
end

local function HasLuckyArrows()
    local Count = 0
    for _, Tool in pairs(Player.Backpack:GetChildren()) do
        if Tool.Name == "Lucky Arrow" then
            Count += 1
        end
    end
    return Count >= 10
end

local function ServerHop()
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    local PlaceId = game.PlaceId
    
    local success, result = pcall(function()
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        if servers and servers.data then
            for _, server in pairs(servers.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    print("Hopeando a servidor: " .. server.id)
                    TeleportService:TeleportToPlaceInstance(PlaceId, server.id, Player)
                    return
                end
            end
        end
    end)
    
    if not success then
        warn("Error en server hop, reintentando con teleport simple...")
        TeleportService:Teleport(PlaceId, Player)
    end
end

local function GetItemInfo(Model)
    if Model and Model:IsA("Model") and Model.Parent and Model.Parent.Name == "Items" then
        local PrimaryPart = Model.PrimaryPart
        local Position = PrimaryPart.Position
        local ProximityPrompt
        for _, ItemInstance in pairs(Model:GetChildren()) do
            if ItemInstance:IsA("ProximityPrompt") and ItemInstance.MaxActivationDistance == 8 then
                ProximityPrompt = ItemInstance
            end
        end
        if ProximityPrompt then
            return {["Name"] = ProximityPrompt.ObjectText, ["ProximityPrompt"] = ProximityPrompt, ["Position"] = Position}
        end
    end
    return nil
end

getgenv().SpawnedItems = {}

if ItemSpawnFolder then
    ItemSpawnFolder.ChildAdded:Connect(function(Model)
        task.wait(1)
        if Model:IsA("Model") then
            local ItemInfo = GetItemInfo(Model)
            if ItemInfo then
                getgenv().SpawnedItems[Model] = ItemInfo
                print("Item detectado: " .. ItemInfo.Name)
            end
        end
    end)
else
    warn("ItemSpawnFolder no existe, no se detectarán items automáticamente")
end

local UzuKeeIsRetardedAndDoesntKnowHowToMakeAnAntiCheatOnTheServerSideAlsoVexStfuIKnowTheCodeIsBadYouDontNeedToTellMe = "  ___XP DE KEY"

local oldNc
oldNc = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local Method = getnamecallmethod()
    local Args = {...}
    if not checkcaller() and rawequal(self.Name, "Returner") and rawequal(Args[1], "idklolbrah2de") then
        return UzuKeeIsRetardedAndDoesntKnowHowToMakeAnAntiCheatOnTheServerSideAlsoVexStfuIKnowTheCodeIsBadYouDontNeedToTellMe
    end
    return oldNc(self, ...)
end))

task.wait(1)

if not PlayerGui:FindFirstChild("HUD") then
    local HUD = ReplicatedStorage.Objects.HUD:Clone()
    HUD.Parent = PlayerGui
end

task.spawn(function()
    PlayerGui:WaitForChild("LoadingScreen1"):Destroy()
    task.wait(.5)
    pcall(function()
        PlayerGui:WaitForChild("LoadingScreen"):Destroy()
    end)
    pcall(function()
        workspace.LoadingScreen.Song:Destroy()
    end)
end)

repeat task.wait() until GetCharacter() and GetCharacter("RemoteEvent")

print("Personaje cargado correctamente")

GetCharacter("RemoteEvent"):FireServer("PressedPlay")

print("Intentando teleportar...")
TeleportTo(CFrame.new(978, -42, -49))
task.wait(1)

local HRP = GetCharacter("HumanoidRootPart")
if HRP then
    print("Posición actual: " .. tostring(HRP.Position))
else
    warn("ERROR: No se encontró HumanoidRootPart")
end

print("Esperando 5 segundos antes de iniciar farm...")
task.wait(5)

print("Iniciando loop de farmeo...")

local cyclesCompleted = 0
local maxCycles = 1
local maxCycleTime = 60 -- 1 minuto máximo después de farmear antes de forzar hop

while true do
    print("=== Ciclo #" .. (cyclesCompleted + 1) .. " ===")
    
    -- Farmear items
    for Index, ItemInfo in pairs(getgenv().SpawnedItems) do
        local HumanoidRootPart = GetCharacter("HumanoidRootPart")
        if HumanoidRootPart then
            local Name = ItemInfo.Name
            local HasMax = HasMaxItem(Name)
            if not HasMax then
                local ProximityPrompt = ItemInfo.ProximityPrompt
                local Position = ItemInfo.Position
                table.remove(getgenv().SpawnedItems, table.find(getgenv().SpawnedItems, ItemInfo))
                local BodyVelocity = Instance.new("BodyVelocity")
                BodyVelocity.Parent = HumanoidRootPart
                BodyVelocity.Velocity = Vector3.new(0, 0, 0)
                ToggleNoclip(true)
                TeleportTo(CFrame.new(Position.X, Position.Y + 25, Position.Z))
                task.wait(.5)
                fireproximityprompt(ProximityPrompt)
                task.wait(.5)
                BodyVelocity:Destroy()
                TeleportTo(CFrame.new(978, -42, -49))
            else
                table.remove(getgenv().SpawnedItems, table.find(getgenv().SpawnedItems, ItemInfo))
            end
        end
    end
    
    task.wait(3)
    
    -- *** AQUÍ EMPIEZA EL TIMEOUT ***
    local cycleStartTime = tick()
    print("Farmeo completado, iniciando venta y compra...")
    
    -- Vender items
    if AutoSell then
        for Item, Sell in pairs(SellItems) do
            if Sell and Player.Backpack and Player.Backpack:FindFirstChild(Item) then
                GetCharacter("Humanoid"):EquipTool(Player.Backpack:FindFirstChild(Item))
                GetCharacter("RemoteEvent"):FireServer("EndDialogue", {
                    ["NPC"] = "Merchant",
                    ["Dialogue"] = "Dialogue5",
                    ["Option"] = "Option2"
                })
                task.wait(.1)
            end
        end
    end
    
    -- Comprar Lucky Arrows si no tiene el máximo
    local Money = Player.PlayerStats.Money
    if BuyLucky and not HasLuckyArrows() then
        print("Comprando Lucky Arrows... (Dinero: $" .. Money.Value .. ")")
        local purchaseAttempts = 0
        while Money.Value >= 75000 and purchaseAttempts < 15 do
            Player.Character.RemoteEvent:FireServer("PurchaseShopItem", {["ItemName"] = "1x Lucky Arrow"})
            task.wait(1) -- Aumentado a 1 segundo para evitar problemas
            purchaseAttempts = purchaseAttempts + 1
            
            -- Contar Lucky Arrows actuales (revisar Backpack Y Character)
            local currentCount = 0
            for _, Tool in pairs(Player.Backpack:GetChildren()) do
                if Tool.Name == "Lucky Arrow" then
                    currentCount = currentCount + 1
                end
            end
            -- Verificar si hay una equipada
            if Player.Character then
                for _, Tool in pairs(Player.Character:GetChildren()) do
                    if Tool:IsA("Tool") and Tool.Name == "Lucky Arrow" then
                        currentCount = currentCount + 1
                    end
                end
            end
            
            print("Lucky Arrows: " .. currentCount .. "/10")
            
            if currentCount >= 10 then
                print("¡Máximo de Lucky Arrows alcanzado!")
                break
            end
            
            -- Si ya intentó varias veces y sigue sin cambiar, salir
            if purchaseAttempts > 3 and currentCount == 9 then
                print("⚠️ No se pudo comprar la décima Lucky Arrow (posible bug del juego)")
                break
            end
        end
    end
    
    -- Incrementar contador de ciclos
    cyclesCompleted = cyclesCompleted + 1
    print("Ciclo completado (" .. cyclesCompleted .. "/" .. maxCycles .. ")")
    
    -- Verificar timeout del ciclo (si se quedó atascado)
    if tick() - cycleStartTime > maxCycleTime then
        print("⚠️ TIMEOUT: Ciclo tardó demasiado, forzando server hop...")
        cyclesCompleted = 0
        ServerHop()
        task.wait(10)
    end
    
    -- Verificar si debe cambiar de servidor
    if cyclesCompleted >= maxCycles then
        print("=== " .. maxCycles .. " ciclos completados, cambiando de servidor ===")
        cyclesCompleted = 0
        local hopStartTime = tick()
        ServerHop()
        task.wait(10)
        
        -- Si después de 15 segundos sigue en el mismo servidor, reintentar
        if tick() - hopStartTime < 15 then
            print("⚠️ Server hop falló, reintentando...")
            task.wait(5)
            ServerHop()
            task.wait(10)
        end
    end
    
    task.wait(2)
end
