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

local autoClick = false
Tabs.Main:Toggle({
    Title = "Auto Click",
    Callback = function(val)
        autoClick = val
        if val then
            task.spawn(function()
                while autoClick do
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("AuraRunnerTrainClick"):FireServer({})
                    end)
                    task.wait(0.01)
                end
            end)
        end
    end
})
local autoFarmW1 = false
local isMobile = game:GetService("UserInputService").TouchEnabled

-- [[ STRICT DOUBLE-VERIFICATION SCANNER ]] --
local function getTargetWinModel()
    local map = workspace:FindFirstChild("Map")
    local stage25 = map and map:FindFirstChild("Stage_25")
    if not stage25 then return nil, nil end
    
    local allChildren = stage25:GetChildren()
    
    for idx, child in ipairs(allChildren) do
        if child.Name == "Win" then
            
            -- CONDITION 1: Pehle check karo kya is 'Win' model me hamara 50B wala text hai?
            local hasTargetText = false
            local descendants = child:GetDescendants()
            
            for _, desc in ipairs(descendants) do
                local success, txt = pcall(function() return desc.Text end)
                if success and type(txt) == "string" and txt ~= "" then
                    local cleanTxt = string.lower(txt):gsub("%s+", "")
                    if string.find(cleanTxt, "50b") or string.find(cleanTxt, "50w") or string.find(cleanTxt, "+50b") then
                        hasTargetText = true
                        break -- Text mil gaya, ab part dhoondna shuru karenge
                    end
                end
            end
            
            -- CONDITION 2: Agar text mil gaya hai, toh USI model ke andar se TouchInterest wala sahi part nikaalo
            if hasTargetText then
                local realWinPart = nil
                
                for _, desc in ipairs(descendants) do
                    -- Part ka naam WinPart hona chahiye AUR uske andar TouchInterest hona ZAROORI hai
                    if desc.Name == "WinPart" and desc:IsA("BasePart") and desc:FindFirstChild("TouchInterest") then
                        realWinPart = desc
                        break
                    end
                end
                
                -- Backup Check: Agar naam 'WinPart' nahi bhi hai par usme TouchInterest hai (just in case)
                if not realWinPart then
                    for _, desc in ipairs(descendants) do
                        if desc:IsA("BasePart") and desc:FindFirstChild("TouchInterest") then
                            realWinPart = desc
                            break
                        end
                    end
                end
                
                -- Agar text bhi mil gaya aur sahi TouchInterest wala part bhi mil gaya, tabhi lock karenge!
                if realWinPart then
                    print(string.format("[AutoFarm W1] [TARGET LOCKED] Sahi Text aur Asli TouchInterest wala Part dono mil gaye! Index: [%d], Part Name: '%s'", idx, realWinPart.Name))
                    return child, realWinPart
                else
                    print(string.format("[AutoFarm W1] [WARNING] Index [%d] me text toh mila, par bina TouchInterest wala dummy part tha. Skipping...", idx))
                end
            end
            
        end
    end
    return nil, nil
end

Tabs.Main:Toggle({
    Title = "Farm Best World 1",
    Callback = function(val)
        autoFarmW1 = val
        if val then
            print("[AutoFarm W1] Toggle ON. Double-Verification Mode Active.")
            task.spawn(function()
                local lockedModel = nil
                local lockedPart = nil
                local lastLogTime = 0
                
                while autoFarmW1 do
                    pcall(function()
                        local player = game.Players.LocalPlayer
                        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        
                        if hrp then
                            -- [[ STEP 1: VERIFY LOCKED TARGET ]] --
                            -- Agar pehle se locked hai toh check karo ki wo sahi hai aur abhi bhi game me maujood hai
                            if lockedModel and lockedModel:IsDescendantOf(workspace) and lockedPart and lockedPart:IsDescendantOf(workspace) and lockedPart:FindFirstChild("TouchInterest") then
                                local distance = (hrp.Position - lockedPart.Position).Magnitude
                                
                                -- BYPASS: Agar sahi part paas me hai toh direct spam bina TP ke
                                if distance < 15 then
                                    local touchInterest = lockedPart:FindFirstChild("TouchInterest")
                                    if touchInterest then
                                        if isMobile then
                                            firetouchinterest(lockedPart, hrp, 0)
                                            task.wait(0.01)
                                            firetouchinterest(lockedPart, hrp, 1)
                                        else
                                            firetouchinterest(lockedPart, hrp, 0)
                                        end
                                    end
                                    return 
                                end
                            else
                                -- Agar lock toot gaya ya dummy tha, toh reset karo
                                lockedModel, lockedPart = nil, nil
                            end
                            
                            -- [[ STEP 2: SCANNING WITH STRICT RULES ]] --
                            lockedModel, lockedPart = getTargetWinModel()
                            
                            -- Agar nahi mila, toh loading area lekar jao taaki map load ho
                            if not lockedModel then
                                if os.clock() - lastLogTime > 2 then
                                    print("[AutoFarm W1] Asli TouchInterest wala 50B part nahi mila. Loading area (-3484, 55, 2) jaa rahe hain...")
                                    lastLogTime = os.clock()
                                end
                                hrp.CFrame = CFrame.new(-3484, 55, 2)
                                task.wait(0.5)
                                
                                lockedModel, lockedPart = getTargetWinModel()
                            end
                            
                            -- [[ STEP 3: TELEPORT & SPAM REAL PART ]] --
                            if lockedModel and lockedPart then
                                -- Ab sirf wahi part TP hoga jiske andar TouchInterest humne step 1 me verify kiya hai
                                pcall(function()
                                    lockedPart.CFrame = CFrame.new(-9, 26, 2)
                                end)
                                
                                hrp.CFrame = CFrame.new(-9, 26, 2)
                                task.wait(0.02)
                                
                                local touchInterest = lockedPart:FindFirstChild("TouchInterest")
                                if touchInterest then
                                    if isMobile then
                                        firetouchinterest(lockedPart, hrp, 0)
                                        task.wait(0.01)
                                        firetouchinterest(lockedPart, hrp, 1)
                                    else
                                        firetouchinterest(lockedPart, hrp, 0)
                                    end
                                end
                            end
                            
                        end
                    end)
                    task.wait(0.02)
                end
                print("[AutoFarm W1] Toggle OFF. Loop Closed.")
            end)
        end
    end
})
local autoEgg = false
Tabs.Main:Toggle({
    Title = "Auto Egg Hatch (500K)",
    Callback = function(val)
        autoEgg = val
        if val then
            task.spawn(function()
                while autoEgg do
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("AuraRunnerHatchEgg"):InvokeServer({ eggModelName = "8" })
                    end)
                    task.wait(0.2)
                end
            end)
        end
    end
})

local autoRebirth = false
Tabs.Main:Toggle({
    Title = "Auto Rebirth",
    Callback = function(val)
        autoRebirth = val
        if val then
            task.spawn(function()
                while autoRebirth do
                    pcall(function()
                        local progress = game:GetService("Players").LocalPlayer.PlayerGui.UI.Rebirth.Frame.ProgressBar:FindFirstChild("Progress")
                        if progress and progress.Size.X.Scale >= 1 then
                            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("AuraRunnerRebirth"):InvokeServer({})
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    end
})


local autoEquip25M = false
local isMobile = game:GetService("UserInputService").TouchEnabled

Tabs.Main:Toggle({
    Title = "Auto Equip 2.5M Click",
    Callback = function(val)
        autoEquip25M = val
        if val then
            print("[Auto Equip 2.5M] Toggle ON. Smart Color Detection Active.")
            task.spawn(function()
                while autoEquip25M do
                    pcall(function()
                        local player = game.Players.LocalPlayer
                        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        
                        if hrp then
                            -- Path to the upgrade part safely
                            local map = workspace:FindFirstChild("Map")
                            local lobby = map and map:FindFirstChild("Lobby")
                            local utility = lobby and lobby:FindFirstChild("Utility")
                            local upgrades = utility and utility:FindFirstChild("Upgrades")
                            local targetUpgrade = upgrades and upgrades:FindFirstChild("50000000000")
                            local upgradePart = targetUpgrade and targetUpgrade:FindFirstChild("touch")
                            
                            if upgradePart then
                                local currColor = upgradePart.Color
                                
                                -- Color checking logic:
                                -- Yellow target (255, 242, 0) -> R near 1, G near 0.94, B near 0
                                local isYellow = (currColor.R > 0.95 and currColor.G > 0.90 and currColor.B < 0.1)
                                
                                if isYellow then
                                    -- [SAFE MODE] Agar color already Yellow (255,242,0) hai, toh TP nahi karega
                                    -- Taaki aapka baaki farm smoothly chalta rahe
                                end
                                
                                if not isYellow then
                                    -- [TP MODE] Agar color change hua (jaise 102, 118, 30 hua), toh jab tak yellow nahi hota tab tak TP karega
                                    print("[Auto Equip 2.5M] Upgrade available! Teleporting to touch part...")
                                    
                                    -- Directly part ke upar CFrame set karo thoda sa offset dekar
                                    hrp.CFrame = upgradePart.CFrame + Vector3.new(0, 2, 0)
                                    
                                    -- TouchInterest backup fire taaki instant buy ho jaye
                                    local touchInterest = upgradePart:FindFirstChild("TouchInterest")
                                    if touchInterest then
                                        if isMobile then
                                            firetouchinterest(upgradePart, hrp, 0)
                                            task.wait(0.01)
                                            firetouchinterest(upgradePart, hrp, 1)
                                        else
                                            firetouchinterest(upgradePart, hrp, 0)
                                        end
                                    end
                                end
                            else
                                print("[Auto Equip 2.5M] Upgrade 'touch' part nahi mila workspace me!")
                            end
                        end
                    end)
                    -- Responsive checking speed (har 0.1 second me check karega color ko)
                    task.wait(0.1)
                end
                print("[Auto Equip 2.5M] Toggle OFF. Loop Closed.")
            end)
        end
    end
})

local PetsSection = Tabs.Main:Section({ 
    Title = "Pets Management", 
    Box = true, 
    BoxBorder = true, 
    Opened = true 
})

local function scanPets()
    local counts = {}
    local knownNames = {}
    local petData = {}
    
    pcall(function()
        local UI = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("UI")
        if not (UI and UI:FindFirstChild("Pets")) then return end
        local petsFrame = UI.Pets.Frame.Pets
        
        local index = 0
        for _, child in ipairs(petsFrame:GetChildren()) do
            index = index + 1
            if child.Name == "Pet" then
                local icon = child:FindFirstChild("Icon")
                if icon then
                    local vp = icon:FindFirstChild("AuraRunnerViewport")
                    local wm = vp and vp:FindFirstChild("AuraRunnerWorldModel")
                    local vpm = wm and wm:FindFirstChild("AuraRunnerViewportModel")
                    if vpm then
                        for _, petModel in ipairs(vpm:GetChildren()) do
                            if petModel:IsA("Model") or petModel:IsA("BasePart") then
                                local pName = petModel.Name
                                counts[pName] = (counts[pName] or 0) + 1
                                
                                local cleanName = pName:gsub("^Shiny ", "")
                                knownNames[cleanName] = true
                                knownNames["Shiny " .. cleanName] = true
                                
                                table.insert(petData, {
                                    name = pName,
                                    copyIndex = index,
                                    frame = child
                                })
                                break
                            end
                        end
                    end
                end
            end
        end
    end)
    return counts, knownNames, petData
end

local autoShiny = false
PetsSection:Toggle({
    Title = "Auto Shiny Pet",
    Callback = function(val)
        autoShiny = val
        if val then
            task.spawn(function()
                while autoShiny do
                    local counts = scanPets()
                    for petName, count in pairs(counts) do
                        if count >= 5 then
                            pcall(function()
                                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("AuraRunnerUpdatePets"):InvokeServer({
                                    action = "make_shiny",
                                    petName = petName
                                })
                            end)
                        end
                    end
                    task.wait(4)
                end
            end)
        end
    end
})

local autoEquip = false
PetsSection:Toggle({
    Title = "Auto Equip Best",
    Callback = function(val)
        autoEquip = val
        if val then
            task.spawn(function()
                while autoEquip do
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("AuraRunnerUpdatePets"):InvokeServer({
                            action = "equip_best"
                        })
                    end)
                    task.wait(1)
                end
            end)
        end
    end
})

local autoDelete = false
local petsToDeleteDict = {}
local knownPetsList = {}

PetsSection:Toggle({
    Title = "Auto Delete Pet",
    Callback = function(val)
        autoDelete = val
        if val then
            task.spawn(function()
                while autoDelete do
                    pcall(function()
                        local _, _, petFrames = scanPets()
                        for _, petObj in ipairs(petFrames) do
                            if petsToDeleteDict[petObj.name] then
                                print("[AutoDelete] Attempting to delete pet:", petObj.name, "Index:", petObj.copyIndex)
                                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("AuraRunnerUpdatePets"):InvokeServer({
                                    petName = petObj.name,
                                    action = "delete",
                                    copyIndex = petObj.copyIndex
                                })
                            end
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    end
})

local DeleteDropdown = PetsSection:Dropdown({
    Title = "Select Pets to Delete",
    Values = {},
    Multi = true,
    Value = {},
    Callback = function(selected)
        petsToDeleteDict = {}
        for _, v in ipairs(selected) do
            petsToDeleteDict[v] = true
        end
    end
})

task.spawn(function()
    while task.wait(3) do
        local _, foundNames = scanPets()
        local changed = false
        for name, _ in pairs(foundNames) do
            if not table.find(knownPetsList, name) then
                table.insert(knownPetsList, name)
                changed = true
            end
        end
        if changed then
            local currentSelections = {}
            for k, _ in pairs(petsToDeleteDict) do
                table.insert(currentSelections, k)
            end
            DeleteDropdown:Refresh(knownPetsList)
            pcall(function() DeleteDropdown:Select(currentSelections) end)
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