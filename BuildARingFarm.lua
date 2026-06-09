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
        windUI_Source = windUI_Source:gsub("([%w_]+)%.UserInputType%s*==%s*Enum%.UserInputType%.MouseButton1", "(%1.UserInputType == Enum.UserInputType.MouseButton1 or %1.UserInputType == Enum.UserInputType.Touch)")
        windUI_Source = windUI_Source:gsub("([%w_]+)%.UserInputType%s*==%s*Enum%.UserInputType%.MouseMovement", "(%1.UserInputType == Enum.UserInputType.MouseMovement or %1.UserInputType == Enum.UserInputType.Touch)")
        WindUI = loadstring(windUI_Source)()
    end
end

local gameName = game.Name or "Unknown Game"
task.spawn(function()
    pcall(function()
        gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    end)
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
    Events = Window:Tab({ Title = "Events", Icon = "solar:star-bold" }),
    AutoBuy = Window:Tab({ Title = "Auto Buy", Icon = "solar:cart-bold" }),
    Movement = Window:Tab({ Title = "Movement", Icon = "solar:running-bold" }),
    Teleport = Window:Tab({ Title = "Teleport", Icon = "solar:map-point-bold" }),
    Settings = Window:Tab({ Title = "Settings", Icon = "solar:settings-bold" }),
    AboutUs  = Window:Tab({ Title = "About Us", Icon = "solar:info-circle-bold" }),
}

local NumberConverter = nil -- we'll use our own function if not loaded

local function parseNumberString(str)
    if type(str) ~= "string" then return tonumber(str) or 0 end
    str = string.lower(string.gsub(str, "[%$%s,]", ""))
    local num, suffix = string.match(str, "^([%d%.]+)([a-z]*)$")
    num = tonumber(num)
    if not num then return tonumber(str) or 0 end
    
    local mults = { k=1e3, m=1e6, b=1e9, t=1e12, qa=1e15, qi=1e18 }
    return num * (mults[suffix] or 1)
end

local function getPlayerCash()
    local lp = game:GetService("Players").LocalPlayer
    local ls = lp:FindFirstChild("leaderstats")
    if ls then
        local validNames = {"Money", "Cash", "Coins", "Gold", "Tokens", "Points"}
        for _, name in ipairs(validNames) do
            local cashObj = ls:FindFirstChild(name)
            if cashObj then
                if type(cashObj.Value) == "number" then return cashObj.Value end
                if type(cashObj.Value) == "string" then return parseNumberString(cashObj.Value) end
            end
        end
        -- Fallback to any first stat
        for _, child in ipairs(ls:GetChildren()) do
            if child:IsA("NumberValue") or child:IsA("IntValue") then
                return child.Value
            elseif child:IsA("StringValue") then
                return parseNumberString(child.Value)
            end
        end
    end
    -- If we really can't find money, return math.huge to allow attempts, but the loop will handle failures.
    return math.huge
end

local function getMyPlot()
    local plots = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Plots")
    if plots then
        local lp = game:GetService("Players").LocalPlayer
        for _, plot in ipairs(plots:GetChildren()) do
            -- Primary method via OwnerSign
            local tl = plot:FindFirstChild("OwnerSign")
                and plot.OwnerSign:FindFirstChild("Face")
                and plot.OwnerSign.Face:FindFirstChild("SurfaceGui")
                and plot.OwnerSign.Face.SurfaceGui:FindFirstChild("TextLabel")
            if tl and tl:IsA("TextLabel") then
                if string.find(tl.Text, lp.DisplayName, 1, true) or string.find(tl.Text, lp.Name, 1, true) then
                    return plot
                end
            end
            
            -- Fallback method
            local owner = plot:FindFirstChild("Owner")
            if owner and owner:IsA("StringValue") and (owner.Value == lp.Name or owner.Value == lp.DisplayName) then
                return plot
            end
        end
    end
    return nil
end

local function getExpectedSeedRollCount(plot)
    if not plot then return 1 end
    local desc = plot:FindFirstChild("UpgradeSign") 
        and plot.UpgradeSign:FindFirstChild("Screen") 
        and plot.UpgradeSign.Screen:FindFirstChild("SurfaceGui") 
        and plot.UpgradeSign.Screen.SurfaceGui:FindFirstChild("SeedRolls") 
        and plot.UpgradeSign.Screen.SurfaceGui.SeedRolls:FindFirstChild("Desc")
    if desc and desc:IsA("TextLabel") then
        local firstNum = string.match(desc.Text, "^(%d+)%s*>")
        if firstNum then
            return tonumber(firstNum) or 1
        else
            local justNumber = string.match(desc.Text, "^%s*(%d+)%s*$")
            if justNumber then return tonumber(justNumber) or 1 end
        end
    end
    return 1 
end

local API_URL = "https://sairo.online"
local AUTH_KEY = "PASSXX09"
local HttpService = game:GetService("HttpService")
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request or function(options)
    return HttpService:RequestAsync(options)
end

local seedPrices = {}

local function saveSeedPrices(seedName, price)
    if not seedName or not price then return end
    task.spawn(function()
        local success, err = pcall(function()
            local body = HttpService:JSONEncode({
                key = "RingFarmSeedPrices",
                new_data = {
                    [seedName] = price
                }
            })
            httpRequest({
                Url = API_URL .. "/api/storage/merge",
                Method = "POST",
                Headers = { 
                    ["Authorization"] = "Bearer " .. AUTH_KEY,
                    ["Content-Type"] = "application/json" 
                },
                Body = body
            })
        end)
        if success then
            local msg = "[Database] Successfully saved prices to database."
            if seedName and price then
                msg = msg .. " (Added: " .. tostring(seedName) .. " = " .. tostring(price) .. ")"
            end
            print(msg)
        else
            print("[Database] Error saving prices to database:", err)
        end
    end)
end

local function extractSeedName(displayName)
    local match = string.match(displayName, "^(.-)%s*%[.-%]$")
    return match or displayName
end

local function extractBaseName(str)
    local n = type(str) == "string" and str or tostring(str)
    n = string.match(n, "^(.-)%s*%[.-%]$") or n
    n = string.gsub(n, "%s*[Ss]eed%s*$", "")
    n = string.lower(string.gsub(n, "^%s*(.-)%s*$", "%1"))
    return n
end

getgenv().autoSeedAndBuyEnabled = false
getgenv().selectedRarities = {}
getgenv().selectedSeeds = {}
getgenv().ifBuySeeds = {}
local seedDropdown
local ifBuyDropdown

local seedData = {}
local seedList = {}
local seedToRarity = {}
local rarityOrder = {}
local rarityData = {}
local rarityList = {}

local function reloadSeedDropdown()
    local newSeedList = {}
    for _, data in ipairs(seedData) do
        local displayName = data.Name
        if seedPrices[data.Name] then
            displayName = data.Name .. " [" .. seedPrices[data.Name] .. "]"
        end
        table.insert(newSeedList, displayName)
    end
    seedList = newSeedList
    if seedDropdown and seedDropdown.Refresh then
        pcall(function() seedDropdown:Refresh(seedList) end)
    end
    if ifBuyDropdown and ifBuyDropdown.Refresh then
        pcall(function() ifBuyDropdown:Refresh(seedList) end)
    end
end

pcall(function()
    local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        local sf = playerGui:FindFirstChild("MainUI") 
            and playerGui.MainUI:FindFirstChild("Menus") 
            and playerGui.MainUI.Menus:FindFirstChild("IndexFrame") 
            and playerGui.MainUI.Menus.IndexFrame:FindFirstChild("Main") 
            and playerGui.MainUI.Menus.IndexFrame.Main:FindFirstChild("PlantsFrame")
        
        if sf then
            for _, child in ipairs(sf:GetChildren()) do
                if child:IsA("Frame") then
                    local seedName = child.Name .. " Seed"
                    local order = child.LayoutOrder or 0
                    local rarityName = "Unknown"
                    local rarityLabel = child:FindFirstChild("RarityName")
                    if rarityLabel and rarityLabel:IsA("TextLabel") then
                        rarityName = rarityLabel.Text
                    end
                    table.insert(seedData, {Name = seedName, Order = order, Rarity = rarityName})
                end
            end
        end
    end
end)

table.sort(seedData, function(a, b) return a.Order < b.Order end)

task.spawn(function()
    local function fetchPrices()
        pcall(function()
            local readUrl = API_URL .. "/api/storage/read?key=RingFarmSeedPrices"
            local response = httpRequest({ 
                Url = readUrl, 
                Method = "GET",
                Headers = { ["Authorization"] = "Bearer " .. AUTH_KEY }
            })
            local data = HttpService:JSONDecode(response.Body)
            if data.success and type(data.value) == "table" then
                local updated = false
                for k, v in pairs(data.value) do
                    if seedPrices[k] ~= v then
                        seedPrices[k] = v
                        updated = true
                    end
                end
                if updated and reloadSeedDropdown then
                    reloadSeedDropdown()
                end
            end
        end)
    end
    
    fetchPrices()
    task.wait(10)
    fetchPrices()
end)

for _, data in ipairs(seedData) do
    local displayName = data.Name
    if seedPrices[data.Name] then
        displayName = data.Name .. " [" .. seedPrices[data.Name] .. "]"
    end
    table.insert(seedList, displayName)
    seedToRarity[data.Name] = data.Rarity
    if not rarityOrder[data.Rarity] then
        rarityOrder[data.Rarity] = data.Order
        table.insert(rarityData, {Name = data.Rarity, Order = data.Order})
    end
end

table.sort(rarityData, function(a, b) return a.Order < b.Order end)
for _, data in ipairs(rarityData) do
    table.insert(rarityList, data.Name)
end

Tabs.Main:Toggle({
    Title = "Auto Best Place Seeds",
    Value = false,
    Callback = function(state)
        getgenv().AutoBestPlaceSeeds = state
        if state then
            task.spawn(function()
                local function getSeedRank(seedName)
                    local baseName = extractBaseName(seedName)
                    for i, data in ipairs(seedData) do
                        if string.lower(extractBaseName(data.Name)) == string.lower(baseName) then
                            return i
                        end
                    end
                    return 0
                end
                
                local function getBestSeedTool()
                    local bestTool = nil
                    local bestRank = -1
                    local bestName = ""
                    
                    local player = game:GetService("Players").LocalPlayer
                    local char = player.Character
                    
                    local checkParent = function(parent)
                        if not parent then return end
                        for _, tool in ipairs(parent:GetChildren()) do
                            if tool:IsA("Tool") and string.match(tool.Name, "[Ss]eed") then
                                local realName = string.gsub(tool.Name, " %(x%d+%)$", "")
                                realName = extractBaseName(realName)
                                local rank = getSeedRank(realName)
                                if rank > bestRank then
                                    bestRank = rank
                                    bestTool = tool
                                    bestName = realName
                                end
                            end
                        end
                    end
                    
                    checkParent(player:FindFirstChild("Backpack"))
                    if char then checkParent(char) end
                    
                    return bestTool, bestRank, bestName
                end
                
                local function getPlantedSeedRank(dirt)
                    for _, child in ipairs(dirt:GetChildren()) do
                        if child:IsA("Model") or child:IsA("BasePart") then
                            local realName = child.Name
                            if not string.match(realName, "[Ss]eed$") then
                                realName = realName .. " Seed"
                            end
                            return getSeedRank(realName), realName
                        end
                    end
                    return -1, nil -- Empty
                end
                
                while getgenv().AutoBestPlaceSeeds do
                    local ok, err = pcall(function()
                        local myPlot = getMyPlot()
                        if not myPlot then return end
                        local farmPlot = myPlot:FindFirstChild("FarmPlot")
                        if not farmPlot then return end

                        local emptyDirts = {}
                        local filledDirts = {}
                        
                        for _, plot in ipairs(farmPlot:GetChildren()) do
                            local dirt = plot:FindFirstChild("Dirt")
                            if dirt then
                                local rank, pName = getPlantedSeedRank(dirt)
                                if rank == -1 then
                                    table.insert(emptyDirts, dirt)
                                else
                                    table.insert(filledDirts, {dirt = dirt, rank = rank, name = pName})
                                end
                            end
                        end

                        local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
                        local plantSeedEvent = remotes:WaitForChild("PlantSeed")
                        local removePlantEvent = remotes:WaitForChild("RemovePlant")

                        local player = game:GetService("Players").LocalPlayer
                        local char = player.Character
                        local hum = char and char:FindFirstChild("Humanoid")

                        local function equipAndPlant(targetDirt)
                            local bestTool, bRank, bName = getBestSeedTool()
                            if not bestTool then return false end
                            
                            if bestTool.Parent ~= char then
                                hum:EquipTool(bestTool)
                                task.wait(0.2)
                            end
                            
                            plantSeedEvent:FireServer(targetDirt)
                            task.wait(0.5)
                            return true
                        end

                        for _, dirt in ipairs(emptyDirts) do
                            if not getgenv().AutoBestPlaceSeeds then return end
                            equipAndPlant(dirt)
                        end

                        for _, fd in ipairs(filledDirts) do
                            if not getgenv().AutoBestPlaceSeeds then return end
                            local bestTool, bRank, bName = getBestSeedTool()
                            if not bestTool then break end
                            
                            if bRank > fd.rank then
                                print("[AutoBestPlace] Removing worse seed:", fd.name, "to place:", bName)
                                removePlantEvent:FireServer(fd.dirt)
                                task.wait(0.5)
                                equipAndPlant(fd.dirt)
                            end
                        end
                        
                        -- Unequip when done planting
                        if char and hum then
                            for _, tool in ipairs(char:GetChildren()) do
                                if tool:IsA("Tool") and string.match(tool.Name, "[Ss]eed") then
                                    hum:UnequipTools()
                                    break
                                end
                            end
                        end
                    end)
                    if not ok then print("[AutoBestPlace] Error:", err) end
                    task.wait(2)
                end
            end)
        end
    end
})

local PickupSection = Tabs.Main:Section({
    Title = "Pickup and Sell",
    Box = true,
    BoxBorder = true,
    Opened = false,
})

getgenv().pickupDelay = 2
PickupSection:Slider({
    Title = "Pickup Delay",
    Desc = "Adjust delay in seconds",
    Step = 1,
    Value = {
        Min = 1,
        Max = 100,
        Default = 2,
    },
    Callback = function(value)
        getgenv().pickupDelay = value
    end
})

PickupSection:Toggle({
    Title = "Auto Pickup And Sell",
    Value = false,
    Callback = function(state)
        getgenv().AutoPickupSell = state
        if state then
            task.spawn(function()
                while getgenv().AutoPickupSell do
                    local ok, err = pcall(function()
                        local player = game:GetService("Players").LocalPlayer
                        local char = player.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        if not root then return end
                        
                        local myPlot = getMyPlot()
                        if not myPlot then return end
                        
                        local harvester = myPlot:FindFirstChild("Harvester")
                        local targetCube = harvester and harvester:FindFirstChild("Cube.003")
                        if targetCube then
                            root.CFrame = targetCube.CFrame + Vector3.new(0, 3, 0)
                            task.wait(0.2)
                        end
                        
                        local cp = myPlot:FindFirstChild("CratePosition")
                        local prompt = cp and cp:FindFirstChild("CratesPickupPrompt")
                        if prompt and prompt.Enabled and fireproximityprompt then
                            fireproximityprompt(prompt)
                        end
                        
                        task.wait(1) -- wait 1 sec to account for ping
                        
                        local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                        local sell = remotes and remotes:FindFirstChild("SellCrates")
                        if sell then
                            sell:FireServer()
                        end
                    end)
                    if not ok then print("[AutoPickupSell] Error:", err) end
                    task.wait(getgenv().pickupDelay)
                end
            end)
        end
    end
})

local MainSection = Tabs.Main:Section({
    Title = "Auto Seed & Buy",
    Box = true,
    BoxBorder = true,
    Opened = true,
})



local currentAutoSeedThread = 0

MainSection:Toggle({
    Title = "Auto Seed & Buy",
    Value = false,
    Callback = function(state)
        getgenv().autoSeedAndBuyEnabled = state
        currentAutoSeedThread = currentAutoSeedThread + 1
        local thisThread = currentAutoSeedThread
        
        if getgenv().autoSeedAndBuyEnabled then
            task.spawn(function()
                while getgenv().autoSeedAndBuyEnabled and currentAutoSeedThread == thisThread do
                    local success, err = pcall(function()
                        local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
                        local rollSeeds = remotes:WaitForChild("RollSeeds")
                        local buySeed = remotes:FindFirstChild("BuySeed") -- don't yield here if it's missing
                        
                        local myPlot = getMyPlot()
                        if not myPlot then
                            task.wait(2)
                            return
                        end
                        
                        local sr = myPlot:FindFirstChild("SeedRoller")
                        if not sr then
                            task.wait(2)
                            return
                        end
                        
                        -- Find Stand positions
                        local standsMap = {}
                        local standsCount = 0
                        for _, stand in ipairs(sr:GetChildren()) do
                            local id = tonumber(string.match(stand.Name, "^Stand(%d+)$"))
                            if id then
                                local cube = stand:FindFirstChild("Cube.007") or stand:FindFirstChild("Cube")
                                if not cube then
                                    for _, c in ipairs(stand:GetChildren()) do
                                        if string.match(c.Name, "^Cube") and c:IsA("BasePart") then cube = c break end
                                    end
                                end
                                if cube then 
                                    standsMap[id] = cube.Position 
                                    standsCount = standsCount + 1
                                else
                                    pcall(function() 
                                        standsMap[id] = stand:GetPivot().Position 
                                        standsCount = standsCount + 1
                                    end)
                                end
                            end
                        end
                        
                        -- Find Seeds on our stands
                        local mySeeds = {}
                        local debugWkspSeeds = 0
                        local debugWithGui = 0
                        for _, obj in ipairs(workspace:GetChildren()) do
                            if (obj:IsA("Model") or obj:IsA("BasePart")) and obj.Name ~= "Map" and not game:GetService("Players"):GetPlayerFromCharacter(obj) then
                                -- Check if it's likely a seed model
                                -- Either it has SeedGui, or it has Rarity/Cost inside some UI
                                local sg = obj:FindFirstChild("SeedGui", true)
                                if not sg then
                                    -- fallback: look for any UI containing Rarity/Cost
                                    for _, desc in ipairs(obj:GetDescendants()) do
                                        if desc.Name == "InfoFrame" or desc.Name == "Rarity" or desc.Name == "Cost" then
                                            sg = desc.Parent
                                            while sg and not (sg:IsA("SurfaceGui") or sg:IsA("BillboardGui")) do
                                                sg = sg.Parent
                                            end
                                            break
                                        end
                                    end
                                end
                                
                                local knownSeedName = nil
                                if seedToRarity[obj.Name] then knownSeedName = obj.Name end
                                if seedToRarity[obj.Name .. " Seed"] then knownSeedName = obj.Name end
                                
                                if string.match(obj.Name, "[Ss]eed$") or sg or knownSeedName then
                                    debugWkspSeeds = debugWkspSeeds + 1
                                end

                                local pivot = obj:GetPivot()
                                if (sg or knownSeedName) and pivot then
                                    if sg then debugWithGui = debugWithGui + 1 end
                                    local pos = pivot.Position
                                    local bestId = nil
                                    local bestDist = 100 -- extra generous distance
                                    for id, stPos in pairs(standsMap) do
                                        local dist = (Vector3.new(pos.X, 0, pos.Z) - Vector3.new(stPos.X, 0, stPos.Z)).Magnitude
                                        if dist < bestDist then
                                            bestDist = dist
                                            bestId = id
                                        end
                                    end
                                    
                                    if bestId then
                                        table.insert(mySeeds, { obj = obj, standId = bestId, sg = sg })
                                    end
                                end
                            end
                        end
                        
                        if #mySeeds == 0 then
                            print("[AutoSeed] Debug: Potential seeds in Wksp =", debugWkspSeeds, "| With UI =", debugWithGui, "| Stands mapped =", standsCount)
                            if standsCount > 0 then
                                for k,v in pairs(standsMap) do
                                    print("   Stand ID:", k, "Pos:", math.floor(v.X), math.floor(v.Y), math.floor(v.Z))
                                end
                            end
                            print("[AutoSeed] No seeds found on stands, rolling...")
                            rollSeeds:FireServer()
                            task.wait(2.5) -- wait longer for seeds to spawn
                            return
                        end
                        
                        local function isSelected(seedName, rarityName, isIfBuyMode)
                            local targetTable = isIfBuyMode and getgenv().ifBuySeeds or getgenv().selectedSeeds
                            local exactMatch = false
                            
                            -- Check direct seed name match
                            if type(targetTable) == "table" then
                                for k, v in pairs(targetTable) do
                                    local val = (type(k) == "string" and v == true) and k or (type(v) == "string" and v or nil)
                                    if val and string.lower(extractBaseName(val)) == string.lower(extractBaseName(seedName)) then
                                        exactMatch = true
                                        break
                                    end
                                end
                            end
                            
                            -- Check rarity match (only for Must Buy)
                            if not isIfBuyMode and rarityName and type(getgenv().selectedRarities) == "table" then
                                for k, v in pairs(getgenv().selectedRarities) do
                                    local val = (type(k) == "string" and v == true) and k or (type(v) == "string" and v or nil)
                                    if val and string.lower(tostring(val)) == string.lower(tostring(rarityName)) then
                                        exactMatch = true
                                        break
                                    end
                                end
                            end
                            return exactMatch
                        end
                        
                        local function attemptToBuy(info)
                            local bs = buySeed
                            if bs and bs:IsA("RemoteEvent") then
                                pcall(function() bs:FireServer(info.standId) end)
                                pcall(function() bs:FireServer("Stand" .. tostring(info.standId)) end)
                                pcall(function() bs:FireServer(tostring(info.standId)) end)
                                pcall(function() bs:FireServer(info.obj.Name) end)
                                pcall(function() bs:FireServer(info.obj) end)
                            elseif bs and bs:IsA("RemoteFunction") then
                                task.spawn(function()
                                    pcall(function() bs:InvokeServer(info.standId) end)
                                end)
                            end
                            
                            for _, d in ipairs(info.obj:GetDescendants()) do
                                if d:IsA("ProximityPrompt") then
                                    pcall(function() d:InputHoldBegin() end)
                                    task.wait(d.HoldDuration or 0)
                                    pcall(function() d:InputHoldEnd() end)
                                end
                            end
                            
                            -- Support cross-platform remote click on GUI if exists
                            if info.sg then
                                for _, d in ipairs(info.sg:GetDescendants()) do
                                    if d:IsA("GuiButton") and d.Visible then
                                        -- Many games just connect MouseButton1Click, we can fire that via signal if allowed
                                        pcall(function()
                                            for _, connection in pairs(getconnections(d.MouseButton1Click)) do
                                                connection:Fire()
                                            end
                                        end)
                                    end
                                end
                            end
                        end
                        
                        local actedOnSeed = false
                        local stillNeedCashForMustBuy = false
                        
                        for _, info in ipairs(mySeeds) do
                            if not getgenv().autoSeedAndBuyEnabled then break end
                            local realName = info.obj.Name
                            if not string.match(realName, "[Ss]eed$") then realName = realName .. " Seed" end
                            local rarity = seedToRarity[realName] or "Unknown"
                            local costText = ""
                            local cost = 0
                            
                            local rInfo = info.sg and info.sg:FindFirstChild("InfoFrame", true)
                            if rInfo then
                                local rLabel = rInfo:FindFirstChild("Rarity")
                                if rLabel and rLabel:IsA("TextLabel") and rLabel.Text ~= "" and rarity == "Unknown" then rarity = rLabel.Text end
                                local cLabel = rInfo:FindFirstChild("Cost")
                                if cLabel and cLabel:IsA("TextLabel") then 
                                    costText = cLabel.Text 
                                    cost = parseNumberString(costText)
                                end
                            end
                            
                            -- Fallback to database price if we didn't find a cost in UI
                            if cost == 0 and costText == "" and seedPrices[realName] then
                                costText = seedPrices[realName]
                                cost = parseNumberString(costText)
                            end
                            
                            -- Update global price dict
                            if costText ~= "" and not seedPrices[realName] then
                                seedPrices[realName] = costText
                                saveSeedPrices(realName, costText)
                            end
                            
                            local mustBuy = isSelected(realName, rarity, false)
                            local ifBuy = not mustBuy and isSelected(realName, rarity, true)
                            
                            -- DEBUG LOGGING --
                            print(string.format("[AutoSeed] Evaluating: '%s' | Extracted: '%s' | Rarity: '%s'", realName, extractBaseName(realName), rarity))
                            print("           MustBuy:", mustBuy, " | IfBuy:", ifBuy)
                            -- END DEBUG --
                            
                            if mustBuy then
                                print("[AutoSeed] MUST_BUY Found:", realName, "| Rarity:", rarity, "| Cost:", cost)
                                if getPlayerCash() >= cost then
                                    attemptToBuy(info)
                                    task.wait(1.5)
                                    actedOnSeed = true
                                    break
                                else
                                    stillNeedCashForMustBuy = true
                                    print("[AutoSeed] MUST_BUY: Waiting for cash to buy", realName)
                                    task.wait(1)
                                end
                            elseif ifBuy then
                                print("[AutoSeed] IF_BUY Found:", realName)
                                if getPlayerCash() >= cost then
                                    attemptToBuy(info)
                                    task.wait(1.5)
                                    actedOnSeed = true
                                    break
                                end
                            end
                        end
                        
                        -- If we did absolutely nothing, and there is NO pending Must Buy waiting for money, roll seeds
                        if not actedOnSeed and not stillNeedCashForMustBuy and getgenv().autoSeedAndBuyEnabled then
                            print("[AutoSeed] No target seeds. Rolling over...")
                            rollSeeds:FireServer()
                            task.wait(2.5) -- wait longer for seeds to spawn
                        end
                    end)
                    if not success then
                        print("[AutoSeed] ERROR DURING AUTO SEED:", err)
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

MainSection:Dropdown({
    Title = "Must Buy Seed Rarity",
    Multi = true,
    AllowNull = true,
    Values = rarityList,
    Value = {},
    Callback = function(values)
        getgenv().selectedRarities = values
        
        local newSeedSelection = {}
        for k, v in pairs(getgenv().selectedSeeds) do
            newSeedSelection[k] = v
        end
        for rarityName, isSel in pairs(getgenv().selectedRarities) do
            if isSel or (type(isSel)=="string" and getgenv().selectedRarities[isSel]) then
                local rName = type(isSel)=="string" and isSel or rarityName
                for idx, fullSeedName in ipairs(seedList) do
                    local sName = extractSeedName(fullSeedName)
                    if seedToRarity[sName] == rName then
                        newSeedSelection[fullSeedName] = true
                    end
                end
            end
        end
        
        if seedDropdown and seedDropdown.SetValue then
            pcall(function() seedDropdown:SetValue(newSeedSelection) end)
        else
            getgenv().selectedSeeds = newSeedSelection
        end
    end
})

seedDropdown = MainSection:Dropdown({
    Title = "Must Buy Seeds",
    Multi = true,
    AllowNull = true,
    Values = seedList,
    Value = {},
    Callback = function(values)
        getgenv().selectedSeeds = values
    end
})

ifBuyDropdown = MainSection:Dropdown({
    Title = "If Buy Seeds",
    Multi = true,
    AllowNull = true,
    Values = seedList,
    Value = {},
    Callback = function(values)
        getgenv().ifBuySeeds = values
    end
})

local UpgradeSection = Tabs.AutoBuy:Section({
    Title = "Auto Buy Upgrade",
    Box = true,
    BoxBorder = true,
    Opened = false,
})

local function getUpgradePrice(plot, signName, upgradeType)
    local sign = plot:FindFirstChild(signName)
    if not sign then return math.huge end
    
    local screen = sign:FindFirstChild("Screen")
    if not screen then return math.huge end
    
    local sGui = screen:FindFirstChild("SurfaceGui")
    if not sGui then return math.huge end
    
    local uType = sGui:FindFirstChild(upgradeType)
    if not uType then return math.huge end
    
    local btn = uType:FindFirstChild("Btn")
    if not btn then return math.huge end
    
    local txt = btn:FindFirstChild("Txt")
    if not txt or not txt:IsA("TextLabel") then return math.huge end
    
    if string.lower(txt.Text) == "max" then return math.huge end
    return parseNumberString(txt.Text)
end

getgenv().UpgradeToggles = {}

local function setupAutoUpgrade(section, title, toggleKey, signName, guiElement, actionCodeFunc)
    section:Toggle({
        Title = title,
        Value = false,
        Callback = function(state)
            getgenv().UpgradeToggles[toggleKey] = state
            if state then
                task.spawn(function()
                    while getgenv().UpgradeToggles[toggleKey] do
                        local ok, err = pcall(function()
                            local myPlot = getMyPlot()
                            if myPlot then
                                local price = getUpgradePrice(myPlot, signName, guiElement)
                                local cash = getPlayerCash()
                                
                                if cash >= price then
                                    actionCodeFunc()
                                    task.wait(0.5)
                                end
                            end
                        end)
                        if not ok then print("[AutoUpgrade] Error:", err) end
                        task.wait(1)
                    end
                end)
            end
        end
    })
end

setupAutoUpgrade(UpgradeSection, "Auto Buy Expand", "Expand", "ExpandSign", "Expand", function()
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UpgradeFarm"):InvokeServer()
end)

setupAutoUpgrade(UpgradeSection, "Auto Buy Sprinkler Power", "SprinklerPower", "PlotUpgradeSign", "SprinklerPower", function()
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PlotUpgradeTransaction"):InvokeServer("ExtraPower", "Floor1")
end)

setupAutoUpgrade(UpgradeSection, "Auto Buy Saw Yield", "SawYield", "PlotUpgradeSign", "SawYield", function()
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PlotUpgradeTransaction"):InvokeServer("ExtraYield", "Floor1")
end)

setupAutoUpgrade(UpgradeSection, "Auto Buy Sprinkler Range", "SprinklerRange", "PlotUpgradeSign", "SprinklerRange", function()
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PlotUpgradeTransaction"):InvokeServer("ExtraSprinklerRange", "Floor1")
end)

setupAutoUpgrade(UpgradeSection, "Auto Buy Saw Range", "SawRange", "PlotUpgradeSign", "SawRange", function()
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PlotUpgradeTransaction"):InvokeServer("ExtraSawRange", "Floor1")
end)

local ReRollSection = Tabs.AutoBuy:Section({
    Title = "Auto Upgrade ReRoll",
    Box = true,
    BoxBorder = true,
    Opened = false,
})

setupAutoUpgrade(ReRollSection, "Auto Buy Seed Luck", "SeedLuck", "UpgradeSign", "SeedLuck", function()
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UpgradeSeedLuck"):InvokeServer()
end)

setupAutoUpgrade(ReRollSection, "Auto Buy Seed Roll", "SeedRoll", "UpgradeSign", "SeedRolls", function()
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UpgradeSeedRolls"):InvokeServer()
end)

local AutoBuyGearSection = Tabs.AutoBuy:Section({
    Title = "Auto Buy Gear",
    Box = true,
    BoxBorder = true,
    Opened = false,
})

local function getGearsList()
    local gl = {}
    local gd = {}
    
    local player = game:GetService("Players").LocalPlayer
    local gui = player:FindFirstChild("PlayerGui")
    if not gui then return gl, gd end
    
    local sf = gui:FindFirstChild("MainUI") and gui.MainUI:FindFirstChild("Menus") 
        and gui.MainUI.Menus:FindFirstChild("GearShopFrame")
        and gui.MainUI.Menus.GearShopFrame:FindFirstChild("ScrollingFrame")
        
    if not sf then return gl, gd end
    
    for _, child in ipairs(sf:GetChildren()) do
        local gName = child:FindFirstChild("GearName")
        local costLbl = child:FindFirstChild("Cost")
        
        if gName and gName:IsA("TextLabel") and costLbl and costLbl:IsA("TextLabel") then
            local order = child:IsA("GuiObject") and child.LayoutOrder or 0
            if child:FindFirstChild("LayoutOrder") and child.LayoutOrder:IsA("IntValue") then
                order = child.LayoutOrder.Value
            end
            table.insert(gd, {
                Name = gName.Text,
                CostText = costLbl.Text,
                CostNum = parseNumberString(costLbl.Text),
                Order = order,
                ObjName = child.Name,
                Obj = child
            })
        end
    end
    
    table.sort(gd, function(a, b) return a.Order < b.Order end)
    for _, g in ipairs(gd) do
        table.insert(gl, g.CostText .. " " .. g.Name)
    end
    return gl, gd
end

local GearDropdown
getgenv().selectedGearNames = {}
local gearList, gearData = getGearsList()

AutoBuyGearSection:Button({
    Title = "Refresh Gear List",
    Callback = function()
        gearList, gearData = getGearsList()
        if GearDropdown and GearDropdown.Refresh then
            pcall(function() GearDropdown:Refresh(gearList) end)
        end
    end
})

GearDropdown = AutoBuyGearSection:Dropdown({
    Title = "Select Gear",
    Multi = true,
    AllowNull = true,
    Values = gearList,
    Value = {},
    Callback = function(values)
        getgenv().selectedGearNames = values
    end
})

AutoBuyGearSection:Toggle({
    Title = "Auto Buy Gear",
    Value = false,
    Callback = function(state)
        getgenv().AutoBuyGear = state
        if state then
            task.spawn(function()
                while getgenv().AutoBuyGear do
                    local ok, err = pcall(function()
                        if type(getgenv().selectedGearNames) ~= "table" then return end
                        
                        for _, currentGearName in ipairs(getgenv().selectedGearNames) do
                            local targetObjName = nil
                            for _, g in ipairs(gearData) do
                                if (g.CostText .. " " .. g.Name) == currentGearName then
                                    targetObjName = g.ObjName
                                    break
                                end
                            end
                            
                            if targetObjName then
                                local player = game:GetService("Players").LocalPlayer
                                local sf = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("MainUI") 
                                    and player.PlayerGui.MainUI:FindFirstChild("Menus") 
                                    and player.PlayerGui.MainUI.Menus:FindFirstChild("GearShopFrame")
                                    and player.PlayerGui.MainUI.Menus.GearShopFrame:FindFirstChild("ScrollingFrame")
                                    
                                if sf then
                                    local child = sf:FindFirstChild(targetObjName)
                                    if child then
                                        local costLbl = child:FindFirstChild("Cost")
                                        local gearImg = child:FindFirstChild("GearImage")
                                        local rarityLbl = gearImg and gearImg:FindFirstChild("Rarity")
                                        
                                        if costLbl and costLbl:IsA("TextLabel") and rarityLbl and rarityLbl:IsA("TextLabel") then
                                            local isStocked = false
                                            local stockNum = string.match(rarityLbl.Text, "Stock:%s*(%d+)")
                                            if stockNum and tonumber(stockNum) > 0 then
                                                isStocked = true
                                            end
                                            
                                            local cost = parseNumberString(costLbl.Text)
                                            local cash = getPlayerCash()
                                            
                                            if isStocked and cash >= cost then
                                                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Gear"):WaitForChild("Transaction"):InvokeServer(targetObjName)
                                                task.wait(1)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    if not ok then print("[AutoBuyGear] Error:", err) end
                    task.wait(1)
                end
            end)
        end
    end
})

local EventsHoneySection = Tabs.Events:Section({
    Title = "Auto Farm",
    Box = true,
    BoxBorder = true,
    Opened = true,
})

EventsHoneySection:Toggle({
    Title = "Auto Farm Honey",
    Value = false,
    Callback = function(state)
        getgenv().AutoFarmHoney = state
        if state then
            task.spawn(function()
                while getgenv().AutoFarmHoney do
                    local ok, err = pcall(function()
                        local player = game:GetService("Players").LocalPlayer
                        local char = player.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        if not root then return end
                        
                        local qb = workspace:FindFirstChild("InteractiveEvents") 
                            and workspace.InteractiveEvents:FindFirstChild("QueenBee")
                        local honeycombs = qb and qb:FindFirstChild("RuntimeHoneycombs")
                        
                        if honeycombs then
                            for _, child in ipairs(honeycombs:GetChildren()) do
                                if not getgenv().AutoFarmHoney then break end
                                local hc = child:FindFirstChild("Honeycomb")
                                if hc then
                                    local prompt = hc:FindFirstChild("CollectPrompt")
                                    if prompt and prompt.Enabled then
                                        root.CFrame = hc.CFrame + Vector3.new(0, 3, 0)
                                        task.wait(0.2)
                                        if prompt and prompt.Enabled and fireproximityprompt then
                                            fireproximityprompt(prompt)
                                        end
                                        task.wait(0.5)
                                    end
                                end
                            end
                        end
                    end)
                    if not ok then print("[AutoFarmHoney] Error:", err) end
                    task.wait(0.5)
                end
            end)
        end
    end
})

-- ══════════════════════════════════════════
--              LOAD OTHERS.LUA
-- ══════════════════════════════════════════
task.spawn(function()
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
end)

WindUI:Notify({
    Title = "Prime X Hub",
    Content = "Script loaded successfully!",
    Duration = 5
})

