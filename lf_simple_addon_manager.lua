--[[

SIMPLE ADDON MANAGER
by LibertyForce
http://steamcommunity.com/id/libertyforce/

--]]

local Version = "1.1.1" -- REQUIRES UPDATING VERSION.TXT

local VersionLatest
local VersionNotify = false
local Addons
local SaveData

local AddonsExport --stores Addon name and full URL
local AddonURL
local AddonListText

--Tags Table
local Tags

--Sorting
local SortType = 1
local IsAscending = true

--Menu
local Menu = { }

--Filtering / Searching
local IsFiltered = false
local Name = "" -- Search string for filtering... such a stupid name again...

local function Save()
	for k, v in pairs( Addons ) do
		SaveData[k] = v.tag or nil
	end
	file.Write( "lf_addon_manager.txt", util.TableToJSON( SaveData, true ) )
end


local function ExportAddonList()
	--for k, v in pairs( AddonsExport ) do
	--	AddonURL[k] = v.title or nil
	--end
	file.Write( "addonslist.txt", AddonListText )
	print("List exported to \"...\\garrysmod\\data\\addonlist.txt\" \nShare it with your friends! :D")
end

local function PopulateByFilter()
	if(IsFiltered) then
		Menu.List.FilterPopulate(Name)
		else
		Menu.List.Populate()
	end
end

--This is for exporting addons as list. Simple...
local function GetAddonsExport()

	AddonURL = { }
	AddonsExport = { }
	AddonListText =	"<html><head><title>Addon List</title></head><body>\r\n"
	--CSS style the table
	AddonListText = "<style>table, th, td {border: 2px solid black;border-collapse: collapse;}</style>"
	AddonListText = AddonListText .. "<table style=\"width:700px\">"
	AddonListText = AddonListText .. "<tr><th>Addon Link</th></tr>"
	
	local installed = engine.GetAddons()
	
	for k, v in pairs( installed ) do
		local id
		if tonumber( v.wsid ) > 0 then id = tostring( v.wsid ) else id = "0" end
		AddonsExport[id] = {}
		AddonsExport[id].title = v.title
		--AddonsExport[id].fullURL = "http://steamcommunity.com/sharedfiles/filedetails/?id=" .. id
		AddonsExport[id].steamURL = "steam://url/CommunityFilePage/" .. id
		
		AddonListText = AddonListText .. "<tr>"
		AddonListText = AddonListText .."<th>"
		AddonListText = AddonListText .. "<a href=" .. AddonsExport[id].steamURL .. ">" .. "\"" .. AddonsExport[id].title .. "\"</a>"
		AddonListText = AddonListText .."</th>"
		AddonListText = AddonListText .."</tr>"
	end
	
	AddonListText = AddonListText .. "</body></html>"

	installed = nil
	
	ExportAddonList()
	
end

local function GetAddons()
	
	Addons = { }
	Tags = { }
	if !istable( SaveData ) then SaveData = { } end
	
	if file.Exists( "lf_addon_manager.txt", "DATA" ) then
		local data = util.JSONToTable( file.Read( "lf_addon_manager.txt", "DATA" ) )
		if istable( data ) then
			for k,v in pairs( data ) do
				SaveData[tostring(k)] = v
			end
		end
	end
	
	timer.Simple( 0.1, function()
	
		local installed = engine.GetAddons()
		for k, v in pairs( installed ) do
			local id
			if tonumber( v.wsid ) > 0 then id = tostring( v.wsid ) else id = "0" end
			--if tonumber( v.wsid ) > 0 then id = v.wsid else id = 0 end
			Addons[id] = {}
			Addons[id].title = v.title
			Addons[id].active = v.mounted
			Addons[id].tag = { }
			if istable( SaveData[id] ) then
				for k, v in pairs( SaveData[id] ) do
					table.insert( Addons[id].tag, tostring(v) )
					if !table.HasValue( Tags, tostring(v) ) then
						table.insert( Tags, tostring(v) )
					end
				end
				table.sort( Addons[id].tag, function( a, b )
					return a[1] < b[1];
				end )
			end
		end
		table.sort( Tags, function( a, b )
			return a[1] < b[1];
		end )
		installed = nil
		
		Save()
		PopulateByFilter()
		Menu.Tags.Populate()

	
	end )
	
end

function Menu.Setup()
	
	if IsValid( Menu.Frame ) then
		Menu.Frame:Close()
		return
	end
	
	if VersionNotify then
		
		VersionNotify = false
		
		Menu.Frame = vgui.Create( "DFrame" )
		local fw, fh = 450, 150
		Menu.Frame:SetSize( fw, fh )
		Menu.Frame:SetTitle( "Simple Addon Manager - Update available" )
		Menu.Frame:SetVisible( true )
		Menu.Frame:SetDraggable( false )
		Menu.Frame:SetScreenLock( true )
		Menu.Frame:SetBackgroundBlur( true )
		Menu.Frame:ShowCloseButton( false )
		Menu.Frame:Center()
		Menu.Frame:MakePopup()
		Menu.Frame:SetKeyboardInputEnabled( false )
		Menu.Frame.OnClose = function() Menu.Setup() end
		
		Menu.Panel = Menu.Frame:Add( "DPanel" )
		Menu.Panel:DockPadding( 10, 10, 10, 10 )
		Menu.Panel:Dock( FILL )
		
		local t = Menu.Panel:Add( "DLabel" )
		t:Dock( TOP )
		t:SetText( "There is an update to version "..VersionLatest.." available for Simple Addon Manager.\nTo get the latest version, please copy and paste the URL below to your browser:\n" )
		t:SetDark( true )
		t:SizeToContents()
		
		local t = Menu.Panel:Add( "RichText" )
		t:Dock( TOP )
		t:InsertColorChange( 0, 0, 0, 255 )
		t:AppendText( "https://github.com/LibertyForce-Gmod/Simple-Addon-Manager/releases/latest" )
		t:SetVerticalScrollbarEnabled( false )
		
		local b = Menu.Panel:Add( "DButton" )
		b:Dock( LEFT )
		b:DockMargin( 20, 10, 20, 0 )
		b:SetWidth( 180 )
		b:SetHeight( 20 )
		b:SetText( "Copy URL to clipboard" )
		b.DoClick = function() SetClipboardText( "https://github.com/LibertyForce-Gmod/Simple-Addon-Manager/releases/latest" ) end
		
		local b = Menu.Panel:Add( "DButton" )
		b:Dock( RIGHT )
		b:DockMargin( 20, 10, 20, 0 )
		b:SetWidth( 100 )
		b:SetHeight( 20 )
		b:SetText( "Close" )
		b.DoClick = function() Menu.Frame:Close() end
		
		return
		
	end
	
	Menu.Frame = vgui.Create( "DFrame" )
	local fw, fh = 1060, 700
	Menu.Frame:SetSize( fw, fh )
	Menu.Frame:SetTitle( "Simple Addon Manager - Version "..Version.." - Created by LibertyForce - Modified by [GJ GAMING] Joe" )
	Menu.Frame:SetVisible( true )
	Menu.Frame:SetDraggable( true )
	Menu.Frame:SetScreenLock( false )
	Menu.Frame:ShowCloseButton( true )
	Menu.Frame:Center()
	Menu.Frame:MakePopup()
	Menu.Frame:SetKeyboardInputEnabled( true )
	
	Menu.Frame.btnMinim:SetVisible( false )
	Menu.Frame.btnMaxim:SetVisible( false )
	
	Menu.List = Menu.Frame:Add( "DListView" )
	Menu.List:SetSortable( false )
	Menu.List:Dock( LEFT )
	Menu.List:SetWidth( 790 )
	Menu.List:DockMargin( 10, 4, 10, 10 )
	Menu.List:SetMultiSelect( true )
	local ColID = Menu.List:AddColumn( "ID" )
	local ColActive = Menu.List:AddColumn( " " )
	local ColName = Menu.List:AddColumn( "Name" )
	local ColTags = Menu.List:AddColumn( "Tags" )
	local ColDesc = Menu.List:AddColumn( "Description" )
	ColID:SetFixedWidth( 80 )
	ColActive:SetFixedWidth( 24 )
	

	ColID.DoClick = function()
		if SortType != 0 then
			SortType = 0
			PopulateByFilter()
		end
	end
	ColActive:SetFixedWidth( 20 )
	ColActive.DoClick = function()
		if SortType != 3 and SortType != 4 and SortType != 5 then
			SortType = SortType + 3
			PopulateByFilter()
		end
	end
	ColName.DoClick = function()
		if SortType != 1 then
			SortType = 1
			PopulateByFilter()
		end
	end
	ColTags.DoClick = function()
		if SortType != 2 then
			SortType = 2
			PopulateByFilter()
		end
	end
	
	Menu.List.DoDoubleClick = function( _, _, line )
		gui.OpenURL( "http://steamcommunity.com/sharedfiles/filedetails/?id="..line:GetValue(1) )
	end
	
	--FILLS THE LIST WITH ALL ADDONS
	function Menu.List.Populate()
		Menu.List:Clear()
		local AddonsReadable = { }
		for k, v in pairs( Addons ) do
			local enabled = ""
			if v.active then enabled = "✔" end
			table.insert( AddonsReadable, { k, enabled, v.title, table.concat( v.tag, "; " ) } )
		end
		table.sort( AddonsReadable, function( a, b )

			if SortType == 3 or SortType == 4 or SortType == 5 then
				if a[2] ~= b[2] then return a[2] > b[2]; end
			end
			if SortType == 2 or SortType == 5 then
				if a[4] ~= b[4] then return a[4] < b[4]; end
			end
			if SortType == 1 or SortType == 2 or SortType == 4 or SortType == 5 then
				if a[3] ~= b[3] then return a[3] < b[3]; end
			end
			return tonumber(a[1]) < tonumber(b[1]);
		end )
		for k, v in pairs( AddonsReadable ) do
			Menu.List:AddLine( v[1], v[2], v[3], v[4] )
		end
		--PrintTable(AddonsReadable)
	end
	
	--FILLS THE LIST WITH SEARCHED ADDONS
	function Menu.List.FilterPopulate( str )
		--[[
		ADDED BY [GJ_GAMING] JOE
		This functions is for showing filtered list by a given string. It helps you to find addons
		that you know a part of their name.
		If you enter "fnaf", it'll list all the addons
		containing "fnaf"
		]]--
		Menu.List:Clear()
		--print(str)
		local AddonsReadable = { }
		for k, v in pairs( Addons ) do
			local enabled = ""
			if v.active then enabled = "✔" end	
			--[[
			Let's check if the filter string is in the title of the addon.
			If yes, put it into the AddonsReadable table
			]]--
			if(str:lower() == string.match(v.title:lower(),str:lower())) then
				table.insert( AddonsReadable, { k, enabled, v.title, table.concat( v.tag, "; " ) } )
			end			
		end
		--[[Sorting]]--
		table.sort( AddonsReadable, function( a, b )
			if SortType == 3 or SortType == 4 or SortType == 5 then
				if a[2] ~= b[2] then return a[2] > b[2]; end
			end
			if SortType == 2 or SortType == 5 then
				if a[4] ~= b[4] then return a[4] < b[4]; end
			end
			if SortType == 1 or SortType == 2 or SortType == 4 or SortType == 5 then
				if a[3] ~= b[3] then return a[3] < b[3]; end
			end
			return tonumber(a[1]) < tonumber(b[1]);
		end )
		for k, v in pairs( AddonsReadable ) do
			Menu.List:AddLine( v[1], v[2], v[3], v[4] )
		end
	end
	
	
	
	Menu.Right = Menu.Frame:Add( "DPanel" )
	Menu.Right:SetHeight( 75 )
	Menu.Right:DockMargin( 10, 4, 10, 4 )
	Menu.Right:DockPadding( 10, 4, 10, 4 )
	Menu.Right:Dock( TOP )
	
	local function AddonToggleSelected( value )
		local sel = Menu.List:GetSelected()
		for k, v in pairs( sel ) do
			local id = tostring( v:GetValue(1) )
			steamworks.SetShouldMountAddon( id, value )
		end
		steamworks.ApplyAddons()
		GetAddons()
	end
	
	
	--ENABLE / DISABLE SELECTED ADDONS
	local b = Menu.Right:Add( "DButton" )
	b:Dock( TOP )
	b:DockMargin( 0, 0, 0, 4 )
	b:SetHeight( 30 )
	b:SetText( "Enable selected Addons" )
	b.DoClick = function() AddonToggleSelected( true ) end
	
	local b = Menu.Right:Add( "DButton" )
	b:Dock( TOP )
	b:DockMargin( 0, 0, 0, 10 )
	b:SetHeight( 30 )
	b:SetText( "Disable selected Addons" )
	b.DoClick = function() AddonToggleSelected( false ) end
	
	Menu.Right = Menu.Frame:Add( "DPanel" )
	Menu.Right:SetHeight( 70 )
	Menu.Right:DockMargin( 10, 4, 10, 4 )
	Menu.Right:DockPadding( 10, 4, 10, 4 )
	Menu.Right:Dock( TOP )
	
	--ENABLES / DISABLES ALL ADDONS
	local function AddonToggleAll( value )
		for k, v in pairs( Addons ) do
			steamworks.SetShouldMountAddon( k, value )
		end
		steamworks.ApplyAddons()
		GetAddons()
	end
	
	--ENABLE / DISABLE ALL ADDONS
	local b = Menu.Right:Add( "DButton" )
	b:Dock( TOP )
	b:DockMargin( 0, 0, 0, 10 )
	b:SetHeight( 24 )
	b:SetText( "Enable ALL Addons" )
	b.DoClick = function() AddonToggleAll( true ) end
	
	local b = Menu.Right:Add( "DButton" )
	b:Dock( TOP )
	b:DockMargin( 0, 0, 0, 10 )
	b:SetHeight( 24 )
	b:SetText( "Disable ALL Addons" )
	b.DoClick = function() AddonToggleAll( false ) end
	
	Menu.Right = Menu.Frame:Add( "DPanel" )
	Menu.Right:SetHeight( 54 )
	Menu.Right:DockMargin( 10, 4, 10, 4 )
	Menu.Right:DockPadding( 10, 4, 10, 4 )
	Menu.Right:Dock( TOP )
	
	--FILTER ADDONS
	local t = Menu.Right:Add( "DLabel" )
	t:Dock( TOP )
	t:DockMargin( 0, 0, 0, 4 )
	t:SetText( "Search Addon" )
	t:SetDark( true )
	t:SizeToContents()
	
	--local Filter = Menu.Right:Add( "DTextEntry" )
	local filter = Menu.Right:Add( "DTextEntry" )
	filter:Dock( TOP )
	filter:DockMargin( 0, 0, 0, 4 )
	local txt = tostring( filter:GetValue() )
		
	filter.OnValueChange = function(txt)
		filter:RequestFocus()
		title = tostring( filter:GetValue() )
		if title == "" then
			Menu.List.Populate()
			IsFiltered = false
			return
		end
		Menu.List.FilterPopulate( title )
		IsFiltered = true
		Name = title
	end
	--b:SetHeight( 20 )
	--b.DoClick = function() AddonToggle( false ) end
	
	--[[
	--FILTER BUTTON (NOT NEEDED ANYMORE AS YOU CAN PRESS ENTER TO FILTER)
	local b = Menu.Right:Add( "DButton" )
	b:Dock( TOP )
	b:DockMargin( 0, 0, 0, 4 )
	b:SetHeight( 20 )
	b:SetText( "Filter" )
	b.DoClick = function()
		title = tostring( filter:GetValue() )
		if title == "" then
			Menu.List.Populate()
			IsFiltered = false
			return
		end
		Menu.List.FilterPopulate( title )
		IsFiltered = true
		Name = title
	end
	]]--
	
	
	--ADDON TAG RELATED
	
	Menu.Right = Menu.Frame:Add( "DPanel" )
	--Menu.Right:SetHeight( 226 )
	Menu.Right:DockMargin( 10, 4, 10, 4 )
	Menu.Right:DockPadding( 10, 4, 10, 4 )
	Menu.Right:Dock( TOP )
	
	local t = Menu.Right:Add( "DLabel" )
	t:Dock( TOP )
	t:DockMargin( 0, 0, 0, 4 )
	t:SetText( "Add / Remove tags" )
	t:SetDark( true )
	t:SizeToContents()
	
	Menu.Tags = Menu.Right:Add( "DComboBox" )
	Menu.Tags:Dock( TOP )
	Menu.Tags:DockMargin( 0, 0, 0, 10 )
	Menu.Tags:SetSortItems( false )
	
	function Menu.Tags.Populate()
		Menu.Tags:Clear()
		for k, v in pairs( Tags ) do
			Menu.Tags:AddChoice( v )
		end
	end
	
	local function AddonToggle( value )
		if !Menu.Tags:GetSelected() then return end
		local cat = tostring( Menu.Tags:GetSelected() )
		for k, v in pairs( Addons ) do
			if table.HasValue( Addons[k].tag, cat ) then
				steamworks.SetShouldMountAddon( k, value )
			end
		end
		steamworks.ApplyAddons()
		GetAddons()
	end
	
	local function ChangeCat( cat, add )
		local sel = Menu.List:GetSelected()
		for k,v in pairs( sel ) do
			local id = tostring( v:GetValue(1) )
			if add and !table.HasValue( Addons[id].tag, cat ) then
				table.insert( Addons[id].tag, cat )
				table.sort( Addons[id].tag, function( a, b )
					return a[1] < b[1];
				end )
			elseif !add and table.HasValue( Addons[id].tag, cat ) then
				table.RemoveByValue( Addons[id].tag, cat )
			end
		end
		Save()
		GetAddons()
	end
	
	
	local b = Menu.Right:Add( "DButton" )
	b:Dock( TOP )
	b:DockMargin( 0, 0, 0, 4 )
	b:SetHeight( 20 )
	b:SetText( "Add tag to selected Addons" )
	b.DoClick = function()
		if !Menu.Tags:GetSelected() then return end
		local cat = tostring( Menu.Tags:GetSelected() )
		ChangeCat( cat, true )
	end
	
	local b = Menu.Right:Add( "DButton" )
	b:Dock( TOP )
	b:DockMargin( 0, 0, 0, 10 )
	b:SetHeight( 20 )
	b:SetText( "Remove tag from selected Addons" )
	b.DoClick = function()
		if !Menu.Tags:GetSelected() then return end
		local cat = tostring( Menu.Tags:GetSelected() )
		ChangeCat( cat, false )
	end
	
	
	local b = Menu.Right:Add( "DButton" )
	b:Dock( TOP )
	b:DockMargin( 0, 0, 0, 4 )
	b:SetHeight( 20 )
	b:SetText( "Enable Addons with chosen tag" )
	b.DoClick = function() AddonToggle( true ) end
	
	local b = Menu.Right:Add( "DButton" )
	b:Dock( TOP )
	b:DockMargin( 0, 0, 0, 4 )
	b:SetHeight( 20 )
	b:SetText( "Disable Addons with chosen tag" )
	b.DoClick = function() AddonToggle( false ) end
	

	
	local t = Menu.Right:Add( "DLabel" )
	t:Dock( TOP )
	t:DockMargin( 0, 0, 0, 4 )
	t:SetText( "Add new tag to addons" )
	t:SetDark( true )
	t:SizeToContents()
	
	local TextEntry = Menu.Right:Add( "DTextEntry" )
	TextEntry:Dock( TOP )
	TextEntry:DockMargin( 0, 0, 0, 4 )
	
	local b = Menu.Right:Add( "DButton" )
	b:Dock( TOP )
	b:DockMargin( 0, 0, 0, 4 )
	b:SetHeight( 25 )
	b:SetText( "Add new tag to selected Addons" )
	b.DoClick = function()
		local cat = tostring( TextEntry:GetValue() )
		if cat == "" then return end
		ChangeCat( cat, true )
	end
	
	Menu.Right:InvalidateLayout( true )
	Menu.Right:SizeToChildren( false, true )
	
	--ADDON URL RELATED
	
	Menu.Right = Menu.Frame:Add( "DPanel" )
	Menu.Right:SetHeight( 88 )
	Menu.Right:DockMargin( 10, 4, 10, 4 )
	Menu.Right:DockPadding( 10, 4, 10, 4 )
	Menu.Right:Dock( TOP )

	local b = Menu.Right:Add( "DButton" )
	b:Dock( TOP )
	b:DockMargin( 0, 0, 0, 4 )
	b:SetHeight( 24 )
	b:SetText( "Export Addon URL list as text file" )
	b.DoClick = function()
		GetAddonsExport()
	end
	
	local b = Menu.Right:Add( "DButton" )
	b:Dock( TOP )
	b:DockMargin( 0, 0, 0, 4 )
	b:SetHeight( 24 )
	b:SetText( "Give LIKE to selected Addons" )
	b.DoClick = function()
		local Confirm = Menu.Right:Add( "DMenu" )
		Confirm:AddOption( "Cancel" ):SetIcon( "icon16/cancel.png" )
		Confirm:AddOption( "Confirm", function()
			local sel = Menu.List:GetSelected()
			for k, v in pairs( sel ) do
				local id = tostring( v:GetValue(1) )
				steamworks.Vote( id, true )
			end
		end ):SetIcon( "icon16/accept.png" )
		Confirm:Open()
	end
	
	local b = Menu.Right:Add( "DButton" )
	b:Dock( TOP )
	b:DockMargin( 0, 0, 0, 4 )
	b:SetHeight( 24 )
	b:SetText( "UNINSTALL selected Addons" )
	b.DoClick = function()
		local Confirm = Menu.Right:Add( "DMenu" )
		Confirm:AddOption( "Cancel" ):SetIcon( "icon16/cancel.png" )
		Confirm:AddOption( "Confirm", function()
			local sel = Menu.List:GetSelected()
			for k, v in pairs( sel ) do
				local id = tostring( v:GetValue(1) )
				steamworks.Unsubscribe( id )
			end
			steamworks.ApplyAddons()
			GetAddons()
		end ):SetIcon( "icon16/accept.png" )
		Confirm:Open()
	end
	
	Menu.Right = Menu.Frame:Add( "DPanel" )
	--Menu.Right:SetHeight( 90 )
	Menu.Right:DockMargin( 10, 10, 10, 10 )
	Menu.Right:DockPadding( 10, 4, 10, 4 )
	Menu.Right:Dock( TOP )
	
	local t = Menu.Right:Add( "DLabel" )
	t:Dock( TOP )
	t:SetText( "You can double-click on an addon,\nto visit it's Workshop page." )
	t:SetDark( true )
	t:SizeToContents()
	
	local b = Menu.Right:Add( "DButton" )
	b:Dock( TOP )
	b:DockMargin( 0, 10, 0, 10 )
	b:SetHeight( 30 )
	b:SetText( "Created by LibertyForce\nClick here for my Workshop addons" )
	b.DoClick = function()
		gui.OpenURL( "http://steamcommunity.com/id/libertyforce/myworkshopfiles/?appid=4000" )
	end
	
	Menu.Right:InvalidateLayout( true )
	Menu.Right:SizeToChildren( false, true )
	
	GetAddons()
	
end


http.Fetch( "https://raw.githubusercontent.com/LibertyForce-Gmod/Simple-Addon-Manager/master/VERSION.txt",
	function( body, len, headers, code )
		VersionLatest = body or Version
		if VersionLatest != Version then
			VersionNotify = true
			print( "Simple Addon Manager "..Version.." - Successfully loaded. UPDATE TO VERSION "..VersionLatest.." AVAILABLE: https://github.com/LibertyForce-Gmod/Simple-Addon-Manager/releases/latest" )
		else
			print( "Simple Addon Manager "..Version.." - Successfully loaded. You are using the latest version! Modified by [GJ GAMING] Joe" )
		end
	end,
	function( reason )
		print( "Simple Addon Manager "..Version.." - Successfully loaded. Error: Could not check for updates. ["..reason.."]" )
	end
 )


concommand.Add("addon_manager", Menu.Setup )
concommand.Add("addons", Menu.Setup )
