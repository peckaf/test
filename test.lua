while wait(0.5) do
	for i, beer in ipairs(workspace:GetDescendants()) do
		if beer:FindFirstChild("Humanoid",beer) then
			if not beer:FindFirstChild("EspBox") then
				if beer ~= game.Players.LocalPlayer.Character then	
					local esp = instance.new("BoxHandleAdornment",beer)
					esp.Adornee = beer
					esp.ZIndex = 0
					esp.Size = Vector3.new(4, 5,1)
					esp.Transparensy = 0.85
					esp.Color3 = Color3.fromRGB(238,59,59)
					esp.AlwaysOnTop  = true
					esp.Name = "EspBox"
			    end
			end	
		end	
    end
 
