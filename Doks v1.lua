local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TextBox = Instance.new("TextBox")
local TextButton = Instance.new("TextButton")

--Properties:

ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(149, 255, 255)
Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0.178571433, 0, 0.271103889, 0)
Frame.Size = UDim2.new(0, 522, 0, 281)

TextBox.Parent = ScreenGui
TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextBox.BorderSizePixel = 0
TextBox.Position = UDim2.new(0.183375657, 0, 0.282987028, 0)
TextBox.Size = UDim2.new(0, 513, 0, 26)
TextBox.Font = Enum.Font.SourceSansBold
TextBox.PlaceholderColor3 = Color3.fromRGB(50, 34, 49)
TextBox.Text = "DOKS V1"
TextBox.TextColor3 = Color3.fromRGB(0, 0, 0)
TextBox.TextSize = 14.000

TextButton.Parent = ScreenGui
TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextButton.BorderSizePixel = 0
TextButton.Position = UDim2.new(0.183080807, 0, 0.370285511, 0)
TextButton.Size = UDim2.new(0, 113, 0, 18)
TextButton.Font = Enum.Font.SourceSansBold
TextButton.Text = "Esp"
TextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
TextButton.TextSize = 14.000

-- Scripts:

local function CTNQAGV_fake_script() -- TextButton.LocalScript 
	local script = Instance.new('LocalScript', TextButton)

	ocal esp = require("esp")
	local surface = require("surface")
	local bit = require("bit")
	local band = bit.band
	
	-- defining our fonts for certain pieces of the custom ESP
	local fonts = {
		["name"] = renderer.create_font("Segoe UI Semilight", 13, 400, {0x010, 0x080}),
		["clantag"] = renderer.create_font("Segoe UI Semilight", 12, 400, {0x010, 0x080}),
		["side_text"] = renderer.create_font("Small Fonts", 8, 400, {0x010, 0x200}),
		["bar_text"] = renderer.create_font("Small Fonts", 8, 400, {0x010, 0x200}),
		["bone_text"] = renderer.create_font("Small Fonts", 14, 400, {0x010, 0x200})
	}
	
	-- playerlist stuff for flags
	local playerlist = ui.reference("PLAYERS", "Players", "Player list")
	local whitelisted = ui.reference("PLAYERS", "Adjustments", "Add to whitelist")
	local disable_visuals = ui.reference("PLAYERS", "Adjustments", "Disable visuals")
	local high_priority = ui.reference("PLAYERS", "Adjustments", "High priority")
	
	-- some helper functions
	local function toBits(num)
		local t = { }
		while num > 0 do
			rest = math.fmod(num,2)
			t[#t+1] = rest
			num = (num-rest) / 2
		end
	
		return t
	end
	local function getDistance(from, to, unit)
		local xDist, yDist, zDist = to[1] - from[1], to[2] - from[2], to[3] - from[3]
	
		local m1, m2 = 0, 0
		if(unit ~= nil and unit == "feet") then
			m1 = 2
			m2 = 30.48
		end
	
		return math.sqrt( (xDist ^ 2) + (yDist ^ 2) + (zDist ^ 2) ) * m1 / m2
	end
	local function round2(num, numDecimalPlaces)
		return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
	end
	local function canDrawEntity(entindex)
		local loc = entity.get_local_player()
		local loc_team = entity.get_prop(loc, "m_iTeamNum")
		local loc_obstarget = entity.get_prop(loc, "m_hObserverTarget")
		local ply_team = entity.get_prop(entindex, "m_iTeamNum")
		local obs_team = entity.get_prop(loc_obstarget, "m_iTeamNum")
	
		return entity.is_alive(entindex) and loc_team ~= ply_team and ply_team ~= obs_team and loc_obstarget ~= entindex
	end
	local function getLatencyColor(latency)
		local r,g,b,a = 0, 255, 0, 255
	
		if(latency <= 50) then
			r,g,b = 105, 255, 105
		elseif(latency <= 150) then
			r,g,b = 255, 255, 105
		else
			r,g,b = 255, 105, 105
		end
	
		return r,g,b,a
	end
	
	-- saving and updating for getting playerlist flags
	local entstuff = {}
	client.set_event_callback("run_command", function(c)
		client.update_player_list()
		entstuff = {}
	
		if not ui.is_menu_open() then
	
			for _, v in pairs(entity.get_players(true)) do
				ui.set(playerlist, v)
				entstuff[v] = {}
				entstuff[v].whitelisted = ui.get(whitelisted)
				entstuff[v].disable = ui.get(disable_visuals)
				entstuff[v].prioritized = ui.get(high_priority)
			end
		else
			local selected_player = ui.get(playerlist)
			if(selected_player ~= nil and selected_player ~= 0) then
				entstuff[selected_player] = {}
				entstuff[selected_player].whitelisted = ui.get(whitelisted)
				entstuff[selected_player].disable = ui.get(disable_visuals)
				entstuff[selected_player].prioritized = ui.get(high_priority)
			end
		end
	end)
	
	-- some more helper functions
	local function has_value(tab, val)
		for index, value in ipairs(tab) do
			if value == val then
				return true
			end
		end
	
		return false
	end
	
	-- max weapon damages for lethal flag
	local weapon_damages = {
		CWeaponSCAR20 = 80,
		CWeaponG3SG1 = 80,
		CWeaponSSG08 = 75,
		CWeaponAWP = 101,
		CDEagle = 80,
		CKnife = 30
	}
	
	local boneIndex = {
		["Head"] = 0,
		["Neck"] = 1,
		["Upper Chest"] = 6,
		["Lower Chest"] = 5,
		["Thorax"] = 4,
		["Stomach"] = 3,
		["Pelvis"] = 2
	}
	
	-- our custom references
	local refs = {
		["scale"] = ui.new_slider("VISUALS", "Player ESP", "Custom scale", 0, 20, 0, true),
		["box"] = ui.new_checkbox("VISUALS", "Player ESP", "Bounding box"),
		["box_color"] = ui.new_color_picker("VISUALS", "Player ESP", "Name color", 255, 255, 255, 255),
		["name"] = ui.new_checkbox("VISUALS", "Player ESP", "Name"),
		["name_color"] = ui.new_color_picker("VISUALS", "Player ESP", "Name color", 255, 255, 255, 255),
		["name_truncate"] = ui.new_slider("VISUALS", "Player ESP", "Name truncation", 5, 20, 10, true),
		["clantag"] = ui.new_checkbox("VISUALS", "Player ESP", "Clantag"),
		["clantag_color"] = ui.new_color_picker("VISUALS", "Player ESP", "Clantag color", 255, 255, 255, 255),
		["health"] = ui.new_checkbox("VISUALS", "Player ESP", "Health bar"),
		["health_color"] = ui.new_color_picker("VISUALS", "Player ESP", "Health bar primary color", 180, 230, 30, 255),
		["health_color2_label"] = ui.new_label("VISUALS", "Player ESP", "Health bar secondary color"),
		["health_color2"] = ui.new_color_picker("VISUALS", "Player ESP", "Health bar secondary color", 0, 0, 0, 255),
		["location"] = ui.new_checkbox("VISUALS", "Player ESP", "Location"),
		["location_color"] = ui.new_color_picker("VISUALS", "Player ESP", "Location color", 255, 255, 255, 255),
		["distance"] = ui.new_checkbox("VISUALS", "Player ESP", "Distance"),
		["distance_color"] = ui.new_color_picker("VISUALS", "Player ESP", "Distance color", 255, 255, 255, 255),
		["latency"] = ui.new_checkbox("VISUALS", "Player ESP", "Latency"),
		["weapon_text"] = ui.new_checkbox("VISUALS", "Player ESP", "Weapon text"),
		["weapon_text_color"] = ui.new_color_picker("VISUALS", "Player ESP", "Weapon text color", 255, 255, 255, 255),
		["weapon_ammo"] = ui.new_checkbox("VISUALS", "Player ESP", "Weapon ammo"),
		["weapon_ammo_color"] = ui.new_color_picker("VISUALS", "Player ESP", "Weapon ammo color", 80, 140, 200, 255),
		["hitboxes"] = ui.new_multiselect("VISUALS", "Player ESP", "Hitboxes", "Head", "Neck", "Upper Chest", "Lower Chest", "Thorax", "Stomach", "Pelvis"),
		["hitboxes_color"] = ui.new_color_picker("VISUALS", "Player ESP", "Hitboxes color", 180, 230, 30, 255),
		["hitboxes_size"] = ui.new_slider("VISUALS", "Player ESP", "\n", 8, 24, 14, true, "px"),
		["flags"] = ui.new_multiselect("VISUALS", "Player ESP", "Flags", "Bomb", "Hostage", "Fake duck", "Lethal", "Whitelisted", "Priority", "Closest"),
		["flags_color"] = ui.new_color_picker("VISUALS", "Player ESP", "Flags color", 180, 230, 30, 255)
	}
	
	local storedTick = 0
	local crouched_ticks = { }
	local cached_data = {}
	local lastHitboxSize = 14
	
	-- we dont really need to see that debug slider, but you can comment it out if you do
	ui.set_visible(refs.name_truncate, false)
	
	-- update dormant players' weapons for ESP
	client.set_event_callback("weapon_fire", function(e)
		local player = client.userid_to_entindex(e.userid)
	
		if(cached_data[player] == nil) then cached_data[player] = {} end
		cached_data[player].weapon_name = e.weapon:gsub("weapon_", "")
	end)
	
	client.set_event_callback("item_equip", function(e)
		local player = client.userid_to_entindex(e.userid)
	
		if(cached_data[player] == nil) then cached_data[player] = {} end
		cached_data[player].weapon_name = e.item
	end)
	
	client.set_event_callback("player_hurt", function(e)
		local victim = client.userid_to_entindex(e.userid)
		local attacker = client.userid_to_entindex(e.attacker)
	
		if(cached_data[attacker] == nil) then cached_data[attacker] = {} end
		cached_data[attacker].weapon_name = e.weapon:gsub("weapon_", "")
	
		if(cached_data[victim] == nil) then cached_data[victim] = {} end
		cached_data[victim].health = e.health
	end)
	
	client.set_event_callback("player_spawned", function(e)
		local player = client.userid_to_entindex(e.userid)
	
		if(entity.is_dormant(player)) then
			if(cached_data[player] == nil) then cached_data[player] = {} end
			cached_data[player].health = 100
		end
	end)
	
	client.set_event_callback("paint", function()
		-- everything in here gets ran every frame
	
		-- update the box scale from our custom scale slider reference
		esp.set_box_scale(ui.get(refs.scale))
	
		-- update health bar element visibility
		ui.set_visible(refs.health_color2_label, ui.get(refs.health))
	
		-- update font for hitbox aim points
		if(ui.get(refs.hitboxes_size) ~= lastHitboxSize) then
			lastHitboxSize = ui.get(refs.hitboxes_size)
			fonts.bone_text = renderer.create_font("Small Fonts", lastHitboxSize, 400, {0x010, 0x200})
		end
	
		local players = esp.get_players()
	
		-- loop through every player
		for k, player in pairs(players) do
	
			if crouched_ticks[player] == nil then
				crouched_ticks[player] = 0
			end
	
			-- get the bbox alpha for the current player in the loop
			local a, b, c, d, alpha = entity.get_bounding_box(player)
	
			-- we dont want to confuse the player with dormant results, especially if they're not fading (yet)
			if(a ~= nil and alpha > 0) then
				-- initialize entstuff index if nil for flags
				if(entstuff[player] == nil) then entstuff[player] = {} end
				if(cached_data[player] == nil) then cached_data[player] = {} end
	
				-- local stuff
				local local_player = entity.get_local_player()
				local local_origin = { entity.get_prop(local_player, "m_vecAbsOrigin") }
				local local_weapon = entity.get_player_weapon(local_player)
				local local_weapon_ammo = {total = entity.get_prop(local_weapon, "m_iClip2") or -1}
	
				-- everything we need about the player
				local player_dormant = entity.is_dormant(player)
				local player_resource = entity.get_player_resource()
				local player_name = entity.get_player_name(player)
				local player_origin = { entity.get_prop(player, "m_vecOrigin") }
				local player_velocity = (function() local vx, vy = entity.get_prop(player, "m_vecVelocity") return math.floor(math.min(10000, math.sqrt(vx*vx + vy*vy) + 0.5)) end)() -- ty estk
	
				local player_weapon = entity.get_player_weapon(player)
				local player_weapon_idx = player_weapon ~= nil and band(entity.get_prop(player_weapon, "m_iItemDefinitionIndex"), 0xFFFF) or nil
	
				local player_weapon_name = (function()
					local wepname = "Unknown"
					if(not player_dormant) then
						-- they are alive and can be seen
						wepname = esp.weapon_names[player_weapon_idx] or "Invalid"
	
						if(cached_data[player] == nil) then cached_data[player] = {} end
						cached_data[player].weapon_name = wepname
					else
						if(cached_data[player] ~= nil) then
							wepname = cached_data[player].weapon_name or "Unknown"
						end
					end
	
					return wepname
				end)()
	
				local player_with_C4 = entity.get_prop(player_resource, "m_iPlayerC4", player)
				local player_with_VIP = entity.get_prop(player_resource, "m_iPlayerVIP", player)
	
				local player_duckamnt = entity.get_prop(player, "m_flDuckAmount")
				local player_duckspeed = entity.get_prop(player, "m_flDuckSpeed")
				local player_flags = entity.get_prop(player, "m_fFlags")
	
				local clantag = entity.get_prop(player_resource, "m_szClan", player)
				local latency = entity.get_prop(player_resource, "m_iPing", player)
				local health = entity.get_prop(player, "m_iHealth")
				if(health == nil or (health == 0 and entity.is_alive(player))) then
					health = cached_data[player].health or health
				end
	
				local last_place = (entity.get_prop(player, "m_szLastPlaceName") .. " "):gsub("%u[%l ]", function(c) return " " .. c end):sub(1, -2)
	
				-- cap the players name to a fixed length
				if(#player_name > ui.get(refs.name_truncate)) then
					player_name = string.format("%s...", player_name:sub(1, ui.get(refs.name_truncate)))
				end
	
				if(ui.get(refs.box)) then
					-- add a bounding box to the player
					esp.add_box(player, {ui.get(refs.box_color)}, {0, 0, 0, 255})
				end
	
				if(ui.get(refs.name)) then
					-- add the players name to the top
					esp.add_text(player, "top", {ui.get(refs.name_color)}, fonts.name, player_name)
				end
	
				if(ui.get(refs.clantag) and clantag ~= nil and #clantag > 1) then
					-- add the players clantag above their name (if enabled)
					esp.add_text(player, "top", {ui.get(refs.clantag_color)}, fonts.clantag, clantag:match("^%s*(.-)%s*$"))
				end
	
				if(ui.get(refs.distance)) then
					-- add the players name to the top
					esp.add_text(player, "bottom", {ui.get(refs.distance_color)}, fonts.side_text, round2(getDistance(local_origin, player_origin, "feet")).."FT")
				end
	
				if(ui.get(refs.latency)) then
					-- add the players name to the top
					esp.add_text(player, "right", {getLatencyColor(latency)}, fonts.side_text, latency.."MS")
				end
	
				if(player_weapon ~= nil) then
					if(ui.get(refs.weapon_text) and player_weapon_name ~= nil) then
						local wep = player_weapon_name
						if(player_dormant == true or wep == nil) then
							wep = cached_data[entindex] ~= nil and (cached_data[entindex].weapon ~= nil and cached_data[entindex].weapon or "unknown") or player_weapon_name
						end
	
						if(wep ~= nil) then
							-- add weapon text using class names (ghetto way)
							esp.add_text(player, "bottom", {ui.get(refs.weapon_text_color)}, fonts.side_text, wep:upper())
						else
							print(string.format("Missing weapon name for class %s (IDX: %s)", entity.get_classname(player_weapon), player_weapon_idx))
						end
					end
	
					if(ui.get(refs.weapon_ammo) and player_weapon_name ~= nil) then
						local ammo = entity.get_prop(player_weapon, "m_iClip1") or 0
						local max_ammo = esp.weapon_ammo[player_weapon_idx] or 0
						local percentage = 100 * ammo / max_ammo
	
						if max_ammo > 0 then
							esp.add_bar(player, "bottom", {ui.get(refs.weapon_ammo_color)}, {0, 0, 0, 255}, percentage, ammo, {255, 255, 255, 255}, fonts.bar_text)
						end
					end
				end
	
				if(ui.get(refs.location) and last_place ~= nil and #last_place > 1) then
					-- location
					esp.add_text(player, "right", {ui.get(refs.location_color)}, fonts.side_text, string.upper(last_place))
				end
	
				-- get the health and display it in a bar format
				-- the bar text won't be displayed until the percentage (health) is below 90
				if(ui.get(refs.health) and health ~= nil) then
					esp.add_gradient_bar(player, "left", {ui.get(refs.health_color2)}, {ui.get(refs.health_color)}, {0, 0, 0, 255}, health, health, {255, 255, 255, 255}, fonts.bar_text)
				end
	
				if(health ~= nil and health >= 1 and not player_dormant) then
					-- get selected hitboxes
					local hitboxes = ui.get(refs.hitboxes)
	
					-- draw head dot
					if(#hitboxes >= 1) then
						for k,bone_name in pairs(hitboxes) do
							local x, y, z = entity.hitbox_position(player, boneIndex[bone_name])
	
							if(x ~= nil) then
								local left, top = renderer.world_to_screen(x, y, z)
								local text_w, text_h = renderer.get_text_size(fonts.bone_text, "+")
	
								if(left ~= nil and top ~= nil) then
									local r, g, b, a = 0, 0, 0, 0
									if(bone_name == "Head") then
										r, g, b, a = 255, 0, 0, 255
									else
										r, g, b, a = ui.get(refs.hitboxes_color)
									end
									renderer.draw_text(left - (text_w/2), top - (text_h/2), r, g, b, a, fonts.bone_text, "+")
								end
							end
						end
					end
				end
	
				-- get flags
				local flags = ui.get(refs.flags)
	
				if(has_value(flags, "Bomb") and player_with_C4 ~= nil and player_with_C4 == player) then
					esp.add_text(player, "right", {255, 105, 105, 255}, fonts.side_text, "BOMB", true)
				end
	
				if(has_value(flags, "Hostage") and player_with_VIP ~= nil and player_with_VIP == player) then
					esp.add_text(player, "right", {255, 105, 105, 255}, fonts.side_text, "VIP", true)
				end
	
				if(has_value(flags, "Fake duck")) then
					if(player_duckspeed == 8 and player_duckamnt <= 0.9 and player_duckamnt > 0.01 and toBits(player_flags)[1] == 1) then
						if storedTick ~= globals.tickcount() then
							crouched_ticks[player] = crouched_ticks[player] + 1
							storedTick = globals.tickcount()
						end
	
						if crouched_ticks[player] >= 5 then
							esp.add_text(player, "right", {230, 180, 30, 255}, fonts.side_text, "FD", true)
						end
					end
				end
	
				-- if lethal is enabled and weapon isn't nil
				if(has_value(flags, "Lethal") and local_weapon ~= nil) then
	
					-- get the current weapon's classname
					local_weapon = entity.get_classname(local_weapon)
	
					local isLethal = (function()
	
						-- if the current weapon is a taser, calculate and display the lethal flag
						if(local_weapon == "CWeaponTaser") then
							local dist = getDistance(local_origin, player_origin, "feet")
							if(health <= 80 and dist >= 12) then
								return true
							elseif(health <= 100 and dist < 12) then
								return true
							end
						elseif(weapon_damages[local_weapon] ~= nil) then -- catch everything else in weapon_damages table
							if(health <= weapon_damages[local_weapon]) then
								return true
							end
						end
	
						return false
					end)()
	
					if(isLethal) then
						esp.add_text(player, "right", {230, 180, 30, 255}, fonts.side_text, "LETHAL", true)
					end
				end
	
				-- whitelist flag
				if(has_value(flags, "Whitelisted") and entstuff[player].whitelisted) then
					esp.add_text(player, "right", {ui.get(refs.flags_color)}, fonts.side_text, "WHITELIST")
				end
	
				-- high priority flag
				if(has_value(flags, "Priority") and entstuff[player].prioritized) then
					esp.add_text(player, "right", {ui.get(refs.flags_color)}, fonts.side_text, "PRIORITY", true)
				end
	
				-- closest flag
				if(has_value(flags, "Closest") and k == 1) then
					esp.add_text(player, "right", {ui.get(refs.flags_color)}, fonts.side_text, "CLOSEST", true)
				end
			end
		end
	end)
	
end
coroutine.wrap(CTNQAGV_fake_script)()
