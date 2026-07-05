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
local loadOthersOk, OthersFunc = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/wendigo5414-cmyk/FireballxArena/main/Others.lua", true))()
end)

local NumberConverter = nil
if loadOthersOk and type(OthersFunc) == "function" then
    pcall(function()
        NumberConverter = OthersFunc(Window, Tabs, WindUI)
    end)
end

if not NumberConverter then
    WindUI:Notify({
        Title = "Warning",
        Content = "Others.lua failed to load. Using fallback parser.",
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


local function CleanAndParse(rawText)
    if not rawText then return 0 end
    local txt = tostring(rawText)
    txt = string.gsub(txt, "<[^>]+>", "")
    
    txt = string.gsub(txt, "[Ww]ins", "")
    txt = string.gsub(txt, "[Ss]peed", "")
    txt = string.gsub(txt, "[Aa]mount", "")
    txt = string.gsub(txt, "[Pp]rice:?", "")
    txt = string.gsub(txt, "[Cc]ost:?", "")
    txt = string.gsub(txt, "[%+%$%s,:]", "")
    
    -- Remove leading 'x' or 'X' safely (e.g. x1.5M -> 1.5M) without breaking Sx
    txt = string.gsub(txt, "^[xX]+", "")
    
    if NumberConverter and NumberConverter.Parse then
        local ok, res = pcall(NumberConverter.Parse, txt)
        if ok and type(res) == "number" then 
            return res 
        end
    end
    
    local num = tonumber(txt)
    if num then return num end
    
    -- Fallback
    local s = string.lower(txt)
    local mult = 1
    if string.find(s, "k") then mult = 1000; s = string.gsub(s, "k", "")
    elseif string.find(s, "m") then mult = 1000000; s = string.gsub(s, "m", "")
    elseif string.find(s, "b") then mult = 1000000000; s = string.gsub(s, "b", "")
    elseif string.find(s, "t") then mult = 1000000000000; s = string.gsub(s, "t", "")
    end
    s = string.gsub(s, "[^%d%.]", "")
    local numFallback = tonumber(s)
    if numFallback then return numFallback * mult end
    return 0
end

local MainSection = Tabs.Main:Section({
    Title = "Farming",
    Box = true,
    BoxBorder = true,
    Expandable = true,
    Opened = true
})


_G.AutoRebirth = false
MainSection:Toggle({
    Title = "Auto Rebirth",
    Value = false,
    Callback = function(Value)
        _G.AutoRebirth = Value
        if Value then
            task.spawn(function()
                while _G.AutoRebirth do
                    pcall(function()
                        local lp = game:GetService("Players").LocalPlayer
                        local bar = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("Main") and lp.PlayerGui.Main:FindFirstChild("UIs") and lp.PlayerGui.Main.UIs:FindFirstChild("Rebirth") and lp.PlayerGui.Main.UIs.Rebirth:FindFirstChild("Level") and lp.PlayerGui.Main.UIs.Rebirth.Level:FindFirstChild("CanvasGroup") and lp.PlayerGui.Main.UIs.Rebirth.Level.CanvasGroup:FindFirstChild("Bar")
                        
                        if bar then
                            if bar.Size.X.Scale >= 1 and bar.Size.Y.Scale >= 1 then
                                local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                                if remotes then
                                    local rebirthRemote = remotes:FindFirstChild("Rebirth")
                                    if rebirthRemote then
                                        rebirthRemote:FireServer()
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

_G.AutoFarmWins = false
MainSection:Toggle({
    Title = "Auto Farm Wins + Steps",
    Value = false,
    Callback = function(Value)
        _G.AutoFarmWins = Value
        local vim = game:GetService("VirtualInputManager")
        if Value then
            task.spawn(function()
                while _G.AutoFarmWins do
                    pcall(function()
                        local lp = game:GetService("Players").LocalPlayer
                        -- FAKE MOVEMENT FOR STEPS
                        if lp and lp.Character and lp.Character:FindFirstChild("Humanoid") then
                            lp.Character.Humanoid:Move(Vector3.new(math.random(-1, 1), 0, math.random(-1, 1)), true)
                            vim:SendKeyEvent(true, Enum.KeyCode.W, false, game)
                        end

                        local bestButton = nil
                        
                        -- FIRST TRY NEW PATH
                        local w2Button = workspace:FindFirstChild("World2") and 
                                         workspace.World2:FindFirstChild("Stage9") and 
                                         workspace.World2.Stage9:FindFirstChild("FinalDestination") and 
                                         workspace.World2.Stage9.FinalDestination:FindFirstChild("NormalWin") and 
                                         workspace.World2.Stage9.FinalDestination.NormalWin:FindFirstChild("Button")
                        
                        if w2Button and w2Button:IsA("BasePart") then
                            bestButton = w2Button
                        else
                            local highestStageNum = -1
                            local map = workspace:FindFirstChild("Map")
                            if map then
                                for _, stage in ipairs(map:GetChildren()) do
                                    if string.match(stage.Name, "^Stage(%d+)$") then
                                        local num = tonumber(string.match(stage.Name, "^Stage(%d+)$"))
                                        if num and num > highestStageNum then
                                            local normalWin = stage:FindFirstChild("NormalWin")
                                            if normalWin then
                                                local button = normalWin:FindFirstChild("Button")
                                                if button and button:IsA("BasePart") then
                                                    highestStageNum = num
                                                    bestButton = button
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        
                        if bestButton then
                            if lp and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                                local hrp = lp.Character.HumanoidRootPart
                                hrp.CFrame = bestButton.CFrame * CFrame.new(math.random(-2, 2), math.random(1, 3), math.random(-2, 2))
                                hrp.Velocity = Vector3.new(0, -50, 0)
                                if type(firetouchinterest) == "function" then
                                    firetouchinterest(hrp, bestButton, 0)
                                    firetouchinterest(hrp, bestButton, 1)
                                end
                            end
                        end
                    end)
                    task.wait(0.01)
                end
                -- RELEASE W WHEN TURNED OFF
                vim:SendKeyEvent(false, Enum.KeyCode.W, false, game)
            end)
        else
            vim:SendKeyEvent(false, Enum.KeyCode.W, false, game)
        end
    end
})

local function findStatLabel(frame)
    local possibleNames = {"Wins", "Speed", "Amount", "Title", "Stat", "Multiplier", "TextLabel"}
    for _, name in ipairs(possibleNames) do
        local lbl = frame:FindFirstChild(name)
        if lbl and (lbl:IsA("TextLabel") or lbl:IsA("TextButton")) then
            return lbl
        end
    end
    
    -- Deep fallback search
    for _, child in ipairs(frame:GetDescendants()) do
        if child:IsA("TextLabel") then
            local n = string.lower(child.Name)
            if n ~= "price" and n ~= "buy" and n ~= "equip" and n ~= "unequip" and n ~= "title" then
                local txt = tostring(child.Text or child.ContentText or "")
                if string.match(txt, "%d") then
                    return child
                end
            end
        end
    end
    return nil
end

_G.AutoBuyAura = false
MainSection:Toggle({
    Title = "Auto Buy Aura",
    Value = false,
    Callback = function(Value)
        _G.AutoBuyAura = Value
        if Value then
            task.spawn(function()
                while _G.AutoBuyAura do
                    local success, err = pcall(function()
                        local lp = game:GetService("Players").LocalPlayer
                        local aurasHolder = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("Main") and lp.PlayerGui.Main:FindFirstChild("UIs") and lp.PlayerGui.Main.UIs:FindFirstChild("Backpack") and lp.PlayerGui.Main.UIs.Backpack:FindFirstChild("MainAuras") and lp.PlayerGui.Main.UIs.Backpack.MainAuras:FindFirstChild("Holder")
                        
                        if aurasHolder then
                            local playerWins = 0
                            if lp:FindFirstChild("leaderstats") and lp.leaderstats:FindFirstChild("\240\159\143\134 Wins") then
                                playerWins = CleanAndParse(lp.leaderstats["\240\159\143\134 Wins"].Value)
                            else
                                local mainGui = lp.PlayerGui:FindFirstChild("Main")
                                local winsLabel = mainGui and mainGui:FindFirstChild("Wins") and mainGui.Wins:FindFirstChild("Amount")
                                if winsLabel and winsLabel:IsA("TextLabel") then
                                    playerWins = CleanAndParse(winsLabel.Text)
                                else
                                    playerWins = math.huge
                                end
                            end

                            local bestAffordableStat = -1
                            local bestAffordableAura = nil
                            local bestAffordableAction = nil
                            local equippedStat = -1
                            
                            for _, auraFrame in ipairs(aurasHolder:GetChildren()) do
                                if auraFrame:IsA("GuiObject") then
                                    local statLabel = findStatLabel(auraFrame)
                                    
                                    local statNum = 0
                                    if statLabel then
                                        local statText = tostring(statLabel.Text or statLabel.ContentText or "0")
                                        statNum = CleanAndParse(statText)
                                        print("[Auto Buy Aura] Checking:", auraFrame.Name, "| Original Text:", statText, "| Parsed Stat:", statNum)
                                    else
                                        print("[Auto Buy Aura] Could not find Stat Label in", auraFrame.Name)
                                    end
                                    
                                    local buttons = auraFrame:FindFirstChild("Buttons")
                                    if buttons then
                                        local buyBtn = buttons:FindFirstChild("Buy")
                                        local equipBtn = buttons:FindFirstChild("Equip")
                                        local unequipBtn = buttons:FindFirstChild("Unequip")
                                        
                                        if unequipBtn and unequipBtn.Visible then
                                            equippedStat = statNum
                                            print("[Auto Buy Aura]", auraFrame.Name, "Status: EQUIPPED")
                                            if statNum > bestAffordableStat then
                                                bestAffordableStat = statNum
                                                bestAffordableAura = auraFrame.Name
                                                bestAffordableAction = "None"
                                            end
                                        elseif equipBtn and equipBtn.Visible then
                                            print("[Auto Buy Aura]", auraFrame.Name, "Status: OWNED (Unequipped)")
                                            if statNum > bestAffordableStat then
                                                bestAffordableStat = statNum
                                                bestAffordableAura = auraFrame.Name
                                                bestAffordableAction = "Equip"
                                            end
                                        elseif buyBtn and buyBtn.Visible then
                                            local priceNum = 0
                                            local rawPrice = "Unknown"
                                            local priceFrame = buyBtn:FindFirstChild("Price")
                                            if priceFrame then
                                                local priceLabel = priceFrame:FindFirstChild("Price")
                                                if priceLabel then
                                                    rawPrice = tostring(priceLabel.Text or priceLabel.ContentText or "")
                                                    priceNum = CleanAndParse(rawPrice)
                                                end
                                            end
                                            print("[Auto Buy Aura]", auraFrame.Name, "Status: UNOWNED | Cost:", priceNum, "| Raw text:", rawPrice)
                                            if priceNum and playerWins >= priceNum then
                                                if statNum > bestAffordableStat then
                                                    bestAffordableStat = statNum
                                                    bestAffordableAura = auraFrame.Name
                                                    bestAffordableAction = "Buy"
                                                end
                                            end
                                        end
                                    else
                                        print("[Auto Buy Aura] 'Buttons' folder not found in", auraFrame.Name)
                                    end
                                end
                            end
                            
                            if bestAffordableAura and bestAffordableAction ~= "None" then
                                if bestAffordableStat > equippedStat then
                                    local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                                    if remotes then
                                        if bestAffordableAction == "Buy" then
                                            local buyRemote = remotes:FindFirstChild("BuyAura") or remotes:FindFirstChild("BuyAuras")
                                            if buyRemote then
                                                print("[Auto Buy Aura] >>> Executing Buy for:", bestAffordableAura)
                                                buyRemote:FireServer(unpack({bestAffordableAura}))
                                            else
                                                print("[Auto Buy Aura] ERROR: Could not find BuyAura remote!")
                                            end
                                        elseif bestAffordableAction == "Equip" then
                                            local equipRemote = remotes:FindFirstChild("EquipAura") or remotes:FindFirstChild("EquipAuras")
                                            if equipRemote then
                                                print("[Auto Buy Aura] >>> Executing Equip for:", bestAffordableAura)
                                                equipRemote:FireServer(unpack({bestAffordableAura}))
                                            else
                                                print("[Auto Buy Aura] ERROR: Could not find EquipAura remote!")
                                            end
                                        end
                                    end
                                end
                            end
                        else
                            print("[Auto Buy Aura] MainAuras Holder NOT FOUND!")
                        end
                    end)
                    if not success then
                        print("[Auto Buy Aura] CRASH ERROR:", err)
                    end
                    task.wait(2.5)
                end
            end)
        end
    end
})

_G.AutoEquipBestAura = false
MainSection:Toggle({
    Title = "Auto Equip Best Aura",
    Value = false,
    Callback = function(Value)
        _G.AutoEquipBestAura = Value
        if Value then
            task.spawn(function()
                while _G.AutoEquipBestAura do
                    pcall(function()
                        local lp = game:GetService("Players").LocalPlayer
                        local aurasHolder = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("Main") and lp.PlayerGui.Main:FindFirstChild("UIs") and lp.PlayerGui.Main.UIs:FindFirstChild("Backpack") and lp.PlayerGui.Main.UIs.Backpack:FindFirstChild("MainAuras") and lp.PlayerGui.Main.UIs.Backpack.MainAuras:FindFirstChild("Holder")
                        
                        if aurasHolder then
                            local bestStat = -1
                            local bestAura = nil
                            local equippedStat = -1
                            
                            for _, auraFrame in ipairs(aurasHolder:GetChildren()) do
                                if auraFrame:IsA("GuiObject") then
                                    local statLabel = findStatLabel(auraFrame)
                                    local statNum = 0
                                    if statLabel then
                                        statNum = CleanAndParse(statLabel.Text or statLabel.ContentText or "0")
                                    end
                                    
                                    local buttons = auraFrame:FindFirstChild("Buttons")
                                    if buttons then
                                        local equipBtn = buttons:FindFirstChild("Equip")
                                        local unequipBtn = buttons:FindFirstChild("Unequip")
                                        
                                        if unequipBtn and unequipBtn.Visible then
                                            equippedStat = statNum
                                        elseif equipBtn and equipBtn.Visible then
                                            if statNum > bestStat then
                                                bestStat = statNum
                                                bestAura = auraFrame.Name
                                            end
                                        end
                                    end
                                end
                            end
                            
                            if bestAura and bestStat > equippedStat then
                                local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                                if remotes then
                                    local equipRemote = remotes:FindFirstChild("EquipAura") or remotes:FindFirstChild("EquipAuras")
                                    if equipRemote then
                                        equipRemote:FireServer(unpack({bestAura}))
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

_G.AutoBuyTrails = false
MainSection:Toggle({
    Title = "Auto Buy Trails",
    Value = false,
    Callback = function(Value)
        _G.AutoBuyTrails = Value
        if Value then
            task.spawn(function()
                while _G.AutoBuyTrails do
                    local success, err = pcall(function()
                        local lp = game:GetService("Players").LocalPlayer
                        local trailsHolder = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("Main") and lp.PlayerGui.Main:FindFirstChild("UIs") and lp.PlayerGui.Main.UIs:FindFirstChild("Backpack") and lp.PlayerGui.Main.UIs.Backpack:FindFirstChild("MainTrails") and lp.PlayerGui.Main.UIs.Backpack.MainTrails:FindFirstChild("Holder")
                        
                        if trailsHolder then
                            local playerWins = 0
                            if lp:FindFirstChild("leaderstats") and lp.leaderstats:FindFirstChild("\240\159\143\134 Wins") then
                                playerWins = CleanAndParse(lp.leaderstats["\240\159\143\134 Wins"].Value)
                            else
                                local mainGui = lp.PlayerGui:FindFirstChild("Main")
                                local winsLabel = mainGui and mainGui:FindFirstChild("Wins") and mainGui.Wins:FindFirstChild("Amount")
                                if winsLabel and winsLabel:IsA("TextLabel") then
                                    playerWins = CleanAndParse(winsLabel.Text)
                                else
                                    playerWins = math.huge
                                end
                            end

                            local bestAffordableStat = -1
                            local bestAffordableTrail = nil
                            local bestAffordableAction = nil
                            local equippedStat = -1
                            
                            for _, trailFrame in ipairs(trailsHolder:GetChildren()) do
                                if trailFrame:IsA("GuiObject") then
                                    local statLabel = findStatLabel(trailFrame)
                                    
                                    local statNum = 0
                                    if statLabel then
                                        local statText = tostring(statLabel.Text or statLabel.ContentText or "0")
                                        statNum = CleanAndParse(statText)
                                        print("[Auto Buy Trails] Checking:", trailFrame.Name, "| Original Text:", statText, "| Parsed Stat:", statNum)
                                    else
                                        print("[Auto Buy Trails] Could not find Stat Label in", trailFrame.Name)
                                    end
                                    
                                    local buttons = trailFrame:FindFirstChild("Buttons")
                                    if buttons then
                                        local buyBtn = buttons:FindFirstChild("Buy")
                                        local equipBtn = buttons:FindFirstChild("Equip")
                                        local unequipBtn = buttons:FindFirstChild("Unequip")
                                        
                                        if unequipBtn and unequipBtn.Visible then
                                            equippedStat = statNum
                                            print("[Auto Buy Trails]", trailFrame.Name, "Status: EQUIPPED")
                                            if statNum > bestAffordableStat then
                                                bestAffordableStat = statNum
                                                bestAffordableTrail = trailFrame.Name
                                                bestAffordableAction = "None"
                                            end
                                        elseif equipBtn and equipBtn.Visible then
                                            print("[Auto Buy Trails]", trailFrame.Name, "Status: OWNED (Unequipped)")
                                            if statNum > bestAffordableStat then
                                                bestAffordableStat = statNum
                                                bestAffordableTrail = trailFrame.Name
                                                bestAffordableAction = "Equip"
                                            end
                                        elseif buyBtn and buyBtn.Visible then
                                            local priceNum = 0
                                            local rawPrice = "Unknown"
                                            local priceFrame = buyBtn:FindFirstChild("Price")
                                            if priceFrame then
                                                local priceLabel = priceFrame:FindFirstChild("Price")
                                                if priceLabel then
                                                    rawPrice = tostring(priceLabel.Text or priceLabel.ContentText or "")
                                                    priceNum = CleanAndParse(rawPrice)
                                                end
                                            end
                                            print("[Auto Buy Trails]", trailFrame.Name, "Status: UNOWNED | Cost:", priceNum, "| Raw text:", rawPrice)
                                            if priceNum and playerWins >= priceNum then
                                                if statNum > bestAffordableStat then
                                                    bestAffordableStat = statNum
                                                    bestAffordableTrail = trailFrame.Name
                                                    bestAffordableAction = "Buy"
                                                end
                                            end
                                        end
                                    else
                                        print("[Auto Buy Trails] 'Buttons' folder not found in", trailFrame.Name)
                                    end
                                end
                            end
                            
                            if bestAffordableTrail and bestAffordableAction ~= "None" then
                                if bestAffordableStat > equippedStat then
                                    local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                                    if remotes then
                                        if bestAffordableAction == "Buy" then
                                            local buyRemote = remotes:FindFirstChild("BuyTrail") or remotes:FindFirstChild("BuyTrails")
                                            if buyRemote then
                                                print("[Auto Buy Trails] >>> Executing Buy for:", bestAffordableTrail)
                                                buyRemote:FireServer(unpack({bestAffordableTrail}))
                                            else
                                                print("[Auto Buy Trails] ERROR: Could not find BuyTrail remote!")
                                            end
                                        elseif bestAffordableAction == "Equip" then
                                            local equipRemote = remotes:FindFirstChild("EquipTrail") or remotes:FindFirstChild("EquipTrails")
                                            if equipRemote then
                                                print("[Auto Buy Trails] >>> Executing Equip for:", bestAffordableTrail)
                                                equipRemote:FireServer(unpack({bestAffordableTrail}))
                                            else
                                                print("[Auto Buy Trails] ERROR: Could not find EquipTrail remote!")
                                            end
                                        end
                                    end
                                end
                            end
                        else
                            print("[Auto Buy Trails] MainTrails Holder NOT FOUND!")
                        end
                    end)
                    if not success then
                        print("[Auto Buy Trails] CRASH ERROR:", err)
                    end
                    task.wait(2.5)
                end
            end)
        end
    end
})

_G.AutoEquipBestTrails = false
MainSection:Toggle({
    Title = "Auto Equip Best Trails",
    Value = false,
    Callback = function(Value)
        _G.AutoEquipBestTrails = Value
        if Value then
            task.spawn(function()
                while _G.AutoEquipBestTrails do
                    pcall(function()
                        local lp = game:GetService("Players").LocalPlayer
                        local trailsHolder = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("Main") and lp.PlayerGui.Main:FindFirstChild("UIs") and lp.PlayerGui.Main.UIs:FindFirstChild("Backpack") and lp.PlayerGui.Main.UIs.Backpack:FindFirstChild("MainTrails") and lp.PlayerGui.Main.UIs.Backpack.MainTrails:FindFirstChild("Holder")
                        
                        if trailsHolder then
                            local bestStat = -1
                            local bestTrail = nil
                            local equippedStat = -1
                            
                            for _, trailFrame in ipairs(trailsHolder:GetChildren()) do
                                if trailFrame:IsA("GuiObject") then
                                    local statLabel = findStatLabel(trailFrame)
                                    local statNum = 0
                                    if statLabel then
                                        statNum = CleanAndParse(statLabel.Text or statLabel.ContentText or "0")
                                    end
                                    
                                    local buttons = trailFrame:FindFirstChild("Buttons")
                                    if buttons then
                                        local equipBtn = buttons:FindFirstChild("Equip")
                                        local unequipBtn = buttons:FindFirstChild("Unequip")
                                        
                                        if unequipBtn and unequipBtn.Visible then
                                            equippedStat = statNum
                                        elseif equipBtn and equipBtn.Visible then
                                            if statNum > bestStat then
                                                bestStat = statNum
                                                bestTrail = trailFrame.Name
                                            end
                                        end
                                    end
                                end
                            end
                            
                            if bestTrail and bestStat > equippedStat then
                                local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                                if remotes then
                                    local equipRemote = remotes:FindFirstChild("EquipTrail") or remotes:FindFirstChild("EquipTrails")
                                    if equipRemote then
                                        equipRemote:FireServer(unpack({bestTrail}))
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

_G.AutoBuySteps = false

MainSection:Toggle({
    Title = "Auto Buy Steps",
    Value = false,
    Callback = function(Value)
        _G.AutoBuySteps = Value
        if Value then
            task.spawn(function()
                while _G.AutoBuySteps do
                    local success, err = pcall(function()
                        local lp = game:GetService("Players").LocalPlayer
                        local upgrades = workspace:FindFirstChild("Upgrades")
                        
                        if upgrades then
                            local bestStepPart = nil
                            local bestPrice = -1
                            local playerWins = 0

                            if lp:FindFirstChild("leaderstats") and lp.leaderstats:FindFirstChild("\240\159\143\134 Wins") then
                                playerWins = CleanAndParse(lp.leaderstats["\240\159\143\134 Wins"].Value)
                            else
                                local mainGui = lp.PlayerGui:FindFirstChild("Main")
                                local winsLabel = mainGui and mainGui:FindFirstChild("Wins") and mainGui.Wins:FindFirstChild("Amount")
                                if winsLabel and winsLabel:IsA("TextLabel") then
                                    playerWins = CleanAndParse(winsLabel.Text)
                                else
                                    playerWins = math.huge
                                end
                            end

                            for _, stepModel in ipairs(upgrades:GetChildren()) do
                                if stepModel:IsA("Model") or stepModel:IsA("Folder") then
                                    local button = nil
                                    for _, child in ipairs(stepModel:GetChildren()) do
                                        if string.match(child.Name, "^Button") and child:IsA("BasePart") then
                                            button = child
                                            break
                                        end
                                    end
                                    
                                    if button and button:FindFirstChildWhichIsA("TouchTransmitter") then
                                        local plusStep = stepModel:FindFirstChild("PlusStep")
                                        if plusStep then
                                            local billboard = plusStep:FindFirstChild("BillboardGui")
                                            if billboard then
                                                local requiredLabel = billboard:FindFirstChild("Required")
                                                if requiredLabel and requiredLabel:IsA("TextLabel") then
                                                    local reqText = tostring(requiredLabel.Text or requiredLabel.ContentText or "")
                                                    reqText = string.gsub(reqText, "[Rr]equired", "")
                                                    reqText = string.gsub(reqText, "[Rr]e%.%.%.", "")
                                                    
                                                    local reqNum = CleanAndParse(reqText)
                                                    
                                                    local r = math.floor(button.Color.R * 255 + 0.5)
                                                    local g = math.floor(button.Color.G * 255 + 0.5)
                                                    local b = math.floor(button.Color.B * 255 + 0.5)
                                                    
                                                    -- Color matching logic with tolerance
                                                    local isEquipped = (r <= 10 and g >= 245 and b <= 10)
                                                    local isOwned = (r <= 10 and g >= 245 and b >= 245)
                                                    local isNotOwned = (r >= 245 and g >= 245 and b <= 10)
                                                    
                                                    if isEquipped then
                                                        if reqNum > bestPrice then
                                                            bestPrice = reqNum
                                                            bestStepPart = button
                                                        end
                                                    elseif isOwned then
                                                        if reqNum > bestPrice then
                                                            bestPrice = reqNum
                                                            bestStepPart = button
                                                        end
                                                    elseif isNotOwned then
                                                        if reqNum > bestPrice and playerWins >= reqNum then
                                                            bestPrice = reqNum
                                                            bestStepPart = button
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end

                            if bestStepPart and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                                fireTouch(bestStepPart, lp.Character.HumanoidRootPart)
                            end
                        end
                    end)
                    if not success then
                        print("[Auto Buy Steps] Error:", err)
                    end
                    task.wait(2.5)
                end
            end)
        end
    end
})



_G.AutoEquipBestSteps = false
MainSection:Toggle({
    Title = "Auto Equip Best Steps",
    Value = false,
    Callback = function(Value)
        _G.AutoEquipBestSteps = Value
        if Value then
            task.spawn(function()
                while _G.AutoEquipBestSteps do
                    pcall(function()
                        local lp = game:GetService("Players").LocalPlayer
                        local upgrades = workspace:FindFirstChild("Upgrades")
                        
                        if upgrades then
                            local bestStepPart = nil
                            local bestStat = -1
                            local equippedStat = -1
                            
                            for _, stepModel in ipairs(upgrades:GetChildren()) do
                                if stepModel:IsA("Model") or stepModel:IsA("Folder") then
                                    local button = nil
                                    for _, child in ipairs(stepModel:GetChildren()) do
                                        if string.match(child.Name, "^Button") and child:IsA("BasePart") then
                                            button = child
                                            break
                                        end
                                    end
                                    
                                    if button and button:FindFirstChildWhichIsA("TouchTransmitter") then
                                        local plusStep = stepModel:FindFirstChild("PlusStep")
                                        if plusStep then
                                            local billboard = plusStep:FindFirstChild("BillboardGui")
                                            if billboard then
                                                local requiredLabel = billboard:FindFirstChild("Required")
                                                if requiredLabel and requiredLabel:IsA("TextLabel") then
                                                    local reqText = tostring(requiredLabel.Text or requiredLabel.ContentText or "")
                                                    reqText = string.gsub(reqText, "[Rr]equired", "")
                                                    reqText = string.gsub(reqText, "[Rr]e%.%.%.", "")
                                                    local reqNum = CleanAndParse(reqText)
                                                    
                                                    local r = math.floor(button.Color.R * 255 + 0.5)
                                                    local g = math.floor(button.Color.G * 255 + 0.5)
                                                    local b = math.floor(button.Color.B * 255 + 0.5)
                                                    
                                                    local isEquipped = (r <= 10 and g >= 245 and b <= 10)
                                                    local isOwned = (r <= 10 and g >= 245 and b >= 245)
                                                    
                                                    if isEquipped then
                                                        equippedStat = reqNum
                                                    elseif isOwned then
                                                        if reqNum > bestStat then
                                                            bestStat = reqNum
                                                            bestStepPart = button
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            
                            if bestStepPart and bestStat > equippedStat and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                                fireTouch(bestStepPart, lp.Character.HumanoidRootPart)
                            end
                        end
                    end)
                    task.wait(2.5)
                end
            end)
        end
    end
})

MainSection:Button({
    Title = "Remove Kill Parts",
    Callback = function()
        local count = 0
        local map = workspace:FindFirstChild("Map")
        if map then
            for _, stage in ipairs(map:GetChildren()) do
                if string.match(stage.Name, "^Stage") then
                    for _, obj in ipairs(stage:GetDescendants()) do
                        if obj.Name == "KillPart" then
                            -- If KillPart is a Part itself
                            local touch = obj:FindFirstChildWhichIsA("TouchTransmitter")
                            if touch then
                                touch:Destroy()
                                count = count + 1
                            end
                            
                            -- If KillPart is a Folder/Model containing parts
                            for _, child in ipairs(obj:GetDescendants()) do
                                if child:IsA("TouchTransmitter") then
                                    child:Destroy()
                                    count = count + 1
                                end
                            end
                        end
                    end
                end
            end
            WindUI:Notify({
                Title = "Success",
                Content = "Removed " .. tostring(count) .. " Kill Parts!",
                Duration = 3
            })
        end
    end
})

WindUI:Notify({
    Title = "Prime X Hub",
    Content = "Script loaded successfully!",
    Duration = 5
})
