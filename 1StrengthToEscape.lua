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
    Main = Window:Tab({ Title = "Main", Icon = "solar:home-bold" }),
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

-- ==========================================
--                  MAIN TAB
-- ==========================================

local StageAndAutoFarmSection = Tabs.Main:Section({
    Title = "Stage & Auto Farm",
    Box = true,
    BoxBorder = true,
    Expandable = true,
    Opened = true
})

_G.AutoGainStrengthToggle = false
StageAndAutoFarmSection:Toggle({
    Title = "Auto Gain Strength",
    Value = false,
    Callback = function(Value)
        _G.AutoGainStrengthToggle = Value
        if Value then
            task.spawn(function()
                while _G.AutoGainStrengthToggle do
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Server"):WaitForChild("GainStrength"):FireServer()
                    end)
                    task.wait(0.03)
                end
            end)
        end
    end
})

StageAndAutoFarmSection:Button({
    Title = "Remove Obstacles",
    Callback = function()
        pcall(function()
            local stagesFolder = workspace:FindFirstChild("Stages")
            if stagesFolder then
                for _, stageModel in ipairs(stagesFolder:GetChildren()) do
                    local obstacles = stageModel:FindFirstChild("Obstacles")
                    if obstacles then
                        obstacles:Destroy()
                    end
                end
            end
        end)
    end
})

_G.HighestBrokenStage = _G.HighestBrokenStage or 0

local function updateHighestBrokenStage()
    local stagesFolder = workspace:FindFirstChild("Stages")
    if stagesFolder then
        for _, stageModel in ipairs(stagesFolder:GetChildren()) do
            local stageNum = tonumber(string.match(stageModel.Name, "Stage (%d+)"))
            if stageNum then
                local wall = stageModel:FindFirstChild("Wall")
                if wall and not wall.CanCollide then
                    if stageNum > _G.HighestBrokenStage then
                        _G.HighestBrokenStage = stageNum
                    end
                end
            end
        end
    end
end

local stageNames = {}
local stagesFolder = workspace:FindFirstChild("Stages")
if stagesFolder then
    for _, stageModel in ipairs(stagesFolder:GetChildren()) do
        if string.match(stageModel.Name, "Stage (%d+)") then
            table.insert(stageNames, stageModel.Name)
        end
    end
end
table.sort(stageNames, function(a, b)
    local numA = tonumber(string.match(a, "%d+")) or 0
    local numB = tonumber(string.match(b, "%d+")) or 0
    return numA > numB
end)

if #stageNames == 0 then
    table.insert(stageNames, "Stage 1")
end

_G.TargetStage = stageNames[1]

_G.AutoFarmToggle = false
StageAndAutoFarmSection:Toggle({
    Title = "Auto Farm",
    Value = false,
    Callback = function(Value)
        _G.AutoFarmToggle = Value
        if Value then
            task.spawn(function()
                while _G.AutoFarmToggle do
                    pcall(function()
                        updateHighestBrokenStage()
                        
                        local targetStageNum = tonumber(string.match(_G.TargetStage, "%d+")) or 1
                        
                        -- Keep broken walls invisible and non-collidable
                        local stagesFolder = workspace:FindFirstChild("Stages")
                        if stagesFolder then
                            for _, stageModel in ipairs(stagesFolder:GetChildren()) do
                                local sNum = tonumber(string.match(stageModel.Name, "Stage (%d+)"))
                                if sNum and sNum <= _G.HighestBrokenStage then
                                    local wall = stageModel:FindFirstChild("Wall")
                                    if wall then
                                        wall.CanCollide = false
                                        wall.Transparency = 1
                                    end
                                end
                            end
                        end
                        
                        if _G.HighestBrokenStage < targetStageNum then
                            local currentTarget = _G.HighestBrokenStage + 1
                            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Server"):WaitForChild("PunchWall"):FireServer(currentTarget)
                        else
                            if stagesFolder then
                                local targetStageModel = stagesFolder:FindFirstChild("Stage " .. tostring(targetStageNum))
                                if targetStageModel then
                                    local hitbox = targetStageModel:FindFirstChild("Wins") 
                                        and targetStageModel.Wins:FindFirstChild("Wins") 
                                        and targetStageModel.Wins.Wins:FindFirstChild("Hitbox")
                                        
                                    if hitbox then
                                        local LocalPlayer = game:GetService("Players").LocalPlayer
                                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                        if hrp then
                                            fireTouch(hrp, hitbox)
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.05)
                end
            end)
        end
    end
})

StageAndAutoFarmSection:Dropdown({
    Title = "Select Farm Stage",
    Values = stageNames,
    Value = _G.TargetStage,
    Callback = function(Value)
        _G.TargetStage = Value
    end
})

local AutoBuySection = Tabs.Main:Section({
    Title = "Auto Buy",
    Box = true,
    BoxBorder = true,
    Expandable = true,
    Opened = true
})

_G.AutoBuyWeightToggle = false
AutoBuySection:Toggle({
    Title = "Auto Buy Weight",
    Value = false,
    Callback = function(Value)
        _G.AutoBuyWeightToggle = Value
        if Value then
            task.spawn(function()
                while _G.AutoBuyWeightToggle do
                    pcall(function()
                        local LocalPlayer = game:GetService("Players").LocalPlayer
                        local weightsFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Weights")
                        if weightsFolder then
                            local bestWeightName = nil
                            local highestPrice = -1
                            local targetAction = nil -- "Purchase" or "Equip"
                            
                            local availableWeights = {}
                            for _, weight in ipairs(weightsFolder:GetChildren()) do
                                local marker = weight:FindFirstChild("Marker")
                                local prompt = marker and marker:FindFirstChild("ProximityPrompt")
                                
                                if prompt then
                                    local actionText = prompt.ActionText
                                    local price = 0
                                    local canProcess = false
                                    
                                    if actionText == "Purchase?" then
                                        local winsGui = marker:FindFirstChild("Title") and marker.Title:FindFirstChild("BillboardGui") and marker.Title.BillboardGui:FindFirstChild("Wins")
                                        if winsGui then
                                            local priceStr = string.gsub(winsGui.Text, "Wins", "")
                                            priceStr = string.gsub(priceStr, "%s+", "")
                                            if NumberConverter and NumberConverter.Parse then
                                                price = NumberConverter.Parse(priceStr)
                                            else
                                                price = tonumber(string.match(priceStr, "[%d%.]+")) or 0
                                            end
                                            canProcess = true
                                        end
                                    elseif actionText == "Equip?" then
                                        -- Already owned, treat its value as high to favor equipping if we can't buy better
                                        -- We need its "worth" (Wins value) to compare, but if it doesn't show Wins when owned, we assume we recorded it or we just check if it's currently unequipped
                                        canProcess = true
                                        price = 0 -- We'll just look for the highest price unowned, or the best owned one.
                                        -- Actually, since we want the best overall, we can evaluate price from BillboardGui if it exists. 
                                        local winsGui = marker:FindFirstChild("Title") and marker.Title:FindFirstChild("BillboardGui") and marker.Title.BillboardGui:FindFirstChild("Wins")
                                        if winsGui then
                                            local priceStr = string.gsub(winsGui.Text, "Wins", "")
                                            priceStr = string.gsub(priceStr, "%s+", "")
                                            if NumberConverter and NumberConverter.Parse then
                                                price = NumberConverter.Parse(priceStr)
                                            else
                                                price = tonumber(string.match(priceStr, "[%d%.]+")) or 0
                                            end
                                        end
                                    end
                                    
                                    if canProcess then
                                        table.insert(availableWeights, {
                                            Name = weight.Name,
                                            Action = actionText,
                                            Price = price,
                                            WeightInst = weight
                                        })
                                    end
                                end
                            end
                            
                            local playerWins = LocalPlayer.leaderstats and LocalPlayer.leaderstats:FindFirstChild("Wins") and tonumber(LocalPlayer.leaderstats.Wins.Value) or 0
                            
                            for _, wData in ipairs(availableWeights) do
                                if wData.Action == "Purchase?" then
                                    if playerWins >= wData.Price and wData.Price > highestPrice then
                                        highestPrice = wData.Price
                                        bestWeightName = wData.Name
                                        targetAction = "Purchase"
                                    end
                                elseif wData.Action == "Equip?" then
                                    if wData.Price >= highestPrice then
                                        local standEquipped = wData.WeightInst:FindFirstChild("Stand") and wData.WeightInst.Stand:FindFirstChild("Equipped")
                                        if standEquipped then
                                            -- Check color to see if it's NOT equipped
                                            if standEquipped.Color == Color3.fromRGB(255, 0, 0) then
                                                highestPrice = wData.Price
                                                bestWeightName = wData.Name
                                                targetAction = "Equip"
                                            elseif standEquipped.Color == Color3.fromRGB(85, 255, 0) then
                                                -- It is currently equipped, meaning we already have the best possible equipped if we don't find a better purchase
                                                if wData.Price >= highestPrice then
                                                    highestPrice = wData.Price
                                                    bestWeightName = nil -- We are already using it
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            
                            if bestWeightName and targetAction then
                                if targetAction == "Purchase" then
                                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Server"):WaitForChild("PurchaseWeight"):FireServer(bestWeightName)
                                elseif targetAction == "Equip" then
                                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Server"):WaitForChild("EquipWeight"):FireServer(bestWeightName)
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

_G.AutoBuyAuraToggle = false
AutoBuySection:Toggle({
    Title = "Auto Buy Aura",
    Value = false,
    Callback = function(Value)
        _G.AutoBuyAuraToggle = Value
        if Value then
            task.spawn(function()
                while _G.AutoBuyAuraToggle do
                    pcall(function()
                        local LocalPlayer = game:GetService("Players").LocalPlayer
                        local holder = LocalPlayer.PlayerGui.Main.AurasFrame.AuraScrollingFrame.Holder
                        
                        local bestAuraName = nil
                        local highestBoost = -1
                        local targetAction = nil
                        
                        local playerWins = LocalPlayer.leaderstats and LocalPlayer.leaderstats:FindFirstChild("Wins") and tonumber(LocalPlayer.leaderstats.Wins.Value) or 0
                        
                        for _, auraUI in ipairs(holder:GetChildren()) do
                            if auraUI:IsA("Frame") and auraUI:FindFirstChild("Boost") and auraUI:FindFirstChild("Options") then
                                local boostStr = string.gsub(auraUI.Boost.Text, "x Boost", "")
                                boostStr = string.gsub(boostStr, "%s+", "")
                                local boostVal = tonumber(boostStr) or 0
                                
                                local options = auraUI.Options
                                local winsButton = options:FindFirstChild("WinsButton")
                                local purchaseButton = options:FindFirstChild("PurchaseButton")
                                
                                if winsButton and winsButton.Visible then
                                    -- Unowned
                                    local priceStr = winsButton:FindFirstChild("Price") and winsButton.Price.Text or "0"
                                    priceStr = string.gsub(priceStr, "%s+", "")
                                    local price = 0
                                    if NumberConverter and NumberConverter.Parse then
                                        price = NumberConverter.Parse(priceStr)
                                    else
                                        price = tonumber(string.match(priceStr, "[%d%.]+")) or math.huge
                                    end
                                    
                                    if playerWins >= price and boostVal > highestBoost then
                                        highestBoost = boostVal
                                        bestAuraName = auraUI.Name
                                        targetAction = "Purchase"
                                    end
                                elseif winsButton and not winsButton.Visible and purchaseButton then
                                    -- Owned
                                    local actionText = purchaseButton:FindFirstChild("Price") and purchaseButton.Price.Text or ""
                                    if actionText == "Equip" then
                                        -- Unequipped
                                        if boostVal > highestBoost then
                                            highestBoost = boostVal
                                            bestAuraName = auraUI.Name
                                            targetAction = "Equip"
                                        end
                                    elseif actionText == "Unequip" then
                                        -- Currently Equipped
                                        if boostVal >= highestBoost then
                                            highestBoost = boostVal
                                            bestAuraName = nil
                                        end
                                    end
                                end
                            end
                        end
                        
                        if bestAuraName and targetAction then
                            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Server"):WaitForChild("PurchaseAura"):FireServer(bestAuraName)
                        end
                    end)
                    task.wait(2.5)
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
                        local bar = LocalPlayer.PlayerGui.Main.RebirthFrame.SpeedProgressBar.ProgressBar
                        if bar.Size.X.Scale >= 1 and bar.Size.Y.Scale >= 1 then
                            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Server"):WaitForChild("Rebirth"):FireServer("Rebirth")
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
