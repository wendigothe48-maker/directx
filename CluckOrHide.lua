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

local gameName = "Cluck or Hide"
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
    Hider = Window:Tab({ Title = "Hider", Icon = "solar:ghost-bold" }),
    Cluck = Window:Tab({ Title = "Cluck", Icon = "solar:danger-triangle-bold" }),
    Movement = Window:Tab({ Title = "Movement", Icon = "solar:running-bold" }),
    Teleport = Window:Tab({ Title = "Teleport", Icon = "solar:map-point-bold" }),
    Settings = Window:Tab({ Title = "Settings", Icon = "solar:settings-bold" }),
    AboutUs  = Window:Tab({ Title = "About Us", Icon = "solar:info-circle-bold" })
}

-- ══════════════════════════════════════════
--              VARIABLES & STATES
-- ══════════════════════════════════════════
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

pcall(function()
    local baseplate = Workspace:FindFirstChild("Baseplate")
    if baseplate and baseplate:IsA("BasePart") then
        baseplate.Size = Vector3.new(5000, 20, 5000)
    end
end)

local Toggles = {
    Fly = false,
    WallEsp = false,
    ObjectEsp = false,
    WallHack = false,
    RejoinAfterDeath = false,
    NoInvis = false,
    CluckEsp = false,
    HelpMe = false,
    HelpOthers = false
}

local hasTeleportedAfterDeath = false

local Options = {
    FlySpeed = 6,
    WallEspTransparency = 0.8
}

local featureStates = {
    Main = false,
    Hider = false,
    Cluck = false
}

local originalWalls = {}

-- ══════════════════════════════════════════
--              CORE FUNCTIONS
-- ══════════════════════════════════════════

local function scanForWalls()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            -- Skip our own character
            if LocalPlayer.Character and obj:IsDescendantOf(LocalPlayer.Character) then continue end
            
            -- Skip any characters
            local parentModel = obj:FindFirstAncestorOfClass("Model")
            if parentModel and (parentModel:FindFirstChild("Humanoid") or parentModel:FindFirstChildOfClass("Humanoid")) then continue end
            
            local s = obj.Size
            local isLand = (obj.Name == "Baseplate") or (s.Y <= 2.6 and (s.Y * 8 < s.X or s.Y * 8 < s.Z))
            
            local isWall = false
            local isObject = false
            
            if not isLand then
                if (s.X * 12 <= s.Z and s.X <= 3) or (s.Z * 12 <= s.X and s.Z <= 3) then
                    isWall = true
                elseif (s.X * s.Y * s.Z) <= 2000 then
                    isObject = true
                end
            end
            
            if isWall or isObject then
                if not originalWalls[obj] then
                    originalWalls[obj] = {
                        Transparency = obj.Transparency,
                        CanCollide = obj.CanCollide,
                        IsWall = isWall,
                        IsObject = isObject
                    }
                end
            end
        end
    end
end

local flyConnection
local flyBodyVelocity
local flyBodyGyro
local isFlying = false

local function startFly()
    if isFlying then return end
    local character = LocalPlayer.Character
    if type(character) ~= "userdata" or not character then return end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if type(humanoidRootPart) ~= "userdata" or not humanoidRootPart or not humanoid then return end

    isFlying = true
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyBodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    flyBodyVelocity.Parent = humanoidRootPart

    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.P = 9e4
    flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBodyGyro.CFrame = humanoidRootPart.CFrame
    flyBodyGyro.Parent = humanoidRootPart

    humanoid.PlatformStand = true

    flyConnection = RunService.RenderStepped:Connect(function()
        local camera = Workspace.CurrentCamera
        local moveDirection = Vector3.new()
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end

        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit
        end

        if type(flyBodyVelocity) == "userdata" and flyBodyVelocity.Parent then
            flyBodyVelocity.Velocity = moveDirection * ((Options.FlySpeed / 3) * 50)
        end
        if type(flyBodyGyro) == "userdata" and flyBodyGyro.Parent then
            flyBodyGyro.CFrame = camera.CFrame
        end
    end)
end

local function stopFly()
    if not isFlying then return end
    isFlying = false

    local character = LocalPlayer.Character
    if type(character) == "userdata" and character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end

    if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
end

local function updateRoles()
    local aliveFolder = Workspace:FindFirstChild("AliveCharacters")
    if type(aliveFolder) ~= "userdata" or not aliveFolder or #aliveFolder:GetChildren() == 0 then
        featureStates.Main = false
        featureStates.Hider = false
        featureStates.Cluck = false
        return
    end

    featureStates.Main = true
    
    local amIKiller = false
    
    for _, char in ipairs(aliveFolder:GetChildren()) do
        if char:FindFirstChild("KillerHighlight") then
            if char.Name == LocalPlayer.Name then
                amIKiller = true
            end
        end
    end
    
    if amIKiller then
        featureStates.Cluck = true
        featureStates.Hider = false
    else
        featureStates.Hider = true
        featureStates.Cluck = false
    end
end

local cluckConnection
local coreGui = game:GetService("CoreGui")
local highlightFolder = coreGui:FindFirstChild("CluckEspHighlights") or Instance.new("Folder")
highlightFolder.Name = "CluckEspHighlights"
highlightFolder.Parent = coreGui

local trackingFolder = Workspace:FindFirstChild("CluckEspTrackers") or Instance.new("Folder")
trackingFolder.Name = "CluckEspTrackers"
trackingFolder.Parent = Workspace

local function clearTrackers()
    highlightFolder:ClearAllChildren()
    trackingFolder:ClearAllChildren()
end

local function updateTracker(char, hrp, isKiller, amIKiller)
    local pName = char.Name
    local tracker = trackingFolder:FindFirstChild(pName)
    
    if isKiller or not Toggles.CluckEsp or not amIKiller then
        if tracker then tracker:Destroy() end
        return
    end

    if not tracker then
        tracker = Instance.new("Part")
        tracker.Name = pName
        tracker.Size = Vector3.new(3, 4.5, 3)
        tracker.Transparency = 1
        tracker.Anchored = true
        tracker.CanCollide = false
        tracker.Parent = trackingFolder
        
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "Box"
        box.Size = tracker.Size
        box.Adornee = tracker
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Transparency = 0.5
        box.Color3 = Color3.fromHex("#0000FF")
        box.Parent = tracker
        
        local bgui = Instance.new("BillboardGui")
        bgui.Name = "Gui"
        bgui.Size = UDim2.new(0, 100, 0, 40)
        bgui.StudsOffset = Vector3.new(0, 3, 0)
        bgui.AlwaysOnTop = true
        bgui.Parent = tracker
        
        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Text = pName
        txt.TextColor3 = Color3.fromHex("#0000FF")
        txt.TextStrokeTransparency = 0
        txt.TextScaled = true
        txt.Font = Enum.Font.Code
        txt.Parent = bgui
    end
    
    if hrp then
        tracker.CFrame = hrp.CFrame
        -- Check if invisible
        local isInvis = false
        local head = char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
        if head and head.Transparency >= 0.9 then
            isInvis = true
        elseif hrp.AssemblyLinearVelocity.Magnitude < 0.5 then
            -- Fallback: if standing still and invisible mechanic applies
            isInvis = true
        end
        
        local box = tracker:FindFirstChild("Box")
        local gui = tracker:FindFirstChild("Gui")
        if box and gui then
            box.Visible = isInvis
            gui.Enabled = isInvis
        end
    end
end

local helpThreadRunning = false
local function manageHelpFeatures()
    if helpThreadRunning then return end
    helpThreadRunning = true
    
    task.spawn(function()
        while true do
            if not featureStates.Main then
                task.wait(1)
                continue
            end
            
            local aliveFolder = Workspace:FindFirstChild("AliveCharacters")
            if not aliveFolder or not LocalPlayer.Character then
                task.wait(1)
                continue
            end
            
            local selfChar = aliveFolder:FindFirstChild(LocalPlayer.Name) or LocalPlayer.Character
            if not selfChar or selfChar:FindFirstChild("KillerHighlight") then
                task.wait(1)
                continue
            end
            
            local selfHrp = selfChar:FindFirstChild("HumanoidRootPart")
            if not selfHrp then
                task.wait(1)
                continue
            end
            
            if Toggles.HelpOthers then
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") then
                        obj.HoldDuration = 0
                    end
                end
            end
            
            local selfHasIce = selfChar:FindFirstChild("IceBlock") ~= nil
            
            if Toggles.HelpMe and selfHasIce then
                local hiders = {}
                for _, c in ipairs(aliveFolder:GetChildren()) do
                    if c.Name ~= LocalPlayer.Name and not c:FindFirstChild("KillerHighlight") and c:FindFirstChild("HumanoidRootPart") and not c:FindFirstChild("IceBlock") then
                        table.insert(hiders, c)
                    end
                end
                
                if #hiders > 0 then
                    local target = hiders[math.random(1, #hiders)]
                    if target and target:FindFirstChild("HumanoidRootPart") then
                        selfHrp.CFrame = target.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                        task.wait(6)
                        continue
                    end
                end
            end
            
            if Toggles.HelpOthers and not selfHasIce then
                local killer = nil
                for _, c in ipairs(aliveFolder:GetChildren()) do
                    if c:FindFirstChild("KillerHighlight") then
                        killer = c
                        break
                    end
                end
                
                local helpedSomeone = false
                for _, c in ipairs(aliveFolder:GetChildren()) do
                    if c.Name ~= LocalPlayer.Name and c:FindFirstChild("IceBlock") then
                        local iceBlock = c:FindFirstChild("IceBlock")
                        local prompt = iceBlock:FindFirstChild("UnfreezePrompt")
                        
                        if prompt then
                            local targetHrp = c:FindFirstChild("HumanoidRootPart")
                            if targetHrp then
                                local isSafe = true
                                local isSelfAlive = aliveFolder:FindFirstChild(LocalPlayer.Name) ~= nil
                                
                                if isSelfAlive and killer then
                                    local kHrp = killer:FindFirstChild("HumanoidRootPart")
                                    if kHrp then
                                        local dist = (kHrp.Position - targetHrp.Position).Magnitude
                                        if dist <= 15 then
                                            isSafe = false
                                        end
                                    end
                                end
                                
                                if isSafe then
                                    local oldCFrame = selfHrp.CFrame
                                    
                                    pcall(function()
                                        if iceBlock:IsA("BasePart") then
                                            iceBlock.CanCollide = true
                                        end
                                        for _, p in ipairs(iceBlock:GetDescendants()) do
                                            if p:IsA("BasePart") then
                                                p.CanCollide = true
                                            end
                                        end
                                    end)
                                    
                                    selfHrp.CFrame = targetHrp.CFrame
                                    task.wait(0.3)
                                    pcall(function()
                                        if fireproximityprompt then
                                            fireproximityprompt(prompt)
                                        end
                                    end)
                                    task.wait(0.1)
                                    selfHrp.CFrame = oldCFrame
                                    helpedSomeone = true
                                    task.wait(0.5)
                                    break
                                end
                            end
                        end
                    end
                end
                
                if helpedSomeone then
                    continue
                end
            end
            
            task.wait(0.5)
        end
    end)
end

local killerTrapParts = {}
local killerTrapConnection = nil
local currentKillerHrp = nil
local debounceTrap = false

local function doSafeTeleport(localHrp, killerHrp)
    debounceTrap = true
    local oldCFrame = localHrp.CFrame
    localHrp.CFrame = killerHrp.CFrame + Vector3.new(0, 13, 0)
    
    task.spawn(function()
        task.wait(0.5)
        while currentKillerHrp and currentKillerHrp.Parent and Toggles.KillerIsSafe do
            if (currentKillerHrp.Position - oldCFrame.Position).Magnitude > 22 then
                break
            end
            task.wait(0.5)
        end
        if localHrp and localHrp.Parent and Toggles.KillerIsSafe then
            localHrp.CFrame = oldCFrame
        end
        debounceTrap = false
    end)
end

local function manageKillerTrapFeatures()
    if Toggles.KillerIsSafe and featureStates.Main then
        if not killerTrapConnection then
            for i = 1, 8 do
                local p = Instance.new("Part")
                p.Anchored = true
                p.CanCollide = true
                p.Transparency = 0.5
                p.Material = Enum.Material.ForceField
                p.Color = Color3.fromRGB(255, 0, 0)
                p.Size = Vector3.new(13, 11.93, 2)
                
                p.Touched:Connect(function(hit)
                    if Toggles.KillerIsSafe and currentKillerHrp and not debounceTrap then
                        local hitPlayer = game.Players:GetPlayerFromCharacter(hit.Parent)
                        if hitPlayer == LocalPlayer and hit.Parent ~= currentKillerHrp.Parent then
                            local localHrp = hit.Parent:FindFirstChild("HumanoidRootPart")
                            if localHrp then
                                doSafeTeleport(localHrp, currentKillerHrp)
                            end
                        end
                    end
                end)
                
                p.Parent = Workspace
                table.insert(killerTrapParts, p)
            end
            
            killerTrapConnection = RunService.RenderStepped:Connect(function()
                local aliveFolder = Workspace:FindFirstChild("AliveCharacters")
                local killerHrp = nil
                if aliveFolder then
                    for _, char in ipairs(aliveFolder:GetChildren()) do
                        if char:FindFirstChild("KillerHighlight") then
                            killerHrp = char:FindFirstChild("HumanoidRootPart")
                            break
                        end
                    end
                end
                
                currentKillerHrp = killerHrp
                
                if killerHrp and featureStates.Main and Toggles.KillerIsSafe then
                    local locChar = LocalPlayer.Character
                    if locChar then
                        local locHrp = locChar:FindFirstChild("HumanoidRootPart")
                        if locHrp and locHrp.Parent ~= currentKillerHrp.Parent and not debounceTrap then
                            local relPos = killerHrp.CFrame:ToObjectSpace(locHrp.CFrame).Position
                            if math.sqrt(relPos.X^2 + relPos.Z^2) <= 7.5 and relPos.Y >= -14 and relPos.Y <= 8 then
                                doSafeTeleport(locHrp, killerHrp)
                            end
                        end
                    end
                    
                    for i, p in ipairs(killerTrapParts) do
                        if p.Parent ~= Workspace then
                            p.Parent = Workspace
                        end
                        
                        local isTop = (i <= 4)
                        local faceIndex = isTop and i or (i - 4)
                        
                        local rot = CFrame.Angles(0, math.rad((faceIndex - 1) * 90), 0)
                        local edgeDist = 6.5
                        local height = 10
                        
                        local apex = Vector3.new(0, isTop and height or -height, 0)
                        local edgeMid = rot * Vector3.new(0, 0, edgeDist)
                        
                        local center = (apex + edgeMid) / 2
                        local upDir = (isTop and (apex - edgeMid) or (edgeMid - apex)).Unit
                        local rightDir = rot * Vector3.new(1, 0, 0)
                        local lookDir = rightDir:Cross(upDir).Unit
                        
                        p.CFrame = killerHrp.CFrame * CFrame.new(0, -3, 0) * CFrame.fromMatrix(center, rightDir, upDir, -lookDir)
                    end
                else
                    for _, p in ipairs(killerTrapParts) do
                        if p.Parent ~= nil then
                            p.Parent = nil
                        end
                    end
                end
            end)
        end
    else
        if killerTrapConnection then
            killerTrapConnection:Disconnect()
            killerTrapConnection = nil
        end
        for _, p in ipairs(killerTrapParts) do
            p:Destroy()
        end
        table.clear(killerTrapParts)
        currentKillerHrp = nil
    end
end

local function manageCluckFeatures()
    if (Toggles.CluckEsp or Toggles.NoInvis) and featureStates.Main then
        if not cluckConnection then
            cluckConnection = RunService.RenderStepped:Connect(function()
                local aliveFolder = Workspace:FindFirstChild("AliveCharacters")
                if not aliveFolder then return end
                
                local tickCount = tick()
                local validTrackers = {}
                
                local amIKiller = false
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("KillerHighlight") then
                    amIKiller = true
                end
                
                for _, char in ipairs(aliveFolder:GetChildren()) do
                    if char.Name ~= LocalPlayer.Name then
                        validTrackers[char.Name] = true
                        local isKiller = char:FindFirstChild("KillerHighlight") ~= nil
                        
                        -- Handle Cluck ESP Highlight
                        if Toggles.CluckEsp then
                            local hl = highlightFolder:FindFirstChild(char.Name)
                            if not hl then
                                hl = Instance.new("Highlight")
                                hl.Name = char.Name
                                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                hl.Parent = highlightFolder
                            end
                            if isKiller then
                                hl.FillColor = Color3.fromHex("#FF0000")
                                hl.OutlineColor = Color3.fromRGB(150, 0, 0)
                                hl.FillTransparency = 0.5
                            else
                                hl.FillColor = Color3.fromHex("#0000FF")
                                hl.OutlineColor = Color3.fromRGB(0, 0, 150)
                                hl.FillTransparency = 0.5
                            end
                            if hl.Adornee ~= char then
                                hl.Adornee = char
                            end
                        else
                            local hl = highlightFolder:FindFirstChild(char.Name)
                            if hl then hl:Destroy() end
                            
                            local legacyHl = char:FindFirstChild("CluckHighlight")
                            if legacyHl then legacyHl:Destroy() end
                        end
                        
                        -- Handle tracking box when invisible
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        updateTracker(char, hrp, isKiller, amIKiller)
                    end
                end
                
                -- Cleanup stale trackers
                for _, child in ipairs(trackingFolder:GetChildren()) do
                    if not validTrackers[child.Name] then
                        child:Destroy()
                    end
                end
            end)
            
            -- Spawn background loop for No Invis so it doesn't freeze frames
            task.spawn(function()
                while cluckConnection do
                    if Toggles.NoInvis then
                        local aliveFolder = Workspace:FindFirstChild("AliveCharacters")
                        if aliveFolder then
                            for _, char in ipairs(aliveFolder:GetChildren()) do
                                if char.Name ~= LocalPlayer.Name then
                                    for _, v in ipairs(char:GetDescendants()) do
                                        if (v:IsA("BasePart") or v:IsA("Decal")) and v.Name ~= "HumanoidRootPart" then
                                            if v.Transparency == 1 then
                                                v.Transparency = 0
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    else
        if cluckConnection then
            cluckConnection:Disconnect()
            cluckConnection = nil
        end
        clearTrackers()
        
        local aliveFolder = Workspace:FindFirstChild("AliveCharacters")
        if aliveFolder then
            for _, char in ipairs(aliveFolder:GetChildren()) do
                local hl = char:FindFirstChild("CluckHighlight")
                if hl then hl:Destroy() end
            end
        end
    end
end

local function refreshAll()
    updateRoles()
    manageHelpFeatures()
    manageKillerTrapFeatures()
    
    -- Sync Fly State
    if Toggles.Fly and featureStates.Main then
        startFly()
    else
        stopFly()
    end
    
    -- Sync Walls State
    if (Toggles.WallEsp or Toggles.WallHack or Toggles.ObjectEsp) and featureStates.Main then
        scanForWalls()
        local espTransparency = Options.WallEspTransparency or 0.8
        for part, orig in pairs(originalWalls) do
            if type(part) == "userdata" and part.Parent then
                if orig.IsWall then
                    local isEspActive = Toggles.WallEsp
                    part.Transparency = isEspActive and espTransparency or orig.Transparency
                    if Toggles.WallHack and isEspActive then
                        part.CanCollide = false
                    else
                        part.CanCollide = orig.CanCollide
                    end
                elseif orig.IsObject then
                    local isEspActive = Toggles.ObjectEsp
                    part.Transparency = isEspActive and espTransparency or orig.Transparency
                    if Toggles.WallHack and isEspActive then
                        part.CanCollide = false
                    else
                        part.CanCollide = orig.CanCollide
                    end
                end
            end
        end
    else
        for part, orig in pairs(originalWalls) do
            if type(part) == "userdata" and part.Parent then
                part.Transparency = orig.Transparency
                part.CanCollide = orig.CanCollide
            end
        end
    end
    
    manageCluckFeatures()
end

-- Refresh Event Listeners
local processPlayAfterDeath

local function hookAliveCharacters()
    local aliveFolder = Workspace:FindFirstChild("AliveCharacters")
    if type(aliveFolder) == "userdata" and aliveFolder then
        aliveFolder.ChildAdded:Connect(function() task.defer(refreshAll) end)
        aliveFolder.ChildRemoved:Connect(function() 
            task.defer(refreshAll) 
            task.defer(processPlayAfterDeath)
        end)
        
        aliveFolder.DescendantAdded:Connect(function(desc)
            if desc.Name == "KillerHighlight" then task.defer(refreshAll) end
        end)
        aliveFolder.DescendantRemoving:Connect(function(desc)
            if desc.Name == "KillerHighlight" then task.defer(refreshAll) end
        end)
    end
end

Workspace.ChildAdded:Connect(function(child)
    if child.Name == "AliveCharacters" then
        hookAliveCharacters()
        task.defer(refreshAll)
    end
end)

if Workspace:FindFirstChild("AliveCharacters") then
    hookAliveCharacters()
end

processPlayAfterDeath = function()
    if not Toggles.RejoinAfterDeath then return end
    local aliveFolder = Workspace:FindFirstChild("AliveCharacters")
    if not aliveFolder then return end

    local playersAlive = aliveFolder:GetChildren()
    if #playersAlive < 2 then
        hasTeleportedAfterDeath = false
        return
    end

    local amIAlive = aliveFolder:FindFirstChild(LocalPlayer.Name) ~= nil
    if amIAlive then
        hasTeleportedAfterDeath = false
    elseif not hasTeleportedAfterDeath then
        local hiders = {}
        local hasKiller = false
        for _, c in ipairs(playersAlive) do
            if c:FindFirstChild("KillerHighlight") then
                hasKiller = true
            elseif c:FindFirstChild("HumanoidRootPart") then
                table.insert(hiders, c)
            end
        end
        
        if #hiders > 0 then
            hasTeleportedAfterDeath = true
            task.spawn(function()
                local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                local root = char:WaitForChild("HumanoidRootPart", 5)
                local target = hiders[math.random(1, #hiders)]
                if root and target:FindFirstChild("HumanoidRootPart") then
                    -- Try to teleport multiple times for safety
                    for i = 1, 5 do
                        if target and target:FindFirstChild("HumanoidRootPart") then
                            root.CFrame = target.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                        end
                        task.wait(0.5)
                    end
                end
            end)
        end
    end
end

-- Call refresh when character respawns to reapply states
LocalPlayer.CharacterAdded:Connect(function()
    hasTeleportedAfterDeath = false
    task.defer(refreshAll)
    task.delay(1, function()
        if Toggles.RejoinAfterDeath then
            processPlayAfterDeath()
        end
    end)
end)

-- ══════════════════════════════════════════
--              UI ELEMENTS
-- ══════════════════════════════════════════

local WallSection = Tabs.Main:Section({
    Title = "Walls",
    Box = true,
    BoxBorder = true,
    Opened = true,
})

WallSection:Toggle({
    Title = "Wall Esp",
    Value = false,
    Callback = function(state)
        Toggles.WallEsp = state
        refreshAll()
    end
})

WallSection:Toggle({
    Title = "+ Object ( May Little Bugs )",
    Value = false,
    Callback = function(state)
        Toggles.ObjectEsp = state
        refreshAll()
    end
})

WallSection:Slider({
    Title = "Esp Transparency",
    Step = 0.05,
    Value = {
        Min = 0,
        Max = 1,
        Default = 0.8,
    },
    Callback = function(value)
        Options.WallEspTransparency = value
        if Toggles.WallEsp or Toggles.ObjectEsp then refreshAll() end
    end
})

WallSection:Toggle({
    Title = "Wall Hack",
    Value = false,
    Callback = function(state)
        Toggles.WallHack = state
        refreshAll()
    end
})

local FlySection = Tabs.Main:Section({
    Title = "Fly Settings",
    Box = true,
    BoxBorder = true,
    Opened = true,
})

FlySection:Toggle({
    Title = "Fly",
    Value = false,
    Callback = function(state)
        Toggles.Fly = state
        refreshAll()
    end
})

FlySection:Slider({
    Title = "Fly Speed",
    Step = 1,
    Value = {
        Min = 1,
        Max = 30,
        Default = 6,
    },
    Callback = function(value)
        Options.FlySpeed = value
    end
})

Tabs.Hider:Toggle({
    Title = "Rejoin After Death",
    Desc = "Become Invinsible after Rebirth : )",
    Value = false,
    Callback = function(state)
        Toggles.RejoinAfterDeath = state
        if state then processPlayAfterDeath() end
    end
})

Tabs.Hider:Toggle({
    Title = "Get away From Killer",
    Desc = "(BUGGY) ! Not Reccomended For Casual Play",
    Value = false,
    Callback = function(state)
        Toggles.KillerIsSafe = state
        refreshAll()
    end
})

local HelpSection = Tabs.Hider:Section({
    Title = "Help Features",
    Box = true,
    BoxBorder = true,
    Opened = true,
})

HelpSection:Toggle({
    Title = "Auto Help Me",
    Value = false,
    Callback = function(state)
        Toggles.HelpMe = state
    end
})

HelpSection:Toggle({
    Title = "Auto Help Others",
    Value = false,
    Callback = function(state)
        Toggles.HelpOthers = state
    end
})

local CluckSection = Tabs.Cluck:Section({
    Title = "Cluck Features",
    Box = true,
    BoxBorder = true,
    Opened = true,
})

CluckSection:Toggle({
    Title = "No Invis",
    Value = false,
    Callback = function(state)
        Toggles.NoInvis = state
        refreshAll()
    end
})

CluckSection:Toggle({
    Title = "Esp",
    Value = false,
    Callback = function(state)
        Toggles.CluckEsp = state
        refreshAll()
    end
})

refreshAll()

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
    Content = "Cluck or Hide script loaded!",
    Duration = 5
})
