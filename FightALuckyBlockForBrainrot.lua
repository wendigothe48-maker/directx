-- fluent code converted to wind ui
-- [[ KEY SYSTEM LOADER ]] --
local KeySystem = loadstring(game:HttpGet("https://raw.githubusercontent.com/wendigo5414-cmyk/scripts/refs/heads/main/keysystem.lua"))()
KeySystem.Init()

-- [[ GAME SCRIPT START ]] --
local cloneref = (cloneref or clonereference or function(instance) return instance end)
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local isMobile = game:GetService("UserInputService").TouchEnabled

local WindUI
local ok, result = pcall(function()
    return require("./src/Init")
end)

if ok then WindUI = result else 
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
pcall(function() gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)

local Window = WindUI:CreateWindow({
    Title = "Prime X Hub | " .. gameName,
    Folder = "PXH_Hub",
    Icon = "solar:gamepad-bold",
    HideSearchBar = false,
    OpenButton = { Title = "Open PXH Hub", CornerRadius = UDim.new(1,0), StrokeThickness = 3, Enabled = true, Draggable = true, OnlyMobile = false, Scale = 0.8, Color = ColorSequence.new(Color3.fromHex("#30FF6A"), Color3.fromHex("#e7ff2f")) },
    Topbar = { Height = 44, ButtonsType = "Mac" },
})

Window:Tag({ Title = "by PXH", Icon = "github", Color = Color3.fromHex("#1c1c1c"), Border = true })

local Tabs = {
    Main = Window:Tab({ Title = "Main", Icon = "solar:bolt-bold" }),
    Movement = Window:Tab({ Title = "Movement", Icon = "solar:running-bold" }),
    Teleport = Window:Tab({ Title = "Teleport", Icon = "solar:map-point-bold" }),
    Settings = Window:Tab({ Title = "Settings", Icon = "solar:settings-bold" }),
    AboutUs  = Window:Tab({ Title = "About Us", Icon = "solar:info-circle-bold" })
}

local ok, OthersFunc = pcall(function() return loadstring(game:HttpGet("https://raw.githubusercontent.com/wendigo5414-cmyk/FireballxArena/main/Others.lua", true))() end)

local NumberConverter = nil
if ok and type(OthersFunc) == "function" then
    NumberConverter = OthersFunc(Window, Tabs, WindUI)
else
    WindUI:Notify({ Title = "Error", Content = "Failed to load basic categories from Others.lua", Duration = 5 })
end


local function CustomParseValue(valStr)
    if type(valStr) == "number" then return valStr end
    local s = tostring(valStr)
    local clean = s:gsub("[%s%$%+,]", "")
    clean = clean:gsub("[Qq][Nn]$", "Qi")
    clean = clean:gsub("[Qq][Dd]$", "Qa")
    return NumberConverter and NumberConverter.Parse(clean) or tonumber(clean) or 0
end

local function getPlayerCash()
    local cashObj = LocalPlayer.leaderstats:FindFirstChild("Cash")
    if cashObj then return tonumber(cashObj.Value) or 0 end
    return 0
end

local function getMyPlot()
    local bases = workspace:FindFirstChild("Bases")
    if not bases then return nil end
    for _, base in ipairs(bases:GetChildren()) do
        local sp = base:FindFirstChild("SpawnPoint")
        if sp then
            local home = sp:FindFirstChild("Home")
            if home then
                local tl = home:FindFirstChild("TextLabel")
                if tl and tl.Text == "Home" then
                    return base
                end
            end
        end
    end
    return nil
end

local autoFarmLuckyBlock = false
Tabs.Main:Toggle({
    Title = "Auto Farm Luckyblock",
    Value = false,
    Callback = function(Value)
        autoFarmLuckyBlock = Value
        if Value then
            task.spawn(function()
                while autoFarmLuckyBlock do
                    pcall(function()
                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            if hrp.Position.X > 291.75 then
                                local startPoint = workspace:FindFirstChild("RoadMap") and workspace.RoadMap:FindFirstChild("StartPoint")
                                if startPoint then
                                    hrp.CFrame = startPoint.CFrame
                                end
                            else
                                game:GetService("ReplicatedStorage"):WaitForChild("ConsPackages"):WaitForChild("Link"):WaitForChild("RemoteEvents"):WaitForChild("DamageBoostClick"):FireServer()
                            end
                        end
                    end)
                    task.wait(0.04)
                end
            end)
        end
    end
})

local BaseGroup = Tabs.Main:Group({})
local BaseSection = BaseGroup:Section({ Title = "Base", Box = true, BoxBorder = true, Opened = true })

local autoCollectEnabled = false
BaseSection:Toggle({
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
                            local padsFolder = plot:FindFirstChild("Pads")
                            if padsFolder then
                                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if hrp and firetouchinterest then
                                    for _, pad in ipairs(padsFolder:GetChildren()) do
                                        if not autoCollectEnabled then break end
                                        local claimHitbox = pad:FindFirstChild("ClaimHitbox")
                                        if claimHitbox then
                                            firetouchinterest(claimHitbox, hrp, 0)
                                            if isMobile then
                                                task.delay(0.01, function()
                                                    if autoCollectEnabled then
                                                        firetouchinterest(claimHitbox, hrp, 1)
                                                    end
                                                end)
                                            end
                                            task.wait(0.35)
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(7)
                end
            end)
        end
    end
})

local autoUpgradeEnabled = false
BaseSection:Toggle({
    Title = "Auto Upgrade Brainrot",
    Value = false,
    Callback = function(Value)
        autoUpgradeEnabled = Value
        if Value then
            task.spawn(function()
                while autoUpgradeEnabled do
                    local didUpgrade = false
                    pcall(function()
                        local myCoinsText = "0"
                        local coinsObj = LocalPlayer.leaderstats:FindFirstChild("Coins")
                        if coinsObj then
                            if coinsObj:IsA("StringValue") then
                                myCoinsText = coinsObj.Value
                            else
                                myCoinsText = tostring(coinsObj.Value)
                            end
                        end
                        
                        local myCoins = CustomParseValue(myCoinsText)
                        local pg = LocalPlayer:FindFirstChild("PlayerGui")
                        local upgHost = pg and pg:FindFirstChild("UpgradeBrainrotsHost")
                        
                        if upgHost then
                            local children = upgHost:GetChildren()
                            for _, child in ipairs(children) do
                                if not autoUpgradeEnabled then break end
                                local button = child:FindFirstChild("Button")
                                local costLabel = button and button:FindFirstChild("Cost")
                                
                                if costLabel then
                                    local costText = costLabel.Text
                                    if costText ~= "$20.43 k" and costText ~= "$20.43k" and costText ~= "Max" and costText ~= "Maxed" then
                                        local strippedCost = string.gsub(costText, "[%$%s]", "")
                                        local costNum = CustomParseValue(strippedCost)
                                        
                                        if myCoins >= costNum then
                                            local adornee = nil
                                            pcall(function() adornee = child.Adornee end)
                                            
                                            if adornee and adornee.Parent then
                                                local padNumber = adornee.Parent.Name
                                                local args = { padNumber }
                                                game:GetService("ReplicatedStorage"):WaitForChild("ConsPackages"):WaitForChild("Link"):WaitForChild("RemoteEvents"):WaitForChild("UpgradeBrainrot"):FireServer(unpack(args))
                                                didUpgrade = true
                                            end
                                        end
                                    end
                                end
                            end
                        else
                            -- UpgradeBrainrotsHost not found
                        end
                    end)
                    if didUpgrade then
                        task.wait()
                    else
                        task.wait(1.5)
                    end
                end
            end)
        end
    end
})


Tabs.Main:Toggle({
    Title = "Auto Place & Open LuckyBlock",
    Value = false,
    Callback = function(Value)
        autoPlaceOpen = Value
        if Value then
            task.spawn(function()
                while autoPlaceOpen do
                    pcall(function()
                        local plot = getMyPlot()
                        if plot then
                            local pads = plot:FindFirstChild("Pads")
                            if pads then
                                -- Gather all empty pads
                                local emptyPads = {}
                                for _, pad in ipairs(pads:GetChildren()) do
                                    local claim = pad:FindFirstChild("Claim")
                                    if claim then
                                        local sg = claim:FindFirstChild("SurfaceGui")
                                        local btn = sg and sg:FindFirstChild("Button")
                                        local coins = btn and btn:FindFirstChild("Coins")
                                        if coins and (coins.Text == "$0" or coins.Text == "0" or coins.Text:match("^0$") or coins.Text == "") then
                                            table.insert(emptyPads, pad.Name)
                                        end
                                    end
                                end

                                if #emptyPads > 0 then
                                    -- Find all LuckyBlock tools
                                    local luckyBlocks = {}
                                    local function gatherBlocks(parent)
                                        if not parent then return end
                                        for _, item in ipairs(parent:GetChildren()) do
                                            if item:IsA("Tool") and string.find(item.Name, "LuckyBlock") then
                                                table.insert(luckyBlocks, item)
                                            end
                                        end
                                    end
                                    
                                    gatherBlocks(LocalPlayer:FindFirstChild("Backpack"))
                                    if LocalPlayer.Character then
                                        gatherBlocks(LocalPlayer.Character)
                                    end
                                    
                                    local placedPads = {}
                                    
                                    if #luckyBlocks > 0 then
                                        local emptyPadIndex = 1
                                        for _, tool in ipairs(luckyBlocks) do
                                            if not autoPlaceOpen then break end
                                            if emptyPadIndex > #emptyPads then break end -- No more empty pads
                                            
                                            local countAttr = tool:GetAttribute("Count")
                                            local count = type(countAttr) == "number" and countAttr or 1
                                            
                                            -- Equip the tool
                                            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                                                LocalPlayer.Character.Humanoid:EquipTool(tool)
                                            end
                                            task.wait(0.1)
                                            
                                            while count > 0 and emptyPadIndex <= #emptyPads do
                                                local targetPad = emptyPads[emptyPadIndex]
                                                game:GetService("ReplicatedStorage"):WaitForChild("ConsPackages"):WaitForChild("Link"):WaitForChild("RemoteEvents"):WaitForChild("PadAction"):FireServer(targetPad)
                                                table.insert(placedPads, targetPad)
                                                count = count - 1
                                                emptyPadIndex = emptyPadIndex + 1
                                                task.wait(0.05)
                                            end
                                        end
                                        
                                        if #placedPads > 0 then
                                            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                                                LocalPlayer.Character.Humanoid:UnequipTools()
                                            end
                                            task.wait(0.5)
                                            
                                            for _, padName in ipairs(placedPads) do
                                                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                                                    LocalPlayer.Character.Humanoid:UnequipTools()
                                                end
                                                game:GetService("ReplicatedStorage"):WaitForChild("ConsPackages"):WaitForChild("Link"):WaitForChild("RemoteEvents"):WaitForChild("PadAction"):FireServer(padName)
                                                task.wait(0.05)
                                            end
                                            
                                            task.spawn(function()
                                                task.wait(3)
                                                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                                                    LocalPlayer.Character.Humanoid:UnequipTools()
                                                end
                                                for _, padName in ipairs(placedPads) do
                                                    game:GetService("ReplicatedStorage"):WaitForChild("ConsPackages"):WaitForChild("Link"):WaitForChild("RemoteEvents"):WaitForChild("PadAction"):FireServer(padName)
                                                    task.wait(0.05)
                                                end
                                            end)
                                            
                                            -- Wait extra for pickup to finish
                                            task.wait(3.5)
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

Tabs.Main:Toggle({
    Title = "Auto Best Buy Weights",
    Value = false,
    Callback = function(Value)
        autoBestWeights = Value
        if Value then
            task.spawn(function()
                while autoBestWeights do
                    pcall(function()
                        local weightShop = LocalPlayer.PlayerGui:FindFirstChild("MainScreen") and LocalPlayer.PlayerGui.MainScreen:FindFirstChild("Interfaces") and LocalPlayer.PlayerGui.MainScreen.Interfaces:FindFirstChild("WeightShop")
                        if weightShop then
                            local scroll = weightShop:FindFirstChild("Content") and weightShop.Content:FindFirstChild("ScrollingFrame")
                            if scroll then
                                local validWeights = {}
                                
                                for _, item in ipairs(scroll:GetChildren()) do
                                    if item:IsA("Frame") and item:FindFirstChild("Container") then
                                        local powerLabel = item.Container:FindFirstChild("Info") and item.Container.Info:FindFirstChild("Power")
                                        local buyBtn = item.Container:FindFirstChild("BuyButtons") and item.Container.BuyButtons:FindFirstChild("CashButton") and item.Container.BuyButtons.CashButton:FindFirstChild("ImageButton") and item.Container.BuyButtons.CashButton.ImageButton:FindFirstChild("Front")
                                        local priceLabel = buyBtn and buyBtn:FindFirstChild("Price")
                                        
                                        if powerLabel and priceLabel then
                                            local powerStr = powerLabel.Text
                                            local powerNum = CustomParseValue(powerStr)
                                            
                                            local priceStr = priceLabel.Text
                                            local status = "buy"
                                            local priceNum = math.huge
                                            
                                            if priceStr == "Equipped" then
                                                status = "equipped"
                                                priceNum = 0
                                            elseif priceStr == "Equip" then
                                                status = "equip"
                                                priceNum = 0
                                            else
                                                priceNum = CustomParseValue(priceStr)
                                            end
                                            
                                            table.insert(validWeights, {
                                                Name = item.Name,
                                                Power = powerNum,
                                                Status = status,
                                                PriceNum = priceNum,
                                                Item = item,
                                                RawPrice = priceStr
                                            })
                                        end
                                    end
                                end
                                
                                table.sort(validWeights, function(a, b) return a.Power > b.Power end)
                                
                                local myCashText = LocalPlayer.leaderstats:FindFirstChild("Cash") and LocalPlayer.leaderstats.Cash.Value or 0
                                local myCash = CustomParseValue(myCashText)
                                
                                for _, weight in ipairs(validWeights) do
                                    if weight.Status == "equipped" then
                                        print(string.format("[Auto Best Weight] Best weight is already equipped: %s (Power: %s)", weight.Name, tostring(weight.Power)))
                                        break
                                    elseif weight.Status == "equip" then
                                        print(string.format("[Auto Best Weight] Equipping previously bought weight: %s (Power: %s)", weight.Name, tostring(weight.Power)))
                                        game:GetService("ReplicatedStorage"):WaitForChild("ConsPackages"):WaitForChild("Link"):WaitForChild("RemoteEvents"):WaitForChild("EquipWeight"):FireServer(weight.Name)
                                        break
                                    elseif weight.Status == "buy" and myCash >= weight.PriceNum then
                                        print(string.format("[Auto Best Weight] Buying new weight: %s | Price: %s | MyCash: %s", weight.Name, weight.RawPrice, tostring(myCash)))
                                        game:GetService("ReplicatedStorage"):WaitForChild("ConsPackages"):WaitForChild("Link"):WaitForChild("RemoteEvents"):WaitForChild("BuyWeightCash"):FireServer(weight.Name)
                                        game:GetService("ReplicatedStorage"):WaitForChild("ConsPackages"):WaitForChild("Link"):WaitForChild("RemoteEvents"):WaitForChild("BuyWeight"):FireServer(weight.Name)
                                        task.wait(0.2)
                                        game:GetService("ReplicatedStorage"):WaitForChild("ConsPackages"):WaitForChild("Link"):WaitForChild("RemoteEvents"):WaitForChild("EquipWeight"):FireServer(weight.Name)
                                        break
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

Tabs.Main:Toggle({
    Title = "Auto Rebirth",
    Value = false,
    Callback = function(Value)
        autoRebirth = Value
        if Value then
            task.spawn(function()
                while autoRebirth do
                    pcall(function()
                        local rbBar = LocalPlayer.PlayerGui:FindFirstChild("MainScreen") and LocalPlayer.PlayerGui.MainScreen:FindFirstChild("Interfaces") and LocalPlayer.PlayerGui.MainScreen.Interfaces:FindFirstChild("Rebirth") and LocalPlayer.PlayerGui.MainScreen.Interfaces.Rebirth:FindFirstChild("Content") and LocalPlayer.PlayerGui.MainScreen.Interfaces.Rebirth.Content:FindFirstChild("Progressbar") and LocalPlayer.PlayerGui.MainScreen.Interfaces.Rebirth.Content.Progressbar:FindFirstChild("Fill")
                        if rbBar then
                            if rbBar.Size.X.Scale >= 1 and rbBar.Size.Y.Scale >= 1 then
                                game:GetService("ReplicatedStorage"):WaitForChild("ConsPackages"):WaitForChild("Link"):WaitForChild("RemoteFunctions"):WaitForChild("RebirthRequest"):InvokeServer()
                            end
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    end
})


WindUI:Notify({ Title = "Prime X Hub", Content = "Script loaded successfully!", Duration = 5 })
