function HandleSpawnMobCommand(Split,Player)
	if Split[2] == nil then
		Player:SendMessageInfo("Usage: /spawnmob [mobtype] [player]")
	end
	Mob = cMonster:StringToMobType(Split[2])
	if Mob == -1 then
		Player:SendMessageFailure("Unknown mob type")
	else
		if Split[3] == nil then
			pos = GetPlayerLookPos(Player)
			if pos.x == 0 and pos.y == 0 and pos.z == 0 then
				--If the player is looking to the air, spawn the mob
				Player:GetWorld():SpawnMob(Player:GetPosX() + 5, Player:GetPosY(), Player:GetPosZ() + 5, Mob)
			else
				--If he's not, spawn the mob where he's looking
				Player:GetWorld():SpawnMob(pos.x, pos.y + 1, pos.z, Mob)
			end
			Player:SendMessageSuccess("Mob spawned")
		elseif Player:HasPermission("es.spawnmob.other") then
			local SpawnMob = function(OtherPlayer)
				if (OtherPlayer:GetName() == Split[3]) then
					pos = GetPlayerLookPos(OtherPlayer)
					if pos.x == 0 and pos.y == 0 and pos.z == 0 then
						OtherPlayer:GetWorld():SpawnMob(OtherPlayer:GetPosX() + 5, OtherPlayer:GetPosY(), OtherPlayer:GetPosZ(), Mob)
					else
						OtherPlayer:GetWorld():SpawnMob(pos.x, pos.y + 1, pos.z, Mob)
					end
					Player:SendMessageSuccess("Spawned mob near "..Split[3])
					return true
				end
			end
			if (not(cRoot:Get():FindAndDoWithPlayer(Split[3], SpawnMob))) then
				Player:SendMessageFailure("Player not found")
			end
		end
	end
	return true
end

function HandleBurnCommand(Split, Player)
	if Split[2] == nil then
		Player:SendMessageInfo("Usage: /burn [player] [seconds]")
	else
		local BurnPlayer = function(OtherPlayer)
			if (OtherPlayer:GetName() == Split[2]) then
				if Split[3] == nil then
					--Burn the player for 10s
					Player:StartBurning(200)
				else
					--Burn the player for the specified time
					Player:StartBurning(Split[3] * 20)
				end
				return true
			end
		end
		if (not(cRoot:Get():FindAndDoWithPlayer(Split[2], BurnPlayer))) then
			Player:SendMessageFailure("Player not found")
		end
	end                  
	return true
end

function HandleExtinguishCommand(Split, Player)
        if Split[2] == nil then
                Player:SendMessageInfo("Usage: /ext [player]")
        else
                local found = cRoot:Get():FindAndDoWithPlayer(Split[2],function(ExtPlayer)
                        if ExtPlayer:GetName() == Split[2] then
                                ExtPlayer:StopBurning()
                        end
                        return true
                end)
                if not found then
                        Player:SendMessageFailure("Player not found")
                end
        end
        return true
end

function HandlePingCommand(Split, Player)
	Player:SendMessage(cChatColor.Green.. "Pong!")
	return true
end

function HandleLightningCommand(Split, Player)
	if (Split[3] == nil) then
		Player:SendMessageInfo("Usage: "..Split[1].." [player] [damage] [-b}")
	else
		local ShockPlayer = function(OtherPlayer)
			if (OtherPlayer:GetName() == Split[2]) then
				--Create a thunderbolt above the player
				OtherPlayer:GetWorld():CastThunderbolt(OtherPlayer:GetPosX(), OtherPlayer:GetPosY(), OtherPlayer:GetPosZ())
				OtherPlayer:TakeDamage(dtPlugin, nil, Split[3], Split[3], 0)
				Player:SendMessageSuccess("A lightning damaged "..Split[2])
				if Split[4] == "-b" then
					--Thunderbolts can burn! :D
					OtherPlayer:StartBurning(200)
				end
				return true
			end
		end
		if (not(cRoot:Get():FindAndDoWithPlayer(Split[2], ShockPlayer))) then
			Player:SendMessageFailure("Player not found")
		end
	end
	return true
end

function HandleItemdbCommand(Split, Player)
	item = cItem()
	if (Split[2] == nil) then
		itemstring = ItemToString(Player:GetEquippedItem())
		item = Player:GetEquippedItem()
		--Show item information
		Player:SendMessageInfo("You are holding "..item.m_ItemCount.." "..itemstring..", ID: "..item.m_ItemType)
	elseif StringToItem(Split[2], item) == true then
		Player:SendMessageInfo(Split[2].." info: ID "..item.m_ItemType..", meta "..item.m_ItemDamage)
	else
		Player:SendMessageFailure("Specify a valid item name")
	end
	return true
end

function HandleMuteCommand(Split, Player)
	if (Split[2] == nil) then
		Player:SendMessageInfo("Usage: "..Split[1].." <player>")
	else
		local MutePlayer = function(OtherPlayer)
			if (OtherPlayer:GetName() == Split[2]) then
				--Mute the player
				UsersIni:SetValue(OtherPlayer:GetName(),   "Muted",   "true")
				UsersIni:WriteFile("users.ini")
				Player:SendMessageSuccess("Muted "..Split[2])
				return true
			end
		end
		if (not(cRoot:Get():FindAndDoWithPlayer(Split[2], MutePlayer))) then
			Player:SendMessageFailure("Player not found")
		end
	end
	return true
end

function HandleUnmuteCommand(Split, Player)
	if (Split[2] == nil) then
		Player:SendMessageInfo("Usage: "..Split[1].." <player>")
	else
		local UnmutePlayer = function(OtherPlayer)
			if (OtherPlayer:GetName() == Split[2]) then
				UsersIni:SetValue(OtherPlayer:GetName(),   "Muted",   "false")
				UsersIni:WriteFile("users.ini")
				Player:SendMessageSuccess("Unuted "..Split[2])
				return true
			end
		end
		if (not(cRoot:Get():FindAndDoWithPlayer(Split[2], UnmutePlayer))) then
			Player:SendMessageFailure("Player not found")
		end
	end
	return true
end

function HandleAntiOchCommand(Split,Player)
	pos = GetPlayerLookPosPlace(Player)
	if pos.x == 0 and pos.y == 0 and pos.z == 0 then
		Player:SendMessageFailure("You're not looking at a block (or it's too far)")
	else
		--Spawn tnt    
		Player:GetWorld():SpawnPrimedTNT(pos.x, pos.y, pos.z, 35)
	end
	return true
end

function HandleInventoryClearCommand(Split,Player)
        if Split[2] == nil then
                Player:SendMessage("Usage: "..Split[1].." <player>")
        else
                local found = cRoot:Get():FindAndDoWithPlayer(Split[2],function(a_Player)
                        a_Player:GetInventory():Clear()
                        return true
                end)
                if not found then
                        Player:SendMessageFailure("Player not found")
                end
        end
        return true
end
