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
    Main = Window:Tab({ Title = "Main", Icon = "solar:bolt-bold" }),
    Movement = Window:Tab({ Title = "Movement", Icon = "solar:running-bold" }),
    Teleport = Window:Tab({ Title = "Teleport", Icon = "solar:map-point-bold" }),
    Settings = Window:Tab({ Title = "Settings", Icon = "solar:settings-bold" }),
    AboutUs  = Window:Tab({ Title = "About Us", Icon = "solar:info-circle-bold" })
}

-- ══════════════════════════════════════════
--              MAIN SCRIPT FEATURES
-- ══════════════════════════════════════════

local isMobile = game:GetService("UserInputService").TouchEnabled

Tabs.Main:Button({
    Title = "Remove Doors",
    Callback = function()
        local mapa = workspace:FindFirstChild("Mapa") or workspace:FindFirstChild("mapa")
        if mapa then
            for _, v in ipairs(mapa:GetDescendants()) do
                if v.Name == "Door" then
                    v:Destroy()
                end
            end
        end
    end
})

Tabs.Main:Button({
    Title = "Get All Free Weapon",
    Callback = function()
        local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local oldCFrame = hrp.CFrame
            hrp.CFrame = CFrame.new(16, 23, 512)
            task.wait(2)
            
            pcall(function()
                local mapa = workspace:FindFirstChild("Mapa") or workspace:FindFirstChild("mapa")
                if mapa then
                    local function getGiverPart(giverFolder, partName)
                        if not giverFolder then return nil end
                        for _, child in ipairs(giverFolder:GetChildren()) do
                            if child.Name == partName and child:FindFirstChild("TouchInterest") then
                                return child
                            end
                        end
                        return giverFolder:FindFirstChild(partName)
                    end
                    
                    local armasGiver = mapa:FindFirstChild("ArmasGivers") and mapa.ArmasGivers:FindFirstChild("Giver")
                    local armoursGiver = mapa:FindFirstChild("ArmoursGivers") and mapa.ArmoursGivers:FindFirstChild("Giver")
                    
                    local p1 = getGiverPart(armasGiver, "DoubleBarrelShotgun")
                    local p2 = getGiverPart(armasGiver, "Ak47")
                    local p3 = getGiverPart(armoursGiver, "Light")
                    
                    local parts = {p1, p2, p3}
                    for i, p in ipairs(parts) do
                        if p and p:IsA("BasePart") then
                            hrp.CFrame = p.CFrame
                            task.wait(1.5)
                        end
                    end
                end
            end)
            
            hrp.CFrame = oldCFrame
        end
    end
})

local espEnabled = false
local espHighlights = {}

local function updateESP()
    for char, hl in pairs(espHighlights) do
        local hum = char and char:FindFirstChild("Humanoid")
        if not char or not char.Parent or not espEnabled or not hum or hum.Health <= 0 then
            if hl and hl.Parent then hl:Destroy() end
            espHighlights[char] = nil
        end
    end
    
    if not espEnabled then return end
    
    local function applyEspToChar(char)
        if char.Name == game.Players.LocalPlayer.Name then return end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then return end
        
        local isCat = char:FindFirstChild("Ears") ~= nil
        local hasCatState = false
        
        if isCat then
            local head = char:FindFirstChild("Head")
            local catState = head and head:FindFirstChild("CatStateBillboardGUI")
            if catState then
                hasCatState = true
            end
        end
        
        local color = Color3.new(0, 0, 1) -- Blue for Police
        if isCat then
            if hasCatState then
                color = Color3.new(1, 0, 0) -- Red for Cat with State
            else
                color = Color3.new(1, 1, 0) -- Yellow for normal Cat
            end
        end
        
        local hl = espHighlights[char]
        if not hl or not hl.Parent then
            hl = Instance.new("Highlight")
            hl.Name = "PXH_ESP"
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0.2
            hl.Parent = char
            espHighlights[char] = hl
        end
        
        hl.FillColor = color
        hl.OutlineColor = color
    end
    
    local charFolder = workspace:FindFirstChild("Characters")
    if charFolder then
        for _, char in ipairs(charFolder:GetChildren()) do
            applyEspToChar(char)
        end
    end
    
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= game.Players.LocalPlayer and plr.Character then
            applyEspToChar(plr.Character)
        end
    end
end

Tabs.Main:Toggle({
    Title = "Player ESP",
    Callback = function(val)
        espEnabled = val
        if not val then
            for char, hl in pairs(espHighlights) do
                if hl and hl.Parent then hl:Destroy() end
            end
            table.clear(espHighlights)
        end
    end
})

task.spawn(function()
    while task.wait(1) do
        if espEnabled then
            pcall(updateESP)
        end
    end
end)

local hitBoxExpanderEnabled = false
local originalHRP = {}

local function revertHitbox(char)
    if originalHRP[char] then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Size = originalHRP[char].Size
            hrp.Transparency = originalHRP[char].Trans
        end
        originalHRP[char] = nil
    end
end

local function revertAllHitboxes()
    for char, _ in pairs(originalHRP) do
        revertHitbox(char)
    end
end

Tabs.Main:Toggle({
    Title = "HitBox Expander",
    Callback = function(val)
        hitBoxExpanderEnabled = val
        if not val then
            pcall(revertAllHitboxes)
        end
    end
})

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if not hitBoxExpanderEnabled then return end
            
            local selfIsCat = false
            local myChar = workspace:FindFirstChild("Characters") and workspace.Characters:FindFirstChild(game.Players.LocalPlayer.Name) or game.Players.LocalPlayer.Character
            if myChar and myChar:FindFirstChild("Ears") then
                selfIsCat = true
            end
            
            local function resizeChar(char)
                if char.Name == game.Players.LocalPlayer.Name then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChild("Humanoid")
                
                if hrp and hum and hum.Health > 0 and not char:FindFirstChild("PVPOFFGUI") then
                    local isEnemyCat = char:FindFirstChild("Ears") ~= nil
                    local shouldExpand = (selfIsCat and not isEnemyCat) or (not selfIsCat and isEnemyCat)
                    
                    if shouldExpand then
                        if not originalHRP[char] then
                            originalHRP[char] = { Size = hrp.Size, Trans = hrp.Transparency }
                        end
                        hrp.Size = Vector3.new(10, 10, 5)
                        hrp.Transparency = 0.5
                        hrp.CanCollide = false
                    else
                        revertHitbox(char)
                    end
                else
                    revertHitbox(char)
                end
            end
            
            local charsFolder = workspace:FindFirstChild("Characters")
            if charsFolder then
                for _, char in ipairs(charsFolder:GetChildren()) do
                    resizeChar(char)
                end
            end
            for _, plr in ipairs(game.Players:GetPlayers()) do
                if plr ~= game.Players.LocalPlayer and plr.Character then
                    resizeChar(plr.Character)
                end
            end
            
            for char, _ in pairs(originalHRP) do
                if not char.Parent then
                    originalHRP[char] = nil
                end
            end
        end)
    end
end)

local KillAuraSection = Tabs.Main:Section({
    Title = "Kill Aura Options",
    Box = true,
    BoxBorder = true,
    Opened = true
})

local gunKillAuraEnabled = false
local killAuraRadius = 50

KillAuraSection:Toggle({
    Title = "Gun Kill Aura (Kill Police)",
    Callback = function(val)
        gunKillAuraEnabled = val
    end
})

local gunKillAuraCatEnabled = false
KillAuraSection:Toggle({
    Title = "Gun Kill All (Kill Cats)",
    Callback = function(val)
        gunKillAuraCatEnabled = val
    end
})

local ringFolder = nil
local lastSliderChange = 0
local alwaysShowRange = false

local function updateSphere(isPreview)
    local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if not ringFolder or not ringFolder.Parent then
        ringFolder = Instance.new("Folder")
        ringFolder.Name = "AuraRing"
        ringFolder.Parent = workspace
    end
    
    -- Calculate segments based on radius, more radius = more parts for smooth curve
    local segments = math.clamp(math.floor(killAuraRadius / 2), 16, 72)
    local angleStep = (math.pi * 2) / segments
    -- wallWidth calculation so the segments connect at the edges forming a continuous circle
    local wallWidth = (2 * killAuraRadius * math.tan(math.pi / segments)) + 0.1
    
    local currentParts = ringFolder:GetChildren()
    if #currentParts < segments then
        for i = #currentParts + 1, segments do
            local part = Instance.new("Part")
            part.Anchored = true
            part.CanCollide = false
            part.CastShadow = false
            part.Material = Enum.Material.Neon
            part.Parent = ringFolder
        end
    elseif #currentParts > segments then
        for i = segments + 1, #currentParts do
            currentParts[i]:Destroy()
        end
    end
    
    currentParts = ringFolder:GetChildren()
    local center = hrp.Position
    
    for i, part in ipairs(currentParts) do
        local angle = (i - 1) * angleStep
        local x = center.X + math.cos(angle) * killAuraRadius
        local z = center.Z + math.sin(angle) * killAuraRadius
        
        local pos = Vector3.new(x, center.Y, z)
        part.Size = Vector3.new(wallWidth, 10, 5)
        -- Aim towards center (CFrame.lookAt acts same as CFrame.new(pos, lookAt))
        part.CFrame = CFrame.new(pos, center)
        -- Ensuring we reset transparency when slider is moved again
        if alwaysShowRange and not isPreview then
            part.Color = Color3.fromRGB(150, 150, 150)
            part.Transparency = 0.85
        else
            part.Color = Color3.new(1, 0, 0)
            part.Transparency = 0.5
        end
    end
end

KillAuraSection:Slider({
    Title = "Aura Radius",
    Step = 1,
    Value = {
        Min = 1,
        Max = 360,
        Default = 50,
    },
    Callback = function(value)
        killAuraRadius = value
        
        local changeTime = os.clock()
        lastSliderChange = changeTime
        
        task.delay(0.05, function()
            if lastSliderChange == changeTime then
                updateSphere(true)
                
                task.delay(2, function()
                    if lastSliderChange == changeTime and ringFolder then
                        if alwaysShowRange then
                            for _, part in ipairs(ringFolder:GetChildren()) do
                                part.Color = Color3.fromRGB(150, 150, 150)
                                part.Transparency = 0.85
                            end
                        else
                            for i = 1, 100 do
                                if ringFolder and lastSliderChange == changeTime and not alwaysShowRange then
                                    local t = 0.5 + (i / 100) * 0.5
                                    for _, part in ipairs(ringFolder:GetChildren()) do
                                        part.Transparency = t
                                    end
                                else
                                    break
                                end
                                task.wait(0.02)
                            end
                            if ringFolder and lastSliderChange == changeTime and not alwaysShowRange then
                                ringFolder:Destroy()
                                ringFolder = nil
                            end
                        end
                    end
                end)
            end
        end)
    end
})

KillAuraSection:Toggle({
    Title = "Always Show Range",
    Callback = function(val)
        alwaysShowRange = val
        if val then
            updateSphere(false)
        else
            if ringFolder then
                ringFolder:Destroy()
                ringFolder = nil
            end
        end
    end
})

task.spawn(function()
    while task.wait(0.05) do
        if alwaysShowRange then
            updateSphere(false)
        end
    end
end)

local function isSelfCat()
    local myChar = workspace:FindFirstChild("Characters") and workspace.Characters:FindFirstChild(game.Players.LocalPlayer.Name)
    if not myChar then
        myChar = game.Players.LocalPlayer.Character
    end
    if myChar and myChar:FindFirstChild("Ears") then
        return true
    end
    return false
end

local WeaponData = {
    RPG7 = { FireRate = 2, BulletCount = 1 },
    M60 = { FireRate = 0.06, BulletCount = 2 },
    DoubleBarrelShotgun = { FireRate = 0.4, BulletCount = 12 },
    GoldenAk47 = { FireRate = 0.08, BulletCount = 1 },
    Uzi = { FireRate = 0.05, BulletCount = 2 },
    Revolver = { FireRate = 0.15, BulletCount = 1 },
    Rifle = { FireRate = 0.09, BulletCount = 1 },
    AWMSniper = { FireRate = 1, BulletCount = 1 },
    Ak47 = { FireRate = 0.1, BulletCount = 1 },
    Pistol = { FireRate = 0.1, BulletCount = 1 },
    Shotgun = { FireRate = 0.9, BulletCount = 7 },
    TranquilizerGun = { FireRate = 0.15, BulletCount = 1 }
}
local WeaponsPriority = { "GoldenAk47", "M60", "Rifle", "Uzi", "Ak47", "RPG7", "Revolver", "Pistol", "DoubleBarrelShotgun", "Shotgun", "AWMSniper", "TranquilizerGun" }

local lastTargetTime = 0

task.spawn(function()
    while true do
        local loopDelay = 0.1
        if not gunKillAuraEnabled and not gunKillAuraCatEnabled then
            task.wait(0.2)
        else
            pcall(function()
                local isCat = isSelfCat()
                local activeTargeting = false
                
                if gunKillAuraEnabled and isCat then
                    activeTargeting = "Police"
                elseif gunKillAuraCatEnabled and not isCat then
                    activeTargeting = "Cat"
                end
                
                if not activeTargeting then 
                    loopDelay = 0.2
                    return 
                end
                
                local myChar = game.Players.LocalPlayer.Character
                local hrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                
                local weapons = WeaponsPriority
                
                local equippedWeapon = nil
                local foundWeapon = nil
                
                for _, wName in ipairs(weapons) do
                    local wep = myChar:FindFirstChild(wName)
                    if wep then
                        equippedWeapon = wName
                        foundWeapon = wep
                        break
                    end
                    local wepBp = game.Players.LocalPlayer.Backpack:FindFirstChild(wName)
                    if wepBp then
                        foundWeapon = wepBp
                        local hum = myChar:FindFirstChild("Humanoid")
                        if hum then
                            hum:EquipTool(foundWeapon)
                            equippedWeapon = wName
                            task.wait(0.1)
                        end
                        break
                    end
                end
                
                if not equippedWeapon then 
                    loopDelay = 0.2
                    return 
                end
                
                local targetHRP = nil
                local targetPlayerName = nil
                local minDist = killAuraRadius
                
                local function checkChar(char, plrName)
                    if char.Name == game.Players.LocalPlayer.Name then return end
                    local tHRP = char:FindFirstChild("HumanoidRootPart")
                    local hum = char:FindFirstChild("Humanoid")
                    local head = char:FindFirstChild("Head")
                    
                    if tHRP and hum and hum.Health > 0 and not char:FindFirstChild("PVPOFFGUI") then
                        local isEnemyCat = char:FindFirstChild("Ears") ~= nil
                        local isValidTarget = false
                        
                        if activeTargeting == "Police" then
                            isValidTarget = not isEnemyCat
                        elseif activeTargeting == "Cat" then
                            isValidTarget = false
                            if isEnemyCat and head then
                                local catState = head:FindFirstChild("CatStateBillboardGUI")
                                if catState then
                                    isValidTarget = true
                                end
                            end
                        end
                        
                        if isValidTarget then
                            local dist = (tHRP.Position - hrp.Position).Magnitude
                            if dist < minDist then
                                minDist = dist
                                targetHRP = tHRP
                                targetPlayerName = plrName
                            end
                        end
                    end
                end
                
                local charFolder = workspace:FindFirstChild("Characters")
                if charFolder then
                    for _, char in ipairs(charFolder:GetChildren()) do
                        checkChar(char, char.Name)
                    end
                end
                
                for _, plr in ipairs(game.Players:GetPlayers()) do
                    if plr ~= game.Players.LocalPlayer and plr.Character then
                        checkChar(plr.Character, plr.Name)
                    end
                end
                
                local currentAmmo = "1/1"
                local ammoGUI = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("AmmoHUD")
                if ammoGUI and ammoGUI:FindFirstChild("Background") and ammoGUI.Background:FindFirstChild("Ammo") then
                    currentAmmo = ammoGUI.Background.Ammo.Text
                end
                
                local needsReload = false
                local ammoLeft, ammoMax = string.match(currentAmmo, "^(%d+)/(%d+)")
                if ammoLeft and ammoMax then
                    ammoLeft = tonumber(ammoLeft)
                    ammoMax = tonumber(ammoMax)
                    if ammoLeft and ammoMax and ammoMax > 0 then
                        if ammoLeft == 0 then
                            needsReload = "immediate"
                        elseif ammoLeft / ammoMax < 0.25 then
                            needsReload = "idle"
                        end
                    end
                elseif string.match(currentAmmo, "^Reloading") then
                    needsReload = "reloading"
                end

                if targetPlayerName and game:GetService("Players"):FindFirstChild(targetPlayerName) and game:GetService("Players"):FindFirstChild(targetPlayerName).Character then
                    local targetChar = game.Players[targetPlayerName].Character
                    local actualTargetPart = targetChar:WaitForChild("HumanoidRootPart")
                    
                    lastTargetTime = tick()
                    
                    if needsReload == "immediate" then
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ReloadRequest"):FireServer(equippedWeapon)
                        loopDelay = 0.5
                    elseif needsReload == "reloading" then
                        loopDelay = 0.1
                    else
                        local fireRate = WeaponData[equippedWeapon] and WeaponData[equippedWeapon].FireRate or 0.1
                        local bCount = WeaponData[equippedWeapon] and WeaponData[equippedWeapon].BulletCount or 1
                        local targetDir = (actualTargetPart.Position - hrp.Position).Unit
                        
                        local bullets = {}
                        for i = 1, bCount do
                            local dir = targetDir
                            if bCount > 1 then
                                dir = CFrame.lookAt(Vector3.zero, targetDir) * CFrame.Angles(
                                    (math.random() - 0.5) * 0.05,
                                    (math.random() - 0.5) * 0.05,
                                    0
                                ).LookVector
                            end
                            table.insert(bullets, {
                                Direction = dir,
                                HitPart = actualTargetPart,
                                HitPosition = actualTargetPart.Position,
                                Origin = hrp.Position
                            })
                        end
                        
                        local args = {
                            equippedWeapon,
                            bullets
                        }
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ShootRequest"):FireServer(unpack(args))
                        loopDelay = fireRate
                    end
                else
                    if needsReload == "idle" and tick() - lastTargetTime >= 1 then
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ReloadRequest"):FireServer(equippedWeapon)
                        loopDelay = 0.5
                    end
                end
            end)
            task.wait(loopDelay)
        end
    end
end)

local TeleportLocations = {
    ["Cat Base"] = Vector3.new(20, 23, 517),
    ["Mid Jungle"] = Vector3.new(189, 24, 328),
    ["Jail"] = Vector3.new(120, 13, -48),
    ["Below Guard Base (Tunnel)"] = Vector3.new(202, -62, -144)
}

local selectedTeleportArea = "Cat Base"

local AreaTPSection = Tabs.Teleport:Section({ 
    Title = "Area Teleport",
    Box = true,
    BoxBorder = true,
    Opened = true
})

AreaTPSection:Button({
    Title = "Teleport To An Area",
    Callback = function()
        pcall(function()
            local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp and TeleportLocations[selectedTeleportArea] then
                hrp.CFrame = CFrame.new(TeleportLocations[selectedTeleportArea])
            end
        end)
    end
})

AreaTPSection:Dropdown({
    Title = "Select Area",
    Values = {"Cat Base", "Mid Jungle", "Jail", "Below Guard Base (Tunnel)"},
    Value = "Cat Base",
    Callback = function(Value)
        selectedTeleportArea = Value
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
