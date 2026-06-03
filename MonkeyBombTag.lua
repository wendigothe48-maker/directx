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
--              AUTO TAG LOGIC
-- ══════════════════════════════════════════
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function getValidPlayers()
    local valid = {}
    local function checkFolder(folderName)
        local folder = workspace:FindFirstChild(folderName)
        if folder then
            for _, p in ipairs(folder:GetChildren()) do
                if p:IsA("Model") and p.Name ~= LocalPlayer.Name and p:FindFirstChild("HumanoidRootPart") then
                    table.insert(valid, p)
                end
            end
        end
    end
    checkFolder("Runners")
    checkFolder("Bomb")
    return valid
end

local preferredTarget = "Random"
local currentTarget = "Random"

local function getTargetHRP()
    local validPlayers = getValidPlayers()
    if #validPlayers == 0 then return nil end
    
    if currentTarget ~= "Random" then
        for _, p in ipairs(validPlayers) do
            if p.Name == currentTarget then
                return p:FindFirstChild("HumanoidRootPart")
            end
        end
    end
    
    local rnd = validPlayers[math.random(1, #validPlayers)]
    return rnd:FindFirstChild("HumanoidRootPart")
end

local autoTagEnabled = false
local autoStealBombEnabled = false
local autoFarmWinsEnabled = false
local originalCFrame = nil
local hasTeleported = false

-- SAFE ZONE SETUP FOR AUTO FARM WINS
local safeZoneCFrame = CFrame.new(-18, -370, 47)
local farmWinsBox = nil

local function createSafeBox()
    if farmWinsBox then return end
    farmWinsBox = Instance.new("Model", workspace)
    farmWinsBox.Name = "AutoFarmWinsBox"
    
    local size = 10
    local height = 10
    local thickness = 1
    
    local floor = Instance.new("Part", farmWinsBox)
    floor.Size = Vector3.new(size, thickness, size)
    floor.CFrame = safeZoneCFrame * CFrame.new(0, -3, 0)
    floor.Anchored = true
    
    local wall1 = Instance.new("Part", farmWinsBox)
    wall1.Size = Vector3.new(size, height, thickness)
    wall1.CFrame = floor.CFrame * CFrame.new(0, height/2, size/2 - thickness/2)
    wall1.Anchored = true
    
    local wall2 = Instance.new("Part", farmWinsBox)
    wall2.Size = Vector3.new(size, height, thickness)
    wall2.CFrame = floor.CFrame * CFrame.new(0, height/2, -size/2 + thickness/2)
    wall2.Anchored = true
    
    local wall3 = Instance.new("Part", farmWinsBox)
    wall3.Size = Vector3.new(thickness, height, size)
    wall3.CFrame = floor.CFrame * CFrame.new(size/2 - thickness/2, height/2, 0)
    wall3.Anchored = true
    
    local wall4 = Instance.new("Part", farmWinsBox)
    wall4.Size = Vector3.new(thickness, height, size)
    wall4.CFrame = floor.CFrame * CFrame.new(-size/2 + thickness/2, height/2, 0)
    wall4.Anchored = true
    
    for _, child in ipairs(farmWinsBox:GetChildren()) do
        if child:IsA("BasePart") then
            child.Transparency = 0.5
            child.Color = Color3.fromRGB(0, 255, 0)
            child.Material = Enum.Material.ForceField
            child.CanCollide = true
        end
    end
    
    local resetPlatform = Instance.new("Part", farmWinsBox)
    resetPlatform.Size = Vector3.new(2000, 2, 2000)
    resetPlatform.CFrame = floor.CFrame * CFrame.new(0, -15, 0)
    resetPlatform.Anchored = true
    resetPlatform.CanCollide = false
    resetPlatform.Transparency = 1
    
    resetPlatform.Touched:Connect(function(hit)
        if autoFarmWinsEnabled then
            if hit.Parent and hit.Parent.Name == LocalPlayer.Name then
                local hrp = hit.Parent:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = safeZoneCFrame
                    local currentHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if currentHrp then currentHrp.Velocity = Vector3.new(0, 0, 0) end
                end
            end
        end
    end)
end

local function removeSafeBox()
    if farmWinsBox then
        farmWinsBox:Destroy()
        farmWinsBox = nil
    end
end

local autoFarmWinsToggle
autoFarmWinsToggle = Tabs.Main:Toggle({
    Title = "Auto Farm Wins",
    Value = false,
    Callback = function(Value)
        autoFarmWinsEnabled = Value
        if Value then
            autoTagEnabled = false
            autoStealBombEnabled = false
            pcall(function() 
                if autoTagToggle then autoTagToggle:Set(false) end
                if autoStealToggle then autoStealToggle:Set(false) end
            end)
            
            createSafeBox()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = safeZoneCFrame end
        else
            removeSafeBox()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = CFrame.new(-2, 176, -4) end
        end
    end
})

local AutoTagSection = Tabs.Main:Section({
    Title = "Auto Tag",
    Box = true,
    BoxBorder = true,
    Expandable = true,
    Opened = true
})

local targetDropdown = AutoTagSection:Dropdown({
    Title = "Select Player to Tag",
    Values = {"Random"},
    Value = "Random",
    Callback = function(Value)
        preferredTarget = Value
        currentTarget = Value
    end
})

autoTagToggle = AutoTagSection:Toggle({
    Title = "Auto Tag",
    Value = false,
    Callback = function(Value)
        autoTagEnabled = Value
        if Value and autoFarmWinsEnabled then
            autoTagEnabled = false
            pcall(function() autoTagToggle:Set(false) end)
            WindUI:Notify({Title = "Error", Content = "Cannot enable while Auto Farm Wins is active."})
        end
    end
})

AutoTagSection:Button({
    Title = "Tag Now",
    Callback = function()
        pcall(function()
            local bombFolder = workspace:FindFirstChild("Bomb")
            if bombFolder and bombFolder:FindFirstChild(LocalPlayer.Name) then
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local originalPos = hrp.CFrame
                    local isTagging = true
                    
                    task.spawn(function()
                        while isTagging do
                            local bFolder = workspace:FindFirstChild("Bomb")
                            if not bFolder or not bFolder:FindFirstChild(LocalPlayer.Name) then
                                isTagging = false
                                local currentHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if currentHrp then
                                    currentHrp.CFrame = originalPos
                                end
                                break
                            else
                                local currentHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                local targetHRP = getTargetHRP()
                                if currentHrp and targetHRP then
                                    currentHrp.CFrame = targetHRP.CFrame
                                end
                            end
                            task.wait()
                        end
                    end)
                end
            end
        end)
    end
})

local AutoStealSection = Tabs.Main:Section({
    Title = "Auto Steal",
    Box = true,
    BoxBorder = true,
    Expandable = true,
    Opened = true
})

local autoStealToggle
autoStealToggle = AutoStealSection:Toggle({
    Title = "Auto Steal Bomb",
    Value = false,
    Callback = function(Value)
        autoStealBombEnabled = Value
        if Value and autoFarmWinsEnabled then
            autoStealBombEnabled = false
            pcall(function() autoStealToggle:Set(false) end)
            WindUI:Notify({Title = "Error", Content = "Cannot enable while Auto Farm Wins is active."})
        end
    end
})

AutoStealSection:Button({
    Title = "Steal Now",
    Callback = function()
        pcall(function()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bombFolder = workspace:FindFirstChild("Bomb")
                if bombFolder then
                    local targetModel = nil
                    for _, child in ipairs(bombFolder:GetChildren()) do
                        if child:IsA("Model") and child.Name ~= LocalPlayer.Name then
                            targetModel = child
                            break
                        end
                    end
                    
                    if targetModel then
                        local targetHRP = targetModel:FindFirstChild("HumanoidRootPart")
                        if targetHRP then
                            local originalPos = hrp.CFrame
                            local isStealing = true
                            task.spawn(function()
                                while isStealing do
                                    local bFolder = workspace:FindFirstChild("Bomb")
                                    if bFolder and bFolder:FindFirstChild(LocalPlayer.Name) then
                                        -- We successfully stole the bomb
                                        isStealing = false
                                        local currentHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                        if currentHrp then
                                            currentHrp.CFrame = originalPos
                                        end
                                        break
                                    else
                                        local currentHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                        -- Verify target still has bomb
                                        local isTargetStillBomb = false
                                        if bFolder then
                                            for _, child in ipairs(bFolder:GetChildren()) do
                                                if child.Name == targetModel.Name then
                                                    isTargetStillBomb = true
                                                    break
                                                end
                                            end
                                        end
                                        
                                        if not isTargetStillBomb then
                                            -- Target is no longer the bomb, stop stealing
                                            isStealing = false
                                            if currentHrp then
                                                currentHrp.CFrame = originalPos
                                            end
                                            break
                                        end
                                        
                                        if currentHrp and targetHRP then
                                            currentHrp.CFrame = targetHRP.CFrame
                                        end
                                    end
                                    task.wait()
                                end
                            end)
                        end
                    end
                end
            end
        end)
    end
})

local autoBananaEnabled = false
Tabs.Main:Toggle({
    Title = "Auto Banana",
    Value = false,
    Callback = function(Value)
        autoBananaEnabled = Value
    end
})

local autoBetterBarrierEnabled = false
local activeRoofs = {}

Tabs.Main:Toggle({
    Title = "Better Barrier",
    Desc = "Makes Barrier Jumpable & Adds Roof",
    Value = false,
    Callback = function(Value)
        autoBetterBarrierEnabled = Value
    end
})

task.spawn(function()
    while task.wait(1) do
        if autoBetterBarrierEnabled then
            pcall(function()
                local mapFolder = workspace:FindFirstChild("Map")
                if not mapFolder then return end
                
                for _, mapModule in ipairs(mapFolder:GetChildren()) do
                    local barriersFolder = mapModule:FindFirstChild("Barriers")
                    if barriersFolder then
                        local foundBarriers = false
                        local minX, minY, minZ = math.huge, math.huge, math.huge
                        local maxX, maxY, maxZ = -math.huge, -math.huge, -math.huge
                        
                        -- First pass: Check if any new "Barrier" exists and calculate bounding box
                        for _, child in ipairs(barriersFolder:GetChildren()) do
                            if child.Name == "Barrier" and child:IsA("BasePart") then
                                foundBarriers = true
                                
                                local sX, sY, sZ = child.Size.X, child.Size.Y, child.Size.Z
                                local cX, cY, cZ = child.CFrame.X, child.CFrame.Y, child.CFrame.Z
                                
                                minX = math.min(minX, cX - sX/2)
                                maxX = math.max(maxX, cX + sX/2)
                                minY = math.min(minY, cY - sY/2)
                                maxY = math.max(maxY, cY + sY/2)
                                minZ = math.min(minZ, cZ - sZ/2)
                                maxZ = math.max(maxZ, cZ + sZ/2)
                            end
                        end
                        
                        if foundBarriers then
                            -- Replace them and build roof
                            for _, child in ipairs(barriersFolder:GetChildren()) do
                                if child.Name == "Barrier" and child:IsA("BasePart") then
                                    local size = child.Size
                                    local cframe = child.CFrame
                                    child:Destroy()
                                    
                                    local p = Instance.new("Part")
                                    p.Name = "BetterBarrier"
                                    p.Anchored = true
                                    p.CanCollide = true
                                    p.Transparency = 0.9
                                    p.Size = size
                                    p.CFrame = cframe
                                    p.Parent = barriersFolder
                                end
                            end
                            
                            -- Build the roof
                            local roofThickness = 2
                            local roof = Instance.new("Part")
                            roof.Name = "BetterBarrierRoof"
                            roof.Anchored = true
                            roof.CanCollide = true
                            roof.Transparency = 0.9
                            roof.Size = Vector3.new(maxX - minX, roofThickness, maxZ - minZ)
                            roof.CFrame = CFrame.new((minX + maxX)/2, maxY + roofThickness/2, (minZ + maxZ)/2)
                            roof.Parent = barriersFolder
                            
                            table.insert(activeRoofs, roof)
                        end
                    end
                end
            end)
        end
    end
end)

game:GetService("RunService").Stepped:Connect(function()
    if autoBetterBarrierEnabled then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            for i = #activeRoofs, 1, -1 do
                local roof = activeRoofs[i]
                if not roof or not roof.Parent then
                    table.remove(activeRoofs, i)
                else
                    if hrp.Position.Y > roof.Position.Y - (roof.Size.Y / 2) then
                        roof.CanCollide = false
                    else
                        roof.CanCollide = true
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        if autoBananaEnabled then
            pcall(function()
                local bananasFolder = workspace:FindFirstChild("Bananas")
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if bananasFolder and hrp then
                    for _, targetPart in ipairs(bananasFolder:GetChildren()) do
                        if firetouchinterest and targetPart:IsA("BasePart") then
                            firetouchinterest(targetPart, hrp, 0)
                            task.wait(0.01)
                            firetouchinterest(targetPart, hrp, 1)
                        elseif firetouchinterest then
                            local realPart = targetPart:FindFirstChildWhichIsA("BasePart")
                            if realPart then
                                firetouchinterest(realPart, hrp, 0)
                                task.wait(0.01)
                                firetouchinterest(realPart, hrp, 1)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.1)
    end
end)

local lastOptionsStr = ""
task.spawn(function()
    while true do
        local valid = getValidPlayers()
        local validNames = {}
        for _, p in ipairs(valid) do
            table.insert(validNames, p.Name)
        end
        table.sort(validNames)
        
        local options = {"Random"}
        local hasPreferred = false
        
        for _, name in ipairs(validNames) do
            table.insert(options, name)
            if name == preferredTarget then
                hasPreferred = true
            end
        end
        
        if preferredTarget ~= "Random" then
            if not hasPreferred then
                currentTarget = "Random"
            else
                currentTarget = preferredTarget
            end
        end
        
        local currentOptionsStr = table.concat(options, ",")
        if currentOptionsStr ~= lastOptionsStr then
            targetDropdown:Refresh(options)
            lastOptionsStr = currentOptionsStr
        end
        
        task.wait(1.5)
    end
end)

local function getStatusLabel()
    local pgui = LocalPlayer:FindFirstChild("PlayerGui")
    if pgui then
        local gui = pgui:FindFirstChild("GUI")
        local container = gui and gui:FindFirstChild("Container")
        local screen = container and container:FindFirstChild("Screen")
        local rs = screen and screen:FindFirstChild("RoundStatus")
        local label = rs and rs:FindFirstChild("TextLabel")
        return label
    end
    return nil
end

local stealTeleported = false

task.spawn(function()
    while true do
        local delay = 0.5
        if autoFarmWinsEnabled then
            delay = 0.1
            local label = getStatusLabel()
            if label and label.Text then
                local txt = label.Text
                local name = txt:match("@([^<]+)<")
                if name then
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if name == LocalPlayer.Name then
                        local targetHRP = getTargetHRP()
                        if targetHRP and hrp then
                            hrp.CFrame = targetHRP.CFrame
                            task.wait(0.5)
                            
                            local currentHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if currentHrp and autoFarmWinsEnabled then
                                currentHrp.CFrame = safeZoneCFrame
                            end
                            task.wait(0.5)
                        end
                    else
                        if hrp and (hrp.Position - safeZoneCFrame.Position).Magnitude > 20 then
                            hrp.CFrame = safeZoneCFrame
                        end
                    end
                end
            end
        elseif autoTagEnabled or autoStealBombEnabled then
            local label = getStatusLabel()
            if label and label.Text then
                local txt = label.Text
                if txt:find("BOMB EXPLODED") then
                    if originalCFrame then
                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.CFrame = originalCFrame
                        end
                        originalCFrame = nil
                    end
                    hasTeleported = false
                    stealTeleported = false
                else
                    local name = txt:match("@([^<]+)<")
                    local timeLeftStr = txt:match("([%d%.]+)s")
                    if name and timeLeftStr then
                        local timeLeft = tonumber(timeLeftStr)
                        if timeLeft <= 3.5 then
                            delay = 0.05
                        end
                        
                        if name == LocalPlayer.Name then
                            stealTeleported = false
                            if autoTagEnabled then
                                if timeLeft <= 1.05 then
                                    local targetHRP = getTargetHRP()
                                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                    if targetHRP and hrp then
                                        if not hasTeleported then
                                            originalCFrame = hrp.CFrame
                                            hasTeleported = true
                                        end
                                        hrp.CFrame = targetHRP.CFrame
                                    end
                                elseif timeLeft > 1.5 then
                                    hasTeleported = false
                                    originalCFrame = nil
                                end
                            end
                        else
                            if hasTeleported and autoTagEnabled and originalCFrame then
                                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if hrp then hrp.CFrame = originalCFrame end
                                hasTeleported = false
                                originalCFrame = nil
                            end
                            if autoStealBombEnabled then
                                if timeLeft <= 2.2 and timeLeft > 1.5 and not stealTeleported then
                                    local bombFolder = workspace:FindFirstChild("Bomb")
                                    local targetModel = bombFolder and bombFolder:FindFirstChild(name)
                                    local targetHRP = targetModel and targetModel:FindFirstChild("HumanoidRootPart")
                                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                    
                                    if targetHRP and hrp then
                                        if not originalCFrame then
                                            originalCFrame = hrp.CFrame
                                        end
                                        hasTeleported = false
                                        stealTeleported = true
                                        
                                        hrp.CFrame = targetHRP.CFrame
                                        task.delay(0.6, function()
                                            local currentHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                            if currentHrp and originalCFrame then
                                                currentHrp.CFrame = originalCFrame
                                            end
                                        end)
                                    end
                                end
                            end
                            if timeLeft > 2.5 then
                                hasTeleported = false
                                stealTeleported = false
                                originalCFrame = nil
                            end
                        end
                    end
                end
            end
        end
        task.wait(delay)
    end
end)

-- ══════════════════════════════════════════
--              SETTINGS LOGIC
-- ══════════════════════════════════════════
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function forceShowMouse()
    pcall(function()
        UserInputService.MouseIconEnabled = true
        local mouse = LocalPlayer:GetMouse()
        if mouse.Icon ~= "" then
            mouse.Icon = ""
        end
        -- Attempt to hide any custom GUI cursor (often named Cursor or Mouse)
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            for _, gui in ipairs(playerGui:GetDescendants()) do
                if gui:IsA("ImageLabel") and (gui.Name:lower():find("cursor") or gui.Name:lower():find("mouse")) then
                    gui.Visible = false
                end
            end
        end
    end)
end

-- Run once on load
forceShowMouse()

Tabs.Settings:Button({
    Title = "Force Show Mouse (PC)",
    Callback = function()
        forceShowMouse()
    end
})

local originalMinZoom = LocalPlayer.CameraMinZoomDistance
local originalMaxZoom = LocalPlayer.CameraMaxZoomDistance

Tabs.Settings:Toggle({
    Title = "Unlock Zoom",
    Value = false,
    Callback = function(Value)
        if Value then
            originalMinZoom = LocalPlayer.CameraMinZoomDistance
            originalMaxZoom = LocalPlayer.CameraMaxZoomDistance
            LocalPlayer.CameraMaxZoomDistance = 10000
            LocalPlayer.CameraMinZoomDistance = 0.5
        else
            LocalPlayer.CameraMaxZoomDistance = originalMaxZoom
            LocalPlayer.CameraMinZoomDistance = originalMinZoom
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
