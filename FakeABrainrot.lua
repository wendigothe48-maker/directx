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

local Suffixes = {"k", "m", "b", "t", "qa", "qi", "sx", "sp", "oc", "no", "dc", "ud", "dd", "td", "qd", "qid", "sxd", "spd", "ocd", "nod", "vg", "uvg"}
local NumberConverter = {}
function NumberConverter.Parse(str)
    if not str or str == "" then return 0 end
    str = string.lower(string.gsub(tostring(str), ",", ""))
    local num = tonumber(str)
    if num then return num end
    local val, suf = string.match(str, "^([%d%.]+)%s*([a-z]+)$")
    if val and suf then
        local base = tonumber(val)
        if base then
            for i, s in ipairs(Suffixes) do
                if s == suf then
                    return base * (10 ^ (i * 3))
                end
            end
        end
    end
    return 0
end

function NumberConverter.Format(num)
    if not num then return "0" end
    local absNum = math.abs(num)
    if absNum < 1000 then return tostring(math.floor(num)) end
    local tier = math.floor(math.log10(absNum) / 3)
    if tier == 0 then return tostring(math.floor(absNum)) end
    local suffix = Suffixes[tier]
    if not suffix then return string.format("%.2e", num) end
    local val = num / (10 ^ (tier * 3))
    local str = string.format("%.2f", val)
    str = string.gsub(str, "%.00$", "")
    local finalSuffix = string.len(suffix) == 1 and string.upper(suffix) or (string.upper(string.sub(suffix, 1, 1)) .. string.sub(suffix, 2))
    return str .. finalSuffix
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local BrainrotSection = Tabs.Main:Section({
    Title = "Brainrot",
    Box = true
})

local espFakeBrainrotEnabled = false
Tabs.Main:Toggle({
    Title = "ESP Fake Brainrot",
    Value = false,
    Callback = function(Value)
        espFakeBrainrotEnabled = Value
        if Value then
            task.spawn(function()
                while espFakeBrainrotEnabled do
                    pcall(function()
                        for _, child in ipairs(workspace:GetChildren()) do
                            local fakeBrainrot = child:FindFirstChild("FakeBrainrot")
                            if fakeBrainrot and fakeBrainrot:IsA("Model") then
                                local hl = fakeBrainrot:FindFirstChild("FakeBrainrotESP")
                                if not hl then
                                    hl = Instance.new("Highlight")
                                    hl.Name = "FakeBrainrotESP"
                                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                    hl.Parent = fakeBrainrot
                                end
                            end
                        end
                        -- cleanup
                        for _, desc in ipairs(workspace:GetDescendants()) do
                            if desc.Name == "FakeBrainrotESP" and desc:IsA("Highlight") then
                                local p = desc.Parent
                                if p and p.Name == "FakeBrainrot" and not espFakeBrainrotEnabled then
                                    desc:Destroy()
                                end
                            end
                        end
                    end)
                    task.wait(1)
                end
                
                for _, desc in ipairs(workspace:GetDescendants()) do
                    if desc.Name == "FakeBrainrotESP" and desc:IsA("Highlight") then
                        desc:Destroy()
                    end
                end
            end)
        end
    end
})

local function getMyPlot()
    local myDisplayName = LocalPlayer.DisplayName
    local plots = workspace:FindFirstChild("Plots")
    if plots then
        for _, plot in ipairs(plots:GetChildren()) do
            local bb = plot:FindFirstChild("OwnerBillboard") and plot.OwnerBillboard:FindFirstChild("BB")
            if bb then
                local textLabel = bb:FindFirstChild("TextLabel")
                if textLabel and textLabel:IsA("TextLabel") then
                    local txt = textLabel.Text
                    if txt and txt:match(myDisplayName) then
                        return plot
                    end
                end
            end
        end
    end
    return nil
end

task.spawn(function()
    while true do
        pcall(function()
            local myPlot = getMyPlot()
            if myPlot then
                local baseFolder = myPlot:FindFirstChild("Base")
                if baseFolder then
                    for _, child in ipairs(baseFolder:GetDescendants()) do
                        if child.Name:match("^Glass") then
                            child:Destroy()
                        end
                    end
                end
            end
        end)
        task.wait(3)
    end
end)

local function getPlayerCash()
    local cashObj = LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Cash")
    if cashObj then
        local cStr = tostring(cashObj.Value)
        cStr = string.gsub(cStr, "[%$%s]", "")
        return NumberConverter and NumberConverter.Parse(cStr) or tonumber(cStr) or 0
    end
    return 0
end

local function parsePPS(txt)
    local matchedVal = string.match(txt, "%$%s*([%d%.]+%w*)%s*/%s*[sS]")
    if matchedVal then
        local num = NumberConverter.Parse(matchedVal) or 0
        return num
    end
    return nil
end

local function simulateClick(button)
    if not button then return end
    local UIS = game:GetService("UserInputService")
    local isMobile = UIS.TouchEnabled and not UIS.MouseEnabled
    if isMobile then
        if button.AbsolutePosition then
            local x = button.AbsolutePosition.X + (button.AbsoluteSize.X / 2)
            local y = button.AbsolutePosition.Y + (button.AbsoluteSize.Y / 2) + game:GetService("GuiService"):GetGuiInset().Y
            local mobileTouchId = 55555
            game:GetService("VirtualInputManager"):SendTouchEvent(mobileTouchId, 0, x, y)
            task.wait(0.02)
            game:GetService("VirtualInputManager"):SendTouchEvent(mobileTouchId, 2, x, y)
        end
    else
        if button.AbsolutePosition then
            local x = button.AbsolutePosition.X + (button.AbsoluteSize.X / 2)
            local y = button.AbsolutePosition.Y + (button.AbsoluteSize.Y / 2) + game:GetService("GuiService"):GetGuiInset().Y
            game:GetService("VirtualInputManager"):SendMouseButtonEvent(x, y, 0, true, game, 1)
            task.wait(0.02)
            game:GetService("VirtualInputManager"):SendMouseButtonEvent(x, y, 0, false, game, 1)
        end
    end
end

local function getBrainrotCount(targetName, shouldLog)
    local count = 0
    if not targetName or targetName == "" then return count end
    
    local function cleanStr(s)
        return string.lower(string.gsub(tostring(s), "[%s_]", ""))
    end
    local cTarget = cleanStr(targetName)
    
    local function checkFolder(parent)
        if not parent then return end
        for _, tool in ipairs(parent:GetChildren()) do
            if tool:IsA("Tool") then
                -- Check label inside BrainrotInfo
                local found = false
                local brainrotInfo = tool:FindFirstChild("BrainrotInfo", true)
                
                if brainrotInfo then
                    for _, desc in ipairs(brainrotInfo:GetDescendants()) do
                        if desc:IsA("TextLabel") and cleanStr(desc.Text) == cTarget then
                            found = true
                            break
                        end
                    end
                end
                
                -- Fallback to tool name
                if found or cleanStr(tool.Name) == cTarget then
                    count = count + 1
                end
            end
        end
    end
    checkFolder(LocalPlayer.Backpack)
    checkFolder(LocalPlayer.Character)
    
    local myPlot = getMyPlot()
    if myPlot then
        local slotsFolder = myPlot:FindFirstChild("Slots")
        if slotsFolder then
            for _, slot in ipairs(slotsFolder:GetChildren()) do
                if slot.Name:match("^Slot%d+$") then
                    if not (slot:IsA("BasePart") and slot.Transparency >= 1) then
                        local placedFolder = slot:FindFirstChild("PlacedBrainrot")
                        if placedFolder then
                            -- Check if there's an actual item placed here with that name
                            local hasFound = false
                            for _, child in ipairs(placedFolder:GetChildren()) do
                                local info = child:FindFirstChild("BrainrotInfo", true)
                                if info then
                                    for _, desc in ipairs(info:GetDescendants()) do
                                        if desc:IsA("TextLabel") and not string.match(desc.Text, "^%$") and not string.match(desc.Text, "^Select") then
                                            if cleanStr(desc.Text) == cTarget then
                                                hasFound = true
                                            end
                                        end
                                    end
                                end
                            end
                            if hasFound then
                                count = count + 1
                            end
                        end
                    end
                end
            end
        end
    end
    return count
end

local activeRebirthRequirements = {}

local autoCollectCashEnabled = false
BrainrotSection:Toggle({
    Title = "Auto Collect Cash",
    Value = false,
    Callback = function(Value)
        autoCollectCashEnabled = Value
        if Value then
            task.spawn(function()
                while autoCollectCashEnabled do
                    pcall(function()
                        local myPlot = getMyPlot()
                        if myPlot then
                            local slots = myPlot:FindFirstChild("Slots")
                            if slots then
                                for _, slot in ipairs(slots:GetChildren()) do
                                    if string.match(slot.Name, "_Collector$") then
                                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                        if hrp then
                                            local isMobile = game:GetService("UserInputService").TouchEnabled and not game:GetService("UserInputService").MouseEnabled
                                            if isMobile then
                                                firetouchinterest(hrp, slot, 0)
                                                task.wait(0.01)
                                                firetouchinterest(hrp, slot, 1)
                                            else
                                                firetouchinterest(hrp, slot, 0)
                                            end
                                            task.wait(0.1)
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(5)
                end
            end)
        end
    end
})

local isPlacingBrainrot = false

local farmMinLimit = 0
local autoFarmBrainrotEnabled = false
BrainrotSection:Toggle({
    Title = "Auto Farm Brainrot",
    Value = false,
    Callback = function(Value)
        autoFarmBrainrotEnabled = Value
        if Value then
            task.spawn(function()
                while autoFarmBrainrotEnabled do
                    if isPlacingBrainrot then
                        task.wait(0.5)
                        continue
                    end
                    pcall(function()
                        local bestBrainrot = nil
                        local superPriorityItem = nil
                        local superPriorityMoney = -1
                        local bestMoney = -1
                        local myCash = getPlayerCash()
                        
                        local cachedCounts = {}
                        local function getCachedCount(targetName)
                            if cachedCounts[targetName] == nil then
                                cachedCounts[targetName] = getBrainrotCount(targetName)
                            end
                            return cachedCounts[targetName]
                        end
                        
                        local activeItems = workspace:FindFirstChild("ActiveItems")
                        if activeItems then
                            for _, item in ipairs(activeItems:GetChildren()) do
                                local brainrotInfo = nil
                                for _, c in ipairs(item:GetChildren()) do
                                    if c:FindFirstChild("BrainrotInfo") then
                                        brainrotInfo = c.BrainrotInfo
                                        break
                                    end
                                end
                                
                                local frame = brainrotInfo and brainrotInfo:FindFirstChild("Frame")
                                if frame then
                                    local isPriority = false
                                    local reqMoney = -1
                                    for _, label in ipairs(frame:GetChildren()) do
                                        if label:IsA("TextLabel") then
                                            local txt = label.Text
                                            
                                            local reqCount = activeRebirthRequirements[txt]
                                            if reqCount and getCachedCount(txt) < reqCount then
                                                isPriority = true
                                            end
                                            
                                            if txt:match("^%$") and not string.lower(txt):match("/s") then
                                                local cln = string.gsub(txt, "[%$%s]", "")
                                                local money = NumberConverter and NumberConverter.Parse(cln) or tonumber(cln)
                                                
                                                if money then
                                                    reqMoney = money
                                                    if money >= farmMinLimit and money <= myCash then
                                                        if money > bestMoney then
                                                            bestMoney = money
                                                            bestBrainrot = item
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    if isPriority and reqMoney >= 0 and reqMoney <= myCash then
                                        -- Pick the highest affordable priority item if there are multiple
                                        if reqMoney > superPriorityMoney then
                                            superPriorityMoney = reqMoney
                                            superPriorityItem = item
                                        end
                                    end
                                end
                            end
                        end
                        
                        if superPriorityItem then
                            bestBrainrot = superPriorityItem
                        end
                        
                        if bestBrainrot then
                            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            local prompt = bestBrainrot:FindFirstChild("_ClientUIAnchor") and bestBrainrot._ClientUIAnchor:FindFirstChild("PickupPrompt")
                            local myPlot = getMyPlot()
                            
                            if hrp and prompt and prompt.Enabled and myPlot then
                                hrp.CFrame = bestBrainrot._ClientUIAnchor.CFrame
                                task.wait(0.25)
                                prompt.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow
                                if fireproximityprompt then
                                    fireproximityprompt(prompt)
                                else
                                    prompt:InputHoldBegin()
                                    task.wait(prompt.HoldDuration + 0.1)
                                    prompt:InputHoldEnd()
                                end
                                task.wait(0.5)
                                
                                local slot1 = myPlot.Slots:FindFirstChild("Slot1")
                                if slot1 then
                                    hrp.CFrame = slot1.CFrame
                                    task.wait(0.5)
                                end
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

BrainrotSection:Input({
    Title = "Set Min Limit For Farm Brainrot",
    Placeholder = "Example: 560K, 24M, 25Sx",
    Callback = function(text)
        if text == nil or text == "" then
            farmMinLimit = 0
            return
        end
        local parsed = (NumberConverter and NumberConverter.Parse(text)) or tonumber(text) or 0
        farmMinLimit = parsed
        
        local formStr = (NumberConverter and NumberConverter.Format(parsed)) or tostring(parsed)
        local displayStr = "$" .. formStr
        
        WindUI:Notify({
            Title = "Min Limit Set",
            Content = displayStr,
            Duration = 3
        })
    end
})

local autoPlaceBrainrotEnabled = false
BrainrotSection:Toggle({
    Title = "Auto Place Brainrot",
    Value = false,
    Callback = function(Value)
        autoPlaceBrainrotEnabled = Value
        if Value then
            task.spawn(function()
                while autoPlaceBrainrotEnabled do
                    pcall(function()
                        local myPlot = getMyPlot()
                        if not myPlot then 
                            return 
                        end
                        
                        -- Get all brainrots in inventory
                        local invBrainrots = {}
                        local function scanForBrainrots(parent)
                            if parent then
                                for _, tool in ipairs(parent:GetChildren()) do
                                    if tool:IsA("Tool") then
                                        local brainrotInfo = tool:FindFirstChild("BrainrotInfo", true)
                                        if brainrotInfo then
                                            local frame = brainrotInfo:FindFirstChild("Frame")
                                            if frame then
                                                for _, label in ipairs(frame:GetChildren()) do
                                                    if label:IsA("TextLabel") then
                                                        local pps = parsePPS(label.Text)
                                                        if pps then
                                                            table.insert(invBrainrots, { item = tool, pps = pps, isEquipped = (parent.Name == LocalPlayer.Name) })
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        scanForBrainrots(LocalPlayer.Backpack)
                        scanForBrainrots(LocalPlayer.Character)
                        
                        -- Sort inventory descending so [1] is best
                        table.sort(invBrainrots, function(a, b) return a.pps > b.pps end)
                        
                        -- Get placed slots
                        local placedSlots = {}
                        local slotsFolder = myPlot:FindFirstChild("Slots")
                        if slotsFolder then
                            for _, slot in ipairs(slotsFolder:GetChildren()) do
                                if slot.Name:match("^Slot%d+$") then -- ensure it's not a SlotX_Collector
                                    if not (slot:IsA("BasePart") and slot.Transparency >= 1) then
                                        local placedFolder = slot:FindFirstChild("PlacedBrainrot")
                                        local prompt = slot:FindFirstChild("SlotPrompt")
                                        
                                        if prompt then
                                            local isEmpty = true
                                            local pps = -1 -- Empty slot defaults to -1
                                            local foundLabel = false
                                            
                                            if placedFolder then
                                                for _, child in ipairs(placedFolder:GetChildren()) do
                                                    local info = child:FindFirstChild("BrainrotInfo", true)
                                                    if info then
                                                        local frame = info:FindFirstChild("Frame")
                                                        if frame then
                                                            for _, label in ipairs(frame:GetChildren()) do
                                                                if label:IsA("TextLabel") then
                                                                    local val = parsePPS(label.Text)
                                                                    if val then
                                                                        pps = val
                                                                        foundLabel = true
                                                                        isEmpty = false
                                                                    end
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                                
                                                if not foundLabel then
                                                    for _, desc in ipairs(placedFolder:GetChildren()) do
                                                        if desc:IsA("Model") or desc:IsA("MeshPart") then
                                                            isEmpty = false
                                                            pps = 0
                                                            break
                                                        end
                                                    end
                                                end
                                            end
                                            
                                            table.insert(placedSlots, { slot = slot, pps = pps, prompt = prompt, isEmpty = isEmpty })
                                        end
                                    end
                                end
                            end
                        end
                        
                        -- Sort placed slots so [1] is the worst (or empty)
                        table.sort(placedSlots, function(a, b) return a.pps < b.pps end)
                        
                        if #invBrainrots > 0 then
                            local bestInv = invBrainrots[1]
                            local logInvStr = bestInv.item.Name .. " ($" .. (NumberConverter and NumberConverter.Format(bestInv.pps) or tostring(bestInv.pps)) .. "/s)"
                            
                            local worstPlaced = nil
                            -- Prioritize empty slots first
                            for _, placed in ipairs(placedSlots) do
                                if placed.isEmpty then
                                    worstPlaced = placed
                                    break
                                end
                            end
                            
                            -- If no empty slots, take the absolute worst from sorting
                            if not worstPlaced and #placedSlots > 0 then
                                worstPlaced = placedSlots[1]
                            end
                            
                            if worstPlaced then
                                local logPlacedStr = worstPlaced.isEmpty and "Empty" or ("$" .. (NumberConverter and NumberConverter.Format(worstPlaced.pps) or tostring(worstPlaced.pps)) .. "/s")
                                
                                -- Compare if it's strictly better or placed is empty
                                if worstPlaced.isEmpty or bestInv.pps > worstPlaced.pps then
                                    isPlacingBrainrot = true
                                    pcall(function()
                                        print("[Auto Place Brainrot] Placing/Swapping best inventory item", logInvStr, "to", worstPlaced.slot.Name, "Replacing:", logPlacedStr)
                                        -- Equip the best one
                                        if not bestInv.isEquipped then
                                            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                                            if humanoid then
                                                humanoid:EquipTool(bestInv.item)
                                                task.wait(0.2)
                                            end
                                        end
                                        
                                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                        if hrp and worstPlaced.prompt then
                                            hrp.CFrame = worstPlaced.slot.CFrame
                                            task.wait(0.25)
                                            worstPlaced.prompt.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow
                                            if fireproximityprompt then
                                                fireproximityprompt(worstPlaced.prompt)
                                            else
                                                worstPlaced.prompt:InputHoldBegin()
                                                task.wait(worstPlaced.prompt.HoldDuration + 0.1)
                                                worstPlaced.prompt:InputHoldEnd()
                                            end
                                            task.wait(0.5)
                                        end
                                    end)
                                    isPlacingBrainrot = false
                                else
                                    -- Target slot is better or equal
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

local autoRebirthEnabled = false
Tabs.Main:Toggle({
    Title = "Auto Rebirth",
    Value = false,
    Callback = function(Value)
        autoRebirthEnabled = Value
        if Value then
            task.spawn(function()
                -- Initial refresh of data
                pcall(function()
                    local hud = LocalPlayer.PlayerGui:FindFirstChild("HUD")
                    if hud then
                        local openBtn = hud.Container:FindFirstChild("RebirthOpenButton")
                        if openBtn then simulateClick(openBtn) end
                        task.wait(0.8)
                        local rbHud = LocalPlayer.PlayerGui:FindFirstChild("RebirthHUD")
                        if rbHud then
                            local closeBtn = rbHud.RebirthFrame:FindFirstChild("CloseButton")
                            if closeBtn then
                                for _ = 1, 3 do
                                    simulateClick(closeBtn)
                                    task.wait(0.1)
                                end
                            end
                        end
                        task.wait(0.5)
                    end
                end)
                
                while autoRebirthEnabled do
                    pcall(function()
                        local rbHud = LocalPlayer.PlayerGui:FindFirstChild("RebirthHUD")
                        if not rbHud then return end
                        local rFrame = rbHud:FindFirstChild("RebirthFrame")
                        if not rFrame then return end
                        
                        -- Parse requirements
                        local reqSec = rFrame:FindFirstChild("RequiredSection")
                        if reqSec then
                            local cells = reqSec:FindFirstChild("Cells")
                            if cells then
                                activeRebirthRequirements = {}
                                for _, cell in ipairs(cells:GetChildren()) do
                                    if cell.Name:match("^Cell_") then
                                        local reqName = string.sub(cell.Name, 6) -- Default fallback
                                        local reqQty = 1
                                        local nameLabel = cell:FindFirstChild("NameLabel")
                                        if nameLabel and nameLabel:IsA("TextLabel") then
                                            local txt = nameLabel.Text
                                            local _, qtyStr = string.match(txt, "^.-%s*[x×X]%s*(%d+)$")
                                            if qtyStr then
                                                reqQty = tonumber(qtyStr) or 1
                                            end
                                        end
                                        activeRebirthRequirements[reqName] = reqQty
                                    end
                                end
                            end
                        end
                        
                        -- Parse Cash Requirement
                        local reqCash = 0
                        local pBar = rFrame:FindFirstChild("ProgressBar")
                        if pBar then
                            local tLabel = pBar:FindFirstChild("TextLabel")
                            if tLabel and tLabel:IsA("TextLabel") then
                                local txt = tLabel.Text
                                local parts = string.split(txt, "/")
                                local targetStr = parts[2] or txt
                                local reqCashStr = string.match(targetStr, "([%d%.]+[a-zA-Z]*)")
                                if reqCashStr then
                                    reqCash = NumberConverter and NumberConverter.Parse(reqCashStr) or tonumber(reqCashStr) or 0
                                end
                            end
                        end
                        
                        local myCash = getPlayerCash()
                        local allReqsMet = (myCash >= reqCash)
                        print("[Auto Rebirth] Cash Check: Have " .. tostring(myCash) .. " | Need " .. tostring(reqCash) .. " -> " .. tostring(allReqsMet))
                        
                        if allReqsMet then
                            for reqName, reqQty in pairs(activeRebirthRequirements) do
                                local currentCount = getBrainrotCount(reqName)
                                print("[Auto Rebirth] Item Check: " .. reqName .. " | Need " .. tostring(reqQty) .. " | Have " .. tostring(currentCount))
                                if currentCount < reqQty then
                                    allReqsMet = false
                                end
                            end
                        end
                        
                        if allReqsMet then
                            print("[Auto Rebirth] Firing RebirthEvent!")
                            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RebirthEvent"):FireServer()
                            task.wait(1)
                            
                            -- Refresh UI
                            local hud = LocalPlayer.PlayerGui:FindFirstChild("HUD")
                            if hud then
                                local openBtn = hud.Container:FindFirstChild("RebirthOpenButton")
                                if openBtn then simulateClick(openBtn) end
                                task.wait(0.8)
                                local rbHudRefresh = LocalPlayer.PlayerGui:FindFirstChild("RebirthHUD")
                                if rbHudRefresh then
                                    local closeBtn = rbHudRefresh.RebirthFrame:FindFirstChild("CloseButton")
                                    if closeBtn then
                                        for _ = 1, 3 do
                                            simulateClick(closeBtn)
                                            task.wait(0.1)
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

local batAuraEnabled = false
Tabs.Main:Toggle({
    Title = "Bat Aura",
    Value = false,
    Callback = function(Value)
        batAuraEnabled = Value
        if Value then
            task.spawn(function()
                while batAuraEnabled do
                    pcall(function()
                        local char = LocalPlayer.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        local humanoid = char and char:FindFirstChild("Humanoid")
                        if not (char and hrp and humanoid and humanoid.Health > 0) then return end
                        
                        -- Find target
                        local target = nil
                        local minDst = 11
                        for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                            if p ~= LocalPlayer and p.Character then
                                local pHealth = p.Character:FindFirstChild("Humanoid")
                                if pHealth and pHealth.Health > 0 then
                                    local pHrp = p.Character:FindFirstChild("HumanoidRootPart")
                                    if pHrp then
                                        local dst = (pHrp.Position - hrp.Position).Magnitude
                                        if dst <= minDst then
                                            minDst = dst
                                            target = p.Character
                                        end
                                    end
                                end
                            end
                        end
                        
                        if target then
                            -- Equip Bat
                            local bat = char:FindFirstChild("Bat")
                            if not bat then
                                local batInBackpack = LocalPlayer.Backpack:FindFirstChild("Bat")
                                if batInBackpack then
                                    humanoid:EquipTool(batInBackpack)
                                    bat = batInBackpack
                                end
                            end
                            
                            if bat then
                                -- Look at target
                                local tHrp = target:FindFirstChild("HumanoidRootPart")
                                if tHrp then
                                    hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(tHrp.Position.X, hrp.Position.Y, tHrp.Position.Z))
                                end
                                
                                -- Swing
                                game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("BatSwing"):FireServer()
                            end
                        end
                    end)
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
