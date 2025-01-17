-- Biến xác định trạng thái cooldown (chờ sau khi dash)
local onCooldown = false
local cooldownDuration = 0.5 -- Thời gian trước khi có thể dash lại

-- Thông số dash (tốc độ và thời lượng)
local dashSpeed = 50 -- Tốc độ của dash
local dashDuration = 0.5 -- Thời gian kéo dài của dash

-- Phím để thực hiện dash
local dashKeys = {Enum.KeyCode.Q} -- Danh sách phím bạn có thể nhấn để dash

-- Nút dash trên giao diện di động
local dashMobileButton
local mobileButtonImage = "rbxassetid://13213984187" -- ID hình ảnh cho nút dash trên di động
local mobileButtonPosition = UDim2.new(1, -125, 1, -125) -- Vị trí nút dash trên màn hình
local normalImageColor = Color3.new(1, 1, 1) -- Màu khi nút dash có sẵn
local cooldownImageColor = Color3.new(0.2, 0.2, 0.2) -- Màu khi nút dash đang cooldown

-- Tăng FOV khi dash
local dashFOVIncrease = 15 -- Lượng tăng FOV khi dash
local defaultFOV

-- Dịch vụ cần thiết
local cas = game:GetService("ContextActionService")
local dashActionName = "DASH_ACTION"

-- Tham chiếu camera và nhân vật
local camera = workspace.CurrentCamera
defaultFOV = camera.FieldOfView

local char = script.Parent
local root = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

-- Tạo LinearVelocity và Attachment cho dash
local attachment = Instance.new("Attachment")
attachment.Name = "DashAttachment0"
attachment.Parent = root

local linearVelocity = Instance.new("LinearVelocity")
linearVelocity.Attachment0 = attachment
linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
linearVelocity.PrimaryTangentAxis = Vector3.new(1, 0, 0)
linearVelocity.SecondaryTangentAxis = Vector3.new(0, 0, 1)
linearVelocity.MaxForce = math.huge
linearVelocity.Enabled = false
linearVelocity.Parent = root

-- Animation và âm thanh dash
local dashAnimation = script:WaitForChild("DashAnimation")
local animationTrack:AnimationTrack = humanoid:WaitForChild("Animator"):LoadAnimation(dashAnimation)
animationTrack.Priority = Enum.AnimationPriority.Action
animationTrack:AdjustSpeed(animationTrack.Length / dashDuration)

local dashSound = script:WaitForChild("DashSound")
dashSound.Parent = root

-- RaycastParams để kiểm tra va chạm khi dash
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {char}
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

-- Hàm nội suy giá trị giữa hai điểm
function Lerp(a, b, t)
	return a + (b - a) * t
end

-- Kiểm tra xem dash có được phép không
function IsDashAllowed(actionName: string, inputState: Enum.UserInputState)
	if onCooldown then return end -- Nếu đang cooldown, không thể dash
	if actionName ~= dashActionName then return end -- Đảm bảo đúng tên hành động
	if inputState ~= Enum.UserInputState.Begin then return end -- Chỉ cho phép khi bắt đầu nhấn phím
	return true
end

-- Lấy hướng và vận tốc dash
function GetDashVelocity()
	local vectorMask = Vector3.new(1, 0, 1) -- Chỉ lấy thành phần X và Z
	local direction = root.AssemblyLinearVelocity * vectorMask -- Hướng dựa trên vận tốc hiện tại
	if direction.Magnitude <= 0.1 then
		direction = camera.CFrame.LookVector * vectorMask -- Nếu không di chuyển, sử dụng hướng camera
	end
	direction = direction.Unit
	local planeDirection = Vector2.new(direction.X, direction.Z)
	local dashVelocity = planeDirection * dashSpeed
	return dashVelocity
end

-- Xử lý cooldown sau khi dash
function HandleCooldown()
	if dashMobileButton then
		dashMobileButton.ImageColor3 = cooldownImageColor
	end
	local cooldownStarted = tick()
	while tick() - cooldownStarted < cooldownDuration do
		game:GetService("RunService").Heartbeat:Wait()
	end
	camera.FieldOfView = defaultFOV
	if dashMobileButton then
		dashMobileButton.ImageColor3 = normalImageColor
	end
	onCooldown = false
end

-- Xử lý dash và hiệu ứng
function HandleDashDuration()
	local dashStarted = tick()
	local startFOV = camera.FieldOfView
	local goalFOV = defaultFOV + dashFOVIncrease
	while tick() - dashStarted < dashDuration do
		game:GetService("RunService").Heartbeat:Wait()
		if camera.FieldOfView < goalFOV then
			camera.FieldOfView = Lerp(camera.FieldOfView, goalFOV, 0.2)
		end
	end
end

-- Hiệu ứng dash
function DashEffects()
	animationTrack:Play()
	dashSound:Play()
end

-- Kích hoạt LinearVelocity để thực hiện dash
function EnableLinearVelocity(dashVelocity: Vector2)
	linearVelocity.PlaneVelocity = dashVelocity
	linearVelocity.Enabled = true
	humanoid.AutoRotate = false
end

-- Vô hiệu hóa LinearVelocity sau dash
function DisableLinearVelocity()
	linearVelocity.Enabled = false
	humanoid.AutoRotate = true
end

-- Hàm chính thực hiện dash
function Dash(actionName: string, inputState: Enum.UserInputState)
	if IsDashAllowed(actionName, inputState) then
		onCooldown = true
		task.spawn(HandleCooldown)
		local dashVelocity = GetDashVelocity()
		EnableLinearVelocity(dashVelocity)
		DashEffects()
		HandleDashDuration()
		DisableLinearVelocity()
	end
end

-- Kết nối phím dash
cas:BindAction(dashActionName, Dash, true, unpack(dashKeys))
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local dashGui = Instance.new("ScreenGui")
dashGui.Name = "DashGUI"
dashGui.Parent = playerGui

local dashButton = Instance.new("TextButton")
dashButton.Name = "DashButton"
dashButton.Size = UDim2.new(0, 150, 0, 50)
dashButton.Position = UDim2.new(0.5, -75, 0.8, 0) -- Vị trí giữa màn hình
dashButton.BackgroundColor3 = Color3.new(0.1, 0.6, 0.8)
dashButton.Text = "Dash"
dashButton.Font = Enum.Font.SourceSansBold
dashButton.TextSize = 20
dashButton.TextColor3 = Color3.new(1, 1, 1)
dashButton.Parent = dashGui

--iiiiiiii

local gui = Instance.new("ScreenGui")
gui.Name = "DraggableGUI"
gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "DraggableFrame"
frame.Size = UDim2.new(0, 200, 0, 150)
frame.Position = UDim2.new(0, 100, 0, 100)
frame.BackgroundTransparency = 0.4
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Visible = true -- Giao diện bắt đầu hiển thị
frame.Parent = gui

-- Nút bật/tắt InfJump
local infJumpButton = Instance.new("TextButton")
infJumpButton.Name = "InfJumpButton"
infJumpButton.Size = UDim2.new(0.8, 0, 0, 30)
infJumpButton.Position = UDim2.new(0.1, 0, 0.2, -15)
infJumpButton.BackgroundColor3 = Color3.new(0, 0.5, 1)
infJumpButton.Font = Enum.Font.SourceSans
infJumpButton.TextColor3 = Color3.new(1, 1, 1)
infJumpButton.TextSize = 14
infJumpButton.Text = "Bật InfJump"
infJumpButton.Parent = frame

-- Nút bật/tắt Noclip
local noclipButton = Instance.new("TextButton")
noclipButton.Name = "NoclipButton"
noclipButton.Size = UDim2.new(0.8, 0, 0, 30)
noclipButton.Position = UDim2.new(0.1, 0, 0.6, -15)
noclipButton.BackgroundColor3 = Color3.new(1, 0, 0)
noclipButton.Font = Enum.Font.SourceSans
noclipButton.TextColor3 = Color3.new(1, 1, 1)
noclipButton.TextSize = 14
noclipButton.Text = "Bật Noclip"
noclipButton.Parent = frame

-- Nhãn tác giả
local label = Instance.new("TextLabel")
label.Name = "CreatorLabel"
label.Size = UDim2.new(0, 200, 0, 20)
label.Position = UDim2.new(0, 0, 0, -20)
label.BackgroundTransparency = 1
label.Font = Enum.Font.SourceSansBold
label.TextColor3 = Color3.new(1, 1, 1)
label.TextSize = 14
label.Text = "Made by IAB"
label.Parent = frame

-- Trạng thái cho InfJump và Noclip
local infiniteJumpEnabled = false
local noclipEnabled = false

-- Hàm bật/tắt InfJump
local function toggleInfJump()
	infiniteJumpEnabled = not infiniteJumpEnabled
	infJumpButton.Text = infiniteJumpEnabled and "Tắt InfJump" or "Bật InfJump" 
end

-- Hàm bật/tắt Noclip
local function toggleNoclip()
	noclipEnabled = not noclipEnabled
	noclipButton.Text = noclipEnabled and "Tắt Noclip" or "Bật Noclip" 
end

-- Kết nối các nút với hàm
infJumpButton.MouseButton1Click:Connect(toggleInfJump)
noclipButton.MouseButton1Click:Connect(toggleNoclip)

-- Xử lý InfJump
game:GetService("UserInputService").JumpRequest:Connect(function()
	if infiniteJumpEnabled then
		game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
	end
end)

-- Xử lý Noclip
game:GetService("RunService").Stepped:Connect(function()
	if noclipEnabled then
		local character = game.Players.LocalPlayer.Character
		if character then
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") and part.CanCollide then
					part.CanCollide = false -- Tắt va chạm
				end
			end
		end
	end
end)

-- Nút bật/tắt menu
local toggleMenuButton = Instance.new("TextButton")
toggleMenuButton.Name = "ToggleMenuButton"
toggleMenuButton.Size = UDim2.new(0, 100, 0, 30)
toggleMenuButton.Position = UDim2.new(0, 10, 0, 10) -- Góc trái trên cùng
toggleMenuButton.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
toggleMenuButton.Font = Enum.Font.SourceSans
toggleMenuButton.TextColor3 = Color3.new(1, 1, 1)
toggleMenuButton.TextSize = 14
toggleMenuButton.Text = "Ẩn Menu"
toggleMenuButton.Parent = gui

-- Trạng thái hiển thị menu
local isMenuVisible = true

-- Hàm bật/tắt hiển thị menu
local function toggleMenu()
	isMenuVisible = not isMenuVisible
	frame.Visible = isMenuVisible
	toggleMenuButton.Text = isMenuVisible and "Ẩn Menu" or "Hiện Menu"
end

-- Kết nối nút với hàm
toggleMenuButton.MouseButton1Click:Connect(toggleMenu)
