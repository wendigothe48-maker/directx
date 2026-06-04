-- fluent code converted to wind ui
-- [[ KEY SYSTEM LOADER ]] --
local KeySystem = loadstring(game:HttpGet("https://raw.githubusercontent.com/wendigo5414-cmyk/scripts/refs/heads/main/keysystem.lua"))()
KeySystem.Init()

-- [[ GAME SCRIPT START ]] --
local cloneref = (cloneref or clonereference or function(instance) return instance end)
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

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

-- ══════════════════════════════════════════
--              MAIN SKELETON CODE
-- ══════════════════════════════════════════

local function getPlayerCash()
    local cashObj = game:GetService("Players").LocalPlayer.leaderstats.Cash
    if cashObj then
        local val = cashObj.Value
        if type(val) == "string" then
            local cleanStr = string.gsub(val, "[%$%s]", "")
            return NumberConverter and NumberConverter.Parse(cleanStr) or 0
        else
            return tonumber(val) or 0
        end
    end
    return 0
end

local myCachedPlot = nil
local function getMyPlot()
    if myCachedPlot and myCachedPlot.Parent then
        return myCachedPlot
    end

    local bases = workspace:FindFirstChild("Bases")
    if bases then
        for _, base in ipairs(bases:GetChildren()) do
            local infoBasePart = base:FindFirstChild("InfoBasePart")
            if infoBasePart then
                local surfaceGui = infoBasePart:FindFirstChild("SurfaceGui")
                if surfaceGui then
                    local baseName = surfaceGui:FindFirstChild("BaseName")
                    if baseName then
                        local nameObj = baseName:FindFirstChild("Name")
                        if nameObj and (nameObj:IsA("TextLabel") or nameObj:IsA("StringValue") or nameObj:IsA("TextButton")) then
                            local text = nameObj.Text or nameObj.Value
                            if text and text:match(LocalPlayer.Name) then
                                myCachedPlot = base
                                print("Successfully Locked your Base:", base.Name)
                                return base
                            end
                        end
                    end
                end
            end
        end
    end
    return nil
end

task.spawn(function()
    while not myCachedPlot do
        getMyPlot()
        task.wait(1)
    end
end)

local AutoBrainrotSection = Tabs.Main:Section({
    Title = "Auto Brainrot",
    Box = true,
    BoxBorder = true,
    Expandable = true,
    Opened = true
})

local availableRarities = {}
pcall(function()
    local mapWalls = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Walls")
    if mapWalls then
        for _, child in ipairs(mapWalls:GetChildren()) do
            if string.lower(string.sub(child.Name, 1, 3)) == "gui" then
                local surfaceGui = child:FindFirstChild("SurfaceGui")
                if surfaceGui then
                    local rarityLabel = surfaceGui:FindFirstChild("Rarity")
                    if rarityLabel and (rarityLabel:IsA("TextLabel") or (type(rarityLabel) == "userdata" and type(rarityLabel.Text) == "string")) then
                        local text = rarityLabel.Text
                        if text and text ~= "" then
                            local rarityName = string.match(text, "^%s*(%S+)")
                            if rarityName then
                                local exists = false
                                for _, v in ipairs(availableRarities) do
                                    if v == rarityName then exists = true; break end
                                end
                                if not exists then
                                    table.insert(availableRarities, rarityName)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

local autoFarmSelectedRarities = {}
for _, v in ipairs(availableRarities) do
    table.insert(autoFarmSelectedRarities, v)
end

local autoFarmBrainrotEnabled = false
local autoFarmMinMoney = 1

AutoBrainrotSection:Toggle({
    Title = "Auto Farm Brainrot",
    Value = false,
    Callback = function(Value)
        autoFarmBrainrotEnabled = Value
        if Value then
            task.spawn(function()
                while autoFarmBrainrotEnabled do
                    pcall(function()
                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if not hrp then return end

                        local bestTarget = nil
                        local highestMoney = -1
                        local targetPrompt = nil
                        
                        local zonesFolder = workspace:FindFirstChild("Zones")
                        if zonesFolder then
                            for _, zone in ipairs(zonesFolder:GetChildren()) do
                                for _, brainrot in ipairs(zone:GetChildren()) do
                                    local standPrimary = brainrot:FindFirstChild("StandPrimary")
                                    if standPrimary then
                                        local prompt = standPrimary:FindFirstChild("CollectPrompt")
                                        if prompt and prompt.Enabled then
                                            local billboard = brainrot:FindFirstChild("Billboard-Part")
                                                and brainrot["Billboard-Part"]:FindFirstChild("WildCharacterBillboard")
                                                and brainrot["Billboard-Part"].WildCharacterBillboard:FindFirstChild("MainFrame")
                                                and brainrot["Billboard-Part"].WildCharacterBillboard.MainFrame:FindFirstChild("Money")
                                                
                                            if billboard and (billboard:IsA("TextLabel") or (type(billboard) == "userdata" and type(billboard.Text) == "string")) then
                                                local textStr = billboard.Text
                                                textStr = string.gsub(textStr, "/s", "")
                                                textStr = string.gsub(textStr, "[%$%s]", "")
                                                local money = NumberConverter and NumberConverter.Parse(textStr) or tonumber(textStr)
                                                
                                                local passesRarity = false
                                                local rarityLabel = brainrot["Billboard-Part"].WildCharacterBillboard.MainFrame:FindFirstChild("Rarity")
                                                if rarityLabel and (rarityLabel:IsA("TextLabel") or (type(rarityLabel) == "userdata" and type(rarityLabel.Text) == "string")) then
                                                    local rText = rarityLabel.Text
                                                    if rText then
                                                        local rName = string.match(rText, "^%s*(%S+)")
                                                        if rName and type(autoFarmSelectedRarities) == "table" then
                                                            for _, sel in ipairs(autoFarmSelectedRarities) do
                                                                if sel == rName then
                                                                    passesRarity = true
                                                                    break
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                                
                                                if passesRarity and money and money >= autoFarmMinMoney and money > highestMoney then
                                                    highestMoney = money
                                                    bestTarget = standPrimary
                                                    targetPrompt = prompt
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        
                        if bestTarget and targetPrompt then
                            hrp.CFrame = bestTarget.CFrame
                            task.wait(0.2)
                            targetPrompt.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow
                            targetPrompt.RequiresLineOfSight = false
                            if fireproximityprompt then
                                fireproximityprompt(targetPrompt)
                            end
                            task.wait(0.5)
                            hrp.CFrame = CFrame.new(15, 13, 26)
                        end
                    end)
                    task.wait(0.2)
                end
            end)
        end
    end
})

AutoBrainrotSection:Dropdown({
    Title = "Target Rarities",
    Multi = true,
    Values = availableRarities,
    Value = autoFarmSelectedRarities,
    Callback = function(Value)
        autoFarmSelectedRarities = Value
    end
})

local autoFarmInput = AutoBrainrotSection:Input({
    Title = "Min Brainrot Money",
    Desc = "Targeting Multiplier (M, B, T, Qa, Qi, Sx...)",
    Placeholder = "e.g. 500k, 12M, 5T",
    Callback = function(text)
        if text == nil or text == "" then
            autoFarmMinMoney = 0
            pcall(function()
                if autoFarmInput and autoFarmInput.SetDesc then
                    autoFarmInput:SetDesc("Targeting Multiplier (M, B, T, Qa, Qi, Sx...)")
                end
            end)
            return
        end
        local parsed = (NumberConverter and NumberConverter.Parse(text)) or tonumber(text) or 0
        autoFarmMinMoney = parsed
        
        local formStr = (NumberConverter and NumberConverter.Format(parsed)) or tostring(parsed)
        local displayStr = "$" .. formStr
        pcall(function()
            if autoFarmInput and autoFarmInput.SetDesc then
                autoFarmInput:SetDesc("Targeting: " .. displayStr)
            end
        end)
        
        WindUI:Notify({
            Title = "Auto Farm Set",
            Content = displayStr .. " has been set as the minimum brainrot value.",
            Duration = 3
        })
    end
})

local autoCollectEnabled = false
local autoCollectDelay = 1

AutoBrainrotSection:Toggle({
    Title = "Auto Collect Cash",
    Value = false,
    Callback = function(Value)
        autoCollectEnabled = Value
        if Value then
            task.spawn(function()
                local isMobile = game:GetService("UserInputService").TouchEnabled and not game:GetService("UserInputService").MouseEnabled
                while autoCollectEnabled do
                    pcall(function()
                        local plot = getMyPlot()
                        if plot then
                            local spotsFolder = plot:FindFirstChild("Spots")
                            if spotsFolder then
                                for _, spot in ipairs(spotsFolder:GetChildren()) do
                                    local buttonHitbox = spot:FindFirstChild("Button") and spot.Button:FindFirstChild("ButtonHitbox")
                                    if buttonHitbox then
                                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                        if hrp and firetouchinterest then
                                            firetouchinterest(buttonHitbox, hrp, 0)
                                            if isMobile then
                                                task.wait(0.01)
                                                firetouchinterest(buttonHitbox, hrp, 1)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    local waited = 0
                    while waited < autoCollectDelay and autoCollectEnabled do
                        task.wait(0.1)
                        waited = waited + 0.1
                    end
                end
            end)
        end
    end
})

local autoCollectSlider
local autoCollectDebounce = 0

autoCollectSlider = AutoBrainrotSection:Slider({
    Title = "Collect Cash Delay",
    Desc = "Delay: 1s",
    Step = 1,
    Value = {
        Min = 1,
        Max = 60,
        Default = 1,
    },
    Callback = function(Value)
        autoCollectDelay = Value
        
        autoCollectDebounce = autoCollectDebounce + 1
        local currentId = autoCollectDebounce
        
        task.delay(0.02, function()
            if currentId == autoCollectDebounce then
                pcall(function()
                    if autoCollectSlider and autoCollectSlider.SetDesc then
                        autoCollectSlider:SetDesc("Delay: " .. tostring(Value) .. "s")
                    end
                end)
            end
        end)
    end
})

local autoUpgradeEnabled = false
AutoBrainrotSection:Toggle({
    Title = "Auto Upgrade Brainrot",
    Value = false,
    Callback = function(Value)
        autoUpgradeEnabled = Value
        if Value then
            task.spawn(function()
                while autoUpgradeEnabled do
                    pcall(function()
                        local plot = getMyPlot()
                        if plot then
                            local spotsFolder = plot:FindFirstChild("Spots")
                            if spotsFolder then
                                for _, spot in ipairs(spotsFolder:GetChildren()) do
                                    local upgradePart = spot:FindFirstChild("Platform") and spot.Platform:FindFirstChild("UpgradePart")
                                    if upgradePart then
                                        local priceLabel = upgradePart:FindFirstChild("UpgradeSurfaceGui") 
                                            and upgradePart.UpgradeSurfaceGui:FindFirstChild("UpgradeAnimalButton")
                                            and upgradePart.UpgradeSurfaceGui.UpgradeAnimalButton:FindFirstChild("Frame")
                                            and upgradePart.UpgradeSurfaceGui.UpgradeAnimalButton.Frame:FindFirstChild("FullFrame")
                                            and upgradePart.UpgradeSurfaceGui.UpgradeAnimalButton.Frame.FullFrame:FindFirstChild("UpgradeText")
                                            and upgradePart.UpgradeSurfaceGui.UpgradeAnimalButton.Frame.FullFrame.UpgradeText:FindFirstChild("Price")
                                            
                                        if priceLabel and (priceLabel:IsA("TextLabel") or (type(priceLabel) == "userdata" and type(priceLabel.Text) == "string")) then
                                            local priceText = string.gsub(priceLabel.Text, "[%$%s]", "")
                                            local price = NumberConverter and NumberConverter.Parse(priceText) or tonumber(priceText)
                                            if price and price > 0 then
                                                if getPlayerCash() >= price then
                                                    local spotNum = tonumber(spot.Name)
                                                    if spotNum then
                                                        -- Check exactly milli-seconds before firing to ensure no cash overlaps
                                                        if getPlayerCash() >= price then
                                                            local args = { spotNum }
                                                            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("upgradeCharacterEvent"):FireServer(unpack(args))
                                                            task.wait(0.05)
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.075)
                end
            end)
        end
    end
})

local autoBuyStrengthEnabled = false
Tabs.Main:Toggle({
    Title = "Auto Buy Strength",
    Value = false,
    Callback = function(Value)
        autoBuyStrengthEnabled = Value
        if Value then
            task.spawn(function()
                while autoBuyStrengthEnabled do
                    pcall(function()
                        local buttonsFolder = game:GetService("Players").LocalPlayer.PlayerGui.Menus.Upgrades.MainFrame.MainBar["1"].Buttons
                        local button2Obj = buttonsFolder.Button2:FindFirstChild("TextWhiite") or buttonsFolder.Button2:FindFirstChild("TextWhite")
                        local cost2Text = string.gsub(button2Obj.Text, "[%$%s]", "")
                        local cost2 = NumberConverter and NumberConverter.Parse(cost2Text) or tonumber(cost2Text)
                        
                        if cost2 and getPlayerCash() >= cost2 then
                            local args = { 10 }
                            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("buySoloEvent"):FireServer(unpack(args))
                        else
                            local button1Obj = buttonsFolder.Button1:FindFirstChild("TextWhiite") or buttonsFolder.Button1:FindFirstChild("TextWhite")
                            local cost1Text = string.gsub(button1Obj.Text, "[%$%s]", "")
                            local cost1 = NumberConverter and NumberConverter.Parse(cost1Text) or tonumber(cost1Text)
                            
                            if cost1 and getPlayerCash() >= cost1 then
                                local args = { 1 }
                                game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("buySoloEvent"):FireServer(unpack(args))
                            end
                        end
                    end)
                    task.wait(0.2)
                end
            end)
        end
    end
})

local autoRebirthEnabled = false
Tabs.Main:Toggle({
    Title = "Auto Rebirth",
    Value = false,
    Callback = function(Value)
        autoRebirthEnabled = Value
        if Value then
            task.spawn(function()
                while autoRebirthEnabled do
                    pcall(function()
                        local greenBar = game:GetService("Players").LocalPlayer.PlayerGui.Menus.Rebirth.MainFrame.MainBar.RequirementsProgressBar.GreenBar
                        if greenBar and greenBar.Size == UDim2.new(1, 0, 1, 0) then
                            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("doRebirthEvent"):FireServer()
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    end
})

Tabs.Main:Button({
    Title = "Buy x1 Strength",
    Callback = function()
        pcall(function()
            local args = { 1 }
            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("buySoloEvent"):FireServer(unpack(args))
        end)
    end
})

Tabs.Main:Button({
    Title = "Buy x10 Strength",
    Callback = function()
        pcall(function()
            local args = { 10 }
            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("buySoloEvent"):FireServer(unpack(args))
        end)
    end
})

Tabs.Main:Button({
    Title = "Remove Balls",
    Callback = function()
        pcall(function()
            local balls = workspace:FindFirstChild("Balls")
            if balls then
                balls:Destroy()
            end
        end)
    end
})

Tabs.Main:Button({
    Title = "Remove Barriers",
    Callback = function()
        pcall(function()
            for _, child in ipairs(workspace:GetChildren()) do
                if child.Name == "BallBarrier" then
                    child:Destroy()
                end
            end
        end)
    end
})

WindUI:Notify({
    Title = "Prime X Hub",
    Content = "Script loaded successfully!",
    Duration = 5
})
