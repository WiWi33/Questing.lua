-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @Rympex


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local pc            = require "Libs/pclib"
local team          = require "Libs/teamlib"
local SurfTarget    = require "Data/surfTargets"

local name		  = 'Traveling'
local description = 'Route 8 To Cinnabar Island'
local level = 55

local ToCinnabarQuest = Quest:new()

function ToCinnabarQuest:new()
	local o = Quest.new(ToCinnabarQuest, name, description, level)
	return o
end

function ToCinnabarQuest:isDoable()
	if self:hasMap() and hasItem("Marsh Badge") and not hasItem("Volcano Badge") then
		return true
	end
	return false
end

function ToCinnabarQuest:isDone()
	if getMapName() == "Cinnabar Island" or getMapName() == "Pokecenter Saffron" then --Fix Blackout
		return true
	end
	return false
end

function ToCinnabarQuest:Route8()
	return moveToMap("Lavender Town")
end

function ToCinnabarQuest:PokecenterLavender()
	self:pokecenter("Lavender Town")
end

function ToCinnabarQuest:LavenderTown()
	if self:needPokecenter() or not game.isTeamFullyHealed() or not self.registeredPokecenter == "Pokecenter Lavender" then
		return moveToMap("Pokecenter Lavender")
	else
		return moveToMap("Route 12")
	end
end

function ToCinnabarQuest:Route12()
	if isNpcOnCell(18,47) then --NPC: Snorlax
		return talkToNpcOnCell(18,47)
	elseif isNpcOnCell(4,73) then --Item: Iron
		return talkToNpcOnCell(4,73)
	elseif isNpcOnCell(3,76) then --Item: Rare Candy
		return talkToNpcOnCell(3,76)
	else
		return moveToMap("Route 13")
	end
end

function ToCinnabarQuest:Route13()
	if isNpcOnCell(47,26) then --Item: PP UP
		return talkToNpcOnCell(47,26)
	elseif isNpcOnCell(28,27) then --Item: Calcium
		return talkToNpcOnCell(28,27)
	elseif isNpcOnCell(21,9) then --Item: Ultra Ball
		return talkToNpcOnCell(21,9)
	else
		return moveToCell(18,34) --Fixed: Can't Use moveToMap("Route 14") 1 cell of this link is on water
	end
end

function ToCinnabarQuest:Route14()
	if isNpcOnCell(21,38) then --Item: Lum Berry
		return talkToNpcOnCell(21,38)
	elseif isNpcOnCell(22,38) then --Item: Lum Berry
		return talkToNpcOnCell(22,38)
	elseif isNpcOnCell(12,3) and game.hasPokemonWithMove("Cut")then --Item: Zync
		return talkToNpcOnCell(12,3)
	else
		return moveToMap("Route 15")
	end
end

function ToCinnabarQuest:Route15()
	if isNpcOnCell(52,24) then --Item: TM-18: Counter
		return talkToNpcOnCell(52,24)
	elseif isNpcOnCell(32,14) then --Item: Pecha Berry
		return talkToNpcOnCell(32,14)
	elseif isNpcOnCell(33,14) then --Item: Leppa Berry
		return talkToNpcOnCell(33,14)
	elseif isNpcOnCell(12,14) then --Item: PP UP
		return talkToNpcOnCell(12,14)
	else
		return moveToMap("Route 15 Stop House")
	end
end

function ToCinnabarQuest:Route15StopHouse()
	return moveToMap("Fuchsia City")
end

function ToCinnabarQuest:hasSurfer()
	local surferIds = SurfTarget.getIds()
	local teamIds = team.getPkmIds()
	local matches = Set.intersection(teamIds, surferIds)

	return team.getFirstPkmWithMove("surf") or matches
end

function ToCinnabarQuest:PokecenterFuchsia()

	local surferIds = SurfTarget.getIds()

	--1. check for surfer
	if not self:hasSurfer() then
		local result, pkmBoxId, boxId, swapTeamId =
		pc.retrieveFirstFromIds(surferIds)

		--working 	| then return because of open proShine functions to be resolved
		--			| if not returned, a "can only execute one function per frame" might occur
		if result == pc.result.WORKING then return sys.info("Searching PC")

		--no solution, terminate bot
		elseif  result == pc.result.NO_RESULT then
			return sys.error("No pokemon in your team or on your computer has the ability to surf. Can't progress Quest")
		end

		--solution found and added
		local pkm = result
		local msg = "Found Surfer "..pkm.name.." on BOX: " .. boxId .. "  Slot: " .. pkmBoxId
		if swapTeamId then  msg = msg .. " | Swapping with pokemon in team N: " .. swapTeamId
		else                msg = msg .. " | Added to team." end
		sys.log(msg)

		--do basic pokecenter related stuff...
	else self:pokecenter("Fuchsia City") end

end

function ToCinnabarQuest:isRodObtainable()
	return BUY_RODS and hasItem("Old Rod") and not hasItem("Good Rod") and getMoney() >= 15000
end

function ToCinnabarQuest:FuchsiaHouse1()
	--talk to the fishing guru
	if self.isRodObtainable() then return talkToNpcOnCell(3,6)
	--leave
	else return moveToMap("Fuchsia City") end
end

function ToCinnabarQuest:FuchsiaCity()
	--visiting pokecenter
	if self:needPokecenter() or not game.isTeamFullyHealed() 		--healing
		or not self:hasSurfer()										--getting surfer
		or not self.registeredPokecenter == "Pokecenter Fuchsia"	--register pokecenter
	then
		return moveToMap("Pokecenter Fuchsia")

	--Item: GoodRod
	elseif self.isRodObtainable() then
		return moveToMap("Fuchsia House 1")

	--else progress story
	else return moveToMap("Fuchsia City Stop House") end
end

function ToCinnabarQuest:FuchsiaCityStopHouse()	
	return moveToMap("Route 19")
end

function ToCinnabarQuest:Route19()
	if game.tryTeachMove("Surf","HM03 - Surf") == true then
		return moveToMap("Route 20")
	end
end

function ToCinnabarQuest:Route20()
	if game.inRectangle(52,16,120,36) then
		return moveToCell(60,32)
	elseif game.inRectangle(0,15,51,47) or game.inRectangle(52,40,81,46) then
		return moveToMap("Cinnabar Island")
	else
		error("ToCinnabarQuest:Route20(): [" .. getPlayerX() .. "," .. getPlayerY() .. "] is not a known position")
	end
end

function ToCinnabarQuest:Seafoam1F()
	if game.inRectangle(7,7,20,16) then
		return moveToCell(20,8)
	elseif game.inRectangle(64,7,77,15)then
		return moveToCell(71,15)
	else
		error("ToCinnabarQuest:Seafoam1F(): [" .. getPlayerX() .. "," .. getPlayerY() .. "] is not a known position")
	end
end

function ToCinnabarQuest:SeafoamB1F()
	if isNpcOnCell(38,17) then
		return talkToNpcOnCell(38,17) --Item: Ice Heal
	else
		return moveToCell(85,22)
	end
end

return ToCinnabarQuest