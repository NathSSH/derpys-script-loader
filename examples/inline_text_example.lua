-- DERPY'S SCRIPT LOADER: COMMAND EXAMPLE
--  shows some examples of how to use DrawTextInline

RequireLoaderVersion(3)

function main()
	local index, examples = 1, {
		F_Introduction,
		F_KillAlgernon,
		F_BigObjective,
		F_MultipleFont,
		F_CustomTextXY,
		F_Style3_SetXY,
		F_CustomFormat,
	}
	examples.n = table.getn(examples)
	gCustomFormat = F_InitCustomFormat()
	while not SystemIsReady() do
		Wait(0)
	end
	while true do
		examples[index]()
		DrawTextInline("("..index.." / "..examples.n..")", 0, 2)
		Wait(0)
		if IsButtonBeingPressed(0, 0) then
			TextPrintString("", 0, 1) -- suppress the game's normal mission text
			SoundPlay2D("ButtonDown")
			index = index - 1
			if index < 1 then
				index = examples.n
			end
		elseif IsButtonBeingPressed(1, 0) then
			TextPrintString("", 0, 1)
			SoundPlay2D("ButtonUp")
			index = index + 1
			if index > examples.n then
				index = 1
			end
		end
	end
end

-- EXAMPLE 1
function F_Introduction()
	-- only one text can show for each style at a time (style used for most examples is 1)
	DrawTextInline("You'll never see this!", 0, 1)
	DrawTextInline("Use left / right to navigate examples!", 0, 1)
end

-- EXAMPLE 2
function F_KillAlgernon()
	-- ~r~ makes text red until something else changes the color
	DrawTextInline("KILL ~r~Algernon Papadopoulos", 0, 1)
end

-- EXAMPLE 3
function F_BigObjective()
	-- linebreaks (\n) no longer reset formatting as of DSL 3
	-- ~o~ is the default color for style 1, ~y~ is yellow, and ~c~ is cyan
	DrawTextInline("Travel to ~y~New Coventry ~o~and recruit\n~c~Peanut ~o~for ~g~$400~o~.", 0, 1)
end

-- EXAMPLE 4
function F_MultipleFont()
	-- we use ~f~ to change the font to the next argument we pass (Comic Sans MS)
	-- then the next ~f~ to set the font back to Georgia (the default)
	-- ~a~ sets the alpha and we pass 100 for the first time we used it and 255 for the second
	DrawTextInline("Using ~f~multiple fonts ~f~is allowed\neven if ~a~strange~a~.", "Comic Sans MS", "Georgia", 64, 255, 0, 1)
end

-- EXAMPLE 5
function F_CustomTextXY()
	-- ~xy~ means we pass 2 coords for where to move the text
	-- ~scale~ means we can pass a new scale for the text size
	-- ~~ makes a regular tilde so we can print ~xy~ on screen
	DrawTextInline("~xy+scale~You can use ~magenta~~~xy~~ ~objective~to change position.", 0.5, 0.5, 1.2, 0, 1)
end

-- EXAMPLE 6
function F_Style3_SetXY()
	-- style 3 doesn't center text
	local x_pos = 0.1 / GetDisplayAspectRatio() -- only go a certain distance regardless of aspect ratio
	DrawTextInline("~xy~Style 3 is just like style 1, but it doesn't center text.\n~xy~This is sometimes useful when using ~blue~~~xy~~~o~.", x_pos, 0.5, x_pos, 0.55, 0, 3)
end

-- EXAMPLE 7
function F_CustomFormat()
	-- instead of using a number for style, we use the text format table we made earlier
	-- this allows us to have much finer control of our text while still benefitting from DrawTextInline
	DrawTextInline("This example is using\na ~g~custom style~w~ to display\nwith ~r~predefined custom formatting~w~.", 0, gCustomFormat)
end
function F_InitCustomFormat()
	SetTextPosition(0.15, 0.4)
	SetTextFont("Georgia")
	SetTextBold()
	SetTextOutline()
	SetTextColor(255, 255, 255, 255)
	return PopTextFormatting()
end
