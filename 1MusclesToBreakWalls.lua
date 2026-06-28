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

_G.YOffsetForTP = 0
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            local lp = game:GetService("Players").LocalPlayer
            local char = lp.Character
            if char then
                local totalY = 0
                local partsToMeasure = {"Head", "UpperTorso", "LowerTorso", "RightUpperLeg", "RightLowerLeg", "RightFoot", "Torso", "Right Leg"}
                for _, partName in ipairs(partsToMeasure) do
                    local part = char:FindFirstChild(partName)
                    if part and part:IsA("BasePart") then
                        totalY = totalY + part.Size.Y
                    end
                end
                
                local standardY = 5
                if char:FindFirstChild("UpperTorso") then
                    standardY = 5.86
                else
                    standardY = 5.2
                end
                
                if totalY > 0 then
                    _G.YOffsetForTP = math.max(0, (totalY - standardY) / 2)
                end
            end
        end)
    end
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

local stageOptions = {}
local stagesFolder = workspace:FindFirstChild("World1") and workspace.World1:FindFirstChild("Stages")

if stagesFolder then
    local stageList = {}
    for _, stage in ipairs(stagesFolder:GetChildren()) do
        if stage:IsA("Folder") or stage:IsA("Model") then
            local wallFolder = stage:FindFirstChild("WallFolder")
            if wallFolder then
                local wall1 = wallFolder:FindFirstChild("Wall1")
                if wall1 then
                    table.insert(stageList, {
                        Name = stage.Name,
                        Z = wall1.Position.Z
                    })
                end
            end
        end
    end
    table.sort(stageList, function(a, b) return a.Z > b.Z end)
    
    for i, data in ipairs(stageList) do
        table.insert(stageOptions, "Stage " .. tostring(i) .. " (" .. data.Name .. ")")
    end
end

if #stageOptions == 0 then
    table.insert(stageOptions, "Stage 1")
end

local FarmSection = Tabs.Main:Section({
    Title = "Farm",
    Box = true,
    BoxBorder = true,
    Expandable = true,
    Opened = true
})

local selectedStage = stageOptions[1]

_G.AutoFarmBreakWalls = false
_G.PauseAutoFarmBreakWalls = false
FarmSection:Toggle({
    Title = "Auto Farm",
    Value = false,
    Callback = function(Value)
        _G.AutoFarmBreakWalls = Value
        if Value then
            task.spawn(function()
                local pausedTpCount = 0
                while _G.AutoFarmBreakWalls do
                    local isPaused = false
                    pcall(function()
                        local lp = game:GetService("Players").LocalPlayer
                        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                        if not hrp then return end
                        
                        local strengthStat = lp:FindFirstChild("leaderstats") and lp.leaderstats:FindFirstChild("Strength")
                        local currentStrength = strengthStat and tonumber(strengthStat.Value) or 0
                        
                        if _G.PauseAutoFarmBreakWalls or currentStrength < _G.MinStrengthFarm then
                            isPaused = true
                            if pausedTpCount < 2 then
                                hrp.CFrame = CFrame.new(123, 70 + (_G.YOffsetForTP or 0), 82)
                                pausedTpCount = pausedTpCount + 1
                            end
                            return
                        else
                            pausedTpCount = 0
                        end
                        
                        local stagesFolder = workspace:FindFirstChild("World1") and workspace.World1:FindFirstChild("Stages")
                        if not stagesFolder then return end
                        
                        local stageList = {}
                        for _, stage in ipairs(stagesFolder:GetChildren()) do
                            local wallFolder = stage:FindFirstChild("WallFolder")
                            local wall1 = wallFolder and wallFolder:FindFirstChild("Wall1")
                            if wall1 then
                                table.insert(stageList, {
                                    Model = stage,
                                    Name = stage.Name,
                                    Z = wall1.Position.Z
                                })
                            end
                        end
                        table.sort(stageList, function(a, b) return a.Z > b.Z end)
                        
                        local targetStageIdx = 1
                        for i, opt in ipairs(stageOptions) do
                            if opt == selectedStage then
                                targetStageIdx = i
                                break
                            end
                        end
                        if targetStageIdx > #stageList then targetStageIdx = #stageList end
                        
                        local activeWall = nil
                        local activeStageModel = nil
                        
                        for i = 1, targetStageIdx do
                            local stageData = stageList[i]
                            if stageData and stageData.Model then
                                local wallFolder = stageData.Model:FindFirstChild("WallFolder")
                                if wallFolder then
                                    local walls = {}
                                    for _, w in ipairs(wallFolder:GetChildren()) do
                                        if string.match(w.Name, "Wall%d+") then
                                            local num = tonumber(string.match(w.Name, "%d+"))
                                            if num then
                                                table.insert(walls, {Part = w, Num = num})
                                            end
                                        end
                                    end
                                    table.sort(walls, function(a, b) return a.Num < b.Num end)
                                    
                                    for _, wData in ipairs(walls) do
                                        if wData.Part and wData.Part.CanCollide == true then
                                            activeWall = wData.Part
                                            activeStageModel = stageData.Model
                                            break
                                        end
                                    end
                                    
                                    if activeWall then break end
                                end
                            end
                        end
                        
                        if activeWall then
                            local targetPos = activeWall.Position + Vector3.new(-1.068, -15.5 + (_G.YOffsetForTP or 0), 4.353)
                            hrp.CFrame = CFrame.new(targetPos, Vector3.new(activeWall.Position.X, targetPos.Y, activeWall.Position.Z))
                            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Punch"):FireServer("RightHand")
                        else
                            local targetStageData = stageList[targetStageIdx]
                            if targetStageData and targetStageData.Model then
                                local winPad = targetStageData.Model:FindFirstChild("WinPad")
                                local guiPart = winPad and winPad:FindFirstChild("GuiPart")
                                local touchInt = guiPart and guiPart:FindFirstChild("TouchInterest")
                                
                                if guiPart and hrp then
                                    if touchInt then
                                        fireTouch(hrp, guiPart)
                                    end
                                end
                            end
                        end
                    end)
                    if isPaused then
                        task.wait(1)
                    else
                        task.wait(0.1)
                    end
                end
                pcall(function()
                    local lp = game:GetService("Players").LocalPlayer
                    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then 
                        hrp.CFrame = CFrame.new(123, 70 + (_G.YOffsetForTP or 0), 82)
                        task.wait(0.1)
                        hrp.CFrame = CFrame.new(123, 70 + (_G.YOffsetForTP or 0), 82)
                    end
                end)
            end)
        else
            pcall(function()
                local lp = game:GetService("Players").LocalPlayer
                local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                if hrp then 
                    hrp.CFrame = CFrame.new(123, 70 + (_G.YOffsetForTP or 0), 82)
                    task.wait(0.1)
                    hrp.CFrame = CFrame.new(123, 70 + (_G.YOffsetForTP or 0), 82)
                end
            end)
        end
    end
})

FarmSection:Dropdown({
    Title = "Select Farm Stage",
    Values = stageOptions,
    Value = selectedStage,
    Callback = function(Value)
        selectedStage = Value
    end
})

_G.MinStrengthFarm = 0
FarmSection:Input({
    Title = "Min Strength",
    Desc = "Start at Given Strength",
    Value = "0",
    Callback = function(Value)
        local cleanStr = string.gsub(Value, "[%s%,]+", "")
        if NumberConverter and NumberConverter.Parse then
            local ok, p = pcall(function() return NumberConverter.Parse(cleanStr) end)
            if ok and p then
                _G.MinStrengthFarm = p
            end
        else
            _G.MinStrengthFarm = tonumber(string.match(cleanStr, "[%d%.]+")) or 0
        end
    end
})

local UpgradesSection = Tabs.Main:Section({
    Title = "Upgrades",
    Box = true,
    BoxBorder = true,
    Expandable = true,
    Opened = true
})

_G.AutoBuyAura = false
UpgradesSection:Toggle({
    Title = "Auto Buy Aura",
    Value = false,
    Callback = function(Value)
        _G.AutoBuyAura = Value
        if Value then
            task.spawn(function()
                while _G.AutoBuyAura do
                    pcall(function()
                        local lp = game:GetService("Players").LocalPlayer
                        local mainAuras = lp.PlayerGui.Frames.Auras.ScrollingFrame.Main
                        local bestAura = nil
                        local highestStat = -1
                        local currentlyEquippedStat = -1

                        local myMoney = 0
                        if lp:FindFirstChild("leaderstats") then
                            local wins = lp.leaderstats:FindFirstChild("Wins")
                            if not wins then wins = lp.leaderstats:FindFirstChild("Cash") end
                            if not wins then wins = lp.leaderstats:FindFirstChild("Gems") end
                            if wins then myMoney = tonumber(wins.Value) or 0 end
                        end
                        
                        for _, auraItem in ipairs(mainAuras:GetChildren()) do
                            if auraItem:FindFirstChild("StatLabel") then
                                local statText = auraItem.StatLabel.Text
                                local statVal = tonumber(string.match(statText, "[%d%.]+")) or 0
                                
                                local buyBtn = auraItem:FindFirstChild("Buy")
                                local equipBtn = auraItem:FindFirstChild("Equip")
                                
                                local isOwned = false
                                if buyBtn and not buyBtn.Visible then
                                    isOwned = true
                                end
                                if equipBtn and equipBtn.Visible then
                                    isOwned = true
                                end
                                
                                local isEquipped = false
                                if isOwned and equipBtn and equipBtn:FindFirstChild("TextLabel") then
                                    local eqText = string.lower(equipBtn.TextLabel.Text)
                                    if string.match(eqText, "equipped") and not string.match(eqText, "unequipped") and eqText ~= "equip" then
                                        isEquipped = true
                                        if statVal > currentlyEquippedStat then
                                            currentlyEquippedStat = statVal
                                        end
                                    end
                                end
                                
                                local price = math.huge
                                if not isOwned and buyBtn and buyBtn:FindFirstChild("Price") then
                                    local priceStr = buyBtn.Price.Text
                                    local cleanStr = string.gsub(priceStr, "[%s%,%$]+", "")
                                    if NumberConverter and NumberConverter.Parse then
                                        local pcallOk, p = pcall(function() return NumberConverter.Parse(cleanStr) end)
                                        if pcallOk and p then price = p end
                                    end
                                    if price == math.huge then
                                        price = tonumber(string.match(cleanStr, "[%d%.]+")) or math.huge
                                    end
                                end
                                
                                if isOwned or myMoney >= price then
                                    if statVal > highestStat then
                                        highestStat = statVal
                                        bestAura = auraItem
                                    end
                                end
                            end
                        end
                        
                        if bestAura and highestStat > currentlyEquippedStat then
                            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("BuyAura"):FireServer(bestAura.Name)
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    end
})

_G.AutoBuyDumbbells = false
UpgradesSection:Toggle({
    Title = "Auto Buy Dumbbells",
    Value = false,
    Callback = function(Value)
        _G.AutoBuyDumbbells = Value
        if Value then
            task.spawn(function()
                while _G.AutoBuyDumbbells do
                    pcall(function()
                        local lp = game:GetService("Players").LocalPlayer
                        local winsStat = lp:FindFirstChild("leaderstats") and lp.leaderstats:FindFirstChild("Wins")
                        local myWins = winsStat and tonumber(winsStat.Value) or 0
                        
                        local dumbbellStands = workspace:FindFirstChild("World1") and workspace.World1:FindFirstChild("Content") and workspace.World1.Content:FindFirstChild("DumbbellArea") and workspace.World1.Content.DumbbellArea:FindFirstChild("DumbbellStands")
                        
                        if dumbbellStands then
                            local bestDumbbell = nil
                            local highestWinsReq = -1
                            local currentlyEquippedWins = -1
                            
                            for _, stand in ipairs(dumbbellStands:GetChildren()) do
                                if tonumber(stand.Name) then
                                    local reqWins = 0
                                    local billboard = stand:FindFirstChild("DumbbellBillboard")
                                    if billboard and billboard:FindFirstChild("WinsValue") then
                                        local winsText = string.lower(billboard.WinsValue.Text) -- "5k wins required"
                                        local cleanStr = string.gsub(winsText, "wins required", "")
                                        cleanStr = string.gsub(cleanStr, "%s+", "")
                                        if NumberConverter and NumberConverter.Parse then
                                            local ok, p = pcall(function() return NumberConverter.Parse(cleanStr) end)
                                            if ok and p then reqWins = p end
                                        else
                                            reqWins = tonumber(string.match(cleanStr, "[%d%.]+")) or 0
                                        end
                                    end
                                    
                                    local cylinder = stand:FindFirstChild("Stand") and stand.Stand:FindFirstChild("Neon") and stand.Stand.Neon:FindFirstChild("Cylinder")
                                    if cylinder then
                                        local c = cylinder.Color
                                        local isOwned = false
                                        local isEquipped = false
                                        
                                        if c.R >= 0.99 and c.G >= 0.99 and c.B >= 0.99 then
                                            isOwned = true
                                        elseif c.G >= 0.99 and c.R < 0.1 and c.B < 0.1 then
                                            isOwned = true
                                            isEquipped = true
                                            if reqWins > currentlyEquippedWins then
                                                currentlyEquippedWins = reqWins
                                            end
                                        end
                                        
                                        if isOwned or myWins >= reqWins then
                                            if reqWins > highestWinsReq then
                                                highestWinsReq = reqWins
                                                bestDumbbell = stand
                                            end
                                        end
                                    end
                                end
                            end
                            
                            if bestDumbbell and highestWinsReq > currentlyEquippedWins then
                                local prompt = bestDumbbell:FindFirstChild("PromptAttachment") and bestDumbbell.PromptAttachment:FindFirstChild("DumbbellPrompt")
                                local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                                
                                if prompt and hrp then
                                    _G.PauseAutoFarmBreakWalls = true
                                    task.wait(0.2)
                                    
                                        local startTpTick = tick()
                                        while hrp and _G.AutoBuyDumbbells and tick() - startTpTick < 5 do
                                            hrp.CFrame = bestDumbbell.PromptAttachment.WorldCFrame + Vector3.new(0, _G.YOffsetForTP or 0, 0)
                                            if fireproximityprompt then
                                                prompt.HoldDuration = 0
                                                fireproximityprompt(prompt)
                                            end
                                            task.wait(0.1)
                                            
                                            local cylinder = bestDumbbell:FindFirstChild("Stand") and bestDumbbell.Stand:FindFirstChild("Neon") and bestDumbbell.Stand.Neon:FindFirstChild("Cylinder")
                                            if cylinder and cylinder.Color.G >= 0.99 and cylinder.Color.R < 0.1 and cylinder.Color.B < 0.1 then
                                                break
                                            end
                                        end
                                    
                                    _G.PauseAutoFarmBreakWalls = false
                                end
                            end
                        end
                    end)
                    task.wait(1.5)
                end
            end)
        end
    end
})

_G.AutoPunch = false
Tabs.Main:Toggle({
    Title = "Auto Punch",
    Value = false,
    Callback = function(Value)
        _G.AutoPunch = Value
        if Value then
            task.spawn(function()
                while _G.AutoPunch do
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Punch"):FireServer("RightHand")
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

_G.AutoTrain = false
Tabs.Main:Toggle({
    Title = "Auto Train",
    Desc = "Not Work In Punching Area",
    Value = false,
    Callback = function(Value)
        _G.AutoTrain = Value
        if Value then
            task.spawn(function()
                while _G.AutoTrain do
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Train"):FireServer()
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})



_G.AutoRebirth = false
Tabs.Main:Toggle({
    Title = "Auto Rebirth",
    Value = false,
    Callback = function(Value)
        _G.AutoRebirth = Value
        if Value then
            task.spawn(function()
                while _G.AutoRebirth do
                    pcall(function()
                        local lp = game:GetService("Players").LocalPlayer
                        local prog = lp.PlayerGui.Frames.Rebirth.ProgressBar.Progress
                        if prog then
                            local scaleX = math.floor(prog.Size.X.Scale * 1000 + 0.5) / 1000
                            local scaleY = math.floor(prog.Size.Y.Scale * 1000 + 0.5) / 1000
                            if scaleX >= 1 and scaleY >= 1 then
                                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Rebirth"):InvokeServer()
                            end
                        end
                    end)
                    task.wait(2)
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
