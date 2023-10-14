-- DERPY'S SCRIPT LOADER: KEYBOARD EXAMPLE
--  press F1 to restore player health
--  press F2 to spawn a bodyguard

LoadScript("peds.lua") -- loads peds.lua into this script (remember loading is different from starting)

function main()
	while not SystemIsReady() do
		Wait(0)
	end
	while true do
		if IsKeyBeingPressed("VK_F1") then
			local hp = PedGetMaxHealth(gPlayer)
			PlayerSetHealth(hp)
			print("health restored: "..hp)
		elseif IsKeyBeingPressed("VK_F2") then
			F_SpawnBodyguardByName()
		end
		Wait(0)
	end
end
function F_SpawnBodyguardByName()
	StartTyping() -- start allowing input on the keyboard
	while IsTypingActive() do
		F_DrawText("Spawn bodyguard: "..GetTypingString()) -- show what we're typing
		PlayerSetControl(0) -- disable player control while typing
		Wait(0)
	end
	if not WasTypingAborted() then -- make sure we actually hit enter on the text rather than escape
		local model = F_SearchForModel("N_"..GetTypingString()) -- search for a ped model with the name "N_" + what we typed
		if model then
			F_CreateBodyguard(model)
			PrintOutput("spawned bodyguard: \""..GetTypingString().."\"")
		else
			PrintError("no ped with the name \""..GetTypingString().."\"")
		end
	end
	PlayerSetControl(1) -- re-enable player control now that we're done
end
function F_DrawText(text)
	SetTextFont("Georgia")
	SetTextBold()
	SetTextOutline()
	SetTextScale(1.5)
	SetTextPosition(0.5, 0.05)
	SetTextColor(255, 255, 150, 255)
	DrawText(text)
end
function F_SearchForModel(name)
	name = string.lower(name) -- we're gonna be case in-sensitive
	-- gDefaultPeds is defined in "peds.lua"
	for index, data in ipairs(gDefaultPeds) do
		if name == string.lower(data[16]) then -- the 16th value in each ped's table is their name
			return index - 1 -- the ped table starts at model 0 but lua arrays start at 1 so we must subtract 1 from the table index
		end
	end
end
function F_CreateBodyguard(model)
	local h, x, y, z = PedGetHeading(gPlayer), PlayerGetPosXYZ()
	local ped = PedCreateXYZ(model, x-math.sin(h), y+math.cos(h), z) -- spawn in front of player
	local leader = gPlayer
	while PedHasAllyFollower(leader) do -- does the player have an ally already? (or does the next person in the ally chain)
		leader = PedGetAllyFollower(leader) -- if so then that ped will recruit an ally instead
	end
	PedRecruitAlly(leader, ped) -- each ped can only have one ally so we must recruit allies in a chain
	PedFaceHeading(ped, math.deg(h)) -- facing same way as player
	GameSetPedStat(ped, 6, 0) -- fearless
	GameSetPedStat(ped, 7, 0) -- no chicken
	GameSetPedStat(ped, 8, 100) -- high attack frequency
	GameSetPedStat(ped, 14, 100) -- aggressive
	PedSetHealth(ped, PedGetMaxHealth(ped)*3) -- 3x health
	PedSetPedToTypeAttitude(ped, 13, 4) -- love the player
end
