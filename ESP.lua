-- Toggle ESP (กด K) + ใช้สคริปเดิมของคุณ

_G.FriendColor = Color3.fromRGB(0, 0, 255)
_G.EnemyColor = Color3.fromRGB(255, 0, 0)
_G.UseTeamColor = true

local ESP_ENABLED = false
local TOGGLE_KEY = Enum.KeyCode.K

local players = game:GetService("Players")
local plr = players.LocalPlayer
local UIS = game:GetService("UserInputService")

-- ================= ESP หลัก =================
local Holder = Instance.new("Folder", game.CoreGui)
Holder.Name = "ESP"

local Box = Instance.new("BoxHandleAdornment")
Box.Size = Vector3.new(1, 2, 1)
Box.Transparency = 0.7
Box.AlwaysOnTop = false
Box.Visible = false

local NameTag = Instance.new("BillboardGui")
NameTag.Size = UDim2.new(0, 200, 0, 50)
NameTag.AlwaysOnTop = true
NameTag.StudsOffset = Vector3.new(0, 1.8, 0)

local Tag = Instance.new("TextLabel", NameTag)
Tag.BackgroundTransparency = 1
Tag.Position = UDim2.new(0, -50, 0, 0)
Tag.Size = UDim2.new(0, 300, 0, 20)
Tag.TextSize = 15
Tag.TextStrokeTransparency = 0.4
Tag.Font = Enum.Font.SourceSansBold

-- ================= ฟังก์ชัน =================
local function getColor(v)
	if _G.UseTeamColor then
		return v.TeamColor.Color
	else
		return (plr.TeamColor == v.TeamColor) and _G.FriendColor or _G.EnemyColor
	end
end

local function ClearAll()
	for _, v in pairs(Holder:GetChildren()) do
		v:Destroy()
	end
	for _, v in pairs(players:GetPlayers()) do
		if v.Character and v.Character:FindFirstChild("GetReal") then
			v.Character.GetReal:Destroy()
		end
	end
end

local function LoadCharacter(v)
	if not ESP_ENABLED then return end
	repeat task.wait() until v.Character ~= nil
	v.Character:WaitForChild("Humanoid")

	local vHolder = Holder:FindFirstChild(v.Name) or Instance.new("Folder", Holder)
	vHolder.Name = v.Name
	vHolder:ClearAllChildren()

	local b = Box:Clone()
	b.Adornee = v.Character
	b.Color3 = getColor(v)
	b.Visible = true
	b.Parent = vHolder

	local t = NameTag:Clone()
	t.Enabled = true
	t.Adornee = v.Character:WaitForChild("Head", 5)
	t.Tag.Text = v.Name
	t.Tag.TextColor3 = getColor(v)
	t.Parent = vHolder
end

local function LoadPlayer(v)
	if v == plr then return end
	
	local function char()
		if ESP_ENABLED then
			pcall(LoadCharacter, v)
		end
	end
	
	v.CharacterAdded:Connect(char)
	v:GetPropertyChangedSignal("TeamColor"):Connect(char)
	
	if v.Character then
		char()
	end
end

-- Highlight ESP (ตัวเดิม)
local function esp(target, color)
	if target.Character then
		if not target.Character:FindFirstChild("GetReal") then
			local h = Instance.new("Highlight")
			h.Name = "GetReal"
			h.Adornee = target.Character
			h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			h.FillColor = color
			h.Parent = target.Character
		else
			target.Character.GetReal.FillColor = color
		end
	end
end

-- ================= Toggle =================
UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	
	if input.KeyCode == TOGGLE_KEY then
		ESP_ENABLED = not ESP_ENABLED
		
		if ESP_ENABLED then
			print("ESP: ON")
			
			-- โหลดผู้เล่นทั้งหมด
			for _, v in pairs(players:GetPlayers()) do
				LoadPlayer(v)
			end
		else
			print("ESP: OFF")
			ClearAll()
		end
	end
end)

-- ================= Loop =================
task.spawn(function()
	while task.wait(0.3) do
		if ESP_ENABLED then
			for _, v in pairs(players:GetPlayers()) do
				if v ~= plr then
					esp(v, getColor(v))
				end
			end
		end
	end
end)

-- Player join/leave
players.PlayerAdded:Connect(function(v)
	if ESP_ENABLED then
		LoadPlayer(v)
	end
end)

players.PlayerRemoving:Connect(function(v)
	local f = Holder:FindFirstChild(v.Name)
	if f then f:Destroy() end
end)
