-- fluent code converted to wind ui
-- [[ KEY SYSTEM LOADER ]] --
local KeySystem = loadstring(game:HttpGet("https://raw.githubusercontent.com/wendigo5414-cmyk/scripts/refs/heads/main/keysystem.lua"))()
KeySystem.Init()

-- [[ GAME SCRIPT START ]] --
local cloneref = (cloneref or clonereference or function(instance) return instance end)
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local Workspace = cloneref(game:GetService("Workspace"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local GuiService = cloneref(game:GetService("GuiService"))

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ══════════════════════════════════════════
--              WIND UI SETUP
-- ══════════════════════════════════════════
local WindUI
local ok, result = pcall(function()
    return require("./src/Init")
end)

if ok then
    WindUI = result
else 
    if RunService:IsStudio() then
        WindUI = require(cloneref(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init")))
    else
        local windUI_Source = game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua")
        windUI_Source = windUI_Source:gsub("([%w_]+)%.UserInputType%s*==%s*Enum%.UserInputType%.MouseButton1", "(%1.UserInputType == Enum.UserInputType.MouseButton1 or %1.UserInputType == Enum.UserInputType.Touch)")
        windUI_Source = windUI_Source:gsub("([%w_]+)%.UserInputType%s*==%s*Enum%.UserInputType%.MouseMovement", "(%1.UserInputType == Enum.UserInputType.MouseMovement or %1.UserInputType == Enum.UserInputType.Touch)")
        WindUI = loadstring(windUI_Source)()
    end
end

local gameName = "Blox Strike"
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
    Aimbot   = Window:Tab({ Title = "Aimbot", Icon = "solar:target-bold" }),
    ESP      = Window:Tab({ Title = "ESP", Icon = "solar:eye-bold" }),
    Movement = Window:Tab({ Title = "Movement", Icon = "solar:running-bold" }),
    Teleport = Window:Tab({ Title = "Teleport", Icon = "solar:map-point-bold" }),
    Settings = Window:Tab({ Title = "Settings", Icon = "solar:settings-bold" }),
    AboutUs  = Window:Tab({ Title = "About Us", Icon = "solar:info-circle-bold" })
}

-- ══════════════════════════════════════════
--              LOAD OTHERS.LUA
-- ══════════════════════════════════════════
local okOthers, OthersFunc = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/wendigo5414-cmyk/FireballxArena/main/Others.lua", true))()
end)

if okOthers and type(OthersFunc) == "function" then
    OthersFunc(Window, Tabs, WindUI)
end

local hasDrawing = (type(Drawing) == "table" and type(Drawing.new) == "function")

-- ══════════════════════════════════════════
--       TEAM DETECTION SYSTEM (UI BASED)
-- ══════════════════════════════════════════
local CachedTeams = {}
local LastTeamScan = 0

local function ScanTeamsFromUI()
    local currentTime = tick()
    if currentTime - LastTeamScan < 0.5 and next(CachedTeams) ~= nil then
        return CachedTeams
    end
    LastTeamScan = currentTime

    local teamMap = {}
    pcall(function()
        local lp = Players.LocalPlayer
        if not lp then return end
        local playerGui = lp:FindFirstChild("PlayerGui")
        if not playerGui then return end
        local mainGui = playerGui:FindFirstChild("MainGui")
        if not mainGui then return end
        local gameplay = mainGui:FindFirstChild("Gameplay")
        if not gameplay then return end
        local middle = gameplay:FindFirstChild("Middle")
        if not middle then return end
        local teamSelection = middle:FindFirstChild("TeamSelection")
        if not teamSelection then return end

        -- 🔴 Terrorists
        local terrorists = teamSelection:FindFirstChild("Terrorists")
        if terrorists and terrorists:FindFirstChild("Container") then
            for _, item in ipairs(terrorists.Container:GetChildren()) do
                if not item:IsA("UIComponent") then
                    local teamLabel = item:FindFirstChild("Team")
                    if teamLabel and teamLabel:IsA("TextLabel") and teamLabel.Text ~= "" then
                        teamMap[string.lower(teamLabel.Text)] = "Terrorists"
                    end
                end
            end
        end

        -- 🔵 Counter-Terrorists
        local counterTerrorists = teamSelection:FindFirstChild("Counter-Terrorists")
        if counterTerrorists and counterTerrorists:FindFirstChild("Container") then
            for _, item in ipairs(counterTerrorists.Container:GetChildren()) do
                if not item:IsA("UIComponent") then
                    local teamLabel = item:FindFirstChild("Team")
                    if teamLabel and teamLabel:IsA("TextLabel") and teamLabel.Text ~= "" then
                        teamMap[string.lower(teamLabel.Text)] = "Counter-Terrorists"
                    end
                end
            end
        end
    end)

    if next(teamMap) ~= nil then
        CachedTeams = teamMap
    end
    return CachedTeams
end

local function GetPlayerTeam(player)
    if not player then return "Unknown" end
    local teamMap = ScanTeamsFromUI()
    
    local nameKey = string.lower(player.Name)
    local displayKey = string.lower(player.DisplayName)
    
    if teamMap[nameKey] then return teamMap[nameKey] end
    if teamMap[displayKey] then return teamMap[displayKey] end
    
    if player.Team and player.Team.Name ~= "" then
        return player.Team.Name
    end
    return "Unknown"
end

local function IsPlayerEnemy(player)
    if not player or player == LocalPlayer then return false end
    local lpTeam = GetPlayerTeam(LocalPlayer)
    local targetTeam = GetPlayerTeam(player)
    
    if lpTeam ~= "Unknown" and targetTeam ~= "Unknown" then
        return lpTeam ~= targetTeam
    end
    
    if LocalPlayer.Team and player.Team then
        return LocalPlayer.Team ~= player.Team
    end
    
    return true
end

-- ══════════════════════════════════════════
--      DYNAMIC CHARACTER & PART LOCATOR
-- ══════════════════════════════════════════
local function GetCharacterParts(player)
    local char = player.Character
    if not char then return nil, nil, nil, nil end

    local root = char:FindFirstChild("HumanoidRootPart") 
        or char:FindFirstChild("RootPart")
        or char:FindFirstChild("Torso")
        or char:FindFirstChild("UpperTorso")
        or char:FindFirstChild("Hitbox")
        or char:FindFirstChild("Main")
        or char.PrimaryPart

    if not root then
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("BasePart") and child.Name ~= "Head" then
                root = child
                break
            end
        end
    end

    local head = char:FindFirstChild("Head") 
        or char:FindFirstChild("HeadHB")
        or char:FindFirstChild("HeadHitbox")

    local humanoid = char:FindFirstChildOfClass("Humanoid")

    return char, root, head, humanoid
end

local function IsPlayerAlive(player)
    if not player then return false end
    local char, root, head, humanoid = GetCharacterParts(player)
    if not char or not root then return false end
    if humanoid then
        return humanoid.Health > 0
    end
    return char.Parent ~= nil
end

-- Format distance (e.g. 25M, 150M, 1.2KM)
local function FormatDistance(studs)
    local meters = math.floor(studs * 0.28)
    if meters >= 1000 then
        return string.format("%.1fKM", meters / 1000)
    end
    return tostring(meters) .. "M"
end

-- ══════════════════════════════════════════
--             ESP ENGINE & STATE
-- ══════════════════════════════════════════
_G.ESP_TeamFilter = "Both Teams"
_G.ESP_PlayerGlow = false
_G.ESP_Tracers = false
_G.ESP_Box = false
_G.ESP_Distance = false

local ESP_Cache = {}
local EnemyColor = Color3.fromRGB(255, 45, 45)
local FriendlyColor = Color3.fromRGB(45, 255, 45)

local function CleanupPlayerESP(player)
    local data = ESP_Cache[player]
    if data then
        if data.Highlight and data.Highlight.Parent then
            pcall(function() data.Highlight:Destroy() end)
        end
        if data.Tracer then
            pcall(function() 
                data.Tracer.Visible = false
                data.Tracer:Remove() 
            end)
        end
        if data.Box then
            pcall(function() 
                data.Box.Visible = false
                data.Box:Remove() 
            end)
        end
        if data.DistanceText then
            pcall(function() 
                data.DistanceText.Visible = false
                data.DistanceText:Remove() 
            end)
        end
        ESP_Cache[player] = nil
    end
end

local function HidePlayerESP(esp)
    if not esp then return end
    if esp.Highlight then esp.Highlight.Enabled = false end
    if esp.Tracer then esp.Tracer.Visible = false end
    if esp.Box then esp.Box.Visible = false end
    if esp.DistanceText then esp.DistanceText.Visible = false end
end

local function CleanupAllESP()
    for player, esp in pairs(ESP_Cache) do
        HidePlayerESP(esp)
    end
end

Players.PlayerRemoving:Connect(CleanupPlayerESP)

local function GetOrCreateESP(player)
    if not ESP_Cache[player] then
        local highlight = nil
        pcall(function()
            highlight = Instance.new("Highlight")
            highlight.Name = "PXH_ESP_" .. player.Name
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Enabled = false
            highlight.Parent = CoreGui
        end)
        if not highlight or not highlight.Parent then
            pcall(function()
                highlight = Instance.new("Highlight")
                highlight.Name = "PXH_ESP_" .. player.Name
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Enabled = false
                highlight.Parent = LocalPlayer:WaitForChild("PlayerGui")
            end)
        end

        local tracer = nil
        if hasDrawing then
            pcall(function()
                tracer = Drawing.new("Line")
                tracer.Visible = false
                tracer.Thickness = 1.5
                tracer.Transparency = 1
            end)
        end

        local box = nil
        if hasDrawing then
            pcall(function()
                box = Drawing.new("Square")
                box.Visible = false
                box.Thickness = 1.5
                box.Filled = false
                box.Transparency = 1
            end)
        end

        local distanceText = nil
        if hasDrawing then
            pcall(function()
                distanceText = Drawing.new("Text")
                distanceText.Visible = false
                distanceText.Size = 22 -- 1.7x size
                distanceText.Center = true
                distanceText.Outline = true
                distanceText.OutlineColor = Color3.fromRGB(0, 0, 0)
                distanceText.Color = Color3.fromRGB(255, 255, 255)
                distanceText.Font = 2
            end)
        end

        ESP_Cache[player] = {
            Highlight = highlight,
            Tracer = tracer,
            Box = box,
            DistanceText = distanceText
        }
    end
    return ESP_Cache[player]
end

-- ══════════════════════════════════════════
--             AIMBOT ENGINE
-- ══════════════════════════════════════════
_G.Aimbot_Enabled = false
_G.Aimbot_WallCheck = false
_G.Aimbot_Range = 500 -- In meters
_G.Aimbot_FOV = 90
_G.Aimbot_DrawFOV = true

local FOVCircle = nil
if hasDrawing then
    pcall(function()
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Visible = false
        FOVCircle.Thickness = 1.2
        FOVCircle.Color = Color3.fromRGB(255, 170, 80)
        FOVCircle.Transparency = 0.8
        FOVCircle.NumSides = 64
        FOVCircle.Filled = false
    end)
end

local function GetCrosshairScreenPoint()
    Camera = Workspace.CurrentCamera
    local viewportSize = Camera and Camera.ViewportSize or Vector2.new(800, 600)
    local fallbackCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)

    local dotPos = nil
    pcall(function()
        local lp = Players.LocalPlayer
        if not lp then return end
        local pGui = lp:FindFirstChild("PlayerGui")
        if not pGui then return end
        local mainGui = pGui:FindFirstChild("MainGui")
        if not mainGui then return end
        local gameplay = mainGui:FindFirstChild("Gameplay")
        if not gameplay then return end
        local middle = gameplay:FindFirstChild("Middle")
        if not middle then return end
        local crosshair = middle:FindFirstChild("Crosshair")
        if not crosshair then return end
        local dot = crosshair:FindFirstChild("Dot")
        if dot and dot.Visible then
            local absPos = dot.AbsolutePosition
            local absSize = dot.AbsoluteSize
            local inset = GuiService:GetGuiInset()
            dotPos = Vector2.new(absPos.X + (absSize.X / 2), absPos.Y + (absSize.Y / 2) + inset.Y)
        end
    end)

    return dotPos or fallbackCenter
end

local function IsVisibleRaycast(originPos, targetPos, targetChar)
    local direction = (targetPos - originPos)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local ignoreList = { LocalPlayer.Character, Camera }
    if targetChar then
        table.insert(ignoreList, targetChar)
    end
    raycastParams.FilterDescendantsInstances = ignoreList
    raycastParams.IgnoreWater = true

    local result = Workspace:Raycast(originPos, direction, raycastParams)
    return result == nil
end

local function GetBestAimbotTarget(crosshairScreenPos)
    Camera = Workspace.CurrentCamera
    if not Camera then return nil, nil end

    local bestTarget = nil
    local bestTargetPart = nil
    local shortestFovDist = math.huge

    local maxRangeStuds = _G.Aimbot_Range / 0.28

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsPlayerAlive(player) and IsPlayerEnemy(player) then
            local char, root, head, humanoid = GetCharacterParts(player)
            local aimPart = head or root
            
            if char and aimPart then
                local distStuds = (Camera.CFrame.Position - aimPart.Position).Magnitude
                if distStuds <= maxRangeStuds then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
                    
                    if onScreen then
                        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - crosshairScreenPos).Magnitude
                        
                        if screenDist <= _G.Aimbot_FOV then
                            local isVisible = true
                            if _G.Aimbot_WallCheck then
                                isVisible = IsVisibleRaycast(Camera.CFrame.Position, aimPart.Position, char)
                            end

                            if isVisible and screenDist < shortestFovDist then
                                shortestFovDist = screenDist
                                bestTarget = player
                                bestTargetPart = aimPart
                            end
                        end
                    end
                end
            end
        end
    end

    return bestTarget, bestTargetPart
end

-- ══════════════════════════════════════════
--             RENDER STEPPED LOOP
-- ══════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    Camera = Workspace.CurrentCamera
    if not Camera then return end
    
    local viewportSize = Camera.ViewportSize
    local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    local screenBottom = Vector2.new(viewportSize.X / 2, viewportSize.Y)
    local crosshairPoint = GetCrosshairScreenPoint()

    -- ──────────────────────────────────────────
    -- 1. AIMBOT RUNTIME & FOV CIRCLE
    -- ──────────────────────────────────────────
    local isSelfAlive = IsPlayerAlive(LocalPlayer)
    
    if FOVCircle then
        if _G.Aimbot_Enabled and _G.Aimbot_DrawFOV and isSelfAlive then
            FOVCircle.Position = crosshairPoint
            FOVCircle.Radius = _G.Aimbot_FOV
            FOVCircle.Visible = true
        else
            FOVCircle.Visible = false
        end
    end

    if _G.Aimbot_Enabled and isSelfAlive then
        local targetPlayer, targetPart = GetBestAimbotTarget(crosshairPoint)
        if targetPlayer and targetPart then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
        end
    end

    -- ──────────────────────────────────────────
    -- 2. ESP RUNTIME (OFFSCREEN TRACER & DEAD CLEANUP)
    -- ──────────────────────────────────────────
    local anyEspActive = _G.ESP_PlayerGlow or _G.ESP_Tracers or _G.ESP_Box or _G.ESP_Distance

    -- If Self is DEAD or no ESP enabled, hide all ESP immediately
    if not isSelfAlive or not anyEspActive or _G.ESP_TeamFilter == "None" then
        for _, esp in pairs(ESP_Cache) do
            HidePlayerESP(esp)
        end
        return
    end

    -- Set of active players in server for safe garbage cleanup
    local activePlayers = {}

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            activePlayers[player] = true
            local esp = GetOrCreateESP(player)
            local char, root, head, humanoid = GetCharacterParts(player)
            local targetAlive = IsPlayerAlive(player)

            -- If Target is DEAD or no character: hide all drawing/text immediately
            if not targetAlive or not char or not root then
                HidePlayerESP(esp)
            else
                local isEnemy = IsPlayerEnemy(player)
                
                local shouldShow = false
                if _G.ESP_TeamFilter == "Both Teams" then
                    shouldShow = true
                elseif _G.ESP_TeamFilter == "Opponent Team" and isEnemy then
                    shouldShow = true
                elseif _G.ESP_TeamFilter == "Your Team" and not isEnemy then
                    shouldShow = true
                end

                local targetColor = isEnemy and EnemyColor or FriendlyColor

                if shouldShow then
                    local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    local distStuds = (Camera.CFrame.Position - root.Position).Magnitude
                    local distTextFormatted = FormatDistance(distStuds)

                    -- 1. Player Glow (Highlight ESP)
                    if _G.ESP_PlayerGlow and esp.Highlight then
                        esp.Highlight.Adornee = char
                        esp.Highlight.FillColor = targetColor
                        esp.Highlight.OutlineColor = targetColor
                        esp.Highlight.Enabled = true
                    elseif esp.Highlight then
                        esp.Highlight.Enabled = false
                    end

                    -- 2. Tracer ESP (With 360° Behind Indicator Support)
                    if _G.ESP_Tracers and esp.Tracer then
                        if onScreen then
                            esp.Tracer.From = screenBottom
                            esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                            esp.Tracer.Color = targetColor
                            esp.Tracer.Visible = true
                        else
                            local toTarget = (root.Position - Camera.CFrame.Position).Unit
                            local camRight = Camera.CFrame.RightVector
                            local camUp = Camera.CFrame.UpVector
                            local camForward = Camera.CFrame.LookVector

                            local dotRight = toTarget:Dot(camRight)
                            local dotUp = toTarget:Dot(camUp)
                            local dotForward = toTarget:Dot(camForward)

                            local dirX = dotRight
                            local dirY = -dotUp
                            if dotForward < 0 then
                                dirX = -dirX
                                dirY = -dirY
                            end

                            local angle = math.atan2(dirY, dirX)
                            local radiusX = (viewportSize.X / 2) - 25
                            local radiusY = (viewportSize.Y / 2) - 25
                            
                            local edgeX = screenCenter.X + math.cos(angle) * radiusX
                            local edgeY = screenCenter.Y + math.sin(angle) * radiusY

                            esp.Tracer.From = screenBottom
                            esp.Tracer.To = Vector2.new(edgeX, edgeY)
                            esp.Tracer.Color = targetColor
                            esp.Tracer.Visible = true
                        end
                    elseif esp.Tracer then
                        esp.Tracer.Visible = false
                    end

                    -- 3. Box ESP (2D Square)
                    local boxScreenX = rootPos.X
                    local boxScreenY = rootPos.Y

                    if _G.ESP_Box and esp.Box then
                        if onScreen then
                            local headPos = head and head.Position or (root.Position + Vector3.new(0, 2, 0))
                            local headScreen = Camera:WorldToViewportPoint(headPos + Vector3.new(0, 0.5, 0))
                            local legScreen = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))

                            local boxHeight = math.abs(headScreen.Y - legScreen.Y)
                            local boxWidth = boxHeight * 0.65

                            boxScreenX = rootPos.X - (boxWidth / 2)
                            boxScreenY = headScreen.Y

                            esp.Box.Size = Vector2.new(boxWidth, boxHeight)
                            esp.Box.Position = Vector2.new(boxScreenX, boxScreenY)
                            esp.Box.Color = targetColor
                            esp.Box.Visible = true
                        else
                            esp.Box.Visible = false
                        end
                    elseif esp.Box then
                        esp.Box.Visible = false
                    end

                    -- 4. Distance ESP (Positioned above Box, Pure White with Black Outline)
                    if _G.ESP_Distance and esp.DistanceText then
                        if onScreen then
                            local textPosY = boxScreenY - 24
                            if not _G.ESP_Box then
                                textPosY = rootPos.Y - 26
                            end
                            esp.DistanceText.Position = Vector2.new(rootPos.X, textPosY)
                            esp.DistanceText.Text = distTextFormatted
                            esp.DistanceText.Color = Color3.fromRGB(255, 255, 255)
                            esp.DistanceText.Outline = true
                            esp.DistanceText.OutlineColor = Color3.fromRGB(0, 0, 0)
                            esp.DistanceText.Visible = true
                        else
                            esp.DistanceText.Visible = false
                        end
                    elseif esp.DistanceText then
                        esp.DistanceText.Visible = false
                    end
                else
                    HidePlayerESP(esp)
                end
            end
        end
    end

    -- Clean up any cached ESP for players that no longer exist
    for p, _ in pairs(ESP_Cache) do
        if not activePlayers[p] then
            CleanupPlayerESP(p)
        end
    end
end)

-- ══════════════════════════════════════════
--              BUILD AIMBOT TAB UI
-- ══════════════════════════════════════════
local AimbotSection = Tabs.Aimbot:Section({
    Title = "Aimbot Settings",
    Box = true,
    BoxBorder = true,
    Expandable = true,
    Opened = true
})

AimbotSection:Toggle({
    Title = "Aimbot",
    Description = "Instant 100% lock onto enemies using dynamic crosshair",
    Value = false,
    Callback = function(Value)
        _G.Aimbot_Enabled = Value
    end
})

AimbotSection:Toggle({
    Title = "Wall Check",
    Description = "Only lock onto enemies visible on screen (not behind walls)",
    Value = false,
    Callback = function(Value)
        _G.Aimbot_WallCheck = Value
    end
})

AimbotSection:Toggle({
    Title = "Draw FOV Circle",
    Description = "Visualizes Aimbot FOV area around crosshair",
    Value = true,
    Callback = function(Value)
        _G.Aimbot_DrawFOV = Value
    end
})

AimbotSection:Slider({
    Title = "Aimbot Range",
    Description = "Maximum target distance in meters (1M to 1000M)",
    Step = 5,
    Value = {
        Min = 1,
        Max = 1000,
        Default = 500,
    },
    Callback = function(Value)
        _G.Aimbot_Range = Value
    end
})

AimbotSection:Slider({
    Title = "Aimbot FOV",
    Description = "Field of view angle/radius for target acquisition",
    Step = 1,
    Value = {
        Min = 30,
        Max = 360,
        Default = 90,
    },
    Callback = function(Value)
        _G.Aimbot_FOV = Value
    end
})

-- ══════════════════════════════════════════
--              BUILD ESP TAB UI
-- ══════════════════════════════════════════
local ESPSection = Tabs.ESP:Section({
    Title = "Visuals & ESP",
    Box = true,
    BoxBorder = true,
    Expandable = true,
    Opened = true
})

ESPSection:Dropdown({
    Title = "ESP Team Target",
    Description = "Select target team for ESP (Enemy: Red, Friendly: Green)",
    Values = {"Both Teams", "Opponent Team", "Your Team", "None"},
    Value = "Both Teams",
    Callback = function(Value)
        _G.ESP_TeamFilter = Value
    end
})

ESPSection:Toggle({
    Title = "Player ESP (Glow)",
    Description = "Glow highlight through walls (Enemy: Red, Your Team: Green)",
    Value = false,
    Callback = function(Value)
        _G.ESP_PlayerGlow = Value
        if not Value then
            for _, data in pairs(ESP_Cache) do
                if data.Highlight then data.Highlight.Enabled = false end
            end
        end
    end
})

ESPSection:Toggle({
    Title = "Tracer ESP",
    Description = "Draws 2D lines with 360° off-screen indicator support",
    Value = false,
    Callback = function(Value)
        _G.ESP_Tracers = Value
        if not Value then
            for _, data in pairs(ESP_Cache) do
                if data.Tracer then data.Tracer.Visible = false end
            end
        end
    end
})

ESPSection:Toggle({
    Title = "Box ESP",
    Description = "Draws 2D bounding boxes around players",
    Value = false,
    Callback = function(Value)
        _G.ESP_Box = Value
        if not Value then
            for _, data in pairs(ESP_Cache) do
                if data.Box then data.Box.Visible = false end
            end
        end
    end
})

ESPSection:Toggle({
    Title = "Distance ESP",
    Description = "Displays distance text in white above box (e.g. 25M, 150M, 1.2KM)",
    Value = false,
    Callback = function(Value)
        _G.ESP_Distance = Value
        if not Value then
            for _, data in pairs(ESP_Cache) do
                if data.DistanceText then data.DistanceText.Visible = false end
            end
        end
    end
})

WindUI:Notify({
    Title = "Prime X Hub",
    Content = "Blox Strike Script & Aimbot loaded successfully!",
    Duration = 5
})
