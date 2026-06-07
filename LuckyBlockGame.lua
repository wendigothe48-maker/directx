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
        return tonumber(cashObj.Value) or 0
    end
    return 0
end

local function getMyPlot()
    local myName = LocalPlayer.DisplayName .. "'s"
    local bases = workspace:FindFirstChild("Bases")
    if not bases then return nil end
    for _, base in ipairs(bases:GetChildren()) do
        local displayGui = base:FindFirstChild("Sign") and base.Sign:FindFirstChild("Display") 
            and base.Sign.Display:FindFirstChild("BaseDisplayGui")
        local playerNameLabel = displayGui and displayGui:FindFirstChild("Frame") 
            and displayGui.Frame:FindFirstChild("Info") 
            and displayGui.Frame.Info:FindFirstChild("PlayerName")
            
        if playerNameLabel and string.find(playerNameLabel.Text, myName, 1, true) then
            return base
        end
    end
    return nil
end

local BrainrotsSection = Tabs.Main:Section({
    Title = "Brainrots",
    Box = true,
    BoxBorder = true,
    Opened = true,
})

local autoFarmBrainrot = false
BrainrotsSection:Toggle({
    Title = "Auto Farm Brainrot",
    Value = false,
    Callback = function(Value)
        autoFarmBrainrot = Value
        if Value then
            task.spawn(function()
                local lastGreenFoundAt = tick()
                while autoFarmBrainrot do
                    pcall(function()
                        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                        local startLabel = playerGui and playerGui:FindFirstChild("MainGui")
                            and playerGui.MainGui:FindFirstChild("UITop")
                            and playerGui.MainGui.UITop:FindFirstChild("Frame")
                            and playerGui.MainGui.UITop.Frame:FindFirstChild("Start")
                            and playerGui.MainGui.UITop.Frame.Start:FindFirstChild("TextLabel")
                            
                        if startLabel then
                            if string.find(string.lower(startLabel.Text), "start run") then
                                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    hrp.CFrame = CFrame.new(-128, 10.8178816, -91)
                                end
                                lastGreenFoundAt = tick()
                                task.wait(2)
                            else
                                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                local spawnedDoors = workspace:FindFirstChild("SpawnedDoors")
                                local greenFoundThisTick = false
                                if spawnedDoors then
                                    for _, child in ipairs(spawnedDoors:GetChildren()) do
                                        if child.Name == "Green" then
                                            local doorPart = child:FindFirstChild("Door")
                                            local touchInt = doorPart and doorPart:FindFirstChild("TouchInterest")
                                            if doorPart and hrp and touchInt then
                                                greenFoundThisTick = true
                                                firetouchinterest(doorPart, hrp, 0)
                                                if isMobile then
                                                    task.wait(0.01)
                                                    firetouchinterest(doorPart, hrp, 1)
                                                end
                                                task.delay(0.5, function()
                                                    if child and child.Parent then
                                                        child:Destroy()
                                                    end
                                                end)
                                            end
                                        elseif child.Name == "Red" then
                                            child:Destroy()
                                        end
                                    end
                                end
                                
                                if greenFoundThisTick then
                                    lastGreenFoundAt = tick()
                                end
                                
                                if tick() - lastGreenFoundAt > 1.0 then
                                    local args = { 999999999999999 }
                                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DamageEvent"):FireServer(unpack(args))
                                end
                                
                                task.wait(0.1)
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

local autoUpgradeBrainrot = false
BrainrotsSection:Toggle({
    Title = "Auto Upgrade Brainrot",
    Value = false,
    Callback = function(Value)
        autoUpgradeBrainrot = Value
        if Value then
            task.spawn(function()
                while autoUpgradeBrainrot do
                    pcall(function()
                        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                        if not playerGui then return end
                        
                        for _, child in ipairs(playerGui:GetChildren()) do
                            if child.Name == "UpgradeBrainrotGui" then
                                local costLabel = child:FindFirstChild("Upgrade") and child.Upgrade:FindFirstChild("Frame") and child.Upgrade.Frame:FindFirstChild("Cost")
                                if costLabel and costLabel:IsA("TextLabel") then
                                    local costText = string.gsub(costLabel.Text, "[%$%s]", "")
                                    local cost = NumberConverter and NumberConverter.Parse(costText) or tonumber(costText)
                                    
                                    if cost and getPlayerCash() >= cost then
                                        local adornee = child.Adornee
                                        if adornee and adornee.Parent then
                                            local platformNum = tonumber(adornee.Parent.Name)
                                            if platformNum then
                                                local args = { platformNum }
                                                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UpgradeBrainrotEvent"):FireServer(unpack(args))
                                                task.wait(0.2)
                                            end
                                        end
                                    end
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

local AutoBestBuySection = Tabs.Main:Section({
    Title = "Auto Best Buy Shop",
    Box = true,
    BoxBorder = true,
    Opened = true,
})

local autoBestBuyDumble = false
AutoBestBuySection:Toggle({
    Title = "Auto Best Buy Dumble",
    Value = false,
    Callback = function(Value)
        autoBestBuyDumble = Value
        if Value then
            task.spawn(function()
                while autoBestBuyDumble do
                    pcall(function()
                        
                        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                        if not playerGui then return end
                        
                        local mainGui = playerGui:FindFirstChild("MainGui")
                        if not mainGui then return end
                        
                        local shovelsFrame = mainGui:FindFirstChild("ShovelsFrame")
                        if not shovelsFrame then return end
                        
                        local frame2 = shovelsFrame:FindFirstChild("Frame2")
                        if not frame2 then return end

                            
                        if frame2 then
                            local items = {}
                            local myCash = getPlayerCash()
                            
                            
                            local children = frame2:GetChildren()
                            
                            
                            for _, child in ipairs(children) do
                                task.wait()
                                
                                if child:IsA("ImageLabel") and child:FindFirstChild("Power") and child:FindFirstChild("Buy") and child.Buy:FindFirstChild("Cost") then
                                    local powerText = child.Power.Text
                                    local powerNumText = string.match(powerText, "[%d%.]+[KkMmBbTt]*") or "0"
                                    local power = NumberConverter and NumberConverter.Parse(powerNumText) or tonumber(string.match(powerText, "[%d%.]+")) or 0
                                    
                                    local costText = child.Buy.Cost.Text
                                    local isEquipped = string.lower(costText) == "equipped"
                                    local isOwned = isEquipped or string.lower(costText) == "equip"
                                    local cost = 0
                                    
                                    if not isOwned then
                                        local costNumText = string.gsub(costText, "[%$%s]", "")
                                        cost = NumberConverter and NumberConverter.Parse(costNumText) or tonumber(string.match(costNumText, "[%d%.]+")) or 0
                                    end
                                    
                                    if isOwned or cost <= myCash then
                                        
                                        table.insert(items, {
                                            Name = child.Name,
                                            Power = power,
                                            IsEquipped = isEquipped,
                                            IsOwned = isOwned,
                                            Cost = cost
                                        })
                                    else
                                         -- ignored
                                    end
                                end
                            end
                            
                            table.sort(items, function(a, b) return a.Power > b.Power end)
                            
                            local bestItem = items[1]
                            
                            
                            if bestItem then
                                
                                if not bestItem.IsOwned then
                                    local args = { bestItem.Name }
                                    
                                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("BuyShovelEvent"):FireServer(unpack(args))
                                    task.wait(0.2)
                                    
                                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("EquipShovelEvent"):FireServer(unpack(args))
                                elseif not bestItem.IsEquipped then
                                    local args = { bestItem.Name }
                                    
                                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("EquipShovelEvent"):FireServer(unpack(args))
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

local autoBuyLuckyBlock = false
AutoBestBuySection:Toggle({
    Title = "Auto Buy Lucky Block",
    Value = false,
    Callback = function(Value)
        autoBuyLuckyBlock = Value
        if Value then
            task.spawn(function()
                while autoBuyLuckyBlock do
                    pcall(function()
                        
                        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                        if not playerGui then return end
                        
                        local mainGui = playerGui:FindFirstChild("MainGui")
                        if not mainGui then return end
                        
                        local blocksFrame = mainGui:FindFirstChild("BlocksFrame")
                        if not blocksFrame then return end
                        
                        local frame2 = blocksFrame:FindFirstChild("Frame2")
                        if not frame2 then return end

                            
                        if frame2 then
                            local items = {}
                            local myCash = getPlayerCash()
                            
                            
                            local children = frame2:GetChildren()
                            
                            
                            for _, child in ipairs(children) do
                                task.wait()
                                
                                if child:IsA("ImageLabel") and child:FindFirstChild("Luck") and child:FindFirstChild("Buy") and child.Buy:FindFirstChild("Cost") then
                                    local luckText = child.Luck.Text
                                    local luckNumText = string.match(luckText, "[%d%.]+") or "0"
                                    local luck = tonumber(luckNumText) or 0
                                    
                                    local costText = child.Buy.Cost.Text
                                    local isEquipped = string.lower(costText) == "equipped"
                                    local isOwned = isEquipped or string.lower(costText) == "equip"
                                    local cost = 0
                                    
                                    if not isOwned then
                                        local costNumText = string.gsub(costText, "[%$%s]", "")
                                        cost = NumberConverter and NumberConverter.Parse(costNumText) or tonumber(string.match(costNumText, "[%d%.]+")) or 0
                                    end
                                    
                                    if isOwned or cost <= myCash then
                                        
                                        table.insert(items, {
                                            Name = child.Name,
                                            Luck = luck,
                                            IsEquipped = isEquipped,
                                            IsOwned = isOwned,
                                            Cost = cost
                                        })
                                    else
                                         -- ignored
                                    end
                                end
                            end
                            
                            table.sort(items, function(a, b) return a.Luck > b.Luck end)
                            
                            local bestItem = items[1]
                            
                            
                            if bestItem then
                                
                                if not bestItem.IsOwned then
                                    local args = { bestItem.Name }
                                    
                                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("BuyBlockEvent"):FireServer(unpack(args))
                                    task.wait(0.2)
                                    
                                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("EquipBlockEvent"):FireServer(unpack(args))
                                elseif not bestItem.IsEquipped then
                                    local args = { bestItem.Name }
                                    
                                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("EquipBlockEvent"):FireServer(unpack(args))
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

local autoDumble = false
AutoBestBuySection:Toggle({
    Title = "Auto Dumble",
    Value = false,
    Callback = function(Value)
        autoDumble = Value
        if Value then
            task.spawn(function()
                while autoDumble do
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("EnergyEvent"):FireServer(true, 16)
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("EnergyEvent"):FireServer()
                    end)
                    task.wait(0.6)
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
                        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                        local progressBar = playerGui and playerGui:FindFirstChild("MainGui") 
                            and playerGui.MainGui:FindFirstChild("RebirthFrame") 
                            and playerGui.MainGui.RebirthFrame:FindFirstChild("Progress") 
                            and playerGui.MainGui.RebirthFrame.Progress:FindFirstChild("Bar")
                        
                        if progressBar and progressBar.Size.X.Scale >= 1 then
                            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RebirthEvent"):FireServer()
                            task.wait(2)
                        end
                    end)
                    task.wait(2.5)
                end
            end)
        end
    end
})

local isMobile = game:GetService("UserInputService").TouchEnabled
local autoCollectDelay = 1
local autoCollectEnabled = false

local originalCollectCFrames = {}
task.spawn(function()
    while task.wait() do
        pcall(function()
            local plot = getMyPlot()
            if plot then
                for _, floor in ipairs(plot:GetChildren()) do
                    if string.match(floor.Name, "^Floor") then
                        local platforms = floor:FindFirstChild("Platforms")
                        if platforms then
                            for _, pf in ipairs(platforms:GetChildren()) do
                                local collectPart = pf:FindFirstChild("Collect")
                                local platformFolder = pf:FindFirstChild("Platform")
                                if collectPart and collectPart:IsA("BasePart") then
                                    if not originalCollectCFrames[collectPart] then
                                        originalCollectCFrames[collectPart] = collectPart.CFrame
                                    else
                                        local diff = (collectPart.CFrame.Position - originalCollectCFrames[collectPart].Position).Magnitude
                                        if diff > 0.1 then
                                            collectPart.CFrame = originalCollectCFrames[collectPart]
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

BrainrotsSection:Toggle({
    Title = "Auto Collect Cash",
    Value = false,
    Callback = function(Value)
        autoCollectEnabled = Value
        if Value then
            task.spawn(function()
                while autoCollectEnabled do
                    pcall(function()
                        local plot = getMyPlot()
                        if plot then
                            for _, floor in ipairs(plot:GetChildren()) do
                                if string.match(floor.Name, "^Floor") then
                                    local platforms = floor:FindFirstChild("Platforms")
                                    if platforms then
                                        for _, pf in ipairs(platforms:GetChildren()) do
                                            local platformFolder = pf:FindFirstChild("Platform")
                                            local collectPart = pf:FindFirstChild("Collect")
                                            
                                            if platformFolder and #platformFolder:GetChildren() > 0 and collectPart then
                                                if collectPart:IsA("BasePart") then
                                                    collectPart.CanCollide = false
                                                end
                                                local touchInt = collectPart:FindFirstChild("TouchInterest")
                                                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                                
                                                if hrp and touchInt and firetouchinterest then
                                                    firetouchinterest(collectPart, hrp, 0)
                                                    if isMobile then
                                                        task.wait(0.01)
                                                        firetouchinterest(collectPart, hrp, 1)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(autoCollectDelay)
                end
            end)
        end
    end
})

BrainrotsSection:Slider({
    Title = "Auto Collect Delay",
    Step = 1,
    Value = {
        Min = 1,
        Max = 30,
        Default = 1,
    },
    Callback = function(Value)
        autoCollectDelay = Value
    end
})

local autoRemoveTsunami = false
Tabs.Main:Toggle({
    Title = "Remove Tsunami",
    Value = false,
    Callback = function(Value)
        autoRemoveTsunami = Value
        if Value then
            task.spawn(function()
                while autoRemoveTsunami do
                    pcall(function()
                        local activeTsunami = workspace:FindFirstChild("ActiveTsunami")
                        if activeTsunami then
                            activeTsunami:Destroy()
                        end
                    end)
                    task.wait(0.1)
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
