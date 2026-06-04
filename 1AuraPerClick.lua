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
local lastW1Log = 0

Tabs.Main:Toggle({
    Title = "Farm Best World 1",
    Callback = function(val)
        autoFarmW1 = val
        if val then
            print("[AutoFarm W1] Started...")
            task.spawn(function()
                while autoFarmW1 do
                    pcall(function()
                        local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local stage25 = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Stage_25")
                            local winModel = stage25 and stage25:FindFirstChild("Win")
                            
                            local shouldLog = (os.clock() - lastW1Log) > 1.0
                            if shouldLog then lastW1Log = os.clock() end
                            
                            if not winModel then
                                if shouldLog then print("[AutoFarm W1] 'Win' model not found in Stage_25. Teleporting user to (-3484, 55, 2) to load...") end
                                hrp.CFrame = CFrame.new(-3484, 55, 2)
                                task.wait(0.5) -- Wait to load region
                                stage25 = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Stage_25")
                                winModel = stage25 and stage25:FindFirstChild("Win")
                            end
                            
                            if winModel then
                                if shouldLog then print("[AutoFarm W1] 'Win' model found! Changing CFrame to (-9, 26, 2)") end
                                pcall(function() winModel:PivotTo(CFrame.new(-9, 26, 2)) end)
                                
                                if shouldLog then print("[AutoFarm W1] Teleporting player safely to new Win model Location (-9, 26, 2)") end
                                hrp.CFrame = CFrame.new(-9, 26, 2)
                                
                                local winPart = winModel:FindFirstChild("WinPart")
                                local touchInterest = winPart and winPart:FindFirstChild("TouchInterest")
                                
                                if touchInterest then
                                    if isMobile then
                                        if shouldLog then print("[AutoFarm W1] Firing TouchInterest for MOBILE (0 then 1)") end
                                        firetouchinterest(winPart, hrp, 0)
                                        task.wait(0.01)
                                        firetouchinterest(winPart, hrp, 1)
                                    else
                                        if shouldLog then print("[AutoFarm W1] Firing TouchInterest for PC (0 Only)") end
                                        firetouchinterest(winPart, hrp, 0)
                                    end
                                else
                                    if shouldLog then print("[AutoFarm W1] ERROR: TouchInterest missing inside WinPart!") end
                                end
                            else
                                if shouldLog then print("[AutoFarm W1] FAIL: Could not load Win model even after attempting teleport!") end
                            end
                        end
                    end)
                    task.wait(0.1)
                end
                print("[AutoFarm W1] Stopped.")
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
Tabs.Main:Toggle({
    Title = "Auto Equip 2.5M Click",
    Callback = function(val)
        autoEquip25M = val
        if val then
            task.spawn(function()
                while autoEquip25M do
                    pcall(function()
                        local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local lobby = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Lobby")
                            local upgradePart = lobby and lobby:FindFirstChild("Utility") and lobby.Utility:FindFirstChild("Upgrades") and lobby.Utility.Upgrades:FindFirstChild("50000000000") and lobby.Utility.Upgrades["50000000000"]:FindFirstChild("touch")
                            local touchInterest = upgradePart and upgradePart:FindFirstChild("TouchInterest")
                            
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
                    end)
                    task.wait(1)
                end
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
