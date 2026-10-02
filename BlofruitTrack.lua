-- Services
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- ลบ UI เก่าทิ้งถ้ามี
if CoreGui:FindFirstChild("ModernBloxFruitUI") then
    CoreGui.ModernBloxFruitUI:Destroy()
end

-- สร้าง ScreenGui หลัก
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModernBloxFruitUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- ปุ่มวงกลมเล็กสำหรับเปิด/ปิด (เมื่อย่อหน้าต่าง)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
ToggleButton.BackgroundTransparency = 0.2
ToggleButton.Position = UDim2.new(0.05, 0, 0.1, 0)
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "BF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 18
ToggleButton.Visible = false

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(120, 110, 255)
ToggleStroke.Thickness = 2
ToggleStroke.Parent = ToggleButton

-- หน้าต่างหลัก (Dark Glass Style)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.BackgroundTransparency = 0.25
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -300)
MainFrame.Size = UDim2.new(0, 400, 0, 620)
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(60, 60, 90)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Top Bar (สำหรับลากหน้าต่าง)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TopBar.BackgroundTransparency = 1
TopBar.Size = UDim2.new(1, 0, 0, 40)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = TopBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.Size = UDim2.new(0, 250, 1, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "Blox Fruits LINE Bot API"
TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- ปุ่มMinimize (ย่อหน้าต่าง)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Parent = TopBar
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Position = UDim2.new(1, -75, 0, 5)
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
MinimizeBtn.TextSize = 18

-- ปุ่มClose (ปิด GUI)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TopBar
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.TextSize = 20

-- Container สำหรับเนื้อหาภายใน
local ContentContainer = Instance.new("ScrollingFrame")
ContentContainer.Parent = MainFrame
ContentContainer.BackgroundTransparency = 1
ContentContainer.Position = UDim2.new(0, 15, 0, 45)
ContentContainer.Size = UDim2.new(1, -30, 1, -55)
ContentContainer.CanvasSize = UDim2.new(0, 0, 0, 950)
ContentContainer.ScrollBarThickness = 4

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ContentContainer
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)

-- ฟังก์ชันสร้าง TextBox
local function createTextBox(name, placeholder, defaultValue)
    local Label = Instance.new("TextLabel")
    Label.Parent = ContentContainer
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.Font = Enum.Font.GothamMedium
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(180, 180, 200)
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Box = Instance.new("TextBox")
    Box.Name = name .. "Box"
    Box.Parent = ContentContainer
    Box.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
    Box.BackgroundTransparency = 0.3
    Box.Size = UDim2.new(1, 0, 0, 35)
    Box.Font = Enum.Font.Gotham
    Box.PlaceholderText = placeholder
    Box.Text = defaultValue or ""
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
    Box.TextSize = 13
    Box.ClearTextOnFocus = false

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Box

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(50, 50, 75)
    Stroke.Thickness = 1
    Stroke.Parent = Box
    
    return Box
end

-- ฟังก์ชันสร้าง Toggle Switch สำหรับเปิด-ปิดโหมดเตะ
local function createToggle(name, defaultState)
    local Frame = Instance.new("Frame")
    Frame.Parent = ContentContainer
    Frame.BackgroundTransparency = 1
    Frame.Size = UDim2.new(1, 0, 0, 30)

    local Label = Instance.new("TextLabel")
    Label.Parent = Frame
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Font = Enum.Font.GothamMedium
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(200, 200, 220)
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local SwitchBtn = Instance.new("TextButton")
    SwitchBtn.Name = "SwitchButton"
    SwitchBtn.Parent = Frame
    SwitchBtn.AnchorPoint = Vector2.new(1, 0.5)
    SwitchBtn.Position = UDim2.new(1, 0, 0.5, 0)
    SwitchBtn.Size = UDim2.new(0, 50, 0, 24)
    SwitchBtn.Font = Enum.Font.GothamBold
    SwitchBtn.Text = ""
    SwitchBtn.TextSize = 12

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(1, 0)
    Corner.Parent = SwitchBtn

    local state = defaultState or false
    local function updateState()
        if state then
            SwitchBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
            SwitchBtn.Text = "ON (เตะ)"
            SwitchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            SwitchBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            SwitchBtn.Text = "OFF (แจ้ง)"
            SwitchBtn.TextColor3 = Color3.fromRGB(150, 150, 170)
        end
    end
    updateState()

    SwitchBtn.MouseButton1Click:Connect(function()
        state = not state
        updateState()
    end)

    -- ฟังก์ชันดึงค่าสถานะปัจจุบันของสวิตช์
    return {
        GetValue = function()
            return state
        end
    }
end

-- สร้าง UI Components
local MoneyBox = createTextBox("เป้าหมายเงิน (Money) [ปล่อยว่างได้ถ้าไม่ตั้ง]", "เช่น 100000000 (ปล่อยว่างได้)", "")
local MoneyKickToggle = createToggle("⚡ ตั้งค่า: เปิด=เตะ / ปิด=แจ้งเตือน (เมื่อถึงเป้าหมายเงิน)", true)

local FragmentBox = createTextBox("เป้าหมาย Fragment [ปล่อยว่างได้ถ้าไม่ตั้ง]", "เช่น 300000 (ปล่อยว่างได้)", "")
local FragKickToggle = createToggle("⚡ ตั้งค่า: เปิด=เตะ / ปิด=แจ้งเตือน (เมื่อถึงเป้าหมาย Fragment)", true)

local WeaponSlotBox = createTextBox("เลือก Slot อาวุธที่ต้องการใช้งาน (เช่น 1, 2, 3)", "ใส่หมายเลข Slot อาวุธ...", "1")
local MasteryBox = createTextBox("เป้าหมาย Mastery อาวุธ (X) [ปล่อยว่างได้]", "เช่น 600 (ปล่อยว่างได้)", "")
local MasteryKickToggle = createToggle("⚡ ตั้งค่า: เปิด=เตะ / ปิด=แจ้งเตือน (เมื่ออาวุธถึง Mastery)", true)

local ChannelTokenBox = createTextBox("Line Channel Access Token", "ใส่ Access Token...", "EfJMrAMgy2aPCimKynOUNPplYc70n5JgpMcdNDLvR2v5dC8ChP6LYJIY/IyRIjnOwyfjQ/OHuYRP0r4kVL4IB6cMsuGexCnTjg7yRfMInWUdT2qipNv1k45AfUEwg6zsvTtL5KZNNP+FgHleR8/ILwdB04t89/1O/w1cDnyilFU=")
local UserIdBox = createTextBox("Line User ID (ขึ้นต้นด้วย U...)", "ใส่ User ID ของคุณ...", "U1c12b681682342ded09e14485acc3fe1")

-- สถานะและตัวจับเวลา
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = ContentContainer
StatusLabel.BackgroundTransparency = 1
StatusLabel.Size = UDim2.new(1, 0, 0, 25)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.Text = "สถานะ: หยุดทำงาน"
StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
StatusLabel.TextSize = 13
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

local TimerLabel = Instance.new("TextLabel")
TimerLabel.Parent = ContentContainer
TimerLabel.BackgroundTransparency = 1
TimerLabel.Size = UDim2.new(1, 0, 0, 20)
TimerLabel.Font = Enum.Font.GothamMedium
TimerLabel.Text = "เวลาที่ใช้ไป: 00:00:00"
TimerLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
TimerLabel.TextSize = 12
TimerLabel.TextXAlignment = Enum.TextXAlignment.Left

-- ปุ่ม Start / Stop
local StartBtn = Instance.new("TextButton")
StartBtn.Name = "StartButton"
StartBtn.Parent = ContentContainer
StartBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
StartBtn.Size = UDim2.new(1, 0, 0, 40)
StartBtn.Font = Enum.Font.GothamBold
StartBtn.Text = "เริ่มทำงาน (START)"
StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartBtn.TextSize = 14

local StartCorner = Instance.new("UICorner")
StartCorner.CornerRadius = UDim.new(0, 8)
StartCorner.Parent = StartBtn

-- ระบบลากหน้าต่าง (Draggable)
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
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

TopBar.InputChanged:Connect(function(input)
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

-- ฟังก์ชันตรวจสอบ Mastery และดึงอาวุธตาม Slot ที่กำหนด
local function getCurrentWeaponMastery()
    local character = LocalPlayer.Character
    if not character then return "ไม่มีอาวุธ (0)" end
    
    local slotNum = tonumber(WeaponSlotBox.Text)
    local equippedTool = nil
    
    if slotNum then
        local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
        if backpack then
            local tools = {}
            for _, t in ipairs(backpack:GetChildren()) do
                if t:IsA("Tool") then
                    table.insert(tools, t)
                end
            end
            if tools[slotNum] then
                equippedTool = tools[slotNum]
            end
        end
    end
    
    if not equippedTool then
        equippedTool = character:FindFirstChildOfClass("Tool")
    end
    
    if not equippedTool then return "ไม่มีอาวุธ (0)" end
    
    local currentMas = 0
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    
    if playerGui then
        for _, descendant in ipairs(playerGui:GetDescendants()) do
            if descendant:IsA("TextLabel") then
                local text = descendant.Text
                if string.find(text, "Mastery") or string.find(text, "Mas") then
                    local num = tonumber(string.match(text, "%d+"))
                    if num and num > 9 and num <= 600 then
                        currentMas = num
                        break
                    end
                end
            end
        end
    end
    
    if currentMas == 0 then
        if equippedTool:FindFirstChild("Level") then
            currentMas = equippedTool.Level.Value
        elseif equippedTool:FindFirstChild("Mastery") then
            currentMas = equippedTool.Mastery.Value
        end
    end
    
    return string.format("%s [Slot: %s] (%d)", equippedTool.Name, tostring(slotNum or "-"), currentMas)
end

-- ฟังก์ชันตรวจสอบเป้าหมาย
local function getFarmingTargetDescription()
    local targets = {}
    local mTarget = tonumber(MoneyBox.Text)
    local fTarget = tonumber(FragmentBox.Text)
    local masTarget = tonumber(MasteryBox.Text)
    local slotTarget = WeaponSlotBox.Text
    
    if mTarget and mTarget > 0 then
        table.insert(targets, "ฟาร์มเงิน Beli ให้ถึง " .. mTarget)
    end
    if fTarget and fTarget > 0 then
        table.insert(targets, "ฟาร์ม Fragment ให้ถึง " .. fTarget)
    end
    if slotTarget ~= "" then
        table.insert(targets, "ใช้ Slot อาวุธที่ " .. slotTarget)
    end
    if masTarget and masTarget > 0 then
        table.insert(targets, "ฟาร์ม Mastery ให้ถึง " .. masTarget)
    end
    
    if #targets == 0 then
        return "ฟาร์มทั่วไป (ไม่ตั้งเป้าหมายหยุดอัตโนมัติ)"
    else
        return table.concat(targets, ", ")
    end
end

-- ฟังก์ชันจัดรูปแบบข้อความรายงานผล
local function getReportMessage(statusTitle, elapsedSeconds, startTimeFormatted)
    local realName = LocalPlayer.Name
    local nickName = LocalPlayer.DisplayName
    local beli = 0
    local fragments = 0
    
    local data = LocalPlayer:FindFirstChild("Data")
    if data then
        beli = data:FindFirstChild("Beli") and data.Beli.Value or 0
        fragments = data:FindFirstChild("Fragments") and data.Fragments.Value or 0
    end
    
    local hours = math.floor(elapsedSeconds / 3600)
    local minutes = math.floor((elapsedSeconds % 3600) / 60)
    local seconds = elapsedSeconds % 60
    local timeStr = string.format("%02d:%02d:%02d", hours, minutes, seconds)
    
    local masInfo = getCurrentWeaponMastery()
    local farmingGoal = getFarmingTargetDescription()
    
    if statusTitle == "เริ่มฟาร์ม" then
        return string.format(
            "🚀 กำลังเริ่มฟาร์ม...\nUserid: %s\nDisplay Name: %s\n🎯 กำลังฟาร์ม: %s\n⏰ เวลาเริ่ม: %s",
            realName, nickName, farmingGoal, startTimeFormatted
        )
    end
    
    return string.format(
        "[%s]\nUserid: %s\nDisplay Name: %s\nBeli: %d\nFragment: %d\nMas: %s\nTime: %s",
        statusTitle, realName, nickName, beli, fragments, masInfo, timeStr
    )
end

-- ฟังก์ชันส่งข้อความผ่าน LINE Messaging API
local function sendLineBotMessage(message)
    local token = ChannelTokenBox.Text
    local userId = UserIdBox.Text
    
    if token == "" or userId == "" then 
        return false 
    end
    
    local url = "https://api.line.me/v2/bot/message/push"
    local payload = {
        ["to"] = userId,
        ["messages"] = {
            {
                ["type"] = "text",
                ["text"] = message
            }
        }
    }
    
    local body = HttpService:JSONEncode(payload)
    local headers = {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bearer " .. token
    }
    
    local req = (getgenv and getgenv().request) or request or (http and http.request)
    
    if req then
        local success = pcall(function()
            req({
                Url = url,
                Method = "POST",
                Headers = headers,
                Body = body
            })
        end)
        return success
    end
    return false
end

-- ตัวแปรการทำงาน
local isRunning = false
local startTime = 0
-- ตัวแปรเช็คว่าส่งแจ้งเตือนไปแล้วหรือยัง (ป้องกันไม่ให้ส่งรัวๆ ทุกเฟรม)
local notifiedMoney = false
local notifiedFrag = false
local notifiedMastery = false

-- ปุ่มเปิด/ปิด Animation
MinimizeBtn.MouseButton1Click:Connect(function()
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = TweenService:Create(MainFrame, tweenInfo, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1})
    tween:Play()
    tween.Completed:Connect(function()
        MainFrame.Visible = false
        ToggleButton.Visible = true
    end)
end)

ToggleButton.MouseButton1Click:Connect(function()
    ToggleButton.Visible = false
    MainFrame.Visible = true
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = TweenService:Create(MainFrame, tweenInfo, {Size = UDim2.new(0, 400, 0, 620), BackgroundTransparency = 0.25})
    tween:Play()
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ปุ่ม Start / Stop
StartBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    notifiedMoney = false
    notifiedFrag = false
    notifiedMastery = false
    
    if isRunning then
        StartBtn.Text = "หยุดทำงาน (STOP)"
        StartBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
        StatusLabel.Text = "สถานะ: กำลังฟาร์ม"
        StatusLabel.TextColor3 = Color3.fromRGB(80, 220, 120)
        startTime = tick()
        
        local startTimeFormatted = os.date("%H:%M:%S")
        sendLineBotMessage(getReportMessage("เริ่มฟาร์ม", 0, startTimeFormatted))
    else
        StartBtn.Text = "เริ่มทำงาน (START)"
        StartBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
        StatusLabel.Text = "สถานะ: หยุดทำงาน"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        local elapsed = math.floor(tick() - startTime)
        sendLineBotMessage(getReportMessage("หยุดสคริปต์", elapsed, ""))
    end
end)

-- ลูปเช็คค่าสถานะและเงื่อนไขเป้าหมายแยกตามสวิตช์
RunService.RenderStepped:Connect(function()
    if isRunning then
        local elapsed = math.floor(tick() - startTime)
        local hours = math.floor(elapsed / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local seconds = elapsed % 60
        TimerLabel.Text = string.format("เวลาที่ใช้ไป: %02d:%02d:%02d", hours, minutes, seconds)

        local data = LocalPlayer:FindFirstChild("Data")
        if data then
            local beli = data:FindFirstChild("Beli") and data.Beli.Value or 0
            local fragments = data:FindFirstChild("Fragments") and data.Fragments.Value or 0
            
            local targetMoney = (MoneyBox.Text ~= "" and tonumber(MoneyBox.Text)) or nil
            local targetFrag = (FragmentBox.Text ~= "" and tonumber(FragmentBox.Text)) or nil
            local targetMasteryX = (MasteryBox.Text ~= "" and tonumber(MasteryBox.Text)) or nil
            
            local function checkEquippedMastery(targetMasX)
                local character = LocalPlayer.Character
                if not character then return false, 0, "ไม่มี" end
                
                local slotNum = tonumber(WeaponSlotBox.Text)
                local equippedTool = nil
                if slotNum then
                    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
                    if backpack then
                        local tools = {}
                        for _, t in ipairs(backpack:GetChildren()) do
                            if t:IsA("Tool") then
                                table.insert(tools, t)
                            end
                        end
                        if tools[slotNum] then
                            equippedTool = tools[slotNum]
                        end
                    end
                end
                if not equippedTool then
                    equippedTool = character:FindFirstChildOfClass("Tool")
                end
                
                if not equippedTool then return false, 0, "ไม่มี" end
                
                local currentMasA = 0
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if playerGui then
                    for _, descendant in ipairs(playerGui:GetDescendants()) do
                        if descendant:IsA("TextLabel") then
                            local text = descendant.Text
                            if string.find(text, "Mastery") or string.find(text, "Mas") then
                                local num = tonumber(string.match(text, "%d+"))
                                if num and num > 9 and num <= 600 then
                                    currentMasA = num
                                    break
                                end
                            end
                        end
                    end
                end
                if currentMasA == 0 then
                    if equippedTool:FindFirstChild("Level") then
                        currentMasA = equippedTool.Level.Value
                    elseif equippedTool:FindFirstChild("Mastery") then
                        currentMasA = equippedTool.Mastery.Value
                    end
                end
                if currentMasA >= targetMasX then
                    return true, currentMasA, equippedTool.Name
                end
                return false, currentMasA, equippedTool.Name
            end
            
            -- 1. เช็คเป้าหมายเงิน
            if targetMoney and targetMoney > 0 and beli >= targetMoney and not notifiedMoney then
                notifiedMoney = true
                local reason = "บรรลุเป้าหมายเงิน: " .. targetMoney
                if MoneyKickToggle.GetValue() then
                    -- เปิดสวิตช์: ส่ง LINE แล้วเตะออกเกม
                    StatusLabel.Text = "สถานะ: สำเร็จเป้าหมายเงิน (กำลังเตะ...)"
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
                    sendLineBotMessage(getReportMessage("🎉 บรรลุเป้าหมาย! (" .. reason .. ")", elapsed, ""))
                    task.wait(1.5)
                    LocalPlayer:Kick("\n[Blox Fruits UI] ทำภารกิจสำเร็จ: " .. reason)
                else
                    -- ปิดสวิตช์: ส่ง LINE แจ้งเตือนเฉยๆ ไม่เตะ
                    sendLineBotMessage(getReportMessage("🔔 แจ้งเตือน: " .. reason, elapsed, ""))
                end
            end
            
            -- 2. เช็คเป้าหมาย Fragment
            if targetFrag and targetFrag > 0 and fragments >= targetFrag and not notifiedFrag then
                notifiedFrag = true
                local reason = "บรรลุเป้าหมาย Fragment: " .. targetFrag
                if FragKickToggle.GetValue() then
                    StatusLabel.Text = "สถานะ: สำเร็จเป้าหมาย Fragment (กำลังเตะ...)"
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
                    sendLineBotMessage(getReportMessage("🎉 บรรลุเป้าหมาย! (" .. reason .. ")", elapsed, ""))
                    task.wait(1.5)
                    LocalPlayer:Kick("\n[Blox Fruits UI] ทำภารกิจสำเร็จ: " .. reason)
                else
                    sendLineBotMessage(getReportMessage("🔔 แจ้งเตือน: " .. reason, elapsed, ""))
                end
            end
            
            -- 3. เช็คเป้าหมาย Mastery อาวุธ
            if targetMasteryX and targetMasteryX > 0 and not notifiedMastery then
                local isReady, currentA, weaponName = checkEquippedMastery(targetMasteryX)
                if isReady then
                    notifiedMastery = true
                    local reason = "อาวุธ [" .. weaponName .. "] ถึง Mastery: " .. targetMasteryX
                    if MasteryKickToggle.GetValue() then
                        StatusLabel.Text = "สถานะ: สำเร็จเป้าหมาย Mastery (กำลังเตะ...)"
                        StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
                        sendLineBotMessage(getReportMessage("🎉 บรรลุเป้าหมาย! (" .. reason .. ")", elapsed, ""))
                        task.wait(1.5)
                        LocalPlayer:Kick("\n[Blox Fruits UI] ทำภารกิจสำเร็จ: " .. reason)
                    else
                        sendLineBotMessage(getReportMessage("🔔 แจ้งเตือน: " .. reason, elapsed, ""))
                    end
                end
            end
        end
    end
end)
