local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Tạo GUI chính
local menuGui = Instance.new("ScreenGui")
menuGui.Name = "MenuGUI"
menuGui.Parent = playerGui

-- Tạo Frame chứa các nút
local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 250, 0, 200)
menuFrame.Position = UDim2.new(0.5, -125, 0.5, -100)
menuFrame.BackgroundTransparency = 0.4
menuFrame.BackgroundColor3 = Color3.new(0, 0, 0)
menuFrame.BorderSizePixel = 0
menuFrame.Active = true
menuFrame.Draggable = true
menuFrame.Parent = menuGui

-- Tạo nhãn tiêu đề
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 250, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Game Features Menu"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.TextSize = 20
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = menuFrame

-- Tạo nút InfJump
local infJumpButton = Instance.new("TextButton")
infJumpButton.Name = "InfJumpButton"
infJumpButton.Size = UDim2.new(0.8, 0, 0, 30)
infJumpButton.Position = UDim2.new(0.1, 0, 0.2, 0)
infJumpButton.BackgroundColor3 = Color3.new(0, 0.5, 1)
infJumpButton.Text = "Enable InfJump"
infJumpButton.Font = Enum.Font.SourceSans
infJumpButton.TextColor3 = Color3.new(1, 1, 1)
infJumpButton.TextSize = 14
infJumpButton.Parent = menuFrame

-- Tạo nút Noclip
local noclipButton = Instance.new("TextButton")
noclipButton.Name = "NoclipButton"
noclipButton.Size = UDim2.new(0.8, 0, 0, 30)
noclipButton.Position = UDim2.new(0.1, 0, 0.4, 0)
noclipButton.BackgroundColor3 = Color3.new(1, 0, 0)
noclipButton.Text = "Enable Noclip"
noclipButton.Font = Enum.Font.SourceSans
noclipButton.TextColor3 = Color3.new(1, 1, 1)
noclipButton.TextSize = 14
noclipButton.Parent = menuFrame

-- Tạo nút Dash
local dashButton = Instance.new("TextButton")
dashButton.Name = "DashButton"
dashButton.Size = UDim2.new(0.8, 0, 0, 30)
dashButton.Position = UDim2.new(0.1, 0, 0.6, 0)
dashButton.BackgroundColor3 = Color3.new(0.1, 0.6, 0.8)
dashButton.Text = "Dash"
dashButton.Font = Enum.Font.SourceSans
dashButton.TextColor3 = Color3.new(1, 1, 1)
dashButton.TextSize = 14
dashButton.Parent = menuFrame

-- Kết nối nút InfJump
local infiniteJumpEnabled = false
infJumpButton.MouseButton1Click:Connect(function()
    infiniteJumpEnabled = not infiniteJumpEnabled
    infJumpButton.Text = infiniteJumpEnabled and "Disable InfJump" or "Enable InfJump"
end)

-- Kết nối nút Noclip
local noclipEnabled = false
noclipButton.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    noclipButton.Text = noclipEnabled and "Disable Noclip" or "Enable Noclip"
end)

-- Kết nối nút Dash
local onCooldown = false
local cooldownDuration = 0.01
local dashSpeed = 50
local dashDuration = 0.5
local dashFOVIncrease = 15
local defaultFOV = workspace.CurrentCamera.FieldOfView
local dashActionName = "DASH_ACTION"

local camera = workspace.CurrentCamera
local char = player.Character
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

local dashAnimation = Instance.new("Animation")
dashAnimation.AnimationId = "rbxassetid://<AnimationID>" -- Thêm ID của animation dash vào đây.
local animationTrack = humanoid:WaitForChild("Animator"):LoadAnimation(dashAnimation)
animationTrack.Priority = Enum.AnimationPriority.Action
animationTrack:AdjustSpeed(animationTrack.Length / dashDuration)

local dashSound = Instance.new("Sound")
dashSound.SoundId = "rbxassetid://<SoundID>" -- Thêm ID âm thanh của dash vào đây
dashSound.Parent = root

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {char}
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

function Dash(actionName: string, inputState: Enum.UserInputState)
    if onCooldown then return end
    if inputState ~= Enum.UserInputState.Begin then return end
    
    onCooldown = true
    task.spawn(function()
        local dashVelocity = root.CFrame.LookVector * dashSpeed
        linearVelocity.PlaneVelocity = dashVelocity
        linearVelocity.Enabled = true
        
        humanoid.AutoRotate = false
        root.CFrame = CFrame.new(root.Position, root.Position + dashVelocity)
        animationTrack:Play()
        dashSound:Play()

        -- Thêm hiệu ứng FOV
        local goalFOV = defaultFOV + dashFOVIncrease
        while camera.FieldOfView < goalFOV do
            camera.FieldOfView = camera.FieldOfView + 1
            wait(0.01)
        end

        -- Sau khi dash kết thúc
        wait(dashDuration)
        linearVelocity.Enabled = false
        humanoid.AutoRotate = true

        -- Quay lại FOV ban đầu
        camera.FieldOfView = defaultFOV

        -- Tắt cooldown
        wait(cooldownDuration)
        onCooldown = false
    end)
end

dashButton.MouseButton1Click:Connect(function()
    Dash(dashActionName, Enum.UserInputState.Begin)
end)

