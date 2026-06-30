-- fluent code converted to wind ui
-- [[ KEY SYSTEM LOADER ]] --
local KeySystem = loadstring(game:HttpGet("https://raw.githubusercontent.com/wendigo5414-cmyk/scripts/refs/heads/main/keysystem.lua"))()
KeySystem.Init()

-- [[ GAME SCRIPT START ]] --
local cloneref = (cloneref or clonereference or function(instance) return instance end)
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local NumberConverter = nil

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
    Dungeon = Window:Tab({ Title = "Dungeon", Icon = "solar:sword-bold" }),
    Movement = Window:Tab({ Title = "Movement", Icon = "solar:running-bold" }),
    Teleport = Window:Tab({ Title = "Teleport", Icon = "solar:map-point-bold" }),
    Settings = Window:Tab({ Title = "Settings", Icon = "solar:settings-bold" }),
    AboutUs  = Window:Tab({ Title = "About Us", Icon = "solar:info-circle-bold" })
}

local savedSpawnCFrame = nil

local UIS = cloneref(game:GetService("UserInputService"))
local GuiService = cloneref(game:GetService("GuiService"))
local VirtualInputManager = cloneref(game:GetService("VirtualInputManager"))

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

local executorName = identifyexecutor and ({identifyexecutor()})[1] or "Unknown"

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

local function getHighestStage()
    local highest = nil
    local maxNum = -1
    local stages = workspace:FindFirstChild("Stages")
    if stages then
        for _, stage in ipairs(stages:GetChildren()) do
            local num = tonumber(string.match(stage.Name, "Stage(%d+)"))
            if num and num > maxNum then
                maxNum = num
                highest = stage
            end
        end
    end
    return highest
end

_G.AutoFarmWins = false
Tabs.Main:Toggle({
    Title = "Auto Farm Wins",
    Value = false,
    Callback = function(Value)
        _G.AutoFarmWins = Value
        if Value then
            task.spawn(function()
                local cachedHighestStage = nil
                local lastStageCheck = 0
                
                while _G.AutoFarmWins do
                    pcall(function()
                        local lp = game:GetService("Players").LocalPlayer
                        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                        if not hrp then return end
                        
                        if not savedSpawnCFrame then
                            local spawnLoc = workspace:FindFirstChild("SpawnLocation")
                            if spawnLoc then
                                savedSpawnCFrame = CFrame.new(spawnLoc.Position.X, spawnLoc.Position.Y + 10, spawnLoc.Position.Z)
                            else
                                local char = lp.Character
                                if char and char:FindFirstChild("Humanoid") then
                                    char.Humanoid.Health = 0
                                end
                                task.wait(2)
                                return
                            end
                        end
                        
                        if tick() - lastStageCheck > 2 or not cachedHighestStage or not cachedHighestStage.Parent then
                            cachedHighestStage = getHighestStage()
                            lastStageCheck = tick()
                        end
                        
                        if cachedHighestStage then
                            local winButton = cachedHighestStage:FindFirstChild("WinButton")
                            if winButton then
                                local touchPart = winButton:FindFirstChild("TouchPart")
                                if touchPart then
                                    touchPart.CFrame = savedSpawnCFrame
                                    
                                    local touchInt = touchPart:FindFirstChild("TouchInterest")
                                    if touchInt then
                                        fireTouch(hrp, touchPart)
                                    end
                                else
                                    if winButton:IsA("Model") then
                                        hrp.CFrame = winButton:GetPivot()
                                    elseif winButton:IsA("BasePart") then
                                        hrp.CFrame = winButton.CFrame
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

_G.AutoTap = false
Tabs.Main:Toggle({
    Title = "Auto Tap",
    Value = false,
    Callback = function(Value)
        _G.AutoTap = Value
        if Value then
            task.spawn(function()
                while _G.AutoTap do
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GainMagicPower"):FireServer()
                    end)
                    task.wait(0.03)
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
                        local frames = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("GUI") and lp.PlayerGui.GUI:FindFirstChild("Frames")
                        local progress = frames and frames:FindFirstChild("Rebirth") and frames.Rebirth:FindFirstChild("Frame") and frames.Rebirth.Frame:FindFirstChild("Bar") and frames.Rebirth.Frame.Bar:FindFirstChild("Progress")
                        
                        if progress and progress.Size.X.Scale >= 1 and progress.Size.Y.Scale >= 1 then
                            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Rebirth"):FireServer()
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    end
})

local function getMyWins(lp)
    local myWins = 0
    local gui = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("GUI")
    local trophyLabel = gui and gui:FindFirstChild("HUD") and gui.HUD:FindFirstChild("Labels") and gui.HUD.Labels:FindFirstChild("TrophyLabel")
    if trophyLabel and trophyLabel:IsA("TextLabel") then
        local text = trophyLabel.Text
        if NumberConverter and NumberConverter.Parse then
            local ok, p = pcall(function() return NumberConverter.Parse(text) end)
            if ok and p then 
                myWins = p 
            end
        end
    end
    return myWins
end

local function getColor3(btn)
    if typeof(btn) == "Instance" then
        if btn:IsA("BasePart") then return btn.Color end
        local cPart = btn:FindFirstChild("Color") or btn:FindFirstChild("color")
        if cPart then
            if cPart:IsA("BasePart") then return cPart.Color end
            if cPart:IsA("Color3Value") then return cPart.Value end
        end
    end
    return nil
end

local function isColorMatch(c1, r, g, b)
    if typeof(c1) ~= "Color3" then return false end
    return math.abs((c1.R * 255) - r) <= 5 and math.abs((c1.G * 255) - g) <= 5 and math.abs((c1.B * 255) - b) <= 5
end

_G.AutoBuyStaff = false
Tabs.Main:Toggle({
    Title = "Auto Buy Staff",
    Value = false,
    Callback = function(Value)
        _G.AutoBuyStaff = Value
        if Value then
            task.spawn(function()
                while _G.AutoBuyStaff do
                    local ok, err = pcall(function()
                        local lp = game:GetService("Players").LocalPlayer
                        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                        if not hrp then return end

                        local myWins = getMyWins(lp)
                        
                        local staffBtns = workspace:FindFirstChild("StaffButtons")
                        if staffBtns then
                            local bestStaff = nil
                            local bestNum = -1
                            
                            for _, btn in ipairs(staffBtns:GetChildren()) do
                                local num = tonumber(string.match(btn.Name, "Staff Button(%d+)"))
                                if num then
                                    local c1 = getColor3(btn)
                                    local isEquipped = isColorMatch(c1, 98, 37, 209)
                                    local isOwned = isEquipped or isColorMatch(c1, 9, 137, 207)
                                    local isUnowned = isColorMatch(c1, 196, 40, 28)
                                    
                                    local price = math.huge
                                    if isUnowned then
                                        local winsLabel = btn:FindFirstChild("Union") and btn.Union:FindFirstChild("StaffUI") and btn.Union.StaffUI:FindFirstChild("WinsLabel")
                                        if winsLabel then
                                            local text = string.gsub(winsLabel.Text, "Wins", "")
                                            if NumberConverter and NumberConverter.Parse then
                                                local ok, p = pcall(function() return NumberConverter.Parse(text) end)
                                                if ok and p then price = p end
                                            end
                                            if price == math.huge then
                                                price = tonumber(string.match(text, "[%d%.]+")) or math.huge
                                            end
                                        end
                                    end
                                    
                                    if isOwned or myWins >= price then
                                        if num > bestNum then
                                            bestNum = num
                                            bestStaff = btn
                                        end
                                    end
                                end
                            end
                            
                            if bestStaff then
                                local cBest = getColor3(bestStaff)
                                local isEquipped = isColorMatch(cBest, 98, 37, 209)
                                if not isEquipped then
                                    local touchPart = bestStaff:FindFirstChild("TouchPart")
                                    if touchPart then
                                        local touchInt = touchPart:FindFirstChild("TouchInterest")
                                        if touchInt then
                                            fireTouch(hrp, touchPart)
                                        end
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

local EggSection = Tabs.Main:Section({
    Title = "Auto Open Egg",
    Box = true,
    BoxBorder = true,
    Expandable = true,
    Opened = true
})

local function getEggs()
    local eggs = {}
    local eggFolder = workspace:FindFirstChild("Eggs")
    if eggFolder then
        for _, egg in ipairs(eggFolder:GetChildren()) do
            table.insert(eggs, egg.Name)
        end
    end
    return #eggs > 0 and eggs or {"No eggs found"}
end

local selectedEgg = "No eggs found"

EggSection:Dropdown({
    Title = "Select Egg",
    Values = getEggs(),
    Value = "No eggs found",
    Callback = function(Value)
        selectedEgg = Value
    end
})

_G.AutoOpenEgg = false
EggSection:Toggle({
    Title = "Auto Open Egg",
    Value = false,
    Callback = function(Value)
        _G.AutoOpenEgg = Value
        if Value then
            task.spawn(function()
                while _G.AutoOpenEgg do
                    local ok, err = pcall(function()
                        if selectedEgg == "No eggs found" or not selectedEgg then 
                            return 
                        end
                        
                        local lp = game:GetService("Players").LocalPlayer
                        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                        if not hrp then return end

                        local myWins = getMyWins(lp)
                        
                        local eggFolder = workspace:FindFirstChild("Eggs")
                        if eggFolder then
                            local eggModelFolder = eggFolder:FindFirstChild(selectedEgg)
                            if eggModelFolder then
                                local targetEgg = eggModelFolder:FindFirstChild(selectedEgg)
                                if targetEgg then
                                    local price = math.huge
                                    for _, desc in ipairs(targetEgg:GetDescendants()) do
                                        if desc.Name == "EggPriceUI" then
                                            local winLabel = desc:FindFirstChild("WinLabel") or desc:FindFirstChild("WinsLabel")
                                            if winLabel and winLabel:IsA("TextLabel") then
                                                local text = string.gsub(winLabel.Text, "Wins", "")
                                                if NumberConverter and NumberConverter.Parse then
                                                    local ok, p = pcall(function() return NumberConverter.Parse(text) end)
                                                    if ok and p then price = p end
                                                end
                                                if price == math.huge then
                                                    price = tonumber(string.match(text, "[%d%.]+")) or math.huge
                                                end
                                                break
                                            end
                                        end
                                    end
                                    
                                    if myWins >= price then
                                        local circle = targetEgg:FindFirstChild("Circle")
                                        local targetPart = circle or targetEgg:FindFirstChildWhichIsA("BasePart")
                                        if targetPart then
                                            hrp.CFrame = targetPart.CFrame * CFrame.new(3, 3, 0)
                                        end
                                        
                                        local args = { selectedEgg }
                                        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and game:GetService("ReplicatedStorage").Remotes:FindFirstChild("OpenEgg")
                                        if remote then
                                            remote:InvokeServer(unpack(args))
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

local savedUniquePetsFile = "PXH_Configs/UniquePets_" .. game.PlaceId .. ".json"
local HttpService = game:GetService("HttpService")

local uniquePets = {}
pcall(function()
    if isfile and isfile(savedUniquePetsFile) then
        uniquePets = HttpService:JSONDecode(readfile(savedUniquePetsFile))
    end
end)

local function saveUniquePets()
    pcall(function()
        if writefile then
            if not isfolder("PXH_Configs") then
                makefolder("PXH_Configs")
            end
            writefile(savedUniquePetsFile, HttpService:JSONEncode(uniquePets))
        end
    end)
end

local selectedPetsToDelete = {}

local AutoDeleteDropdown = EggSection:Dropdown({
    Title = "Select Pets To Delete",
    Values = #uniquePets > 0 and uniquePets or {"No pets logged"},
    Multi = true,
    Value = {},
    Callback = function(Value)
        selectedPetsToDelete = Value
    end
})

_G.AutoDeletePets = false
EggSection:Toggle({
    Title = "Auto Delete Pets",
    Value = false,
    Callback = function(Value)
        _G.AutoDeletePets = Value
        if Value then
            task.spawn(function()
                while _G.AutoDeletePets do
                    pcall(function()
                        local lp = game:GetService("Players").LocalPlayer
                        local backpackFrames = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("GUI") and lp.PlayerGui.GUI:FindFirstChild("Frames")
                        local petScroll = backpackFrames and backpackFrames:FindFirstChild("Backpack") and backpackFrames.Backpack:FindFirstChild("Pets") and backpackFrames.Backpack.Pets:FindFirstChild("ScrollingFrame")
                        
                        if petScroll then
                            local toDelete = {}
                            
                            for _, petFrame in ipairs(petScroll:GetChildren()) do
                                if not petFrame:IsA("UIGridStyleLayout") and not petFrame:IsA("UIComponent") then
                                    local uuid = petFrame.Name
                                    local petNameLabel = petFrame:FindFirstChild("PetName")
                                    if petNameLabel and petNameLabel:IsA("TextLabel") then
                                        local pName = petNameLabel.Text
                                        if pName and pName ~= "" then
                                            if type(selectedPetsToDelete) == "table" and table.find(selectedPetsToDelete, pName) then
                                                table.insert(toDelete, uuid)
                                            end
                                        end
                                    end
                                end
                            end
                            
                            if #toDelete > 0 then
                                for _, uuid in ipairs(toDelete) do
                                    local args = { { uuid } }
                                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and game:GetService("ReplicatedStorage").Remotes:FindFirstChild("DeletePets")
                                    if remote then
                                        remote:FireServer(unpack(args))
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

task.spawn(function()
    while true do
        pcall(function()
            local lp = game:GetService("Players").LocalPlayer
            local backpackFrames = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("GUI") and lp.PlayerGui.GUI:FindFirstChild("Frames")
            local petScroll = backpackFrames and backpackFrames:FindFirstChild("Backpack") and backpackFrames.Backpack:FindFirstChild("Pets") and backpackFrames.Backpack.Pets:FindFirstChild("ScrollingFrame")
            
            if petScroll then
                local addedNew = false
                
                for _, petFrame in ipairs(petScroll:GetChildren()) do
                    if not petFrame:IsA("UIGridStyleLayout") and not petFrame:IsA("UIComponent") then
                        local petNameLabel = petFrame:FindFirstChild("PetName")
                        if petNameLabel and petNameLabel:IsA("TextLabel") then
                            local pName = petNameLabel.Text
                            if pName and pName ~= "" then
                                if not table.find(uniquePets, pName) then
                                    local noLogIdx = table.find(uniquePets, "No pets logged")
                                    if noLogIdx then
                                        table.remove(uniquePets, noLogIdx)
                                    end
                                    table.insert(uniquePets, pName)
                                    addedNew = true
                                end
                            end
                        end
                    end
                end
                
                if addedNew then
                    saveUniquePets()
                    if AutoDeleteDropdown and AutoDeleteDropdown.Refresh then
                        AutoDeleteDropdown:Refresh(uniquePets)
                    end
                end
            end
        end)
        task.wait(2)
    end
end)

-- ══════════════════════════════════════════
--              DUNGEON TAB
-- ══════════════════════════════════════════
Tabs.Dungeon:Paragraph({
    Title = "USE AUTO EXECUTE",
    Desc = "every executor have auto execute feature\n(Not Recommended in Xeno)"
})

local DungeonSection = Tabs.Dungeon:Section({
    Title = "Dungeon Auto",
    Box = true,
    BoxBorder = true,
    Expandable = true,
    Opened = true
})

_G.SelectedDungeonPlayers = 1
DungeonSection:Dropdown({
    Title = "Select Players",
    Values = {"1", "2", "3", "4", "5"},
    Value = "1",
    Callback = function(Value)
        _G.SelectedDungeonPlayers = tonumber(Value) or 1
    end
})

local function getValidQueue()
    local queuesFolder = workspace:FindFirstChild("Queues")
    if queuesFolder then
        for _, queue in ipairs(queuesFolder:GetChildren()) do
            local refs = queue:FindFirstChild("Refs")
            local ui = refs and refs:FindFirstChild("UI")
            local bbGui = ui and ui:FindFirstChild("BillboardGui")
            local timeLabel = bbGui and bbGui:FindFirstChild("Time")
            if timeLabel and timeLabel:IsA("TextLabel") then
                if string.find(string.upper(timeLabel.Text), "DUNGEONS") then
                    return queue
                end
            end
        end
    end
    return nil
end

_G.AutoJoinDungeon = false
DungeonSection:Toggle({
    Title = "Auto Join Dungeon",
    Value = false,
    Callback = function(Value)
        _G.AutoJoinDungeon = Value
        if Value then
            task.spawn(function()
                while _G.AutoJoinDungeon do
                    pcall(function()
                        local lp = game:GetService("Players").LocalPlayer
                        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                        if not hrp then return end

                        local targetQueue = getValidQueue()
                        if targetQueue then
                            local enterPart = targetQueue:FindFirstChild("Refs") and targetQueue.Refs:FindFirstChild("Enter")
                            if enterPart and enterPart:FindFirstChild("TouchInterest") then
                                local timeLabel = targetQueue.Refs.UI.BillboardGui.Time
                                
                                fireTouch(hrp, enterPart)
                                
                                local t = 0
                                while _G.AutoJoinDungeon and t < 50 do
                                    if string.find(string.upper(timeLabel.Text), "RESERVING...") then
                                        break
                                    end
                                    task.wait(0.1)
                                    t = t + 1
                                end
                                
                                if string.find(string.upper(timeLabel.Text), "RESERVING...") then
                                    local args = { tonumber(_G.SelectedDungeonPlayers) or 1, false }
                                    local reserveRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Queue") and game:GetService("ReplicatedStorage").Queue:FindFirstChild("ReserveQueue")
                                    if reserveRemote then
                                        reserveRemote:FireServer(unpack(args))
                                    end
                                    
                                    t = 0
                                    while _G.AutoJoinDungeon and t < 50 do
                                        if not string.find(string.upper(timeLabel.Text), "RESERVING...") then
                                            break
                                        end
                                        task.wait(0.1)
                                        t = t + 1
                                    end
                                    
                                    local success = false
                                    while _G.AutoJoinDungeon do
                                        local currentText = string.upper(timeLabel.Text)
                                        if string.find(currentText, "DUNGEONS") then
                                            break
                                        end
                                        local numStr = string.match(currentText, "%d+")
                                        if numStr then
                                            local num = tonumber(numStr)
                                            if num and num <= 1 then
                                                success = true
                                                break
                                            end
                                        end
                                        task.wait(0.1)
                                    end
                                    
                                    if success then
                                        task.wait(5)
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

_G.AutoKillMobs = false
DungeonSection:Toggle({
    Title = "Auto Kill Mobs",
    Value = false,
    Callback = function(Value)
        _G.AutoKillMobs = Value
        if Value then
            task.spawn(function()
                while _G.AutoKillMobs do
                    pcall(function()
                        local mobsFolder = workspace:FindFirstChild("DungeonMobs")
                        if mobsFolder then
                            local targetMob = nil
                            for _, mob in ipairs(mobsFolder:GetChildren()) do
                                local head = mob:FindFirstChild("Head")
                                if head then
                                    local mobHealth = head:FindFirstChild("MobHealth")
                                    if mobHealth and mobHealth.Enabled then
                                        targetMob = mob
                                        break
                                    end
                                end
                            end

                            if targetMob then
                                local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and game:GetService("ReplicatedStorage").Remotes:FindFirstChild("DealMobDamage")
                                if remote then
                                    while _G.AutoKillMobs and targetMob.Parent == mobsFolder do
                                        local isAlive = false
                                        pcall(function()
                                            local head = targetMob:FindFirstChild("Head")
                                            if head then
                                                local mobHealth = head:FindFirstChild("MobHealth")
                                                if mobHealth and mobHealth.Enabled then
                                                    isAlive = true
                                                end
                                            end
                                        end)
                                        
                                        if not isAlive then break end
                                        
                                        remote:FireServer(targetMob, 999999)
                                        task.wait(0.01)
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.01)
                end
            end)
        end
    end
})

_G.AutoGainMagicDungeon = false
DungeonSection:Toggle({
    Title = "Auto Gain Magic",
    Value = false,
    Callback = function(Value)
        _G.AutoGainMagicDungeon = Value
        if Value then
            task.spawn(function()
                while _G.AutoGainMagicDungeon do
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GainMagicPower"):FireServer()
                    end)
                    task.wait(0.03)
                end
            end)
        end
    end
})

_G.ManageDistance = false
local pxPlatform = nil

local function cleanupPlatform()
    if pxPlatform then
        pxPlatform:Destroy()
        pxPlatform = nil
    end
end

DungeonSection:Toggle({
    Title = "Manage Distance",
    Desc = "Goes to a safer spot so mobs can't kill you",
    Value = false,
    Callback = function(Value)
        _G.ManageDistance = Value
        if Value then
            task.spawn(function()
                local currentSafeSpot = nil
                while _G.ManageDistance do
                    pcall(function()
                        local lp = game:GetService("Players").LocalPlayer
                        local char = lp.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local mobsFolder = workspace:FindFirstChild("DungeonMobs")
                            if mobsFolder then
                                local isCurrentSafe = true
                                
                                if currentSafeSpot then
                                    local parts = workspace:GetPartBoundsInBox(hrp.CFrame, hrp.Size + Vector3.new(2, 2, 2))
                                    for _, p in ipairs(parts) do
                                        if p:IsDescendantOf(mobsFolder) then
                                            isCurrentSafe = false
                                            break
                                        end
                                    end
                                    
                                    if pxPlatform and pxPlatform.Parent then
                                        if hrp.Position.Y < pxPlatform.Position.Y - 2 then
                                            hrp.CFrame = CFrame.new(currentSafeSpot)
                                        end
                                    end
                                else
                                    isCurrentSafe = false
                                end
                                
                                if not isCurrentSafe then
                                    local newSafeSpot = nil
                                    for i = 1, 15 do
                                        local rx = -344 + math.random(-50, 50)
                                        local ry = 44
                                        local rz = 266 + math.random(-50, 50)
                                        
                                        local isSafe = true
                                        local parts = workspace:GetPartBoundsInRadius(Vector3.new(rx, ry, rz), 15)
                                        for _, p in ipairs(parts) do
                                            if p:IsDescendantOf(mobsFolder) then
                                                isSafe = false
                                                break
                                            end
                                        end
                                        
                                        if isSafe then
                                            newSafeSpot = Vector3.new(rx, ry, rz)
                                            break
                                        end
                                    end
                                    
                                    if newSafeSpot then
                                        currentSafeSpot = newSafeSpot
                                        
                                        if not pxPlatform or not pxPlatform.Parent then
                                            pxPlatform = Instance.new("Part")
                                            pxPlatform.Name = "PXH_SafePlatform"
                                            pxPlatform.Size = Vector3.new(10, 1, 10)
                                            pxPlatform.Anchored = true
                                            pxPlatform.CanCollide = true
                                            pxPlatform.Transparency = 1
                                            pxPlatform.Parent = workspace
                                        end
                                        pxPlatform.Position = currentSafeSpot - Vector3.new(0, 3.5, 0)
                                        
                                        task.spawn(function()
                                            hrp.Anchored = true
                                            local ts = game:GetService("TweenService")
                                            local dist = (hrp.Position - currentSafeSpot).Magnitude
                                            local tweenInfo = TweenInfo.new(dist / 100, Enum.EasingStyle.Linear)
                                            local tween = ts:Create(hrp, tweenInfo, {CFrame = CFrame.new(currentSafeSpot)})
                                            tween:Play()
                                            tween.Completed:Wait()
                                            hrp.Anchored = false
                                        end)
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.1)
                end
                
                cleanupPlatform()
            end)
        else
            cleanupPlatform()
        end
    end
})

_G.AutoPickCards = false
DungeonSection:Toggle({
    Title = "Auto Pick Cards",
    Value = false,
    Callback = function(Value)
        _G.AutoPickCards = Value
        if Value then
            task.spawn(function()
                while _G.AutoPickCards do
                    pcall(function()
                        local lp = game:GetService("Players").LocalPlayer
                        local gui = lp:FindFirstChild("PlayerGui")
                        local dungeonCardsGui = gui and gui:FindFirstChild("DungeonCardsGui")
                        
                        if dungeonCardsGui and dungeonCardsGui.Enabled then
                            local autoPickBg = dungeonCardsGui:FindFirstChild("Dim") and dungeonCardsGui.Dim:FindFirstChild("AutoPick") and dungeonCardsGui.Dim.AutoPick:FindFirstChild("Background")
                            
                            if autoPickBg and autoPickBg:IsA("ImageLabel") and autoPickBg.Visible then
                                if autoPickBg.Image ~= "rbxassetid://92958786684902" then
                                    simulateClick(autoPickBg)
                                    task.wait(1)
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

-- ══════════════════════════════════════════
--              LOAD OTHERS.LUA
-- ══════════════════════════════════════════
local ok, OthersFunc = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/wendigo5414-cmyk/FireballxArena/main/Others.lua", true))()
end)

if ok and type(OthersFunc) == "function" then
    NumberConverter = OthersFunc(Window, Tabs, WindUI)
else
    WindUI:Notify({
        Title = "Error",
        Content = "Failed to load basic categories from Others.lua",
        Duration = 5
    })
end

WindUI:Notify({
    Title = "Prime X Hub",
    Content = "Script loaded successfully!",
    Duration = 5
})
