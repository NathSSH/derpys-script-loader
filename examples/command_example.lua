-- DERPY'S SCRIPT LOADER: COMMAND EXAMPLE
--  creates a few commands to show how commands are used

-- ex: /give_weapon 301
SetCommand("give_weapon", function(weapon)
	weapon = tonumber(weapon) -- convert from string to number
	if weapon and weapon >= 299 and weapon <= 444 then
		PedSetWeapon(gPlayer, weapon, 30)
		PrintOutput("player was given weapon #"..weapon)
	else
		PrintError("invalid weapon given")
	end
end)

-- ex: /echo_command test arguments
SetCommand("echo_command", function(...)
	for index, str in ipairs(arg) do -- arg is a table of all arguments passed (this is a feature of lua 5.0.2)
		print("arg "..index..": "..str)
	end
end)

-- ex: /echo_command_raw test arguments
SetCommand("echo_command_raw", function(raw_arg)
	if raw_arg then
		print("arg 1: "..raw_arg)
	else
		print("no argument given")
	end
end, true)
