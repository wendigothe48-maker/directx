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

local cachedSelfPlot = nil
local function getSelfPlot()
    if cachedSelfPlot and cachedSelfPlot.Parent then
        return cachedSelfPlot
    end

    print("[Plot Detection] Searching for player's plot...")
    local plotsFolder = workspace:FindFirstChild("Plots")
    if not plotsFolder then 
        print("[Plot Detection] 'Plots' folder not found in workspace!")
        return nil 
    end
    for _, plot in ipairs(plotsFolder:GetChildren()) do
        local expandSigns = plot:FindFirstChild("ExpandSigns")
        if expandSigns then
            for _, sign in ipairs(expandSigns:GetChildren()) do
                local triggerPart = sign:FindFirstChild("TriggerPart")
                if triggerPart and triggerPart.CanCollide == true then
                    print("[Plot Detection] Found Self Plot: " .. plot.Name .. " via " .. sign.Name)
                    cachedSelfPlot = plot
                    return plot
                end
            end
        end
    end
    print("[Plot Detection] No plot found where TriggerPart.CanCollide == true")
    return nil
end

local function getPlayerMoney()
    local lp = game:GetService("Players").LocalPlayer
    local moneyStat = lp:FindFirstChild("leaderstats") and lp.leaderstats:FindFirstChild("Money")
    if moneyStat then
        local moneyStr = tostring(moneyStat.Value)
        moneyStr = string.gsub(moneyStr, "%$", "")
        if NumberConverter then
            return NumberConverter.Parse(moneyStr)
        else
            return tonumber(moneyStr) or 0
        end
    end
    return 0
end

local MainSection = Tabs.Main:Section({
    Title = "Auto Farm",
    Box = true,
    BoxBorder = true,
    Expandable = true,
    Opened = true
})

_G.AutoPaint = false
MainSection:Toggle({
    Title = "Auto Paint",
    Value = false,
    Callback = function(Value)
        _G.AutoPaint = Value
        if Value then

            task.spawn(function()
                local camera = workspace.CurrentCamera
                local spectatorPart = nil
                local spectatorConn = nil
                local lastTpTime = 0

                local function enableSpectatorMode()
                    if spectatorPart then return end
                    local lp = game:GetService("Players").LocalPlayer
                    local char = lp.Character
                    if not char then return end

                    spectatorPart = Instance.new("Part")
                    spectatorPart.Size = Vector3.new(1, 1, 1)
                    spectatorPart.Transparency = 1
                    spectatorPart.Anchored = true
                    spectatorPart.CanCollide = false
                    
                    if char:FindFirstChild("HumanoidRootPart") then
                        spectatorPart.CFrame = char.HumanoidRootPart.CFrame
                    else
                        spectatorPart.CFrame = camera.CFrame
                    end
                    spectatorPart.Parent = workspace

                    camera.CameraSubject = spectatorPart
                    camera.CameraType = Enum.CameraType.Custom

                    local uis = cloneref(game:GetService("UserInputService"))
                    local rs = cloneref(game:GetService("RunService"))
                    
                    spectatorConn = rs.RenderStepped:Connect(function(dt)
                        if not spectatorPart then return end
                        local moveDir = Vector3.new(0, 0, 0)
                        
                        if uis:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Vector3.new(0, 0, -1) end
                        if uis:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir + Vector3.new(0, 0, 1) end
                        if uis:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir + Vector3.new(-1, 0, 0) end
                        if uis:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Vector3.new(1, 0, 0) end
                        
                        local actualMove = Vector3.new(0, 0, 0)
                        
                        if moveDir.Magnitude > 0 then
                            moveDir = moveDir.Unit
                            local camCFrame = camera.CFrame
                            local lookVector = camCFrame.LookVector
                            local rightVector = camCFrame.RightVector
                            
                            local flatLook = Vector3.new(lookVector.X, 0, lookVector.Z)
                            if flatLook.Magnitude > 0 then flatLook = flatLook.Unit end
                            
                            local flatRight = Vector3.new(rightVector.X, 0, rightVector.Z)
                            if flatRight.Magnitude > 0 then flatRight = flatRight.Unit end
                            
                            actualMove = (flatLook * -moveDir.Z) + (flatRight * moveDir.X)
                        else
                            if char and char:FindFirstChild("Humanoid") then
                                actualMove = char.Humanoid.MoveDirection
                            end
                        end
                        
                        if uis:IsKeyDown(Enum.KeyCode.E) then actualMove = actualMove + Vector3.new(0, 1, 0) end
                        if uis:IsKeyDown(Enum.KeyCode.Q) then actualMove = actualMove + Vector3.new(0, -1, 0) end

                        if actualMove.Magnitude > 0 then
                            if actualMove.Magnitude > 1 then actualMove = actualMove.Unit end
                            spectatorPart.CFrame = spectatorPart.CFrame + (actualMove * 60 * dt)
                        end
                    end)
                end

                local function disableSpectatorMode()
                    if spectatorConn then
                        spectatorConn:Disconnect()
                        spectatorConn = nil
                    end
                    if spectatorPart then
                        spectatorPart:Destroy()
                        spectatorPart = nil
                    end
                    local lp = game:GetService("Players").LocalPlayer
                    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                        camera.CameraSubject = lp.Character.Humanoid
                    end
                    camera.CameraType = Enum.CameraType.Custom
                end

                while _G.AutoPaint do
                    if _G.PauseAutoPaint then
                        disableSpectatorMode()
                        while _G.PauseAutoPaint and _G.AutoPaint do
                            task.wait(0.5)
                        end
                    end
                    if not _G.AutoPaint then break end
                    
                    local ok, err = pcall(function()
                        local lp = game:GetService("Players").LocalPlayer
                        local selfPlot = getSelfPlot()
                        if not selfPlot then return end
                        
                        local paintBarInner = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("HUD") and lp.PlayerGui.HUD:FindFirstChild("PaintBar") and lp.PlayerGui.HUD.PaintBar:FindFirstChild("Inner")
                        
                        local needsRefill = false
                        if paintBarInner and paintBarInner:IsA("GuiObject") then
                            if paintBarInner.Size.X.Scale <= 0.1 then
                                needsRefill = true
                            end
                        end
                        
                        if needsRefill then
                            disableSpectatorMode()
                            local refillSpot = selfPlot:FindFirstChild("PaintTank") and selfPlot.PaintTank:FindFirstChild("RefillSpot")
                            if refillSpot and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                                lp.Character.HumanoidRootPart.CFrame = refillSpot.CFrame + Vector3.new(0, 3, 0)

                                local refillStart = tick()
                                while _G.AutoPaint do
                                    if _G.PauseAutoPaint then
                                        while _G.PauseAutoPaint and _G.AutoPaint do task.wait(0.2) end
                                        if refillSpot and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                                            lp.Character.HumanoidRootPart.CFrame = refillSpot.CFrame + Vector3.new(0, 3, 0)
                                        end
                                        refillStart = tick()
                                    end
                                    task.wait(0.1)
                                    if paintBarInner and paintBarInner.Size.X.Scale >= 0.95 then
                                        break
                                    elseif not paintBarInner then
                                        break
                                    elseif tick() - refillStart > 10 then

                                        break
                                    end
                                end
                            end
                        else
                            local keycapsFolder = selfPlot:FindFirstChild("Keycaps")
                            if keycapsFolder then
                                local remoteFolder = game:GetService("ReplicatedStorage"):FindFirstChild("shared/network/MiscNetwork@GlobalMiscEvents")
                                if remoteFolder then
                                    local stepEvent = remoteFolder:FindFirstChild("StepKeycap")
                                    if stepEvent then
                                        local keycaps = keycapsFolder:GetChildren()

                                        
                                        if #keycaps > 0 then
                                            enableSpectatorMode()
                                        else
                                            if lastTpTime and (tick() - lastTpTime >= 1) then
                                                disableSpectatorMode()
                                            end
                                            task.wait(0.5)
                                        end

                                        for _, keycap in ipairs(keycaps) do
                                            if not _G.AutoPaint then break end
                                            
                                            if _G.PauseAutoPaint then
                                                disableSpectatorMode()
                                                while _G.PauseAutoPaint and _G.AutoPaint do
                                                    task.wait(0.2)
                                                end
                                                if not _G.AutoPaint then break end
                                                enableSpectatorMode()
                                            end

                                            if paintBarInner and paintBarInner.Size.X.Scale <= 0.1 then
                                                break
                                            end


                                            
                                            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                                                if keycap:IsA("BasePart") then
                                                    lp.Character.HumanoidRootPart.CFrame = keycap.CFrame + Vector3.new(0, 3, 0)
                                                elseif keycap:IsA("Model") and keycap.PrimaryPart then
                                                    lp.Character.HumanoidRootPart.CFrame = keycap.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
                                                end
                                            end
                                            
                                            stepEvent:FireServer(keycap)
                                            lastTpTime = tick()
                                            task.wait(0.1)
                                        end
                                    else
                                        task.wait(1)
                                    end
                                else

                                    task.wait(1)
                                end
                            else

                                task.wait(1)
                            end
                        end
                    end)
                    if not ok then

                        disableSpectatorMode()
                        task.wait(1)
                    end
                end
                
                disableSpectatorMode()

            end)
        end
    end
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
                        local rebirthFrame = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("Main") and lp.PlayerGui.Main:FindFirstChild("Rebirth") and lp.PlayerGui.Main.Rebirth:FindFirstChild("MoneyRequiredBar") and lp.PlayerGui.Main.Rebirth.MoneyRequiredBar:FindFirstChild("Frame")
                        if rebirthFrame and rebirthFrame:IsA("GuiObject") then
                            if rebirthFrame.Size.X.Scale >= 1 then
                                local args = { 0 }
                                local remote = game:GetService("ReplicatedStorage"):FindFirstChild("shared/network/MiscNetwork@GlobalMiscFunctions")
                                if remote then
                                    local reqRebirth = remote:FindFirstChild("RequestRebirth")
                                    if reqRebirth then
                                        reqRebirth:FireServer(unpack(args))
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

_G.AutoExpandLand = false
MainSection:Toggle({
    Title = "Auto Expand Land",
    Value = false,
    Callback = function(Value)
        _G.AutoExpandLand = Value
        if Value then
            task.spawn(function()
                while _G.AutoExpandLand do
                    pcall(function()
                        local lp = game:GetService("Players").LocalPlayer
                        local selfPlot = getSelfPlot()
                        if selfPlot then
                            local expandSigns = selfPlot:FindFirstChild("ExpandSigns")
                            if expandSigns then
                                for _, sign in ipairs(expandSigns:GetChildren()) do
                                    if string.match(sign.Name, "ExpandSign_") then
                                        local tpPart = sign:FindFirstChild("TriggerPart")
                                        if tpPart then
                                            local prompt = tpPart:FindFirstChildWhichIsA("ProximityPrompt")
                                            local surfaceGui = tpPart:FindFirstChild("SurfaceGui")
                                            local frame = surfaceGui and surfaceGui:FindFirstChild("Frame")
                                            local costLabel = frame and frame:FindFirstChild("Cost")
                                            
                                            if costLabel and costLabel:IsA("TextLabel") and prompt then
                                                local costText = costLabel.Text
                                                if string.match(costText, "%$") then
                                                    local cleanPrice = string.gsub(costText, "%$", "")
                                                    local priceNum = NumberConverter and NumberConverter.Parse(cleanPrice) or tonumber(cleanPrice)
                                                    
                                                    if priceNum and getPlayerMoney() >= priceNum then
                                                        _G.PauseAutoPaint = true
                                                        task.wait(1)
                                                        if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                                                            lp.Character.HumanoidRootPart.CFrame = tpPart.CFrame + Vector3.new(0, 3, 0)
                                                            task.wait(0.5)
                                                            fireproximityprompt(prompt, 0)
                                                            task.wait(1)
                                                        end
                                                        _G.PauseAutoPaint = false
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(1)
                end
                _G.PauseAutoPaint = false
            end)
        end
    end
})

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

_G.AutoBuyPaint = false
Tabs.Shop:Toggle({
    Title = "Auto Buy Paint",
    Value = false,
    Callback = function(Value)
        _G.AutoBuyPaint = Value
        if Value then
            task.spawn(function()
                while _G.AutoBuyPaint do
                    pcall(function()
                        local lp = game:GetService("Players").LocalPlayer
                        local frames = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("Main")
                        local buyPaint = frames and frames:FindFirstChild("BuyPaint")
                        local scrollingFrame = buyPaint and buyPaint:FindFirstChild("ScrollingFrame")
                        
                        if scrollingFrame then
                            local myMoney = getPlayerMoney()
                            local bestAffordable = nil
                            local highestStatAffordable = -1
                            
                            local bestEquipped = nil
                            local highestStatEquipped = -1

                            for _, child in ipairs(scrollingFrame:GetChildren()) do
                                if child:IsA("Frame") or child:IsA("ImageLabel") then
                                    local rebirthReq = child:FindFirstChild("RebirthRequired")
                                    if not (rebirthReq and rebirthReq.Visible) then
                                        local content = child:FindFirstChild("Content")
                                        if content then
                                            local moneyLabel = content:FindFirstChild("MoneyPerStep")
                                            local buttons = content:FindFirstChild("Buttons")
                                            local buyBtn = buttons and buttons:FindFirstChild("Buy")
                                            
                                            if moneyLabel and moneyLabel:IsA("TextLabel") and buyBtn and buyBtn.Visible then
                                                local moneyText = moneyLabel.Text
                                                moneyText = string.gsub(moneyText, "%+%$", "")
                                                moneyText = string.gsub(moneyText, "/step", "")
                                                local statValue = NumberConverter and NumberConverter.Parse(moneyText) or tonumber(moneyText) or 0
                                                
                                                local costLabel = buyBtn:FindFirstChild("Cost")
                                                if costLabel and costLabel:IsA("TextLabel") then
                                                    local costText = costLabel.Text
                                                    local isEquipped = (costText == "EQUIPPED")
                                                    local isOwned = (costText == "EQUIP")
                                                    local price = math.huge
                                                    
                                                    if not isEquipped and not isOwned then
                                                        local pText = string.gsub(costText, "%$", "")
                                                        price = NumberConverter and NumberConverter.Parse(pText) or math.huge
                                                    end
                                                    
                                                    if isEquipped then
                                                        if statValue > highestStatEquipped then
                                                            highestStatEquipped = statValue
                                                            bestEquipped = child.Name
                                                        end
                                                    end
                                                    
                                                    if isOwned then
                                                        if statValue > highestStatAffordable then
                                                            highestStatAffordable = statValue
                                                            bestAffordable = {Name = child.Name, Action = "Equip"}
                                                        end
                                                    elseif price <= myMoney then
                                                        if statValue > highestStatAffordable then
                                                            highestStatAffordable = statValue
                                                            bestAffordable = {Name = child.Name, Action = "Buy"}
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            
                            if bestAffordable and highestStatAffordable > highestStatEquipped then
                                if bestAffordable.Action == "Equip" then
                                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("shared/network/MiscNetwork@GlobalMiscEvents")
                                    if remote then
                                        local equipEvent = remote:FindFirstChild("EquipPaint")
                                        if equipEvent then
                                            equipEvent:FireServer(bestAffordable.Name)
                                        end
                                    end
                                elseif bestAffordable.Action == "Buy" then
                                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("shared/network/MiscNetwork@GlobalMiscEvents")
                                    if remote then
                                        local buyEvent = remote:FindFirstChild("BuyPaint")
                                        if buyEvent then
                                            buyEvent:FireServer(bestAffordable.Name)
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

local ShopSection = Tabs.Shop:Section({
    Title = "Upgrades",
    Box = true,
    BoxBorder = true,
    Expandable = true,
    Opened = true
})

_G.AutoUpgradeWorkers = false
ShopSection:Toggle({
    Title = "Auto Upgrade Workers",
    Value = false,
    Callback = function(Value)
        _G.AutoUpgradeWorkers = Value
        if Value then
            task.spawn(function()
                while _G.AutoUpgradeWorkers do
                    pcall(function()
                        local lp = game:GetService("Players").LocalPlayer
                        local frames = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("Main")
                        local workers = frames and frames:FindFirstChild("Workers")
                        local hireWorkers = workers and workers:FindFirstChild("HireWorkers")
                        local oneWorker = hireWorkers and hireWorkers:FindFirstChild("+1Worker")
                        local costLabel = oneWorker and oneWorker:FindFirstChild("Cost")
                        
                        if costLabel and costLabel:IsA("TextLabel") then
                            local costText = costLabel.Text
                            if string.lower(costText) ~= "max" and string.lower(costText) ~= "maxed" then
                                local cleanPrice = string.gsub(costText, "%$", "")
                                local priceNum = NumberConverter and NumberConverter.Parse(cleanPrice) or tonumber(cleanPrice)
                                
                                if priceNum and getPlayerMoney() >= priceNum then
                                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("shared/network/MiscNetwork@GlobalMiscEvents")
                                    if remote then
                                        local hireWorkerEvent = remote:FindFirstChild("HireWorker")
                                        if hireWorkerEvent then
                                            hireWorkerEvent:FireServer()
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.2)
                end
            end)
        end
    end
})

local upgradesToAuto = {
    {"Walk Speed", "WalkSpeed"},
    {"Roller Size", "RollerSize"},
    {"Paint Tank", "PaintTankSize"},
    {"Worker Speed", "WorkerSpeed"}
}

for _, upg in ipairs(upgradesToAuto) do
    local titleName = upg[1]
    local frameName = upg[2]
    local toggleVar = "AutoUpgrade_" .. frameName
    
    _G[toggleVar] = false
    ShopSection:Toggle({
        Title = "Auto Upgrade " .. titleName,
        Value = false,
        Callback = function(Value)
            _G[toggleVar] = Value
            if Value then
                task.spawn(function()
                    while _G[toggleVar] do
                        pcall(function()
                            local lp = game:GetService("Players").LocalPlayer
                            local upgFrame = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("Main") and lp.PlayerGui.Main:FindFirstChild("Upgrades") and lp.PlayerGui.Main.Upgrades:FindFirstChild("Frame")
                            if upgFrame then
                                local specificFrame = upgFrame:FindFirstChild(frameName)
                                local buyBtn = specificFrame and specificFrame:FindFirstChild("Buy")
                                local costLabel = buyBtn and buyBtn:FindFirstChild("Cost")
                                
                                if costLabel and costLabel:IsA("TextLabel") then
                                    local costText = costLabel.Text
                                    if string.lower(costText) ~= "max" and string.lower(costText) ~= "maxed" then
                                        local cleanPrice = string.gsub(costText, "%$", "")
                                        local priceNum = NumberConverter and NumberConverter.Parse(cleanPrice) or tonumber(cleanPrice) or math.huge
                                        
                                        if getPlayerMoney() >= priceNum then
                                            local remote = game:GetService("ReplicatedStorage"):FindFirstChild("shared/network/MiscNetwork@GlobalMiscEvents")
                                            if remote then
                                                local buyEvent = remote:FindFirstChild("BuyUpgrade")
                                                if buyEvent then
                                                    buyEvent:FireServer(frameName)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                        task.wait(0.2)
                    end
                end)
            end
        end
    })
end

local RollSection = Tabs.Shop:Section({
    Title = "Roll Upgrades",
    Box = true,
    BoxBorder = true,
    Expandable = true,
    Opened = true
})

local function getRollUpgradeCost(upgradeName)
    local selfPlot = getSelfPlot()
    if selfPlot then
        local rng = selfPlot:FindFirstChild("RNG")
        local upgrades = rng and rng:FindFirstChild("Upgrades")
        if upgrades then
            for _, part in ipairs(upgrades:GetChildren()) do
                if string.match(part.Name, "Part") then
                    local surfaceGui = part:FindFirstChild("SurfaceGui")
                    local frame = surfaceGui and surfaceGui:FindFirstChild("Frame")
                    local specificUpgrade = frame and frame:FindFirstChild(upgradeName)
                    local buyBtn = specificUpgrade and specificUpgrade:FindFirstChild("Buy")
                    local costLabel = buyBtn and buyBtn:FindFirstChild("Cost")
                    if costLabel and costLabel:IsA("TextLabel") then
                        local costText = costLabel.Text
                        if string.lower(costText) ~= "max" and string.lower(costText) ~= "maxed" then
                            local cleanPrice = string.gsub(costText, "%$", "")
                            local priceNum = NumberConverter and NumberConverter.Parse(cleanPrice) or tonumber(cleanPrice)
                            if priceNum then
                                return priceNum
                            end
                        end
                    end
                end
            end
        end
    end
    return nil
end

_G.AutoUpgradeRollLuck = false
RollSection:Toggle({
    Title = "Auto Upgrade Roll Luck",
    Value = false,
    Callback = function(Value)
        _G.AutoUpgradeRollLuck = Value
        if Value then
            task.spawn(function()
                while _G.AutoUpgradeRollLuck do
                    pcall(function()
                        local cost = getRollUpgradeCost("RollLuck")
                        if cost and getPlayerMoney() >= cost then
                            local remote = game:GetService("ReplicatedStorage"):FindFirstChild("shared/network/MiscNetwork@GlobalMiscEvents")
                            if remote then
                                local buyEvent = remote:FindFirstChild("BuyRNGUpgrade")
                                if buyEvent then
                                    buyEvent:FireServer("RollLuck")
                                end
                            end
                        end
                    end)
                    task.wait(0.2)
                end
            end)
        end
    end
})

_G.AutoUpgradeRollSpeed = false
RollSection:Toggle({
    Title = "Auto Upgrade Roll Speed",
    Value = false,
    Callback = function(Value)
        _G.AutoUpgradeRollSpeed = Value
        if Value then
            task.spawn(function()
                while _G.AutoUpgradeRollSpeed do
                    pcall(function()
                        local cost = getRollUpgradeCost("RollSpeed")
                        if cost and getPlayerMoney() >= cost then
                            local remote = game:GetService("ReplicatedStorage"):FindFirstChild("shared/network/MiscNetwork@GlobalMiscEvents")
                            if remote then
                                local buyEvent = remote:FindFirstChild("BuyRNGUpgrade")
                                if buyEvent then
                                    buyEvent:FireServer("RollSpeed")
                                end
                            end
                        end
                    end)
                    task.wait(0.2)
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