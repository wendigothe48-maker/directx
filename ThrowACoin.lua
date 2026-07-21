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


local function CleanAndParse(rawText)
    if type(rawText) ~= "string" then rawText = tostring(rawText) end
    local text = rawText
    -- Remove rich text tags
    text = string.gsub(text, "<[^>]+>", "")
    -- Remove known labels
    text = string.gsub(text, "[Ww]ins?", "")
    text = string.gsub(text, "[Ss]peed", "")
    text = string.gsub(text, "[Aa]mount", "")
    text = string.gsub(text, "[Pp]rice:?", "")
    text = string.gsub(text, "[Cc]ost:?", "")
    text = string.gsub(text, "[Cc]oins?", "")
    text = string.gsub(text, "[Ll]uck", "")
    -- Remove symbols: $, +, comma, space, colon
    text = string.gsub(text, "[%$%+%s,:]", "")
    -- Remove leading x or X (like x1.5)
    text = string.gsub(text, "^[xX]+", "")
    -- Remove trailing x or X (like 5x)
    text = string.gsub(text, "[xX]+$", "")
    
    local num = tonumber(text)
    if num then return num end
    
    local suffixes = {k = 1e3, m = 1e6, b = 1e9, t = 1e12, qa = 1e15, qi = 1e18, sx = 1e21}
    local numberPart, suffixPart = string.match(string.lower(text), "^([%d%.]+)([a-z]+)$")
    if numberPart then
        local n = tonumber(numberPart)
        if n then
            if suffixPart and suffixes[suffixPart] then
                return n * suffixes[suffixPart]
            else
                return n
            end
        end
    end
    
    local finalClean = string.gsub(text, "[^%d%.]", "")
    return tonumber(finalClean) or 0
end

local Tabs = {
    Main = Window:Tab({ Title = "Main", Icon = "solar:home-2-bold" }),
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

local MainSection = Tabs.Main:Section({
    Title = "Farming",
    Box = true,
    BoxBorder = true,
    Expandable = true,
    Opened = true
})


local function GetBestOwnedCoin()
    local bestCoin = "Basic Coin"
    local bestStat = -1
    
    pcall(function()
        local lp = game:GetService("Players").LocalPlayer
        local coinShop = lp.PlayerGui.UiFolder.Main.Frames.CoinShop.SFcontainer.SF
        
        for _, coinFrame in ipairs(coinShop:GetChildren()) do
            if coinFrame:IsA("Frame") and coinFrame.Name ~= "Template" and coinFrame:FindFirstChild("Main") then
                local main = coinFrame.Main
                local buyBtn = main:FindFirstChild("ButtonContainer") and main.ButtonContainer:FindFirstChild("BuyButton")
                if buyBtn and buyBtn.Visible then
                    local priceLabel = buyBtn:FindFirstChild("Price")
                    if priceLabel then
                        local priceText = string.lower(priceLabel.Text)
                        if string.find(priceText, "equip") then
                            local rarityLabel = main:FindFirstChild("RarityChanceInfo") and main.RarityChanceInfo:FindFirstChild("RarityChance") and main.RarityChanceInfo.RarityChance:FindFirstChild("Chance")
                            if rarityLabel then
                                local stat = CleanAndParse(rarityLabel.Text)
                                if stat > bestStat then
                                    bestStat = stat
                                    bestCoin = coinFrame.Name
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    
    return bestCoin
end

_G.AutoThrow = false
MainSection:Toggle({
    Title = "Auto Throw (2x Luck)",
    Value = false,
    Callback = function(Value)
        _G.AutoThrow = Value
        if Value then
            task.spawn(function()
                while _G.AutoThrow do
                    pcall(function()
                        local bestCoinName = GetBestOwnedCoin()
                        local args = {
                            2,
                            Vector3.new(-1164.7989501953125, 0.7260000109672546, -175.9498291015625),
                            bestCoinName
                        }
                        game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Events"):WaitForChild("CoinLanded"):FireServer(unpack(args))
                    end)
                    task.wait(1)
                end
            end)
        end
    end
})


local UpgradesSection = Tabs.Main:Section({
    Title = "Upgrades",
    Box = true,
    BoxBorder = true,
    Expandable = true,
    Opened = true
})

_G.AutoBestBuyCoins = false
UpgradesSection:Toggle({
    Title = "Auto Best Buy Coins",
    Value = false,
    Callback = function(Value)
        _G.AutoBestBuyCoins = Value
        if Value then
            task.spawn(function()
                while _G.AutoBestBuyCoins do
                    local success, err = pcall(function()
                        local lp = game:GetService("Players").LocalPlayer
                        local cashObj = lp:FindFirstChild("leaderstats") and lp.leaderstats:FindFirstChild("Cash")
                        if not cashObj then return end
                        
                        local currentCash = CleanAndParse(cashObj.Value)
                        local coinShop = lp.PlayerGui.UiFolder.Main.Frames.CoinShop.SFcontainer.SF
                        
                        local bestOwnedStat = -1
                        local bestUnownedCoin = nil
                        local bestUnownedStat = -1
                        
                        for _, coinFrame in ipairs(coinShop:GetChildren()) do
                            if coinFrame:IsA("Frame") and coinFrame.Name ~= "Template" and coinFrame:FindFirstChild("Main") then
                                local coinName = coinFrame.Name
                                local main = coinFrame.Main
                                local buyBtn = main:FindFirstChild("ButtonContainer") and main.ButtonContainer:FindFirstChild("BuyButton")
                                
                                if buyBtn and buyBtn.Visible then
                                    local priceLabel = buyBtn:FindFirstChild("Price")
                                    local rarityLabel = main:FindFirstChild("RarityChanceInfo") and main.RarityChanceInfo:FindFirstChild("RarityChance") and main.RarityChanceInfo.RarityChance:FindFirstChild("Chance")
                                    
                                    if priceLabel and rarityLabel then
                                        local priceText = string.lower(priceLabel.Text)
                                        local statText = rarityLabel.Text
                                        local stat = CleanAndParse(statText)
                                        
                                        if string.find(priceText, "equip") then
                                            if stat > bestOwnedStat then
                                                bestOwnedStat = stat
                                            end
                                        else
                                            local priceTextRaw = priceLabel.Text
                                            local price = CleanAndParse(priceTextRaw)
                                            
                                            if currentCash >= price then
                                                if stat > bestUnownedStat then
                                                    bestUnownedStat = stat
                                                    bestUnownedCoin = coinName
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        
                        if bestUnownedCoin then
                            if bestUnownedStat > bestOwnedStat then
                                local args = { bestUnownedCoin }
                                game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Events"):WaitForChild("BuyCoin"):FireServer(unpack(args))
                            end
                        end
                    end)
                    task.wait(0.3)
                end
            end)
        end
    end
})

_G.AutoUpgradeLuck = false
UpgradesSection:Toggle({
    Title = "Auto Upgrade Luck",
    Value = false,
    Callback = function(Value)
        _G.AutoUpgradeLuck = Value
        if Value then
            task.spawn(function()
                while _G.AutoUpgradeLuck do
                    pcall(function()
                        local lp = game:GetService("Players").LocalPlayer
                        local cashObj = lp:FindFirstChild("leaderstats") and lp.leaderstats:FindFirstChild("Cash")
                        if not cashObj then return end
                        
                        local currentCash = CleanAndParse(cashObj.Value)
                        local upgradeFrame = lp.PlayerGui.UiFolder.Main.Frames.Upgrades.SFHolder["Luck Multiplier"]
                        local amountLabel = upgradeFrame.Main.BuyButton:FindFirstChild("Amount")
                        
                        if amountLabel then
                            local cost = CleanAndParse(amountLabel.Text)
                            if currentCash >= cost then
                                local args = { "Luck Multiplier" }
                                game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Events"):WaitForChild("RequestUpgrade"):FireServer(unpack(args))
                            end
                        end
                    end)
                    task.wait(0.3)
                end
            end)
        end
    end
})

_G.AutoUpgradeValue = false
UpgradesSection:Toggle({
    Title = "Auto Upgrade Value",
    Value = false,
    Callback = function(Value)
        _G.AutoUpgradeValue = Value
        if Value then
            task.spawn(function()
                while _G.AutoUpgradeValue do
                    pcall(function()
                        local lp = game:GetService("Players").LocalPlayer
                        local cashObj = lp:FindFirstChild("leaderstats") and lp.leaderstats:FindFirstChild("Cash")
                        if not cashObj then return end
                        
                        local currentCash = CleanAndParse(cashObj.Value)
                        local upgradeFrame = lp.PlayerGui.UiFolder.Main.Frames.Upgrades.SFHolder["Value Multiplier"]
                        local amountLabel = upgradeFrame.Main.BuyButton:FindFirstChild("Amount")
                        
                        if amountLabel then
                            local cost = CleanAndParse(amountLabel.Text)
                            if currentCash >= cost then
                                local args = { "Value Multiplier" }
                                game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Events"):WaitForChild("RequestUpgrade"):FireServer(unpack(args))
                            end
                        end
                    end)
                    task.wait(0.3)
                end
            end)
        end
    end
})

_G.AutoSellAll = false
MainSection:Toggle({
    Title = "Auto SellAll (10S Delay)",
    Value = false,
    Callback = function(Value)
        _G.AutoSellAll = Value
        if Value then
            task.spawn(function()
                while _G.AutoSellAll do
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Events"):WaitForChild("SellAll"):FireServer()
                    end)
                    task.wait(10)
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
