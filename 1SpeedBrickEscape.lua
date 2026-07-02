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
    Shop = Window:Tab({ Title = "Shop", Icon = "solar:cart-large-2-bold" }),
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

local VirtualInputManager = cloneref(game:GetService("VirtualInputManager"))
local GuiService = cloneref(game:GetService("GuiService"))
local UIS = cloneref(game:GetService("UserInputService"))

local function simulateClick(button)
    if not button then return end
    if UIS.TouchEnabled and not UIS.MouseEnabled then
        if button.AbsolutePosition then
            local x = button.AbsolutePosition.X + (button.AbsoluteSize.X / 2)
            local y = button.AbsolutePosition.Y + (button.AbsoluteSize.Y / 2) + GuiService:GetGuiInset().Y
            local mobileTouchId = 55555
            VirtualInputManager:SendTouchEvent(mobileTouchId, 0, x, y)
            task.wait(0.02)
            VirtualInputManager:SendTouchEvent(mobileTouchId, 2, x, y)
        end
    else
        if button.AbsolutePosition then
            local x = button.AbsolutePosition.X + (button.AbsoluteSize.X / 2)
            local y = button.AbsolutePosition.Y + (button.AbsoluteSize.Y / 2) + GuiService:GetGuiInset().Y
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1) -- Left Click Down
            task.wait(0.02)
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1) -- Left Click Up
        end
    end
end

-- ══════════════════════════════════════════
--              MAIN TAB
-- ══════════════════════════════════════════
Tabs.Main:Paragraph({
    Title = "Notice",
    Desc = "Stage 18 Works After (Game) Update\nYou can try if E109 Shows mean Stage18 Is Still not updated"
})

local savedVictoryCFrames = {}

local FarmSection = Tabs.Main:Section({
    Title = "Auto Farm",
    Box = true,
    BoxBorder = true,
    Expandable = true,
    Opened = true
})

local stageList = {}
local selectedStages = {}

local function scanStages()
    local stagesFolder = workspace:FindFirstChild("_____Stages_____")
    if not stagesFolder then return end

    local rawStages = {}
    for _, child in ipairs(stagesFolder:GetChildren()) do
        local numStr = string.match(child.Name, "Stage%s*(%d+)")
        if numStr then
            table.insert(rawStages, {
                Name = child.Name,
                Num = tonumber(numStr)
            })
        end
    end
    
    table.sort(rawStages, function(a, b)
        return a.Num < b.Num
    end)
    
    stageList = {}
    for _, s in ipairs(rawStages) do
        table.insert(stageList, s.Name)
    end
    
    if #stageList == 0 then
        table.insert(stageList, "Stage 1")
    end
end

scanStages()
if #selectedStages == 0 and #stageList > 0 then
    selectedStages = {stageList[1]}
end

_G.AutoFarmWinsBrick = false
FarmSection:Toggle({
    Title = "Auto Farm Wins",
    Value = false,
    Callback = function(Value)
        _G.AutoFarmWinsBrick = Value
        if Value then
            print("[Auto Farm] Started")
            task.spawn(function()
                local currentStageIndex = 1
                while _G.AutoFarmWinsBrick do
                    local ok, err = pcall(function()
                        local lp = game:GetService("Players").LocalPlayer
                        local char = lp.Character
                        if not char then print("[Auto Farm] Character missing") return end
                        
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if not hrp then print("[Auto Farm] HumanoidRootPart missing") return end

                        local stagesFolder = workspace:FindFirstChild("_____Stages_____")
                        if not stagesFolder then print("[Auto Farm] _____Stages_____ folder not found") return end

                        if not selectedStages or type(selectedStages) ~= "table" or #selectedStages == 0 then
                            print("[Auto Farm] No stages selected")
                            return
                        end

                        if currentStageIndex > #selectedStages then
                            currentStageIndex = 1
                        end

                        local targetStageName = selectedStages[currentStageIndex]
                        local targetStage = stagesFolder:FindFirstChild(targetStageName)
                        if not targetStage then print("[Auto Farm] Target Stage not found: " .. tostring(targetStageName)) return end

                        local endFolder = targetStage:FindFirstChild("End")
                        if not endFolder then print("[Auto Farm] End folder not found in " .. tostring(targetStageName)) return end

                        local claimWin = endFolder:FindFirstChild("ClaimWin")
                        if not claimWin then print("[Auto Farm] ClaimWin not found in " .. tostring(targetStageName)) return end

                        local victoryPart = claimWin:FindFirstChild("VictoryPart")
                        
                        if victoryPart then
                            savedVictoryCFrames[targetStageName] = victoryPart.CFrame
                            print("[Auto Farm] Found and saved VictoryPart CFrame from " .. tostring(targetStageName))
                        else
                            print("[Auto Farm] VictoryPart not found in " .. tostring(targetStageName))
                        end

                        if savedVictoryCFrames[targetStageName] then
                            print("[Auto Farm] Teleporting to VictoryPart")
                            hrp.CFrame = savedVictoryCFrames[targetStageName]
                            task.wait(0.1)
                            if _G.AutoFarmWinsBrick then
                                print("[Auto Farm] Teleporting 10 studs above VictoryPart")
                                hrp.CFrame = savedVictoryCFrames[targetStageName] + Vector3.new(0, 10, 0)
                            end
                            currentStageIndex = currentStageIndex + 1
                        else
                            print("[Auto Farm] Teleporting to ClaimWin to load VictoryPart")
                            if claimWin:IsA("Model") then
                                hrp.CFrame = claimWin:GetPivot()
                            elseif claimWin:IsA("BasePart") then
                                hrp.CFrame = claimWin.CFrame
                            else
                                local anyPart = claimWin:FindFirstChildWhichIsA("BasePart", true)
                                if anyPart then
                                    hrp.CFrame = anyPart.CFrame
                                else
                                    print("[Auto Farm] Failed to find any part in ClaimWin to teleport to")
                                end
                            end
                        end
                    end)
                    if not ok then
                        print("[Auto Farm] ERROR:", err)
                    end
                    task.wait(0.1)
                end
                print("[Auto Farm] Stopped")
            end)
        end
    end
})

local StageDropdown
StageDropdown = FarmSection:Dropdown({
    Title = "Select Stages",
    Multi = true,
    Values = stageList,
    Value = selectedStages,
    Callback = function(Value)
        local parsed = {}
        if type(Value) == "table" then
            for k, v in pairs(Value) do
                if type(k) == "number" then
                    table.insert(parsed, v)
                elseif v == true then
                    table.insert(parsed, k)
                end
            end
        elseif type(Value) == "string" then
            table.insert(parsed, Value)
        end
        selectedStages = parsed
        savedVictoryCFrames = {}
    end
})

FarmSection:Button({
    Title = "Refresh Stages",
    Callback = function()
        scanStages()
        if StageDropdown and StageDropdown.Refresh then
            StageDropdown:Refresh(stageList)
        end
    end
})

_G.AutoRebirthBrick = false
FarmSection:Toggle({
    Title = "Auto Rebirth",
    Value = false,
    Callback = function(Value)
        _G.AutoRebirthBrick = Value
        if Value then
            task.spawn(function()
                while _G.AutoRebirthBrick do
                    pcall(function()
                        local lp = game:GetService("Players").LocalPlayer
                        local frames = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("MainUI") and lp.PlayerGui.MainUI:FindFirstChild("Frames")
                        local rebirth = frames and frames:FindFirstChild("Rebirth")
                        local bar = rebirth and rebirth:FindFirstChild("Progress") and rebirth.Progress:FindFirstChild("CanvasGroup") and rebirth.Progress.CanvasGroup:FindFirstChild("Bar")
                        
                        if bar and bar.Size.X.Scale >= 1 and bar.Size.Y.Scale >= 1 then
                            local remote = game:GetService("ReplicatedStorage"):FindFirstChild("BrickRebirthRequest")
                            if remote then
                                remote:FireServer()
                            end
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    end
})

local EggSection = Tabs.Main:Section({
    Title = "Eggs",
    Box = true,
    BoxBorder = true,
    Expandable = true,
    Opened = true
})

local eggList = {"No eggs found"}
local eggDataMap = {}

local function scanEggs()
    local eggsFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Lobby") and workspace.Map.Lobby:FindFirstChild("Essential") and workspace.Map.Lobby.Essential:FindFirstChild("EggsArea") and workspace.Map.Lobby.Essential.EggsArea:FindFirstChild("Eggs")
    if not eggsFolder then return end

    local rawEggs = {}
    for _, folder in ipairs(eggsFolder:GetChildren()) do
        if string.match(folder.Name, "^Hatching") then
            local amtLabel = folder:FindFirstChild("Billboard") and folder.Billboard:FindFirstChild("BillboardGui") and folder.Billboard.BillboardGui:FindFirstChild("CashPrice") and folder.Billboard.BillboardGui.CashPrice:FindFirstChild("Amt")
            local priceStr = amtLabel and amtLabel.Text or "0"
            local priceNum = NumberConverter and NumberConverter.Parse(priceStr) or 0
            
            local eggMesh = folder:FindFirstChildWhichIsA("MeshPart")
            if eggMesh then
                local rawName = eggMesh.Name
                local eggType = string.gsub(rawName, "Egg$", "")
                local displayName = rawName
                
                if rawName == "CrystalEgg" then
                    displayName = "Meka Egg"
                end
                
                local ddName = displayName .. " (" .. priceStr .. ")"
                
                table.insert(rawEggs, {
                    Folder = folder,
                    RawName = rawName,
                    EggType = eggType,
                    PriceNum = priceNum,
                    DropdownName = ddName
                })
            end
        end
    end
    
    table.sort(rawEggs, function(a, b)
        return a.PriceNum < b.PriceNum
    end)
    
    eggList = {}
    eggDataMap = {}
    for _, e in ipairs(rawEggs) do
        table.insert(eggList, e.DropdownName)
        eggDataMap[e.DropdownName] = e
    end
    
    if #eggList == 0 then
        table.insert(eggList, "No eggs found")
    end
end

scanEggs()

local selectedEggDD = eggList[1] or "No eggs found"
local EggDropdown

_G.AutoEggHatch = false
EggSection:Toggle({
    Title = "Auto Hatch Egg",
    Value = false,
    Callback = function(Value)
        _G.AutoEggHatch = Value
        if Value then
            task.spawn(function()
                while _G.AutoEggHatch do
                    local hatched = false
                    pcall(function()
                        local lp = game:GetService("Players").LocalPlayer
                        local frames = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("MainUI") and lp.PlayerGui.MainUI:FindFirstChild("Frames")
                        local pets = frames and frames:FindFirstChild("Pets")
                        local contentFrame = pets and pets:FindFirstChild("ContentFrame")
                        local bar = contentFrame and contentFrame:FindFirstChild("Bar")
                        local bot = bar and bar:FindFirstChild("Bot")
                        local two = bot and bot:FindFirstChild("2")
                        local yeat = two and two:FindFirstChild("Yeat")
                        
                        local isFull = false
                        if yeat and yeat:IsA("TextLabel") then
                            local text = yeat.Text
                            local current, max = string.match(text, "(%d+)/(%d+)")
                            if current and max then
                                if tonumber(current) >= tonumber(max) then
                                    isFull = true
                                end
                            end
                        end
                        
                        if not isFull and selectedEggDD and eggDataMap[selectedEggDD] then
                            local data = eggDataMap[selectedEggDD]
                            
                            local guiWins = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("MainUI") and lp.PlayerGui.MainUI:FindFirstChild("Buttons") and lp.PlayerGui.MainUI.Buttons:FindFirstChild("Left") and lp.PlayerGui.MainUI.Buttons.Left:FindFirstChild("Wins") and lp.PlayerGui.MainUI.Buttons.Left.Wins:FindFirstChild("VictoryLabel")
                            
                            local myWins = 0
                            if guiWins and guiWins:IsA("TextLabel") then
                                myWins = NumberConverter and NumberConverter.Parse(guiWins.Text) or 0
                            end
                            
                            if myWins >= data.PriceNum then
                                local remote = game:GetService("ReplicatedStorage"):FindFirstChild("PetsHatchRequest")
                                if remote then
                                    if data.RawName == "CrystalEgg" then
                                        remote:FireServer("Crystal", data.Folder, false)
                                        task.wait(0.1)
                                        remote:FireServer("Zoo", data.Folder, false)
                                        task.wait(0.1)
                                        remote:FireServer("Meka", data.Folder, false)
                                        task.wait(3)
                                        hatched = true
                                    else
                                        remote:FireServer(data.EggType, data.Folder, false)
                                        task.wait(2.7)
                                        hatched = true
                                    end
                                end
                            end
                        end
                    end)
                    if not hatched then
                        task.wait(0.5)
                    end
                end
            end)
        end
    end
})

EggDropdown = EggSection:Dropdown({
    Title = "Select Egg",
    Values = eggList,
    Value = selectedEggDD,
    Callback = function(Value)
        selectedEggDD = Value
    end
})

EggSection:Button({
    Title = "Refresh Eggs",
    Callback = function()
        scanEggs()
        if EggDropdown and EggDropdown.Refresh then
            EggDropdown:Refresh(eggList)
        end
    end
})

_G.AutoEquipBest = false
EggSection:Toggle({
    Title = "Auto Equip Best",
    Value = false,
    Callback = function(Value)
        _G.AutoEquipBest = Value
        if Value then
            task.spawn(function()
                while _G.AutoEquipBest do
                    pcall(function()
                        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("PetsEquipBest")
                        if remote then
                            remote:FireServer()
                        end
                    end)
                    task.wait(5)
                end
            end)
        end
    end
})

local UpgradeSection = Tabs.Shop:Section({
    Title = "Buy & Upgrade",
    Box = true,
    BoxBorder = true,
    Expandable = true,
    Opened = true
})

_G.AutoEquipBestAccessory = false
UpgradeSection:Toggle({
    Title = "Auto Equip Best Accessory",
    Value = false,
    Callback = function(Value)
        _G.AutoEquipBestAccessory = Value
        if Value then
            task.spawn(function()
                while _G.AutoEquipBestAccessory do
                    pcall(function()
                        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("AccessoriesEquipBest")
                        if remote then
                            remote:FireServer()
                        end
                    end)
                    task.wait(5)
                end
            end)
        end
    end
})

local accessoryList = {"No accessories found"}
local accessoryDataMap = {}
local selectedAccessories = {}

local function scanAccessories()
    local lp = game:GetService("Players").LocalPlayer
    local frames = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("MainUI") and lp.PlayerGui.MainUI:FindFirstChild("Frames")
    local accessoryShop = frames and frames:FindFirstChild("AccessoryShop")
    local scrollingFrame = accessoryShop and accessoryShop:FindFirstChild("ScrollingFrame")
    
    if not scrollingFrame then return false end
    
    local rawAcc = {}
    for _, child in ipairs(scrollingFrame:GetChildren()) do
        if string.match(child.Name, "^Slot_") then
            local nameLabel = child:FindFirstChild("NameLabel")
            local stockLabel = child:FindFirstChild("StockLabel")
            local purchaseBtn = child:FindFirstChild("RegularPurchaseButton")
            local priceLabel = purchaseBtn and purchaseBtn:FindFirstChild("CanvasGroup") and purchaseBtn.CanvasGroup:FindFirstChild("TextLabel")
            
            if nameLabel and nameLabel:IsA("TextLabel") and priceLabel and priceLabel:IsA("TextLabel") then
                local accName = nameLabel.Text
                local priceText = priceLabel.Text
                local priceNum = NumberConverter and NumberConverter.Parse(priceText) or 0
                local ddName = child.Name .. " (" .. accName .. ")"
                
                table.insert(rawAcc, {
                    Slot = child,
                    RawName = accName,
                    PriceNum = priceNum,
                    PriceText = priceText,
                    DropdownName = ddName,
                    Button = purchaseBtn
                })
            end
        end
    end
    
    local newList = {}
    local newMap = {}
    for _, a in ipairs(rawAcc) do
        table.insert(newList, a.DropdownName)
        newMap[a.DropdownName] = a
    end
    
    if #newList == 0 then
        table.insert(newList, "No accessories found")
    end
    
    local changed = false
    if #newList ~= #accessoryList then
        changed = true
    else
        for i, v in ipairs(newList) do
            if accessoryList[i] ~= v then
                changed = true
                break
            end
        end
    end
    
    if changed then
        accessoryList = newList
        accessoryDataMap = newMap
        return true
    end
    return false
end

scanAccessories()

local AccessoryDropdown
AccessoryDropdown = UpgradeSection:Dropdown({
    Title = "Select Accessories",
    Multi = true,
    Values = accessoryList,
    Value = selectedAccessories,
    Callback = function(Value)
        local parsed = {}
        if type(Value) == "table" then
            for k, v in pairs(Value) do
                if type(k) == "number" then
                    table.insert(parsed, v)
                elseif v == true then
                    table.insert(parsed, k)
                end
            end
        elseif type(Value) == "string" then
            table.insert(parsed, Value)
        end
        selectedAccessories = parsed
    end
})

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            if scanAccessories() then
                if AccessoryDropdown and AccessoryDropdown.Refresh then
                    AccessoryDropdown:Refresh(accessoryList)
                end
            end
        end)
    end
end)

_G.AutoBuyAccessory = false
UpgradeSection:Toggle({
    Title = "Auto Buy Accessory",
    Value = false,
    Callback = function(Value)
        _G.AutoBuyAccessory = Value
        if Value then
            task.spawn(function()
                while _G.AutoBuyAccessory do
                    pcall(function()
                        local lp = game:GetService("Players").LocalPlayer
                        local guiWins = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("MainUI") and lp.PlayerGui.MainUI:FindFirstChild("Buttons") and lp.PlayerGui.MainUI.Buttons:FindFirstChild("Left") and lp.PlayerGui.MainUI.Buttons.Left:FindFirstChild("Wins") and lp.PlayerGui.MainUI.Buttons.Left.Wins:FindFirstChild("VictoryLabel")
                        
                        local myWins = 0
                        if guiWins and guiWins:IsA("TextLabel") then
                            myWins = NumberConverter and NumberConverter.Parse(guiWins.Text) or 0
                        end
                        
                        for _, selName in ipairs(selectedAccessories) do
                            if not _G.AutoBuyAccessory then break end
                            local data = accessoryDataMap[selName]
                            if data and data.Slot and data.Slot.Parent then
                                local stockLabel = data.Slot:FindFirstChild("StockLabel")
                                if stockLabel and stockLabel:IsA("TextLabel") then
                                    local stockText = stockLabel.Text
                                    local stockNum = tonumber(string.match(stockText, "%d+")) or 0
                                    
                                    if stockNum > 0 and myWins >= data.PriceNum then
                                        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("AccessoryShopBuyWins")
                                        if remote then
                                            local slotNumStr = string.match(data.Slot.Name, "Slot_(%d+)")
                                            local slotNum = tonumber(slotNumStr)
                                            if slotNum then
                                                remote:FireServer(slotNum)
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

_G.AutoBuyTrails = false
UpgradeSection:Toggle({
    Title = "Auto Buy Trails",
    Value = false,
    Callback = function(Value)
        _G.AutoBuyTrails = Value
        if Value then
            print("[AutoBuyTrails] Started")
            task.spawn(function()
                while _G.AutoBuyTrails do
                    local ok, err = pcall(function()
                        local lp = game:GetService("Players").LocalPlayer
                        local guiWins = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("MainUI") and lp.PlayerGui.MainUI:FindFirstChild("Buttons") and lp.PlayerGui.MainUI.Buttons:FindFirstChild("Left") and lp.PlayerGui.MainUI.Buttons.Left:FindFirstChild("Wins") and lp.PlayerGui.MainUI.Buttons.Left.Wins:FindFirstChild("VictoryLabel")
                        
                        local myWins = 0
                        if guiWins and guiWins:IsA("TextLabel") then
                            myWins = NumberConverter and NumberConverter.Parse(guiWins.Text) or 0
                        end

                        print("[AutoBuyTrails] Current Wins: " .. tostring(myWins))

                        local frames = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("MainUI") and lp.PlayerGui.MainUI:FindFirstChild("Frames")
                        local inventory = frames and frames:FindFirstChild("Inventory")
                        local trails = inventory and inventory:FindFirstChild("Trails")
                        local scrolling = trails and trails:FindFirstChild("Scrolling")

                        if scrolling then
                            local bestAffordableTrail = nil
                            local highestStatAffordable = -1
                            
                            local bestEquippedTrail = nil
                            local highestStatEquipped = -1

                            print("[AutoBuyTrails] Scanning trails...")
                            for _, child in ipairs(scrolling:GetChildren()) do
                                if string.match(child.Name, "^Trail%d+") then
                                    local container = child:FindFirstChild("Container")
                                    if container then
                                        local statLabel = container:FindFirstChild("SpeedBoost")
                                        local buttons = container:FindFirstChild("Buttons")
                                        
                                        if statLabel and statLabel:IsA("TextLabel") and buttons then
                                            local statText = statLabel.Text
                                            local cleanedStatStr = string.match(statText, "[%d%.]+")
                                            local statValue = tonumber(cleanedStatStr) or 0
                                            
                                            local equipBtn = buttons:FindFirstChild("Equip")
                                            local winsBtn = buttons:FindFirstChild("Wins")
                                            
                                            local isEquipped = false
                                            local isOwned = false
                                            local price = math.huge
                                            
                                            if equipBtn and equipBtn.Visible then
                                                isOwned = true
                                                local eText = ""
                                                local eLbl = equipBtn:FindFirstChildOfClass("TextLabel")
                                                if eLbl then eText = eLbl.Text elseif equipBtn:IsA("TextLabel") or equipBtn:IsA("TextButton") then eText = equipBtn.Text end
                                                
                                                if eText == "Equipped" then
                                                    isEquipped = true
                                                end
                                            elseif winsBtn and winsBtn.Visible then
                                                local pText = ""
                                                local pLbl = winsBtn:FindFirstChildOfClass("TextLabel")
                                                if pLbl then pText = pLbl.Text elseif winsBtn:IsA("TextLabel") or winsBtn:IsA("TextButton") then pText = winsBtn.Text end
                                                
                                                price = NumberConverter and NumberConverter.Parse(pText) or math.huge
                                            end
                                            
                                            print(string.format("[AutoBuyTrails] %s | Stat: %s | Owned: %s | Equipped: %s | Price: %s", child.Name, tostring(statValue), tostring(isOwned), tostring(isEquipped), tostring(price)))
                                            
                                            if isEquipped then
                                                if statValue > highestStatEquipped then
                                                    highestStatEquipped = statValue
                                                    bestEquippedTrail = child.Name
                                                end
                                            end
                                            
                                            if isOwned then
                                                if statValue > highestStatAffordable then
                                                    highestStatAffordable = statValue
                                                    bestAffordableTrail = {Name = child.Name, Action = "Equip"}
                                                end
                                            elseif price <= myWins then
                                                if statValue > highestStatAffordable then
                                                    highestStatAffordable = statValue
                                                    bestAffordableTrail = {Name = child.Name, Action = "Buy"}
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            
                            print("[AutoBuyTrails] Best Equipped Stat: " .. tostring(highestStatEquipped))
                            if bestAffordableTrail then
                                print("[AutoBuyTrails] Best Affordable Stat: " .. tostring(highestStatAffordable) .. " | Target: " .. bestAffordableTrail.Name .. " | Action: " .. bestAffordableTrail.Action)
                                
                                if highestStatAffordable > highestStatEquipped then
                                    if bestAffordableTrail.Action == "Equip" then
                                        print("[AutoBuyTrails] Equipping " .. bestAffordableTrail.Name)
                                        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("TrailsEquip")
                                        if remote then
                                            remote:FireServer(bestAffordableTrail.Name)
                                        end
                                    elseif bestAffordableTrail.Action == "Buy" then
                                        print("[AutoBuyTrails] Buying " .. bestAffordableTrail.Name)
                                        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("TrailsBuyWins")
                                        if remote then
                                            remote:FireServer(bestAffordableTrail.Name)
                                        end
                                    end
                                else
                                    print("[AutoBuyTrails] Already have the best trail equipped.")
                                end
                            else
                                print("[AutoBuyTrails] No affordable trail found better than equipped.")
                            end
                        else
                            print("[AutoBuyTrails] Scrolling frame not found.")
                        end
                    end)
                    if not ok then
                        print("[AutoBuyTrails] Error: ", err)
                    end
                    task.wait(2.5)
                end
                print("[AutoBuyTrails] Stopped")
            end)
        end
    end
})

WindUI:Notify({
    Title = "Prime X Hub",
    Content = "Script loaded successfully!",
    Duration = 5
})