-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @Rympex


local sys    = require "Libs/syslib"
local pc     = require "Libs/pclib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name		  = 'Saffron Guard'
local description = 'Route 15 to Saffron City'
local level = 55

local SaffronGuardQuest = Quest:new()

function SaffronGuardQuest:new()
	return Quest.new(SaffronGuardQuest, name, description, level)
end

function SaffronGuardQuest:isDoable()
	if self:hasMap() and not hasItem("Marsh Badge") then
		return true
	end
	return false
end

function SaffronGuardQuest:isDone()
	if getMapName() == "Saffron City" or getMapName() == "Pokecenter Fuchsia" then --Fix Blackout
		return true
	end
	return false
end

function SaffronGuardQuest:Route15()
	if isNpcOnCell(32,14) then --Item: Pecha Berry
		return talkToNpcOnCell(32,14)
	elseif isNpcOnCell(33,14) then --Item: Leppa Berry
		return talkToNpcOnCell(33,14)
	else
		return moveToMap("Route 14")
	end
end

function SaffronGuardQuest:Route14()
	if isNpcOnCell(21,38) then --Item: Lum Berry
		return talkToNpcOnCell(21,38)
	elseif isNpcOnCell(22,38) then --Item: Lum Berry
		return talkToNpcOnCell(22,38)
	else
		return moveToMap("Route 13")
	end
end

function SaffronGuardQuest:Route13()
	return moveToMap("Route 12")
end

function SaffronGuardQuest:Route12()
	return moveToMap("Route 11 Stop House")
end

function SaffronGuardQuest:Route11StopHouse()
	return moveToMap("Route 11")
end

function SaffronGuardQuest:Route11()
	if isNpcOnCell(82,22) then --Item: Great Ball
		return talkToNpcOnCell(82,22)
	elseif isNpcOnCell(79,8) then --Item: Chesto Berry
		return talkToNpcOnCell(79,8)
	elseif isNpcOnCell(80,8) then --Item: Perism Berry
		return talkToNpcOnCell(80,8)
	elseif isNpcOnCell(21,8) then --Item: Awakening
		return talkToNpcOnCell(21,8)
	else
		return moveToMap("Vermilion City")
	end
end

function SaffronGuardQuest:VermilionPokemart()
	self:pokemart("Vermilion City")
end

function SaffronGuardQuest:VermilionCity()

	if self:needPokemart() and getMoney() > 200 then
		return moveToMap("Vermilion Pokemart")

	elseif self:isDittoSwapNeeded() then
		return moveToMap("Pokecenter Vermilion")

	--has ditto, get Bike Voucher
	elseif self:isVoucherNeeded() then
		return moveToCell(32,21)
	end

	--all done - move to next quest location
	return moveToMap("Route 6")
end

function SaffronGuardQuest:isVoucherNeeded()
	return not hasItem("Bike Voucher")
		and hasPokemonInTeam("Ditto")
		and not hasItem("Bicycle")
		and BUY_BIKE
end


function SaffronGuardQuest:isDittoSwapNeeded()
	return not hasItem("Bike Voucher")
		and not hasPokemonInTeam("Ditto")
		and not hasItem("Bicycle")
		and BUY_BIKE
end

function SaffronGuardQuest:isReSwapNeeded()
	return swapBoxId and swapSlotId
end

function SaffronGuardQuest:PokecenterVermilion()
	if not self:isDittoSwapNeeded() then
		local isDittoSwaped = getTeamSize() >= 6

		local dittoId = {132 }
		local result, pkmBoxId, slotId, swapTeamId = pc.retrieveFirstFromIds(dittoId)

		--working 	| then return because of open proShine functions to be resolved
		--			| if not returned, a "can only execute one function per frame" might occur
		if result == pc.result.WORKING then return sys.info("Searching PC")

			--no solution, terminate bot
		elseif  result == pc.result.NO_RESULT then
			-- quick fix until pathfinder is added, then moving to route 8 wouldn't
			-- such a hassle to implement
			BUY_BIKE = false
			return sys.log("No ditto caught, you skipped a quest. You missed out on a fancy new bike :(")
		end

		--solution found and already added to team

		--if team was full set values, needed to return swap target
		if isDittoSwaped then
			swapBoxId = pkmBoxId
			swapSlotId = slotId
		end

		local pkm = result
		local msg = "Found "..pkm.name.." on BOX: " .. pkmBoxId .. "  Slot: " .. slotId
		if swapTeamId then  msg = msg .. " | Swapping with pokemon in team N: " .. swapTeamId
		else                msg = msg .. " | Added to team." end
		sys.log(msg)

	--getting the pokemon, we needed to put down because of ditto
	elseif self:isReSwapNeeded() then
		--start pc
		if not isPCOpen() then return usePC() end
		--refresing
		if not isCurrentPCBoxRefreshed() then return sys.debug("refreshed") end
		-- open correct box for transfer
		if swapBoxId ~= getCurrentPCBoxId() then return openPCBox(swapBoxId) end

		--get the pokemon we put down to retrieve
	    withdrawPokemonFromPC(swapBoxId, swapSlotId)
		swapBoxId, swapSlotId = nil, nil	--reset after swap
		return

	--do basic pokecenter related stuff...
	else self:pokecenter("Fuchsia City") end
end

function SaffronGuardQuest:VermilionHouse2Bottom()
	--retrieve bike voucher
	if self:isVoucherNeeded() then return talkToNpcOnCell(6,6)

	--leave house otherwise when done
	else return moveToMap("Vermilion City") end
end

function SaffronGuardQuest:Route6()
	if isNpcOnCell(31, 5) then -- Berry 1
		return talkToNpcOnCell(31, 5)
	elseif isNpcOnCell(32, 5) then -- Berry 2
		return talkToNpcOnCell(32, 5)
	elseif isNpcOnCell(37, 5) then -- Berry 3
		return talkToNpcOnCell(37, 5)
	elseif isNpcOnCell(38, 5) then -- Berry 4
		return talkToNpcOnCell(38, 5)
	else
		return moveToMap("Route 6 Stop House")
	end
end

function SaffronGuardQuest:Route6StopHouse()
	return moveToMap("Saffron City")
end

return SaffronGuardQuest