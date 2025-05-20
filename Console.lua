local LogService = game:GetService("LogService")
local TweenService = game:GetService("TweenService");



local CustomOutput  = {
    Open = true,
    Messages = {}
}


local HaveFunction = pcall(function()
    hookfunction()
end)


local http = game:GetService("HttpService")


if not getgenv().oldwarn then
    
    getgenv().oldwarn = hookfunction(warn,function(...)
        local str =  (typeof(...) == "table" and http:JSONEncode(...) or ...)
        return getgenv().oldwarn((typeof(...) == "table" and string.sub(str,1,-1) or str))
    end)

    getgenv().oldprint = hookfunction(print,function(...)
        local str =  (typeof(...) == "table" and http:JSONEncode(...) or ...)
        return getgenv().oldprint((typeof(...) == "table" and string.sub(str,1,-1) or str))
    end)

    getgenv().olderror = hookfunction(error,function(...)
        local str =  (typeof(...) == "table" and http:JSONEncode(...) or ...)
        return getgenv().olderror((typeof(...) == "table" and string.sub(str,1,-1) or str))
    end)

end


local HasProperty = function(instance, property) -- Currently not so reliable. Tests if instance has a certain property
	local successful = pcall(function()
		return instance[property]
	end)
	return successful and not instance:FindFirstChild(property) -- Fails if instance DOES have a child named a property, will fix soon
end


function Create(instance : string,properties : table)
	local Corner,Stroke
	local CreatedInstance = Instance.new(instance)
    local StrokeProperties
    local Stroke
	if instance == "TextButton" or instance == "ImageButton" then
		CreatedInstance.AutoButtonColor = false
	end

    if HasProperty(CreatedInstance,"BorderSizePixel") then
        CreatedInstance.BorderSizePixel = 0
    end

	for property,value in next,properties do
		if tostring(property) ~= "CornerRadius" and tostring(property) ~= "Stroke" and tostring(property) ~= "BoxShadow" then
			CreatedInstance[property] = value
		elseif tostring(property) == "Stroke" then
			StrokeProperties = {
				Color = value['Color'],
				Thickness = value['Thickness'],
				Transparency = value['Transparency'] or 0
			}
			Stroke = Instance.new("UIStroke",CreatedInstance)
			Stroke.Name = "Stroke"
			Stroke.Color = value["Color"] or Color3.fromRGB(255,255,255)
			Stroke.Thickness = value["Thickness"] or 1
			Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			Stroke.Transparency = value["Transparency"] or 0
			Stroke.LineJoinMode = Enum.LineJoinMode.Round

		elseif tostring(property) == "CornerRadius" then
			Corner = Instance.new("UICorner",CreatedInstance)
			Corner.Name = "Corner"
			Corner.CornerRadius = value
        elseif tostring(property) == "BoxShadow" then
            local BoxShadow = Instance.new("ImageLabel",CreatedInstance)
            BoxShadow.Size = UDim2.new(1,value['Size'][1],1,value['Size'][2])
            BoxShadow.AnchorPoint = Vector2.new(0.5,0.5)
            BoxShadow.Position = UDim2.new(0.5,value['Padding'][1],0.5,value['Padding'][2])
            BoxShadow.Image = "rbxassetid://1316045217"
            BoxShadow.BackgroundTransparency = 1
            BoxShadow.ImageTransparency = value['Transparency']
            BoxShadow.ScaleType = Enum.ScaleType.Slice
            BoxShadow.SliceCenter = Rect.new(10,10,118,118)
            BoxShadow.ImageColor3 = value['Color']
            BoxShadow.ZIndex = value['ZIndex'] or 1
            BoxShadow.Name = "Shadow"
		end
	end


	return CreatedInstance;
end




local function Tween(instance, time, properties,EasingStyle,EasingDirection)
	local tw = TweenService:Create(instance, TweenInfo.new(time, EasingStyle and Enum.EasingStyle[EasingStyle] or Enum.EasingStyle.Quad,EasingDirection and Enum.EasingDirection[EasingDirection] or Enum.EasingDirection.Out), properties)
	task.delay(0, function()
		tw:Play()
	end)
	return tw
end


CustomOutput.Init = function()
    local Output = {
        Elements = {},
        MessageColors = {
            MessageError = {Color3.fromRGB(255,50,0), "rbxassetid://3926305904", Vector2.new(964, 84), Vector2.new(36,36),true},
            MessageWarning = {Color3.fromRGB(255,150,0), "rbxassetid://3926305904", Vector2.new(364, 324), Vector2.new(36,36),true},
            MessageOutput = {Color3.fromRGB(230,230,230), "rbxassetid://3926305904", Vector2.new(764, 444), Vector2.new(36,36),true}
        }
    }
   
    if game.CoreGui:FindFirstChild("CustomOutput") then
        game.CoreGui.CustomOutput:Destroy()
    end


    local SG = Create("ScreenGui",{
        Parent = game.CoreGui,
        Name = "CustomOutput",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ScreenInsets = Enum.ScreenInsets.None
    })


    Output.Elements.Main = Create("Frame",{
        Parent = SG,
        Name = "Main",
        Size = UDim2.new(0.4,0,0.8,0),
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.new(0.5,0,0.5,0),
        BackgroundColor3 = Color3.fromRGB(30,30,30),
        BackgroundTransparency = 1,
        ZIndex = 999,
        CornerRadius = UDim.new(0,10),
        BoxShadow = {
            Size = {16,16},
            Padding = {0,0},
            Transparency = 0.5,
            Color = Color3.fromRGB(0,0,0),
            ZIndex = 998
        }
    })


    Output.Elements.MainBackground = Create("CanvasGroup",{
        Parent = Output.Elements.Main,
        Name = "Main",
        Size = UDim2.new(1,0,1,0),
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.new(0.5,0,0.5,0),
        BackgroundColor3 = Color3.fromRGB(30,30,30),
        GroupTransparency = 0.3,
        BackgroundTransparency = 0,
        ZIndex = 999,
        CornerRadius = UDim.new(0,10),
    })

    local dragging
    local dragInput
    local dragStart
    local startPos
    local off = Vector2.new(0,0,0)

    local function update(input)
        local delta = input.Position - dragStart
        pcall(function()
            Output.Elements.Main:TweenPosition(UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y),"Out","Quad",0.025,true,nil)
        end)
    end
    Output.Elements.MainBackground.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Output.Elements.Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    Output.Elements.MainBackground.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input

        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    local openclose = game:GetService("UserInputService").InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.F9 then
            Output.Open = not Output.Open
            if Output.Open then
                game.CoreGui:WaitForChild('DevConsoleMaster').Enabled = false
                Tween(Output.Elements.MainBackground,0.1,{GroupTransparency = 1})
                Tween(Output.Elements.Main:FindFirstChild("Shadow"),0.1,{ImageTransparency = 1})
                task.delay(0.1,function()
                    SG.Enabled = false
                    
                end)
            else
                game.CoreGui:WaitForChild('DevConsoleMaster').Enabled = false
                Tween(Output.Elements.MainBackground,0.1,{GroupTransparency = 0.3})
                SG.Enabled = true
                Tween(Output.Elements.Main:FindFirstChild("Shadow"),0.1,{ImageTransparency = 0.5})
            end
        end
    end)


    Output.Elements.Main.Destroying:Connect(function()
        openclose:Disconnect()
    end)

    Output.Elements.Filters = Create("Frame",{
        Parent = Output.Elements.MainBackground,
        Name = "Filters",
        Size = UDim2.new(1,-20,0,36),
        Position = UDim2.new(0,10,0,38),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    })

    local FiltersLayout = Create("UIListLayout",{
        Parent = Output.Elements.Filters,
        Name = "ListLayout",
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0,8),
        FillDirection = Enum.FillDirection.Horizontal
    })

    for i,v in next,Output.MessageColors do
        local Filter = Create("TextButton",{
            Parent = Output.Elements.Filters,
            Name = "Filter_"..i,
            Size = UDim2.new(0,0,1,0),
            AutomaticSize = Enum.AutomaticSize.X,
            Position = UDim2.new(0,0,0,0),
            BackgroundTransparency = 0,
            BackgroundColor3 = Color3.fromRGB(0,170,255),
            TextColor3 = Color3.fromRGB(255,255,255),
            TextSize = 18,
            Text = string.gsub(i,"Message",""),
            FontFace = Font.fromId(12187365364),
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            CornerRadius = UDim.new(1,0)
        })

        local checkedIcon = Create("ImageLabel",{
            Parent = Filter,
            Name = "Icon",
            AnchorPoint = Vector2.new(0,0.5),
            Size = UDim2.new(0,20,0,20),
            Position = UDim2.new(0,0,0.5,0),
            BackgroundTransparency = 1,
            ImageTransparency = 0,
            ImageColor3 = Color3.fromRGB(255,255,255),
            Image = "rbxassetid://3926305904",
            ScaleType = Enum.ScaleType.Fit,
            ImageRectOffset = Vector2.new(644, 204),
            ImageRectSize = Vector2.new(36,36),
        })


        local padding = Create("UIPadding",{
            Parent = Filter,
            Name = "Padding",
            PaddingTop = UDim.new(0,10),
            PaddingBottom = UDim.new(0,10),
            PaddingLeft = UDim.new(0,10),
            PaddingRight = UDim.new(0,10)
        })

        task.wait()
        Filter.Size = UDim2.new(0,Filter.AbsoluteSize.X + 44,1,0)
        Filter.AutomaticSize = Enum.AutomaticSize.None

        Filter.MouseButton1Click:Connect(function()
            Output.MessageColors[i][5] = not Output.MessageColors[i][5]
            Tween(checkedIcon,0.3,{ImageTransparency = (Output.MessageColors[i][5] and 0 or 1)})
            Tween(Filter,0.3,{Size = Output.MessageColors[i][5] and UDim2.new(0,Filter.AbsoluteSize.X + 24,1,0) or UDim2.new(0,Filter.AbsoluteSize.X - 24,1,0)})
            Tween(Filter,0.3,{BackgroundColor3 = (Output.MessageColors[i][5] and Color3.fromRGB(0,150,255) or Color3.fromRGB(0,0,0))})
            for c,x in next,Output.Elements.MessagesFrame:GetChildren() do
                if x.Name == "MessageFrame" then
                    if x:GetAttribute("Type") == i then
                        if Output.MessageColors[i][5] then
                            Tween(x,0.1,{GroupTransparency = 0})
                            x.Visible = true
                        else
                            Tween(x,0.1,{GroupTransparency = 1})
                            task.delay(0.1,function()
                                x.Visible = false
                            end)
                        end
                    end
                end
            end
        end)

        Filter.MouseEnter:Connect(function()
            Tween(Filter,0.3,{BackgroundColor3 = (Output.MessageColors[i][5] and Color3.fromRGB(0,170,255) or Color3.fromRGB(20,20,20))})
        end)
        Filter.MouseLeave:Connect(function()
            Tween(Filter,0.3,{BackgroundColor3 = (not Output.MessageColors[i][5] and Color3.fromRGB(0,0,0) or Color3.fromRGB(0,150,255))})
        end)
    end



    Output.Elements.ClearButton = Create("TextButton",{
        Parent = Output.Elements.MainBackground,
        Name = "ClearButton",
        Size = UDim2.new(0,120,0,35),
        AutomaticSize = Enum.AutomaticSize.X,
        Position = UDim2.new(0,8,1,-43),
        BackgroundTransparency = 0,
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        TextColor3 = Color3.fromRGB(255,255,255),
        TextSize = 18,
        Text = "       Clear logs",
        FontFace = Font.fromId(12187365364),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        CornerRadius = UDim.new(0,8)
    })

    local ClearIcon = Create("ImageLabel",{
        Parent = Output.Elements.ClearButton,
        Name = "Icon",
        AnchorPoint = Vector2.new(0.5,0.5),
        Size = UDim2.new(0,20,0,20),
        Position = UDim2.new(0,18,0.5,0),
        BackgroundTransparency = 1,
        ImageTransparency = 0,
        ImageColor3 = Color3.fromRGB(255,255,255),
        Image = "rbxassetid://3926305904",
        ScaleType = Enum.ScaleType.Fit,
        ImageRectOffset = Vector2.new(644, 724),
        ImageRectSize = Vector2.new(36,36),
    })

    Output.Elements.ClearButton.MouseEnter:Connect(function()
        Tween(Output.Elements.ClearButton,0.3,{BackgroundColor3 = Color3.fromRGB(214, 78, 101)})
    end)

    Output.Elements.ClearButton.MouseLeave:Connect(function()
        Tween(Output.Elements.ClearButton,0.3,{BackgroundColor3 = Color3.fromRGB(0,0,0)})
    end)


    Output.Elements.ClearButton.MouseButton1Click:Connect(function()
        for i,v in next,Output.Elements.MessagesFrame:GetChildren() do
            if v.Name == "MessageFrame" then
                Tween(v,0.3,{GroupTransparency = 1})
                task.delay(0.3,function()
                    v:Destroy()
                end)
            end
        end
    end)

    Output.Elements.MessagesFrame = Create("ScrollingFrame",{
        Parent = Output.Elements.MainBackground,
        Name = "MessagesFrame",
        Size = UDim2.new(1,-20,1,-128),
        Position = UDim2.new(0,10,0,80),
        BackgroundTransparency = 1,
        CanvasSize = UDim2.new(0,0,0,0),
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = Color3.fromRGB(255,255,255),
        BorderSizePixel = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.XY,
    })

    Output.Elements.MessagesFrame:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(function()
        Tween(Output.Elements.MessagesFrame,0.3,{
            CanvasPosition = Vector2.new(0,Output.Elements.MessagesFrame.AbsoluteCanvasSize.Y)
        })
    end)

    local ListLayout = Create("UIListLayout",{
        Parent = Output.Elements.MessagesFrame,
        Name = "ListLayout",
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0,5),
        FillDirection = Enum.FillDirection.Vertical
    })

    Output.Elements.Title = Create("TextLabel",{
        Parent = Output.Elements.MainBackground,
        Name = "Title",
        Size = UDim2.new(1,0,0,60),
        Position = UDim2.new(0,8,0,4),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(230,230,230),
        TextSize = 28,
        Text = "Dev console v2",
        FontFace = Font.fromId(12187365364),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
    })
    Output.Add = function(message,Type)
        local msgFrame = Create("CanvasGroup",{
            Parent = Output.Elements.MessagesFrame,
            Name = "MessageFrame",
            Size = UDim2.new(1,-10,0,0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 0,
            GroupTransparency = 1,
            BackgroundColor3 = Color3.fromRGB(10,10,10),
            BorderSizePixel = 0,
            CornerRadius = UDim.new(0,8),
        })


        msgFrame:SetAttribute("Type",Type)

        Tween(msgFrame,0.1,{GroupTransparency = (Output.MessageColors[Type][5] and 0 or 1)})
        msgFrame.Visible = (Output.MessageColors[Type][5] and true or false)

        Tween(msgFrame,0.3,{GroupTransparency = 0})

        local padding = Create("UIPadding",{
            Parent = msgFrame,
            Name = "Padding",
            PaddingTop = UDim.new(0,10),
            PaddingBottom = UDim.new(0,10),
            PaddingLeft = UDim.new(0,10),
            PaddingRight = UDim.new(0,10)
        })


        local TypeIcon = Create("ImageLabel",{
            Parent = msgFrame,
            Name = "TypeIcon",
            Size = UDim2.new(0,20,0,20),
            Position = UDim2.new(0,0,0,0),
            BackgroundTransparency = 1,
            ImageTransparency = 0,
            ImageColor3 = Output.MessageColors[Type][1],
            Image = Output.MessageColors[Type][2],
            ScaleType = Enum.ScaleType.Fit,
            ImageRectOffset = Output.MessageColors[Type][3],
            ImageRectSize = Output.MessageColors[Type][4],
            BackgroundColor3 = Color3.fromRGB(0,0,0),
            CornerRadius = UDim.new(0,8)
        })


        local msg = Create("TextLabel",{
            Parent = msgFrame,
            Name = "Message",
            Size = UDim2.new(1,-40,0,0),
            Position = UDim2.new(0,40,0,0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 0,
            BackgroundColor3 = Color3.fromRGB(10,10,10),
            TextColor3 = Color3.fromRGB(230,230,230),
            TextSize = 18,
            Text = "",
            FontFace = Font.fromId(12187365364),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            RichText = true,
            TextWrapped = true,
            CornerRadius = UDim.new(0,8),
            Selectable = true,
            ZIndex = 1
        })

        local fakemsg = Create("TextBox",{
            Parent = msgFrame,
            Name = "Message",
            Size = UDim2.new(1,-40,0,0),
            Position = UDim2.new(0,40,0,18),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BackgroundColor3 = Color3.fromRGB(10,10,10),
            TextColor3 = Color3.fromRGB(230,230,230),
            TextSize = 18,
            TextTransparency = 1,
            Text = "",
            FontFace = Font.fromId(12187365364),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            RichText = true,
            TextWrapped = true,
            CornerRadius = UDim.new(0,8),
            Selectable = true,
            TextEditable = false,
            ClearTextOnFocus = false,
            ZIndex = 2
        })


        local CustomHighlight = Create("Frame",{
            Parent = fakemsg,
            Name = "CustomHighlight",
            AnchorPoint = Vector2.new(0,0.5),
            Size = UDim2.new(0,0,1,0),
            Position = UDim2.new(0,-2,0.5,0),
            BackgroundTransparency = 0.8,
            BackgroundColor3 = Color3.fromRGB(80, 169, 241),
            ZIndex = -3
        })

        msg.Text = "| " .. os.date("%X").." |\n" .. '<font color="#' .. tostring(Output.MessageColors[Type][1]:ToHex()) .. '">' .. message .. " </font>"
        fakemsg.Text = message

        msgFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if not fakemsg:IsFocused() then
                    fakemsg:CaptureFocus()
                end
            end
        end)

        fakemsg.Focused:Connect(function()
            fakemsg.CursorPosition = #fakemsg.Text + 1
            fakemsg.SelectionStart = 1
            Tween(CustomHighlight,0.1,{Size = UDim2.new(0,fakemsg.TextBounds.X + 4,0,fakemsg.TextBounds.Y + 4)})
        end)

        fakemsg.FocusLost:Connect(function()
            Tween(CustomHighlight,0.1,{Size = UDim2.new(0,0,0,fakemsg.TextBounds.Y + 2)})
        end)
    end

    return Output;
end




local output = CustomOutput.Init()

local http = game:GetService("HttpService")

LogService.MessageOut:Connect(function(message, messageType)
    output.Add(message, string.gsub(tostring(messageType),"Enum.MessageType.", ""))
end)
