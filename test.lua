-- Roblox Lua Script for a Complete GUI
-- Place this script in StarterGui > StarterPlayerGui (LocalScript) for client-side GUI
-- This creates a full GUI with buttons, text input, labels, a scrollbar, and events

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CompleteGUI"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

-- Main Frame (like a window)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.Parent = screenGui

-- Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 50)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(73, 175, 80)
titleLabel.Text = "Complete Roblox GUI - Just GUI"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = mainFrame

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 10)
closeButton.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.SourceSansBold
closeButton.Parent = mainFrame

-- Counter Label and Button
local counterLabel = Instance.new("TextLabel")
counterLabel.Name = "CounterLabel"
counterLabel.Size = UDim2.new(1, -20, 0, 30)
counterLabel.Position = UDim2.new(0, 10, 0, 70)
counterLabel.BackgroundTransparency = 1
counterLabel.Text = "Counter: 0"
counterLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
counterLabel.TextScaled = true
counterLabel.Font = Enum.Font.SourceSans
counterLabel.Parent = mainFrame

local incrementButton = Instance.new("TextButton")
incrementButton.Name = "IncrementButton"
incrementButton.Size = UDim2.new(0, 150, 0, 40)
incrementButton.Position = UDim2.new(0, 10, 0, 110)
incrementButton.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
incrementButton.Text = "Increment Counter"
incrementButton.TextColor3 = Color3.fromRGB(255, 255, 255)
incrementButton.TextScaled = true
incrementButton.Font = Enum.Font.SourceSansBold
incrementButton.Parent = mainFrame

-- Text Input and Save Button
local nameLabel = Instance.new("TextLabel")
nameLabel.Name = "NameLabel"
nameLabel.Size = UDim2.new(1, -20, 0, 20)
nameLabel.Position = UDim2.new(0, 10, 0, 170)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = "Enter Your Name:"
nameLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
nameLabel.TextScaled = true
nameLabel.Font = Enum.Font.SourceSans
nameLabel.Parent = mainFrame

local nameTextBox = Instance.new("TextBox")
nameTextBox.Name = "NameTextBox"
nameTextBox.Size = UDim2.new(1, -20, 0, 30)
nameTextBox.Position = UDim2.new(0, 10, 0, 200)
nameTextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
nameTextBox.Text = "Type your name here..."
nameTextBox.TextColor3 = Color3.fromRGB(128, 128, 128)
nameTextBox.TextScaled = true
nameTextBox.Font = Enum.Font.SourceSans
nameTextBox.Parent = mainFrame

local saveButton = Instance.new("TextButton")
saveButton.Name = "SaveButton"
saveButton.Size = UDim2.new(0, 100, 0, 30)
saveButton.Position = UDim2.new(0, 10, 0, 240)
saveButton.BackgroundColor3 = Color3.fromRGB(255, 152, 0)
saveButton.Text = "Save"
saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
saveButton.TextScaled = true
saveButton.Font = Enum.Font.SourceSansBold
saveButton.Parent = mainFrame

-- Text Area with ScrollingFrame
local textAreaLabel = Instance.new("TextLabel")
textAreaLabel.Name = "TextAreaLabel"
textAreaLabel.Size = UDim2.new(1, -20, 0, 20)
textAreaLabel.Position = UDim2.new(0, 10, 0, 290)
textAreaLabel.BackgroundTransparency = 1
textAreaLabel.Text = "Log Messages:"
textAreaLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
textAreaLabel.TextScaled = true
textAreaLabel.Font = Enum.Font.SourceSans
textAreaLabel.Parent = mainFrame

local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Name = "ScrollingFrame"
scrollingFrame.Size = UDim2.new(1, -20, 0, 150)
scrollingFrame.Position = UDim2.new(0, 10, 0, 320)
scrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
scrollingFrame.BorderSizePixel = 1
scrollingFrame.ScrollBarThickness = 10
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 200)  -- Will be updated dynamically
scrollingFrame.Parent = mainFrame

-- Sample log text
local logText = Instance.new("TextLabel")
logText.Name = "LogText"
logText.Size = UDim2.new(1, -10, 0, 20)
logText.Position = UDim2.new(0, 5, 0, 0)
logText.BackgroundTransparency = 1
logText.Text = "Welcome to the Complete GUI! (Scroll to see more)"
logText.TextColor3 = Color3.fromRGB(0, 0, 0)
logText.TextScaled = true
logText.TextXAlignment = Enum.TextXAlignment.Left
logText.Font = Enum.Font.SourceSans
logText.Parent = scrollingFrame

-- Clear Button for Log
local clearButton = Instance.new("TextButton")
clearButton.Name = "ClearButton"
clearButton.Size = UDim2.new(0, 80, 0, 30)
clearButton.Position = UDim2.new(1, -90, 0, 290)
clearButton.BackgroundColor3 = Color3.fromRGB(158, 158, 158)
clearButton.Text = "Clear Log"
clearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
clearButton.TextScaled = true
clearButton.Font = Enum.Font.SourceSansBold
clearButton.Parent = mainFrame

-- Variables
local counter = 0
local logEntries = {}

-- Function to add log entry
local function addLog(text)
    table.insert(logEntries, text)
    
    -- Clear existing children
    for _, child in pairs(scrollingFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    -- Recreate labels
    local canvasHeight = 0
    for i, entry in ipairs(logEntries) do
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0, 20)
        label.Position = UDim2.new(0, 5, 0, canvasHeight)
        label.BackgroundTransparency = 1
        label.Text = tostring(i) .. ": " .. entry
        label.TextColor3 = Color3.fromRGB(0, 0, 0)
        label.TextScaled = true
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.SourceSans
        label.Parent = scrollingFrame
        canvasHeight = canvasHeight + 25
    end
    
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, canvasHeight)
end

-- Function to update counter
local function updateCounter()
    counter = counter + 1
    counterLabel.Text = "Counter: " .. counter
    addLog("Counter incremented to " .. counter)
end

-- Function to save name
local function saveName()
    local name = nameTextBox.Text
    if name ~= "" and name ~= "Type your name here..." then
        addLog("Saved name: " .. name)
        nameTextBox.TextColor3 = Color3.fromRGB(0, 0, 0)
    else
        addLog("Please enter a valid name!")
    end
end

-- Function to clear log
local function clearLog()
    logEntries = {}
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    addLog("Log cleared.")
end

-- Function to close GUI
local function closeGUI()
    screenGui:Destroy()
end

-- Event Connections
closeButton.MouseButton1Click:Connect(closeGUI)
incrementButton.MouseButton1Click:Connect(updateCounter)
saveButton.MouseButton1Click:Connect(saveName)
clearButton.MouseButton1Click:Connect(clearLog)

-- Placeholder text event
nameTextBox.Focused:Connect(function()
    if nameTextBox.Text == "Type your name here..." then
        nameTextBox.Text = ""
        nameTextBox.TextColor3 = Color3.fromRGB(0, 0, 0)
    end
end)

nameTextBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        saveName()
    end
end)

-- Initial log
addLog("GUI loaded successfully on " .. os.date("%B %d, %Y"))

-- Tween for entrance animation
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tween = TweenService:Create(mainFrame, tweenInfo, {Position = UDim2.new(0.5, -200, 0.5, -250)})
tween:Play()
