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

-- ══════════════════════════════════════════
--              MAIN SCRIPT FEATURES
-- ══════════════════════════════════════════

local function ParseNum(str)
    local cleaned = string.gsub(tostring(str), ",", "")
    if NumberConverter and NumberConverter.Parse then
        return NumberConverter.Parse(cleaned)
    else
        return tonumber((string.match(cleaned, "[%d%.]+"))) or 0
    end
end

local AutoSection = Tabs.Main:Section({
    Title = "Auto Boxed",
    Box = true,
    BoxBorder = true,
    Opened = true
})

local autoRebirth = false
AutoSection:Toggle({
    Title = "Auto Rebirth",
    Callback = function(val)
        autoRebirth = val
    end
})

task.spawn(function()
    while task.wait(1) do
        if autoRebirth then
            pcall(function()
                local textLabel = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.MainFrames.Rebirth.ProgressBar.TextLabel
                local text = textLabel.Text
                local v1, v2 = string.match(text, "([%d%.,]+[A-Za-z]*)%s*/%s*([%d%.,]+[A-Za-z]*)")
                if v1 and v2 then
                    local num1 = ParseNum(v1)
                    local num2 = ParseNum(v2)
                    if num1 >= num2 then
                        game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("RemoteEventService"):WaitForChild("RebirthRemoteEvent"):FireServer()
                    end
                end
            end)
        end
    end
end)

local autoEvolve = false
AutoSection:Toggle({
    Title = "Auto Evolve",
    Callback = function(val)
        autoEvolve = val
    end
})

task.spawn(function()
    while task.wait(1) do
        if autoEvolve then
            pcall(function()
                local winsLabel = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.MainFrames.Evolve.WinsCostLabel
                local pgbLabel = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.MainFrames.Evolve.ProgressBar.TextLabel
                
                local w1, w2 = string.match(winsLabel.Text, "([%d%.,]+[A-Za-z]*)%s*/%s*([%d%.,]+[A-Za-z]*)")
                local p1, p2 = string.match(pgbLabel.Text, "([%d%.,]+[A-Za-z]*)%s*/%s*([%d%.,]+[A-Za-z]*)")
                
                local canEvolve = false
                if w1 and w2 and p1 and p2 then
                    local nw1 = ParseNum(w1)
                    local nw2 = ParseNum(w2)
                    local np1 = ParseNum(p1)
                    local np2 = ParseNum(p2)
                    
                    if nw1 >= nw2 and np1 >= np2 then
                        canEvolve = true
                    end
                end
                
                if canEvolve then
                    local args = { { Action = "Evolve" } }
                    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("RemoteEventService"):WaitForChild("EvolutionRemoteEvent"):FireServer(unpack(args))
                end
            end)
        end
    end
end)

local autoAddSpeed = false
AutoSection:Toggle({
    Title = "Auto +X Speed",
    Callback = function(val)
        autoAddSpeed = val
    end
})

task.spawn(function()
    while true do
        if autoAddSpeed then
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("RemoteEventService"):WaitForChild("AddSpeedRemoteEvent"):FireServer()
            end)
            task.wait(0.02)
        else
            task.wait(0.2)
        end
    end
end)

local isMobile = game:GetService("UserInputService").TouchEnabled

local autoEquipBestSpeed = false
Tabs.Main:Toggle({
    Title = "Auto Equip Best Step Upgrade",
    Callback = function(val)
        autoEquipBestSpeed = val
    end
})

task.spawn(function()
    while task.wait(1) do
        if autoEquipBestSpeed then
            pcall(function()
                local char = game.Players.LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                
                local upgradeButtons = workspace:FindFirstChild("UpgradeButtons")
                if not upgradeButtons then return end
                
                local winsObj = game.Players.LocalPlayer:FindFirstChild("leaderstats") and game.Players.LocalPlayer.leaderstats:FindFirstChild("Wins")
                local myWins = 0
                if winsObj then
                    myWins = ParseNum(winsObj.Value)
                end
                
                local buttons = {}
                for _, btn in ipairs(upgradeButtons:GetChildren()) do
                    local num = tonumber(btn.Name)
                    local touchPart = btn:FindFirstChild("Touch")
                    if num and touchPart and touchPart:FindFirstChild("TouchInterest") then
                        table.insert(buttons, {num = num, part = btn, touchPart = touchPart})
                    end
                end
                
                table.sort(buttons, function(a, b) return a.num < b.num end)
                
                local targetAction = nil

                for _, data in ipairs(buttons) do
                    local touchPart = data.touchPart
                    local color = touchPart.Color
                    local r, g, b = math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5)
                    
                    if r >= 200 and g >= 200 and b <= 50 then
                        -- Yellow: Owned
                        targetAction = touchPart
                    elseif r <= 50 and g >= 200 and b <= 50 then
                        -- Green: Equipped
                        targetAction = nil -- Clears previous yellow because we are already equipped at a higher level
                    elseif r >= 200 and g <= 50 and b <= 50 then
                        -- Red: Unowned
                        local bbGui = touchPart:FindFirstChild("BillboardGui")
                        local winsCostLabel = bbGui and bbGui:FindFirstChild("WinsCostLabel")
                        if winsCostLabel then
                            local costText = string.match(winsCostLabel.Text, "([%d%.,]+[A-Za-z]*)")
                            if costText then
                                local cost = ParseNum(costText)
                                if myWins >= cost then
                                    targetAction = touchPart
                                end
                            end
                        end
                        break -- Always break on the first Red (unowned) step. Either we buy it, or we don't buy anything higher.
                    end
                end
                
                if targetAction then
                    firetouchinterest(targetAction, hrp, 0)
                    if isMobile then
                        task.wait(0.01)
                        firetouchinterest(targetAction, hrp, 1)
                    end
                end
            end)
        end
    end
end)

local autoFarmWinsW1 = false
Tabs.Main:Toggle({
    Title = "Auto Farm Wins (World 1)",
    Callback = function(val)
        autoFarmWinsW1 = val
    end
})

task.spawn(function()
    while task.wait(0.1) do
        if autoFarmWinsW1 then
            pcall(function()
                local char = game.Players.LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                local win14 = workspace:FindFirstChild("Wins") and workspace.Wins:FindFirstChild("14")
                local touchPart = win14 and win14:FindFirstChild("Touch")

                if not touchPart or not touchPart:FindFirstChild("TouchInterest") then
                    print("[Auto Farm Wins] TouchPart or TouchInterest missing. Teleporting to 8026, 210, 472 to load...")
                    hrp.CFrame = CFrame.new(8026, 210, 472)
                    task.wait(4)
                    
                    win14 = workspace:FindFirstChild("Wins") and workspace.Wins:FindFirstChild("14")
                    touchPart = win14 and win14:FindFirstChild("Touch")
                    
                    if touchPart then
                        print("[Auto Farm Wins] TouchPart loaded! Moving it to -101, 32, 43")
                        touchPart.CFrame = CFrame.new(-101, 32, 43)
                    else
                        print("[Auto Farm Wins] Failed to load TouchPart after 4 seconds.")
                    end
                end
                
                if touchPart and touchPart:FindFirstChild("TouchInterest") then
                    firetouchinterest(touchPart, hrp, 0)
                    if isMobile then
                        task.wait(0.01)
                        firetouchinterest(touchPart, hrp, 1)
                    end
                end
            end)
        end
    end
end)

local autoBuyBestTrail = false
Tabs.Main:Toggle({
    Title = "Auto Buy Best Trail",
    Callback = function(val)
        autoBuyBestTrail = val
    end
})

task.spawn(function()
    while task.wait(1) do
        if autoBuyBestTrail then
            pcall(function()
                local lp = game.Players.LocalPlayer
                local trailsMenu = lp.PlayerGui:FindFirstChild("ScreenGui")
                    and lp.PlayerGui.ScreenGui:FindFirstChild("MainFrames")
                    and lp.PlayerGui.ScreenGui.MainFrames:FindFirstChild("Trails")
                    and lp.PlayerGui.ScreenGui.MainFrames.Trails:FindFirstChild("ScrollingFrame")
                
                if not trailsMenu then return end
                
                local winsObj = lp:FindFirstChild("leaderstats") and lp.leaderstats:FindFirstChild("Wins")
                local myWins = 0
                if winsObj then
                    myWins = ParseNum(tostring(winsObj.Value))
                end
                
                local trails = {}
                for _, child in ipairs(trailsMenu:GetChildren()) do
                    if child:IsA("Frame") and child:FindFirstChild("MultiplierLabel") and child:FindFirstChild("WinsButton") and child:FindFirstChild("EquipButton") then
                        local multText = child.MultiplierLabel.Text
                        local mult = tonumber(string.match(multText, "([%d%.]+)")) or 0
                        
                        local winsBtn = child.WinsButton
                        local winsTextLabel = winsBtn:FindFirstChild("TextLabel") or winsBtn:FindFirstChildWhichIsA("TextLabel")
                        local costText = winsTextLabel and string.match(winsTextLabel.Text, "([%d%.,]+[A-Za-z]*)") or "0"
                        local cost = ParseNum(costText)
                        
                        table.insert(trails, {
                            name = child.Name,
                            mult = mult,
                            cost = cost,
                            winsBtn = winsBtn,
                            equipBtn = child.EquipButton
                        })
                    end
                end
                
                table.sort(trails, function(a, b) return a.mult > b.mult end)
                
                for _, trail in ipairs(trails) do
                    if trail.winsBtn.Visible then
                        if myWins >= trail.cost then
                            local args = {{ Action = "Buy", TrailName = trail.name }}
                            game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("RemoteEventService"):WaitForChild("TrailRemoteEvent"):FireServer(unpack(args))
                            task.wait(0.2)
                            break
                        end
                    elseif trail.equipBtn.Visible then
                        local equipLabel = trail.equipBtn:FindFirstChild("TextLabel") or trail.equipBtn:FindFirstChildWhichIsA("TextLabel")
                        local eText = equipLabel and equipLabel.Text or ""
                        if string.find(string.lower(eText), "un") then
                            -- Already equipped
                            break
                        else
                            -- Equip it
                            local args = {{ Action = "Equip", TrailName = trail.name }}
                            game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("RemoteEventService"):WaitForChild("TrailRemoteEvent"):FireServer(unpack(args))
                            task.wait(0.2)
                            break
                        end
                    end
                end
            end)
        end
    end
end)

WindUI:Notify({
    Title = "Prime X Hub",
    Content = "Script loaded successfully!",
    Duration = 5
})
