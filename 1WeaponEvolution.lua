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

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local parseWins = function(valStr)
    if type(valStr) ~= "string" then valStr = tostring(valStr) end
    local wVal = string.upper(valStr)
    wVal = string.gsub(wVal, "<[^>]+>", "")
    wVal = string.gsub(wVal, ",", "")
    wVal = string.gsub(wVal, "WINS", "")
    wVal = string.gsub(wVal, "REQUIRED", "")
    wVal = string.gsub(wVal, "%s+", "")
    
    local numVal, suffix = string.match(wVal, "([%d%.]+)([KMBT]?)")
    if numVal then
        local n = tonumber(numVal)
        if n then
            if suffix == "K" then n = n * 1000
            elseif suffix == "M" then n = n * 1000000
            elseif suffix == "B" then n = n * 1000000000
            elseif suffix == "T" then n = n * 1000000000000
            end
            return n
        end
    end
    
    return 0
end

local FarmingSection = Tabs.Main:Section({ Title = "Farming", Box = true, BoxBorder = true, Opened = true })

local PetsSection = Tabs.Main:Section({ Title = "Slimes", Box = true, BoxBorder = true, Opened = true })

local autoFarmClicksEnabled = false
FarmingSection:Toggle({
    Title = "Auto Farm Clicks",
    Value = false,
    Callback = function(Value)
        autoFarmClicksEnabled = Value
        if Value then
            task.spawn(function()
                while autoFarmClicksEnabled do
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ClickNoob"):FireServer("1")
                    end)
                    task.wait(0.01)
                end
            end)
        end
    end
})

local autoFarmWinsEnabled = false
FarmingSection:Toggle({
    Title = "Auto Farm Wins",
    Value = false,
    Callback = function(Value)
        autoFarmWinsEnabled = Value
        if Value then
            task.spawn(function()
                while autoFarmWinsEnabled do
                    pcall(function()
                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local winsStage = workspace:FindFirstChild("WinsStage")
                            if winsStage then
                                local highestNum = -1
                                local highestFolder = nil
                                for _, child in ipairs(winsStage:GetChildren()) do
                                    local num = tonumber(child.Name)
                                    if num and num > highestNum then
                                        highestNum = num
                                        highestFolder = child
                                    end
                                end
                                
                                if highestFolder then
                                    local wins = highestFolder:FindFirstChild("Wins")
                                    if wins then
                                        local t_part = wins:FindFirstChild("T")
                                        if t_part and t_part:IsA("BasePart") then
                                            local uis = game:GetService("UserInputService")
                                            local isMobile = uis.TouchEnabled and not uis.MouseEnabled
                                            if isMobile then
                                                firetouchinterest(hrp, t_part, 0)
                                                task.wait(0.01)
                                                firetouchinterest(hrp, t_part, 1)
                                            else
                                                firetouchinterest(hrp, t_part, 0)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.4)
                end
            end)
        end
    end
})

local autoEquipWeaponEnabled = false
FarmingSection:Toggle({
    Title = "Auto Equip Best Weapon",
    Value = false,
    Callback = function(Value)
        autoEquipWeaponEnabled = Value
        if Value then
            task.spawn(function()
                while autoEquipWeaponEnabled do
                    pcall(function()
                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if not hrp then return end
                        
                        local currentWins = 0
                        local winsInfo = LocalPlayer:FindFirstChild("PlayerGui")
                        if winsInfo then
                            winsInfo = winsInfo:FindFirstChild("GameUI")
                        end
                        if winsInfo then
                            winsInfo = winsInfo:FindFirstChild("Info")
                        end
                        if winsInfo then
                            winsInfo = winsInfo:FindFirstChild("wins")
                        end
                        if winsInfo then
                            winsInfo = winsInfo:FindFirstChild("amount")
                        end
                        
                        if winsInfo and winsInfo:IsA("TextLabel") then
                            currentWins = parseWins(winsInfo.Text)
                        end
                        
                        local weaponsLayout = workspace:FindFirstChild("WeaponsLayout")
                        if weaponsLayout then
                            local bestWeaponCost = -1
                            local bestWeaponModel = nil
                            
                            for _, weapon in ipairs(weaponsLayout:GetChildren()) do
                                if weapon:IsA("Model") then
                                    local pad = weapon:FindFirstChild("Pad")
                                    if pad then
                                        local bb = pad:FindFirstChild("WeaponsBillboard")
                                        if bb then
                                            local winsLbl = bb:FindFirstChild("Wins")
                                            if winsLbl and winsLbl:IsA("TextLabel") then
                                                local wCost = parseWins(winsLbl.Text)
                                                if wCost <= currentWins and wCost > bestWeaponCost then
                                                    bestWeaponCost = wCost
                                                    bestWeaponModel = weapon
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            
                            if bestWeaponModel then
                                local pad = bestWeaponModel:FindFirstChild("Pad")
                                local hitbox = bestWeaponModel:FindFirstChild("Hitbox")
                                if pad and hitbox then
                                    local parts = pad:FindFirstChild("Parts")
                                    if parts then
                                        local union = parts:FindFirstChild("Union")
                                        if union and union:IsA("BasePart") then
                                            local c = union.Color
                                            local isEquipped = (math.abs(c.R*255 - 58) < 5 and math.abs(c.G*255 - 209) < 5 and math.abs(c.B*255 - 255) < 5)
                                            if not isEquipped then
                                                local uis = game:GetService("UserInputService")
                                                local isMobile = uis.TouchEnabled and not uis.MouseEnabled
                                                if isMobile then
                                                    firetouchinterest(hrp, hitbox, 0)
                                                    task.wait(0.01)
                                                    firetouchinterest(hrp, hitbox, 1)
                                                else
                                                    firetouchinterest(hrp, hitbox, 0)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(2)
                end
            end)
        end
    end
})

local autoRebirthEnabled = false
FarmingSection:Toggle({
    Title = "Auto Rebirth",
    Value = false,
    Callback = function(Value)
        autoRebirthEnabled = Value
        if Value then
            task.spawn(function()
                while autoRebirthEnabled do
                    pcall(function()
                        local gui = LocalPlayer:FindFirstChild("PlayerGui")
                        if gui then
                            local gameGui = gui:FindFirstChild("GameUI")
                            if gameGui then
                                local rFrame = gameGui:FindFirstChild("RebirthFrame")
                                if rFrame then
                                    local req = rFrame:FindFirstChild("LevelRequirement")
                                    if req then
                                        local grad = req:FindFirstChild("Gradient")
                                        if grad and grad.Size.X.Scale >= 0.99 then
                                            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Rebirth"):FireServer()
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    end
})

local function getEggOptions()
    local options = {}
    local eggInfoFolder = workspace:FindFirstChild("EggInfo")
    if eggInfoFolder then
        for _, egg in ipairs(eggInfoFolder:GetChildren()) do
            local info = egg:FindFirstChild("EggInfo")
            if info then
                local winsLbl = info:FindFirstChild("Wins")
                if winsLbl and winsLbl:IsA("TextLabel") then
                    local costText = winsLbl.Text
                    table.insert(options, egg.Name .. " [" .. costText .. "]")
                end
            end
        end
    end
    table.sort(options, function(a, b)
        local numA = tonumber(string.match(a, "^(%d+)")) or tonumber(a) or 0
        local numB = tonumber(string.match(b, "^(%d+)")) or tonumber(b) or 0
        return numA < numB
    end)
    return options
end

local selectedEggName = nil
local selectedEggCost = 0

PetsSection:Dropdown({
    Title = "Select Egg to Open",
    Value = nil,
    AllowMultiple = false,
    Values = getEggOptions(),
    Callback = function(val)
        if type(val) == "string" then
            selectedEggName = string.match(val, "^(.-)%s*%[") or val
            local costStr = string.match(val, "%[([^%]]+)%]")
            selectedEggCost = parseWins(costStr or "0")
        end
    end
})

local autoOpenEggEnabled = false
PetsSection:Toggle({
    Title = "Auto Open Egg",
    Value = false,
    Callback = function(Value)
        autoOpenEggEnabled = Value
        if Value then
            task.spawn(function()
                while autoOpenEggEnabled do
                    if selectedEggName and selectedEggCost then
                        pcall(function()
                            local currentWins = 0
                            local winsInfo = LocalPlayer:FindFirstChild("PlayerGui")
                            if winsInfo then winsInfo = winsInfo:FindFirstChild("GameUI") end
                            if winsInfo then winsInfo = winsInfo:FindFirstChild("Info") end
                            if winsInfo then winsInfo = winsInfo:FindFirstChild("wins") end
                            if winsInfo then winsInfo = winsInfo:FindFirstChild("amount") end
                            
                            if winsInfo and winsInfo:IsA("TextLabel") then
                                currentWins = parseWins(winsInfo.Text)
                            end
                            
                            if currentWins >= selectedEggCost then
                                local args = { selectedEggName, 1 }
                                game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("EggHatch"):InvokeServer(unpack(args))
                            end
                        end)
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

local autoEquipPetsEnabled = false
PetsSection:Toggle({
    Title = "Auto Equip Best Slime (12S)",
    Value = false,
    Callback = function(Value)
        autoEquipPetsEnabled = Value
        if Value then
            task.spawn(function()
                while autoEquipPetsEnabled do
                    pcall(function()
                        local args = { "equip best" }
                        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Slime"):InvokeServer(unpack(args))
                    end)
                    task.wait(12)
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
