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
        -- Patch Dropdown to toggle instead of flickering/re-opening when clicking value
        windUI_Source = windUI_Source:gsub("function%(%)%s*ar:Open%(%)%s*end", "function() if an.Opened then ar:Close() else ar:Open() end end")
        WindUI = loadstring(windUI_Source)()
    end
end

local gameName = "Unknown Game"
pcall(function()
    gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
end)

local RESTRICTED_POS = Vector3.new(-321, 241, 18)
local RESTRICTED_RADIUS = 300

local function inRestrictedZone()
    local player = game:GetService("Players").LocalPlayer
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local dist = (hrp.Position - RESTRICTED_POS).Magnitude
        if dist <= RESTRICTED_RADIUS then
            return true
        end
    end
    return false
end

task.spawn(function()
    while true do
        task.wait(2)
        if inRestrictedZone() then
            -- print("Is the local player in the restricted zone? Yes. Background tasks from GUI are paused.")
        end
    end
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
    Farm = Window:Tab({ Title = "Farm", Icon = "solar:leaf-bold" }),
    Legit = Window:Tab({ Title = "Legit", Icon = "solar:shield-check-bold" }),
    Rage = Window:Tab({ Title = "Rage", Icon = "solar:danger-bold" }),
    Event = Window:Tab({ Title = "Event", Icon = "solar:star-bold" }),
    Movement = Window:Tab({ Title = "Movement", Icon = "solar:running-bold" }),
    Teleport = Window:Tab({ Title = "Teleport", Icon = "solar:map-point-bold" }),
    Settings = Window:Tab({ Title = "Settings", Icon = "solar:settings-bold" }),
    AboutUs  = Window:Tab({ Title = "About Us", Icon = "solar:info-circle-bold" })
}

-- ══════════════════════════════════════════
--              FARM TAB
-- ══════════════════════════════════════════
local FarmSection = Tabs.Farm:Section({
    Title = "Auto Farm",
    Box = true,
    BoxBorder = true,
    Opened = false
})

getgenv().AutoFarmGameMode = "3v3"
FarmSection:Dropdown({
    Title = "Select Game Mode",
    Values = {"1v1", "2v2", "3v3"},
    Value = "3v3",
    Callback = function(Value)
        getgenv().AutoFarmGameMode = Value
    end
})

getgenv().AutoFarmLoop = false

FarmSection:Paragraph({
    Title = "⚠️ Warning",
    Desc = "We highly recommend using an alt account. Frequent player reports on the MVS Discord may lead to a ban."
})

FarmSection:Toggle({
    Title = "Auto Farm",
    Description = "Automatically queues for matched game mode.",
    Default = false,
    Callback = function(state)
        getgenv().AutoFarmLoop = state
        if state then
            task.spawn(function()
                while getgenv().AutoFarmLoop do
                    task.wait(1)
                    if inRestrictedZone() then
                        pcall(function()
                            local mode = getgenv().AutoFarmGameMode:lower()
                            local args = {
                                "play",
                                {
                                    mode = mode
                                }
                            }
                            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Networking"):WaitForChild("RE/Matchmaking/Matchmaking"):FireServer(unpack(args))
                        end)
                        task.wait(10) -- Wait 10 seconds before firing again
                    end
                end
            end)
            
            pcall(function()
                if getgenv().startAutoKillThread then getgenv().startAutoKillThread() end
                if getgenv().startAutoCollectHatThread then getgenv().startAutoCollectHatThread() end
            end)
        end
    end
})

local AltFarmStreakSection = Tabs.Farm:Section({
    Title = "Auto Farm Alt Streak",
    Box = true,
    BoxBorder = true,
    Opened = false
})

getgenv().AltFarmStreakLoop = false
AltFarmStreakSection:Toggle({
    Title = "Alt Farm",
    Description = "Automatically farm streak with an alt.",
    Default = false,
    Callback = function(state)
        getgenv().AltFarmStreakLoop = state
        if state then
            task.spawn(function()
                local hasFiredRemove = false
                while getgenv().AltFarmStreakLoop do
                    task.wait(1)
                    if inRestrictedZone() then
                        if not hasFiredRemove then
                            pcall(function()
                                local args = { "REMOVE" }
                                game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Networking"):WaitForChild("RE/Match/SetStatePlr"):FireServer(unpack(args))
                            end)
                            hasFiredRemove = true
                        end
                        
                        local LocalPlayer = game:GetService("Players").LocalPlayer
                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        
                        if hrp then
                            if getgenv().AltFarmRole == "Select Role" then
                                print("[Alt Farm] Please select a role first.")
                            else
                                local dest = getgenv().AltFarmRole == "Victim" and Vector3.new(-292, 242, 34) or Vector3.new(-300, 242, 34)
                                print("[Alt Farm] Tweening to destination. Role:", getgenv().AltFarmRole, "Destination:", tostring(dest))
                                local TweenService = game:GetService("TweenService")
                                local info = TweenInfo.new((hrp.Position - dest).Magnitude / 50, Enum.EasingStyle.Linear)
                                local t = TweenService:Create(hrp, info, {CFrame = CFrame.new(dest)})
                                t:Play()
                            end
                        else
                            print("[Alt Farm] HumanoidRootPart not found. Cannot tween.")
                        end
                        
                        task.wait(5) -- Wait before trying to tween again or while queuing
                    else
                        hasFiredRemove = false
                        print("[Alt Farm] Not in restricted zone. Waiting...")
                        task.wait(2)
                    end
                end
            end)
            
            pcall(function()
                if getgenv().startAutoKillThread then getgenv().startAutoKillThread() end
                if getgenv().startAutoCollectHatThread then getgenv().startAutoCollectHatThread() end
            end)
        end
    end
})

getgenv().AltFarmRole = "Select Role"
AltFarmStreakSection:Dropdown({
    Title = "Select Role",
    Values = {"Select Role", "Victim", "Attacker"},
    Value = "Select Role",
    Callback = function(value)
        getgenv().AltFarmRole = value
    end
})

-- ══════════════════════════════════════════
--              LEGIT TAB
-- ══════════════════════════════════════════
local AimbotSection = Tabs.Legit:Section({
    Title = "Aimbot",
    Box = true,
    BoxBorder = true,
    Opened = false
})

local aimbotScreenGui = nil
local aimbotConnection = nil

local function isVisible(targetChar)
    local player = game:GetService("Players").LocalPlayer
    local myChar = player.Character
    if not myChar or not myChar:FindFirstChild("Head") then return false end
    if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then return false end
    
    local myHead = myChar.Head
    local targetHRP = targetChar.HumanoidRootPart
    
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {myChar}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.IgnoreWater = true
    
    local dir = targetHRP.Position - myHead.Position
    local result = workspace:Raycast(myHead.Position, dir, rayParams)
    
    if result and result.Instance then
        if result.Instance:IsDescendantOf(targetChar) then
            return true
        else
            return false
        end
    end
    return true
end

local function getVisibleAimbotTarget()
    local player = game:GetService("Players").LocalPlayer
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    local myName = player.Name
    local myTeam = nil
    local myGameFolder = nil
    local runningGames = workspace:FindFirstChild("RunningGames")
    
    if runningGames then
        for _, gameFolder in ipairs(runningGames:GetChildren()) do
            local alivePlayers = gameFolder:FindFirstChild("AlivePlayers")
            if alivePlayers then
                if alivePlayers:FindFirstChild("TeamRed") and alivePlayers.TeamRed:FindFirstChild(myName) then
                    myTeam = "TeamRed"
                    myGameFolder = gameFolder
                    break
                elseif alivePlayers:FindFirstChild("TeamBlue") and alivePlayers.TeamBlue:FindFirstChild(myName) then
                    myTeam = "TeamBlue"
                    myGameFolder = gameFolder
                    break
                end
            end
        end
    end

    if not myGameFolder or not myTeam then return nil end
    
    local enemyFolder = nil
    local alivePlayers = myGameFolder:FindFirstChild("AlivePlayers")
    if alivePlayers then
        if myTeam == "TeamRed" then
            enemyFolder = alivePlayers:FindFirstChild("TeamBlue")
        else
            enemyFolder = alivePlayers:FindFirstChild("TeamRed")
        end
    end
    
    if not enemyFolder then return nil end
    
    for _, enemyNode in ipairs(enemyFolder:GetChildren()) do
        local enemyPlayer = game:GetService("Players"):FindFirstChild(enemyNode.Name)
        if enemyPlayer and enemyPlayer.Character and enemyPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if isVisible(enemyPlayer.Character) then
                return enemyPlayer.Character
            end
        end
    end
    
    return nil
end

local function handleAimbotFire(targetChar)
    if inRestrictedZone() then return end
    local player = game:GetService("Players").LocalPlayer
    local char = player.Character
    if not char then return end
    
    local currentTool = char:FindFirstChildOfClass("Tool")
    
    -- Auto Equip if nothing in hand
    if not currentTool then
        local bp = player:FindFirstChild("Backpack")
        if bp then
            -- Search for Gun first (no "Slash" child)
            for _, t in ipairs(bp:GetChildren()) do
                if t:IsA("Tool") and not t:FindFirstChild("Slash") then
                    -- print("[Aimbot] Equipping Gun: " .. t.Name)
                    t.Parent = char
                    currentTool = t
                    task.wait(0.1)
                    break
                end
            end
            -- If still no gun, try Knife (has "Slash" child)
            if not currentTool then
                for _, t in ipairs(bp:GetChildren()) do
                    if t:IsA("Tool") and t:FindFirstChild("Slash") then
                        -- print("[Aimbot] Equipping Knife: " .. t.Name)
                        t.Parent = char
                        currentTool = t
                        task.wait(0.1)
                        break
                    end
                end
            end
        end
    end
    
    if not currentTool then 
        -- print("[Aimbot] No tools found in Backpack or Character.")
        return 
    end
    
    if not targetChar then
        targetChar = getVisibleAimbotTarget()
    end
    if not targetChar then 
        -- print("[Aimbot] No valid enemy target found.")
        return 
    end
    local targetPlayer = game:GetService("Players"):FindFirstChild(targetChar.Name)
    if not targetPlayer then return end

    -- Determine if Knife or Gun
    local isKnife = currentTool:FindFirstChild("Slash") ~= nil
    
    if isKnife then
        local myHRP = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
        local enemyHRP = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Head")
        
        local throwRemote = currentTool:FindFirstChild("Throw")
        if throwRemote and throwRemote:IsA("RemoteEvent") and myHRP and enemyHRP then
            pcall(function()
                local args = {
                    myHRP.CFrame,
                    enemyHRP.Position
                }
                throwRemote:FireServer(unpack(args))
            end)
        end
        
        -- Knife Remote: FireServer(LocalPlayer)
        local remote = game:GetService("ReplicatedStorage"):WaitForChild("Packages", 3):WaitForChild("Networking", 3):WaitForChild("RE/Combat/KnifeKill", 3)
        if remote then
            -- print("[Aimbot] Firing Knife Remote at: " .. targetPlayer.Name)
            remote:FireServer(targetPlayer) -- KnifeKill takes targetPlayer
        end
    else
        -- Gun Remote: FireServer(unpack(args))
        local killRemote = currentTool:FindFirstChild("kill")
        if killRemote and killRemote:IsA("RemoteEvent") then
            local myHRP = char:FindFirstChild("HumanoidRootPart")
            local enemyHRP = targetChar:FindFirstChild("HumanoidRootPart")
            if myHRP and enemyHRP then
                -- Calculate normalized direction vector towards closest target
                local dir = (enemyHRP.Position - myHRP.Position).Unit
                
                local fireRemote = currentTool:FindFirstChild("fire")
                if fireRemote and fireRemote:IsA("RemoteEvent") then
                    pcall(function() fireRemote:FireServer() end)
                end
                
                -- print("[Aimbot] Firing Gun Remote at: " .. targetPlayer.Name)
                local args = {
                    targetPlayer,
                    dir
                }
                killRemote:FireServer(unpack(args))
            end
        end
    end
end

AimbotSection:Toggle({
    Title = "Aimbot(Phone)",
    Description = "Red Button = Gun, Blue Button = Knife. Auto Equips & Team Checks.",
    Default = false,
    Callback = function(state)
        if state then
            if aimbotScreenGui then aimbotScreenGui:Destroy() end
            
            aimbotScreenGui = Instance.new("ScreenGui")
            aimbotScreenGui.Name = "AimbotPhoneUI"
            aimbotScreenGui.Parent = game:GetService("CoreGui")
            
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 80, 0, 80)
            btn.Position = UDim2.new(0.65, 0, 0.45, 0)
            btn.Text = "FIRE"
            btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 18
            btn.Parent = aimbotScreenGui
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = btn
            
            -- Dragging support
            local dragging = false
            local dragInput, dragStart, startPos
            btn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    dragStart = input.Position
                    startPos = btn.Position
                end
            end)
            btn.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local delta = input.Position - dragStart
                    btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end)
            game:GetService("UserInputService").InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            aimbotConnection = game:GetService("RunService").RenderStepped:Connect(function()
                local player = game:GetService("Players").LocalPlayer
                local char = player.Character
                if char then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("Slash") then
                        btn.Text = "THROW"
                        btn.BackgroundColor3 = Color3.fromRGB(0, 0, 200)
                    else
                        btn.Text = "FIRE"
                        btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
                    end
                end
            end)
            
            btn.MouseButton1Click:Connect(function()
                handleAimbotFire()
            end)
        else
            if aimbotScreenGui then aimbotScreenGui:Destroy() end
            if aimbotConnection then aimbotConnection:Disconnect() end
            aimbotScreenGui = nil
        end
    end
})

getgenv().AimbotKeybindEnabled = false
AimbotSection:Toggle({
    Title = "Enable Aimbot Keybind",
    Description = "Turns the Aimbot Sheriff keybind on or off",
    Default = false,
    Callback = function(state)
        getgenv().AimbotKeybindEnabled = state
    end
})

AimbotSection:Keybind({
    Title = "Aimbot Keybind",
    Description = "Press the key to instantly execute Aimbot",
    Default = "Q",
    Callback = function()
        if getgenv().AimbotKeybindEnabled then
            handleAimbotFire()
        end
    end
})

getgenv().KillWhenVisibleLoop = false
AimbotSection:Toggle({
    Title = "Kill When Visible",
    Description = "Auto kills enemies when visible.",
    Default = false,
    Callback = function(state)
        getgenv().KillWhenVisibleLoop = state
        if state then
            task.spawn(function()
                while getgenv().KillWhenVisibleLoop do
                    task.wait(0.2)
                    if inRestrictedZone() then continue end
                    
                    local visibleTarget = getVisibleAimbotTarget()
                    if visibleTarget then
                        handleAimbotFire(visibleTarget)
                    end
                end
            end)
        end
    end
})

Tabs.Legit:Section({ Title = "Visuals (ESP)" })

getgenv().ESPActive = false
Tabs.Legit:Toggle({
    Title = "Player ESP",
    Description = "Highlights teammates in Green and enemies in Red through walls",
    Default = false,
    Callback = function(state)
        getgenv().ESPActive = state
        if state then
            task.spawn(function()
                while getgenv().ESPActive do
                    task.wait(0.5)
                    local Players = game:GetService("Players")
                    local LocalPlayer = Players.LocalPlayer
                    local charName = LocalPlayer.Name
                    
                    local myTeam = nil
                    local myGameFolder = nil
                    local runningGames = workspace:FindFirstChild("RunningGames")
                    
                    if runningGames then
                        for _, gameFolder in ipairs(runningGames:GetChildren()) do
                            local alivePlayers = gameFolder:FindFirstChild("AlivePlayers")
                            local bodies = gameFolder:FindFirstChild("Bodies")
                            
                            if alivePlayers then
                                local teamRed = alivePlayers:FindFirstChild("TeamRed")
                                local teamBlue = alivePlayers:FindFirstChild("TeamBlue")
                                
                                if teamRed and teamRed:FindFirstChild(charName) then
                                    myTeam = "TeamRed"
                                    myGameFolder = gameFolder
                                    break
                                elseif teamBlue and teamBlue:FindFirstChild(charName) then
                                    myTeam = "TeamBlue"
                                    myGameFolder = gameFolder
                                    break
                                end
                            end
                            if bodies and bodies:FindFirstChild(charName) then
                                myTeam = "Bodies"
                                myGameFolder = gameFolder
                                break
                            end
                        end
                    end
                    
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local playerTeam = nil
                            
                            if myGameFolder then
                                local alivePlayers = myGameFolder:FindFirstChild("AlivePlayers")
                                local bodies = myGameFolder:FindFirstChild("Bodies")
                                
                                if alivePlayers then
                                    local pTeamRed = alivePlayers:FindFirstChild("TeamRed")
                                    local pTeamBlue = alivePlayers:FindFirstChild("TeamBlue")
                                    
                                    if pTeamRed and pTeamRed:FindFirstChild(player.Name) then
                                        playerTeam = "TeamRed"
                                    elseif pTeamBlue and pTeamBlue:FindFirstChild(player.Name) then
                                        playerTeam = "TeamBlue"
                                    end
                                end
                                
                                if bodies and bodies:FindFirstChild(player.Name) then
                                    playerTeam = "Bodies"
                                end
                            end
                            
                            local highlight = player.Character:FindFirstChild("ESP_Highlight")
                            
                            if playerTeam == "Bodies" or not playerTeam then
                                -- Do not highlight players in Bodies or no team or outside our game folder
                                if highlight then highlight:Destroy() end
                            else
                                if not highlight then
                                    highlight = Instance.new("Highlight")
                                    highlight.Name = "ESP_Highlight"
                                    highlight.Parent = player.Character
                                    highlight.FillTransparency = 0.5
                                    highlight.OutlineTransparency = 0.1
                                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                end
                                
                                if myTeam == "Bodies" then
                                    highlight.FillColor = Color3.fromRGB(128, 128, 128)
                                    highlight.OutlineColor = Color3.fromRGB(128, 128, 128)
                                elseif playerTeam == myTeam then
                                    highlight.FillColor = Color3.fromRGB(0, 255, 0)
                                    highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                                else
                                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                                    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                                end
                            end
                        end
                    end
                end
                
                -- Cleanup when toggled off
                for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                    if player.Character then
                        local highlight = player.Character:FindFirstChild("ESP_Highlight")
                        if highlight then highlight:Destroy() end
                    end
                end
            end)
        else
            -- Cleanup immediately when turning off
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player.Character then
                    local highlight = player.Character:FindFirstChild("ESP_Highlight")
                    if highlight then highlight:Destroy() end
                end
            end
        end
    end
})

-- ══════════════════════════════════════════
--              RAGE TAB
-- ══════════════════════════════════════════
Tabs.Rage:Section({ Title = "Kill All 💀" })

Tabs.Rage:Button({
    Title = "Kill All (once)",
    Description = "Kills everyone on the enemy team based on the UI scoreboard",
    Callback = function()
        pcall(function()
            if inRestrictedZone() then return end
            
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            local charName = LocalPlayer.Name
            
            local myTeam = nil
            local myGameFolder = nil
            local runningGames = workspace:FindFirstChild("RunningGames")
            
            if runningGames then
                for _, gameFolder in ipairs(runningGames:GetChildren()) do
                    local alivePlayers = gameFolder:FindFirstChild("AlivePlayers")
                    if alivePlayers then
                        local teamRed = alivePlayers:FindFirstChild("TeamRed")
                        local teamBlue = alivePlayers:FindFirstChild("TeamBlue")
                        
                        if teamRed and teamRed:FindFirstChild(charName) then
                            myTeam = "TeamRed"
                            myGameFolder = gameFolder
                            break
                        elseif teamBlue and teamBlue:FindFirstChild(charName) then
                            myTeam = "TeamBlue"
                            myGameFolder = gameFolder
                            break
                        end
                    end
                end
            end
            
            if myTeam and myGameFolder then
                local alivePlayers = myGameFolder:FindFirstChild("AlivePlayers")
                if alivePlayers then
                    local enemyFolder = nil
                    if myTeam == "TeamRed" then
                        enemyFolder = alivePlayers:FindFirstChild("TeamBlue")
                    elseif myTeam == "TeamBlue" then
                        enemyFolder = alivePlayers:FindFirstChild("TeamRed")
                    end
                    
                    if enemyFolder then
                        local KnifeKillRemote = game:GetService("ReplicatedStorage"):WaitForChild("Packages", 3):WaitForChild("Networking", 3):WaitForChild("RE/Combat/KnifeKill", 3)
                        if KnifeKillRemote then
                            for _, enemyModel in ipairs(enemyFolder:GetChildren()) do
                                local enemyPlr = Players:FindFirstChild(enemyModel.Name)
                                if enemyPlr then
                                    pcall(function()
                                        KnifeKillRemote:FireServer(enemyPlr)
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
})

getgenv().autoKillThreadRunning = false
getgenv().startAutoKillThread = function()
    if getgenv().autoKillThreadRunning then return end
    getgenv().autoKillThreadRunning = true
    task.spawn(function()
        local RunService = game:GetService("RunService")
        local activeEnemyFolder = nil
        
        local KnifeKillRemote = nil
        pcall(function()
            KnifeKillRemote = game:GetService("ReplicatedStorage"):WaitForChild("Packages", 3):WaitForChild("Networking", 3):WaitForChild("RE/Combat/KnifeKill", 3)
        end)
        
        local lastGameFolder = nil
        
        while getgenv().AutoKillFixedLoop or getgenv().AutoFarmLoop or getgenv().AltFarmStreakLoop do
            task.wait(0.1)
            
            if getgenv().AltFarmStreakLoop and getgenv().AltFarmRole == "Victim" then
                activeEnemyFolder = nil
                lastGameFolder = nil
                task.wait(1)
                continue
            end
            
            if inRestrictedZone() then 
                activeEnemyFolder = nil
                lastGameFolder = nil
                continue 
            end
            
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            local charName = LocalPlayer.Name
            
            local myTeam = nil
            local myGameFolder = nil
            local runningGames = workspace:FindFirstChild("RunningGames")
            
            if runningGames then
                for _, gameFolder in ipairs(runningGames:GetChildren()) do
                    local alivePlayers = gameFolder:FindFirstChild("AlivePlayers")
                    local bodies = gameFolder:FindFirstChild("Bodies")
                    
                    if alivePlayers then
                        local teamRed = alivePlayers:FindFirstChild("TeamRed")
                        local teamBlue = alivePlayers:FindFirstChild("TeamBlue")
                        
                        if teamRed and teamRed:FindFirstChild(charName) then
                            myTeam = "TeamRed"
                            myGameFolder = gameFolder
                            break
                        elseif teamBlue and teamBlue:FindFirstChild(charName) then
                            myTeam = "TeamBlue"
                            myGameFolder = gameFolder
                            break
                        end
                    end
                end
            end
            
            if lastGameFolder ~= myGameFolder then
                lastGameFolder = myGameFolder
                activeEnemyFolder = nil
                getgenv().CachedMvsEnemies = {}
                if myGameFolder then
                    task.wait(1)
                    continue
                end
            end
            
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            local timerText = "65"
            local teamBlueScore = 0
            local teamRedScore = 0
            
            if pg and pg:FindFirstChild("Main") then
                local main = pg:FindFirstChild("Main")
                if main:FindFirstChild("MainGameFrame") then
                    local mgf = main:FindFirstChild("MainGameFrame")
                    if mgf:FindFirstChild("IngameScore") then
                        local isc = mgf:FindFirstChild("IngameScore")
                        local timerNode = isc:FindFirstChild("Timer")
                        if timerNode and timerNode:IsA("TextLabel") then
                            timerText = timerNode.Text
                        end
                        
                        local blueScoreNode = isc:FindFirstChild("TeamBlueScore")
                        if blueScoreNode and blueScoreNode:IsA("TextLabel") then
                            teamBlueScore = tonumber(blueScoreNode.Text) or 0
                        end
                        
                        local redScoreNode = isc:FindFirstChild("TeamRedScore")
                        if redScoreNode and redScoreNode:IsA("TextLabel") then
                            teamRedScore = tonumber(redScoreNode.Text) or 0
                        end
                    end
                end
            end
            
            -- If score is 0-0 and timer is 65, do not kill
            if teamBlueScore == 0 and teamRedScore == 0 and timerText == "65" then 
                activeEnemyFolder = nil
                continue 
            end
            

            if myTeam and myGameFolder then
                local alivePlayers = myGameFolder:FindFirstChild("AlivePlayers")
                local enemyFolder = nil
                
                -- Cache enemy players to keep firing at them even if they move into the Bodies folder
                getgenv().CachedMvsEnemies = getgenv().CachedMvsEnemies or {}
                
                if alivePlayers and #getgenv().CachedMvsEnemies == 0 then
                    if myTeam == "TeamRed" then
                        enemyFolder = alivePlayers:FindFirstChild("TeamBlue")
                    elseif myTeam == "TeamBlue" then
                        enemyFolder = alivePlayers:FindFirstChild("TeamRed")
                    end
                    
                    if enemyFolder then
                        for _, enemyModel in ipairs(enemyFolder:GetChildren()) do
                            local enemyPlr = Players:FindFirstChild(enemyModel.Name)
                            if enemyPlr then
                                table.insert(getgenv().CachedMvsEnemies, enemyPlr)
                            end
                        end
                    end
                end
                
                if KnifeKillRemote then
                    for _, enemyPlr in ipairs(getgenv().CachedMvsEnemies) do
                        pcall(function()
                            for i = 1, 10 do
                                KnifeKillRemote:FireServer(enemyPlr)
                            end
                        end)
                    end
                end
            else
                getgenv().CachedMvsEnemies = {}
            end
        end
        getgenv().autoKillThreadRunning = false
    end)
end

getgenv().AutoKillFixedLoop = false
Tabs.Rage:Toggle({
    Title = "Auto Kill All",
    Description = "Spam kills enemies from anywhere (waits for 65s if score is 0-0).",
    Default = false,
    Callback = function(state)
        getgenv().AutoKillFixedLoop = state
        if state then
            if getgenv().startAutoKillThread then getgenv().startAutoKillThread() end
        end
    end
})

-- ══════════════════════════════════════════
--              EVENT TAB
-- ══════════════════════════════════════════
local EventSection = Tabs.Event:Section({
    Title = "Event",
    Box = true,
    BoxBorder = true,
    Opened = false
})

getgenv().autoCollectHatThreadRunning = false
getgenv().startAutoCollectHatThread = function()
    if getgenv().autoCollectHatThreadRunning then return end
    getgenv().autoCollectHatThreadRunning = true
    task.spawn(function()
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Workspace = game:GetService("Workspace")
        local wasInGame = false
        
        while getgenv().AutoCollectHatLoop or getgenv().AutoFarmLoop or getgenv().AltFarmStreakLoop do
            task.wait(1)
            if inRestrictedZone() then continue end
            
            pcall(function()
                local RunningGames = Workspace:FindFirstChild("RunningGames")
                if not RunningGames then return end
                
                local isInAnyGameList = false
                for _, gameFolder in ipairs(RunningGames:GetChildren()) do
                    local AlivePlayers = gameFolder:FindFirstChild("AlivePlayers")
                    local Bodies = gameFolder:FindFirstChild("Bodies")
                    
                    local inBlue = AlivePlayers and AlivePlayers:FindFirstChild("TeamBlue") and AlivePlayers.TeamBlue:FindFirstChild(LocalPlayer.Name)
                    local inRed = AlivePlayers and AlivePlayers:FindFirstChild("TeamRed") and AlivePlayers.TeamRed:FindFirstChild(LocalPlayer.Name)
                    local inBodies = Bodies and Bodies:FindFirstChild(LocalPlayer.Name)
                    
                    if inBlue or inRed or inBodies then
                        isInAnyGameList = true
                        break
                    end
                end
                
                if isInAnyGameList then
                    if not wasInGame then
                        wasInGame = true
                        local remote = ReplicatedStorage:WaitForChild("Packages", 3):WaitForChild("Networking", 3):WaitForChild("RE/Events/CollectEventSpawnable", 3)
                        if remote then
                            for i = 1, 30 do
                                remote:FireServer()
                                task.wait()
                            end
                        end
                    end
                else
                    wasInGame = false
                end
            end)
        end
        getgenv().autoCollectHatThreadRunning = false
    end)
end

getgenv().AutoCollectHatLoop = false
EventSection:Toggle({
    Title = "Auto collect hat",
    Description = "Automatically collects hats until stopped",
    Default = false,
    Callback = function(state)
        getgenv().AutoCollectHatLoop = state
        if state then
            if getgenv().startAutoCollectHatThread then getgenv().startAutoCollectHatThread() end
        end
    end
})

getgenv().SelectedEventCrate = "Void Crate"
EventSection:Dropdown({
    Title = "Select crate",
    Values = {"Void Crate", "Jade Strong Box"},
    Value = "Void Crate",
    Callback = function(Value)
        getgenv().SelectedEventCrate = Value
    end
})

getgenv().AutoBuyEventCrateLoop = false
EventSection:Toggle({
    Title = "Auto buy Event Crate",
    Default = false,
    Callback = function(state)
        getgenv().AutoBuyEventCrateLoop = state
        if state then
            task.spawn(function()
                local LocalPlayer = game:GetService("Players").LocalPlayer
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                
                while getgenv().AutoBuyEventCrateLoop do
                    task.wait(7)
                    
                    pcall(function()
                        local eventCurrencyLabel = LocalPlayer:FindFirstChild("PlayerGui") and 
                                                   LocalPlayer.PlayerGui:FindFirstChild("Main") and 
                                                   LocalPlayer.PlayerGui.Main:FindFirstChild("SideHUD") and 
                                                   LocalPlayer.PlayerGui.Main.SideHUD:FindFirstChild("EventCurrency") and 
                                                   LocalPlayer.PlayerGui.Main.SideHUD.EventCurrency:FindFirstChild("Amount") and 
                                                   LocalPlayer.PlayerGui.Main.SideHUD.EventCurrency.Amount:FindFirstChild("TextLabel")
                        
                        if eventCurrencyLabel then
                            local currencyText = eventCurrencyLabel.Text
                            local currencyAmount = tonumber(string.match(string.gsub(currencyText, ",", ""), "%d+")) or 0
                            
                            local remote = ReplicatedStorage:FindFirstChild("Packages") and 
                                           ReplicatedStorage.Packages:FindFirstChild("Networking") and 
                                           ReplicatedStorage.Packages.Networking:FindFirstChild("RE/Events/PurchaseEventCrate")
                                           
                            if remote then
                                if getgenv().SelectedEventCrate == "Void Crate" then
                                    if currencyAmount >= 12000 then
                                        remote:FireServer("BoxTwo")
                                    end
                                elseif getgenv().SelectedEventCrate == "Jade Strong Box" then
                                    if currencyAmount >= 3500 then
                                        remote:FireServer("BoxOne")
                                    end
                                end
                            end
                        end
                    end)
                end
            end)
        end
    end
})

getgenv().AutoExecuteEnabled = false
Tabs.Settings:Toggle({
    Title = "Auto Execute",
    Description = "Automatically load Prime X Hub when you teleport/server hop",
    Default = false,
    Callback = function(state)
        getgenv().AutoExecuteEnabled = state
        if state then
            local queue = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport) or (request and request.queue_on_teleport)
            if queue then
                pcall(function()
                    queue([[loadstring(game:HttpGet("https://raw.githubusercontent.com/wendigothe48-maker/directx/main/mvs.lua"))()]])
                end)
            else
                -- print("[Auto Execute] Your executor does not support queue_on_teleport.")
            end
        end
    end
})

-- ══════════════════════════════════════════
--              LOAD OTHERS.LUA
-- ══════════════════════════════════════════
-- Set a unified Place ID for configurations (Shared across all MVS GameModes)
getgenv().PXHConfig_PlaceId = "135856908115931"

local ok, OthersFunc = pcall(function()
    local othersCode = game:HttpGet("https://raw.githubusercontent.com/wendigo5414-cmyk/FireballxArena/main/Others.lua", true)
    -- Inject the unified Place ID so configs load correctly on teleport
    othersCode = string.gsub(othersCode, "tostring%(game%.PlaceId%)", "(getgenv().PXHConfig_PlaceId or tostring(game.PlaceId))")
    return loadstring(othersCode)()
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
