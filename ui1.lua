local Kavo = {}

local tween = game:GetService("TweenService")
local tweeninfo = TweenInfo.new
local input = game:GetService("UserInputService")
local run = game:GetService("RunService")

local Utility = {}
local Objects = {}
function Kavo:DraggingEnabled(frame, parent)
        
    parent = parent or frame
end

local dragging = false
    local dragInput, mousePos, framePos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = parent.Position
            
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

    input.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            parent.Position  = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

function Utility:TweenObject(obj, properties, duration, ...)
    tween:Create(obj, tweeninfo(duration, ...), properties):Play()
end

local themes = {
    SchemeColor = Color3.fromRGB(0.94117647058824, 1, 1)
    Background = Color3.fromRGB(0.49803921568627, 1, 0.83137254901961)
    Header = Color3.fromRGB(0, 1, 1)
    TextColor = Color3.fromRGB(0.54117647058824, 0.16862745098039, 0.88627450980392)
    ElementColor = Color3.fromRGB(0.54117647058824, 0.16862745098039, 0.88627450980392)
}
local themeStyles = {
    SchemeColor = Color3,fromRGB(0, 0, 0.54509803921569)
}
