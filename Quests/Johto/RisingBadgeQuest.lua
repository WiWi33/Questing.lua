-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @WiWi__33[NetPaPa]


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name		  = 'Rising Badge Quest'
local description = 'Will exp to lv 80 and earn the 8th badge'
local level = 80

local dialogs = {
	xxx = Dialog:new({ 
		" "
	})
}

local RisingBadgeQuest = Quest:new()

function RisingBadgeQuest:new()
	return Quest.new(RisingBadgeQuest, name, description, level, dialogs)
end

function RisingBadgeQuest:isDoable()
	if self:hasMap() and not hasItem("Rising Badge") and hasItem("Glacier Badge") then
		return true
	end
	return false
end

function RisingBadgeQuest:isDone()
	if hasItem("Rising Badge") and getMapName() == "Blackthorn City Gym" then
		return true
	else
		return false
	end
end

function RisingBadgeQuest:MahoganyTownGym()
	if game.inRectangle(15,50,21,66) then 
		moveToCell(18,67)
	elseif game.inRectangle(12,33,18,45) then  
		moveToCell(17,46)
	elseif game.inRectangle(13,12,20,28) then 
		moveToCell(17,29)
	end
end

function RisingBadgeQuest:PokecenterMahogany()
	if isNpcOnCell(9,22) then
		talkToNpcOnCell(9,22)
	else return self:pokecenter("Mahogany Town")
	end
end


function RisingBadgeQuest:MahoganyTown()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Mahogany Town" then
		moveToMap("Pokecenter Mahogany")
	else moveToMap("Route 44")
	end
end

function RisingBadgeQuest:Route44()
	moveToMap("Ice Path 1F")
end

function RisingBadgeQuest:IcePath1F()
	if game.inRectangle(11,15,49,61) or game.inRectangle(47,13,58,19) then
		moveToCell(57,15)
	else moveToMap("Blackthorn City")
	end
end

function RisingBadgeQuest:IcePathB1F()
	if game.inRectangle (24,41,41,49) or game.inRectangle (14,45,24,43) then
		moveToCell(18,45)
	else
	moveToCell(21,25)
	end
end

function RisingBadgeQuest:IcePathB2F()
	if game.inRectangle (49,9,58,30) then
		moveToCell(50,27)
	else
		moveToCell(23,22)
	end
end

function RisingBadgeQuest:IcePathB3F()
	moveToCell(32,17)
end

function RisingBadgeQuest:BlackthornCity()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Blackthorn City" then
		moveToMap("Pokecenter Blackthorn" )
	elseif not self:isTrainingOver() then 
		moveToMap("Dragons Den Entrance")
	else moveToMap("Blackthorn City Gym")
	end
end

function RisingBadgeQuest:DragonsDenEntrance()
	if self:needPokecenter() then
		moveToMap("Blackthorn City")
	elseif not self:isTrainingOver() then
		moveToMap("Dragons Den")
	else moveToMap("Blackthorn City")
	end
end

function RisingBadgeQuest:DragonsDen()
	if self:needPokecenter() then 
		moveToMap("Dragons Den Entrance")
	elseif not self:isTrainingOver()then
		moveToRectangle(35,17,50,24)
	else moveToMap("Dragons Den Entrance")
	end
end

function RisingBadgeQuest:PokecenterBlackthorn()
	self:pokecenter("Blackthorn City")
end


function RisingBadgeQuest:BlackthornCityGym()
	talkToNpcOnCell(29,12)
end

return RisingBadgeQuest