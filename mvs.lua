local parent
pcall(function()
    parent = (gethui and gethui()) or game:GetService("CoreGui")
end)
if not parent then
    parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PXH_Maintenance"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 9999999
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = parent

local Overlay = Instance.new("Frame")
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Overlay.BackgroundTransparency = 0.5
Overlay.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 200)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = Overlay

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(60, 60, 60)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

local MessageLabel = Instance.new("TextLabel")
MessageLabel.Size = UDim2.new(1, -40, 0, 80)
MessageLabel.Position = UDim2.new(0, 20, 0, 20)
MessageLabel.BackgroundTransparency = 1
MessageLabel.Font = Enum.Font.GothamMedium
MessageLabel.Text = "This script is on maintenance.\nJoin the Discord for updates."
MessageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
MessageLabel.TextSize = 18
MessageLabel.TextWrapped = true
MessageLabel.Parent = MainFrame

local DiscordButton = Instance.new("TextButton")
DiscordButton.Size = UDim2.new(0, 200, 0, 45)
DiscordButton.Position = UDim2.new(0.5, 0, 1, -25)
DiscordButton.AnchorPoint = Vector2.new(0.5, 1)
DiscordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
DiscordButton.Font = Enum.Font.GothamBold
DiscordButton.Text = "Join Discord"
DiscordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DiscordButton.TextSize = 16
DiscordButton.Parent = MainFrame

local BtnUICorner = Instance.new("UICorner")
BtnUICorner.CornerRadius = UDim.new(0, 8)
BtnUICorner.Parent = DiscordButton

DiscordButton.MouseButton1Click:Connect(function()
    if setclipboard then
        pcall(function() setclipboard("https://discord.gg/bscnxEGP5F") end)
        DiscordButton.Text = "Copied link!"
        task.wait(2)
        DiscordButton.Text = "Join Discord"
    else
        DiscordButton.Text = "No Clipboard Support"
        task.wait(2)
        DiscordButton.Text = "Join Discord"
    end
end)
