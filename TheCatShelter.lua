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
            task.wait(1)
            
            pcall(function()
                local mapa = workspace:FindFirstChild("Mapa") or workspace:FindFirstChild("mapa")
                if mapa then
                    local p1 = mapa:FindFirstChild("ArmasGivers") and mapa.ArmasGivers:FindFirstChild("Giver") and mapa.ArmasGivers.Giver:FindFirstChild("Ak47")
                    local p2 = mapa:FindFirstChild("ArmasGivers") and mapa.ArmasGivers.Giver:FindFirstChild("DoubleBarrelShotgun")
                    local p3 = mapa:FindFirstChild("ArmoursGivers") and mapa.ArmoursGivers:FindFirstChild("Giver") and mapa.ArmoursGivers.Giver:FindFirstChild("Light")
                    
                    local parts = {p1, p2, p3}
                    for i, p in ipairs(parts) do
                        if p and p:IsA("BasePart") then
                            hrp.CFrame = p.CFrame
                            if i < 3 then
                                task.wait(1)
                            else
                                task.wait(0.1)
                            end
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
        local head = char:FindFirstChild("Head")
        local hasCatState = false
        if head and head:FindFirstChild("CatStateBillboardGUI") then
            hasCatState = true
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
    while task.wait(0.5) do
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

local spherePart = nil
local lastSliderChange = 0

local function updateSphere()
    local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if not spherePart or not spherePart.Parent then
        spherePart = Instance.new("Part")
        spherePart.Shape = Enum.PartType.Ball
        spherePart.Material = Enum.Material.Plastic
        spherePart.Color = Color3.new(1, 0, 0)
        spherePart.Transparency = 0.2
        spherePart.CanCollide = false
        spherePart.Anchored = true
        spherePart.CastShadow = false
        spherePart.Parent = workspace
        
        local innerSphere = Instance.new("Part")
        innerSphere.Name = "InnerSphere"
        innerSphere.Shape = Enum.PartType.Ball
        innerSphere.Material = Enum.Material.Plastic
        innerSphere.Color = Color3.new(1, 0, 0)
        innerSphere.Transparency = 0.2
        innerSphere.CanCollide = false
        innerSphere.Anchored = true
        innerSphere.CastShadow = false
        
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.Sphere
        mesh.Scale = Vector3.new(-1, -1, -1)
        mesh.Parent = innerSphere
        
        innerSphere.Parent = spherePart
    end
    
    spherePart.Size = Vector3.new(killAuraRadius * 2, killAuraRadius * 2, killAuraRadius * 2)
    spherePart.Position = hrp.Position
    spherePart.Transparency = 0.2
    
    local inner = spherePart:FindFirstChild("InnerSphere")
    if inner then
        inner.Size = spherePart.Size
        inner.Position = spherePart.Position
        inner.Transparency = spherePart.Transparency
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
                updateSphere()
                
                task.delay(2, function()
                    if lastSliderChange == changeTime and spherePart then
                        for i = 1, 100 do
                            if spherePart and lastSliderChange == changeTime then
                                local t = 0.2 + (i / 100) * 0.8
                                spherePart.Transparency = t
                                local inner = spherePart:FindFirstChild("InnerSphere")
                                if inner then inner.Transparency = t end
                            else
                                break
                            end
                            task.wait(0.02)
                        end
                        if spherePart and lastSliderChange == changeTime then
                            spherePart:Destroy()
                            spherePart = nil
                        end
                    end
                end)
            end
        end)
    end
})

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
                
                local weapons = {"AWMSniper", "M60", "GoldenAk47", "Rifle", "Ak47", "DoubleBarrelShotgun", "Shotgun"}
                
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
                
                if targetPlayerName and game:GetService("Players"):FindFirstChild(targetPlayerName) and game:GetService("Players"):FindFirstChild(targetPlayerName).Character then
                    local targetChar = game.Players[targetPlayerName].Character
                    local actualTargetPart = targetChar:WaitForChild("HumanoidRootPart")
                    
                    local currentAmmo = "1/1"
                    local ammoGUI = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("AmmoHUD")
                    if ammoGUI and ammoGUI:FindFirstChild("Background") and ammoGUI.Background:FindFirstChild("Ammo") then
                        currentAmmo = ammoGUI.Background.Ammo.Text
                    end
                    
                    if string.match(currentAmmo, "^0/") then
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ReloadRequest"):FireServer(equippedWeapon)
                        loopDelay = 0.5
                    elseif string.match(currentAmmo, "^Reloading") then
                        loopDelay = 0.1
                    else
                        if equippedWeapon == "DoubleBarrelShotgun" then
                            local args = {
                                "DoubleBarrelShotgun",
                                {
                                    { Direction = Vector3.new(-0.8777754902839661, 0.35243743658065796, 0.32449692487716675), HitPart = actualTargetPart, HitPosition = actualTargetPart.Position, Origin = hrp.Position },
                                    { Direction = Vector3.new(-0.8908711671829224, 0.30258309841156006, 0.338809996843338), HitPart = actualTargetPart, HitPosition = actualTargetPart.Position, Origin = hrp.Position },
                                    { Direction = Vector3.new(-0.9362114667892456, 0.23900267481803894, 0.25765499472618103), HitPart = actualTargetPart, HitPosition = actualTargetPart.Position, Origin = hrp.Position },
                                    { Direction = Vector3.new(-0.9233906269073486, 0.27403345704078674, 0.26880407333374023), HitPart = actualTargetPart, HitPosition = actualTargetPart.Position, Origin = hrp.Position },
                                    { Direction = Vector3.new(-0.9175576567649841, 0.2601691484451294, 0.30066612362861633), HitPart = actualTargetPart, HitPosition = actualTargetPart.Position, Origin = hrp.Position },
                                    { Direction = Vector3.new(-0.8845078349113464, 0.33693602681159973, 0.32267671823501587), HitPart = actualTargetPart, HitPosition = actualTargetPart.Position, Origin = hrp.Position },
                                    { Direction = Vector3.new(-0.9172711968421936, 0.3114051818847656, 0.24827507138252258), HitPart = actualTargetPart, HitPosition = actualTargetPart.Position, Origin = hrp.Position },
                                    { Direction = Vector3.new(-0.8665684461593628, 0.35421502590179443, 0.35155510902404785), HitPart = actualTargetPart, HitPosition = actualTargetPart.Position, Origin = hrp.Position },
                                    { Direction = Vector3.new(-0.9057658910751343, 0.23491910099983215, 0.35270562767982483), HitPart = actualTargetPart, HitPosition = actualTargetPart.Position, Origin = hrp.Position },
                                    { Direction = Vector3.new(-0.8902404308319092, 0.3309277892112732, 0.31298378109931946), HitPart = actualTargetPart, HitPosition = actualTargetPart.Position, Origin = hrp.Position },
                                    { Direction = Vector3.new(-0.9130688905715942, 0.29724279046058655, 0.2791989743709564), HitPart = actualTargetPart, HitPosition = actualTargetPart.Position, Origin = hrp.Position },
                                    { Direction = Vector3.new(-0.8934589624404907, 0.3214917778968811, 0.313646525144577), HitPart = actualTargetPart, HitPosition = actualTargetPart.Position, Origin = hrp.Position }
                                }
                            }
                            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ShootRequest"):FireServer(unpack(args))
                        elseif equippedWeapon == "Shotgun" then
                            local args = {
                                "Shotgun",
                                {
                                    { Direction = Vector3.new(0.8891921639442444, 0.3844687342643738, 0.24803447723388672), HitPart = actualTargetPart, HitPosition = actualTargetPart.Position, Origin = hrp.Position },
                                    { Direction = Vector3.new(0.8799793124198914, 0.4288162291049957, 0.20433567464351654), HitPart = actualTargetPart, HitPosition = actualTargetPart.Position, Origin = hrp.Position },
                                    { Direction = Vector3.new(0.8953884243965149, 0.376289427280426, 0.23808813095092773), HitPart = actualTargetPart, HitPosition = actualTargetPart.Position, Origin = hrp.Position },
                                    { Direction = Vector3.new(0.885267436504364, 0.3988744914531708, 0.23916688561439514), HitPart = actualTargetPart, HitPosition = actualTargetPart.Position, Origin = hrp.Position },
                                    { Direction = Vector3.new(0.8662892580032349, 0.4485095739364624, 0.21995949745178223), HitPart = actualTargetPart, HitPosition = actualTargetPart.Position, Origin = hrp.Position },
                                    { Direction = Vector3.new(0.8932737112045288, 0.41170379519462585, 0.18044978380203247), HitPart = actualTargetPart, HitPosition = actualTargetPart.Position, Origin = hrp.Position },
                                    { Direction = Vector3.new(0.8662761449813843, 0.45726028084754944, 0.20119325816631317), HitPart = actualTargetPart, HitPosition = actualTargetPart.Position, Origin = hrp.Position }
                                }
                            }
                            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ShootRequest"):FireServer(unpack(args))
                        else
                            local args = {
                                equippedWeapon,
                                {
                                    { Direction = Vector3.new(-0.08102967590093613, -0.9508105516433716, 0.2989876866340637), HitPart = actualTargetPart, HitPosition = actualTargetPart.Position, Origin = hrp.Position }
                                }
                            }
                            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ShootRequest"):FireServer(unpack(args))
                        end
                        loopDelay = 0.02
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

local AreaTPSection = Tabs.Teleport:Section({ Title = "Area Teleport" })

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
