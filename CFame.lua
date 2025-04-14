local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local freeSoul = false
local speed = 50
local yaw = 0
local pitch = 0

-- UI setup
local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
screenGui.Name = "SoulCamUI"

local toggleBtn = Instance.new("TextButton", screenGui)
toggleBtn.Size = UDim2.new(0, 120, 0, 40)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.Text = "Tách Hồn"
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 100)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)

local speedLabel = Instance.new("TextLabel", screenGui)
speedLabel.Size = UDim2.new(0, 120, 0, 30)
speedLabel.Position = UDim2.new(0, 10, 0, 60)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.Text = "Tốc độ: "..speed

local plusBtn = Instance.new("TextButton", screenGui)
plusBtn.Size = UDim2.new(0, 50, 0, 40)
plusBtn.Position = UDim2.new(0, 10, 0, 100)
plusBtn.Text = "+"
plusBtn.BackgroundColor3 = Color3.fromRGB(70, 150, 70)
plusBtn.TextColor3 = Color3.new(1, 1, 1)

local minusBtn = Instance.new("TextButton", screenGui)
minusBtn.Size = UDim2.new(0, 50, 0, 40)
minusBtn.Position = UDim2.new(0, 80, 0, 100)
minusBtn.Text = "-"
minusBtn.BackgroundColor3 = Color3.fromRGB(150, 70, 70)
minusBtn.TextColor3 = Color3.new(1, 1, 1)

-- ESP
local function createSelfESP()
	local char = LocalPlayer.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp or char:FindFirstChild("SoulESP") then return end

	local box = Instance.new("BoxHandleAdornment")
	box.Name = "SoulESP"
	box.Adornee = hrp
	box.Size = Vector3.new(4, 6, 2)
	box.Color3 = Color3.new(0, 1, 0)
	box.Transparency = 0.3
	box.AlwaysOnTop = true
	box.ZIndex = 5
	box.Parent = char
end

local function removeSelfESP()
	local char = LocalPlayer.Character
	if not char then return end

	local esp = char:FindFirstChild("SoulESP")
	if esp then esp:Destroy() end
end

-- Toggle button
toggleBtn.MouseButton1Click:Connect(function()
	freeSoul = not freeSoul

	if freeSoul then
		local head = LocalPlayer.Character:WaitForChild("Head")
		local cf = head.CFrame
		yaw, pitch = cf:ToOrientation()

		Camera.CameraType = Enum.CameraType.Scriptable
		Camera.CFrame = CFrame.new(cf.Position) * CFrame.Angles(0, yaw, 0)

		createSelfESP()
		toggleBtn.Text = "Nhập Hồn"
	else
		Camera.CameraType = Enum.CameraType.Custom
		removeSelfESP()
		toggleBtn.Text = "Tách Hồn"
	end
end)

-- Tăng giảm tốc độ
plusBtn.MouseButton1Click:Connect(function()
	speed += 10
	speedLabel.Text = "Tốc độ: "..speed
end)

minusBtn.MouseButton1Click:Connect(function()
	speed = math.max(10, speed - 10)
	speedLabel.Text = "Tốc độ: "..speed
end)

-- Xoay camera bằng ngón tay
local rotating = false
local lastPos

UserInputService.InputBegan:Connect(function(input, gpe)
	if not freeSoul or gpe then return end

	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton2 then
		rotating = true
		lastPos = input.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not freeSoul or not rotating then return end

	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - lastPos
		lastPos = input.Position

		yaw = yaw - math.rad(delta.X * 0.2)
		pitch = math.clamp(pitch - math.rad(delta.Y * 0.2), -math.pi/2 + 0.1, math.pi/2 - 0.1)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton2 then
		rotating = false
	end
end)

-- Di chuyển theo hướng nhìn
RunService.RenderStepped:Connect(function(dt)
	if not freeSoul then return end

	local camRot = CFrame.Angles(pitch, yaw, 0)
	local moveDirection = Vector3.zero

	local char = LocalPlayer.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")

	if humanoid then
		local moveInput = humanoid.MoveDirection
		if moveInput.Magnitude > 0 then
			moveDirection += camRot:VectorToWorldSpace(Vector3.new(moveInput.X, 0, moveInput.Z))
		end
	end

	-- Space = bay lên, Ctrl = bay xuống
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		moveDirection += Vector3.new(0, 1, 0)
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		moveDirection += Vector3.new(0, -1, 0)
	end

	local camPos = Camera.CFrame.Position
	Camera.CFrame = CFrame.new(camPos) * camRot + moveDirection.Unit * speed * dt * (moveDirection.Magnitude > 0 and 1 or 0)
end)
