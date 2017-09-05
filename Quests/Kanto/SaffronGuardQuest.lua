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

	elseif BUY_BIKE then
		--abourt buying a bike, when already gotten one or not enough money
		if hasItem("Bicycle") or BUY_BIKE and getMoney() < 60000 then
			BUY_BIKE = false
			if not hasItem("Bicycle") then
				log("Not enough money, you skipped a quest. You missed out on a fancy new bike :(")
			end

		--enough money, but no Ditto and Voucher or your way back to retrieve swaped pkm
		elseif not hasPokemonInTeam("Ditto") and not hasItem("Bike Voucher")	--need to fetch ditto
			or pkmIdDitto 														--want to retrieve swaped pkm
		then
			return moveToMap("Pokecenter Vermilion")

		--has ditto, get Bike Voucher
		elseif hasPokemonInTeam("Ditto") and not hasItem("Bike Voucher") then
			return moveToCell(32,21)
		end
	end

	--all done - move to next quest location
	return moveToMap("Route 6")
end

function SaffronGuardQuest:PokecenterVermilion()
	--already swapped and we want't to get our pkm back
	if pkmIdDittoSwap then
		return withdrawPokemonFromPC(boxIdDittoSwap, pkmIdDittoSwap)

	-- in need of a ditto
	elseif BUY_BIKE and not hasPokemonInTeam("Ditto") and not hasItem("Bike Voucher") then
		--setting swap target
		local swapId = team.getLowestLvlPkm()

		--take item especially leftovers from it, when it is holding one
		if getPokemonHeldItem(swapId) then return takeItemFromPokemon(swapId) end

		--check for ditto | has to be in global context - don't add local
		pkmIdDittoSwap, boxIdDittoSwap = pc.retrieveFirstFromNames("Ditto")

		-- no solution
		if not pkmIdDittoSwap then
			-- quick fix until pathfinder is added, then moving to route 8 wouldn't
			-- such a hassle to implement
			log("No ditto caught, you skipped a quest. You missed out on a fancy new bike :(")
			BUY_BIKE = false

		--still searching
		elseif not boxIdDittoSwap then return sys.debug("Starting PC or Switching Boxes")

		--solution found, swapping with teammember
		else
			log("LOG: Ditto Found on BOX: " .. boxIdDittoSwap .."  Slot: ".. pkmIdDittoSwap .. "  Swapping with pokemon in team N: " .. swapId)
			return swapPokemonFromPC(boxIdDittoSwap, pkmIdDittoSwap, swapId)
		end
	end

	--not buying a bike or Ditto retrieved
	return moveToMap("Vermilion City")
end

function SaffronGuardQuest:VermilionHouse2Bottom()
	if BUY_BIKE and getMoney() >= 60000 and not hasItem("Bike Voucher") and not hasItem("Bicycle")then
		return talkToNpcOnCell(6,6)
	end
	--leave house, when done
	return moveToMap("Vermilion City")
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