local onCooldown = false
local cooldownDuration = 0.01 --Time before dash is available again

local dashSpeed = 50 --Speed of dash
local dashDuration = 0.5 --Length of dash

local dashKeys = {Enum.KeyCode.Q} --List of keys you can press to dash

local dashMobileButton
local mobileButtonImage = "rbxassetid://13213984187" --Image ID of dash mobile button
local mobileButtonPosition = UDim2.new(1, -125, 1, -125) --Position of dash mobile button
local normalImageColor = Color3.new(1, 1, 1) --Image color of dash mobile button when dash is available
local cooldownImageColor = Color3.new(0.2, 0.2, 0.2) --Image color of dash mobile button when dash is on cooldown

local dashFOVIncrease = 15 --Amount of FOV to increase default FOV by when dashing
local defaultFOV

local cas = game:GetService("ContextActionService")
local dashActionName = "DASH_ACTION"

local camera = workspace.CurrentCamera
defaultFOV = camera.FieldOfView

local char = script.Parent
local root = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

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

local dashAnimation = script:WaitForChild("DashAnimation")
local animationTrack:AnimationTrack = humanoid:WaitForChild("Animator"):LoadAnimation(dashAnimation)
animationTrack.Priority = Enum.AnimationPriority.Action
animationTrack:AdjustSpeed(animationTrack.Length / dashDuration)

local dashSound = script:WaitForChild("DashSound")
dashSound.Parent = root

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {char}
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist


function Lerp(a, b, t)
	
	return a + (b - a) * t
end

function IsDashAllowed(actionName: string, inputState: Enum.UserInputState)
	
	if onCooldown then return end

	if actionName ~= dashActionName then return end

	if inputState ~= Enum.UserInputState.Begin then return end

	return true
end

function GetDashVelocity()
	
	local vectorMask = Vector3.new(1, 0, 1)

	local direction = root.AssemblyLinearVelocity * vectorMask

	if direction.Magnitude <= 0.1 then
		direction = camera.CFrame.LookVector * vectorMask
	end

	direction = direction.Unit
	local planeDirection = Vector2.new(direction.X, direction.Z)

	local dashVelocity = planeDirection * dashSpeed
	
	return dashVelocity
end

function HandleCooldown()
	
	if dashMobileButton then
		dashMobileButton.ImageColor3 = cooldownImageColor
	end

	local cooldownStarted = tick()
	local lastTick = tick()

	while tick() - cooldownStarted < cooldownDuration do

		game:GetService("RunService").Heartbeat:Wait()
		
		local deltaTime = tick() - lastTick
		lastTick = tick()

		local startFOV

		if linearVelocity.Enabled == false then
			
			if camera.FieldOfView > defaultFOV then
				
				if not startFOV then
					startFOV = camera.FieldOfView
				end
				
				local lerpAmount = deltaTime * 10
				local newFOV = Lerp(startFOV, defaultFOV, lerpAmount)

				camera.FieldOfView = newFOV
			end
		end
	end
	camera.FieldOfView = defaultFOV

	if dashMobileButton then
		dashMobileButton.ImageColor3 = normalImageColor
	end

	onCooldown = false
end

function HandleDashDuration()
	
	local dashStarted = tick()
	
	local startFOV = camera.FieldOfView
	local goalFOV = defaultFOV + dashFOVIncrease
	
	local lastTick = tick()
	
	while tick() - dashStarted < dashDuration do

		game:GetService("RunService").Heartbeat:Wait()
		
		if camera.FieldOfView < goalFOV then
			local deltaTime = tick() - lastTick
			lastTick = tick()
			
			local lerpAmount = deltaTime * 20
			local newFOV = Lerp(camera.FieldOfView, goalFOV, lerpAmount)
			
			camera.FieldOfView = newFOV
		end
		
		if IsDashBlocked() then
			break
		end
	end
end

function IsDashBlocked()
	
	local rayOrigin = root.Position
	local rayDirection = root.CFrame.LookVector
	local rayDepth = 3
	local ray = workspace:Raycast(rayOrigin, rayDirection * rayDepth, raycastParams)

	if ray and ray.Instance.CanCollide and ray.Instance.Anchored then
		return true
	end
end

function DashEffects()
	
	animationTrack:Play()
	dashSound:Play()
end

function EnableLinearVelocity(dashVelocity: Vector2)
	
	linearVelocity.PlaneVelocity = dashVelocity
	linearVelocity.Enabled = true

	humanoid.AutoRotate = false
	root.CFrame = CFrame.new(root.Position, Vector3.new(dashVelocity.X, 0, dashVelocity.Y) * 1000)
end

function DisableLinearVelocity()
	
	linearVelocity.Enabled = false
	humanoid.AutoRotate = true
end

function Dash(actionName: string, inputState: Enum.UserInputState)
	
	if dashMobileButton then
		dashMobileButton.Image = mobileButtonImage
	end
	
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

cas:BindAction(dashActionName, Dash, true, unpack(dashKeys))

dashMobileButton = cas:GetButton(dashActionName)

if dashMobileButton then
	
	dashMobileButton.Image = mobileButtonImage
	dashMobileButton.ImageColor3 = normalImageColor
	dashMobileButton.Position = mobileButtonPosition
end
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

-- Kết nối sự kiện click của nút
dashButton.MouseButton1Click:Connect(function()
	Dash(dashActionName, Enum.UserInputState.Begin)
end)
