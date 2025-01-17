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
