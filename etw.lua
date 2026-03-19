_G.AutoGrabEat = false
_G.AutoSell = false
_G.AutoUpgrade = false
_G.AutoReward = false
_G.EatSpeed = 7
_G.SellSize = 200

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- ===== GUI =====
local gui = Instance.new("ScreenGui", game.CoreGui)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 270)
frame.Position = UDim2.new(0, 50, 0, 200)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)

local function createButton(text, posY)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.Position = UDim2.new(0, 5, 0, posY)
    btn.Text = text.." : OFF"
    btn.BackgroundColor3 = Color3.fromRGB(150,0,0)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    return btn
end

local grabBtn = createButton("Auto Eat", 5)
local sellBtn = createButton("Auto Sell", 50)
local upgBtn = createButton("Auto Upgrade", 95)
local rewardBtn = createButton("Auto Reward", 140)

local function toggle(var, btn)
    _G[var] = not _G[var]
    if _G[var] then
        btn.Text = btn.Text:gsub("OFF","ON")
        btn.BackgroundColor3 = Color3.fromRGB(0,170,0)
    else
        btn.Text = btn.Text:gsub("ON","OFF")
        btn.BackgroundColor3 = Color3.fromRGB(150,0,0)
    end
end

grabBtn.MouseButton1Click:Connect(function() toggle("AutoGrabEat", grabBtn) end)
sellBtn.MouseButton1Click:Connect(function() toggle("AutoSell", sellBtn) end)
upgBtn.MouseButton1Click:Connect(function() toggle("AutoUpgrade", upgBtn) end)
rewardBtn.MouseButton1Click:Connect(function() toggle("AutoReward", rewardBtn) end)

-- ===== ตั้งค่า Size =====
local sizeBox = Instance.new("TextBox", frame)
sizeBox.Size = UDim2.new(1, -10, 0, 35)
sizeBox.Position = UDim2.new(0, 5, 0, 185)
sizeBox.Text = "Set: ".._G.SellSize
sizeBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
sizeBox.TextColor3 = Color3.new(1,1,1)
sizeBox.TextScaled = true

sizeBox.FocusLost:Connect(function()
    local num = tonumber(sizeBox.Text)
    if num then
        _G.SellSize = num
        sizeBox.Text = "Set: "..num
    else
        sizeBox.Text = "Invalid!"
    end
end)

-- ===== ลาก GUI =====
local dragging, dragInput, startPos, startFramePos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        startPos = input.Position
        startFramePos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - startPos
        frame.Position = UDim2.new(
            startFramePos.X.Scale,
            startFramePos.X.Offset + delta.X,
            startFramePos.Y.Scale,
            startFramePos.Y.Offset + delta.Y
        )
    end
end)

-- ===== ICON (ลากได้) =====
local toggleIcon = Instance.new("TextButton", gui)
toggleIcon.Size = UDim2.new(0, 50, 0, 50)
toggleIcon.Position = UDim2.new(0, 10, 0, 150)
toggleIcon.BackgroundColor3 = Color3.fromRGB(0,170,255)
toggleIcon.Text = "≡"
toggleIcon.TextScaled = true
toggleIcon.Visible = false

toggleIcon.MouseButton1Click:Connect(function()
    frame.Visible = true
    toggleIcon.Visible = false
end)

-- ลาก icon
local iconDragging, iconDragInput, iconStartPos, iconStartFramePos

toggleIcon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        iconDragging = true
        iconStartPos = input.Position
        iconStartFramePos = toggleIcon.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                iconDragging = false
            end
        end)
    end
end)

toggleIcon.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        iconDragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if iconDragging and input == iconDragInput then
        local delta = input.Position - iconStartPos
        toggleIcon.Position = UDim2.new(
            iconStartFramePos.X.Scale,
            iconStartFramePos.X.Offset + delta.X,
            iconStartFramePos.Y.Scale,
            iconStartFramePos.Y.Offset + delta.Y
        )
    end
end)

-- ===== ปุ่ม K =====
local guiVisible = true
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.K then
        guiVisible = not guiVisible
        frame.Visible = guiVisible
        toggleIcon.Visible = not guiVisible
    end
end)

-- ===== Events =====
local function getEvents()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local events = char:FindFirstChild("Events")
    if not events then return end

    return events:FindFirstChild("Grab"),
           events:FindFirstChild("Eat"),
           events:FindFirstChild("Sell"),
           events:FindFirstChild("Upgrade")
end

-- ===== Loop =====
task.spawn(function()
    while task.wait(0.1) do
        local Grab, Eat, Sell, Upgrade = getEvents()

        if _G.AutoGrabEat then
            if Grab then Grab:FireServer(false,false) end
            if Eat then
                for i = 1,_G.EatSpeed do
                    Eat:FireServer()
                    task.wait(0.02)
                end
            end
        end

        if _G.AutoUpgrade and Upgrade then
            Upgrade:FireServer("Size")
            Upgrade:FireServer("Speed")
        end
    end
end)

-- ===== Smart Sell =====
task.spawn(function()
    while task.wait(0.2) do
        if not _G.AutoSell then continue end

        local stats = LocalPlayer:FindFirstChild("leaderstats")
        local char = LocalPlayer.Character
        if not stats or not char then continue end

        local events = char:FindFirstChild("Events")
        local Sell = events and events:FindFirstChild("Sell")
        if not Sell then continue end

        local size = stats:FindFirstChild("Size")

        if size and size.Value >= _G.SellSize then
            Sell:FireServer()
        end
    end
end)

-- ===== Auto Reward =====
task.spawn(function()
    while task.wait(3) do
        if _G.AutoReward then
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui then
                for _,v in pairs(playerGui:GetDescendants()) do
                    if v:IsA("TextButton") or v:IsA("ImageButton") then
                        if v.Visible and v.Active then
                            if string.find(string.lower(v.Name), "claim")
                            or string.find(string.lower(v.Text or ""), "claim") then
                                pcall(function()
                                    v:Activate()
                                end)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ===== กันค้าง =====
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
--[[
batus made this i just forked
]]

repeat wait() until game:IsLoaded() and game.Players and game.Players.LocalPlayer and game.Players.LocalPlayer.Character

if getgenv().AntiAfkExecuted and thisoneissocoldww then 
    getgenv().AntiAfkExecuted = false
	getgenv().zamanbaslaticisi = false
	game.CoreGui.thisoneissocoldww:Destroy()
end

getgenv().AntiAfkExecuted = true

local thisoneissocoldww = Instance.new("ScreenGui")
local madebybloodofbatus = Instance.new("Frame")
local UICornerw = Instance.new("UICorner")
local DestroyButton = Instance.new("TextButton")
local uselesslabelone = Instance.new("TextLabel")
local timerlabel = Instance.new("TextLabel")
local uselesslabeltwo = Instance.new("TextLabel")
local fpslabel = Instance.new("TextLabel")
local uselesslabelthree = Instance.new("TextLabel")
local pinglabel = Instance.new("TextLabel")
local uselessframeone = Instance.new("Frame")
local UICornerww = Instance.new("UICorner")
local uselesslabelfour = Instance.new("TextLabel")

--Properties:

thisoneissocoldww.Name = "thisoneissocoldww"
thisoneissocoldww.Parent = game.CoreGui
thisoneissocoldww.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

madebybloodofbatus.Name = "madebybloodofbatus"
madebybloodofbatus.Parent = thisoneissocoldww
madebybloodofbatus.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
madebybloodofbatus.Position = UDim2.new(0.0854133144, 0, 0.13128835, 0)
madebybloodofbatus.Size = UDim2.new(0, 225, 0, 96)

UICornerw.Name = "UICornerw"
UICornerw.Parent = madebybloodofbatus

DestroyButton.Name = "DestroyButton"
DestroyButton.Parent = madebybloodofbatus
DestroyButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
DestroyButton.BackgroundTransparency = 1.000
DestroyButton.Position = UDim2.new(0.871702373, 0, 0.0245379955, 0)
DestroyButton.Size = UDim2.new(0, 27, 0, 15)
DestroyButton.Font = Enum.Font.SourceSans
DestroyButton.Text = "X"
DestroyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DestroyButton.TextSize = 14.000

DestroyButton.MouseButton1Click:connect(function()
	getgenv().AntiAfkExecuted = false
	
	wait(0.1)
	thisoneissocoldww:Destroy()
end)

uselesslabelone.Name = "uselesslabelone"
uselesslabelone.Parent = madebybloodofbatus
uselesslabelone.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
uselesslabelone.BackgroundTransparency = 1.000
uselesslabelone.Position = UDim2.new(0.302473009, 0, 0, 0)
uselesslabelone.Size = UDim2.new(0, 95, 0, 24)
uselesslabelone.Font = Enum.Font.SourceSans
uselesslabelone.Text = "Anti Afk V1 By Evxn#6765"
uselesslabelone.TextColor3 = Color3.fromRGB(255, 255, 255)
uselesslabelone.TextSize = 14.000

timerlabel.Name = "timerlabel"
timerlabel.Parent = madebybloodofbatus
timerlabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
timerlabel.BackgroundTransparency = 1.000
timerlabel.Position = UDim2.new(0.65344125, 0, 0.68194294, 0)
timerlabel.Size = UDim2.new(0, 60, 0, 24)
timerlabel.Font = Enum.Font.SourceSans
timerlabel.Text = "0:0:0"
timerlabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timerlabel.TextSize = 14.000

uselesslabeltwo.Name = "uselesslabeltwo"
uselesslabeltwo.Parent = madebybloodofbatus
uselesslabeltwo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
uselesslabeltwo.BackgroundTransparency = 1.000
uselesslabeltwo.Position = UDim2.new(0.038864471, 0, 0.373806685, 0)
uselesslabeltwo.Size = UDim2.new(0, 29, 0, 24)
uselesslabeltwo.Font = Enum.Font.SourceSans
uselesslabeltwo.Text = "Ping: "
uselesslabeltwo.TextColor3 = Color3.fromRGB(255, 255, 255)
uselesslabeltwo.TextSize = 14.000

fpslabel.Name = "fpslabel"
fpslabel.Parent = madebybloodofbatus
fpslabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
fpslabel.BackgroundTransparency = 1.000
fpslabel.Position = UDim2.new(0.724226236, 0, 0.358796299, 0)
fpslabel.Size = UDim2.new(0, 55, 0, 24)
fpslabel.Font = Enum.Font.SourceSans
fpslabel.Text = "this contact dev"
fpslabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fpslabel.TextSize = 14.000

uselesslabelthree.Name = "uselesslabelthree"
uselesslabelthree.Parent = madebybloodofbatus
uselesslabelthree.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
uselesslabelthree.BackgroundTransparency = 1.000
uselesslabelthree.Position = UDim2.new(0.506917477, 0, 0.352585167, 0)
uselesslabelthree.Size = UDim2.new(0, 26, 0, 24)
uselesslabelthree.Font = Enum.Font.SourceSans
uselesslabelthree.Text = "Fps: "
uselesslabelthree.TextColor3 = Color3.fromRGB(255, 255, 255)
uselesslabelthree.TextSize = 14.000

pinglabel.Name = "pinglabel"
pinglabel.Parent = madebybloodofbatus
pinglabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
pinglabel.BackgroundTransparency = 1.000
pinglabel.Position = UDim2.new(0.20330891, 0, 0.371578127, 0)
pinglabel.Size = UDim2.new(0, 55, 0, 24)
pinglabel.Font = Enum.Font.SourceSans
pinglabel.Text = "if you see this"
pinglabel.TextColor3 = Color3.fromRGB(255, 255, 255)
pinglabel.TextSize = 14.000
pinglabel.TextWrapped = true

uselessframeone.Name = "uselessframeone"
uselessframeone.Parent = madebybloodofbatus
uselessframeone.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
uselessframeone.Position = UDim2.new(0.00444444455, 0, 0.243312627, 0)
uselessframeone.Size = UDim2.new(0, 224, 0, 5)

UICornerww.CornerRadius = UDim.new(0, 50)
UICornerww.Name = "UICornerww"
UICornerww.Parent = uselessframeone

uselesslabelfour.Name = "uselesslabelfour"
uselesslabelfour.Parent = madebybloodofbatus
uselesslabelfour.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
uselesslabelfour.BackgroundTransparency = 1.000
uselesslabelfour.Position = UDim2.new(0.0580285639, 0, 0.8125, 0)
uselesslabelfour.Size = UDim2.new(0, 95, 0, 12)
uselesslabelfour.Font = Enum.Font.SourceSans
uselesslabelfour.Text = "Anti-Afk Auto Enabled"
uselesslabelfour.TextColor3 = Color3.fromRGB(255, 255, 255)
uselesslabelfour.TextSize = 14.000



local Drag = game.CoreGui.thisoneissocoldww.madebybloodofbatus
gsCoreGui = game:GetService("CoreGui")
gsTween = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local dragging
local dragInput
local dragStart
local startPos
local function update(input)
	local delta = input.Position - dragStart
	local dragTime = 0.04
	local SmoothDrag = {}
	SmoothDrag.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	local dragSmoothFunction = gsTween:Create(Drag, TweenInfo.new(dragTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), SmoothDrag)
	dragSmoothFunction:Play()
end
Drag.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = Drag.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)
Drag.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging and Drag.Size then
		update(input)
	end
end)



local bbbatusxxxddddd = game:service'VirtualUser'

game:service'Players'.LocalPlayer.Idled:connect(function()
	bbbatusxxxddddd:CaptureController()
	bbbatusxxxddddd:ClickButton2(Vector2.new())
end)




local FPSsLabel = fpslabel
local RunService = game:GetService("RunService")
local RenderStepped = RunService.RenderStepped
local sec = nil
local FPS = {}

local function fre()
	local fr = tick()
	for index = #FPS,1,-1 do
		FPS[index + 1] = (FPS[index] >= fr - 1) and FPS[index] or nil
	end
	FPS[1] = fr
	local fps = (tick() - sec >= 1 and #FPS) or (#FPS / (tick() - sec))
	fps = math.floor(fps)
	fpslabel.Text = fps
end


sec = tick()
RenderStepped:Connect(fre)




spawn(function()
	repeat
		wait(1)
		local ping = tonumber(game:GetService("Stats"):FindFirstChild("PerformanceStats").Ping:GetValue())
		ping = math.floor(ping)
		pinglabel.Text = ping



	until pinglabel == nil
end)

local saniye = 0



local dakika = 0



local saat = 0




getgenv().zamanbaslaticisi = true

while true do


		if getgenv().zamanbaslaticisi then

			saniye = saniye + 1

			wait(1)

		end --if zaman baslaticisi end


		if saniye >= 60 then
			saniye = 0
			dakika = dakika + 1

		end --if saniye 60 end


		if dakika >= 60 then
			dakika = 0
			saat = saat + 1

		end --if dakika 60 end

		timerlabel.Text = saat..":"..dakika..":"..saniye
	end
