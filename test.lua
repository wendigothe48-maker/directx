task.wait(3)

local buttonPart = workspace:WaitForChild("GameStations", 5)
if buttonPart then 
    buttonPart = buttonPart:FindFirstChild("Normal") 
    if buttonPart then buttonPart = buttonPart:FindFirstChild("1") end
    if buttonPart then buttonPart = buttonPart:FindFirstChild("Buttons") end
    if buttonPart then buttonPart = buttonPart:FindFirstChild("Player2") end
end

if not buttonPart then 
    return print("❌ Button nahi mila game me!") 
end

-- Agar wo model hai to uske andar ka part dhundo
local targetPart = buttonPart:IsA("Model") and (buttonPart.PrimaryPart or buttonPart:FindFirstChildWhichIsA("BasePart")) or buttonPart:IsA("BasePart") and buttonPart or nil
if not targetPart then 
    return print("❌ Target part nahi mila button ke andar!") 
end

print("🔥 Testing click on:", targetPart:GetFullName())

-- Method 1: ClickDetector (Ye sabse best hai agar game ise use karta hai)
local cd = targetPart:FindFirstChildWhichIsA("ClickDetector") or (buttonPart.Parent and buttonPart.Parent:FindFirstChildWhichIsA("ClickDetector"))
if cd then
    print("✅ Method 1: Found ClickDetector! Firing...")
    fireclickdetector(cd)
    return
end

-- Camera ko button pe focus karo taki wo screen pe visible ho
local camera = workspace.CurrentCamera
camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetPart.Position)
task.wait(0.5)

local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
if not onScreen then return print("❌ Button screen par nahi hai!") end

local GuiService = game:GetService("GuiService")
local inset = GuiService:GetGuiInset()
local clickX = screenPos.X
local clickY = screenPos.Y + inset.Y

print("📱 Attempting Touch Simulations for Phone...")

-- Method 2: VirtualInputManager Touch
pcall(function()
    print("👉 Method 2: Testing VIM TouchEvent...")
    local vim = game:GetService("VirtualInputManager")
    -- TouchState 0 = Began, 2 = Ended
    vim:SendTouchEvent(12345, 0, clickX, clickY)
    task.wait(0.1)
    vim:SendTouchEvent(12345, 2, clickX, clickY)
end)

task.wait(1.5)

-- Method 3: VirtualUser Button1
pcall(function()
    print("👉 Method 3: Testing VirtualUser Button1Down/Up...")
    local vu = game:GetService("VirtualUser")
    vu:Button1Down(Vector2.new(clickX, clickY), camera.CFrame)
    task.wait(0.1)
    vu:Button1Up(Vector2.new(clickX, clickY), camera.CFrame)
end)

task.wait(1.5)

-- Method 4: VirtualUser ClickButton
pcall(function()
    print("👉 Method 4: Testing VirtualUser ClickButton...")
    local vu = game:GetService("VirtualUser")
    vu:ClickButton(Vector2.new(clickX, clickY), camera.CFrame)
end)

print("✅ Test Done. Dekho game me button press hua ya nahi!")