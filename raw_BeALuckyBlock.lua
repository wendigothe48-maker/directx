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
        WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
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
    Farming = Window:Tab({ Title = "Farming", Icon = "solar:leaf-bold" }),
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
--              FARMING LOGIC
-- ══════════════════════════════════════════
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function getPlayerCash()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats and leaderstats:FindFirstChild("Cash") then
        return leaderstats.Cash.Value
    end
    return 0
end

local function getPlayerPlot()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    
    for _, plotFolder in ipairs(plots:GetChildren()) do
        local subPlot = plotFolder:FindFirstChild(plotFolder.Name)
        if subPlot then
            for _, obj in ipairs(subPlot:GetChildren()) do
                if obj:IsA("BillboardGui") and string.match(obj.Name, "_FloatingPlotSign$") then
                    local username = string.gsub(obj.Name, "_FloatingPlotSign$", "")
                    if username == LocalPlayer.Name then
                        return subPlot
                    end
                end
            end
        end
    end
    return nil
end

local function getHighestBase()
    local bossSpawns = workspace:FindFirstChild("BossSpawns")
    if not bossSpawns then return nil, nil end
    
    local highestNum = -1
    local highestBase = nil
    
    for _, base in ipairs(bossSpawns:GetChildren()) do
        if string.match(base.Name, "^base(%d+)$") then
            local num = tonumber(string.match(base.Name, "^base(%d+)$"))
            if num and num > highestNum then
                highestNum = num
                highestBase = base
            end
        end
    end
    
    return highestBase, highestNum
end

local function removeObstacles()
    local highestBase, highestNum = getHighestBase()
    local bossSpawns = workspace:FindFirstChild("BossSpawns")
    
    if bossSpawns and highestBase then
        for _, base in ipairs(bossSpawns:GetChildren()) do
            if string.match(base.Name, "^base%d+$") and base ~= highestBase then
                base:Destroy()
            end
        end
    end
    
    local bossTouchDetectors = workspace:FindFirstChild("BossTouchDetectors")
    if bossTouchDetectors then
        bossTouchDetectors:Destroy()
    end
end

Tabs.Farming:Button({
    Title = "Remove Obstacles",
    Callback = function()
        removeObstacles()
    end
})

local autoFarmEnabled = false
Tabs.Farming:Toggle({
    Title = "Auto Farm",
    Value = false,
    Callback = function(Value)
        autoFarmEnabled = Value
        if Value then
            task.spawn(function()
                removeObstacles()
                while autoFarmEnabled do
                    local highestBase, highestNum = getHighestBase()
                    if highestBase then
                        local args = {
                            highestBase.Name
                        }
                        pcall(function()
                            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("RunningService"):WaitForChild("RF"):WaitForChild("OpenLuckyBlock"):InvokeServer(unpack(args))
                        end)
                    end
                    
                    task.wait(5)
                    
                    if not autoFarmEnabled then break end
                    
                    local plot = getPlayerPlot()
                    if plot then
                        local tpPart = plot:IsA("Model") and plot.PrimaryPart or plot:FindFirstChildWhichIsA("BasePart", true)
                        if tpPart and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = tpPart.CFrame + Vector3.new(0, 5, 0)
                        end
                    end
                    
                    task.wait(1)
                end
            end)
        end
    end
})

Tabs.Farming:Button({
    Title = "Collect Cash",
    Callback = function()
        local plot = getPlayerPlot()
        if plot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local containers = plot:FindFirstChild("Containers")
            if containers then
                for _, container in ipairs(containers:GetChildren()) do
                    local innerModel = container:FindFirstChild("InnerModel")
                    if innerModel and #innerModel:GetChildren() > 0 then
                        local collection = container:FindFirstChild("Collection")
                        if collection then
                            local collectionPad = collection:FindFirstChild("CollectionPad")
                            if collectionPad and firetouchinterest then
                                firetouchinterest(collectionPad, LocalPlayer.Character.HumanoidRootPart, 0)
                            end
                        end
                    end
                end
            end
        end
    end
})

local autoCollectEnabled = false
Tabs.Farming:Toggle({
    Title = "Auto Collect Cash",
    Value = false,
    Callback = function(Value)
        autoCollectEnabled = Value
        if Value then
            task.spawn(function()
                while autoCollectEnabled do
                    local plot = getPlayerPlot()
                    if plot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local containers = plot:FindFirstChild("Containers")
                        if containers then
                            for _, container in ipairs(containers:GetChildren()) do
                                local innerModel = container:FindFirstChild("InnerModel")
                                if innerModel and #innerModel:GetChildren() > 0 then
                                    local collection = container:FindFirstChild("Collection")
                                    if collection then
                                        local collectionPad = collection:FindFirstChild("CollectionPad")
                                        if collectionPad and firetouchinterest then
                                            firetouchinterest(collectionPad, LocalPlayer.Character.HumanoidRootPart, 0)
                                        end
                                    end
                                end
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

local autoUpgradeEnabled = false
Tabs.Farming:Toggle({
    Title = "Auto Upgrade Brainrot",
    Value = false,
    Callback = function(Value)
        autoUpgradeEnabled = Value
        if Value then
            task.spawn(function()
                while autoUpgradeEnabled do
                    local plot = getPlayerPlot()
                    if plot then
                        local effects = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Effects")
                        if effects then
                            for _, gui in ipairs(effects:GetChildren()) do
                                if not autoUpgradeEnabled then break end
                                if gui:IsA("SurfaceGui") or gui:IsA("BillboardGui") then
                                    local adornee = gui.Adornee
                                    if adornee and adornee:IsDescendantOf(plot) then
                                        local container = adornee.Parent and adornee.Parent.Parent
                                        if container then
                                            local innerModel = container:FindFirstChild("InnerModel")
                                            if innerModel and #innerModel:GetChildren() > 0 then
                                                local buyMax = gui:FindFirstChild("BuyMax")
                                                if buyMax then
                                                    local cashLabel = buyMax:FindFirstChild("Cash")
                                                    if cashLabel and cashLabel:IsA("TextLabel") then
                                                        local costText = string.gsub(cashLabel.Text, "[%$%s]", "")
                                                        local cost = NumberConverter and NumberConverter.Parse(costText) or tonumber(costText)
                                                        
                                                        if cost and getPlayerCash() >= cost then
                                                            local containerNum = container.Name
                                                            if containerNum then
                                                                print("[Brainrot] Upgrading container " .. containerNum .. " for " .. costText)
                                                                local args = { containerNum }
                                                                pcall(function()
                                                                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("ContainerService"):WaitForChild("RF"):WaitForChild("UpgradeBrainrot"):InvokeServer(unpack(args))
                                                                end)
                                                                task.wait(0.5)
                                                            end
                                                        end
                                                    end
                                                end
                                            else
                                                print("[Brainrot] Ignored container " .. container.Name .. " (No brainrot inside)")
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    task.wait(2)
                end
            end)
        end
    end
})

local autoUpgradeMSEnabled = false
Tabs.Farming:Toggle({
    Title = "Auto Upgrade Movement Speed",
    Value = false,
    Callback = function(Value)
        autoUpgradeMSEnabled = Value
        if Value then
            task.spawn(function()
                while autoUpgradeMSEnabled do
                    pcall(function()
                        local gui = LocalPlayer.PlayerGui.Windows.UpgradesShop.Container.ScrollingFrame.MovementSpeed
                        local cashLabel = gui.Main.Buttons.Buy1:FindFirstChild("Cash")
                        if cashLabel then
                            local costText = string.gsub(cashLabel.Text, "[%$%s]", "")
                            local cost = NumberConverter and NumberConverter.Parse(costText) or tonumber(costText)
                            if cost and getPlayerCash() >= cost then
                                print("[MovementSpeed] Upgrading for " .. costText)
                                local args = { "MovementSpeed", 4 }
                                game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("UpgradesService"):WaitForChild("RF"):WaitForChild("Upgrade"):InvokeServer(unpack(args))
                            end
                        end
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end
})

local autoBuyLuckyBlock = false
Tabs.Farming:Toggle({
    Title = "Auto Buy Best Lucky Block",
    Value = false,
    Callback = function(Value)
        autoBuyLuckyBlock = Value
        if Value then
            task.spawn(function()
                while autoBuyLuckyBlock do
                    pcall(function()
                        local scrollingFrame = LocalPlayer.PlayerGui.Windows.PickaxeShop.ShopContainer.ScrollingFrame
                        local ignoreList = {}
                        
                        -- Identify event items to ignore
                        for _, child in ipairs(scrollingFrame:GetChildren()) do
                            if child:IsA("Frame") or child:IsA("ImageLabel") then
                                if string.match(child.Name, "_event$") then
                                    ignoreList[child.Name] = true
                                    local baseName = string.gsub(child.Name, "_event$", "")
                                    ignoreList[baseName] = true
                                end
                            end
                        end
                        
                        local bestItem = nil
                        local currentEquipped = nil
                        local playerCash = getPlayerCash()
                        
                        for _, child in ipairs(scrollingFrame:GetChildren()) do
                            if (child:IsA("Frame") or child:IsA("ImageLabel")) and not ignoreList[child.Name] and child:FindFirstChild("Main") then
                                local buyFrame = child.Main:FindFirstChild("Buy")
                                if buyFrame then
                                    local buyBtn = buyFrame:FindFirstChild("BuyButton")
                                    local unequipBtn = buyFrame:FindFirstChild("Unequip")
                                    local equipBtn = buyFrame:FindFirstChild("Equip")
                                    
                                    if buyBtn and buyBtn:FindFirstChild("Cash") then
                                        local costText = string.gsub(buyBtn.Cash.Text, "[%$%s]", "")
                                        local cost = NumberConverter and NumberConverter.Parse(costText) or tonumber(costText)
                                        
                                        local isEquipped = unequipBtn and unequipBtn.Visible
                                        local isPurchased = not buyBtn.Visible
                                        
                                        if cost then
                                            if isEquipped then
                                                if not currentEquipped or cost > currentEquipped.price then
                                                    currentEquipped = { name = child.Name, price = cost }
                                                end
                                            end
                                            
                                            if isPurchased or playerCash >= cost then
                                                if not bestItem or cost > bestItem.price then
                                                    bestItem = { name = child.Name, price = cost, button = buyBtn, equipBtn = equipBtn, isPurchased = isPurchased }
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        
                        -- Logic to buy/equip
                        if bestItem then
                            if not currentEquipped or bestItem.price > currentEquipped.price then
                                print("[LuckyBlock] Upgrading to " .. bestItem.name)
                                if not bestItem.isPurchased then
                                    -- Try firing the button if possible
                                    if getconnections then
                                        for _, conn in ipairs(getconnections(bestItem.button.MouseButton1Click)) do
                                            pcall(function() conn.Function() end)
                                        end
                                    end
                                    -- Fallback to remote guess
                                    local args = { bestItem.name }
                                    pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("PickaxeService"):WaitForChild("RF"):WaitForChild("BuyPickaxe"):InvokeServer(unpack(args)) end)
                                    pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("PickaxeService"):WaitForChild("RF"):WaitForChild("Buy"):InvokeServer(unpack(args)) end)
                                end
                                
                                -- Equip
                                if getconnections and bestItem.equipBtn then
                                    for _, conn in ipairs(getconnections(bestItem.equipBtn.MouseButton1Click)) do
                                        pcall(function() conn.Function() end)
                                    end
                                end
                                local args = { bestItem.name }
                                pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("PickaxeService"):WaitForChild("RF"):WaitForChild("EquipPickaxe"):InvokeServer(unpack(args)) end)
                                pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("PickaxeService"):WaitForChild("RF"):WaitForChild("Equip"):InvokeServer(unpack(args)) end)
                            end
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
