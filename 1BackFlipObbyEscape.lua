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

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function getHighestGiveWinsFolder()
    local giveWins = workspace:FindFirstChild("GiveWins")
    if not giveWins then return nil end
    local highestNum = -1
    local highestFolder = nil
    for _, child in ipairs(giveWins:GetChildren()) do
        local num = tonumber(child.Name)
        if num and num > highestNum then
            highestNum = num
            highestFolder = child
        end
    end
    return highestFolder
end

local function getTop5GiveWinsFolders()
    local giveWins = workspace:FindFirstChild("GiveWins")
    if not giveWins then return {} end
    local folders = {}
    for _, child in ipairs(giveWins:GetChildren()) do
        local num = tonumber(child.Name)
        if num then table.insert(folders, {num = num, folder = child}) end
    end
    table.sort(folders, function(a, b) return a.num > b.num end)
    local topFolders = {}
    for i = 1, math.min(5, #folders) do
        table.insert(topFolders, folders[i].folder)
    end
    return topFolders
end

local parseWins = function(valStr)
    if type(valStr) ~= "string" then valStr = tostring(valStr) end
    local wVal = string.upper(valStr)
    wVal = string.gsub(wVal, "<[^>]+>", "")
    wVal = string.gsub(wVal, ",", "")
    wVal = string.gsub(wVal, "WINS", "")
    wVal = string.gsub(wVal, "REQUIRED", "")
    wVal = string.gsub(wVal, "%s+", "")
    
    local numVal, suffix = string.match(wVal, "([%d%.]+)([KMBT]?)")
    if numVal then
        local n = tonumber(numVal)
        if n then
            if suffix == "K" then n = n * 1000
            elseif suffix == "M" then n = n * 1000000
            elseif suffix == "B" then n = n * 1000000000
            elseif suffix == "T" then n = n * 1000000000000
            end
            return n
        end
    end
    
    return 0
end

local getMultiplier = function(text)
    local num = string.match(text, "x([%d%.]+)") or string.match(text, "([%d%.]+)")
    return tonumber(num) or 0
end

local function getSafeText(inst)
    if not inst then return "" end
    
    local txt = ""
    pcall(function()
        local textChild = inst:FindFirstChild("Text")
        if textChild and (textChild:IsA("TextLabel") or textChild:IsA("TextButton") or textChild:IsA("TextBox")) then
            txt = textChild.Text
        elseif inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
            txt = inst.Text 
        end
    end)
    
    if txt and type(txt) == "string" and txt ~= "" then 
        return string.upper(txt) 
    end
    
    for _, child in ipairs(inst:GetDescendants()) do
        local cs, ctxt = pcall(function() 
            if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                return (child.ContentText and child.ContentText ~= "") and child.ContentText or child.Text 
            end
            return child.Text 
        end)
        if cs and type(ctxt) == "string" and ctxt ~= "" then 
            local upperText = string.upper(ctxt)
            if string.match(upperText, "%d") then
                return upperText
            end
        end
    end
    return ""
end

local autoBuySettings = { Steps = false, Trails = false, Auras = false }

local AutoBuyGroup = Tabs.Main:Group({})
local AutoBuySection = AutoBuyGroup:Section({ 
    Title = "Auto Best Buy Shop",
    Box = true,
    BoxBorder = true,
    Opened = true
})

AutoBuySection:Toggle({
    Title = "Auto Buy Steps",
    Value = false,
    Callback = function(Value) autoBuySettings.Steps = Value end
})

AutoBuySection:Toggle({
    Title = "Auto Buy Trails",
    Value = false,
    Callback = function(Value) autoBuySettings.Trails = Value end
})

AutoBuySection:Toggle({
    Title = "Auto Buy Auras",
    Value = false,
    Callback = function(Value) autoBuySettings.Auras = Value end
})

task.spawn(function()
    while true do
        local acted = false
        pcall(function()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local winsObj = LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Wins")
            local currentWins = 0
            if winsObj then
                currentWins = parseWins(winsObj.Value)
            end

            if autoBuySettings.Steps or autoBuySettings.Trails or autoBuySettings.Auras then
                print("[Auto Buy Shop] Current Player Wins: " .. tostring(currentWins))
            end

            if autoBuySettings.Steps then
                local upgradeWins = workspace:FindFirstChild("UpgradeWins")
                if upgradeWins then
                    local highestActionablePart = nil
                    local bestAction = "NONE"
                    local bestCost = -1
                    
                    local i = 1
                    while true do
                        local buttonName = "Button" .. tostring(i)
                        local button = upgradeWins:FindFirstChild(buttonName)
                        if not button then break end
                        
                        local touchPart = button:FindFirstChild("Touch")
                        if not touchPart then break end
                        
                        local gui = touchPart:FindFirstChild("GUI")
                        if not gui then break end
                        
                        local winCostLabel = gui:FindFirstChild("WinCost")
                        if not winCostLabel or not winCostLabel:IsA("TextLabel") then break end
                        
                        local text = string.upper(winCostLabel.Text)
                        
                        if string.find(text, "0 WINS REQUIRED") then
                            -- Skip locked steps
                        elseif string.find(text, "EQUIPPED") then
                            highestActionablePart = nil
                            bestAction = "NONE"
                        elseif string.find(text, "OWNED") then
                            highestActionablePart = touchPart
                            bestAction = "EQUIP"
                        elseif string.find(text, "WINS REQUIRED") then
                            local cost = parseWins(text)
                            if cost > 0 and currentWins >= cost then
                                if cost > bestCost then
                                    bestCost = cost
                                    highestActionablePart = touchPart
                                    bestAction = "PURCHASE"
                                end
                            end
                        end
                        i = i + 1
                    end
                    
                    if highestActionablePart and bestAction ~= "NONE" then
                        local uis = game:GetService("UserInputService")
                        local isMobile = uis.TouchEnabled and not uis.MouseEnabled
                        if isMobile then
                            firetouchinterest(hrp, highestActionablePart, 0)
                            task.wait(0.01)
                            firetouchinterest(hrp, highestActionablePart, 1)
                        else
                            firetouchinterest(hrp, highestActionablePart, 0)
                        end
                        acted = true
                    end
                end
            end
            
            if acted then return end

            if autoBuySettings.Trails then
                local trailsGui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("GUI") and LocalPlayer.PlayerGui.GUI:FindFirstChild("Frames") and LocalPlayer.PlayerGui.GUI.Frames:FindFirstChild("Trails") and LocalPlayer.PlayerGui.GUI.Frames.Trails:FindFirstChild("Scrolling")
                
                if trailsGui then
                    local bestMultiplier = -1
                    local bestFrame = nil
                    local bestAction = "NONE"
                    local currentlyEquippedMul = -1

                    for _, frame in ipairs(trailsGui:GetChildren()) do
                        if frame:IsA("Frame") and frame:FindFirstChild("SpeedBoost") and frame:FindFirstChild("Buttons") then
                            local mult = getMultiplier(frame.SpeedBoost.Text)
                            local buttons = frame.Buttons
                            local winsBtn = buttons:FindFirstChild("Wins")
                            local isOwned = true
                            local cost = 0
                            
                            if winsBtn and winsBtn.Visible then
                                isOwned = false
                                local rawTxt = getSafeText(winsBtn)
                                cost = parseWins(rawTxt)
                                if cost == 0 then
                                    print("[Auto Buy Trails] Failed to extract raw text cost properly from " .. frame.Name .. " - Extracted: '" .. tostring(rawTxt) .. "'")
                                end
                            end
                            
                            local equipBtn = buttons:FindFirstChild("Equip") or buttons:FindFirstChild("EquipButton")
                            local isEquipped = false
                            if isOwned and equipBtn then
                                local etext = getSafeText(equipBtn)
                                if string.find(etext, "UNEQUIP") then
                                    isEquipped = true
                                    if mult > currentlyEquippedMul then
                                        currentlyEquippedMul = mult
                                    end
                                end
                            end

                            print("[Auto Buy Trails] Scanning " .. frame.Name .. " | Mult: x" .. tostring(mult) .. " | Cost: " .. tostring(cost) .. " | Owned: " .. tostring(isOwned) .. " | Equipped: " .. tostring(isEquipped))

                            if isOwned then
                                if not isEquipped and mult > bestMultiplier then
                                    bestMultiplier = mult
                                    bestFrame = frame
                                    bestAction = "EQUIP"
                                end
                            else
                                if cost > 0 and currentWins >= cost and mult > bestMultiplier then
                                    bestMultiplier = mult
                                    bestFrame = frame
                                    bestAction = "PURCHASE"
                                end
                            end
                        end
                    end
                    
                    if bestFrame and bestMultiplier > currentlyEquippedMul then
                        print("[Auto Buy Trails] Found Better Trail: " .. bestFrame.Name .. " | Action: " .. bestAction .. " | Target Mult: x" .. tostring(bestMultiplier) .. " vs Current: x" .. tostring(currentlyEquippedMul))
                        if bestAction == "PURCHASE" then
                            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("TrailAction"):FireServer("BuyWins", bestFrame.Name)
                            acted = true
                        elseif bestAction == "EQUIP" then
                            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("TrailAction"):FireServer("Equip", bestFrame.Name)
                            acted = true
                        end
                    else
                        print("[Auto Buy Trails] Nothing better to buy or equip.")
                    end
                end
            end

            if acted then return end

            if autoBuySettings.Auras then
                local carsGui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("GUI") and LocalPlayer.PlayerGui.GUI:FindFirstChild("Frames") and LocalPlayer.PlayerGui.GUI.Frames:FindFirstChild("Cars") and LocalPlayer.PlayerGui.GUI.Frames.Cars:FindFirstChild("Scrolling")
                
                if carsGui then
                    local bestMultiplier = -1
                    local bestFrame = nil
                    local bestAction = "NONE"
                    local currentlyEquippedMul = -1

                    for _, frame in ipairs(carsGui:GetChildren()) do
                        if frame:IsA("Frame") and frame:FindFirstChild("WinBoost") and frame:FindFirstChild("Buttons") then
                            local mult = getMultiplier(frame.WinBoost.Text)
                            local buttons = frame.Buttons
                            local winsBtn = buttons:FindFirstChild("BuyWins") or buttons:FindFirstChild("Wins")
                            local isOwned = true
                            local cost = 0
                            
                            if winsBtn and winsBtn.Visible then
                                isOwned = false
                                local rawTxt = getSafeText(winsBtn)
                                cost = parseWins(rawTxt)
                                if cost == 0 then
                                    print("[Auto Buy Auras] Failed to extract raw text cost properly from " .. frame.Name .. " - Extracted: '" .. tostring(rawTxt) .. "'")
                                end
                            end
                            
                            local equipBtn = buttons:FindFirstChild("EquipButton") or buttons:FindFirstChild("Equip")
                            local isEquipped = false
                            if isOwned and equipBtn then
                                local etext = getSafeText(equipBtn)
                                if string.find(etext, "UNEQUIP") then
                                    isEquipped = true
                                    if mult > currentlyEquippedMul then
                                        currentlyEquippedMul = mult
                                    end
                                end
                            end

                            print("[Auto Buy Auras] Scanning " .. frame.Name .. " | Mult: x" .. tostring(mult) .. " | Cost: " .. tostring(cost) .. " | Owned: " .. tostring(isOwned) .. " | Equipped: " .. tostring(isEquipped))

                            if isOwned then
                                if not isEquipped and mult > bestMultiplier then
                                    bestMultiplier = mult
                                    bestFrame = frame
                                    bestAction = "EQUIP"
                                end
                            else
                                if cost > 0 and currentWins >= cost and mult > bestMultiplier then
                                    bestMultiplier = mult
                                    bestFrame = frame
                                    bestAction = "PURCHASE"
                                end
                            end
                        end
                    end
                    
                    if bestFrame and bestMultiplier > currentlyEquippedMul then
                        print("[Auto Buy Auras] Found Better Aura: " .. bestFrame.Name .. " | Action: " .. bestAction .. " | Target Mult: x" .. tostring(bestMultiplier) .. " vs Current: x" .. tostring(currentlyEquippedMul))
                        if bestAction == "PURCHASE" then
                            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("CarAction"):FireServer("BuyWins", bestFrame.Name)
                            acted = true
                        elseif bestAction == "EQUIP" then
                            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("CarAction"):FireServer("Equip", bestFrame.Name)
                            acted = true
                        end
                    else
                        print("[Auto Buy Auras] Nothing better to buy or equip.")
                    end
                end
            end
        end)
        task.wait(2.5)
    end
end)

local autoFarmStepsEnabled = false
Tabs.Main:Toggle({
    Title = "Auto Farm Steps",
    Value = false,
    Callback = function(Value)
        autoFarmStepsEnabled = Value
        if Value then
            task.spawn(function()
                while autoFarmStepsEnabled do
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("AddSpeed"):FireServer()
                    end)
                    task.wait(0.05)
                end
            end)
        end
    end
})

local autoFarmHighestEnabled = false
Tabs.Main:Toggle({
    Title = "Auto Farm Highest",
    Value = false,
    Callback = function(Value)
        autoFarmHighestEnabled = Value
        if Value then
            task.spawn(function()
                while autoFarmHighestEnabled do
                    local s, e = pcall(function()
                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if not hrp then return end
                        
                        local topFolders = getTop5GiveWinsFolders()
                        if #topFolders == 0 then return end
                        
                        local spawnLocation = workspace:FindFirstChild("SpawnLocation")
                        if not spawnLocation then return end
                        
                        local spawnCFrame = spawnLocation.CFrame
                        local targetCFrame = CFrame.new(spawnCFrame.X + 10, spawnCFrame.Y - 10, spawnCFrame.Z)
                        
                        local isSet = true
                        for _, folder in ipairs(topFolders) do
                            local touchPart = folder:FindFirstChild("Touch")
                            if not touchPart or (touchPart.Position - targetCFrame.Position).Magnitude > 5 then
                                isSet = false
                                break
                            end
                        end
                        
                        if not isSet then
                            -- Setup
                            for _, folder in ipairs(topFolders) do
                                if not autoFarmHighestEnabled then return end
                                hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if not hrp then return end
                                
                                local touchPart = folder:FindFirstChild("Touch")
                                if touchPart and (touchPart.Position - targetCFrame.Position).Magnitude < 5 then
                                    continue
                                end
                                
                                if folder:IsA("Model") then
                                    hrp.CFrame = folder:GetPivot()
                                elseif folder:IsA("BasePart") then
                                    hrp.CFrame = folder.CFrame
                                end
                                
                                local waitTime = 0
                                while not folder:FindFirstChild("Touch") and waitTime < 3 and autoFarmHighestEnabled do
                                    task.wait(0.1)
                                    waitTime = waitTime + 0.1
                                    hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                    if hrp then
                                        if folder:IsA("Model") then
                                            hrp.CFrame = folder:GetPivot()
                                        elseif folder:IsA("BasePart") then
                                            hrp.CFrame = folder.CFrame
                                        end
                                    end
                                end
                                
                                touchPart = folder:FindFirstChild("Touch")
                                if touchPart then
                                    local t = 0
                                    while t < 2 and autoFarmHighestEnabled do
                                        touchPart.CFrame = targetCFrame
                                        if (touchPart.Position - targetCFrame.Position).Magnitude < 5 then
                                            break
                                        end
                                        task.wait(0.05)
                                        t = t + 0.05
                                    end
                                end
                            end
                            task.wait(0.2)
                        end
                        
                        -- Verification
                        isSet = true
                        for _, folder in ipairs(topFolders) do
                            local touchPart = folder:FindFirstChild("Touch")
                            if not touchPart or (touchPart.Position - targetCFrame.Position).Magnitude > 5 then
                                isSet = false
                                break
                            end
                        end
                        
                        if isSet and autoFarmHighestEnabled then
                            hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then hrp.CFrame = spawnCFrame end
                            
                            local uis = game:GetService("UserInputService")
                            local isMobile = uis.TouchEnabled and not uis.MouseEnabled
                            
                            while autoFarmHighestEnabled do
                                local currentTop = getTop5GiveWinsFolders()
                                if #currentTop == 0 or currentTop[1] ~= topFolders[1] then
                                    break
                                end
                                
                                local safe = true
                                for _, folder in ipairs(topFolders) do
                                    local touchPart = folder:FindFirstChild("Touch")
                                    if not touchPart or (touchPart.Position - targetCFrame.Position).Magnitude > 5 then
                                        safe = false
                                        break
                                    end
                                end
                                
                                if safe then
                                    hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                    if hrp then
                                        for _, folder in ipairs(topFolders) do
                                            local touchPart = folder:FindFirstChild("Touch")
                                            if touchPart then
                                                if isMobile then
                                                    firetouchinterest(hrp, touchPart, 0)
                                                    task.wait(0.01)
                                                    firetouchinterest(hrp, touchPart, 1)
                                                else
                                                    firetouchinterest(hrp, touchPart, 0)
                                                end
                                            end
                                        end
                                    end
                                else
                                    break
                                end
                                task.wait(0.01)
                            end
                        end
                    end)
                    task.wait()
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
                        local progress = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("GUI"):WaitForChild("Frames"):WaitForChild("Rebirth"):WaitForChild("Bar"):WaitForChild("Progress")
                        if progress.Size.X.Scale >= 1 then
                            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RequestRebirth"):InvokeServer()
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    end
})

local autoRemoveKillPartEnabled = false
Tabs.Main:Toggle({
    Title = "Auto Remove Kill Part",
    Value = false,
    Callback = function(Value)
        autoRemoveKillPartEnabled = Value
        if Value then
            task.spawn(function()
                while autoRemoveKillPartEnabled do
                    pcall(function()
                        local killPartFolder = workspace:FindFirstChild("KillPart")
                        if killPartFolder then
                            for _, child in ipairs(killPartFolder:GetChildren()) do
                                local touchInterest = child:FindFirstChild("TouchInterest")
                                if touchInterest then
                                    touchInterest:Destroy()
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

WindUI:Notify({
    Title = "Prime X Hub",
    Content = "Script loaded successfully!",
    Duration = 5
})
