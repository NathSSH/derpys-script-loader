-- server browser - derpy54320

-- server status
local gAddress
local gConnected = false
local gDownloading = false
local gKicked

-- browser state
local gIndex = 1
local gServers -- {addr = "address",listing = {...},requested = GetTimer()}
local gBrowser -- ordered using online status and gServers order
local gAddresses = {} -- [realip] = "address"
local gDrawBrowser = false

-- disconnect state
local gDisconnecting

-- main
function main()
	local threads
	local key = GetConfigString(GetScriptConfig(),"open_key","F1")
	if not IsKeyValid(key) then
		PrintWarning("invalid open_key: \""..tostring(key).."\" (check "..GetScriptFilePath("config.txt")..")")
		return
	end
	while not IsNetworkingAllowed() do
		SetTextFont("Arial")
		SetTextBlack()
		SetTextOutline()
		SetTextColor(255,100,50,255)
		SetTextPosition(0.5,0.02)
		SetTextScale(1.2)
		DrawText("Networking is disabled, turn it on in _derpy_script_loader/config.txt.")
		Wait(0)
	end
	CreateAdvancedThread("PRE_FADE","T_DrawStatus")
	DisconnectFromServer()
	F_InitServers()
	while not SystemIsReady() do
		Wait(0)
	end
	while true do
		if threads and not IsThreadRunning(threads[1]) then
			for _,t in ipairs(threads) do
				TerminateThread(t)
			end
			threads = nil
		end
		if IsKeyBeingPressed(key) then
			if gAddress then
				if GetConfigBoolean(GetScriptConfig(),"also_discon",false) then
					gDisconnecting = GetTimer()
				end
			elseif threads then
				for _,t in ipairs(threads) do
					TerminateThread(t)
				end
				threads = nil
			else
				F_ReorderBrowser()
				threads = {CreateThread("T_Controls"),CreateAdvancedThread("PRE_FADE","T_Drawing")}
			end
			SoundPlay2D("ButtonDown")
		elseif gDisconnecting then
			if not gAddress or not IsKeyPressed(key) then
				gDisconnecting = nil
			elseif GetTimer() - gDisconnecting >= 500 then
				SoundPlay2D("ButtonDown")
				DisconnectFromServer()
				gDisconnecting = nil
			end
		end
		while F_UpdateListings(threads ~= nil) do
		end
		Wait(0)
	end
end

-- browser utility
function F_InitServers(servers)
	local listed = {}
	for _,addr in ipairs(GetServerList()) do
		if F_CheckServer(listed,addr) then
			table.insert(listed,addr)
		end
	end
	gServers = {}
	for addr in AllConfigStrings(GetScriptConfig(),"custom_order") do
		if F_RemoveServer(listed,addr) then
			table.insert(gServers,F_GetServer(servers,addr) or {addr = addr})
		end
	end
	if GetConfigBoolean(GetScriptConfig(),"abc_order") then
		F_SortServers(servers,listed)
	end
	for _,addr in ipairs(listed) do
		table.insert(gServers,F_GetServer(servers,addr) or {addr = addr})
	end
end
function F_CheckServer(listed,addr)
	for _,v in ipairs(listed) do
		if v == addr then
			return false
		end
	end
	return true
end
function F_RemoveServer(listed,addr)
	for i,v in ipairs(listed) do
		if v == addr then
			return table.remove(listed,i)
		end
	end
end
function F_GetServer(servers,addr)
	if servers then
		for _,v in ipairs(servers) do
			if v.addr == addr then
				return v
			end
		end
	end
end
function F_SortServers(servers,listed)
	table.sort(listed,function(a,b)
		local x = F_GetServer(servers,a)
		local y = F_GetServer(servers,b)
		return string.lower(x and x.listing and x.listing.name or a) < string.lower(y and y.listing and y.listing.name or b)
	end)
end
function F_ReorderBrowser()
	local order = {}
	F_InitServers(gServers)
	gBrowser = {}
	for i,v in ipairs(gServers) do
		gBrowser[i] = v
		order[v] = i
	end
	table.sort(gBrowser,function(a,b)
		if not a.listing ~= not b.listing then
			return a.listing ~= nil
		end
		return order[a] < order[b]
	end)
end
function F_UpdateListings(open)
	local r
	local req_delay_s = 30000 -- you are advised not to change this so you don't spam servers with connections
	local req_delay_f = 1000
	for _,v in ipairs(gServers) do
		if not v.requested then
			local addr = RequestServerListing(v.addr)
			if addr then
				v.requested = GetTimer() + req_delay_s
				gAddresses[addr] = v.addr
				return true
			end
			v.requested = GetTimer() + req_delay_f
		elseif open and (not r or v.requested < r.requested) then
			r = v
		end
	end
	if r and GetTimer() >= r.requested then
		local addr = RequestServerListing(r.addr)
		if addr then
			r.requested = GetTimer() + req_delay_s
			gAddresses[addr] = r.addr
			return true
		end
		r.requested = GetTimer() + req_delay_f
	end
	return false
end

-- browser threads
function T_Controls()
	local fixcam = false
	while true do
		if IsKeyBeingPressed("UP") then
			SoundPlay2D("NavUp")
			gIndex = gIndex - 1
			if gIndex < 1 then
				gIndex = table.getn(gBrowser)
			end
		elseif IsKeyBeingPressed("DOWN") then
			SoundPlay2D("NavDwn")
			gIndex = gIndex + 1
			if gIndex > table.getn(gBrowser) then
				gIndex = 1
			end
		elseif (IsKeyBeingPressed("RIGHT") or IsKeyBeingPressed("RETURN")) and gBrowser[gIndex] and ConnectToServer(gBrowser[gIndex].addr) then
			SoundPlay2D("ButtonDown")
			return
		end
		if IsButtonBeingReleased(2,0) then
			CameraAllowChange(false)
			fixcam = true
		end
		gDrawBrowser = true
		Wait(0)
		if fixcam then
			CameraAllowChange(true)
			fixcam = false
		end
	end
end
function T_Drawing()
	local fmt
	local list_height = 0.03
	local browser_x = 0.07
	local browser_y = 0.32
	local desc_y = 0.005
	local w_name = 0.4
	local w_detail = 0.1
	local max_show = 20
	local offset = 0
	local hint = not GetConfigBoolean(GetScriptConfig(),"suppress_hint")
	SetTextFont("Georgia")
	SetTextBold()
	SetTextColor(210,210,210,255)
	SetTextAlign("L","T")
	fmt = PopTextFormatting()
	while not gDrawBrowser do
		Wait(0)
	end
	while true do
		local ar = GetDisplayAspectRatio()
		local count = table.getn(gBrowser)
		local height,width,w,h = 0,(list_height+w_name+w_detail)/ar
		local description = "No server information available, it may be offline or running a different version."
		if count <= max_show then
			offset = 0
		elseif gIndex <= offset then
			offset = gIndex - 1
		elseif gIndex - offset > 4 then
			offset = gIndex - max_show
		end
		if hint and (count == 0 or (count == 1 and gBrowser[1].addr == "localhost:17017")) then
			SetTextFont("Arial")
			SetTextBlack()
			SetTextOutline()
			SetTextColor(255,100,50,255)
			SetTextPosition(0.5,0.02)
			SetTextScale(1.2)
			DrawText("You can list more servers by adding them to _derpy_script_loader/config.txt.")
		end
		SetTextFormatting(fmt)
		SetTextHeight(list_height)
		for i = 1,max_show do
			local v = gBrowser[offset+i]
			if v then
				w,h = MeasureText(v.listing and v.listing.name or v.addr)
				height = math.max(height,h+list_height*(i-1))
			end
		end
		DiscardText()
		SetTextFont("Arial")
		SetTextBlack()
		SetTextColor(255,255,255,255)
		SetTextScale(1.2)
		--SetTextShadow()
		SetTextAlign("L","B")
		SetTextPosition(browser_x/ar+width*0.01,browser_y)
		w,h = MeasureText("SERVER BROWSER")
		DrawRectangle(browser_x/ar,browser_y-h,width,h,0,0,0,255)
		DrawText("SERVER BROWSER")
		SetTextFont("Arial")
		SetTextBlack()
		SetTextColor(255,255,255,255)
		SetTextScale(0.95)
		--SetTextShadow()
		SetTextAlign("R","C")
		SetTextPosition(browser_x/ar+width*0.99,browser_y-h/2)
		DrawText("("..gIndex.." / "..count..")")
		DrawRectangle(browser_x/ar,browser_y,width,height,16,16,16,128)
		for i = 1,max_show do
			local v = gBrowser[offset+i]
			if v then
				local x,y= browser_x/ar,browser_y+list_height*(i-1)
				SetTextFormatting(fmt)
				SetTextPosition(x+list_height/ar,y)
				SetTextHeight(list_height)
				SetTextClipping(w_name/ar)
				w,h = MeasureText(v.listing and v.listing.name or v.addr)
				if offset + i == gIndex then
					DrawRectangle(x,y,width,h,210,210,210,128)
					SetTextColor(255,192,0,255)
					SetTextOutline()
				elseif not v.listing then
					SetTextColor(120,120,120,255)
				end
				if v.listing then
					if v.listing.icon then
						DrawTexture(v.listing.icon,x,y+math.max(0,h-list_height)/2,list_height/ar,list_height,255,255,255,255)
					end
					DrawText(v.listing.name)
				else
					DrawText(v.addr)
				end
				if v.listing then
					SetTextFormatting(fmt)
					SetTextPosition(x+(list_height+w_name+w_detail*0.95)/ar,y)
					SetTextAlign("R","T")
					SetTextHeight(list_height)
					SetTextClipping(w_detail/ar)
					if offset + i == gIndex then
						SetTextColor(16,16,16,255)
					end
					DrawText(v.listing.players.." / "..v.listing.max_players)
				end
			end
		end
		if gBrowser[gIndex].listing then
			description = gBrowser[gIndex].listing.info
		end
		SetTextFormatting(fmt)
		SetTextScale(0.9)
		SetTextWrapping(width)
		SetTextPosition(browser_x/ar,browser_y+height+desc_y)
		SetTextColor(200,200,200,255)
		w,h = MeasureText(description)
		DrawRectangle(browser_x/ar,browser_y+height+desc_y,width,h,16,16,16,128)
		DrawText(description)
		gDrawBrowser = false
		repeat
			Wait(0)
		until gDrawBrowser
	end
end

-- monitor server events
RegisterLocalEventHandler("ServerListing",function(address,listing)
	address = gAddresses[address]
	if address then
		for _,v in ipairs(gServers) do
			if v.addr == address then
				v.listing = listing -- icon, info, max_players, mode, name, players
			end
		end
		F_ReorderBrowser()
	end
end)
RegisterLocalEventHandler("ServerConnecting",function(address)
	gAddress = address
end)
RegisterLocalEventHandler("ServerConnected",function()
	gConnected = true
	gDownloading = false
end)
RegisterLocalEventHandler("ServerDisconnected",function()
	if gAddress then
		gKicked = {reason = "disconnected from server",started = GetTimer(),red = false}
	end
	gAddress = nil
	gConnected = false
	gDownloading = false
end)
RegisterLocalEventHandler("ServerDownloading",function()
	if not gConnected then
		gDownloading = true
	end
end)
RegisterLocalEventHandler("ServerKicked",function(reason)
	if string.find(reason,"%S") then
		reason = "kicked from server: "..reason
	else
		reason = "kicked from server"
	end
	gKicked = {reason = reason,started = GetTimer(),red = true}
end)

-- monitor status thread
function T_DrawStatus(reason)
	local fmt
	SetTextFont("Arial")
	SetTextBlack()
	SetTextOutline()
	SetTextPosition(0.5,0.02)
	SetTextScale(1.2)
	SetTextColor(220,220,220,255)
	fmt = PopTextFormatting()
	while true do
		if gAddress then
			if gDisconnecting then
				SetTextFormatting(fmt)
				DrawText("disconnecting from server"..string.rep(".",math.min(math.ceil(((GetTimer()-gDisconnecting)/500)*3),3)))
			elseif gDownloading then
				SetTextFormatting(fmt)
				DrawText("downloading server files")
			elseif not gConnected then
				SetTextFormatting(fmt)
				DrawText("connecting to server")
			end
		elseif gKicked then
			if GetTimer() - gKicked.started < 3000 then
				SetTextFormatting(fmt)
				if gKicked.red then
					SetTextColor(255,50,50,255)
				end
				DrawText(gKicked.reason)
			else
				gKicked = nil
			end
		end
		Wait(0)
	end
end

-- conditional keyboard input
function IsKeyBeingPressed(...)
	if IsConsoleActive() then
		return false
	end
	return _G.IsKeyBeingPressed(unpack(arg))
end
function IsKeyPressed(...)
	if IsConsoleActive() then
		return false
	end
	return _G.IsKeyPressed(unpack(arg))
end

-- debug listing requests
function RequestServerListing(...)
	--print("request listing: "..tostring(arg[1]))
	return _G.RequestServerListing(unpack(arg))
end
