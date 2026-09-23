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
    Farming  = Window:Tab({ Title = "Farming", Icon = "solar:leaf-bold" }),
    AutoBuy  = Window:Tab({ Title = "Auto Buy", Icon = "solar:cart-large-4-bold" }),
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

local Players = cloneref(game:GetService("Players"))
local LocalPlayer = Players.LocalPlayer
local CoreGui = cloneref(game:GetService("CoreGui"))

-- Silent Logger (No On-Screen Console)
local Logger = {}
function Logger:Log(...) end

local executorName = identifyexecutor and ({identifyexecutor()})[1] or "Unknown"

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

-- ══════════════════════════════════════════
--          NUMBER / LUCK PARSER
-- ══════════════════════════════════════════
local function parseLuck(raw)
    if not raw then return 0 end
    if type(raw) == "number" then return raw end
    
    -- 1. Try Others.lua NumberConverter
    if NumberConverter and type(NumberConverter.Parse) == "function" then
        local res = NumberConverter.Parse(raw)
        if res and res > 0 then return res end
    end
    
    -- 2. Robust CleanAndParse Fallback
    local cleanText = string.gsub(tostring(raw), "<[^>]+>", "")
    cleanText = string.gsub(cleanText, ",", "")
    cleanText = string.gsub(cleanText, "%+", "")
    cleanText = string.gsub(cleanText, "LUCK", "")
    cleanText = string.gsub(cleanText, "x", "")
    cleanText = string.gsub(cleanText, "X", "")
    
    local numStr, suffix = string.match(string.lower(cleanText), "([%d%.]+)%s*([a-z]*)")
    if not numStr then return 0 end
    local num = tonumber(numStr) or 0
    local mult = 1
    
    if suffix == "k" then mult = 1e3
    elseif suffix == "m" then mult = 1e6
    elseif suffix == "b" then mult = 1e9
    elseif suffix == "t" then mult = 1e12
    elseif suffix == "qa" then mult = 1e15
    elseif suffix == "qi" then mult = 1e18
    elseif suffix == "sx" then mult = 1e21
    elseif suffix == "sp" then mult = 1e24
    elseif suffix == "oc" then mult = 1e27
    elseif suffix == "no" then mult = 1e30
    end
    
    return num * mult
end

-- ══════════════════════════════════════════
--          SELF PLOT DETECTION
-- ══════════════════════════════════════════
local function getSelfPlot()
    local plotsFolder = workspace:FindFirstChild("Plots")
    if not plotsFolder then return nil end
    local myName = LocalPlayer.Name
    local myUserId = tostring(LocalPlayer.UserId)
    
    for _, plot in ipairs(plotsFolder:GetChildren()) do
        local data = plot:FindFirstChild("Data")
        local ownerObj = (data and data:FindFirstChild("Owner")) or plot:FindFirstChild("Owner")
        
        if ownerObj then
            local val = nil
            if ownerObj:IsA("ValueBase") then
                val = ownerObj.Value
            end
            if val ~= nil then
                if tostring(val) == myName or val == LocalPlayer or tostring(val) == myUserId then
                    return plot
                end
            end
        end
        
        -- Attribute fallback
        local ownerAttr = (data and data:GetAttribute("Owner")) or plot:GetAttribute("Owner")
        if ownerAttr and (tostring(ownerAttr) == myName or tostring(ownerAttr) == myUserId) then
            return plot
        end
    end
    
    return nil
end

local function getSelfPlotCFrame()
    local plot = getSelfPlot()
    if not plot then return nil end
    
    -- Check for designated landing spot or base
    local landing = plot:FindFirstChild("Spawn") 
        or plot:FindFirstChild("SpawnPoint") 
        or plot:FindFirstChild("Base") 
        or plot:FindFirstChild("Center") 
        or plot:FindFirstChild("Floor")
        
    if landing and landing:IsA("BasePart") then
        return landing.CFrame + Vector3.new(0, 3.5, 0)
    end
    
    if plot:IsA("Model") then
        return plot:GetPivot() + Vector3.new(0, 3.5, 0)
    elseif plot:IsA("BasePart") then
        return plot.CFrame + Vector3.new(0, 3.5, 0)
    end
    
    return nil
end

-- ══════════════════════════════════════════
--          EGG HELPERS & PICKUP
-- ══════════════════════════════════════════
local function getEggLuck(egg)
    if not egg then return 0 end
    
    -- Target: workspace.RenderedEggs[...].Handle.EggLuck.Luck
    local luckObj = nil
    local handle = egg:FindFirstChild("Handle")
    if handle then
        local eggLuck = handle:FindFirstChild("EggLuck")
        if eggLuck then
            luckObj = eggLuck:FindFirstChild("Luck") or eggLuck
        end
    end
    
    -- Fallback search inside egg
    if not luckObj then
        local eggLuck = egg:FindFirstChild("EggLuck", true)
        if eggLuck then
            luckObj = eggLuck:FindFirstChild("Luck") or eggLuck
        else
            luckObj = egg:FindFirstChild("Luck", true)
        end
    end
    
    if not luckObj then return 0 end
    
    local rawText = ""
    if luckObj:IsA("TextLabel") or luckObj:IsA("TextBox") then
        rawText = luckObj.Text
    elseif luckObj:IsA("ValueBase") then
        rawText = tostring(luckObj.Value)
    elseif luckObj:IsA("BillboardGui") or luckObj:IsA("SurfaceGui") then
        local lbl = luckObj:FindFirstChildWhichIsA("TextLabel", true)
        if lbl then rawText = lbl.Text end
    else
        rawText = tostring(luckObj.Name)
    end
    
    return parseLuck(rawText)
end

local function findPickupPrompt(egg)
    if not egg then return nil end
    
    -- Target: workspace.RenderedEggs["Flaming Egg"].BandicootEgg.Pickup
    local prompt = egg:FindFirstChild("Pickup", true)
    if prompt and prompt:IsA("ProximityPrompt") then
        return prompt
    end
    
    -- Any proximity prompt inside egg
    local anyPrompt = egg:FindFirstChildWhichIsA("ProximityPrompt", true)
    if anyPrompt then
        return anyPrompt
    end
    
    return nil
end

local function firePrompt(prompt)
    if not prompt then return end
    
    pcall(function()
        if type(fireproximityprompt) == "function" then
            fireproximityprompt(prompt)
            fireproximityprompt(prompt, 0)
        end
    end)
    
    pcall(function()
        local oldHold = prompt.HoldDuration
        local oldDist = prompt.MaxActivationDistance
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 999
        prompt:InputHoldBegin()
        task.wait(0.04)
        prompt:InputHoldEnd()
        prompt.HoldDuration = oldHold
        prompt.MaxActivationDistance = oldDist
    end)
end

local function getHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart")
end

local RunService = cloneref(game:GetService("RunService"))
local noclipConnection = nil

local function setNoclip(enable)
    if enable then
        if not noclipConnection then
            noclipConnection = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    for _, p in ipairs(char:GetDescendants()) do
                        if p:IsA("BasePart") and p.CanCollide then
                            p.CanCollide = false
                        end
                    end
                end
            end)
        end
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end
end

local autoFarmEggs = false
local autoPlaceEgg = false
local fixedFlySpeed = 250 -- Reduced by ~10% (250 studs/s, smooth & steady)
local undergroundOffset = 10 -- 10 studs below ground level

local function createVector(x, y, z)
    if typeof(vector) == "table" and type(vector.create) == "function" then
        return vector.create(x, y, z)
    else
        return Vector3.new(x, y, z)
    end
end

local function getEggPlantPosition()
    local selfPlot = getSelfPlot()
    local baseplate = selfPlot and selfPlot:FindFirstChild("Baseplate", true)
    
    local baseX, baseY, baseZ = 35.879, 40313.24, 995.159
    if baseplate and baseplate:IsA("BasePart") then
        baseX = baseplate.Position.X
        baseY = baseplate.Position.Y + (baseplate.Size.Y / 2) + 0.2
        baseZ = baseplate.Position.Z
    elseif selfPlot then
        local cf = getSelfPlotCFrame()
        if cf then
            baseX = cf.Position.X
            baseY = cf.Position.Y - 3.0
            baseZ = cf.Position.Z
        end
    end
    
    -- Random offset between -5 and +5 studs for X and Z (0 to 5+ / 0 to 5-)
    local offsetX = (math.random() * 10) - 5
    local offsetZ = (math.random() * 10) - 5
    
    return baseX + offsetX, baseY, baseZ + offsetZ
end

-- Fly with noclip from current position to targetPos
local function flyNoclipTo(targetPos)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    setNoclip(true)
    
    local startTime = tick()
    local maxFlyTime = 22
    
    while autoFarmEggs do
        local currentChar = LocalPlayer.Character
        local currentHRP = currentChar and currentChar:FindFirstChild("HumanoidRootPart")
        if not currentHRP then break end
        
        local currentPos = currentHRP.Position
        local diff = targetPos - currentPos
        local dist = diff.Magnitude
        
        if dist <= 3 or (tick() - startTime) > maxFlyTime then
            currentHRP.CFrame = CFrame.new(targetPos)
            currentHRP.AssemblyLinearVelocity = Vector3.zero
            currentHRP.AssemblyAngularVelocity = Vector3.zero
            break
        end
        
        local dt = RunService.Heartbeat:Wait()
        local step = math.min(dist, fixedFlySpeed * dt)
        local dir = diff.Unit
        local nextPos = currentPos + dir * step
        currentHRP.CFrame = CFrame.new(nextPos, nextPos + dir)
        currentHRP.AssemblyLinearVelocity = Vector3.zero
        currentHRP.AssemblyAngularVelocity = Vector3.zero
    end
    
    return true
end

-- Underground travel: dive 10 studs below, travel horizontally underground, then ascend
local function travelUndergroundTo(targetSurfacePos, referenceGroundY)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local undergroundY = referenceGroundY - undergroundOffset
    local currentPos = hrp.Position
    
    -- Phase 1: Dive down underground (10 studs below reference ground)
    local divePos = Vector3.new(currentPos.X, undergroundY, currentPos.Z)
    flyNoclipTo(divePos)
    if not autoFarmEggs then return false end
    
    -- Phase 2: Horizontal travel underground to underneath target
    local underTargetPos = Vector3.new(targetSurfacePos.X, undergroundY, targetSurfacePos.Z)
    flyNoclipTo(underTargetPos)
    if not autoFarmEggs then return false end
    
    -- Phase 3: Ascend up to the target surface position
    flyNoclipTo(targetSurfacePos)
    
    setNoclip(false)
    return true
end

-- ══════════════════════════════════════════
--          FARMING SECTION
-- ══════════════════════════════════════════
local FarmingSection = Tabs.Farming:Section({
    Title = "Farming",
    Box = true,
    BoxBorder = true,
    Expandable = true,
    Opened = true
})

local minLuckValue = parseLuck("10k")

FarmingSection:Toggle({
    Title = "Auto Farm Eggs",
    Value = false,
    Callback = function(state)
        autoFarmEggs = state
        if not state then
            setNoclip(false)
            local hrp = getHRP()
            if hrp then
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
            Logger:Log("Auto Farm Eggs turned OFF.", "WARN")
        else
            Logger:Log("Auto Farm Eggs turned ON. Target Min Luck: " .. tostring(minLuckValue), "SUCCESS")
            task.spawn(function()
                while autoFarmEggs do
                    local success, err = pcall(function()
                        local hrp = getHRP()
                        if not hrp then
                            Logger:Log("Waiting for HumanoidRootPart...", "WARN")
                            task.wait(0.5)
                            return
                        end
                        
                        local renderedEggs = workspace:FindFirstChild("RenderedEggs")
                        if not renderedEggs then
                            Logger:Log("RenderedEggs folder not found in Workspace.", "WARN")
                            task.wait(0.5)
                            return
                        end
                        
                        -- Continuous scan: check both existing and new eggs
                        local eggs = renderedEggs:GetChildren()
                        local bestEgg = nil
                        local highestLuck = -1
                        
                        for _, egg in ipairs(eggs) do
                            local luck = getEggLuck(egg)
                            if luck >= minLuckValue and luck > highestLuck then
                                highestLuck = luck
                                bestEgg = egg
                            end
                        end
                        
                        -- If eligible highest egg found
                        if bestEgg and bestEgg.Parent == renderedEggs then
                            Logger:Log("Target Found: " .. bestEgg.Name .. " (Luck: " .. tostring(highestLuck) .. ")", "FARM")
                            
                            -- Determine egg position
                            local eggCFrame = nil
                            local handle = bestEgg:FindFirstChild("Handle")
                            if handle and handle:IsA("BasePart") then
                                eggCFrame = handle.CFrame
                            elseif bestEgg:IsA("Model") then
                                eggCFrame = bestEgg:GetPivot()
                            elseif bestEgg:IsA("BasePart") then
                                eggCFrame = bestEgg.CFrame
                            end
                            
                            if eggCFrame then
                                local plotCFrame = getSelfPlotCFrame()
                                local refGroundY = (plotCFrame and plotCFrame.Position.Y) or eggCFrame.Position.Y
                                
                                local eggSurfacePos = Vector3.new(eggCFrame.Position.X, eggCFrame.Position.Y + 0.5, eggCFrame.Position.Z)
                                
                                -- 1. Fly to Egg Underground (10 studs below ground, surfaces directly at egg)
                                Logger:Log("Traveling underground (10 studs below) to " .. bestEgg.Name .. "...", "INFO")
                                travelUndergroundTo(eggSurfacePos, refGroundY)
                                
                                if not autoFarmEggs then return end
                                
                                hrp.CFrame = CFrame.new(eggSurfacePos)
                                hrp.AssemblyLinearVelocity = Vector3.zero
                                hrp.AssemblyAngularVelocity = Vector3.zero
                                task.wait(0.08)
                                
                                -- 2. Confirm Player is Physically on the Egg
                                local distToEgg = (hrp.Position - eggCFrame.Position).Magnitude
                                if distToEgg > 5 then
                                    Logger:Log("Distance high (" .. string.format("%.1f", distToEgg) .. " studs), re-snapping to egg...", "WARN")
                                    hrp.CFrame = CFrame.new(eggSurfacePos)
                                    hrp.AssemblyLinearVelocity = Vector3.zero
                                    task.wait(0.08)
                                    distToEgg = (hrp.Position - eggCFrame.Position).Magnitude
                                end
                                
                                Logger:Log("Surfaced & Confirmed on egg! Distance: " .. string.format("%.2f", distToEgg) .. " studs", "SUCCESS")
                                
                                -- 3. Find and Fire Pickup Prompt (with Verification & Retry)
                                local prompt = findPickupPrompt(bestEgg)
                                local pickupSuccess = false
                                
                                if prompt then
                                    Logger:Log("Pickup prompt detected: " .. prompt.Name .. " (MaxDist: " .. tostring(prompt.MaxActivationDistance) .. ")", "INFO")
                                    
                                    -- Loop up to 5 attempts to ensure the egg is actually picked up before leaving
                                    for attempt = 1, 5 do
                                        if not autoFarmEggs then return end
                                        if not bestEgg or not bestEgg.Parent or bestEgg.Parent ~= renderedEggs then
                                            pickupSuccess = true
                                            Logger:Log("Egg picked up successfully! (Despawned from RenderedEggs)", "SUCCESS")
                                            break
                                        end
                                        
                                        Logger:Log("Triggering Pickup Prompt (Attempt " .. tostring(attempt) .. "/5)...", "FARM")
                                        firePrompt(prompt)
                                        task.wait(0.18)
                                        
                                        -- Check if egg was picked up (either destroyed or moved out of RenderedEggs)
                                        if not bestEgg or not bestEgg.Parent or bestEgg.Parent ~= renderedEggs then
                                            pickupSuccess = true
                                            Logger:Log("Egg collected! Disappeared from RenderedEggs.", "SUCCESS")
                                            break
                                        end
                                        
                                        -- If still exists, make sure character is still tight on egg
                                        hrp.CFrame = CFrame.new(eggSurfacePos)
                                        hrp.AssemblyLinearVelocity = Vector3.zero
                                        task.wait(0.06)
                                    end
                                    
                                    if not pickupSuccess then
                                        Logger:Log("Egg could not be collected after 5 attempts. Moving to plot.", "WARN")
                                    end
                                else
                                    Logger:Log("No Pickup ProximityPrompt found inside " .. bestEgg.Name .. "!", "WARN")
                                end
                                
                                if not autoFarmEggs then return end
                                
                                -- 4. Dive 10 studs underground and Fly Back to Self Plot
                                if plotCFrame then
                                    Logger:Log("Diving underground (10 studs below) to return to Self Plot...", "FARM")
                                    travelUndergroundTo(plotCFrame.Position, refGroundY)
                                    
                                    hrp.CFrame = plotCFrame
                                    hrp.AssemblyLinearVelocity = Vector3.zero
                                    task.wait(0.05)
                                    local distToPlot = (hrp.Position - plotCFrame.Position).Magnitude
                                    Logger:Log("Surfaced Back at Self Plot! (Dist: " .. string.format("%.1f", distToPlot) .. " studs)", "SUCCESS")
                                    
                                    -- Auto Place Egg if enabled
                                    if autoPlaceEgg then
                                        task.wait(0.08)
                                        pcall(function()
                                            local plantX, plantY, plantZ = getEggPlantPosition()
                                            local plantPos = createVector(plantX, plantY, plantZ)
                                            local args = {
                                                {
                                                    PlantPosition = plantPos
                                                }
                                            }
                                            local placeRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("EggPlaced")
                                            placeRemote:FireServer(unpack(args))
                                            Logger:Log("Auto Placed Egg at Plot: (" .. string.format("%.2f, %.2f, %.2f", plantX, plantY, plantZ) .. ")", "SUCCESS")
                                        end)
                                    end
                                else
                                    Logger:Log("Self plot not detected, staying at current position.", "WARN")
                                end
                                
                                task.wait(0.15)
                            else
                                Logger:Log("Could not determine CFrame for egg: " .. bestEgg.Name, "ERROR")
                                task.wait(0.3)
                            end
                        else
                            Logger:Log("No egg >= " .. tostring(minLuckValue) .. " luck currently rendered (Total scanned: " .. tostring(#eggs) .. ")", "INFO")
                            task.wait(0.5)
                        end
                    end)
                    
                    if not success then
                        Logger:Log("Auto Farm Exception: " .. tostring(err), "ERROR")
                        task.wait(0.5)
                    end
                end
                setNoclip(false)
            end)
        end
    end
})

FarmingSection:Input({
    Title = "Min Luck Egg",
    Desc = "Minimum luck required (e.g. 10k, 200, 250M, 12T)",
    Value = "10k",
    Placeholder = "Enter min luck (e.g. 10k)",
    Callback = function(value)
        minLuckValue = parseLuck(value)
        Logger:Log("Min Luck Egg updated to: " .. tostring(value) .. " (" .. tostring(minLuckValue) .. ")", "FARM")
        WindUI:Notify({
            Title = "Min Luck Updated",
            Content = "Target set to " .. tostring(value) .. " (" .. tostring(minLuckValue) .. ")",
            Duration = 3
        })
    end
})

FarmingSection:Toggle({
    Title = "Auto Place Egg",
    Desc = "Whenever it Farm An Egg it places that egg automatically",
    Value = false,
    Callback = function(state)
        autoPlaceEgg = state
    end
})

-- ══════════════════════════════════════════
--          AUTO BUY TAB & FEATURES
-- ══════════════════════════════════════════
local AutoBuySection = Tabs.AutoBuy:Section({
    Title = "Auto Buy",
    Box = true,
    BoxBorder = true,
    Expandable = true,
    Opened = true
})

-- ── Auto Rebirth Helper Functions ──
local function getRebirthProgressBarText()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    local main = playerGui:FindFirstChild("Main")
    if not main then return nil end
    local rebirth = main:FindFirstChild("Rebirth")
    if not rebirth then return nil end
    local seg2 = rebirth:FindFirstChild("Segment2")
    if not seg2 then return nil end
    local pbf = seg2:FindFirstChild("ProgressBarFrame")
    if not pbf then return nil end
    
    local valObj = pbf:FindFirstChild("Value") or pbf:FindFirstChildWhichIsA("TextLabel", true)
    if valObj then
        if valObj:IsA("TextLabel") or valObj:IsA("TextBox") then
            return valObj.Text
        elseif valObj:IsA("ValueBase") then
            return tostring(valObj.Value)
        end
    end
    return nil
end

local function checkRebirthProgress()
    local rawText = getRebirthProgressBarText()
    if not rawText or type(rawText) ~= "string" or not string.find(rawText, "/") then
        return false, 0, 0, rawText
    end
    
    local parts = string.split(rawText, "/")
    if #parts < 2 then return false, 0, 0, rawText end
    
    local leftStr = parts[1]
    local rightStr = parts[2]
    
    local leftNum = parseLuck(leftStr)
    local rightNum = parseLuck(rightStr)
    
    if rightNum > 0 and leftNum >= rightNum then
        return true, leftNum, rightNum, rawText
    end
    return false, leftNum, rightNum, rawText
end

local function getRequiredPetName()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    local main = playerGui:FindFirstChild("Main")
    if not main then return nil end
    local rebirth = main:FindFirstChild("Rebirth")
    if not rebirth then return nil end
    local seg2 = rebirth:FindFirstChild("Segment2")
    if not seg2 then return nil end
    
    local petHolder = seg2:FindFirstChild("pEThOLDER") 
        or seg2:FindFirstChild("PetHolder") 
        or seg2:FindFirstChild("PETHOLDER")
        or seg2:FindFirstChild("petholder")
        or seg2:FindFirstChildWhichIsA("Frame")
    if not petHolder then return nil end
    
    local petNameObj = petHolder:FindFirstChild("PetName") 
        or petHolder:FindFirstChild("petName")
        or petHolder:FindFirstChild("Petname")
        or petHolder:FindFirstChildWhichIsA("TextLabel", true)
    
    if petNameObj then
        if petNameObj:IsA("TextLabel") or petNameObj:IsA("TextBox") then
            return petNameObj.Text
        elseif petNameObj:IsA("ValueBase") then
            return tostring(petNameObj.Value)
        end
    end
    return nil
end

local function checkHasRequiredPet(requiredPetName)
    if not requiredPetName or requiredPetName == "" then
        return true, "None"
    end
    
    -- Clean target name: strip rich text, brackets like [5,287 KG], and prefixes
    local cleanName = string.gsub(requiredPetName, "<[^>]+>", "")
    cleanName = string.gsub(cleanName, "%[.*%]", "")
    cleanName = string.match(cleanName, "([%a%s]+)") or cleanName
    cleanName = string.gsub(cleanName, "^%s+", "")
    cleanName = string.gsub(cleanName, "%s+$", "")
    
    if cleanName == "" then
        return true, "None"
    end
    local cleanLower = string.lower(cleanName)
    
    -- 1. Check Backpack
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            local itemName = string.lower(item.Name)
            if string.find(itemName, cleanLower, 1, true) then
                return true, item.Name
            end
        end
    end
    
    -- 2. Check Character (equipped items/pets)
    local char = LocalPlayer.Character
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") or item:IsA("Model") then
                local itemName = string.lower(item.Name)
                if string.find(itemName, cleanLower, 1, true) then
                    return true, item.Name
                end
            end
        end
    end
    
    -- 3. Check any Inventory/Pets folder in LocalPlayer
    for _, folderName in ipairs({"Inventory", "Pets", "PlayerInventory"}) do
        local inv = LocalPlayer:FindFirstChild(folderName)
        if inv then
            for _, item in ipairs(inv:GetChildren()) do
                local itemName = string.lower(item.Name)
                if string.find(itemName, cleanLower, 1, true) then
                    return true, item.Name
                end
            end
        end
    end
    
    return false, nil
end

-- ── Auto Upgrade Hatch Luck Helper Functions ──
local lockedMaxUpgradeGui = nil

local function getSelfMaxUpgradeGui()
    local selfPlot = getSelfPlot()
    if not selfPlot then return nil end
    
    -- Check if previously locked GUI is still valid
    if lockedMaxUpgradeGui and lockedMaxUpgradeGui.Parent then
        local adornee = nil
        pcall(function() adornee = lockedMaxUpgradeGui.Adornee end)
        if adornee and adornee:IsDescendantOf(selfPlot) then
            return lockedMaxUpgradeGui
        end
    end
    
    lockedMaxUpgradeGui = nil
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    
    -- 1. Search in PlayerGui for any MaxUpgrade whose Adornee is inside selfPlot
    for _, gui in ipairs(playerGui:GetChildren()) do
        if string.find(gui.Name, "MaxUpgrade") then
            local adornee = nil
            pcall(function() adornee = gui.Adornee end)
            if adornee and adornee:IsDescendantOf(selfPlot) then
                lockedMaxUpgradeGui = gui
                Logger:Log("Locked Self Plot MaxUpgrade via Adornee: " .. adornee:GetFullName(), "INFO")
                return gui
            end
        end
    end
    
    -- 2. Fallback: Search inside selfPlot.HatchUpgrade directly
    local hatchUpgrade = selfPlot:FindFirstChild("HatchUpgrade", true)
    if hatchUpgrade then
        local maxUp = hatchUpgrade:FindFirstChild("MaxUpgrade", true)
        if maxUp and (maxUp:IsA("BillboardGui") or maxUp:IsA("SurfaceGui") or maxUp:IsA("GuiBase2d")) then
            lockedMaxUpgradeGui = maxUp
            return maxUp
        end
    end
    
    -- 3. Fallback: Check all PlayerGui MaxUpgrade instances for Adornee pointing to HatchUpgrade
    for _, gui in ipairs(playerGui:GetChildren()) do
        if string.find(gui.Name, "MaxUpgrade") then
            local adornee = nil
            pcall(function() adornee = gui.Adornee end)
            if adornee and string.find(adornee.Name, "Upgrade") and adornee:IsDescendantOf(selfPlot) then
                lockedMaxUpgradeGui = gui
                return gui
            end
        end
    end
    
    return nil
end

local function getPlayerCash()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return 0 end
    local main = playerGui:FindFirstChild("Main")
    if not main then return 0 end
    local cashLabel = main:FindFirstChild("CashLabel") or main:FindFirstChild("Cash", true)
    if not cashLabel then return 0 end
    
    local rawText = ""
    if cashLabel:IsA("TextLabel") or cashLabel:IsA("TextBox") then
        rawText = cashLabel.Text
    elseif cashLabel:IsA("ValueBase") then
        rawText = tostring(cashLabel.Value)
    end
    
    return parseLuck(rawText)
end

local function getUpgradePrice(gui)
    if not gui then return 0 end
    
    local purchase = gui:FindFirstChild("Purchase", true)
    local priceObj = nil
    if purchase then
        priceObj = purchase:FindFirstChild("Price") or purchase:FindFirstChildWhichIsA("TextLabel", true)
    end
    if not priceObj then
        priceObj = gui:FindFirstChild("Price", true)
    end
    
    if not priceObj then return 0 end
    
    local rawText = ""
    if priceObj:IsA("TextLabel") or priceObj:IsA("TextBox") then
        rawText = priceObj.Text
    elseif priceObj:IsA("ValueBase") then
        rawText = tostring(priceObj.Value)
    end
    
    local lower = string.lower(rawText)
    if string.find(lower, "max") then
        return -1 -- Already maxed out
    end
    
    return parseLuck(rawText)
end

-- ── Auto Rebirth Feature ──
local autoRebirth = false

AutoBuySection:Toggle({
    Title = "Auto Rebirth",
    Value = false,
    Callback = function(state)
        autoRebirth = state
        if state then
            Logger:Log("Auto Rebirth turned ON.", "SUCCESS")
            task.spawn(function()
                while autoRebirth do
                    local ok, err = pcall(function()
                        local canRebirth, currentVal, targetVal, rawProgress = checkRebirthProgress()
                        
                        if canRebirth then
                            local reqPet = getRequiredPetName()
                            local hasPet, matchedItem = checkHasRequiredPet(reqPet)
                            
                            if hasPet then
                                Logger:Log("Rebirth Ready! Cash: " .. tostring(rawProgress) .. " | Pet: " .. tostring(matchedItem or reqPet or "None"), "FARM")
                                local rebirthRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("Rebirth")
                                rebirthRemote:FireServer()
                                Logger:Log("Rebirth Remote Fired Successfully!", "SUCCESS")
                                task.wait(1.5)
                            else
                                Logger:Log("Rebirth cash ready (" .. tostring(rawProgress) .. ") but required pet '" .. tostring(reqPet) .. "' missing from Backpack/Inventory.", "WARN")
                                task.wait(1.5)
                            end
                        else
                            task.wait(1)
                        end
                    end)
                    if not ok then
                        Logger:Log("Auto Rebirth check error: " .. tostring(err), "ERROR")
                        task.wait(1.5)
                    end
                end
                Logger:Log("Auto Rebirth turned OFF.", "WARN")
            end)
        else
            Logger:Log("Auto Rebirth turned OFF.", "WARN")
        end
    end
})

-- ── Auto Upgrade Hatch Luck Feature ──
local autoUpgradeHatchLuck = false

AutoBuySection:Toggle({
    Title = "Auto Upgrade Hatch Luck",
    Value = false,
    Callback = function(state)
        autoUpgradeHatchLuck = state
        if state then
            Logger:Log("Auto Upgrade Hatch Luck turned ON.", "SUCCESS")
            task.spawn(function()
                while autoUpgradeHatchLuck do
                    local ok, err = pcall(function()
                        local upgradeGui = getSelfMaxUpgradeGui()
                        if not upgradeGui then
                            task.wait(1)
                            return
                        end
                        
                        local price = getUpgradePrice(upgradeGui)
                        if price == -1 then
                            Logger:Log("Hatch Luck Upgrade is already MAXED!", "SUCCESS")
                            task.wait(3)
                            return
                        end
                        
                        if price > 0 then
                            local playerCash = getPlayerCash()
                            if playerCash >= price then
                                Logger:Log("Affordable Upgrade! Cash: " .. tostring(playerCash) .. " >= Price: " .. tostring(price) .. ". Purchasing...", "FARM")
                                
                                local args = { "Max" }
                                local upgradeRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("Plot"):WaitForChild("Upgrades")
                                upgradeRemote:FireServer(unpack(args))
                                
                                Logger:Log("Max Upgrade remote fired!", "SUCCESS")
                                task.wait(0.4)
                            else
                                task.wait(0.3)
                            end
                        else
                            task.wait(0.5)
                        end
                    end)
                    
                    if not ok then
                        Logger:Log("Auto Upgrade Hatch Luck error: " .. tostring(err), "ERROR")
                        task.wait(1)
                    end
                end
                Logger:Log("Auto Upgrade Hatch Luck turned OFF.", "WARN")
            end)
        else
            Logger:Log("Auto Upgrade Hatch Luck turned OFF.", "WARN")
        end
    end
})

WindUI:Notify({
    Title = "Prime X Hub",
    Content = "Script loaded successfully!",
    Duration = 5
})
