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

local function isPlayerInArena(character)
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local pos = hrp.Position
    local minX, maxX = -56, 1
    local minY, maxY = 5, 100 -- Expanded Y bounds greatly so jumping/falling doesn't flicker
    local minZ, maxZ = -70, -13
    return pos.X >= minX and pos.X <= maxX and pos.Y >= minY and pos.Y <= maxY and pos.Z >= minZ and pos.Z <= maxZ
end

local function getValidPlayers()
    local valid = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if not p.Character:FindFirstChild("BombActive") then
                local humanoid = p.Character:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    if isPlayerInArena(p.Character) then
                        table.insert(valid, p.Character)
                    end
                end
            end
        end
    end
    return valid
end

local function getBomber()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("BombActive") then
            return p
        end
    end
    return nil
end

local function getCountdownTime()
    local bomber = getBomber()
    if bomber and bomber.Character then
        local bombActive = bomber.Character:FindFirstChild("BombActive")
        if bombActive then
            local handle = bombActive:FindFirstChild("Handle")
            if handle then
                local billboard = handle:FindFirstChild("BillboardGui")
                if billboard then
                    local countdown = billboard:FindFirstChild("Countdown")
                    if countdown and countdown:IsA("TextLabel") then
                        local match = string.match(countdown.Text, "%d+%.?%d*")
                        if match then
                            return tonumber(match)
                        end
                    end
                end
            end
            
            local countdown = bombActive:FindFirstChild("Countdown")
            if countdown and countdown:IsA("TextLabel") then
                local match = string.match(countdown.Text, "%d+%.?%d*")
                if match then
                    return tonumber(match)
                end
            end
        end
    end
    return nil
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
local auto1v1Enabled = false
local auto1v1Toggle
local auto1v1Platform = nil
local originalCFrame = nil
local hasTeleported = false

-- SAFE ZONE SETUP FOR AUTO FARM WINS
local safeZoneCFrame = nil
local farmWinsBox = nil

local function createSafeBox(cframe)
    if farmWinsBox then return end
    farmWinsBox = Instance.new("Model", workspace)
    farmWinsBox.Name = "AutoFarmWinsBox"
    
    local size = 15
    local height = 10
    local thickness = 1
    
    local floor = Instance.new("Part", farmWinsBox)
    floor.Size = Vector3.new(size, thickness, size)
    floor.CFrame = cframe * CFrame.new(0, -3, 0)
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
        if autoFarmWinsEnabled and safeZoneCFrame then
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

local function create1v1Platform()
    if auto1v1Platform then return end
    auto1v1Platform = Instance.new("Part", workspace)
    auto1v1Platform.Name = "Auto1v1Platform"
    -- Make it much bigger globally so we don't fall off during heavy teleporting
    auto1v1Platform.Size = Vector3.new(200, 2, 200)
    -- Put it just below the Y=5 boundary explicitly stated by user
    auto1v1Platform.Position = Vector3.new(-27.5, 3, -41.5)
    auto1v1Platform.Anchored = true
    auto1v1Platform.Transparency = 0.5
    auto1v1Platform.BrickColor = BrickColor.new("Bright blue")
end

local function remove1v1Platform()
    if auto1v1Platform then
        auto1v1Platform:Destroy()
        auto1v1Platform = nil
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
            auto1v1Enabled = false
            pcall(function() 
                if autoTagToggle then autoTagToggle:Set(false) end
                if autoStealToggle then autoStealToggle:Set(false) end
                if auto1v1Toggle then auto1v1Toggle:Set(false) end
            end)
            
            -- Main loop handles creation
        else
            removeSafeBox()
            if originalCFrame and hasTeleported then
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = originalCFrame end
            end
            hasTeleported = false
            originalCFrame = nil
            safeZoneCFrame = nil
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
            if getBomber() == LocalPlayer then
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local originalPos = hrp.CFrame
                    local isTagging = true
                    
                    task.spawn(function()
                        while isTagging do
                            if getBomber() ~= LocalPlayer then
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
                                    local offsetX = math.random(-15, 15) / 10
                                    local offsetZ = math.random(-15, 15) / 10
                                    currentHrp.CFrame = targetHRP.CFrame * CFrame.new(offsetX, 0, offsetZ)
                                    pcall(function()
                                        local isMobile = game:GetService("UserInputService").TouchEnabled and not game:GetService("UserInputService").MouseEnabled
                                        if isMobile then
                                            firetouchinterest(currentHrp, targetHRP, 0)
                                            task.wait(0.01)
                                            firetouchinterest(currentHrp, targetHRP, 1)
                                        else
                                            firetouchinterest(currentHrp, targetHRP, 0)
                                        end
                                    end)
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
                local bomberPlayer = getBomber()
                if bomberPlayer and bomberPlayer ~= LocalPlayer then
                    local targetHRP = bomberPlayer.Character and bomberPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if targetHRP then
                        local originalPos = hrp.CFrame
                        local isStealing = true
                        task.spawn(function()
                            while isStealing do
                                local currentBomber = getBomber()
                                if currentBomber == LocalPlayer then
                                    -- We successfully stole the bomb
                                    isStealing = false
                                    local currentHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                    if currentHrp then
                                        currentHrp.CFrame = originalPos
                                    end
                                    break
                                else
                                    local currentHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                    if currentBomber ~= bomberPlayer then
                                        -- Target is no longer the bomb, stop stealing
                                        isStealing = false
                                        if currentHrp then
                                            currentHrp.CFrame = originalPos
                                        end
                                        break
                                    end
                                    
                                    if currentHrp and targetHRP then
                                        local offsetX = math.random(-15, 15) / 10
                                        local offsetZ = math.random(-15, 15) / 10
                                        currentHrp.CFrame = targetHRP.CFrame * CFrame.new(offsetX, 0, offsetZ)
                                        pcall(function()
                                            local isMobile = game:GetService("UserInputService").TouchEnabled and not game:GetService("UserInputService").MouseEnabled
                                            if isMobile then
                                                firetouchinterest(currentHrp, targetHRP, 0)
                                                task.wait(0.01)
                                                firetouchinterest(currentHrp, targetHRP, 1)
                                            else
                                                firetouchinterest(currentHrp, targetHRP, 0)
                                            end
                                        end)
                                    end
                                end
                                task.wait()
                            end
                        end)
                    end
                end
            end
        end)
    end
})

local lastOptionsStr = ""
local function refreshDropdownList()
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
end

AutoTagSection:Button({
    Title = "Refresh Targets",
    Desc = "Manually refresh the player list for Auto Tag",
    Callback = function()
        refreshDropdownList()
    end
})

auto1v1Toggle = Tabs.Main:Toggle({
    Title = "Auto 1v1",
    Value = false,
    Callback = function(Value)
        auto1v1Enabled = Value
        if Value and autoFarmWinsEnabled then
            auto1v1Enabled = false
            pcall(function() auto1v1Toggle:Set(false) end)
            WindUI:Notify({Title = "Error", Content = "Cannot enable while Auto Farm Wins is active."})
        end
    end
})

Tabs.Main:Button({
    Title = "Disable Lava Kill Intent",
    Callback = function()
        pcall(function()
            local touchInterest = workspace:FindFirstChild("Map") 
                and workspace.Map:FindFirstChild("Lava")
                and workspace.Map.Lava:FindFirstChild("TouchPart")
                and workspace.Map.Lava.TouchPart:FindFirstChild("TouchInterest")
            
            if touchInterest then
                touchInterest:Destroy()
                WindUI:Notify({Title = "Success", Content = "Lava Kill Intent Disabled."})
            else
                WindUI:Notify({Title = "Info", Content = "Lava Kill Intent not found or already disabled."})
            end
        end)
    end
})

local stealTeleported = false
local isInRound = false
local isAutoTagging = false
local lastBomberTime = 0

task.spawn(function()
    while true do
        local delay = 0.5
        local bomber = getBomber()
        local timeLeft = getCountdownTime()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

        local actuallyHasBomber = (bomber ~= nil)
        if actuallyHasBomber then
            lastBomberTime = tick()
        end

        local isRoundActive = actuallyHasBomber or (tick() - lastBomberTime < 4)

        if autoFarmWinsEnabled then
            delay = 0.1
            if isRoundActive then
                if not isInRound then
                    isInRound = true
                    if hrp then
                        originalCFrame = hrp.CFrame
                        safeZoneCFrame = originalCFrame * CFrame.new(0, 50, 0)
                        createSafeBox(safeZoneCFrame)
                        hrp.CFrame = safeZoneCFrame
                        hrp.Velocity = Vector3.new(0,0,0)
                        hasTeleported = true
                    end
                end
                
                if hrp then
                    if bomber == LocalPlayer then
                        local targetHRP = getTargetHRP()
                        if targetHRP then
                            local offsetX = math.random(-15, 15) / 10
                            local offsetZ = math.random(-15, 15) / 10
                            hrp.CFrame = targetHRP.CFrame * CFrame.new(offsetX, 0, offsetZ)
                        end
                    else
                        if safeZoneCFrame and (hrp.Position - safeZoneCFrame.Position).Magnitude > 20 then
                            hrp.CFrame = safeZoneCFrame
                            hrp.Velocity = Vector3.new(0,0,0)
                        end
                    end
                end
            else
                if isInRound then
                    isInRound = false
                    removeSafeBox()
                    if hrp and originalCFrame then
                        hrp.CFrame = originalCFrame
                        hrp.Velocity = Vector3.new(0,0,0)
                    end
                    hasTeleported = false
                    originalCFrame = nil
                    safeZoneCFrame = nil
                end
            end
            
        elseif autoTagEnabled or autoStealBombEnabled then
            if isRoundActive then
                local weAreBomber = (bomber == LocalPlayer)
                
                -- IF WE ARE NO LONGER THE BOMBER, INSTANTLY STOP AUTOTAGGING
                if not weAreBomber and isAutoTagging then
                    isAutoTagging = false
                    if hasTeleported and autoTagEnabled and originalCFrame and hrp then
                        hrp.CFrame = originalCFrame 
                        hrp.Velocity = Vector3.new(0,0,0)
                        hasTeleported = false
                        originalCFrame = nil
                    end
                end

                if bomber and timeLeft then
                    if timeLeft <= 3 then
                        delay = 0.05
                    end
                    
                    if weAreBomber then
                        -- We are the Bomber
                        if stealTeleported then
                            if hasTeleported and originalCFrame and hrp then
                                hrp.CFrame = originalCFrame
                                hrp.Velocity = Vector3.new(0,0,0)
                            end
                            hasTeleported = false
                            originalCFrame = nil
                            stealTeleported = false
                        end
                        
                        if autoTagEnabled then
                            if timeLeft <= 2 and timeLeft > 1 then
                                -- Evade at < 2s
                                local targetHRP = getTargetHRP()
                                if targetHRP and hrp and (hrp.Position - targetHRP.Position).Magnitude <= 5 then
                                    local direction = (hrp.Position - targetHRP.Position).Unit
                                    if direction.X ~= direction.X then direction = Vector3.new(1,0,0) end
                                    direction = Vector3.new(direction.X, 0, direction.Z).Unit
                                    local newPos = targetHRP.Position + direction * 10
                                    local clampedX = math.clamp(newPos.X, -56, 1)
                                    local clampedZ = math.clamp(newPos.Z, -70, -13)
                                    hrp.CFrame = CFrame.new(clampedX, 5, clampedZ)
                                end
                            elseif timeLeft <= 1 or isAutoTagging then
                                local targetHRP = getTargetHRP()
                                if targetHRP and hrp then
                                    if not hasTeleported then
                                        originalCFrame = hrp.CFrame
                                        hasTeleported = true
                                    end
                                    isAutoTagging = true
                                    local offsetX = math.random(-15, 15) / 10
                                    local offsetZ = math.random(-15, 15) / 10
                                    hrp.CFrame = targetHRP.CFrame * CFrame.new(offsetX, 0, offsetZ)
                                    
                                    pcall(function()
                                        local isMobile = game:GetService("UserInputService").TouchEnabled and not game:GetService("UserInputService").MouseEnabled
                                        if isMobile then
                                            firetouchinterest(hrp, targetHRP, 0)
                                            task.wait(0.01)
                                            firetouchinterest(hrp, targetHRP, 1)
                                        else
                                            firetouchinterest(hrp, targetHRP, 0)
                                        end
                                    end)
                                end
                            end
                        end
                    else
                        -- We are a Runner
                        
                        if autoTagEnabled and timeLeft <= 2 then
                            local bombTarget = bomber.Character and bomber.Character:FindFirstChild("HumanoidRootPart")
                            if bombTarget and hrp then
                                if (hrp.Position - bombTarget.Position).Magnitude <= 5 then
                                    local direction = (hrp.Position - bombTarget.Position).Unit
                                    if direction.X ~= direction.X then direction = Vector3.new(1,0,0) end
                                    direction = Vector3.new(direction.X, 0, direction.Z).Unit
                                    local newPos = bombTarget.Position + direction * 10
                                    local clampedX = math.clamp(newPos.X, -56, 1)
                                    local clampedZ = math.clamp(newPos.Z, -70, -13)
                                    hrp.CFrame = CFrame.new(clampedX, 5, clampedZ)
                                end
                            end
                        end
                        
                        if autoStealBombEnabled then
                            if timeLeft <= 2 and timeLeft > 0 then
                                local targetHRP = bomber.Character and bomber.Character:FindFirstChild("HumanoidRootPart")
                                
                                if targetHRP and hrp then
                                    if not hasTeleported then
                                        originalCFrame = hrp.CFrame
                                        hasTeleported = true
                                    end
                                    stealTeleported = true
                                    local offsetX = math.random(-15, 15) / 10
                                    local offsetZ = math.random(-15, 15) / 10
                                    hrp.CFrame = targetHRP.CFrame * CFrame.new(offsetX, 0, offsetZ)
                                end
                            end
                        end
                        
                        if timeLeft > 2.5 then
                            stealTeleported = false
                        end
                    end
                end
            else
                -- Logic when round ends / no bomber exists
                if hasTeleported and originalCFrame and hrp then
                    hrp.CFrame = originalCFrame 
                    hrp.Velocity = Vector3.new(0,0,0)
                    hasTeleported = false
                    originalCFrame = nil
                end
                
                if stealTeleported and originalCFrame and not hasTeleported and hrp then
                    hrp.CFrame = originalCFrame 
                    hrp.Velocity = Vector3.new(0,0,0) 
                    stealTeleported = false
                    originalCFrame = nil
                end
                
                isAutoTagging = false
                stealTeleported = false
            end
        elseif auto1v1Enabled then
            local count = 0
            local otherPlayer = nil
            local localInArena = false
            local Players = game:GetService("Players")
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character then
                    local checkHrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if checkHrp then
                        local pos = checkHrp.Position
                        local minX, maxX = -56, 1
                        local minY, maxY = 5, 100
                        local minZ, maxZ = -70, -13
                        if pos.X >= minX and pos.X <= maxX and pos.Y >= minY and pos.Y <= maxY and pos.Z >= minZ and pos.Z <= maxZ then
                            local humanoid = p.Character:FindFirstChild("Humanoid")
                            if humanoid and humanoid.Health > 0 then
                                count = count + 1
                                if p == LocalPlayer then
                                    localInArena = true
                                else
                                    otherPlayer = p
                                end
                            end
                        end
                    end
                end
            end

            if count == 2 and localInArena and otherPlayer then
                create1v1Platform()
                delay = 0.05
                local targetHRP = otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP and hrp then
                    local tPos = targetHRP.Position
                    local yPos = tPos.Y
                    if yPos < 5 then yPos = 5 end -- keep above platform which is at Y=3
                    
                    local offsetX = math.random(-15, 15) / 10
                    local offsetZ = math.random(-15, 15) / 10
                    
                    local myX = math.clamp(tPos.X + offsetX, -55, 0)
                    local myZ = math.clamp(tPos.Z + offsetZ, -69, -14)
                    local myPos = Vector3.new(myX, yPos, myZ)
                    local facingPos = Vector3.new(tPos.X, yPos, tPos.Z)
                    hrp.CFrame = CFrame.lookAt(myPos, facingPos)
                    
                    pcall(function()
                        local uis = game:GetService("UserInputService")
                        local isMobile = uis.TouchEnabled and not uis.MouseEnabled
                        if isMobile then
                            firetouchinterest(hrp, targetHRP, 0)
                            task.wait(0.01)
                            firetouchinterest(hrp, targetHRP, 1)
                        else
                            firetouchinterest(hrp, targetHRP, 0)
                        end
                    end)
                    
                    local cam = workspace.CurrentCamera
                    if cam then
                        local vim = game:GetService("VirtualInputManager")
                        local vp = cam.ViewportSize
                        local cx = vp.X / 2
                        local cy = vp.Y - (vp.Y * 0.1) -- 10% from the bottom
                        
                        vim:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
                        task.wait(0.01)
                        vim:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
                    end
                end
            else
                remove1v1Platform()
                delay = 0.1
            end
        end
        
        if not auto1v1Enabled then
            remove1v1Platform()
        end
        
        task.wait(delay)
    end
end)

-- ══════════════════════════════════════════
--              SETTINGS LOGIC
-- ══════════════════════════════════════════
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

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

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local touchInterest = workspace:FindFirstChild("Map") 
                and workspace.Map:FindFirstChild("Lava")
                and workspace.Map.Lava:FindFirstChild("TouchPart")
                and workspace.Map.Lava.TouchPart:FindFirstChild("TouchInterest")
            
            if touchInterest then
                touchInterest:Destroy()
            end
        end)
    end
end)

WindUI:Notify({
    Title = "Prime X Hub",
    Content = "Script loaded successfully!",
    Duration = 5
})
