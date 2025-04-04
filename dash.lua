local gui = Instance.new("ScreenGui")
gui.Name = "DraggableGUI"
gui.ResetOnSpawn = false -- Giữ GUI khi chết
gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Biến trạng thái toàn cục
local infiniteJumpEnabled = false
local noclipEnabled = false

-- Tạo khung GUI chính
local frame = Instance.new("Frame")
frame.Name = "DraggableFrame"
frame.Size = UDim2.new(0, 200, 0, 150)
frame.Position = UDim2.new(0, 100, 0, 100)
frame.BackgroundTransparency = 0.4
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Visible = true
frame.Parent = gui

-- Nút InfJump
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

-- Nút Noclip
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
label.Text = "Made by Duy Khang"
label.Parent = frame

-- Nút ẩn/hiện menu
local toggleMenuButton = Instance.new("TextButton")
toggleMenuButton.Name = "ToggleMenuButton"
toggleMenuButton.Size = UDim2.new(0, 100, 0, 30)
toggleMenuButton.Position = UDim2.new(0, 10, 0, 10)
toggleMenuButton.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
toggleMenuButton.Font = Enum.Font.SourceSans
toggleMenuButton.TextColor3 = Color3.new(1, 1, 1)
toggleMenuButton.TextSize = 14
toggleMenuButton.Text = "Ẩn Menu"
toggleMenuButton.Parent = gui

-- Bật / Tắt InfJump
infJumpButton.MouseButton1Click:Connect(function()
    infiniteJumpEnabled = not infiniteJumpEnabled
    infJumpButton.Text = infiniteJumpEnabled and "Tắt InfJump" or "Bật InfJump"
end)

-- Bật / Tắt Noclip
noclipButton.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    noclipButton.Text = noclipEnabled and "Tắt Noclip" or "Bật Noclip"
end)

-- Xử lý ẩn/hiện menu
local isMenuVisible = true
toggleMenuButton.MouseButton1Click:Connect(function()
    isMenuVisible = not isMenuVisible
    frame.Visible = isMenuVisible
    toggleMenuButton.Text = isMenuVisible and "Ẩn Menu" or "Hiện Menu"
end)

-- Xử lý InfJump
game:GetService("UserInputService").JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        local character = game.Players.LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState("Jumping")
            end
        end
    end
end)

-- Xử lý Noclip
game:GetService("RunService").Stepped:Connect(function()
    if noclipEnabled then
        local character = game.Players.LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- Khi nhân vật hồi sinh, tắt các chức năng
game.Players.LocalPlayer.CharacterAdded:Connect(function()
    wait(0.5)
    infiniteJumpEnabled = false
    noclipEnabled = false
    infJumpButton.Text = "Bật InfJump"
    noclipButton.Text = "Bật Noclip"
end)

-- FullBright
local Light = game:GetService("Lighting")

local function dofullbright()
    Light.Ambient = Color3.new(1, 1, 1)
    Light.ColorShift_Bottom = Color3.new(1, 1, 1)
    Light.ColorShift_Top = Color3.new(1, 1, 1)
end

dofullbright()
Light.LightingChanged:Connect(dofullbright)

