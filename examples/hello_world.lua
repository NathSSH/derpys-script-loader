-- DERPY'S SCRIPT LOADER: BASIC EXAMPLE
--  prints in the console and draws "hello world" on screen

function main()
	print("hello world") -- shows up in the console
	while true do
		SetTextFont("Georgia")
		SetTextBold()
		SetTextOutline()
		SetTextScale(1.5)
		SetTextColor(255, 255, 150, 255)
		SetTextPosition(0.5, 0.2)
		DrawText("hello world") -- draws on the screen using all the options specified above
		Wait(0)
	end
end
