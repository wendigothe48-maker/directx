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

-- ══════════════════════════════════════════
--              MAIN TAB
-- ══════════════════════════════════════════
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
                local lastCount = -1
                while _G.AutoEquipBest do
                    pcall(function()
                        local lp = game:GetService("Players").LocalPlayer
                        local frames = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("MainUI") and lp.PlayerGui.MainUI:FindFirstChild("Frames")
                        local pets = frames and frames:FindFirstChild("Pets")
                        local contentFrame = pets and pets:FindFirstChild("ContentFrame")
                        local main = contentFrame and contentFrame:FindFirstChild("Main")
                        local nine = main and main:FindFirstChild("9")
                        
                        if nine then
                            local currentCount = #nine:GetChildren()
                            if lastCount ~= -1 and currentCount ~= lastCount then
                                local remote = game:GetService("ReplicatedStorage"):FindFirstChild("PetsEquipBest")
                                if remote then
                                    remote:FireServer()
                                end
                            end
                            lastCount = currentCount
                        end
                    end)
                    task.wait(0.5)
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