while wait(0.5) do
	for i, childrik in ipairs(workspace:GetDescendants()) do
		if childrik:FindFirstChild("Humanoid",childrik) then
			if not childrik:FindFirstChild("EspBox") then
				if childrik ~= game.Players.LocalPlayer.Character then	
					local esp = instance.new("BoxHandleAdornment",childrik)
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
end
