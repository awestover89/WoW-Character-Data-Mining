AllCharNames = {}
country = string.sub(GetCVar("realmList"),1,2)
realm = GetRealmName()

function GetPartyInfo()
	if GetNumRaidMembers() > 0 then
		for i = 1, GetNumRaidMembers() do
			local unitname, unitrealm = UnitName("raid"..i)
				if unitname == nil then break end
				if unitrealm == nil or unitrealm == "" then
					unitrealm = realm
				end
			AllCharNames[unitname.."-"..unitrealm.."-"..country.."\n"] = "";
			--print(unitname.."-"..unitrealm)
		end
	elseif GetNumPartyMembers() > 0 then
		for i = 1, GetNumPartyMembers() do
			local unitname, unitrealm = UnitName("party"..i)
				if unitname == nil then break end
				if unitrealm == nil or unitrealm == "" then
					unitrealm = realm
				end
			AllCharNames[unitname.."-"..unitrealm.."-"..country.."\n"] = "";
			--AllCharNames = AllCharNames..unitname.."-"..unitrealm.."-"..country.."\n"
			--print(unitname.."-"..unitrealm)
		end
	end
end

function GetTargetInfo()
	if UnitIsPlayer("target") then
		local unitname, unitrealm = UnitName("target")
		if unitname == nil then return nil end
		if unitrealm == nil or unitrealm == "" then
			unitrealm = realm
		end
		AllCharNames[unitname.."-"..unitrealm.."-"..country.."\n"] = "";
	end
end

function GetChatInfo(author)
	if author ~= nil and author ~= "" then
		hasRealm = string.find(author, "-")
		if hasRealm == nil then
			author = author.."-"..realm
		end
		author = author.."-"..country.."\n"
		AllCharNames[author] = "";
	end
end

SLASH_CS490FINAL1 = '/cs490';

function SlashHandle(msg, editbox)
	batch,whole=CanSendAuctionQuery("list")
	if whole then
		print("Can query auctions")
		QueryAuctionItems("",0,0,0,0,0,0,0,0,true)
	else
		print("No can do boss")
	end
end

function getChatNames(names)
	local i = 0
	local n = strfind(names,",",i)
	while(n) do
		AllCharNames[strsub(names,i,n-1).."-"..realm.."-"..country.."\n"] = ""
		i=n+2
		n = strfind(names,",",i)
	end
end

SlashCmdList["CS490FINAL"] = SlashHandle;

function EventHandler(self, event, ...)
	local arg1, arg2 = ...
	if event == "PLAYER_TARGET_CHANGED" then
		GetTargetInfo()
	elseif event == "PARTY_MEMBERS_CHANGED" then
		GetPartyInfo()
	elseif event == "ADDON_LOADED" and arg1 == "CS490Final" then
		print("Loaded")
		AllCharNames = _G["AllCharNames"]
		if AllCharNames == nil then
			AllCharNames = {}
		end
	elseif event == "PLAYER_LOGOUT" then
		_G["AllCharNames"] = AllCharNames
		print(_G["AllCharNames"])
	elseif event == "AUCTION_ITEM_LIST_UPDATE" then
		local MaxAuctions,name,texture,count,quality,canuse,level,minBid,minIncrement,buyoutPrice,bidAmount,highBidder,owner,salestatus
		_,MaxAuctions = GetNumAuctionItems("list")
		local count = 0
		for i=1,MaxAuctions do
			local delay
			delay = time()+10
			name,texture,count,quality,canuse,level,minBid,minIncrement,buyoutPrice,bidAmount,highBidder,owner,salestatus=GetAuctionItemInfo("list",i)
			if owner == nil then
				break
			end
			AllCharNames[owner.."-"..realm.."-"..country.."\n"] = "";
		end
	elseif event == "WHO_LIST_UPDATE" then
		local numWhos, totalCount = GetNumWhoResults()
		for i=1,numWhos do
			local name = GetWhoInfo(i)
			AllCharNames[name.."-"..realm.."-"..country.."\n"] = "";
		end
	elseif event == "CHAT_MSG_CHANNEL_LIST" then
		local names = arg1
		getChatNames(names)
	elseif arg2 ~= nil then
		GetChatInfo(arg2)
	end
end
