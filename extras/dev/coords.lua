-- save player coords with /pos
-- saves in this format: x, y, z, heading

local gFile

SetCommand("pos",function(comment)
	local h,x,y,z = math.deg(PedGetHeading(gPlayer)),PlayerGetPosXYZ()
	PrintOutput(string.format("%.3f, %.3f, %.3f, %.1f",x,y,z,h))
	if not IsScriptZipped() then
		if not gFile then
			gFile = OpenFile("coords.txt","ab")
		end
		if comment then
			WriteFile(gFile,string.format("%.3f,%.3f,%.3f,%.1f -- %s\r\n",x,y,z,h,comment))
		else
			WriteFile(gFile,string.format("%.3f,%.3f,%.3f,%.1f\r\n",x,y,z,h))
		end
		FlushFile(gFile)
	else
		PrintWarning("cannot save to file because the script is zipped")
	end
end,true,"Usage: pos [comment]\nSave the player's position and heading to a file.")
