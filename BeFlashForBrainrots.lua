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

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local isMobile = UIS.TouchEnabled and not UIS.MouseEnabled

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
--              MAIN LOGIC
-- ══════════════════════════════════════════

local DashEvent = ReplicatedStorage:WaitForChild("DashEvent")

local function getPlayerBase()
    local plotsFolder = workspace:FindFirstChild("Plots")
    if plotsFolder then
        for _, plot in ipairs(plotsFolder:GetChildren()) do
            local att = plot:FindFirstChild("Att_Player")
            local bb = att and att:FindFirstChild("Billboard")
            local main = bb and bb:FindFirstChild("Main")
            local txtName = main and main:FindFirstChild("Txt_Name")
            if txtName and txtName:IsA("TextLabel") then
                if txtName.Text == LocalPlayer.DisplayName or txtName.Text == LocalPlayer.Name then
                    return plot
                end
            end
        end
    end
    return nil
end

local function parseBrainrotValue(text)
    if not text then return 0 end
    text = string.gsub(text, "/s", "")
    text = string.gsub(text, "[%$%s]", "")
    if NumberConverter and NumberConverter.Parse then
        return NumberConverter.Parse(text)
    end
    return tonumber(text) or 0
end

local function calculateBaseAmount(revenueText, levelText)
    local cash = parseBrainrotValue(revenueText)
    local level = 1
    if levelText then
        local lvlStr = string.match(levelText, "%d+")
        if lvlStr then level = tonumber(lvlStr) or 1 end
    end
    -- Equation: Base Amount = Current Cash / (1.20 ^ (Level - 1))
    return cash / (1.20 ^ (level - 1))
end

local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")

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

local pxWarningGui
local function showWarning(show)
    if show then
        if not pxWarningGui then
            local targetParent = LocalPlayer:FindFirstChild("PlayerGui") or game:GetService("CoreGui")
            if targetParent then
                pxWarningGui = Instance.new("ScreenGui")
                pxWarningGui.Name = "PXH_HoldWarning"
                pxWarningGui.DisplayOrder = 999999
                pxWarningGui.IgnoreGuiInset = true
                
                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1, 0, 0, 60)
                textLabel.Position = UDim2.new(0, 0, 0, 0)
                textLabel.BackgroundTransparency = 0.3
                textLabel.BackgroundColor3 = Color3.new(0, 0, 0)
                textLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                textLabel.TextScaled = false
                textLabel.TextSize = 20
                textLabel.Font = Enum.Font.GothamBold
                textLabel.Text = "⚠️ PXH Hub: Don't click! [Auto Farm] Charge Button is on Hold\nIt stuck if you click anywhere now (Auto Fix in 10 Sec)"
                textLabel.Parent = pxWarningGui
                
                pxWarningGui.Parent = targetParent
            end
        end
        if pxWarningGui then pxWarningGui.Enabled = true end
    else
        if pxWarningGui then
            pxWarningGui.Enabled = false
        end
    end
end

local function simulateHold(button, holdState)
    if not button then return end
    if UIS.TouchEnabled and not UIS.MouseEnabled then
        if button.AbsolutePosition then
            local x = button.AbsolutePosition.X + (button.AbsoluteSize.X / 2)
            local y = button.AbsolutePosition.Y + (button.AbsoluteSize.Y / 2) + GuiService:GetGuiInset().Y
            local mobileTouchId = 55556
            VirtualInputManager:SendTouchEvent(mobileTouchId, holdState and 0 or 2, x, y)
        end
    else
        if button.AbsolutePosition then
            local x = button.AbsolutePosition.X + (button.AbsoluteSize.X / 2)
            local y = button.AbsolutePosition.Y + (button.AbsoluteSize.Y / 2) + GuiService:GetGuiInset().Y
            if holdState then
                VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
            else
                VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
            end
        end
    end
end

local _pxhCurrentAutoTask = "None"
local _pxhRequest_AutoPlace = false
local _pxhRequest_AutoSell = false

local function tryAcquireTask(taskName)
    if _pxhCurrentAutoTask == taskName then return true end
    if _pxhCurrentAutoTask ~= "None" then return false end
    
    if taskName == "AutoPlace" then
        _pxhCurrentAutoTask = "AutoPlace"
        return true
    elseif taskName == "AutoSell" then
        if _pxhRequest_AutoPlace then return false end
        _pxhCurrentAutoTask = "AutoSell"
        return true
    elseif taskName == "AutoFarm" then
        if _pxhRequest_AutoPlace or _pxhRequest_AutoSell then return false end
        _pxhCurrentAutoTask = "AutoFarm"
        return true
    elseif taskName == "AutoUpgrade" then
        if _pxhRequest_AutoPlace or _pxhRequest_AutoSell then return false end
        _pxhCurrentAutoTask = "AutoUpgrade"
        return true
    end
    return false
end

local autoSellTargetAmount = 0
local autoSellMethod = "Base Value"
local autoSellBrainrotEnabled = false

local AutoSellSection = Tabs.Main:Section({
    Title = "Auto Sell Brainrot",
    Box = true,
    BoxBorder = true,
    Opened = false
})

AutoSellSection:Toggle({
    Title = "Auto Sell Brainrot",
    Value = false,
    Callback = function(state)
        autoSellBrainrotEnabled = state
        if not state then _pxhRequest_AutoSell = false end
        if autoSellBrainrotEnabled then
            task.spawn(function()
                while autoSellBrainrotEnabled do
                    local needToSell = false
                    local toolsToSell = {}
                    pcall(function()
                        local bp = LocalPlayer:FindFirstChild("Backpack")
                        if bp then
                            for _, tool in ipairs(bp:GetChildren()) do
                                if tool:IsA("Tool") then
                                    local mb = tool:FindFirstChild("Mini_Billboard")
                                    if mb then
                                        local txtRev = mb:FindFirstChild("Txt_Revenue")
                                        local txtLvl = mb:FindFirstChild("Txt_Level")
                                        if txtRev and txtLvl then
                                            local ba = 0
                                            if autoSellMethod == "Base Value" then
                                                ba = calculateBaseAmount(txtRev.Text, txtLvl.Text)
                                            else
                                                ba = parseBrainrotValue(txtRev.Text)
                                            end
                                            if ba > 0 and ba < autoSellTargetAmount then
                                                needToSell = true
                                                table.insert(toolsToSell, tool)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    
                    if needToSell then
                        _pxhRequest_AutoSell = true
                        
                        if tryAcquireTask("AutoSell") then
                            for _, tool in ipairs(toolsToSell) do
                                pcall(function()
                                    local bp = LocalPlayer:FindFirstChild("Backpack")
                                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                    if bp and hrp and tool.Parent == bp then
                                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                                            LocalPlayer.Character.Humanoid:EquipTool(tool)
                                        end
                                        task.wait(0.2)
                                        hrp.CFrame = CFrame.new(-32, 3, 106)
                                        task.wait(0.2)
                                        local args = { "One", tool }
                                        local rs = ReplicatedStorage:FindFirstChild("Remotes")
                                        local sellEvt = rs and rs:FindFirstChild("SellEvent")
                                        if sellEvt then
                                            sellEvt:FireServer(unpack(args))
                                        end
                                        task.wait(0.5)
                                    end
                                end)
                                if _pxhRequest_AutoPlace then break end
                            end
                            
                            if _pxhCurrentAutoTask == "AutoSell" then
                                _pxhCurrentAutoTask = "None"
                            end
                        end
                    else
                        _pxhRequest_AutoSell = false
                    end
                    task.wait(1)
                end
                _pxhRequest_AutoSell = false
                if _pxhCurrentAutoTask == "AutoSell" then _pxhCurrentAutoTask = "None" end
            end)
        end
    end
})

AutoSellSection:Dropdown({
    Title = "Sell Brainrot By Checking",
    Values = {"Base Value", "Current Value"},
    Value = "Base Value",
    Callback = function(value)
        autoSellMethod = value
        WindUI:Notify({
            Title = "Sell Method",
            Content = "Set to: " .. tostring(value),
            Duration = 3
        })
    end
})

AutoSellSection:Input({
    Title = "(Checks Amount Of Brainrot)",
    Placeholder = "Ex . 50k , 2T",
    Callback = function(value)
        autoSellTargetAmount = parseBrainrotValue(value)
        WindUI:Notify({
            Title = "Target Sell Value",
            Content = "Set to: " .. tostring(value),
            Duration = 3
        })
    end
})


local autoPlaceBrainrotEnabled = false
Tabs.Main:Toggle({
    Title = "Auto Best Place Brainrot",
    Desc = "Calculates Mutation and Rarity And Places Best Brainrot In Your Backpack to Plot",
    Value = false,
    Callback = function(state)
        autoPlaceBrainrotEnabled = state
        if not state then _pxhRequest_AutoPlace = false end
        if autoPlaceBrainrotEnabled then
            task.spawn(function()
                while autoPlaceBrainrotEnabled do
                    local bestTool = nil
                    local targetStandObj = nil
                    local promptToFire = nil
                    local destCFrame = nil
                    local needToPlace = false
                    
                    pcall(function()
                        local bp = LocalPlayer:FindFirstChild("Backpack")
                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local myBase = getPlayerBase()
                        local workingBrainrots = workspace:FindFirstChild("WorkingBrainrots")
                        
                        if not bp or not hrp or not myBase or not workingBrainrots then return end
                        
                        local bestToolBaseAmount = -1
                        
                        for _, tool in ipairs(bp:GetChildren()) do
                            if tool:IsA("Tool") then
                                local mb = tool:FindFirstChild("Mini_Billboard")
                                if mb then
                                    local txtRev = mb:FindFirstChild("Txt_Revenue")
                                    local txtLvl = mb:FindFirstChild("Txt_Level")
                                    if txtRev and txtLvl then
                                        local ba = calculateBaseAmount(txtRev.Text, txtLvl.Text)
                                        if ba > bestToolBaseAmount then
                                            bestToolBaseAmount = ba
                                            bestTool = tool
                                        end
                                    end
                                end
                            end
                        end
                        
                        if not bestTool then return end
                        
                        local occupiedStands = {}
                        local worstPlotAmount = math.huge
                        local worstPlotStand = nil
                        
                        for _, br in ipairs(workingBrainrots:GetChildren()) do
                            if br:GetAttribute("OwnerId") == LocalPlayer.UserId then
                                local placeAttr = br:GetAttribute("Place")
                                if placeAttr then
                                    occupiedStands[placeAttr] = br
                                    
                                    local bb = br:FindFirstChild("Billboard_Details")
                                    if bb then
                                        local revL = bb:FindFirstChild("Txt_Revenue")
                                        local lvlL = bb:FindFirstChild("Txt_Level")
                                        if revL and lvlL then
                                            local ba = calculateBaseAmount(revL.Text, lvlL.Text)
                                            if ba < worstPlotAmount then
                                                worstPlotAmount = ba
                                                worstPlotStand = placeAttr
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        
                        local modelStands = myBase:FindFirstChild("ModelStands")
                        if not modelStands then return end
                        
                        for _, ms in ipairs(modelStands:GetChildren()) do
                            if string.match(ms.Name, "ModelStand") then
                                if not occupiedStands[ms.Name] then
                                    targetStandObj = ms
                                    local placePt = ms:FindFirstChild("PlacePoint")
                                    local attPlace = placePt and placePt:FindFirstChild("Att_Place")
                                    promptToFire = attPlace and attPlace:FindFirstChild("EquipPrompt")
                                    break
                                end
                            end
                        end
                        
                        if not targetStandObj then
                            if bestToolBaseAmount > worstPlotAmount and worstPlotStand then
                                targetStandObj = modelStands:FindFirstChild(worstPlotStand)
                                if targetStandObj then
                                    local placePt = targetStandObj:FindFirstChild("PlacePoint")
                                    local attPickup = placePt and placePt:FindFirstChild("Att_Pickup")
                                    promptToFire = attPickup and attPickup:FindFirstChild("PickupPrompt")
                                end
                            end
                        end
                        
                        if targetStandObj and promptToFire then
                            needToPlace = true
                            if targetStandObj:FindFirstChild("PlacePoint") then
                                destCFrame = targetStandObj.PlacePoint.CFrame
                            else
                                destCFrame = targetStandObj.CFrame
                            end
                        end
                    end)
                    
                    if needToPlace then
                        _pxhRequest_AutoPlace = true
                        
                        if tryAcquireTask("AutoPlace") then
                            pcall(function()
                                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if hrp and destCFrame and bestTool then
                                    hrp.CFrame = destCFrame * CFrame.new(0, 3, 0)
                                    task.wait(0.5)
                                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                                        LocalPlayer.Character.Humanoid:EquipTool(bestTool)
                                    end
                                    task.wait(0.2)
                                    if promptToFire and fireproximityprompt then
                                        if (hrp.Position - destCFrame.Position).Magnitude < 15 then
                                            fireproximityprompt(promptToFire)
                                        end
                                    end
                                end
                            end)
                            if _pxhCurrentAutoTask == "AutoPlace" then
                                _pxhCurrentAutoTask = "None"
                            end
                        end
                    else
                        _pxhRequest_AutoPlace = false
                    end
                    task.wait(1)
                end
                _pxhRequest_AutoPlace = false
                if _pxhCurrentAutoTask == "AutoPlace" then _pxhCurrentAutoTask = "None" end
            end)
        end
    end
})

local autoFarmBrainrotEnabled = false
Tabs.Main:Toggle({
    Title = "Auto Farm Brainrot",
    Value = false,
    Callback = function(state)
        autoFarmBrainrotEnabled = state
        if autoFarmBrainrotEnabled then
            pcall(function()
                local slipstreams = workspace:FindFirstChild("Gameplay") and workspace.Gameplay:FindFirstChild("Slipstreams")
                if slipstreams then
                    for _, part in ipairs(slipstreams:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.Size = part.Size + Vector3.new(0, 30, 0)
                            part.CanCollide = true
                        end
                    end
                end
            end)
            task.spawn(function()
                while autoFarmBrainrotEnabled do
                    if not tryAcquireTask("AutoFarm") then
                        task.wait(0.2)
                        continue
                    end
                    
                    pcall(function()
                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            -- 1. Teleport
                            hrp.CFrame = CFrame.new(4, 3, 24)
                            task.wait(0.5)
                            if not autoFarmBrainrotEnabled or _pxhCurrentAutoTask ~= "AutoFarm" then return end
                            
                            -- 2. Hold Charge Button
                            local pg = LocalPlayer:FindFirstChild("PlayerGui")
                            local dashInterface = pg and pg:FindFirstChild("DashInterface")
                            local chargeBtn = dashInterface and dashInterface:FindFirstChild("ChargeButton")
                            local chargeBarFill = dashInterface and dashInterface:FindFirstChild("ChargeBar") and dashInterface.ChargeBar:FindFirstChild("Fill")
                            
                            if chargeBtn and chargeBarFill then
                                local wasCharging = false
                                local chargeStartTime = tick()
                                local holdApplied = false

                                while autoFarmBrainrotEnabled do
                                    if tick() - chargeStartTime > 12 then 
                                        if holdApplied then
                                            simulateHold(chargeBtn, false)
                                            showWarning(false)
                                        end
                                        return -- restart on timeout
                                    end

                                    if not holdApplied then
                                        simulateHold(chargeBtn, true)
                                        showWarning(true)
                                        holdApplied = true
                                        task.wait(0.2)
                                    end
                                    
                                    local scale = chargeBarFill.Size.X.Scale
                                    if scale >= 1 then
                                        break -- fully charged
                                    elseif scale > 0.01 then
                                        wasCharging = true
                                    elseif scale == 0 then
                                        if wasCharging then
                                            break -- fired prematurely
                                        else
                                            -- Hasn't started charging, maybe missed hold!
                                            -- Re-apply hold if 1 second passed and still 0
                                            if tick() - chargeStartTime > 1.0 then
                                                simulateHold(chargeBtn, false)
                                                task.wait(0.1)
                                                holdApplied = false
                                                chargeStartTime = tick() -- reset timer
                                            end
                                        end
                                    end
                                    
                                    task.wait(0.05)
                                    if _pxhCurrentAutoTask ~= "AutoFarm" then break end
                                end
                                
                                if holdApplied then
                                    simulateHold(chargeBtn, false)
                                    showWarning(false)
                                end
                            end
                            if not autoFarmBrainrotEnabled or _pxhCurrentAutoTask ~= "AutoFarm" then return end
                            task.wait(0.2)
                            
                            -- 3. Monitor QTE and wait for Luckyblock lifecycle
                            local luckyblockAppeared = false
                            local qteStartTime = tick()
                            local currentKeyHeld = nil

                            local function releaseKey()
                                if currentKeyHeld then
                                    VirtualInputManager:SendKeyEvent(false, currentKeyHeld, false, game)
                                    currentKeyHeld = nil
                                end
                            end
                            
                            while autoFarmBrainrotEnabled do
                                if tick() - qteStartTime > 12 then 
                                    releaseKey()
                                    return 
                                end -- restart on timeout
                                if _pxhCurrentAutoTask ~= "AutoFarm" then 
                                    releaseKey()
                                    return 
                                end
                                
                                -- Balance on X-axis near -1
                                local currentX = hrp.Position.X
                                if currentX < -3 then
                                    -- Move Right (D)
                                    if currentKeyHeld ~= Enum.KeyCode.D then
                                        releaseKey()
                                        currentKeyHeld = Enum.KeyCode.D
                                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.D, false, game)
                                    end
                                elseif currentX > 1 then
                                    -- Move Left (A)
                                    if currentKeyHeld ~= Enum.KeyCode.A then
                                        releaseKey()
                                        currentKeyHeld = Enum.KeyCode.A
                                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.A, false, game)
                                    end
                                else
                                    -- Balanced enough
                                    releaseKey()
                                end
                                
                                local pgCurrent = LocalPlayer:FindFirstChild("PlayerGui")
                                local qte = pgCurrent and pgCurrent:FindFirstChild("BifrostImageQTE")
                                if qte then
                                    for _, child in ipairs(qte:GetDescendants()) do
                                        if child:IsA("ImageButton") then
                                            simulateClick(child)
                                        end
                                    end
                                end
                                
                                local fof = workspace:FindFirstChild("foffasfieifro")
                                local lb1 = fof and fof:FindFirstChild("Luckyblock")
                                local lb2 = lb1 and lb1:FindFirstChild("Luckyblock")
                                
                                if lb2 then
                                    luckyblockAppeared = true
                                else
                                    if luckyblockAppeared then
                                        -- Luckyblock was deleted
                                        releaseKey()
                                        break
                                    end
                                end
                                task.wait(0.01)
                            end
                            releaseKey()
                            
                            -- Wait 8 seconds after lucky block deleted
                            if autoFarmBrainrotEnabled and _pxhCurrentAutoTask == "AutoFarm" then
                                task.wait(8)
                            end
                        end
                    end)
                    
                    if _pxhCurrentAutoTask == "AutoFarm" then
                        _pxhCurrentAutoTask = "None"
                    end
                    task.wait(0.5)
                end
                if _pxhCurrentAutoTask == "AutoFarm" then _pxhCurrentAutoTask = "None" end
            end)
        end
    end
})

local autoRebirthEnabled = false
Tabs.Main:Toggle({
    Title = "Auto Rebirth",
    Value = false,
    Callback = function(state)
        autoRebirthEnabled = state
        if autoRebirthEnabled then
            task.spawn(function()
                while autoRebirthEnabled do
                    pcall(function()
                        local pg = LocalPlayer:FindFirstChild("PlayerGui")
                        if pg then
                            local bar = pg:FindFirstChild("Rebirth") and
                                        pg.Rebirth:FindFirstChild("Main") and
                                        pg.Rebirth.Main:FindFirstChild("Rebirth") and
                                        pg.Rebirth.Main.Rebirth:FindFirstChild("Contents") and
                                        pg.Rebirth.Main.Rebirth.Contents:FindFirstChild("BarInfo") and
                                        pg.Rebirth.Main.Rebirth.Contents.BarInfo:FindFirstChild("BarProgression") and
                                        pg.Rebirth.Main.Rebirth.Contents.BarInfo.BarProgression:FindFirstChild("Bar")

                            if bar and bar:IsA("GuiObject") then
                                if bar.Size.X.Scale >= 1 and bar.Size.Y.Scale >= 1 then
                                    local URebirth = ReplicatedStorage:FindFirstChild("RemoteGUI") and ReplicatedStorage.RemoteGUI:FindFirstChild("URebirth")
                                    if URebirth then
                                        URebirth:FireServer()
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

local autoTreadMillEnabled = false
Tabs.Main:Toggle({
    Title = "Auto TreadMill (2x Fire)",
    Value = false,
    Callback = function(state)
        autoTreadMillEnabled = state
        if autoTreadMillEnabled then
            task.spawn(function()
                local lastClickTick = 0
                while autoTreadMillEnabled do
                    pcall(function()
                        local pg = LocalPlayer:FindFirstChild("PlayerGui")
                        if pg then
                            local function checkAndClick(uiName)
                                if tick() - lastClickTick < 1 then return false end
                                local tmQte = pg:FindFirstChild(uiName)
                                if tmQte and tmQte:IsA("ScreenGui") and tmQte.Enabled then
                                    local frame = tmQte:FindFirstChild("Frame")
                                    if frame then
                                        local imgBtn = frame:FindFirstChild("ImageButton")
                                        if imgBtn and imgBtn:IsA("ImageButton") and imgBtn.Visible then
                                            simulateClick(imgBtn)
                                            lastClickTick = tick()
                                            return true
                                        end
                                    end
                                end
                                return false
                            end

                            if not checkAndClick("TreadmillQTE_Icon") then
                                checkAndClick("TreadmillQTE_Icon_copy")
                            end
                        end
                    end)
                    task.wait(0.05)
                end
            end)
        end
    end
})

local autoCollectCashEnabled = false
Tabs.Main:Toggle({
    Title = "Auto Collect Cash",
    Value = false,
    Callback = function(state)
        autoCollectCashEnabled = state
        if autoCollectCashEnabled then
            task.spawn(function()
                while autoCollectCashEnabled do
                    pcall(function()
                        local base = getPlayerBase()
                        if base then
                            local modelStands = base:FindFirstChild("ModelStands")
                            if modelStands then
                                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    for _, modelStand in ipairs(modelStands:GetChildren()) do
                                        local standClaim = modelStand:FindFirstChild("StandClaim")
                                        local hitbox = standClaim and standClaim:FindFirstChild("StandClaimHitbox")
                                        
                                        if hitbox and hitbox:FindFirstChild("TouchInterest") then
                                            if firetouchinterest then
                                                firetouchinterest(hitbox, hrp, 0)
                                                if isMobile then
                                                    task.wait(0.05)
                                                    firetouchinterest(hitbox, hrp, 1)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(3)
                end
            end)
        end
    end
})


local autoUpgradeBrainrotEnabled = false
Tabs.Main:Toggle({
    Title = "Auto Upgrade Brainrot",
    Value = false,
    Callback = function(state)
        autoUpgradeBrainrotEnabled = state
        print("[PXH] Auto Upgrade State Changed to:", state)
        if autoUpgradeBrainrotEnabled then
            task.spawn(function()
                local continuousUpgrades = 0
                local lastUpgradeTick = tick()
                while autoUpgradeBrainrotEnabled do
                    local didUpgrade = false
                    
                    if autoFarmBrainrotEnabled then
                        print("[PXH] Auto Farm is toggled ON. Auto Upgrade is paused.")
                        task.wait(1)
                        continue
                    end
                    
                    if not tryAcquireTask("AutoUpgrade") then
                        task.wait(0.5)
                        continue
                    end

                    pcall(function()
                        print("[PXH] --- Auto Upgrade Cycle Started ---")
                        local myBase = getPlayerBase()
                        if not myBase then 
                            print("[PXH] Could not find myBase. Skipping cycle.")
                            return 
                        end
                        print("[PXH] myBase found!")
                        
                        local ls = LocalPlayer:FindFirstChild("leaderstats")
                        local cashObj = ls and ls:FindFirstChild("Money")
                        local playerCash = 0
                        if cashObj then
                            if type(cashObj.Value) == "number" then playerCash = cashObj.Value 
                            else playerCash = parseBrainrotValue(tostring(cashObj.Value)) end
                            print("[PXH] Player Money detected:", playerCash)
                        else
                            print("[PXH] Could not find leaderstats.Money. Assuming Money = 0.")
                        end
                        
                        local modelStands = myBase:FindFirstChild("ModelStands")
                        if not modelStands then 
                            print("[PXH] Could not find ModelStands in myBase.")
                            return 
                        end
                        
                        print("[PXH] Checking all ModelStands sequentially...")
                        for _, ms in ipairs(modelStands:GetChildren()) do
                            if not autoUpgradeBrainrotEnabled or _pxhCurrentAutoTask ~= "AutoUpgrade" then break end
                            
                            local upg = ms:FindFirstChild("Upgrade")
                            local surfaceGui = upg and upg:FindFirstChild("SurfaceGui")
                            local main = surfaceGui and surfaceGui:FindFirstChild("Main")
                            local btn = main and main:FindFirstChild("Btn_Upgrade")
                            local txtPrice = btn and btn:FindFirstChild("Txt_UpgradePrice")
                            
                            if upg and upg:IsA("BasePart") and txtPrice and txtPrice:IsA("TextLabel") and txtPrice.Text ~= "" and txtPrice.Text ~= "Max" then
                                local pVal = parseBrainrotValue(txtPrice.Text)
                                
                                -- Re-fetch cash to check during loop execution
                                local ls = LocalPlayer:FindFirstChild("leaderstats")
                                local cashObj = ls and ls:FindFirstChild("Money")
                                local currentCash = 0
                                if cashObj then
                                    if type(cashObj.Value) == "number" then currentCash = cashObj.Value 
                                    else currentCash = parseBrainrotValue(tostring(cashObj.Value)) end
                                end
                                
                                if pVal > 0 and pVal <= currentCash then
                                    print("[PXH] Upgrading Stand:", ms.Name, "|| Price:", pVal)
                                    
                                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                    if hrp then
                                        -- Teleport directly to the 'Upgrade' part
                                        hrp.CFrame = upg.CFrame * CFrame.new(0, 1, 0)
                                        task.wait(0.2) -- Wait briefly after teleport
                                        
                                        local ls2 = LocalPlayer:FindFirstChild("leaderstats")
                                        local finalCashObj = ls2 and ls2:FindFirstChild("Money")
                                        local finalCash = 0
                                        if finalCashObj then
                                            if type(finalCashObj.Value) == "number" then finalCash = finalCashObj.Value 
                                            else finalCash = parseBrainrotValue(tostring(finalCashObj.Value)) end
                                        end
                                        
                                        if pVal <= finalCash then
                                            local args = { myBase, ms }
                                            local rs = ReplicatedStorage:FindFirstChild("Remotes")
                                            local upgRemote = rs and rs:FindFirstChild("UpgradeBrainrotRemote")
                                            if upgRemote then
                                                upgRemote:FireServer(unpack(args))
                                                print("[PXH] Remote Fired for:", ms.Name)
                                                didUpgrade = true
                                            end
                                        else
                                            print("[PXH] Cash dropped before upgrade. Skipping.")
                                        end
                                        task.wait(0.1) -- Brief wait before checking next stand
                                    end
                                end
                            end
                        end
                    end)
                    
                    if _pxhCurrentAutoTask == "AutoUpgrade" then
                        _pxhCurrentAutoTask = "None"
                    end
                    
                    print("[PXH] Cycle Ended.")
                    if didUpgrade then
                        print("[PXH] Waiting 0.3 seconds (Fast Speed)")
                        task.wait(0.3)
                    else
                        print("[PXH] Waiting 0.3 seconds")
                        task.wait(0.3)
                    end
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
