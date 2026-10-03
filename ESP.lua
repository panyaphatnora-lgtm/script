-- Toggle ESP (กด K) + แสดงชื่อ, กล่อง และ Highlight ครบถ้วน

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
Box.AlwaysOnTop = true -- ตั้งค่าให้มองเห็นทะลุสิ่งกีดขวาง
Box.Visible = false

local NameTag = Instance.new("BillboardGui")
NameTag.Size = UDim2.new(0, 200, 0, 50)
NameTag.AlwaysOnTop = true
NameTag.StudsOffset = Vector3.new(0, 2.5, 0) -- ขยับขึ้นไปด้านบนหัวเล็กน้อย

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

-- Highlight ESP
local function esp(target, color)
	if target.Character then
		local colorToUse = color or getColor(target)
		if not target.Character:FindFirstChild("GetReal") then
			local h = Instance.new("Highlight")
			h.Name = "GetReal"
			h.Adornee = target.Character
			h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			h.FillColor = colorToUse
			h.Parent = target.Character
		else
			target.Character.GetReal.FillColor = colorToUse
		end
	end
end

local function LoadCharacter(v)
	if not ESP_ENABLED or v == plr then return end
	if not v.Character or not v.Character:FindFirstChild("HumanoidRootPart") then return end

	local vHolder = Holder:FindFirstChild(v.Name) or Instance.new("Folder", Holder)
	vHolder.Name = v.Name
	vHolder:ClearAllChildren()

	local targetColor = getColor(v)

	-- สร้าง Box
	local b = Box:Clone()
	b.Adornee = v.Character
	b.Color3 = targetColor
	b.Visible = true
	b.Parent = vHolder

	-- สร้าง NameTag
	local head = v.Character:FindFirstChild("Head")
	if head then
		local t = NameTag:Clone()
		t.Enabled = true
		t.Adornee = head
		t.Tag.Text = v.Name
		t.Tag.TextColor3 = targetColor
		t.Parent = vHolder
	end

	-- สร้าง Highlight
	esp(v, targetColor)
end

local function LoadPlayer(v)
	if v == plr then return end
	
	local function char()
		if ESP_ENABLED then
			task.wait(0.5) -- รอให้โมเดลตัวละครโหลดเสร็จสมบูรณ์
			pcall(LoadCharacter, v)
		end
	end
	
	v.CharacterAdded:Connect(char)
	v:GetPropertyChangedSignal("TeamColor"):Connect(char)
	
	if v.Character then
		char()
	end
end

-- ================= Toggle =================
UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	
	if input.KeyCode == TOGGLE_KEY then
		ESP_ENABLED = not ESP_ENABLED
		
		if ESP_ENABLED then
			print("ESP: ON")
			for _, v in pairs(players:GetPlayers()) do
				LoadPlayer(v)
			end
		else
			print("ESP: OFF")
			ClearAll()
		end
	end
end)

-- ================= Loop คอยอัปเดต =================
task.spawn(function()
	while task.wait(0.5) do
		if ESP_ENABLED then
			for _, v in pairs(players:GetPlayers()) do
				if v ~= plr then
					if v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
						-- ถ้ายังไม่มี Folder หรือ NameTag ให้สร้างใหม่ (กรณีรีสawn)
						if not Holder:FindFirstChild(v.Name) or not v.Character:FindFirstChild("GetReal") then
							LoadCharacter(v)
						else
							-- อัปเดตสีตามทีมแบบเรียลไทม์
							local currentTeamColor = getColor(v)
							local f = Holder:FindFirstChild(v.Name)
							if f then
								if f:FindFirstChildOfClass("BoxHandleAdornment") then
									f:FindFirstChildOfClass("BoxHandleAdornment").Color3 = currentTeamColor
								end
								if f:FindFirstChildOfClass("BillboardGui") then
									f:FindFirstChildOfClass("BillboardGui").Tag.TextColor3 = currentTeamColor
								end
							end
							esp(v, currentTeamColor)
						end
					end
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
