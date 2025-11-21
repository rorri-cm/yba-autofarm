-- ==== INTERNAL AUTO-RESOLVING CONFIG ACCESSORS ====
local function IsBuyLucky()
    if getgenv and getgenv().Config and getgenv().Config.BuyLucky ~= nil then
        return getgenv().Config.BuyLucky
    end
    return true
end
local function IsAutoSell()
    if getgenv and getgenv().Config and getgenv().Config.AutoSell ~= nil then
        return getgenv().Config.AutoSell
    end
    return true
end
local function GetWebhookURL()
    return (getgenv and getgenv().Config and getgenv().Config.Webhook ~= nil)
        and getgenv().Config.Webhook or ""
end
local function GetMaxMoneyAlert()
    return (getgenv and getgenv().Config and getgenv().Config.MaxMoneyAlert ~= nil)
        and getgenv().Config.MaxMoneyAlert or 1000000
end

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
                Player:Kick("❌ You have been kicked from the script by the administrator.")
                return true
            end
        end
    end
    return false
end

if CheckBanlist() then
    return
end

task.spawn(function()
    while true do
        task.wait(30)
        CheckBanlist()
    end
end)

print("Script Loading...")
warn("Script Loading...")

-- NOTIFICATION ON SCREEN: "Loop loaded successfully, enjoy!"
do
    local PlayerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    local sg = Instance.new("ScreenGui")
    sg.IgnoreGuiInset = true
    sg.Name = "Loop_Notification"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = PlayerGui

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(0, 420, 0, 42)
    txt.AnchorPoint = Vector2.new(0.5, 0)
    txt.Position = UDim2.new(0.5, 0, 0.04, 0)
    txt.BackgroundTransparency = 0.13
    txt.BackgroundColor3 = Color3.fromRGB(191, 127, 255)
    txt.Text = "Loop loaded successfully, enjoy!"
    txt.TextColor3 = Color3.fromRGB(255, 255, 255)
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 27
    txt.Parent = sg
    txt.BorderSizePixel = 0
    txt.ZIndex = 2000
    txt.TextStrokeTransparency = 0.4

    local cr = Instance.new("UICorner")
    cr.CornerRadius = UDim.new(0, 16)
    cr.Parent = txt

    spawn(function()
        local totalTime = 5
        local steps = 50
        for i = 0, steps do
            local alpha = i/steps
            txt.TextTransparency = alpha
            txt.BackgroundTransparency = 0.13 + 0.87 * alpha
            txt.TextStrokeTransparency = 0.4 + 0.6 * alpha
            wait(totalTime/steps)
        end
        sg:Destroy()
    end)
end

wait(6)
print("Loop Loaded!")
warn("Loop Loaded!")
wait(2)

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

local Has2x = false
pcall(function()
    Has2x = MarketplaceService:UserOwnsGamePassAsync(Player.UserId, 14597778)
end)

-- Hook opcional (no se toca tu farmeo)
if hookmetamethod and newcclosure then
    pcall(function()
        local oldMagnitude
        oldMagnitude = hookmetamethod(Vector3.new(), "__index", newcclosure(function(self, index)
            local CallingScript = tostring(getcallingscript())
            if not checkcaller() and index == "magnitude" and CallingScript == "ItemSpawn" then
                return 0
            end
            return oldMagnitude(self, index)
        end))
    end)
end

local ItemSpawnFolder
local folderSuccess = pcall(function()
    ItemSpawnFolder = Workspace:WaitForChild("Item_Spawns", 10):WaitForChild("Items", 10)
end)

if not folderSuccess or not ItemSpawnFolder then
    warn("Item_Spawns folder not found, retrying...")
    task.wait(5)
    ItemSpawnFolder = Workspace:FindFirstChild("Item_Spawns")
    if ItemSpawnFolder then
        ItemSpawnFolder = ItemSpawnFolder:FindFirstChild("Items")
    end
    if not ItemSpawnFolder then
        warn("ERROR: Items folder could not be found")
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
    local PlaceId = game.PlaceId

    pcall(function()
        local HttpService = game:GetService("HttpService")
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        if servers and servers.data then
            for _, server in pairs(servers.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    print("Hopping to server: " .. server.id)
                    TeleportService:TeleportToPlaceInstance(PlaceId, server.id, Player)
                    return
                end
            end
        end
    end)

    TeleportService:Teleport(PlaceId, Player)
end

local function GetItemInfo(Model)
    if Model and Model:IsA("Model") and Model.Parent and Model.Parent.Name == "Items" then
        local PrimaryPart = Model.PrimaryPart
        if not PrimaryPart then return nil end
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
                print("Detected item: " .. ItemInfo.Name)
            end
        end
    end)
else
    warn("ItemSpawnFolder doesn't exist, items won't be detected automatically")
end

if hookmetamethod and newcclosure then
    pcall(function()
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
    end)
end

task.wait(1)

if not PlayerGui:FindFirstChild("HUD") then
    pcall(function()
        local HUD = ReplicatedStorage.Objects.HUD:Clone()
        HUD.Parent = PlayerGui
    end)
end

task.spawn(function()
    pcall(function()
        PlayerGui:WaitForChild("LoadingScreen1"):Destroy()
    end)
    task.wait(.5)
    pcall(function()
        PlayerGui:WaitForChild("LoadingScreen"):Destroy()
    end)
    pcall(function()
        workspace.LoadingScreen.Song:Destroy()
    end)
end)

repeat task.wait() until GetCharacter() and GetCharacter("RemoteEvent")
print("Character loaded successfully")
GetCharacter("RemoteEvent"):FireServer("PressedPlay")
print("Attempting teleport...")
TeleportTo(CFrame.new(978, -42, -49))
task.wait(1)

local HRP = GetCharacter("HumanoidRootPart")
if HRP then
    print("Current position: " .. tostring(HRP.Position))
else
    warn("ERROR: HumanoidRootPart not found")
end

print("Waiting 5 seconds before starting farm...")
task.wait(5)
print("Starting autofarm loop...")

local cyclesCompleted = 0
local maxCycles = 1
local maxCycleTime = 60

-- WEBHOOK NOTIFY FUNCTION
local notifiedMoney = false
local function SendWebhook(message)
    local url = GetWebhookURL()
    if url and url ~= "" then
        pcall(function()
            local HttpService = game:GetService("HttpService")
            local data = {
                ["content"] = message,
                ["username"] = "YBA Auto Farm - " .. Player.Name
            }
            request({
                Url = url,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(data)
            })
        end)
    end
end

while true do
    print("=== Cycle #" .. (cyclesCompleted + 1) .. " ===")
    -- Farmear items (NO TOCAR)
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

                if fireproximityprompt then
                    fireproximityprompt(ProximityPrompt)
                else
                    ProximityPrompt:InputHoldBegin()
                    task.wait(ProximityPrompt.HoldDuration or 0.5)
                    ProximityPrompt:InputHoldEnd()
                end

                task.wait(.5)
                BodyVelocity:Destroy()
                TeleportTo(CFrame.new(978, -42, -49))
            else
                table.remove(getgenv().SpawnedItems, table.find(getgenv().SpawnedItems, ItemInfo))
            end
        end
    end

    task.wait(3)
    local cycleStartTime = tick()
    print("Farm finished, starting sell and buy checks...")

    -- Money notification webhook (reads config live)
    local Money = Player.PlayerStats.Money
    if Money.Value >= GetMaxMoneyAlert() and not notifiedMoney then
        notifiedMoney = true
        SendWebhook("💰 $" .. GetMaxMoneyAlert() .. " REACHED! Current Money: $" .. Money.Value)
        print("🎉 Alert: Target money reached!")
    end

    -- Sell items (reads user config live)
    if IsAutoSell() then
        for Item, Sell in pairs(SellItems) do
            if Sell and Player.Backpack and Player.Backpack:FindFirstChild(Item) then
                pcall(function()
                    GetCharacter("Humanoid"):EquipTool(Player.Backpack:FindFirstChild(Item))
                    GetCharacter("RemoteEvent"):FireServer("EndDialogue", {
                        ["NPC"] = "Merchant",
                        ["Dialogue"] = "Dialogue5",
                        ["Option"] = "Option2"
                    })
                end)
                task.wait(.1)
            end
        end
    end

    -- Buy Lucky Arrows (reads user config live)
    if IsBuyLucky() and not HasLuckyArrows() then
        print("Buying Lucky Arrows... (Money: $" .. Money.Value .. ")")
        local purchaseAttempts = 0
        while Money.Value >= 75000 and purchaseAttempts < 15 do
            pcall(function()
                Player.Character.RemoteEvent:FireServer("PurchaseShopItem", {["ItemName"] = "1x Lucky Arrow"})
            end)
            task.wait(1)
            purchaseAttempts = purchaseAttempts + 1

            local currentCount = 0
            for _, Tool in pairs(Player.Backpack:GetChildren()) do
                if Tool.Name == "Lucky Arrow" then
                    currentCount = currentCount + 1
                end
            end
            if Player.Character then
                for _, Tool in pairs(Player.Character:GetChildren()) do
                    if Tool:IsA("Tool") and Tool.Name == "Lucky Arrow" then
                        currentCount = currentCount + 1
                    end
                end
            end

            print("Lucky Arrows: " .. currentCount .. "/10")
            if currentCount >= 10 then
                SendWebhook("🏹 MAX LUCKY ARROWS REACHED! Total: " .. currentCount .. "/10")
                print("Max Lucky Arrows reached!")
                break
            end

            if purchaseAttempts > 3 and currentCount == 9 then
                print("⚠️ Could not buy the tenth Lucky Arrow")
                break
            end
        end
    end

    cyclesCompleted = cyclesCompleted + 1
    print("Cycle completed (" .. cyclesCompleted .. "/" .. maxCycles .. ")")

    if tick() - cycleStartTime > maxCycleTime then
        print("⚠️ TIMEOUT: Forcing server hop...")
        cyclesCompleted = 0
        ServerHop()
        task.wait(10)
    end

    if cyclesCompleted >= maxCycles then
        print("=== " .. maxCycles .. " cycles completed, hopping server ===")
        cyclesCompleted = 0
        ServerHop()
        task.wait(10)
    end

    task.wait(2)
end
