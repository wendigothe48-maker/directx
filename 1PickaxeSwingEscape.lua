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

local MainSection = Tabs.Main:Section({
    Title = "Auto Farm",
    Box = true,
    BoxBorder = true,
    Expandable = true,
    Opened = true
})

_G.AutoFarmWins = false
MainSection:Toggle({
    Title = "Auto Farm Wins",
    Description = "Automatically teleport to highest stage and win pad",
    State = false,
    Callback = function(Value)
        _G.AutoFarmWins = Value
        if Value then
            task.spawn(function()
                while _G.AutoFarmWins do
                    local lp = game:GetService("Players").LocalPlayer
                    local char = lp.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local maxStageX = 0
                        local maxStagePart = nil
                        
                        local highestMapNum = -1
                        local highestMapFolder = nil
                        for _, child in ipairs(workspace:GetChildren()) do
                            if child.Name == "Map" then
                                if 0 > highestMapNum then
                                    highestMapNum = 0
                                    highestMapFolder = child
                                end
                            else
                                local mNum = tonumber(string.match(child.Name, "^Map(%d+)$"))
                                if mNum and mNum > highestMapNum then
                                    highestMapNum = mNum
                                    highestMapFolder = child
                                end
                            end
                        end
                        
                        local stages = highestMapFolder and highestMapFolder:FindFirstChild("Stages")
                        if stages then
                            for _, child in ipairs(stages:GetChildren()) do
                                local num = tonumber(string.match(child.Name, "^Stage(%d+)$"))
                                if num and num > maxStageX then
                                    maxStageX = num
                                    maxStagePart = child
                                end
                            end
                        end
                        
                        if maxStagePart then
                            char.HumanoidRootPart.CFrame = maxStagePart.CFrame
                            task.wait(1.1)
                            
                            if not _G.AutoFarmWins then break end
                            
                            local hitBox = nil
                            local shortestDist = math.huge
                            local worlds = workspace:FindFirstChild("Worlds")
                            if worlds then
                                for _, world in ipairs(worlds:GetChildren()) do
                                    local winPads = world:FindFirstChild("DefaultWinPads")
                                    if winPads then
                                        for _, pad in ipairs(winPads:GetChildren()) do
                                            local hb = pad:FindFirstChild("HitBox")
                                            if hb and hb:IsA("BasePart") then
                                                local dist = (char.HumanoidRootPart.Position - hb.Position).Magnitude
                                                if dist < shortestDist then
                                                    shortestDist = dist
                                                    hitBox = hb
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                                
                            if hitBox then
                                char.HumanoidRootPart.CFrame = hitBox.CFrame
                                fireTouch(hitBox, char.HumanoidRootPart)
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})


_G.AutoRebirth = false
MainSection:Toggle({
    Title = "Auto Rebirth",
    Description = "Automatically rebirths when the bar is full",
    State = false,
    Callback = function(Value)
        _G.AutoRebirth = Value
        if Value then
            task.spawn(function()
                while _G.AutoRebirth do
                    local lp = game:GetService("Players").LocalPlayer
                    local gui = lp:FindFirstChild("PlayerGui")
                    if gui then
                        local progress = gui:FindFirstChild("Game") 
                            and gui.Game:FindFirstChild("Rebirths") 
                            and gui.Game.Rebirths:FindFirstChild("Bar") 
                            and gui.Game.Rebirths.Bar:FindFirstChild("Progress")
                        
                        if progress then
                            local size = progress.Size
                            if size.X.Scale >= 1 and size.Y.Scale >= 1 then
                                pcall(function()
                                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Rebirth"):InvokeServer()
                                end)
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

local AuraSection = Tabs.Main:Section({
    Title = "Aura",
    Box = true,
    BoxBorder = true,
    Expandable = true,
    Opened = true
})

_G.AuraMode = "None"
AuraSection:Dropdown({
    Title = "Select Aura",
    Values = {"None", "Level Up Aura", "Block Break Aura"},
    Value = "None",
    Callback = function(Value)
        _G.AuraMode = Value
    end
})

_G.AuraToggle = false
AuraSection:Toggle({
    Title = "Enable Aura",
    Description = "Activates the selected aura",
    State = false,
    Callback = function(Value)
        _G.AuraToggle = Value
        if Value then
            task.spawn(function()
                while _G.AuraToggle do
                    local lp = game:GetService("Players").LocalPlayer
                    local char = lp.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    
                    if root then
                        local blocksFolder = workspace:FindFirstChild("Blocks")
                        if blocksFolder then
                            if _G.AuraMode == "Block Break Aura" then
                                for _, block in ipairs(blocksFolder:GetChildren()) do
                                    if not _G.AuraToggle or _G.AuraMode ~= "Block Break Aura" then break end
                                    local pos = block:IsA("Model") and (block.PrimaryPart and block.PrimaryPart.Position or block:GetModelCFrame().Position) or block:IsA("BasePart") and block.Position
                                    
                                    if pos then
                                        local dx = math.abs(root.Position.X - pos.X)
                                        local dy = math.abs(root.Position.Y - pos.Y)
                                        local dz = math.abs(root.Position.Z - pos.Z)
                                        
                                        if dx <= 19 and dz <= 19 and dy <= 6 then
                                            if block:IsA("BasePart") then
                                                block.CFrame = block.CFrame - Vector3.new(0, 8, 0)
                                            elseif block:IsA("Model") then
                                                block:PivotTo(block:GetPivot() - Vector3.new(0, 8, 0))
                                            end
                                        end
                                    end
                                end
                                task.wait(0.1)
                                
                            elseif _G.AuraMode == "Level Up Aura" then
                                local inRange = {}
                                for _, block in ipairs(blocksFolder:GetChildren()) do
                                    local pos = block:IsA("Model") and (block.PrimaryPart and block.PrimaryPart.Position or block:GetModelCFrame().Position) or block:IsA("BasePart") and block.Position
                                    if pos then
                                        local dx = math.abs(root.Position.X - pos.X)
                                        local dy = math.abs(root.Position.Y - pos.Y)
                                        local dz = math.abs(root.Position.Z - pos.Z)
                                        if dx <= 19 and dz <= 19 and dy <= 6 then
                                            table.insert(inRange, block)
                                        end
                                    end
                                end
                                
                                if #inRange > 0 then
                                    for _, block in ipairs(inRange) do
                                        if not _G.AuraToggle or _G.AuraMode ~= "Level Up Aura" then break end
                                        
                                        local pos = block:IsA("Model") and (block.PrimaryPart and block.PrimaryPart.Position or block:GetModelCFrame().Position) or block:IsA("BasePart") and block.Position
                                        if pos and root then
                                            local dx = math.abs(root.Position.X - pos.X)
                                            local dy = math.abs(root.Position.Y - pos.Y)
                                            local dz = math.abs(root.Position.Z - pos.Z)
                                            if dx <= 19 and dz <= 19 and dy <= 6 then
                                                task.spawn(function()
                                                    pcall(function()
                                                        local args = { block }
                                                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DamageBlock"):InvokeServer(unpack(args))
                                                    end)
                                                end)
                                            end
                                        end
                                    end
                                    task.wait(0.2)
                                else
                                    task.wait(0.2)
                                end
                            else
                                task.wait(0.5) -- "None" selected
                            end
                        else
                            task.wait(1)
                        end
                    else
                        task.wait(1)
                    end
                end
            end)
        end
    end
})


local function CleanAndParse(rawText)
    if type(rawText) ~= "string" then return 0 end
    local cleanText = string.gsub(rawText, "<[^>]+>", "") -- remove rich text tags
    cleanText = string.gsub(cleanText, ",", "") -- remove commas
    
    -- Using string.match to strictly extract the first valid number and its optional suffix
    local numStr, suffix = string.match(string.lower(cleanText), "([%d%.]+)%s*([kmbt]?)")
    
    if not numStr then return 0 end
    
    local num = tonumber(numStr)
    if not num then return 0 end
    
    local mult = 1
    if suffix == "k" then mult = 1e3
    elseif suffix == "m" then mult = 1e6
    elseif suffix == "b" then mult = 1e9
    elseif suffix == "t" then mult = 1e12
    end
    
    return num * mult
end

_G.AutoBestBuyPickaxe = false
MainSection:Toggle({
    Title = "Auto Best Buy Pickaxe",
    Description = "Automatically buys and equips the best affordable pickaxe",
    State = false,
    Callback = function(Value)
        _G.AutoBestBuyPickaxe = Value
        if Value then
            task.spawn(function()
                while _G.AutoBestBuyPickaxe do
                    local lp = game:GetService("Players").LocalPlayer
                    local pickaxes = workspace:FindFirstChild("Pickaxes")
                    
                    if pickaxes and lp:FindFirstChild("leaderstats") and lp.leaderstats:FindFirstChild("Wins") then
                        local myWins = CleanAndParse(tostring(lp.leaderstats.Wins.Value))
                        
                        local currentEquippedStat = -1
                        local bestOwnedStat = -1
                        local bestOwnedName = nil
                        local cheapestUnownedPrice = math.huge
                        local cheapestUnownedName = nil
                        local cheapestUnownedStat = -1
                        
                        print("[Auto Best Buy Pickaxe] Checking pickaxes...")
                        -- First pass: find what is equipped
                        for _, pickaxe in ipairs(pickaxes:GetChildren()) do
                            local attachment = pickaxe:FindFirstChild("Attachment")
                            if attachment then
                                local bbGui = attachment:FindFirstChild("BillboardGui")
                                if bbGui and bbGui:FindFirstChild("Txt") and bbGui:FindFirstChild("Wins") and bbGui.Wins:FindFirstChild("Reward") then
                                    local txtVal = string.upper(bbGui.Txt.Text)
                                    if string.find(txtVal, "EQUIPPED") then
                                        currentEquippedStat = CleanAndParse(bbGui.Wins.Reward.Text)
                                        print("[Auto Best Buy Pickaxe] Found currently equipped: " .. pickaxe.Name .. " with stat: " .. tostring(currentEquippedStat))
                                        break
                                    end
                                end
                            end
                        end
                        
                        -- Second pass: find best owned and cheapest unowned
                        for _, pickaxe in ipairs(pickaxes:GetChildren()) do
                            local attachment = pickaxe:FindFirstChild("Attachment")
                            if attachment then
                                local bbGui = attachment:FindFirstChild("BillboardGui")
                                if bbGui and bbGui:FindFirstChild("Txt") and bbGui:FindFirstChild("Wins") and bbGui.Wins:FindFirstChild("Reward") then
                                    local txtVal = string.upper(bbGui.Txt.Text)
                                    local statVal = CleanAndParse(bbGui.Wins.Reward.Text)
                                    
                                    if not string.find(txtVal, "LOCKED") and not string.find(txtVal, "EQUIPPED") then
                                        if string.find(txtVal, "OWNED") then
                                            print("[Auto Best Buy Pickaxe] Found OWNED pickaxe: " .. pickaxe.Name .. " stat: " .. tostring(statVal))
                                            if statVal > currentEquippedStat and statVal > bestOwnedStat then
                                                bestOwnedStat = statVal
                                                bestOwnedName = pickaxe.Name
                                            end
                                        else
                                            local priceVal = CleanAndParse(txtVal)
                                            print("[Auto Best Buy Pickaxe] Found UNOWNED pickaxe: " .. pickaxe.Name .. " price: " .. tostring(priceVal) .. " stat: " .. tostring(statVal))
                                            if myWins >= priceVal and priceVal < cheapestUnownedPrice then
                                                cheapestUnownedPrice = priceVal
                                                cheapestUnownedName = pickaxe.Name
                                                cheapestUnownedStat = statVal
                                            end
                                        end
                                    else
                                        print("[Auto Best Buy Pickaxe] Ignoring " .. pickaxe.Name .. " (LOCKED or EQUIPPED)")
                                    end
                                end
                            end
                        end
                        
                        local bestPickaxeName = nil
                        
                        -- Prioritize buying the cheapest affordable pickaxe we don't own yet
                        if cheapestUnownedName then
                            print("[Auto Best Buy Pickaxe] Buying cheapest unowned pickaxe: " .. cheapestUnownedName .. " for " .. tostring(cheapestUnownedPrice))
                            bestPickaxeName = cheapestUnownedName
                        -- Else, if we own one that is better than currently equipped, equip it
                        elseif bestOwnedName then
                            print("[Auto Best Buy Pickaxe] Equipping best owned pickaxe: " .. bestOwnedName .. " with stat " .. tostring(bestOwnedStat))
                            bestPickaxeName = bestOwnedName
                        else
                            print("[Auto Best Buy Pickaxe] No pickaxe to buy or equip.")
                        end
                        
                        if bestPickaxeName then
                            pcall(function()
                                local args = { bestPickaxeName }
                                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PickaxeShop"):FireServer(unpack(args))
                            end)
                        end
                    end
                    task.wait(2.5)
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
