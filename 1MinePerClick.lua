-- fluent code converted to wind ui
-- [[ KEY SYSTEM LOADER ]] --
local KeySystem = loadstring(game:HttpGet("https://raw.githubusercontent.com/wendigo5414-cmyk/scripts/refs/heads/main/keysystem.lua"))()
KeySystem.Init()

-- [[ GAME SCRIPT START ]] --
local cloneref = (cloneref or clonereference or function(instance) return instance end)
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))

local WindUI
local ok, result = pcall(function()
    return require("./src/Init")
end)

if ok then
    WindUI = result
else 
    if cloneref(game:GetService("RunService")):IsStudio() then
        WindUI = require(cloneref(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init")))
    else
        local windUI_Source = game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua")
        windUI_Source = windUI_Source:gsub("([%w_]+)\\.UserInputType%s*==%s*Enum\\.UserInputType\\.MouseButton1", "(%1.UserInputType == Enum.UserInputType.MouseButton1 or %1.UserInputType == Enum.UserInputType.Touch)")
        windUI_Source = windUI_Source:gsub("([%w_]+)\\.UserInputType%s*==%s*Enum\\.UserInputType\\.MouseMovement", "(%1.UserInputType == Enum.UserInputType.MouseMovement or %1.UserInputType == Enum.UserInputType.Touch)")
        WindUI = loadstring(windUI_Source)()
    end
end 

local gameName = "Unknown Game"
pcall(function()
    gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
end)

local Window = WindUI:CreateWindow({
    Title = "Prime X Hub | " .. gameName,
    Folder = "PXH_Hub",
    Icon = "solar:gamepad-bold",
    HideSearchBar = false,
    OpenButton = {
        Title = "Open PXH Hub",
        CornerRadius = UDim.new(1,0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 0.8,
        Color = ColorSequence.new(
            Color3.fromHex("#30FF6A"), 
            Color3.fromHex("#e7ff2f")
        )
    },
    Topbar = {
        Height = 44,
        ButtonsType = "Mac",
    },
})

Window:Tag({
    Title = "by PXH",
    Icon = "github",
    Color = Color3.fromHex("#1c1c1c"),
    Border = true,
})

local Tabs = {
    Main = Window:Tab({ Title = "Main", Icon = "solar:bolt-bold" }),
    Movement = Window:Tab({ Title = "Movement", Icon = "solar:running-bold" }),
    Teleport = Window:Tab({ Title = "Teleport", Icon = "solar:map-point-bold" }),
    Settings = Window:Tab({ Title = "Settings", Icon = "solar:settings-bold" }),
    AboutUs  = Window:Tab({ Title = "About Us", Icon = "solar:info-circle-bold" })
}

-- ══════════════════════════════════════════
--              LOAD OTHERS.LUA
-- ══════════════════════════════════════════
local ok, OthersFunc = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/wendigo5414-cmyk/FireballxArena/main/Others.lua", true))()
end)

local NumberConverter = nil
if ok and type(OthersFunc) == "function" then
    NumberConverter = OthersFunc(Window, Tabs, WindUI)
else
    WindUI:Notify({
        Title = "Error",
        Content = "Failed to load basic categories from Others.lua",
        Duration = 5
    })
end

local executorName = identifyexecutor and ({identifyexecutor()})[1] or "Unknown"
if type(executorName) == "string" and string.find(string.lower(executorName), "xeno") then
    print("Detected: Xeno")
else
    print("Detected: Non-Xeno (" .. tostring(executorName) .. ")")
end

local function fireTouch(part, toPart)
    if not part or not toPart then return end
    
    if type(executorName) == "string" and string.find(string.lower(executorName), "xeno") then
        firetouchinterest(part, toPart, 0)
    else
        firetouchinterest(part, toPart, 0)
        task.wait(0.01)
        firetouchinterest(part, toPart, 1)
    end
end

local FarmingSection = Tabs.Main:Section({ Title = "Farming", Box = true, BoxBorder = true, Expandable = true, Opened = true })

local stagesFolder = workspace:WaitForChild("Stages", 5)
local stageOptions = {}
if stagesFolder then
    for _, child in ipairs(stagesFolder:GetChildren()) do
        if string.match(child.Name, "Stage %d+") then
            table.insert(stageOptions, child.Name)
        end
    end
end
table.sort(stageOptions, function(a, b)
    local numA = tonumber(string.match(a, "%d+")) or 0
    local numB = tonumber(string.match(b, "%d+")) or 0
    return numA > numB
end)

if #stageOptions == 0 then
    table.insert(stageOptions, "Stage 1")
end

local SelectedAutoFarmStage = stageOptions[1]

_G.AutoFarmToggle = false
FarmingSection:Toggle({
    Title = "Auto Farm",
    Value = false,
    Callback = function(Value)
        _G.AutoFarmToggle = Value
        if Value then
            task.spawn(function()
                local remoteObj = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 5)
                local serverFolder = remoteObj and remoteObj:WaitForChild("Server", 5)
                local hitWallRemote = serverFolder and serverFolder:WaitForChild("HitWall", 5)
                
                local LocalPlayer = game:GetService("Players").LocalPlayer
                
                while _G.AutoFarmToggle do
                    local stageName = SelectedAutoFarmStage
                    local targetStageNum = tonumber(string.match(stageName, "%d+"))
                    if not targetStageNum then task.wait(1) continue end
                    
                    local foundStage = nil
                    local partsToMine = {}
                    local currentStagesFolder = workspace:FindFirstChild("Stages")
                    
                    if currentStagesFolder then
                        for sIdx = 1, targetStageNum do
                            local sModel = currentStagesFolder:FindFirstChild("Stage " .. tostring(sIdx))
                            if sModel then
                                local iStages = sModel:FindFirstChild("Stages")
                                if iStages then
                                    for pIdx = 1, 500 do
                                        local actualPart = iStages:FindFirstChild(tostring(pIdx))
                                        if actualPart and actualPart.CanCollide then
                                            foundStage = sIdx
                                            table.insert(partsToMine, pIdx)
                                            if #partsToMine >= 3 then break end
                                        end
                                    end
                                end
                            end
                            if foundStage then break end
                        end
                    end
                    
                    if foundStage and #partsToMine > 0 then
                        if hitWallRemote then
                            for _, pIdx in ipairs(partsToMine) do
                                hitWallRemote:FireServer(foundStage, pIdx)
                            end
                        end
                        task.wait(0.2)
                    else
                        local stageModel = workspace:FindFirstChild("Stages") and workspace.Stages:FindFirstChild(stageName)
                        if not stageModel then task.wait(1) continue end
                        local spawnpoints = stageModel:FindFirstChild("Spawnpoints")
                        if spawnpoints then
                            local bestItemVal = -1
                            local bestItemPart = nil
                            local bestItemPrompt = nil
                            local bestItemName = nil
                            
                            for _, desc in ipairs(spawnpoints:GetDescendants()) do
                                if desc:IsA("ProximityPrompt") then
                                    local meshPart = desc.Parent
                                    if meshPart then
                                        local itemStats = meshPart:FindFirstChild("ItemStats")
                                        if itemStats then
                                            local bbGui = itemStats:FindFirstChild("BillboardGui")
                                            if bbGui then
                                                local revLabel = bbGui:FindFirstChild("Revenue")
                                                if revLabel then
                                                    local text = revLabel.Text
                                                    local cleanText = string.gsub(text, "<[^>]+>", "")
                                                    cleanText = string.gsub(cleanText, "[%$%s]", "")
                                                    local val = 0
                                                    if NumberConverter and NumberConverter.Parse then
                                                        val = NumberConverter.Parse(cleanText)
                                                    else
                                                        val = tonumber(cleanText) or 0
                                                    end
                                                    
                                                    if val > bestItemVal then
                                                        bestItemVal = val
                                                        bestItemPart = meshPart
                                                        bestItemPrompt = desc
                                                        bestItemName = meshPart.Name
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            
                            if bestItemPart and bestItemPrompt then
                                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    hrp.CFrame = bestItemPart.CFrame + Vector3.new(0, 3, 0)
                                    task.wait(0.2)
                                    fireproximityprompt(bestItemPrompt)
                                    task.wait(0.5)
                                end
                            else
                                task.wait(0.5)
                            end
                            
                            local mainGui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Main")
                            if mainGui then
                                local amountLabel = mainGui:FindFirstChild("Wins") and mainGui.Wins:FindFirstChild("BackpackFrame") and mainGui.Wins.BackpackFrame:FindFirstChild("Amount")
                                if amountLabel then
                                    local amtText = amountLabel.Text
                                    local current, max = string.match(amtText, "(%d+)%s*/%s*(%d+)")
                                    if current and max and tonumber(current) >= tonumber(max) then
                                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                        if hrp then
                                            hrp.CFrame = CFrame.new(4, 1, -13)
                                            task.wait(1)
                                        end
                                    end
                                end
                            end
                        end
                        task.wait(0.2)
                    end
                end
            end)
        end
    end
})

FarmingSection:Dropdown({
    Title = "Select Farm Stage",
    Values = stageOptions,
    Value = SelectedAutoFarmStage,
    Callback = function(Value)
        SelectedAutoFarmStage = Value
    end
})

_G.AutoClickToggle = false
FarmingSection:Toggle({
    Title = "Auto Click",
    Value = false,
    Callback = function(Value)
        _G.AutoClickToggle = Value
        if Value then
            task.spawn(function()
                local remoteObj = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 5)
                local serverFolder = remoteObj and remoteObj:WaitForChild("Server", 5)
                local clickRemote = serverFolder and serverFolder:WaitForChild("Click", 5)
                
                if not clickRemote then
                    return
                end
                
                for i = 1, 5 do
                    task.spawn(function()
                        while _G.AutoClickToggle do
                            clickRemote:FireServer()
                            task.wait(0.01)
                        end
                    end)
                end
            end)
        end
    end
})

_G.AutoMineToggle = false
FarmingSection:Toggle({
    Title = "Auto Mine",
    Value = false,
    Callback = function(Value)
        _G.AutoMineToggle = Value
        if Value then
            task.spawn(function()
                local remoteObj = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 5)
                local serverFolder = remoteObj and remoteObj:WaitForChild("Server", 5)
                local hitWallRemote = serverFolder and serverFolder:WaitForChild("HitWall", 5)
                
                if not hitWallRemote then
                    return
                end
                
                while _G.AutoMineToggle do
                    local foundStage = nil
                    local partsToMine = {}
                    
                    local stagesFolder = workspace:FindFirstChild("Stages")
                    if stagesFolder then
                        for stageIdx = 1, 100 do
                            local stageStr = tostring(stageIdx)
                            local stageModel = stagesFolder:FindFirstChild("Stage " .. stageStr)
                            if stageModel then
                                local innerStages = stageModel:FindFirstChild("Stages")
                                if innerStages then
                                    for partIdx = 1, 500 do
                                        local partStr = tostring(partIdx)
                                        local actualPart = innerStages:FindFirstChild(partStr)
                                        if actualPart and actualPart.CanCollide then
                                            foundStage = stageIdx
                                            table.insert(partsToMine, partIdx)
                                            if #partsToMine >= 3 then break end
                                        end
                                    end
                                end
                            end
                            if foundStage then break end
                        end
                    end
                    
                    if foundStage and #partsToMine > 0 then
                        for _, pIdx in ipairs(partsToMine) do
                            hitWallRemote:FireServer(foundStage, pIdx)
                        end
                    end
                    task.wait(0.2)
                end
            end)
        end
    end
})

_G.AutoSellAllToggle = false
FarmingSection:Toggle({
    Title = "Auto Sell All",
    Value = false,
    Callback = function(Value)
        _G.AutoSellAllToggle = Value
        if Value then
            task.spawn(function()
                while _G.AutoSellAllToggle do
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Server"):WaitForChild("SellAllLoot"):FireServer()
                    end)
                    task.wait(10)
                end
            end)
        end
    end
})

local LocalPlayer = game:GetService("Players").LocalPlayer

local function getPlayerCash()
    local cashObj = LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Cash")
    if cashObj then
        local val = tostring(cashObj.Value)
        if NumberConverter and NumberConverter.Parse then
            return NumberConverter.Parse(val)
        end
        return tonumber(val) or 0
    end
    return 0
end

local AutoBuySection = Tabs.Main:Section({ Title = "Auto Buy", Box = true, BoxBorder = true, Expandable = true, Opened = true })

_G.AutoBuyAurasToggle = false
AutoBuySection:Toggle({
    Title = "Auto Buy Auras",
    Value = false,
    Callback = function(Value)
        _G.AutoBuyAurasToggle = Value
        if Value then
            task.spawn(function()
                while _G.AutoBuyAurasToggle do
                    pcall(function()
                        local mainGui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Main")
                        if not mainGui then return end
                        local holder = mainGui:FindFirstChild("AurasFrame") and mainGui.AurasFrame:FindFirstChild("AuraScrollingFrame") and mainGui.AurasFrame.AuraScrollingFrame:FindFirstChild("Holder")
                        if not holder then return end
                        
                        local bestEquippedBoost = -1
                        local bestAffordableBoost = -1
                        local bestAffordableAura = nil
                        
                        local currentCash = getPlayerCash()
                        
                        local function cleanText(text)
                            if type(text) ~= "string" then return "" end
                            local c = string.gsub(text, "<[^>]+>", "")
                            return string.gsub(c, "^%s*(.-)%s*$", "%1")
                        end
                        
                        for _, item in ipairs(holder:GetChildren()) do
                            if item:FindFirstChild("Boost") and item:FindFirstChild("Buttons") and item.Buttons:FindFirstChild("PurchaseButton") and item.Buttons.PurchaseButton.Visible and item.Buttons.PurchaseButton:FindFirstChild("Amount") then
                                local boostText = cleanText(item.Boost.Text)
                                local boostVal = tonumber(string.match(boostText, "([%d%.]+)")) or 0
                                
                                local btnText = cleanText(item.Buttons.PurchaseButton.Amount.Text)
                                local lowerBtn = string.lower(btnText)
                                
                                if lowerBtn == "unequip" or lowerBtn == "equipped" then
                                    if boostVal > bestEquippedBoost then
                                        bestEquippedBoost = boostVal
                                    end
                                elseif lowerBtn == "equip" then
                                    if boostVal > bestEquippedBoost and boostVal > bestAffordableBoost then
                                        bestAffordableBoost = boostVal
                                        bestAffordableAura = item.Name
                                    end
                                else
                                    local cleanPrice = string.gsub(btnText, "%$", "")
                                    local priceVal = 0
                                    if NumberConverter and NumberConverter.Parse then
                                        priceVal = NumberConverter.Parse(cleanPrice)
                                    else
                                        priceVal = tonumber(cleanPrice) or math.huge
                                    end
                                    
                                    if currentCash >= priceVal then
                                        if boostVal > bestAffordableBoost then
                                            bestAffordableBoost = boostVal
                                            bestAffordableAura = item.Name
                                        end
                                    end
                                end
                            end
                        end
                        
                        if bestAffordableBoost > bestEquippedBoost and bestAffordableAura then
                            local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 3)
                            if remotes then
                                local server = remotes:WaitForChild("Server", 3)
                                if server then
                                    local purchaseAura = server:WaitForChild("PurchaseAura", 3)
                                    if purchaseAura then
                                        purchaseAura:FireServer(bestAffordableAura)
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(2.5)
                end
            end)
        end
    end
})

_G.AutoBuyPickaxeToggle = false
AutoBuySection:Toggle({
    Title = "Auto Buy Pickaxe",
    Value = false,
    Callback = function(Value)
        _G.AutoBuyPickaxeToggle = Value
        if Value then
            task.spawn(function()
                while _G.AutoBuyPickaxeToggle do
                    pcall(function()
                        local mainGui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Main")
                        if not mainGui then return end
                        local holder = mainGui:FindFirstChild("PickaxeFrame") and mainGui.PickaxeFrame:FindFirstChild("PickaxesScrollingFrame") and mainGui.PickaxeFrame.PickaxesScrollingFrame:FindFirstChild("Holder")
                        if not holder then return end
                        
                        local bestEquippedStrength = -1
                        local bestAffordableStrength = -1
                        local bestAffordablePickaxe = nil
                        local shouldJustEquip = false
                        
                        local currentCash = getPlayerCash()
                        
                        local function cleanText(text)
                            if type(text) ~= "string" then return "" end
                            local c = string.gsub(text, "<[^>]+>", "")
                            return string.gsub(c, "^%s*(.-)%s*$", "%1")
                        end
                        
                        for _, item in ipairs(holder:GetChildren()) do
                            if item:FindFirstChild("Strength") and item.Strength:FindFirstChild("Amount") and item:FindFirstChild("Buttons") and item.Buttons:FindFirstChild("PurchaseButton") and item.Buttons.PurchaseButton.Visible and item.Buttons.PurchaseButton:FindFirstChild("Amount") then
                                local strText = cleanText(item.Strength.Amount.Text)
                                local cleanStr = string.gsub(strText, "%+", "")
                                local strengthVal = 0
                                if NumberConverter and NumberConverter.Parse then
                                    strengthVal = NumberConverter.Parse(cleanStr)
                                else
                                    strengthVal = tonumber(cleanStr) or 0
                                end
                                
                                local btnText = cleanText(item.Buttons.PurchaseButton.Amount.Text)
                                local lowerBtn = string.lower(btnText)
                                
                                if lowerBtn == "equipped" or lowerBtn == "unequip" then
                                    if strengthVal > bestEquippedStrength then
                                        bestEquippedStrength = strengthVal
                                    end
                                elseif lowerBtn == "equip" then
                                    if strengthVal > bestEquippedStrength and strengthVal > bestAffordableStrength then
                                        bestAffordableStrength = strengthVal
                                        bestAffordablePickaxe = item.Name
                                        shouldJustEquip = true
                                    end
                                else
                                    local cleanPrice = string.gsub(btnText, "%$", "")
                                    local priceVal = 0
                                    if NumberConverter and NumberConverter.Parse then
                                        priceVal = NumberConverter.Parse(cleanPrice)
                                    else
                                        priceVal = tonumber(cleanPrice) or math.huge
                                    end
                                    
                                    if currentCash >= priceVal then
                                        if strengthVal > bestAffordableStrength then
                                            bestAffordableStrength = strengthVal
                                            bestAffordablePickaxe = item.Name
                                            shouldJustEquip = false
                                        end
                                    end
                                end
                            end
                        end
                        
                        if bestAffordableStrength > bestEquippedStrength and bestAffordablePickaxe then
                            local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 3)
                            if remotes then
                                local server = remotes:WaitForChild("Server", 3)
                                if server then
                                    if shouldJustEquip then
                                        local equipPickaxe = server:WaitForChild("EquipPickaxe", 3)
                                        if equipPickaxe then
                                            equipPickaxe:FireServer(bestAffordablePickaxe, "Cash")
                                        end
                                    else
                                        local purchasePickaxe = server:WaitForChild("PurchasePickaxe", 3)
                                        if purchasePickaxe then
                                            purchasePickaxe:FireServer(bestAffordablePickaxe, "Cash")
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(2.5)
                end
            end)
        end
    end
})

_G.AutoUpgradeCarryToggle = false
AutoBuySection:Toggle({
    Title = "Auto Upgrade Carry",
    Value = false,
    Callback = function(Value)
        _G.AutoUpgradeCarryToggle = Value
        if Value then
            task.spawn(function()
                while _G.AutoUpgradeCarryToggle do
                    pcall(function()
                        local mainGui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Main")
                        if not mainGui then return end
                        local holder = mainGui:FindFirstChild("UpgradeFrame") and mainGui.UpgradeFrame:FindFirstChild("UpgradesScrollingFrame") and mainGui.UpgradeFrame.UpgradesScrollingFrame:FindFirstChild("Holder")
                        if not holder then return end
                        
                        local slots = holder:FindFirstChild("Slots")
                        if slots and slots:FindFirstChild("Buttons") and slots.Buttons:FindFirstChild("PurchaseButton") and slots.Buttons.PurchaseButton:FindFirstChild("Amount") then
                            local function cleanText(text)
                                if type(text) ~= "string" then return "" end
                                local c = string.gsub(text, "<[^>]+>", "")
                                return string.gsub(c, "^%s*(.-)%s*$", "%1")
                            end
                            local btnText = cleanText(slots.Buttons.PurchaseButton.Amount.Text)
                            local lowerBtn = string.lower(btnText)
                            if lowerBtn ~= "max" and lowerBtn ~= "maxed" then
                                local cleanPrice = string.gsub(btnText, "%$", "")
                                local priceVal = 0
                                if NumberConverter and NumberConverter.Parse then
                                    priceVal = NumberConverter.Parse(cleanPrice)
                                else
                                    priceVal = tonumber(cleanPrice) or math.huge
                                end
                                
                                local currentCash = getPlayerCash()
                                if currentCash >= priceVal then
                                    local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 3)
                                    if remotes then
                                        local server = remotes:WaitForChild("Server", 3)
                                        if server then
                                            local upgradeSlot = server:WaitForChild("UpgradeSlot", 3)
                                            if upgradeSlot then
                                                upgradeSlot:FireServer("Cash")
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.2)
                end
            end)
        end
    end
})

_G.AutoUpgradeWalkSpeedToggle = false
AutoBuySection:Toggle({
    Title = "Auto Upgrade WalkSpeed",
    Value = false,
    Callback = function(Value)
        _G.AutoUpgradeWalkSpeedToggle = Value
        if Value then
            task.spawn(function()
                while _G.AutoUpgradeWalkSpeedToggle do
                    pcall(function()
                        local mainGui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Main")
                        if not mainGui then return end
                        local holder = mainGui:FindFirstChild("UpgradeFrame") and mainGui.UpgradeFrame:FindFirstChild("UpgradesScrollingFrame") and mainGui.UpgradeFrame.UpgradesScrollingFrame:FindFirstChild("Holder")
                        if not holder then return end
                        
                        local walkspeed = holder:FindFirstChild("Walkspeed")
                        if walkspeed and walkspeed:FindFirstChild("Buttons") and walkspeed.Buttons:FindFirstChild("PurchaseButton") and walkspeed.Buttons.PurchaseButton:FindFirstChild("Amount") then
                            local function cleanText(text)
                                if type(text) ~= "string" then return "" end
                                local c = string.gsub(text, "<[^>]+>", "")
                                return string.gsub(c, "^%s*(.-)%s*$", "%1")
                            end
                            local btnText = cleanText(walkspeed.Buttons.PurchaseButton.Amount.Text)
                            local lowerBtn = string.lower(btnText)
                            if lowerBtn ~= "max" and lowerBtn ~= "maxed" then
                                local cleanPrice = string.gsub(btnText, "%$", "")
                                local priceVal = 0
                                if NumberConverter and NumberConverter.Parse then
                                    priceVal = NumberConverter.Parse(cleanPrice)
                                else
                                    priceVal = tonumber(cleanPrice) or math.huge
                                end
                                
                                local currentCash = getPlayerCash()
                                if currentCash >= priceVal then
                                    local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 3)
                                    if remotes then
                                        local server = remotes:WaitForChild("Server", 3)
                                        if server then
                                            local upgradeWs = server:WaitForChild("UpgradeWalkspeed", 3)
                                            if upgradeWs then
                                                upgradeWs:FireServer("Cash")
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.2)
                end
            end)
        end
    end
})

_G.AutoRebirthToggle = false
Tabs.Main:Toggle({
    Title = "Auto Rebirth",
    Value = false,
    Callback = function(Value)
        _G.AutoRebirthToggle = Value
        if Value then
            task.spawn(function()
                while _G.AutoRebirthToggle do
                    pcall(function()
                        local LocalPlayer = game:GetService("Players").LocalPlayer
                        local pb = LocalPlayer.PlayerGui.Main.RebirthFrame.SpeedProgressBar.ProgressBar
                        if pb.Size.X.Scale >= 1 and pb.Size.Y.Scale >= 1 then
                            local args = { "Rebirth" }
                            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Server"):WaitForChild("Rebirth"):FireServer(unpack(args))
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    end
})

WindUI:Notify({
    Title = "Prime X Hub",
    Content = "Script loaded successfully!",
    Duration = 5
})
