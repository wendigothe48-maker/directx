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
    Main = Window:Tab({ Title = "Main", Icon = "solar:star-bold" }),
    Movement = Window:Tab({ Title = "Movement", Icon = "solar:running-bold" }),
    Teleport = Window:Tab({ Title = "Teleport", Icon = "solar:map-point-bold" }),
    Settings = Window:Tab({ Title = "Settings", Icon = "solar:settings-bold" }),
    AboutUs  = Window:Tab({ Title = "About Us", Icon = "solar:info-circle-bold" })
}

-- ══════════════════════════════════════════
--              FARMING UTILITIES
-- ══════════════════════════════════════════
local autoLemonsToggle = false
local autoUpgradeLemonToggle = false
local autoUpgradeButtonsToggle = false
local upgradeTargetOptions = {}
local upgradeLemonsDelay = 0.5

local suffixes = {
    k = 1e3, m = 1e6, million = 1e6, b = 1e9, billion = 1e9, t = 1e12, trillion = 1e12,
    qa = 1e15, quadrillion = 1e15, qi = 1e18, quintillion = 1e18, sx = 1e21, sextillion = 1e21,
    sp = 1e24, septillion = 1e24, oc = 1e27, octillion = 1e27, no = 1e30, nonillion = 1e30,
    dc = 1e33, decillion = 1e33, ud = 1e36, undecillion = 1e36, dd = 1e39, duodecillion = 1e39,
    td = 1e42, tredecillion = 1e42, qad = 1e45, quattuordecillion = 1e45, qid = 1e48, quindecillion = 1e48,
    sxd = 1e51, sexdecillion = 1e51, spd = 1e54, septendecillion = 1e54, od = 1e57, octodecillion = 1e57,
    nd = 1e60, novemdecillion = 1e60, v = 1e63, vigintillion = 1e63, uv = 1e66, unvigintillion = 1e66,
    dv = 1e69, duovigintillion = 1e69, tv = 1e72, trevigintillion = 1e72, qav = 1e75, quattuorvigintillion = 1e75,
    qiv = 1e78, quinvigintillion = 1e78, sxv = 1e81, sexvigintillion = 1e81, spv = 1e84, septenvigintillion = 1e84
}

local function parseToNum(str)
    if not str then return 0 end
    str = tostring(str):lower():gsub(",", ""):gsub("%$", ""):gsub("^%s*", ""):gsub("%s*$", "")
    if str == "" then return 0 end
    local numPart, suffixPart = str:match("([%d%.]+)%s*(%a*)")
    if not numPart then return 0 end
    local num = tonumber(numPart) or 0
    if suffixPart and suffixPart ~= "" and suffixes[suffixPart] then
        num = num * suffixes[suffixPart]
    end
    return num
end

local function getPlayerCash()
    local lp = game:GetService("Players").LocalPlayer
    local hudCash = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("HUD") and lp.PlayerGui.HUD:FindFirstChild("Balance") and lp.PlayerGui.HUD.Balance:FindFirstChild("Main") and lp.PlayerGui.HUD.Balance.Main:FindFirstChild("Cash")
    if hudCash and hudCash:IsA("TextLabel") then
        return parseToNum(hudCash.Text)
    end
    
    local cashStat = lp:FindFirstChild("leaderstats") and lp.leaderstats:FindFirstChild("Cash")
    if cashStat then
        return parseToNum(cashStat.Value)
    end
    return 0
end

local function getMyTycoon()
    local lp = game:GetService("Players").LocalPlayer
    for _, child in ipairs(workspace:GetChildren()) do
        if child.Name:match("^Tycoon") and child:FindFirstChild("Owner") then
            local owner = child.Owner
            if owner:IsA("ObjectValue") and owner.Value == lp then
                return child
            elseif owner:IsA("StringValue") and owner.Value == lp.Name then
                return child
            end
        end
    end
    return nil
end

task.spawn(function()
    task.wait(2)
    local foundTycoon = getMyTycoon()
    if foundTycoon then
        print("[Prime X Hub] Successfully detected Player's Tycoon: " .. foundTycoon.Name)
    else
        print("[Prime X Hub] Failed to detect Player's Tycoon!")
    end
end)

local function hasSelection(valTable, key)
    if type(valTable) == "table" then
        if valTable[key] == true then return true end
        for _, v in pairs(valTable) do
            if v == key then return true end
        end
    end
    return false
end

Tabs.Main:Toggle({
    Title = "Auto Click Lemons",
    Desc = "For Newbie (Click On That Button Of Lemon Stand, Lemon Dash)",
    Default = false,
    Callback = function(state)
        autoLemonsToggle = state
    end
})

local UpgradeSection = Tabs.Main:Section({
    Title = "Upgrade Lemons Stand",
    Box = true,
    BoxBorder = true,
    Expandable = true,
    Opened = true
})

UpgradeSection:Toggle({
    Title = "Auto Upgrade Lemons Stand",
    Desc = "Purchases Lemon upgrades automatically.",
    Default = false,
    Callback = function(state)
        autoUpgradeLemonToggle = state
    end
})

local UpgradeDropdown = UpgradeSection:Dropdown({
    Title = "Upgrade Lemon Targets",
    Multi = true,
    Values = {},
    Callback = function(values)
        upgradeTargetOptions = values
    end
})

UpgradeSection:Slider({
    Title = "Delay Between Each Upgrade",
    Step = 0.1,
    Value = {
        Min = 0.2,
        Max = 5.0,
        Default = 0.5,
    },
    Callback = function(value)
        upgradeLemonsDelay = value
    end
})

Tabs.Main:Toggle({
    Title = "Auto Buy Buttons",
    Desc = "Auto Purchase Those Click Buy Buttons When Money is Enough",
    Default = false,
    Callback = function(state)
        autoUpgradeButtonsToggle = state
    end
})

local availableUpgrades = {}
local availablePurchases = {}

task.spawn(function()
    while task.wait(5) do
        local ty = getMyTycoon()
        if ty and ty:FindFirstChild("Purchases") then
            local newFound = false
            local count = 0
            for _, desc in ipairs(ty.Purchases:GetDescendants()) do
                if desc:IsA("RemoteFunction") then
                    if desc.Name == "Upgrade" then
                        local pName = desc.Parent and desc.Parent.Name
                        if pName and not availableUpgrades[pName] then
                            availableUpgrades[pName] = desc
                            newFound = true
                        end
                    elseif desc.Name == "Purchase" then
                        if not availablePurchases[desc] then
                            availablePurchases[desc] = true
                        end
                    end
                end
                count = count + 1
                if count % 100 == 0 then task.wait() end
            end
            
            -- Cleanup destroyed purchases
            for desc, _ in pairs(availablePurchases) do
                if not desc.Parent or not desc:IsDescendantOf(ty) then
                    availablePurchases[desc] = nil
                end
            end
            
            if newFound and UpgradeDropdown then
                local opts = {}
                for k, _ in pairs(availableUpgrades) do
                    table.insert(opts, k)
                end
                UpgradeDropdown:Refresh(opts)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if autoLemonsToggle then
            local ty = getMyTycoon()
            if ty and ty:FindFirstChild("Remotes") and ty.Remotes:FindFirstChild("WakeIncomeStream") then
                local wakeRemote = ty.Remotes.WakeIncomeStream
                pcall(function() wakeRemote:InvokeServer("LemonStand") end)
                pcall(function() wakeRemote:InvokeServer("LemonDash") end)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if autoUpgradeLemonToggle then
            local ty = getMyTycoon()
            if ty then
                for pName, remoteFunc in pairs(availableUpgrades) do
                    if hasSelection(upgradeTargetOptions, pName) then
                        pcall(function() remoteFunc:InvokeServer(1) end)
                    end
                end
            end
            task.wait(upgradeLemonsDelay)
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if autoUpgradeButtonsToggle then
            local ty = getMyTycoon()
            if ty and ty:FindFirstChild("Purchases") then
                local currentCash = getPlayerCash()
                for desc, isValid in pairs(availablePurchases) do
                    if isValid and desc.Parent and desc:IsDescendantOf(workspace) then
                        local buttonFolder = desc.Parent
                        local btn = buttonFolder:FindFirstChild("Button")
                        local gui = btn and btn:FindFirstChild("Gui")
                        local priceLabel = gui and gui:FindFirstChild("Price")
                        local priceMagLabel = gui and gui:FindFirstChild("PriceMag")
                        
                        if priceLabel and (priceLabel:IsA("TextLabel") or priceLabel:IsA("TextBox")) then
                            local text = priceLabel.Text
                            if text:match("%d") then 
                                local pMag = ""
                                if priceMagLabel and (priceMagLabel:IsA("TextLabel") or priceMagLabel:IsA("TextBox")) then
                                    pMag = priceMagLabel.Text
                                end
                                
                                local combinedText = text .. " " .. pMag
                                local priceVal = parseToNum(combinedText)
                                
                                if priceVal > 0 and currentCash >= priceVal then
                                    pcall(function() desc:InvokeServer(false) end)
                                    task.wait(0.01)
                                end
                            end
                        end
                    else
                        availablePurchases[desc] = nil
                    end
                end
            end
        end
    end
end)

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
