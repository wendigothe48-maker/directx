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

WindUI:Notify({
    Title = "Prime X Hub",
    Content = "Script loaded successfully!",
    Duration = 5
})

-- ==========================================
--                  MAIN TAB
-- ==========================================

_G.AutoFarmBrainrot = false
_G.CurrentFarmCFrame = CFrame.new(-17, 4, -2025)
_G.MinBrainrotCash = 0

local function FormatNumber(value)
    if value >= 1e15 then
        return string.format("%.2fQa", value / 1e15)
    elseif value >= 1e12 then
        return string.format("%.2fT", value / 1e12)
    elseif value >= 1e9 then
        return string.format("%.2fB", value / 1e9)
    elseif value >= 1e6 then
        return string.format("%.2fM", value / 1e6)
    elseif value >= 1e3 then
        return string.format("%.2fK", value / 1e3)
    else
        return tostring(value)
    end
end



local AutoFarmSection = Tabs.Main:Section({
    Title = "Farm & Tap",
    Box = true,
    BoxBorder = true,
    Expandable = true,
    Opened = true
})

_G.AutoFarmBrainrot = false
AutoFarmSection:Toggle({
    Title = "Auto Farm",
    Value = false,
    Callback = function(Value)
        _G.AutoFarmBrainrot = Value
        if Value then
            _G.CurrentFarmCFrame = CFrame.new(-17, 4, -2025)

            
            -- Coordinate Ensure Loop
            task.spawn(function()
                while _G.AutoFarmBrainrot do
                    local LocalPlayer = game:GetService("Players").LocalPlayer
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and _G.CurrentFarmCFrame and not _G.PauseAutoFarmBrainrot then
                        if (hrp.Position - _G.CurrentFarmCFrame.Position).Magnitude > 5 then
                            hrp.CFrame = _G.CurrentFarmCFrame
                        end
                    end
                    task.wait(0.1)
                end
            end)
            
            -- 5 Minute Reset Loop
            task.spawn(function()
                local lastTpTime = 0
                while _G.AutoFarmBrainrot do
                    if (tick() - lastTpTime >= 300) then
                        _G.CurrentFarmCFrame = CFrame.new(-17, 4, -2025)
                        lastTpTime = tick()
                    end
                    task.wait(1)
                end
            end)
            
            -- Main Farm Logic
            task.spawn(function()
                task.wait(3)
                
                while _G.AutoFarmBrainrot do
                    pcall(function()
                        local spawnedFolder = workspace:FindFirstChild("SpawnedBrainrots")
                        if spawnedFolder then
                            local bestBrainrot = nil
                            local highestMoney = -1
                            
                            for i, brainrot in ipairs(spawnedFolder:GetChildren()) do
                                if not _G.AutoFarmBrainrot or _G.PauseAutoFarmBrainrot then break end
                                
                                local overhead = brainrot:FindFirstChild("Overhead")
                                local attachment = overhead and overhead:FindFirstChild("Attachment")
                                local unitsBillboard = attachment and attachment:FindFirstChild("UnitsBillboard")
                                local perSecondAmount = unitsBillboard and unitsBillboard:FindFirstChild("PerSecondAmount")
                                
                                if perSecondAmount then
                                    local priceStr = string.gsub(perSecondAmount.Text, "%$", "")
                                    priceStr = string.gsub(priceStr, "/s", "")
                                    priceStr = string.gsub(priceStr, "%s+", "")
                                    
                                    local price = 0
                                    if NumberConverter and NumberConverter.Parse then
                                        price = NumberConverter.Parse(priceStr)
                                    else
                                        price = tonumber(string.match(priceStr, "[%d%.]+")) or 0
                                    end
                                    
                                    if price >= _G.MinBrainrotCash and price > highestMoney then
                                        highestMoney = price
                                        bestBrainrot = brainrot
                                    end
                                end
                                if i % 10 == 0 then
                                    task.wait()
                                end
                            end
                            
                            if bestBrainrot and _G.AutoFarmBrainrot and not _G.PauseAutoFarmBrainrot then
                                local pickupHitbox = bestBrainrot:FindFirstChild("PickupHitbox")
                                local prompt = pickupHitbox and pickupHitbox:FindFirstChildOfClass("ProximityPrompt")
                                
                                if pickupHitbox and prompt then
                                    _G.CurrentFarmCFrame = pickupHitbox.CFrame + Vector3.new(0, 3, 0)
                                    task.wait(0.5)
                                    fireproximityprompt(prompt)
                                    
                                    local startTime = tick()
                                    while bestBrainrot.Parent == spawnedFolder and tick() - startTime < 5 do
                                        task.wait(0.1)
                                    end
                                    
                                    local collectionPart = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("BrainrotCollectionPart")
                                    if collectionPart then
                                        local lp = game:GetService("Players").LocalPlayer
                                        local rp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                                        if rp then
                                            fireTouch(rp, collectionPart)
                                        end
                                    end
                                    _G.CurrentFarmCFrame = CFrame.new(-17, 4, -2025)
                                    task.wait(0.5)
                                end
                            end
                        end
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end
})

AutoFarmSection:Input({
    Title = "Minimum Cash Brainrot",
    PlaceholderText = "e.g., 2M, 5T",
    Callback = function(Text)
        local rawText = string.gsub(Text, "%$", "")
        rawText = string.gsub(rawText, ",", "")
        rawText = string.gsub(rawText, "%s+", "")
        
        local parsedValue = 0
        if NumberConverter and NumberConverter.Parse then
            parsedValue = NumberConverter.Parse(rawText)
        else
            parsedValue = tonumber(string.match(rawText, "[%d%.]+")) or 0
        end
        
        _G.MinBrainrotCash = parsedValue
        
        local formatted = FormatNumber(parsedValue)
        WindUI:Notify({
            Title = "Minimum Brainrot Set",
            Content = "Set to: $" .. formatted,
            Duration = 5
        })
    end
})

_G.AutoTapHealth = false
Tabs.Main:Toggle({
    Title = "Auto Tap Health",
    Value = false,
    Callback = function(Value)
        _G.AutoTapHealth = Value
        if Value then
            for i = 1, 2 do
                task.spawn(function()
                    while _G.AutoTapHealth do
                        pcall(function()
                            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("TapHealth"):FireServer()
                        end)
                        task.wait(0.05)
                    end
                end)
            end
        end
    end
})

local function GetBrainrotCount()
    local lp = game:GetService("Players").LocalPlayer
    local count = 0
    if lp:FindFirstChild("Backpack") then
        count = count + #lp.Backpack:GetChildren()
    end
    if lp.Character then
        for _, v in ipairs(lp.Character:GetChildren()) do
            if v:IsA("Tool") then
                count = count + 1
            end
        end
    end
    return count
end

Tabs.Main:Toggle({
    Title = "Auto Best Place Brainrot",
    Value = false,
    Callback = function(Value)
        _G.AutoBestPlaceBrainrot = Value
        if Value then
            task.spawn(function()
                pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PlaceBest"):FireServer()
                end)
                
                local prevCount = GetBrainrotCount()
                local pending = false
                local lastFireTime = tick()
                local changeDetectTime = 0
                
                while _G.AutoBestPlaceBrainrot do
                    pcall(function()
                        local currentCount = GetBrainrotCount()
                        
                        if currentCount > prevCount then
                            if not pending then
                                pending = true
                                changeDetectTime = tick()
                            end
                        end
                        prevCount = currentCount
                        
                        if pending then
                            local timeSinceLastFire = tick() - lastFireTime
                            local timeSinceChange = tick() - changeDetectTime
                            local shouldFire = false
                            
                            if timeSinceLastFire >= 12 then
                                if timeSinceChange >= 3 then
                                    shouldFire = true
                                end
                            end
                            
                            if shouldFire then
                                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PlaceBest"):FireServer()
                                lastFireTime = tick()
                                pending = false
                                task.wait(0.5)
                                prevCount = GetBrainrotCount()
                            end
                        end
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end
})


local function GetSelfPlot()
    local LocalPlayer = game:GetService("Players").LocalPlayer
    local plotsFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("SpawnArea") and workspace.Map.SpawnArea:FindFirstChild("Plots")
    if plotsFolder then
        for _, plot in ipairs(plotsFolder:GetChildren()) do
            local ownerSign = plot:FindFirstChild("OwnerSign")
            if ownerSign then
                for _, ground in ipairs(ownerSign:GetChildren()) do
                    if ground.Name == "Ground" then
                        local surfaceGui = ground:FindFirstChild("SurfaceGui")
                        local textLabel = surfaceGui and surfaceGui:FindFirstChild("TextLabel")
                        if textLabel and textLabel.Text then
                            local text = string.gsub(textLabel.Text, "Plot", "")
                            text = string.gsub(text, "\n", "")
                            text = string.gsub(text, "%s+", "")
                            local displayName = string.gsub(LocalPlayer.DisplayName, "%s+", "")
                            local name = string.gsub(LocalPlayer.Name, "%s+", "")
                            
                            if string.lower(text) == string.lower(displayName) or string.lower(text) == string.lower(name) then
                                return plot
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
    task.wait(2)
    local plot = GetSelfPlot()
    if plot then
        print("Self Plot Detected: " .. plot.Name)
        WindUI:Notify({
            Title = "Plot Detected",
            Content = "Your plot is: " .. plot.Name,
            Duration = 5
        })
    else
        print("Self Plot Not Detected")
        WindUI:Notify({
            Title = "Plot Detection Failed",
            Content = "Could not find your plot.",
            Duration = 5
        })
    end
end)

_G.AutoCollectCash = false
Tabs.Main:Toggle({
    Title = "Auto Collect Cash",
    Value = false,
    Callback = function(Value)
        _G.AutoCollectCash = Value
        if Value then
            task.spawn(function()
                while _G.AutoCollectCash do
                    pcall(function()
                        local selfPlot = GetSelfPlot()
                        if selfPlot then
                            local floorsFolder = selfPlot:FindFirstChild("Floors")
                            if floorsFolder then
                                local hrp = game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    local originalCFrame = hrp.CFrame
                                    _G.PauseAutoFarmBrainrot = true
                                    for _, floor in ipairs(floorsFolder:GetChildren()) do
                                        local funcFolder = floor:FindFirstChild("Functionals")
                                        local basePlacements = funcFolder and funcFolder:FindFirstChild("BasePlacmentPlots")
                                        if basePlacements then
                                            for _, basePlace in ipairs(basePlacements:GetChildren()) do
                                                local collectCash = basePlace:FindFirstChild("CollectCash")
                                                local cashPart = collectCash and collectCash:FindFirstChild("CashCollectPart")
                                                if cashPart then
                                                    local attachment = cashPart:FindFirstChild("Attachment")
                                                    local unitsBillboard = attachment and attachment:FindFirstChild("UnitsBillboard")
                                                    
                                                    if unitsBillboard and unitsBillboard.Enabled then
                                                        hrp.CFrame = cashPart.CFrame
                                                        task.wait(0.5)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    hrp.CFrame = originalCFrame
                                    _G.PauseAutoFarmBrainrot = false
                                end
                            end
                        end
                    end)
                    task.wait(45)
                end
            end)
        end
    end
})

_G.AutoUpgradeBrainrot = false
Tabs.Main:Toggle({
    Title = "Auto Upgrade Brainrot",
    Value = false,
    Callback = function(Value)
        if type(executorName) == "string" and string.find(string.lower(executorName), "xeno") then
            WindUI:Notify({
                Title = "Not Supported",
                Content = "Xeno Executor Not Supported",
                Duration = 5
            })
            _G.AutoUpgradeBrainrot = false
            return
        end
        
        _G.AutoUpgradeBrainrot = Value
        if Value then
            task.spawn(function()
                while _G.AutoUpgradeBrainrot do
                    pcall(function()
                        local selfPlot = GetSelfPlot()
                        local LocalPlayer = game:GetService("Players").LocalPlayer
                        local cashStat = LocalPlayer.leaderstats and LocalPlayer.leaderstats:FindFirstChild("Cash")
                        if selfPlot and cashStat then
                            local myCash = tonumber(cashStat.Value) or 0
                            local floorsFolder = selfPlot:FindFirstChild("Floors")
                            if floorsFolder then
                                for _, floor in ipairs(floorsFolder:GetChildren()) do
                                    local funcFolder = floor:FindFirstChild("Functionals")
                                    local basePlacements = funcFolder and funcFolder:FindFirstChild("BasePlacmentPlots")
                                    if basePlacements then
                                        for _, basePlace in ipairs(basePlacements:GetChildren()) do
                                            local upgradeBtnPart = basePlace:FindFirstChild("UpgradeButton")
                                            local surfaceGui = upgradeBtnPart and upgradeBtnPart:FindFirstChild("SurfaceGui")
                                            local upgradeBtnUI = surfaceGui and surfaceGui:FindFirstChild("UpgradeButton")
                                            local cashAmount = upgradeBtnUI and upgradeBtnUI:FindFirstChild("CashAmount")
                                            local clickDetector = upgradeBtnPart and upgradeBtnPart:FindFirstChild("UpgradeClickDetector")
                                            
                                            if cashAmount and clickDetector then
                                                local priceStr = string.gsub(cashAmount.Text, "%$", "")
                                                priceStr = string.gsub(priceStr, "%s+", "")
                                                local price = math.huge
                                                if NumberConverter and NumberConverter.Parse then
                                                    price = NumberConverter.Parse(priceStr)
                                                else
                                                    price = tonumber(string.match(priceStr, "[%d%.]+")) or math.huge
                                                end
                                                
                                                if myCash >= price then
                                                    fireclickdetector(clickDetector)
                                                    task.wait(0.1)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    end
})

_G.AutoUpgradeSteps = false
Tabs.Main:Toggle({
    Title = "Auto Upgrade Health",
    Value = false,
    Callback = function(Value)
        _G.AutoUpgradeSteps = Value
        if Value then
            task.spawn(function()
                local lastBuyTime = tick()
                local currentDelay = 0.2
                while _G.AutoUpgradeSteps do
                    pcall(function()
                        local boughtAny = false
                        local LocalPlayer = game:GetService("Players").LocalPlayer
                        local cashStat = LocalPlayer.leaderstats and LocalPlayer.leaderstats:FindFirstChild("Cash")
                        local playerCash = cashStat and tonumber(cashStat.Value) or 0
                        local scrollingFrame = LocalPlayer.PlayerGui.App.Container.Frames.UpgradesImage.ScrollingFrame
                        
                        local steps = {"Step500", "Step75", "Step5"}
                        for _, stepName in ipairs(steps) do
                            local stepUI = scrollingFrame:FindFirstChild(stepName)
                            if stepUI then
                                local btn = stepUI:FindFirstChild("ClaimButton1")
                                if btn then
                                    local priceLabel = btn:FindFirstChild("PriceLabel")
                                    if priceLabel then
                                        local text = string.gsub(priceLabel.Text, "^%s*(.-)%s*$", "%1")
                                        if string.lower(text) ~= "max" and string.lower(text) ~= "maxed" then
                                            local priceStr = string.gsub(text, "[%$%s]", "")
                                            local price = math.huge
                                            if NumberConverter and NumberConverter.Parse then
                                                price = NumberConverter.Parse(priceStr)
                                            else
                                                price = tonumber(string.match(priceStr, "[%d%.]+")) or math.huge
                                            end
                                            
                                            if playerCash >= price then
                                                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("BuySpeedStepUpgrade"):FireServer(stepName)
                                                boughtAny = true
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        
                        if boughtAny then
                            lastBuyTime = tick()
                            currentDelay = 0.2
                        else
                            if tick() - lastBuyTime >= 2 then
                                currentDelay = 2
                            end
                        end
                    end)
                    task.wait(currentDelay)
                end
            end)
        end
    end
})

_G.AutoBuyTrailToggle = false
Tabs.Main:Toggle({
    Title = "Auto Buy Trail",
    Value = false,
    Callback = function(Value)
        _G.AutoBuyTrailToggle = Value
        if Value then
            task.spawn(function()
                while _G.AutoBuyTrailToggle do
                    pcall(function()
                        local LocalPlayer = game:GetService("Players").LocalPlayer
                        local scrollingFrame = LocalPlayer.PlayerGui.App.Container.Frames.TrailImage.ScrollingFrame
                        
                        local bestTrailName = nil
                        local highestSpeed = -1
                        local targetAction = nil
                        
                        local cashStat = LocalPlayer.leaderstats and LocalPlayer.leaderstats:FindFirstChild("Cash")
                        local playerCash = cashStat and tonumber(cashStat.Value) or 0
                        
                        for _, trailUI in ipairs(scrollingFrame:GetChildren()) do
                            if string.match(trailUI.Name, "Trail%d+") then
                                local claimButton = trailUI:FindFirstChild("ClaimButton1")
                                if claimButton and claimButton.Visible then
                                    local speedLabel = trailUI:FindFirstChild("Speed")
                                    if speedLabel then
                                        local speedStr = string.gsub(speedLabel.Text, "x", "")
                                        speedStr = string.gsub(speedStr, "Health", "")
                                        speedStr = string.gsub(speedStr, "%s+", "")
                                        local speedVal = tonumber(speedStr) or 0
                                        
                                        local priceLabel = claimButton:FindFirstChild("PriceLabel")
                                        if priceLabel then
                                            local labelText = priceLabel.Text
                                            if labelText == "On" then
                                                -- Equipped
                                                if speedVal >= highestSpeed then
                                                    highestSpeed = speedVal
                                                    bestTrailName = nil
                                                end
                                            elseif labelText == "Off" then
                                                -- Unequipped (Owned)
                                                if speedVal > highestSpeed then
                                                    highestSpeed = speedVal
                                                    bestTrailName = trailUI.Name
                                                    targetAction = "Equip"
                                                end
                                            else
                                                -- Price (Unowned)
                                                local priceStr = string.gsub(labelText, "%$", "")
                                                priceStr = string.gsub(priceStr, "%s+", "")
                                                
                                                local price = math.huge
                                                if NumberConverter and NumberConverter.Parse then
                                                    price = NumberConverter.Parse(priceStr)
                                                else
                                                    price = tonumber(string.match(priceStr, "[%d%.]+")) or math.huge
                                                end
                                                
                                                if playerCash >= price and speedVal > highestSpeed then
                                                    highestSpeed = speedVal
                                                    bestTrailName = trailUI.Name
                                                    targetAction = "Purchase"
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        
                        if bestTrailName and targetAction then
                            if targetAction == "Purchase" then
                                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("BuyTrail"):FireServer(bestTrailName, "cash")
                            elseif targetAction == "Equip" then
                                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("BuyTrail"):FireServer(bestTrailName, "Equip")
                            end
                        end
                    end)
                    task.wait(2.5)
                end
            end)
        end
    end
})

_G.AutoRebirthBrainrot = false
Tabs.Main:Toggle({
    Title = "Auto Rebirth",
    Value = false,
    Callback = function(Value)
        _G.AutoRebirthBrainrot = Value
        if Value then
            task.spawn(function()
                while _G.AutoRebirthBrainrot do
                    pcall(function()
                        local LocalPlayer = game:GetService("Players").LocalPlayer
                        local progressReward = LocalPlayer.PlayerGui.App.Container.Frames.Rebirth.RewardBackground.ProgressReward
                        if progressReward then
                            local scaleX = math.floor(progressReward.Size.X.Scale * 1000 + 0.5) / 1000
                            local scaleY = math.floor(progressReward.Size.Y.Scale * 1000 + 0.5) / 1000
                            
                            if scaleX >= 1 and scaleY >= 1 then
                                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestRebirth"):FireServer()
                            end
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    end
})

