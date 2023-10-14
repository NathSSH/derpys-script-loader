-- DERPY'S SCRIPT LOADER: SAVING EXAMPLE
--  this script saves how many apples you eat to show how the save system works
--  mostly any lua value can be saved along with normal save games using this system

function main()
	local eating = false
	gSaveData = GetSaveDataTable("test_saving_system") -- returns a table that saves inside normal game saves (by default the table is empty, make sure to use a unique id that won't conflict with other mods)
	while not SystemIsReady() do
		Wait(0)
	end
	if not gSaveData.apples then
		gSaveData.apples = 0 -- initial value if one does not exist
	end
	while true do
		if PedMePlaying(gPlayer,"EatDirect",true) and PedGetWeapon(gPlayer) == 310 then
			eating = true
		elseif eating then
			eating = false
			gSaveData.apples = gSaveData.apples + 1 -- increment our apple count (since we're editing it in the save table, it will save with the game)
		end
		drawText("[saving example]\nJimmy has consumed "..gSaveData.apples.." apples.")
		Wait(0)
	end
end
function drawText(text)
	SetTextFont("Georgia")
	SetTextBold()
	SetTextShadow()
	SetTextScale(1.2)
	SetTextPosition(0.5, 0.9)
	SetTextColor(191, 191, 191, 255)
	DrawText(text)
end
