-- DERPY'S SCRIPT LOADER: LOADER CALLBACK EXAMPLE
--  this script shows how the event system works and how to use some events

RequireLoaderVersion(4)

-- stay up past 2AM
RegisterLocalEventHandler("PlayerSleepCheck", function()
	return true -- returning true for this event cancels the player sleep check
end)

-- modify some native scripts to do different things
function F_Nothing()
end
function F_ShopAddItem(...)
	arg[5] = 0
	return ShopAddItem(unpack(arg))
end
RegisterLocalEventHandler("NativeScriptLoaded", function(name, env)
	if name == "AreaScripts/Bdorm.lua" then
		-- change a function the bdorm script to stop little kids from being despawned
		env.F_KillAllLittleKids = F_Nothing
	elseif name == "SStores.lua" then
		-- change SStores.lua's ShopAddItem to be our custom version so we can change prices
		env.ShopAddItem = F_ShopAddItem
	end
	print("loaded "..name)
end)
