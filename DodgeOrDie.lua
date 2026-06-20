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

-- ══════════════════════════════════════════
--              MAIN FEATURES
-- ══════════════════════════════════════════
local LocalPlayer = game:GetService("Players").LocalPlayer

local removeBalls = false
Tabs.Main:Toggle({
    Title = "Remove Balls",
    Value = false,
    Callback = function(Value)
        removeBalls = Value
        if Value then
            task.spawn(function()
                while removeBalls do
                    pcall(function()
                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local ballsFolder = workspace:FindFirstChild("Balls")
                            if ballsFolder then
                                for _, child in ipairs(ballsFolder:GetDescendants()) do
                                    if child:IsA("BasePart") then
                                        local distance = (child.Position - hrp.Position).Magnitude
                                        if distance <= 20 then
                                            child:Destroy()
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.05)
                end
            end)
        end
    end
})

local stuckBallsAura = false

local auraData = {
    folder = nil,
    staticOuter = {},
    staticInner = nil,
    expanding = nil
}

local function createBoxParts(folder)
    local parts = {}
    for i = 1, 4 do
        local part = Instance.new("Part")
        part.Anchored = true
        part.CanCollide = true
        part.Transparency = 1
        part.CastShadow = false
        part.Parent = folder
        table.insert(parts, part)
    end
    return parts
end

local function setupAura()
    if auraData.folder then return end
    auraData.folder = Instance.new("Folder")
    auraData.folder.Name = "StuckBallsAuraFolder"
    auraData.folder.Parent = workspace
    
    auraData.staticOuter = {}
    for _, d in ipairs({15, 17, 18}) do
        table.insert(auraData.staticOuter, { parts = createBoxParts(auraData.folder), distance = d })
    end
    
    auraData.staticInner = { parts = createBoxParts(auraData.folder), distance = 3 }
    auraData.expanding = { parts = createBoxParts(auraData.folder), distance = 3 }
end

local function cleanupAura()
    if auraData.folder then
        auraData.folder:Destroy()
        auraData.folder = nil
    end
    auraData.staticOuter = {}
    auraData.staticInner = nil
    auraData.expanding = nil
end

local function updateBox(partsList, cframe, d)
    partsList[1].Size = Vector3.new(d*2 + 2, 50, 2)
    partsList[1].CFrame = cframe * CFrame.new(0, 0, -d)
    
    partsList[2].Size = Vector3.new(d*2 + 2, 50, 2)
    partsList[2].CFrame = cframe * CFrame.new(0, 0, d)
    
    partsList[3].Size = Vector3.new(2, 50, d*2 + 2)
    partsList[3].CFrame = cframe * CFrame.new(-d, 0, 0)
    
    partsList[4].Size = Vector3.new(2, 50, d*2 + 2)
    partsList[4].CFrame = cframe * CFrame.new(d, 0, 0)
end

Tabs.Main:Toggle({
    Title = "Stuck Balls Aura",
    Value = false,
    Callback = function(Value)
        stuckBallsAura = Value
        if Value then
            task.spawn(function()
                local isExpanding = false
                local expandProgress = 0
                local expandDuration = 2
                
                while stuckBallsAura do
                    pcall(function()
                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local ballNear = false
                            local ballsFolder = workspace:FindFirstChild("Balls")
                            if ballsFolder then
                                for _, child in ipairs(ballsFolder:GetDescendants()) do
                                    if child:IsA("BasePart") then
                                        local distance = (child.Position - hrp.Position).Magnitude
                                        if distance <= 20 then
                                            ballNear = true
                                            break
                                        end
                                    end
                                end
                            end
                            
                            if ballNear then
                                setupAura()
                                
                                if not isExpanding then
                                    isExpanding = true
                                    expandProgress = 0
                                end
                                
                                local dt = 0.01
                                expandProgress = expandProgress + dt
                                local currentExpandDist = 3 + ((20 - 3) * (expandProgress / expandDuration))
                                
                                if expandProgress >= expandDuration then
                                    isExpanding = false
                                end
                                
                                local cf = hrp.CFrame
                                
                                for _, box in ipairs(auraData.staticOuter) do
                                    updateBox(box.parts, cf, box.distance)
                                end
                                
                                updateBox(auraData.staticInner.parts, cf, auraData.staticInner.distance)
                                updateBox(auraData.expanding.parts, cf, currentExpandDist)
                            else
                                cleanupAura()
                                isExpanding = false
                            end
                        else
                            cleanupAura()
                            isExpanding = false
                        end
                    end)
                    task.wait(0.01)
                end
                cleanupAura()
            end)
        else
            cleanupAura()
        end
    end
})

local infinityAura = false
Tabs.Main:Toggle({
    Title = "Infinity Aura",
    Value = false,
    Callback = function(Value)
        infinityAura = Value
        if Value then
            task.spawn(function()
                local lockedBalls = {}
                while infinityAura do
                    pcall(function()
                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local ballsFolder = workspace:FindFirstChild("Balls")
                            if ballsFolder then
                                -- Cleanup deleted balls
                                for ball, _ in pairs(lockedBalls) do
                                    if not ball or not ball.Parent then
                                        lockedBalls[ball] = nil
                                    end
                                end
                                
                                for _, child in ipairs(ballsFolder:GetDescendants()) do
                                    if child:IsA("BasePart") then
                                        local distance = (child.Position - hrp.Position).Magnitude
                                        
                                        if distance < 15 then
                                            -- Instantly TP outside of the 15 stud range
                                            local dir = (child.Position - hrp.Position).Unit
                                            if dir.X ~= dir.X then -- NaN check if exactly same position
                                                dir = Vector3.new(1, 0, 0)
                                            end
                                            
                                            local newTargetPos = hrp.Position + (dir * 15.5)
                                            child.CFrame = CFrame.new(newTargetPos)
                                            child.AssemblyLinearVelocity = Vector3.zero
                                            child.AssemblyAngularVelocity = Vector3.zero
                                            
                                            lockedBalls[child] = child.CFrame
                                        elseif distance >= 15 and distance <= 20 then
                                            -- Stuck Range
                                            if not lockedBalls[child] then
                                                lockedBalls[child] = child.CFrame
                                            end
                                            child.CFrame = lockedBalls[child]
                                            child.AssemblyLinearVelocity = Vector3.zero
                                            child.AssemblyAngularVelocity = Vector3.zero
                                        elseif distance > 20 then
                                            -- Free the ball
                                            if lockedBalls[child] then
                                                lockedBalls[child] = nil
                                            end
                                        end
                                    end
                                end
                            end
                        else
                            table.clear(lockedBalls)
                        end
                    end)
                    -- Run frequent to keep them fully stuck and out of range
                    task.wait()
                end
            end)
        end
    end
})

WindUI:Notify({
    Title = "Prime X Hub",
    Content = "Script loaded successfully!",
    Duration = 5
})
