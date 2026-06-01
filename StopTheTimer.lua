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
    Main = Window:Tab({ Title = "Main", Icon = "solar:star-bold" }),
    Movement = Window:Tab({ Title = "Movement", Icon = "solar:running-bold" }),
    Teleport = Window:Tab({ Title = "Teleport", Icon = "solar:map-point-bold" }),
    Settings = Window:Tab({ Title = "Settings", Icon = "solar:settings-bold" }),
    AboutUs  = Window:Tab({ Title = "About Us", Icon = "solar:info-circle-bold" })
}

-- [[ AUTO FARM STREAK LOGIC ]] --
local MainSection = Tabs.Main:Section({
    Title = "Auto Farm",
    Box = true,
    BoxBorder = true,
    Expandable = true,
    Opened = true
})

getgenv().autoFarmStreak = false
getgenv().autoFarmThread = 0
getgenv().clickOffsetMS = 30

MainSection:Slider({
    Flag = "LatencyOffset",
    Title = "Latency Offset (ms)",
    Step = 1,
    Value = {
        Min = 0,
        Max = 150,
        Default = 30,
    },
    Callback = function(value)
        getgenv().clickOffsetMS = value
    end
})

local function click3DButton(buttonPart)
    local camera = workspace.CurrentCamera
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local GuiService = game:GetService("GuiService")
    
    -- Option 1: Fire ClickDetector directly
    local cd = buttonPart:FindFirstChildWhichIsA("ClickDetector") or buttonPart.Parent:FindFirstChildWhichIsA("ClickDetector")
    if cd then
        fireclickdetector(cd)
        return
    end

    -- Option 2: Fallback to VirtualInputManager click
    local screenPos, onScreen = camera:WorldToViewportPoint(buttonPart.Position)
    if onScreen then
        local inset = GuiService:GetGuiInset()
        local clickX = screenPos.X
        local clickY = screenPos.Y + inset.Y
        
        -- Support for Touch / Mobile as requested by the rule
        local UIS = game:GetService("UserInputService")
        if UIS.TouchEnabled and not UIS.MouseEnabled then
            pcall(function()
                local VirtualUser = game:GetService("VirtualUser")
                VirtualUser:Button1Down(Vector2.new(clickX, clickY), workspace.CurrentCamera.CFrame)
                task.wait(0.05)
                VirtualUser:Button1Up(Vector2.new(clickX, clickY), workspace.CurrentCamera.CFrame)
            end)
        else
            VirtualInputManager:SendMouseMoveEvent(clickX, clickY, game)
            task.wait(0.02)
            VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 1)
            task.wait(0.02)
            VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 1)
        end
    end
end

local function extractTargetTime(uiElement)
    local function checkStr(str)
        if not str then return nil end
        local stripped = str:gsub("<[^>]+>", "") 
        local match = stripped:match("(%d+%.%d%d)") 
        if match then return tonumber(match) end
        return nil
    end

    if uiElement:IsA("TextLabel") or uiElement:IsA("TextButton") or uiElement:IsA("TextBox") then
        local res = checkStr(uiElement.Text)
        if res then return res end
    end
    for _, v in ipairs(uiElement:GetDescendants()) do
        if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
            local res = checkStr(v.Text)
            if res then return res end
        end
    end
    return nil
end

local function findEmptySeat()
    local gameStations = workspace:FindFirstChild("GameStations")
    if not gameStations or not gameStations:FindFirstChild("Normal") then return nil end
    local normalStations = gameStations.Normal
    
    for i = 1, 10 do
        local st = normalStations:FindFirstChild(tostring(i))
        if st and st:FindFirstChild("Chairs") then
            local p1Seat = st.Chairs:FindFirstChild("Player1") and st.Chairs.Player1:FindFirstChild("Seat")
            local p2Seat = st.Chairs:FindFirstChild("Player2") and st.Chairs.Player2:FindFirstChild("Seat")
            
            if p1Seat and not p1Seat:FindFirstChild("SeatWeld") then
                return p1Seat, tostring(i), "Player1"
            end
            if p2Seat and not p2Seat:FindFirstChild("SeatWeld") then
                return p2Seat, tostring(i), "Player2"
            end
        end
    end
    return nil
end

local function getMyStationAndRole(lp)
    local normalStations = workspace:FindFirstChild("GameStations") and workspace.GameStations:FindFirstChild("Normal")
    if normalStations then
        for i = 1, 10 do
            local st = normalStations:FindFirstChild(tostring(i))
            if st and st:FindFirstChild("Chairs") then
                local ch1 = st.Chairs:FindFirstChild("Player1")
                if ch1 and ch1:FindFirstChild("Seat") and ch1.Seat:FindFirstChild("SeatWeld") then
                    if ch1.Seat.SeatWeld.Part1 and ch1.Seat.SeatWeld.Part1.Parent == lp.Character then
                        return tostring(i), "Player1"
                    end
                end
                local ch2 = st.Chairs:FindFirstChild("Player2")
                if ch2 and ch2:FindFirstChild("Seat") and ch2.Seat:FindFirstChild("SeatWeld") then
                    if ch2.Seat.SeatWeld.Part1 and ch2.Seat.SeatWeld.Part1.Parent == lp.Character then
                        return tostring(i), "Player2"
                    end
                end
            end
        end
    end
    return nil, nil
end

local function startAutoFarm()
    local lp = game:GetService("Players").LocalPlayer
    local RunService = game:GetService("RunService")
    local thisThread = getgenv().autoFarmThread
    
    local lastSeatUsed = nil
    
    while getgenv().autoFarmStreak and getgenv().autoFarmThread == thisThread do
        local gameUI = lp.PlayerGui:FindFirstChild("GameUI")
        if not gameUI then
            task.wait(1)
            continue
        end

        local hum = lp.Character and lp.Character:FindFirstChild("Humanoid")
        local isSitting = (hum and hum.Sit)
        
        -- 1. IF NOT SITTING, FIND AN EMPTY CHAIR AND SIT
        if not isSitting then
            local emptySeat = nil
            
            -- Try to sit on the same seat first if it exists and is empty
            if lastSeatUsed and lastSeatUsed.Parent and not lastSeatUsed:FindFirstChild("SeatWeld") then
                emptySeat = lastSeatUsed
            else
                local s, sid, srole = findEmptySeat()
                emptySeat = s
            end
            
            if emptySeat then
                lastSeatUsed = emptySeat
                local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                if root and hum then
                    -- To avoid sinking/shaking, we TP slightly above and use the Seat:Sit() method directly.
                    root.CFrame = emptySeat.CFrame * CFrame.new(0, 0.5, 0)
                    task.wait(0.2)
                    
                    if emptySeat:IsA("Seat") and not hum.Sit then
                        pcall(function() emptySeat:Sit(hum) end)
                    end
                    task.wait(0.5)
                end
            else
                task.wait(1)
            end
            continue
        end

        -- 2. IF SITTING, CHECK IF WE ARE IN A MATCH (USING SecondsToSet instead of VsFrame)
        local myStationId, myRole = getMyStationAndRole(lp)
        
        if myStationId and myRole then
            local secondsToSet = gameUI:FindFirstChild("SecondsToSet")
            
            if secondsToSet and secondsToSet.Visible then
                local turnText = secondsToSet:FindFirstChild("TurnText")
                if turnText and turnText.Text:lower():match("your turn") then
                    
                    local timerTextLabel = workspace.GameStations.Normal[myStationId].Timer[myRole].SurfaceGui:FindFirstChild("TimerText")
                    local buttonPart = workspace.GameStations.Normal[myStationId].Buttons[myRole]
                    
                    if timerTextLabel and buttonPart then
                        local buttonTarget = buttonPart:IsA("Model") and (buttonPart.PrimaryPart or buttonPart:FindFirstChildWhichIsA("BasePart")) or buttonPart:IsA("BasePart") and buttonPart or nil
                        if buttonTarget then
                            local clicked = false
                            local camera = workspace.CurrentCamera
                            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, buttonTarget.Position)
                            
                            local conn
                            conn = RunService.RenderStepped:Connect(function()
                                if not getgenv().autoFarmStreak then conn:Disconnect() return end
                                
                                local currentTurnText = secondsToSet:FindFirstChild("TurnText")
                                if not currentTurnText or not currentTurnText.Text:lower():match("your turn") then
                                    conn:Disconnect()
                                    return
                                end

                                -- Continuously extract targetVal in case it updates late
                                local targetVal = extractTargetTime(secondsToSet)

                                local currVal = tonumber(timerTextLabel.Text)
                                if currVal and targetVal then
                                    local offsetSecs = (getgenv().clickOffsetMS or 0) / 1000
                                    local adjustedTarget = targetVal - offsetSecs
                                    -- If we reached exact target (count UP usually in this game)
                                    if currVal >= adjustedTarget and not clicked then
                                        clicked = true
                                        click3DButton(buttonTarget)
                                        conn:Disconnect()
                                    end
                                end
                            end)
                            
                            -- Wait until it is no longer our turn to avoid overlapping checks
                            while getgenv().autoFarmStreak and turnText and turnText.Parent and turnText.Text:lower():match("your turn") do
                                task.wait(0.1)
                            end
                            if conn then conn:Disconnect() end
                        end
                    end
                end
            end
        end
        
        -- Ensure loop yields when seated but waiting for turns or match start
        task.wait(0.5)
    end
end

MainSection:Toggle({
    Title = "Auto Farm Streak",
    Value = false,
    Callback = function(state)
        getgenv().autoFarmStreak = state
        if state then
            getgenv().autoFarmThread = getgenv().autoFarmThread + 1
            task.spawn(startAutoFarm)
        end
    end
})

getgenv().autoClick = false
getgenv().autoClickThread = 0

local function startAutoClick()
    local lp = game:GetService("Players").LocalPlayer
    local RunService = game:GetService("RunService")
    local thisThread = getgenv().autoClickThread
    
    while getgenv().autoClick and getgenv().autoClickThread == thisThread do
        local gameUI = lp.PlayerGui:FindFirstChild("GameUI")
        if not gameUI then
            task.wait(1)
            continue
        end

        local hum = lp.Character and lp.Character:FindFirstChild("Humanoid")
        local isSitting = (hum and hum.Sit)
        
        if isSitting then
            local myStationId, myRole = getMyStationAndRole(lp)
            if myStationId and myRole then
                local secondsToSet = gameUI:FindFirstChild("SecondsToSet")
                
                if secondsToSet and secondsToSet.Visible then
                    local turnText = secondsToSet:FindFirstChild("TurnText")
                    if turnText and turnText.Text:lower():match("your turn") then
                        local timerTextLabel = workspace.GameStations.Normal[myStationId].Timer[myRole].SurfaceGui:FindFirstChild("TimerText")
                        local buttonPart = workspace.GameStations.Normal[myStationId].Buttons[myRole]
                        
                        if timerTextLabel and buttonPart then
                            local buttonTarget = buttonPart:IsA("Model") and (buttonPart.PrimaryPart or buttonPart:FindFirstChildWhichIsA("BasePart")) or buttonPart:IsA("BasePart") and buttonPart or nil
                            if buttonTarget then
                                local clicked = false
                                local camera = workspace.CurrentCamera
                                camera.CFrame = CFrame.lookAt(camera.CFrame.Position, buttonTarget.Position)
                                
                                local conn
                                conn = RunService.RenderStepped:Connect(function()
                                    if not getgenv().autoClick then conn:Disconnect() return end
                                    
                                    local currentTurnText = secondsToSet:FindFirstChild("TurnText")
                                    if not currentTurnText or not currentTurnText.Text:lower():match("your turn") then
                                        conn:Disconnect()
                                        return
                                    end

                                    local targetVal = extractTargetTime(secondsToSet)
                                    local currVal = tonumber(timerTextLabel.Text)
                                    if currVal and targetVal then
                                        local offsetSecs = (getgenv().clickOffsetMS or 0) / 1000
                                        local adjustedTarget = targetVal - offsetSecs
                                        if currVal >= adjustedTarget and not clicked then
                                            clicked = true
                                            click3DButton(buttonTarget)
                                            conn:Disconnect()
                                        end
                                    end
                                end)
                                
                                while getgenv().autoClick and turnText and turnText.Parent and turnText.Text:lower():match("your turn") do
                                    task.wait(0.1)
                                end
                                if conn then conn:Disconnect() end
                            end
                        end
                    end
                end
            end
        end
        
        task.wait(0.5)
    end
end

MainSection:Toggle({
    Title = "Auto Click",
    Value = false,
    Callback = function(state)
        getgenv().autoClick = state
        if state then
            getgenv().autoClickThread = getgenv().autoClickThread + 1
            task.spawn(startAutoClick)
        end
    end
})


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

WindUI:Notify({
    Title = "Prime X Hub",
    Content = "Script loaded successfully!",
    Duration = 5
})
