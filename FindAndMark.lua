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
    Main = Window:Tab({ Title = "Main", Icon = "solar:home-2-bold" }),
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

local MainSection = Tabs.Main:Section({
    Title = "Auto Join",
    Box = true,
    BoxBorder = true,
    Expandable = true,
    Opened = true
})

local minBounds = Vector3.new(math.min(-76, 34), math.min(-9, 79), math.min(64, -150))
local maxBounds = Vector3.new(math.max(-76, 34), math.max(-9, 79), math.max(64, -150))

local function isWithinRegion(pos)
    return pos.X >= minBounds.X and pos.X <= maxBounds.X and
           pos.Y >= minBounds.Y and pos.Y <= maxBounds.Y and
           pos.Z >= minBounds.Z and pos.Z <= maxBounds.Z
end

_G.ClickMethod = "Fire Virtually"
_G.PickMarkSpeed = "No Delay"
_G.AutoJoin = false
_G.AutoMarkX = false
_G.AutoFind = false
_G.AutoPick = false
local waitingTables = {}

MainSection:Toggle({
    Title = "Auto Join",
    Value = false,
    Callback = function(Value)
        _G.AutoJoin = Value
        if Value then
            task.spawn(function()
                while _G.AutoJoin do
                    pcall(function()
                        local lp = game:GetService("Players").LocalPlayer
                        local char = lp.Character
                        local hum = char and char:FindFirstChild("Humanoid")
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if not hum or not hrp then return end
                        
                        local gameTablesFolder = workspace:FindFirstChild("GameTables")
                        if not gameTablesFolder then return end
                        
                        local mySeat = hum.SeatPart
                        local myTable = nil
                        
                        if mySeat and mySeat.Parent and mySeat.Parent.Parent and mySeat.Parent.Parent.Parent == gameTablesFolder then
                            myTable = mySeat.Parent.Parent
                        end
                        
                        if myTable then
                            local barriers = myTable:FindFirstChild("Barriers")
                            local block = barriers and barriers:FindFirstChild("Block")
                            if block and block.CanCollide == true then
                                return
                            end
                        end
                        
                        local bestTargetTable = nil
                        local bestTargetChair = nil
                        local longestWait = 0
                        local anyEmptyTable = nil
                        local anyEmptyChair = nil
                        
                        for idx, tbl in ipairs(gameTablesFolder:GetChildren()) do
                            if idx % 10 == 0 then task.wait() end
                            local chair1 = tbl:FindFirstChild("Chair1")
                            local chair2 = tbl:FindFirstChild("Chair2")
                            local seat1 = chair1 and chair1:FindFirstChild("Seat")
                            local seat2 = chair2 and chair2:FindFirstChild("Seat")
                            local barriers = tbl:FindFirstChild("Barriers")
                            local block = barriers and barriers:FindFirstChild("Block")
                            
                            if seat1 and seat2 and block then
                                if isWithinRegion(block.Position) then
                                    local weld1 = seat1:FindFirstChild("SeatWeld")
                                    local weld2 = seat2:FindFirstChild("SeatWeld")
                                    
                                    local isMe1 = weld1 and mySeat == seat1
                                    local isMe2 = weld2 and mySeat == seat2
                                    local someoneElse1 = weld1 and not isMe1
                                    local someoneElse2 = weld2 and not isMe2
                                    
                                    if someoneElse1 and not weld2 then
                                        if not waitingTables[tbl] then waitingTables[tbl] = tick() end
                                        local waitTime = tick() - waitingTables[tbl]
                                        if waitTime >= 2 and waitTime > longestWait then
                                            longestWait = waitTime
                                            bestTargetTable = tbl
                                            bestTargetChair = seat2
                                        end
                                    elseif someoneElse2 and not weld1 then
                                        if not waitingTables[tbl] then waitingTables[tbl] = tick() end
                                        local waitTime = tick() - waitingTables[tbl]
                                        if waitTime >= 2 and waitTime > longestWait then
                                            longestWait = waitTime
                                            bestTargetTable = tbl
                                            bestTargetChair = seat1
                                        end
                                    else
                                        waitingTables[tbl] = nil
                                        if not weld1 and not weld2 then
                                            anyEmptyTable = tbl
                                            anyEmptyChair = seat1
                                        end
                                    end
                                end
                            end
                        end
                        
                        for tbl, _ in pairs(waitingTables) do
                            if not tbl.Parent or tbl.Parent ~= gameTablesFolder then
                                waitingTables[tbl] = nil
                            end
                        end
                        
                        if bestTargetChair then
                            if myTable ~= bestTargetTable then
                                if mySeat then
                                    hum.Sit = false
                                    task.wait(0.1)
                                    hum.Jump = true
                                    task.wait(0.3)
                                end
                                fireTouch(bestTargetChair, hrp)
                            end
                        elseif not mySeat and anyEmptyChair then
                            fireTouch(anyEmptyChair, hrp)
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

MainSection:Dropdown({
    Title = "Click Method",
    Values = {"Fire Virtually", "Fire Touch"},
    Value = "Fire Virtually",
    Callback = function(Value)
        _G.ClickMethod = Value
    end
})

MainSection:Dropdown({
    Title = "Pick & Mark Speed",
    Values = {"Slow", "Normal", "Fast", "No Delay"},
    Value = "No Delay",
    Callback = function(Value)
        _G.PickMarkSpeed = Value
    end
})

local function applySpeedDelay()
    if _G.PickMarkSpeed == "Fast" then
        task.wait(math.random(25, 30) / 10)
    elseif _G.PickMarkSpeed == "Normal" then
        task.wait(math.random(29, 35) / 10)
    elseif _G.PickMarkSpeed == "Slow" then
        task.wait(math.random(35, 49) / 10)
    end
end


local function safeClickPart(part, clickDetector)
    if not part then return end
    if _G.ClickMethod == "Fire Virtually" then
        if clickDetector then
            fireclickdetector(clickDetector)
        end
    else
        local cam = workspace.CurrentCamera
        if not cam then return end
        
        -- Point camera at part
        cam.CFrame = CFrame.lookAt(cam.CFrame.Position, part.Position)
        task.wait(0.05)
        
        local screenPos, onScreen = cam:WorldToScreenPoint(part.Position)
        if onScreen then
            local x = screenPos.X
            local y = screenPos.Y
            local GuiService = game:GetService("GuiService")
            y = y + GuiService:GetGuiInset().Y
            
            local UIS = game:GetService("UserInputService")
            local VirtualInputManager = game:GetService("VirtualInputManager")
            
            if UIS.TouchEnabled and not UIS.MouseEnabled then
                local mobileTouchId = 55555
                VirtualInputManager:SendTouchEvent(mobileTouchId, 0, x, y)
                task.wait(0.02)
                VirtualInputManager:SendTouchEvent(mobileTouchId, 2, x, y)
            else
                VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
                task.wait(0.02)
                VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
            end
        end
    end
end

MainSection:Toggle({
    Title = "Auto Mark X",
    Value = false,
    Callback = function(Value)
        _G.AutoMarkX = Value
    end
})

MainSection:Toggle({
    Title = "Auto Find",
    Value = false,
    Callback = function(Value)
        _G.AutoFind = Value
    end
})

MainSection:Toggle({
    Title = "Auto Pick",
    Value = false,
    Callback = function(Value)
        _G.AutoPick = Value
    end
})

task.spawn(function()
    while true do
        pcall(function()
            local lp = game:GetService("Players").LocalPlayer
            if not lp then return end
            
            local topTextObj = lp:FindFirstChild("PlayerGui") 
                and lp.PlayerGui:FindFirstChild("Main GUI") 
                and lp.PlayerGui["Main GUI"]:FindFirstChild("Text") 
                and lp.PlayerGui["Main GUI"].Text:FindFirstChild("Top Text")
                
            if topTextObj and topTextObj.Visible then
                local text = topTextObj.Text
                
                local char = lp.Character
                local hum = char and char:FindFirstChild("Humanoid")
                local mySeat = hum and hum.SeatPart
                
                local myTable = nil
                local myChair = nil
                if mySeat and mySeat.Parent and mySeat.Parent.Parent and mySeat.Parent.Parent.Parent == workspace:FindFirstChild("GameTables") then
                    myChair = mySeat.Parent
                    myTable = myChair.Parent
                end
                
                if myTable and myChair then
                    if _G.AutoMarkX and string.find(string.lower(text), "mark x's!") then
                        local gridName = (myChair.Name == "Chair2") and "Grid2" or "Grid1"
                        local grid = myTable:FindFirstChild(gridName)
                        if grid then
                            local cellsToProcess = {}
                            for i = 1, 300 do
                                local cell = grid:FindFirstChild("Cell" .. i)
                                if cell then
                                    local sg = cell:FindFirstChild("SurfaceGui")
                                    local tl = sg and (sg:FindFirstChild("TextLabel") or sg:FindFirstChildOfClass("TextLabel"))
                                    local cd = cell:FindFirstChild("ClickDetector") or cell:FindFirstChildOfClass("ClickDetector")
                                    if tl and cd then
                                        local ct = tl.Text or ""
                                        if ct == "" or string.match(ct, "^%s*$") then
                                            table.insert(cellsToProcess, {cell=cell, cd=cd, clicks=2})
                                        elseif string.match(ct, "/") then
                                            table.insert(cellsToProcess, {cell=cell, cd=cd, clicks=1})
                                        end
                                    end
                                end
                            end
                            
                            for i, data in ipairs(cellsToProcess) do
                                if not _G.AutoMarkX then break end
                                
                                -- Re-check if game state has changed (very important so camera doesnt go crazy)
                                if not topTextObj or not topTextObj.Visible then break end
                                local currentText = topTextObj.Text
                                if not string.find(string.lower(currentText), "mark x's!") then
                                    break
                                end
                                
                                for c = 1, data.clicks do
                                    safeClickPart(data.cell, data.cd)
                                    task.wait(0.2) -- Constant 0.2s delay for continuous firing for Mark X as requested
                                end
                            end
                        end
                    elseif _G.AutoFind and string.find(string.lower(text), "find ") then
                        local numStr = string.match(text, "Find (%d+)")
                        if numStr then
                            local targetNum = numStr
                            local paper = myTable:FindFirstChild("MiddlePaper") and myTable.MiddlePaper:FindFirstChild("Paper_1")
                            if paper then
                                local foundSpot = nil
                                local foundCd = nil
                                for _, spot in ipairs(paper:GetChildren()) do
                                    if string.find(spot.Name, "Spot") then
                                        local sg = spot:FindFirstChild("SurfaceGui")
                                        local tl = sg and sg:FindFirstChild("TextLabel")
                                        local cd = spot:FindFirstChild("ClickDetector") or spot:FindFirstChildOfClass("ClickDetector")
                                        if tl and cd and tl.Text == targetNum then
                                            foundSpot = spot
                                            foundCd = cd
                                            break
                                        end
                                    end
                                end
                                if foundSpot and foundCd then
                                    applySpeedDelay()
                                    
                                    -- Check if game state changed while waiting
                                    if topTextObj and topTextObj.Visible then
                                        local currentText = topTextObj.Text
                                        if string.find(string.lower(currentText), "find ") then
                                            safeClickPart(foundSpot, foundCd)
                                            if _G.PickMarkSpeed ~= "No Delay" then
                                                task.wait(0.1)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    elseif _G.AutoPick and string.find(string.lower(text), "pick a number for") then
                        local paper = myTable:FindFirstChild("MiddlePaper") and myTable.MiddlePaper:FindFirstChild("Paper_1")
                        if paper then
                            local availableSpots = {}
                            for _, spot in ipairs(paper:GetChildren()) do
                                if string.find(spot.Name, "Spot") then
                                    local sg = spot:FindFirstChild("SurfaceGui")
                                    local tl = sg and sg:FindFirstChild("TextLabel")
                                    local cd = spot:FindFirstChild("ClickDetector") or spot:FindFirstChildOfClass("ClickDetector")
                                    if tl and cd then
                                        local col = tl.TextColor3
                                        if col.R < 0.1 and col.G < 0.1 and col.B < 0.1 then
                                            table.insert(availableSpots, {spot=spot, cd=cd})
                                        end
                                    end
                                end
                            end
                            if #availableSpots > 0 then
                                local r = math.random(1, #availableSpots)
                                applySpeedDelay()
                                
                                -- Check if game state changed while waiting
                                if topTextObj and topTextObj.Visible then
                                    local currentText = topTextObj.Text
                                    if string.find(string.lower(currentText), "pick a number for") then
                                        safeClickPart(availableSpots[r].spot, availableSpots[r].cd)
                                        if _G.PickMarkSpeed ~= "No Delay" then
                                            task.wait(0.5)
                                        else
                                            task.wait(0.1)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
        task.wait(0.1)
    end
end)

WindUI:Notify({
    Title = "Prime X Hub",
    Content = "Script loaded successfully!",
    Duration = 5
})
