local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")

local LocalPlayer = Players.LocalPlayer
local HWID = RbxAnalyticsService:GetClientId()
local API_URL = _G.SairoAPI_URL or "https://sairo.online"
local DEVID = _G.SairoDevID or "admin" 

-- Prevent multiple executions
if CoreGui:FindFirstChild("SairoSupportUI") then
    CoreGui.SairoSupportUI:Destroy()
end

local SupportUI = Instance.new("ScreenGui")
SupportUI.Name = "SairoSupportUI"
SupportUI.Parent = CoreGui
SupportUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SupportUI.IgnoreGuiInset = true
SupportUI.ResetOnSpawn = false

local camera = workspace.CurrentCamera
local vpSize = camera and camera.ViewportSize or Vector2.new(1920, 1080)
local defW = 480
local defH = 550
if vpSize.X < 600 then defW = vpSize.X * 0.9 end
if vpSize.Y < 700 then defH = vpSize.Y * 0.8 end

-- The main draggable window
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = SupportUI
MainFrame.AnchorPoint = Vector2.new(0.5, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, defW, 0, 0) -- Starts at 0 height for entrance anim
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.ClipsDescendants = true
MainFrame.BorderSizePixel = 0
MainFrame.Active = true

local BgPattern = Instance.new("ImageLabel")
BgPattern.Parent = MainFrame
BgPattern.Size = UDim2.new(1, 0, 1, 0)
BgPattern.BackgroundTransparency = 1
BgPattern.Image = "rbxassetid://7186985474" -- Subtle noise/pattern
BgPattern.ImageTransparency = 0.95
BgPattern.ScaleType = Enum.ScaleType.Tile
BgPattern.TileSize = UDim2.new(0, 256, 0, 256)
BgPattern.ZIndex = 0

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

local StrokeGradient = Instance.new("UIGradient")
StrokeGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 185, 129)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(59, 130, 246)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(139, 92, 246))
})
StrokeGradient.Rotation = 45
StrokeGradient.Parent = UIStroke

-- Topbar
local Topbar = Instance.new("Frame")
Topbar.Name = "Topbar"
Topbar.Parent = MainFrame
Topbar.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Topbar.BackgroundTransparency = 0.5
Topbar.Size = UDim2.new(1, 0, 0, 56)
Topbar.BorderSizePixel = 0
Topbar.ZIndex = 5
Topbar.Active = true

local TopbarBorder = Instance.new("Frame")
TopbarBorder.Parent = Topbar
TopbarBorder.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
TopbarBorder.Size = UDim2.new(1, 0, 0, 1)
TopbarBorder.Position = UDim2.new(0, 0, 1, -1)
TopbarBorder.BorderSizePixel = 0

local TitleHeader = Instance.new("TextLabel")
TitleHeader.Parent = Topbar
TitleHeader.BackgroundTransparency = 1
TitleHeader.Position = UDim2.new(0, 20, 0, 10)
TitleHeader.Size = UDim2.new(1, -150, 0, 20)
TitleHeader.Font = Enum.Font.GothamBold
TitleHeader.Text = "Support Chat"
TitleHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleHeader.TextSize = 16
TitleHeader.TextXAlignment = Enum.TextXAlignment.Left

local StatusDot = Instance.new("Frame")
StatusDot.Parent = Topbar
StatusDot.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
StatusDot.Position = UDim2.new(0, 20, 0, 36)
StatusDot.Size = UDim2.new(0, 8, 0, 8)
local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = StatusDot

local StatusText = Instance.new("TextLabel")
StatusText.Parent = Topbar
StatusText.BackgroundTransparency = 1
StatusText.Position = UDim2.new(0, 34, 0, 30)
StatusText.Size = UDim2.new(1, -150, 0, 20)
StatusText.Font = Enum.Font.GothamMedium
StatusText.Text = "Connecting..."
StatusText.TextColor3 = Color3.fromRGB(150, 150, 160)
StatusText.TextSize = 12
StatusText.TextXAlignment = Enum.TextXAlignment.Left

-- Controls
local MinBtn = Instance.new("TextButton")
MinBtn.Parent = Topbar
MinBtn.BackgroundTransparency = 1
MinBtn.Position = UDim2.new(1, -80, 0, 12)
MinBtn.Size = UDim2.new(0, 32, 0, 32)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "-"
MinBtn.TextSize = 24
MinBtn.TextColor3 = Color3.fromRGB(180, 180, 190)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = Topbar
CloseBtn.BackgroundTransparency = 1
CloseBtn.Position = UDim2.new(1, -44, 0, 12)
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = Color3.fromRGB(180, 180, 190)

-- Hover Effects
MinBtn.MouseEnter:Connect(function() TweenService:Create(MinBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play() end)
MinBtn.MouseLeave:Connect(function() TweenService:Create(MinBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(180, 180, 190)}):Play() end)

CloseBtn.MouseEnter:Connect(function() TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(248, 113, 113)}):Play() end)
CloseBtn.MouseLeave:Connect(function() TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(180, 180, 190)}):Play() end)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    
    local contentStr = MainFrame:FindFirstChild("Content")
    local resizeHnd = MainFrame:FindFirstChild("ResizeHandle")
    
    if minimized then
        if contentStr then contentStr.Visible = false end
        if resizeHnd then resizeHnd.Visible = false end
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, defW, 0, 56)}):Play()
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, defW, 0, defH)}):Play()
        if contentStr then contentStr.Visible = true end
        if resizeHnd then resizeHnd.Visible = true end
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    SupportUI:Destroy()
end)

-- Messages Area
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "Content"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 0, 0, 56)
ContentFrame.Size = UDim2.new(1, 0, 1, -56)
ContentFrame.ClipsDescendants = true

local ChatScroll = Instance.new("ScrollingFrame")
ChatScroll.Name = "ChatScroll"
ChatScroll.Parent = ContentFrame
ChatScroll.BackgroundTransparency = 1
ChatScroll.Position = UDim2.new(0, 0, 0, 0)
ChatScroll.Size = UDim2.new(1, 0, 1, -70) -- 56 top, 70 bottom
ChatScroll.BorderSizePixel = 0
ChatScroll.ScrollBarThickness = 4
ChatScroll.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 80)
ChatScroll.ZIndex = 1

local ChatPadding = Instance.new("UIPadding")
ChatPadding.Parent = ChatScroll
ChatPadding.PaddingTop = UDim.new(0, 16)
ChatPadding.PaddingBottom = UDim.new(0, 16)
ChatPadding.PaddingLeft = UDim.new(0, 20)
ChatPadding.PaddingRight = UDim.new(0, 16)

local ChatLayout = Instance.new("UIListLayout")
ChatLayout.Parent = ChatScroll
ChatLayout.SortOrder = Enum.SortOrder.LayoutOrder
ChatLayout.Padding = UDim.new(0, 12)

ChatLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ChatScroll.CanvasSize = UDim2.new(0, 0, 0, ChatLayout.AbsoluteContentSize.Y + 32)
    -- Auto scroll to bottom
    ChatScroll.CanvasPosition = Vector2.new(0, ChatLayout.AbsoluteContentSize.Y + 200)
end)

-- Input Area
local InputContainer = Instance.new("Frame")
InputContainer.Name = "InputContainer"
InputContainer.Parent = ContentFrame
InputContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
InputContainer.Position = UDim2.new(0, 0, 1, -70)
InputContainer.Size = UDim2.new(1, 0, 0, 70)
InputContainer.BorderSizePixel = 0
InputContainer.ZIndex = 2

local InputBorder = Instance.new("Frame")
InputBorder.Parent = InputContainer
InputBorder.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
InputBorder.Size = UDim2.new(1, 0, 0, 1)
InputBorder.Position = UDim2.new(0, 0, 0, 0)
InputBorder.BorderSizePixel = 0

local TBFrame = Instance.new("Frame")
TBFrame.Parent = InputContainer
TBFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
TBFrame.Position = UDim2.new(0, 20, 0.5, -20)
TBFrame.Size = UDim2.new(1, -110, 0, 40)
local TBCorner = Instance.new("UICorner")
TBCorner.CornerRadius = UDim.new(0, 6)
TBCorner.Parent = TBFrame
local TBStroke = Instance.new("UIStroke")
TBStroke.Color = Color3.fromRGB(50, 50, 60)
TBStroke.Parent = TBFrame

local TextBox = Instance.new("TextBox")
TextBox.Parent = TBFrame
TextBox.BackgroundTransparency = 1
TextBox.Position = UDim2.new(0, 15, 0, 0)
TextBox.Size = UDim2.new(1, -30, 1, 0)
TextBox.Font = Enum.Font.Gotham
TextBox.PlaceholderText = "Type your message..."
TextBox.Text = ""
TextBox.TextColor3 = Color3.fromRGB(240, 240, 250)
TextBox.TextSize = 13
TextBox.TextXAlignment = Enum.TextXAlignment.Left
TextBox.ClearTextOnFocus = false

local SendBtn = Instance.new("TextButton")
SendBtn.Parent = InputContainer
SendBtn.BackgroundColor3 = Color3.fromRGB(249, 115, 22) -- Orange
SendBtn.Position = UDim2.new(1, -80, 0.5, -20)
SendBtn.Size = UDim2.new(0, 60, 0, 40)
SendBtn.Font = Enum.Font.GothamBold
SendBtn.Text = "SEND"
SendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SendBtn.TextSize = 12
SendBtn.AutoButtonColor = false
local SendCorner = Instance.new("UICorner")
SendCorner.CornerRadius = UDim.new(0, 6)
SendCorner.Parent = SendBtn

SendBtn.MouseEnter:Connect(function() TweenService:Create(SendBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(251, 146, 60)}):Play() end)
SendBtn.MouseLeave:Connect(function() TweenService:Create(SendBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(249, 115, 22)}):Play() end)

-- Initial Animation
TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, defW, 0, defH)}):Play()

-- Draggable Logic
local dragging, dragInput, dragStart, startPos
Topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
Topbar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- HTTP Request Helper
local function RequestAccess(options)
    pcall(function()
        if syn and syn.request then return syn.request(options) end
        if http and http.request then return http.request(options) end
        if request then return request(options) end
    end)
    return nil
end

local lastMessageCount = 0

local function addMessage(data)
    if not data or type(data) ~= "table" then return end
    local txt = data.text or ""
    local isAdmin = (data.sender == "admin")
    
    -- Dynamically calc size
    local maxWidth = 320
    local size = Vector2.new(100, 20)
    pcall(function()
        size = TextService:GetTextSize(txt, 14, Enum.Font.Gotham, Vector2.new(maxWidth, 10000))
    end)
    
    local container = Instance.new("Frame")
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, size.Y + 36)
    container.Parent = ChatScroll
    
    local bubble = Instance.new("Frame")
    bubble.BackgroundColor3 = isAdmin and Color3.fromRGB(20, 20, 30) or Color3.fromRGB(25, 20, 35)
    bubble.Size = UDim2.new(0, math.max(size.X + 24, 70), 0, size.Y + 34)
    if isAdmin then
        bubble.Position = UDim2.new(0, 0, 0, 0)
    else
        bubble.AnchorPoint = Vector2.new(1, 0)
        bubble.Position = UDim2.new(1, 0, 0, 0)
    end
    bubble.Parent = container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = bubble

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = isAdmin and Color3.fromRGB(45, 45, 65) or Color3.fromRGB(65, 45, 85)
    stroke.Parent = bubble
    
    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, 0, 1, -14)
    textLabel.Position = UDim2.new(0, 0, 0, 0)
    textLabel.Font = Enum.Font.Gotham
    textLabel.Text = txt
    textLabel.TextColor3 = Color3.fromRGB(250, 250, 250)
    textLabel.TextSize = 14
    textLabel.TextWrapped = true
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.Parent = bubble
    
    local timeLabel = Instance.new("TextLabel")
    timeLabel.BackgroundTransparency = 1
    timeLabel.Size = UDim2.new(1, 0, 0, 12)
    timeLabel.Position = UDim2.new(0, 0, 1, -12)
    timeLabel.Font = Enum.Font.Gotham
    timeLabel.Text = os.date("%I:%M %p")
    timeLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
    timeLabel.TextSize = 10
    timeLabel.TextXAlignment = Enum.TextXAlignment.Right
    timeLabel.Parent = bubble

    if not isAdmin then
        -- Add tick
        local ticks = Instance.new("TextLabel")
        ticks.BackgroundTransparency = 1
        ticks.Size = UDim2.new(0, 16, 0, 12)
        ticks.Position = UDim2.new(1, 4, 1, -12)
        ticks.Font = Enum.Font.GothamBold
        ticks.Text = "✔"
        -- Start blue if we know dev is online
        if StatusText.Text == "Dev is Online" then
            ticks.TextColor3 = Color3.fromRGB(59, 130, 246)
        else
            ticks.TextColor3 = Color3.fromRGB(150, 150, 160) -- Default gray
        end
        ticks.TextSize = 11
        ticks.TextXAlignment = Enum.TextXAlignment.Left
        ticks.Parent = bubble
        timeLabel.Position = UDim2.new(0, -18, 1, -12) -- shift time left
        
        -- Store it in a global or upvalue table so we can update it
        if not _G.userTicks then _G.userTicks = {} end
        table.insert(_G.userTicks, ticks)
    end
    
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, 12)
    pad.PaddingTop = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 4)
    pad.Parent = bubble
end

local isFetching = false
local function fetchMessages()
    if isFetching then return end
    isFetching = true
    task.spawn(function()
        pcall(function()
            local res
            if syn and syn.request then
                res = syn.request({Url = API_URL .. "/api/chat?hwid=" .. HWID, Method = "GET"})
            elseif http and http.request then
                res = http.request({Url = API_URL .. "/api/chat?hwid=" .. HWID, Method = "GET"})
            elseif request then
                res = request({Url = API_URL .. "/api/chat?hwid=" .. HWID, Method = "GET"})
            end
            
            if res and res.StatusCode == 200 then
                local s, msgs = pcall(function() return HttpService:JSONDecode(res.Body) end)
                if s and type(msgs) == "table" then
                    if #msgs > lastMessageCount then
                        for i = lastMessageCount + 1, #msgs do
                            addMessage(msgs[i])
                        end
                        lastMessageCount = #msgs
                    end
                end
            end
            
            -- Dev Status
            local stRes
            if syn and syn.request then
                stRes = syn.request({Url = API_URL .. "/api/chat/status?hwid=" .. HWID .. "&devId=" .. DEVID, Method = "GET"})
            elseif http and http.request then
                stRes = http.request({Url = API_URL .. "/api/chat/status?hwid=" .. HWID .. "&devId=" .. DEVID, Method = "GET"})
            elseif request then
                stRes = request({Url = API_URL .. "/api/chat/status?hwid=" .. HWID .. "&devId=" .. DEVID, Method = "GET"})
            end
            
            if stRes and stRes.StatusCode == 200 then
                local s, st = pcall(function() return HttpService:JSONDecode(stRes.Body) end)
                if s and type(st) == "table" then
                    if st.adminOnline then
                        TweenService:Create(StatusDot, TweenInfo.new(0.5), {BackgroundColor3 = Color3.fromRGB(16, 185, 129)}):Play()
                        StatusText.Text = "Dev is Online"
                        StatusText.TextColor3 = Color3.fromRGB(16, 185, 129)
                        
                        -- Update all user ticks to blue since dev is online
                        if _G.userTicks then
                            for _, tickLbl in ipairs(_G.userTicks) do
                                TweenService:Create(tickLbl, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(59, 130, 246)}):Play()
                            end
                        end
                    else
                        TweenService:Create(StatusDot, TweenInfo.new(0.5), {BackgroundColor3 = Color3.fromRGB(80, 80, 90)}):Play()
                        StatusText.Text = "Dev is Offline"
                        StatusText.TextColor3 = Color3.fromRGB(150, 150, 160)
                    end
                end
            end
        end)
        isFetching = false
    end)
end

-- Force initial
fetchMessages()

-- Polling
task.spawn(function()
    while SupportUI.Parent do
        fetchMessages()
        task.wait(3)
    end
end)

-- Sending
local isSending = false
local function sendMessage()
    if isSending then return end
    local txt = TextBox.Text
    if txt:gsub("%s+", "") == "" then return end
    
    isSending = true
    TextBox.Text = ""
    SendBtn.Text = "..."
    
    task.spawn(function()
        pcall(function()
            local gameName = "Unknown Game"
            pcall(function() gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)
            
            local pl = {
                hwid = HWID,
                displayName = LocalPlayer and LocalPlayer.Name or "Unknown",
                text = txt,
                type = "text",
                gameName = gameName
            }
            local bodyStr = HttpService:JSONEncode(pl)
            
            if syn and syn.request then
                syn.request({Url = API_URL .. "/api/chat", Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = bodyStr})
            elseif http and http.request then
                http.request({Url = API_URL .. "/api/chat", Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = bodyStr})
            elseif request then
                request({Url = API_URL .. "/api/chat", Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = bodyStr})
            end
            
            fetchMessages()
        end)
        isSending = false
        SendBtn.Text = "SEND"
    end)
end

SendBtn.MouseButton1Click:Connect(sendMessage)

TextBox.FocusLost:Connect(function(enter)
    if enter then
        sendMessage()
    end
end)

-- Resize Logic
local ResizeHandle = Instance.new("TextButton")
ResizeHandle.Parent = MainFrame
ResizeHandle.Name = "ResizeHandle"
ResizeHandle.BackgroundTransparency = 1
ResizeHandle.Position = UDim2.new(1, -20, 1, -20)
ResizeHandle.Size = UDim2.new(0, 20, 0, 20)
ResizeHandle.ZIndex = 10
ResizeHandle.Text = "↘"
ResizeHandle.TextColor3 = Color3.fromRGB(150, 150, 160)
ResizeHandle.TextSize = 18
ResizeHandle.Font = Enum.Font.GothamBold

local resizing = false
local rDragStart
local rStartSize

ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        resizing = true
        rDragStart = input.Position
        rStartSize = MainFrame.AbsoluteSize
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                resizing = false
                if not minimized then
                    defW = MainFrame.AbsoluteSize.X
                    defH = MainFrame.AbsoluteSize.Y
                end
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - rDragStart
        local newW = math.max(300, rStartSize.X + delta.X)
        local newH = math.max(400, rStartSize.Y + delta.Y)
        if not minimized then
            MainFrame.Size = UDim2.new(0, newW, 0, newH)
        end
    end
end)