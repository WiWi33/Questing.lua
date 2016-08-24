-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @Rympex


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name		  = 'Goldenrod City'
local description = " Complete Guard's Quest"
local level = 020

local dialogs = {
	guardQuestPart1 = Dialog:new({ 
		"any information on his whereabouts"
	}),
	directorQuestPart1 = Dialog:new({ 
		"there is nothing to see here"
	}),
	guardQuestPart2 = Dialog:new({ 
		"where did you find him",
		"he might be able to help"
	}),
	guardSleepingPart2 = Dialog:new({ 
		"xxx",
		"xxx"
	}),
	guardQuestPart3 = Dialog:new({ 
		"xxxxx",
		"xxxxx"
	})
}

local GoldenrodCityQuest = Quest:new()

function GoldenrodCityQuest:new()
	return Quest.new(GoldenrodCityQuest, name, description, level, dialogs)
end

function GoldenrodCityQuest:isDoable()
	if self:hasMap() then
		if getMapName() == "Goldenrod City" then 
			return isNpcOnCell(48,34)
		else
			return true
		end
	end
	return false
end

function GoldenrodCityQuest:isDone()
	if getMapName() == "Goldenrod City" and not isNpcOnCell(48,34) then
		return true
	else
		return false
	end
end

function GoldenrodCityQuest:PokecenterGoldenrod()
	if hasItem("Basement Key") and not (hasPokemonInTeam("Oddish") or hasPokemonInTeam("Bellsprout")) and not hasItem("spruzzino") and dialogs.guardQuestPart2.state and not dialogs.guardQuestPart3.state then
		fatal("Need Wait FIX for ProShine API [ usePC() ] -  No other quests for now")
	else
		self:pokecenter("Goldenrod City")
	end	
end

function GoldenrodCityQuest:GoldenrodCity()
	if self:needPokecenter() or not game.isTeamFullyHealed() or not self.registeredPokecenter == "Pokecenter Goldenrod" then
		return moveToMap("Pokecenter Goldenrod")
	elseif hasItem("Bike Voucher") then
		return moveToMap("Goldenrod City Bike Shop")
	elseif hasItem("Basement Key") and not game.hasPokemonWithMove("Sleep Powder") and not hasItem("spruzzino") and dialogs.guardQuestPart2.state and not dialogs.guardQuestPart3.state then --get Oddish on PC and start leveling
		if hasPokemonInTeam("Oddish") or hasPokemonInTeam("Bellsprout") then
			if not game.hasPokemonWithMove("Sleep Powder") then
				return moveToMap("Route 34")
			else
				return moveToMap("Goldenrod Mart 1")
			end
		else
			return moveToMap("Pokecenter Goldenrod")
		end
	elseif isNpcOnCell(48,34) then
		if dialogs.guardQuestPart3.state then
			
		elseif dialogs.guardQuestPart2.state then
			if hasItem("Basement Key") then
				
			else
				return moveToMap("Goldenrod City House 2")
			end
		elseif dialogs.guardQuestPart1.state then
			return moveToMap("Goldenrod Underground Entrance Top")
		else
			pushDialogAnswer(2)
			return talkToNpcOnCell(48,34)
		end
	else
	
	end
	
end

function GoldenrodCityQuest:GoldenrodCityBikeShop()
	if hasItem("Bike Voucher") then
		return talkToNpcOnCell(11,3)
	else
		return moveToMap("Goldenrod City")
	end
end

function GoldenrodCityQuest:GoldenrodUndergroundEntranceTop()
	dialogs.guardQuestPart1.state = false
	if dialogs.directorQuestPart1.state then
		return moveToMap("Goldenrod City")
	else
		return moveToMap("Goldenrod Underground Path")
	end
	
end

function GoldenrodCityQuest:GoldenrodUndergroundPath()
	if isNpcOnCell(7,2) then
		return talkToNpcOnCell(7,2) --Item: TM-46   Psywave
	elseif dialogs.directorQuestPart1.state then
		return moveToMap("Goldenrod Underground Entrance Top")
	else
		return talkToNpcOnCell(17,10)
	end
end

function GoldenrodCityQuest:GoldenrodCityHouse2()
	if not hasItem("Basement Key") then
		return talkToNpcOnCell(9,5)
	else
		return moveToMap("Goldenrod City")
	end
end

function GoldenrodCityQuest:MapName()
	
end

function GoldenrodCityQuest:MapName()
	
end

function GoldenrodCityQuest:MapName()
	
end

function GoldenrodCityQuest:MapName()
	
end

function GoldenrodCityQuest:MapName()
	
end

function GoldenrodCityQuest:MapName()
	
end

function GoldenrodCityQuest:MapName()
	
end

function GoldenrodCityQuest:MapName()
	
end

function GoldenrodCityQuest:MapName()
	
end

function GoldenrodCityQuest:MapName()
	
end

function GoldenrodCityQuest:MapName()
	
end

return GoldenrodCityQuest