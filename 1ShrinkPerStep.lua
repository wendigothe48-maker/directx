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
    Main     = Window:Tab({ Title = "Main", Icon = "solar:home-bold" }),
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

_G.AutoBuyShrinkToggle = false
Tabs.Main:Toggle({
    Title = "Auto Buy Shrink",
    Value = false,
    Callback = function(Value)
        _G.AutoBuyShrinkToggle = Value
        if Value then
            task.spawn(function()
                while _G.AutoBuyShrinkToggle do
                    pcall(function()
                        local LocalPlayer = game:GetService("Players").LocalPlayer
                        local highestAffordable = -1
                        local targetNode = nil
                        local nodesFolder = workspace:FindFirstChild("Nodes")
                        
                        if nodesFolder then
                            for _, node in ipairs(nodesFolder:GetChildren()) do
                                local nodeNum = tonumber(node.Name)
                                if nodeNum then
                                    local lockedGui = node:FindFirstChild("Model") 
                                        and node.Model:FindFirstChild("Main") 
                                        and node.Model.Main:FindFirstChild("Attachment2") 
                                        and node.Model.Main.Attachment2:FindFirstChild("BillboardGui") 
                                        and node.Model.Main.Attachment2.BillboardGui:FindFirstChild("Locked")
                                    
                                    if lockedGui then
                                        local state = lockedGui.Text
                                        if state == "Equipped" then
                                            if nodeNum > highestAffordable then
                                                highestAffordable = nodeNum
                                                targetNode = nil
                                            end
                                        elseif state == "Unlocked" then
                                            if nodeNum > highestAffordable then
                                                highestAffordable = nodeNum
                                                targetNode = node
                                            end
                                        elseif state == "Locked" then
                                            local winsGui = lockedGui.Parent:FindFirstChild("Wins")
                                            if winsGui then
                                                local priceStr = string.gsub(winsGui.Text, "Wins", "")
                                                priceStr = string.gsub(priceStr, "%s+", "")
                                                local price = math.huge
                                                if NumberConverter and NumberConverter.Parse then
                                                    price = NumberConverter.Parse(priceStr)
                                                else
                                                    price = tonumber(string.match(priceStr, "[%d%.]+")) or math.huge
                                                end
                                                local playerWins = LocalPlayer.leaderstats and LocalPlayer.leaderstats:FindFirstChild("Wins") and tonumber(LocalPlayer.leaderstats.Wins.Value) or 0
                                                if playerWins >= price then
                                                    if nodeNum > highestAffordable then
                                                        highestAffordable = nodeNum
                                                        targetNode = node
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        
                        if targetNode then
                            local mainPart = targetNode.Model.Main
                            local prompt = mainPart:FindFirstChild("Attachment") and mainPart.Attachment:FindFirstChild("Buy")
                            if prompt then
                                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    _G.PauseAutoFarmWins = true
                                    for attempt = 1, 10 do
                                        if not _G.AutoBuyShrinkToggle then break end
                                        local distance = (hrp.Position - mainPart.Position).Magnitude
                                        if distance > 10 then
                                            hrp.CFrame = mainPart.CFrame + Vector3.new(0, 3, 0)
                                            task.wait(0.2)
                                        end
                                        fireproximityprompt(prompt)
                                        task.wait(0.1)
                                    end
                                    task.wait(1)
                                    _G.PauseAutoFarmWins = false
                                end
                            end
                        end
                    end)
                    task.wait(2)
                end
            end)
        end
    end
})

_G.FakeStepToggle = false
Tabs.Main:Toggle({
    Title = "Fake Step",
    Value = false,
    Callback = function(Value)
        _G.FakeStepToggle = Value
        local LocalPlayer = game:GetService("Players").LocalPlayer
        local char = LocalPlayer and LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            if not Value then
                hrp.Anchored = false
                pcall(function()
                    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                    if playerGui then
                        local touchGui = playerGui:FindFirstChild("TouchGui")
                        if touchGui then
                            touchGui.Enabled = false
                            task.wait(0.05)
                            touchGui.Enabled = true
                        end
                    end
                end)
            end
        end
    end
})

task.spawn(function()
    local VirtualInputManager = game:GetService("VirtualInputManager")
    while task.wait() do
        if _G.FakeStepToggle then
            local LocalPlayer = game:GetService("Players").LocalPlayer
            local char = LocalPlayer and LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            if hrp then
                hrp.Anchored = true
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
            end
        end
    end
end)

_G.AutoFarmWinsToggle = false
Tabs.Main:Toggle({
    Title = "Auto Farm Wins",
    Value = false,
    Callback = function(Value)
        _G.AutoFarmWinsToggle = Value
        if Value then
            task.spawn(function()
                local VirtualInputManager = game:GetService("VirtualInputManager")
                while _G.AutoFarmWinsToggle do
                    if _G.PauseAutoFarmWins then
                        task.wait(0.1)
                    else
                        pcall(function()
                            local highestRoom = -1
                            local roomsFolder = workspace:FindFirstChild("Rooms")
                        if roomsFolder then
                            for _, room in ipairs(roomsFolder:GetChildren()) do
                                local roomNum = tonumber(room.Name)
                                if roomNum then
                                    local textLabel = room:FindFirstChild("Showcase") 
                                        and room.Showcase:FindFirstChild("SurfaceGui") 
                                        and room.Showcase.SurfaceGui:FindFirstChild("TextLabel")
                                    if textLabel then
                                        local color = textLabel.TextColor3
                                        if color.G > 0.9 and color.R < 0.1 and color.B < 0.1 then
                                            if roomNum > highestRoom then
                                                highestRoom = roomNum
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        
                        if highestRoom >= 0 and roomsFolder then
                            local targetRoom = roomsFolder:FindFirstChild(tostring(highestRoom))
                            if targetRoom then
                                local winPart = targetRoom:FindFirstChild("Win")
                                if winPart then
                                    local LocalPlayer = game:GetService("Players").LocalPlayer
                                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                    if hrp then
                                        for i = 1, 10 do
                                            if not _G.AutoFarmWinsToggle then break end
                                            if _G.PauseAutoFarmWins then break end
                                            
                                            hrp.CFrame = winPart.CFrame + Vector3.new(math.random(-10, 10)/10, 2, math.random(-10, 10)/10)
                                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
                                            
                                            task.wait(0.05)
                                        end
                                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
                                    end
                                end
                            end
                        else
                            task.wait(1)
                        end
                    end)
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

_G.AutoRebirthToggle = false
Tabs.Main:Toggle({
    Title = "Auto Rebirth",
    Value = false,
    Callback = function(Value)
        _G.AutoRebirthToggle = Value
        if Value then
            task.spawn(function()
                while _G.AutoRebirthToggle do
                    pcall(function()
                        local LocalPlayer = game:GetService("Players").LocalPlayer
                        local bar = LocalPlayer.PlayerGui.Main.Frames.Rebirths.Progress.CanvasGroup.Bar
                        if bar.Size.X.Scale >= 1 and bar.Size.Y.Scale >= 1 then
                            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Rebirth"):InvokeServer()
                        end
                    end)
                    task.wait(1)
                end
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

WindUI:Notify({
    Title = "Prime X Hub",
    Content = "Script loaded successfully!",
    Duration = 5
})
