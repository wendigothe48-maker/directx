-- fluent code converted to wind ui
-- [[ KEY SYSTEM LOADER ]] --
local KeySystem = loadstring(game:HttpGet("https://raw.githubusercontent.com/wendigo5414-cmyk/scripts/refs/heads/main/keysystem.lua"))()
KeySystem.Init()

-- [[ GAME SCRIPT START ]] --
local cloneref = (cloneref or clonereference or function(instance) return instance end)
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

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
--              MAIN SKELETON CODE
-- ══════════════════════════════════════════

local suffixes = {
    K = 1e3,
    M = 1e6,
    B = 1e9,
    T = 1e12,
    Q = 1e15,
    Qn = 1e18,
    Sx = 1e21,
    Sp = 1e24,
    O = 1e27,
    N = 1e30,
    D = 1e33
}

local function ParseSuffixNumber(str)
    if not str then return 0 end
    -- Upper case the input to handle 'k', 'm', 'q' etc.
    str = string.upper(tostring(str))
    str = string.gsub(str, "[^%d%.A-Z]", "") -- Keep only digits, dots, and letters
    local numberPart, suffixPart = string.match(str, "^([%d%.]+)([A-Z]*)$")
    
    if numberPart then
        local num = tonumber(numberPart)
        if num then
            if suffixPart and suffixes[suffixPart] then
                return num * suffixes[suffixPart]
            elseif suffixPart == "" then
                return num
            end
        end
    end
    return tonumber(str) or 0
end

local function getPlayerCash()
    local cashObj = LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Cash")
    if cashObj then
        local valueStr = tostring(cashObj.Value)
        return ParseSuffixNumber(valueStr)
    end
    return 0
end

local function getMyPlot()
    local basesFolder = workspace:FindFirstChild("Bases")
    if not basesFolder then return nil end
    for _, base in ipairs(basesFolder:GetChildren()) do
        local textLabel = base:FindFirstChild("NameTagModel")
            and base.NameTagModel:FindFirstChild("NameTag")
            and base.NameTagModel.NameTag:FindFirstChild("SurfaceGui")
            and base.NameTagModel.NameTag.SurfaceGui:FindFirstChild("Main")
            and base.NameTagModel.NameTag.SurfaceGui.Main:FindFirstChild("TextLabel")
        
        if textLabel and textLabel.Text then
            local playerName = string.match(textLabel.Text, "^(.-)'s")
            if playerName and (playerName == LocalPlayer.Name or playerName == LocalPlayer.DisplayName) then
                return base
            elseif string.find(textLabel.Text, LocalPlayer.Name) or string.find(textLabel.Text, LocalPlayer.DisplayName) then
                return base
            end
        end
    end
    return nil
end

local hammerAuraEnabled = false
Tabs.Main:Toggle({
    Title = "Hammer Aura",
    Desc = "Equip hammer to use it",
    Value = false,
    Callback = function(Value)
        hammerAuraEnabled = Value
        if Value then
            task.spawn(function()
                while hammerAuraEnabled do
                    pcall(function()
                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local eggRenderModels = workspace:FindFirstChild("EggRenderModels")
                        if hrp and eggRenderModels then
                            local eggsToHit = {}
                            for _, eggModel in ipairs(eggRenderModels:GetChildren()) do
                                local hitbox = eggModel:FindFirstChild("Hitbox")
                                if hitbox then
                                    local dist = (hrp.Position - hitbox.Position).Magnitude
                                    if dist <= 20 then
                                        table.insert(eggsToHit, eggModel.Name)
                                    end
                                end
                            end
                            
                            if #eggsToHit > 0 then
                                game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("EggSpawnerService"):WaitForChild("RF"):WaitForChild("RequestHitEgg"):InvokeServer(eggsToHit)
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

local autoRebirthEnabled = false
Tabs.Main:Toggle({
    Title = "Auto Rebirth",
    Value = false,
    Callback = function(Value)
        autoRebirthEnabled = Value
        if Value then
            task.spawn(function()
                while autoRebirthEnabled do
                    pcall(function()
                        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                        local progressBar = playerGui and playerGui:FindFirstChild("Rebirth") 
                            and playerGui.Rebirth:FindFirstChild("Container")
                            and playerGui.Rebirth.Container:FindFirstChild("Main")
                            and playerGui.Rebirth.Container.Main:FindFirstChild("Rebirth")
                            and playerGui.Rebirth.Container.Main.Rebirth:FindFirstChild("Content")
                            and playerGui.Rebirth.Container.Main.Rebirth.Content:FindFirstChild("Body")
                            and playerGui.Rebirth.Container.Main.Rebirth.Content.Body:FindFirstChild("BodyContent")
                            and playerGui.Rebirth.Container.Main.Rebirth.Content.Body.BodyContent:FindFirstChild("RequirementsContainer")
                            and playerGui.Rebirth.Container.Main.Rebirth.Content.Body.BodyContent.RequirementsContainer:FindFirstChild("Bar")
                            and playerGui.Rebirth.Container.Main.Rebirth.Content.Body.BodyContent.RequirementsContainer.Bar:FindFirstChild("Content")
                            and playerGui.Rebirth.Container.Main.Rebirth.Content.Body.BodyContent.RequirementsContainer.Bar.Content:FindFirstChild("Progress")
                        
                        if progressBar and progressBar.Size.X.Scale >= 1 then
                            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("RebirthService"):WaitForChild("RF"):WaitForChild("RequestRebirth"):InvokeServer()
                            task.wait(2) -- Wait after rebirthing
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    end
})

local autoCollectEnabled = false
Tabs.Main:Toggle({
    Title = "Auto Collect Cash",
    Value = false,
    Callback = function(Value)
        autoCollectEnabled = Value
        if Value then
            task.spawn(function()
                while autoCollectEnabled do
                    pcall(function()
                        local plot = getMyPlot()
                        if plot then
                            for _, floor in ipairs(plot:GetChildren()) do
                                if string.match(floor.Name, "^Floor_") then
                                    local platforms = floor:FindFirstChild("Platforms")
                                    if platforms then
                                        for _, platform in ipairs(platforms:GetChildren()) do
                                            if not autoCollectEnabled then return end
                                            local stand = platform:FindFirstChild("Stand")
                                            local att = stand and stand:FindFirstChild("Attachment")
                                            if att and att:FindFirstChild("RenderModel") then
                                                local platformNumber = tonumber(string.match(platform.Name, "(%d+)"))
                                                if platformNumber then
                                                    local args = { platformNumber }
                                                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BaseService"):WaitForChild("RF"):WaitForChild("RequestPlatformCollect"):InvokeServer(unpack(args))
                                                    task.wait(0.05)
                                                end
                                            end
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

local autoBuyEnabled = false
Tabs.Main:Toggle({
    Title = "Auto Buy Hammer",
    Value = false,
    Callback = function(Value)
        autoBuyEnabled = Value
        if Value then
            task.spawn(function()
                while autoBuyEnabled do
                    pcall(function()
                        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                        local bodyFrame = playerGui 
                            and playerGui:FindFirstChild("HammerShop")
                            and playerGui.HammerShop:FindFirstChild("Container")
                            and playerGui.HammerShop.Container:FindFirstChild("Main")
                            and playerGui.HammerShop.Container.Main:FindFirstChild("Shop")
                            and playerGui.HammerShop.Container.Main.Shop:FindFirstChild("Content")
                            and playerGui.HammerShop.Container.Main.Shop.Content:FindFirstChild("Body")
                            and playerGui.HammerShop.Container.Main.Shop.Content.Body:FindFirstChild("Entries")
                            and playerGui.HammerShop.Container.Main.Shop.Content.Body.Entries:FindFirstChild("BodyFrame")
                        
                        if bodyFrame then
                            local items = {}
                            for _, child in ipairs(bodyFrame:GetChildren()) do
                                local num = tonumber(string.match(child.Name, "^i(%d+)$"))
                                if num then
                                    table.insert(items, {instance = child, num = num})
                                end
                            end
                            table.sort(items, function(a, b) return a.num > b.num end)
                            
                            for _, itemData in ipairs(items) do
                                local item = itemData.instance
                                local numStr = item.Name
                                local button = item:FindFirstChild("Button")
                                if button then
                                    local isEquipped = false
                                    local isPurchased = false
                                    local cost = nil
                                    
                                    for _, v in ipairs(button:GetDescendants()) do
                                        if v:IsA("TextLabel") and v.Text then
                                            local text = string.lower(string.match(v.Text, "^%s*(.-)%s*$") or v.Text)
                                            if text == "equipped" then
                                                isEquipped = true
                                                isPurchased = true
                                            elseif text == "equip" then
                                                isPurchased = true
                                            elseif string.find(v.Text, "%$") then
                                                cost = ParseSuffixNumber(v.Text)
                                            end
                                        end
                                    end
                                    
                                    if isEquipped then
                                        print("[Prime X Hub | Auto Best Buy Shop] Best affordable item (" .. numStr .. ") is already equipped. Ignoring.")
                                        break
                                    elseif isPurchased then
                                        print("[Prime X Hub | Auto Best Buy Shop] Best owned item (" .. numStr .. ") is not equipped. Equipping.")
                                        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("HammerShopService"):WaitForChild("RF"):WaitForChild("EquipHammer"):InvokeServer(numStr)
                                        task.wait(0.5)
                                        break
                                    elseif cost and getPlayerCash() >= cost then
                                        print("[Prime X Hub | Auto Best Buy Shop] Best affordable item (" .. numStr .. ") is not owned. Purchasing for $" .. tostring(cost) .. ".")
                                        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("HammerShopService"):WaitForChild("RF"):WaitForChild("PurchaseHammer"):InvokeServer(numStr)
                                        task.wait(0.5)
                                        break
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

local autoSwingHitEnabled = false
Tabs.Main:Toggle({
    Title = "Auto Swing Hit",
    Value = false,
    Callback = function(Value)
        autoSwingHitEnabled = Value
        if Value then
            task.spawn(function()
                while autoSwingHitEnabled do
                    pcall(function()
                        local playerIds = {}
                        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                            if player.UserId ~= LocalPlayer.UserId then
                                table.insert(playerIds, player.UserId)
                            end
                        end
                        
                        if #playerIds > 0 then
                            local args1 = {
                                "SwingHit",
                                "i10:0",
                                playerIds
                            }
                            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ToolInteractionService"):WaitForChild("RF"):WaitForChild("RequestInteraction"):InvokeServer(unpack(args1))
                            
                            local args2 = {
                                "SlapHit",
                                "i1:1",
                                playerIds
                            }
                            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ToolInteractionService"):WaitForChild("RF"):WaitForChild("RequestInteraction"):InvokeServer(unpack(args2))
                        end
                    end)
                    task.wait(0.1)
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
