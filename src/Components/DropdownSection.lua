local Root = script.Parent.Parent
local Creator = require(Root.Creator)
local Flipper = require(Root.Packages.Flipper)

local New = Creator.New

return function(Title, Parent)
	local DropdownSection = {}

	DropdownSection.Opened = true

	DropdownSection.Layout = New("UIListLayout", {
		Padding = UDim.new(0, 5),
	})

	DropdownSection.Container = New("Frame", {
		Size = UDim2.new(1, 0, 0, 26),
		Position = UDim2.fromOffset(0, 38),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
	}, {
		DropdownSection.Layout,
	})

	-- Arrow icon that rotates
	DropdownSection.Arrow = New("ImageLabel", {
		Image = "rbxassetid://10709790948",
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.fromOffset(2, 4),
		BackgroundTransparency = 1,
		Rotation = 0,
		ThemeTag = {
			ImageColor3 = "Text",
		},
	})

	-- Clickable header button
	DropdownSection.HeaderButton = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 22),
		Position = UDim2.fromOffset(0, 2),
		BackgroundTransparency = 1,
		Text = "",
	}, {
		DropdownSection.Arrow,
		New("TextLabel", {
			RichText = true,
			Text = Title,
			TextTransparency = 0,
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			TextSize = 18,
			TextXAlignment = "Right",
			TextYAlignment = "Center",
			Size = UDim2.new(1, -20, 1, 0),
			Position = UDim2.fromOffset(0, 0),
			BackgroundTransparency = 1,
			ThemeTag = {
				TextColor3 = "Text",
			},
		}),
	})

	-- Border frame that wraps everything
	DropdownSection.BorderFrame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		New("UIStroke", {
			Thickness = 0.8,
			Transparency = 0.5,
			Color = Color3.fromRGB(255, 255, 255),
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		}),
	})

	DropdownSection.Root = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 26),
		LayoutOrder = 7,
		Parent = Parent,
	}, {
		DropdownSection.BorderFrame,
		DropdownSection.HeaderButton,
		DropdownSection.Container,
	})

	-- Spring motors for smooth animations
	local ContainerSizeMotor = Flipper.SingleMotor.new(0)
	local ArrowRotationMotor = Flipper.SingleMotor.new(0)
	local BorderSizeMotor = Flipper.SingleMotor.new(30)

	ContainerSizeMotor:onStep(function(value)
		DropdownSection.Container.Size = UDim2.new(1, 0, 0, value)
	end)

	ArrowRotationMotor:onStep(function(value)
		DropdownSection.Arrow.Rotation = value
	end)

	BorderSizeMotor:onStep(function(value)
		DropdownSection.BorderFrame.Size = UDim2.new(1, 0, 0, value)
	end)

	local function UpdateSize()
		local contentSize = DropdownSection.Layout.AbsoluteContentSize.Y
		local targetSize = DropdownSection.Opened and contentSize or 0
		
		ContainerSizeMotor:setGoal(Flipper.Spring.new(targetSize, { frequency = 5 }))
		
		-- Update border size to match content
		local borderHeight = DropdownSection.Opened and (contentSize + 38) or 30
		BorderSizeMotor:setGoal(Flipper.Spring.new(borderHeight, { frequency = 5 }))
		
		-- Update root size
		DropdownSection.Root.Size = UDim2.new(1, 0, 0, targetSize + 38)
	end

	Creator.AddSignal(DropdownSection.Layout:GetPropertyChangedSignal("AbsoluteContentSize"), UpdateSize)

	-- Toggle function
	function DropdownSection:Toggle()
		DropdownSection.Opened = not DropdownSection.Opened
		
		-- Animate arrow rotation
		local targetRotation = DropdownSection.Opened and 0 or -90
		ArrowRotationMotor:setGoal(Flipper.Spring.new(targetRotation, { frequency = 6 }))
		
		UpdateSize()
	end

	-- Open function
	function DropdownSection:Open()
		if not DropdownSection.Opened then
			DropdownSection:Toggle()
		end
	end

	-- Close function
	function DropdownSection:Close()
		if DropdownSection.Opened then
			DropdownSection:Toggle()
		end
	end

	-- Set opened state
	function DropdownSection:SetOpened(state)
		if DropdownSection.Opened ~= state then
			DropdownSection:Toggle()
		end
	end

	Creator.AddSignal(DropdownSection.HeaderButton.MouseButton1Click, function()
		DropdownSection:Toggle()
	end)

	-- Initial state
	UpdateSize()

	return DropdownSection
end
