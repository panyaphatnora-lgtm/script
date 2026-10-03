repeat task.wait() until game:IsLoaded() and game.Players and game.Players.LocalPlayer and game.Players.LocalPlayer.Character

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

-- Global Settings
_G.AutoGrabEat = true
_G.AutoSell = true
_G.EatSpeed = 10
_G.SellSize = 4219500

-- ===== สร้างหน้าต่าง GUI หลัก =====
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "ModernAutoFarmGui"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 260, 0, 320)
mainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
mainFrame.BorderSizePixel = 0

local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 10)

-- ส่วนหัว (Title Bar)
local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
titleLabel.Text = "  AUTO FARM & ANTI-AFK"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

local titleCorner = Instance.new("UICorner", titleLabel)
titleCorner.CornerRadius = UDim.new(0, 10)

local fixCorner = Instance.new("Frame", titleLabel)
fixCorner.Size = UDim2.new(1, 0, 0, 5)
fixCorner.Position = UDim2.new(0, 0, 1, -5)
fixCorner.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
fixCorner.BorderSizePixel = 0

-- Container สำหรับจัดเรียงปุ่ม
local container = Instance.new("ScrollingFrame", mainFrame)
container.Size = UDim2.new(1, -16, 1, -55)
container.Position = UDim2.new(0, 8, 0, 48)
container.BackgroundTransparency = 1
container.BorderSizePixel = 0
container.CanvasSize = UDim2.new(0, 0, 0, 290)
container.ScrollBarThickness = 4

local UIListLayout = Instance.new("UIListLayout", container)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

-- Function สร้างปุ่ม Toggle
local function createButton(text, defaultState)
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.Text = text .. " : " .. (defaultState and "ON" or "OFF")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.SourceSansSemibold
    btn.BackgroundColor3 = defaultState and Color3.fromRGB(46, 160, 67) or Color3.fromRGB(218, 54, 51)
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 6)
    return btn
end

local grabBtn = createButton("Auto Eat", _G.AutoGrabEat)
local sellBtn = createButton("Auto Sell", _G.AutoSell)

local function toggle(var, btn, text)
    _G[var] = not _G[var]
    if _G[var] then
        btn.Text = text .. " : ON"
        btn.BackgroundColor3 = Color3.fromRGB(46, 160, 67)
    else
        btn.Text = text .. " : OFF"
        btn.BackgroundColor3 = Color3.fromRGB(218, 54, 51)
    end
end

grabBtn.MouseButton1Click:Connect(function() toggle("AutoGrabEat", grabBtn, "Auto Eat") end)
sellBtn.MouseButton1Click:Connect(function() toggle("AutoSell", sellBtn, "Auto Sell") end)

-- ช่องใส่ค่า Size
local sizeBox = Instance.new("TextBox", container)
sizeBox.Size = UDim2.new(1, 0, 0, 38)
sizeBox.Text = "Sell Size: " .. _G.SellSize
sizeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
sizeBox.TextSize = 13
sizeBox.Font = Enum.Font.SourceSansSemibold
sizeBox.BackgroundColor3 = Color3.fromRGB(40, 40, 48)

local sizeCorner = Instance.new("UICorner", sizeBox)
sizeCorner.CornerRadius = UDim.new(0, 6)

sizeBox.FocusLost:Connect(function()
    local num = tonumber(sizeBox.Text:match("%d+")) or tonumber(sizeBox.Text)
    if num then
        _G.SellSize = num
        sizeBox.Text = "Sell Size: " .. num
    else
        sizeBox.Text = "Invalid Number!"
        task.wait(1)
        sizeBox.Text = "Sell Size: " .. _G.SellSize
    end
end)

-- ===== แผงแสดงข้อมูลสถานะ =====
local statsFrame = Instance.new("Frame", container)
statsFrame.Size = UDim2.new(1, 0, 0, 110)
statsFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 38)

local statsCorner = Instance.new("UICorner", statsFrame)
statsCorner.CornerRadius = UDim.new(0, 6)

local function createStatLabel(name, posY)
    local lbl = Instance.new("TextLabel", statsFrame)
    lbl.Size = UDim2.new(1, -20, 0, 24)
    lbl.Position = UDim2.new(0, 10, 0, posY)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.SourceSans
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Name = name
    return lbl
end

local pingLbl = createStatLabel("PingLabel", 8)
local fpsLbl = createStatLabel("FpsLabel", 32)
local timerLbl = createStatLabel("TimerLabel", 56)
local statusLbl = createStatLabel("StatusLabel", 80)
pingLbl.Text = "Ping: 0 ms"
fpsLbl.Text = "FPS: 0"
timerLbl.Text = "Time Active: 0:0:0"
statusLbl.Text = "Status: Anti-AFK Active"
statusLbl.TextColor3 = Color3.fromRGB(46, 160, 67)

-- ===== ระบบลากหน้าต่าง GUI =====
local dragging, dragInput, startPos, startFramePos

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        startPos = input.Position
        startFramePos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - startPos
        mainFrame.Position = UDim2.new(
            startFramePos.X.Scale,
            startFramePos.X.Offset + delta.X,
            startFramePos.Y.Scale,
            startFramePos.Y.Offset + delta.Y
        )
    end
end)

-- ===== ปุ่มซ่อน/แสดง (Key K) =====
local guiVisible = true
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.K then
        guiVisible = not guiVisible
        mainFrame.Visible = guiVisible
    end
end)

-- ===== ฟังก์ชันการทำงานหลัก (Auto Eat & Auto Sell) =====
local function getEvents()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local events = char:FindFirstChild("Events")
    if not events then return end
    return events:FindFirstChild("Grab"), events:FindFirstChild("Eat"), events:FindFirstChild("Sell")
end

task.spawn(function()
    while task.wait(0.1) do
        local Grab, Eat, Sell = getEvents()

        if _G.AutoGrabEat then
            if Grab then Grab:FireServer(false, false) end
            if Eat then
                for i = 1, _G.EatSpeed do
                    Eat:FireServer()
                    task.wait(0.02)
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if not _G.AutoSell then continue end
        local stats = LocalPlayer:FindFirstChild("leaderstats")
        local char = LocalPlayer.Character
        if not stats or not char then continue end
        local events = char:FindFirstChild("Events")
        local Sell = events and events:FindFirstChild("Sell")
        local size = stats:FindFirstChild("Size")

        if Sell and size and size.Value >= _G.SellSize then
            Sell:FireServer()
        end
    end
end)

-- ===== Anti-AFK & Stats System =====
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

local frames, lastTick = 0, tick()
RunService.RenderStepped:Connect(function()
    frames = frames + 1
    if tick() - lastTick >= 1 then
        fpsLbl.Text = "FPS: " .. frames
        frames = 0
        lastTick = tick()
    end
end)

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local pingVal = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            pingLbl.Text = "Ping: " .. pingVal .. " ms"
        end)
    end
end)

local hours, minutes, seconds = 0, 0, 0
task.spawn(function()
    while task.wait(1) do
        seconds = seconds + 1
        if seconds >= 60 then
            seconds = 0
            minutes = minutes + 1
        end
        if minutes >= 60 then
            minutes = 0
            hours = hours + 1
        end
        timerLbl.Text = string.format("Time Active: %d:%02d:%02d", hours, minutes, seconds)
    end
end)

RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hrp then hrp.Anchored = false end
    if hum then
        hum.PlatformStand = false
        hum.Sit = false
    end
end)
