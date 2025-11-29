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

-- ✅ REMOVED: SafeMode optimization (3D rendering, FPS cap, quality)

if not game:IsLoaded() then
    game.Loaded:Wait()
end

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

-- OPTIMIZED DELAYS (no SafeMode)
local ActionDelay = 0.35
local TeleportDelay = 0.7

wait(6)
print("Loop Loaded!")
warn("Loop Loaded!")
wait(2)

-- ✅ MODIFIED: Only Rokakakas and Arrows
local SellItems = {
    ["Rokakaka"] = false,
    ["Mysterious Arrow"] = false,
    ["Lucky Arrow"] = false
}

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")

local PlayerGui = Player:WaitForChild("PlayerGui")

-- ==== AUTO-REJOIN SYSTEM (Enhanced) ====
-- Detects ANY kick/disconnect and automatically rejoins
local TeleportService = game:GetService("TeleportService")
local PlaceId = game.PlaceId

-- Method 1: CoreGui Error Prompt Detection (original)
game:GetService("CoreGui").DescendantAdded:Connect(function(child)
    if child.Name == "ErrorPrompt" then
        local GrabError = child:FindFirstChild("ErrorMessage", true)
        if GrabError then
            repeat task.wait() until GrabError.Text ~= "Label"
            local Reason = GrabError.Text
            print("⚠️ Kick detected: " .. Reason)
            print("🔄 Auto-rejoining in 2 seconds...")
            task.wait(2)
            TeleportService:Teleport(PlaceId, Player)
        end
    end
end)

-- Method 2: Player.Kick detection (catches manual kicks)
if hookmetamethod then
    pcall(function()
        local oldKick
        oldKick = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if method == "Kick" and self == Player then
                local reason = args[1] or "Unknown reason"
                print("⚠️ Kick detected via Kick(): " .. tostring(reason))
                
                -- Don't rejoin if it's the banlist kick
                if not tostring(reason):match("administrator") then
                    print("🔄 Auto-rejoining in 2 seconds...")
                    task.wait(2)
                    TeleportService:Teleport(PlaceId, Player)
                end
                
                return -- Prevent the actual kick from showing
            end
            
            return oldKick(self, ...)
        end)
    end)
end

-- Method 3: Connection lost detection
pcall(function()
    game:GetService("GuiService").ErrorMessageChanged:Connect(function()
        local errorMessage = game:GetService("GuiService"):GetErrorMessage()
        if errorMessage and errorMessage ~= "" then
            print("⚠️ Connection error detected: " .. errorMessage)
            print("🔄 Auto-rejoining in 2 seconds...")
            task.wait(2)
            TeleportService:Teleport(PlaceId, Player)
        end
    end)
end)

-- Method 4: Teleport failed detection (backup)
TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
    if player == Player then
        warn("⚠️ Teleport failed: " .. tostring(errorMessage))
        print("🔄 Retrying teleport in 3 seconds...")
        task.wait(3)
        TeleportService:Teleport(PlaceId, Player)
    end
end)

print("✅ Auto-Rejoin system loaded (4 detection methods active)")



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

-- ✅ MODIFIED: Only Rokakakas and Arrows (stop at 10 each)
local MaxItemAmounts = {
    ["Rokakaka"] = 10,
    ["Mysterious Arrow"] = 10
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

-- ✅ REMOVED: ServerHop function completely removed

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
                -- ✅ MODIFIED: Only track Rokakakas and Arrows
                if ItemInfo.Name == "Rokakaka" or ItemInfo.Name == "Mysterious Arrow" then
                    getgenv().SpawnedItems[Model] = ItemInfo
                    print("Detected item: " .. ItemInfo.Name)
                end
            end
        end
    end)
    
    -- ✅ ADDED: Scan for items that already exist in the world
    print("Scanning for existing items...")
    for _, Model in pairs(ItemSpawnFolder:GetChildren()) do
        if Model:IsA("Model") then
            local ItemInfo = GetItemInfo(Model)
            if ItemInfo then
                -- ✅ FILTER: Only track Rokakakas and Arrows
                if ItemInfo.Name == "Rokakaka" or ItemInfo.Name == "Mysterious Arrow" then
                    getgenv().SpawnedItems[Model] = ItemInfo
                    print("Found existing item: " .. ItemInfo.Name)
                end
            end
        end
    end
    print("Initial scan complete!")
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
    -- Safer loading screen removal
    local function safeDestroy(name)
        pcall(function()
            local gui = PlayerGui:FindFirstChild(name)
            if gui then gui:Destroy() end
        end)
    end

    safeDestroy("LoadingScreen1")
    task.wait(0.5)
    safeDestroy("LoadingScreen")
    
    pcall(function()
        if workspace:FindFirstChild("LoadingScreen") and workspace.LoadingScreen:FindFirstChild("Song") then
            workspace.LoadingScreen.Song:Destroy()
        end
    end)
end)

-- Robust Character Wait
local function WaitForCharacter()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 10)
    local remote = char:WaitForChild("RemoteEvent", 10)
    
    if not hrp or not remote then
        warn("Character load timed out, retrying...")
        return WaitForCharacter() -- Recursively wait
    end
    return char
end

WaitForCharacter()
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

-- ✅ REMOVED: cyclesCompleted, maxCycles, maxCycleTime variables

-- WEBHOOK NOTIFY FUNCTION
local notifiedMoney = false
local function SendWebhook(message)
    local url = GetWebhookURL()
    if url and url ~= "" then
        pcall(function()
            local HttpService = game:GetService("HttpService")
            -- Include username in the content for better visibility
            local finalMessage = "**[" .. Player.Name .. "]** " .. message
            local data = {
                ["content"] = finalMessage,
                ["username"] = "YBA Auto Farm"
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

-- ✅ MODIFIED: Loop until 10 Rokas and 10 Arrows are collected
while true do
    task.wait(0.1) -- Prevent CPU lockup
    
    -- Check if we have 10 Rokas and 10 Arrows
    local rokaCount = 0
    local arrowCount = 0
    for _, Tool in pairs(Player.Backpack:GetChildren()) do
        if Tool.Name == "Rokakaka" then
            rokaCount = rokaCount + 1
        elseif Tool.Name == "Mysterious Arrow" then
            arrowCount = arrowCount + 1
        end
    end
    
    if rokaCount >= 10 and arrowCount >= 10 then
        print("✅ TARGET REACHED! Rokas: " .. rokaCount .. "/10 | Arrows: " .. arrowCount .. "/10")
        print("⏸️ Waiting for items to be used...")
        SendWebhook("✅ Farming complete! Rokas: " .. rokaCount .. " | Arrows: " .. arrowCount)
        
        -- ✅ CHANGED: Wait instead of stopping - monitor inventory
        while rokaCount >= 10 and arrowCount >= 10 do
            task.wait(2) -- Check every 2 seconds
            
            -- Recount items
            rokaCount = 0
            arrowCount = 0
            for _, Tool in pairs(Player.Backpack:GetChildren()) do
                if Tool.Name == "Rokakaka" then
                    rokaCount = rokaCount + 1
                elseif Tool.Name == "Mysterious Arrow" then
                    arrowCount = arrowCount + 1
                end
            end
            
            print("⏸️ Waiting... (Rokas: " .. rokaCount .. "/10 | Arrows: " .. arrowCount .. "/10)")
        end
        
        print("🔄 Items used! Resuming farming...")
        SendWebhook("🔄 Items below 10, resuming farm...")
    end
    
    print("=== Farming Rokas & Arrows === (Rokas: " .. rokaCount .. "/10 | Arrows: " .. arrowCount .. "/10)")
    
    -- ✅ FIXED: Collect items to remove FIRST, then remove them AFTER iteration
    local itemsToRemove = {}
    
    for Index, ItemInfo in pairs(getgenv().SpawnedItems) do
        local HumanoidRootPart = GetCharacter("HumanoidRootPart")
        if HumanoidRootPart then
            local Name = ItemInfo.Name
            local HasMax = HasMaxItem(Name)
            if not HasMax then
                local ProximityPrompt = ItemInfo.ProximityPrompt
                local Position = ItemInfo.Position
                
                -- Mark for removal (will remove after loop)
                table.insert(itemsToRemove, Index)
                
                local BodyVelocity = Instance.new("BodyVelocity")
                BodyVelocity.Parent = HumanoidRootPart
                BodyVelocity.Velocity = Vector3.new(0, 0, 0)
                ToggleNoclip(true)
                TeleportTo(CFrame.new(Position.X, Position.Y + 25, Position.Z))
                task.wait(TeleportDelay)

                if fireproximityprompt then
                    fireproximityprompt(ProximityPrompt)
                else
                    ProximityPrompt:InputHoldBegin()
                    task.wait(ProximityPrompt.HoldDuration or 0.5)
                    ProximityPrompt:InputHoldEnd()
                end

                task.wait(TeleportDelay)
                BodyVelocity:Destroy()
                TeleportTo(CFrame.new(978, -42, -49))
            else
                -- Mark for removal (already have max)
                table.insert(itemsToRemove, Index)
            end
        end
    end
    
    -- ✅ FIXED: Remove items AFTER iteration (SpawnedItems is a dictionary, use Index as key)
    for _, Index in ipairs(itemsToRemove) do
        getgenv().SpawnedItems[Index] = nil
    end

    task.wait(3)
    print("Farm finished, starting sell and buy checks...")

    -- Money notification webhook (reads config live)
    local Money = Player.PlayerStats.Money
    if Money.Value >= GetMaxMoneyAlert() and not notifiedMoney then
        notifiedMoney = true
        SendWebhook("💰 reached MAX MONEY! ($" .. GetMaxMoneyAlert() .. ")")
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
                task.wait(ActionDelay)
            end
        end
    end


    -- ✅ REMOVED: Lucky Arrow purchase logic

    -- ✅ REMOVED: All cycle completion and server hop logic

    task.wait(2)
end
