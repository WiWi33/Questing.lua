-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @Rympex


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name		  = 'Training for Saffron'
local description = 'Exp in Seafoam'
local level 	  = 65

local ExpForSaffronQuest = Quest:new()

function ExpForSaffronQuest:new()
	return Quest.new(ExpForSaffronQuest, name, description, level)
end

function ExpForSaffronQuest:isDoable()
	if self:hasMap() and not hasItem("Marsh Badge") then
		return true
	end
	return false
end

function ExpForSaffronQuest:isDone()
	if getMapName() == "Route 19" or getMapName() == "Pokecenter Fuchsia" then
		return true
	end
	return false
end

function ExpForSaffronQuest:Route20()
	if not self:isTrainingOver() then
		return moveToCell(60,32) --Seafoam 1F
	else
		return moveToMap("Route 19")
	end
end

function ExpForSaffronQuest:Seafoam1F()
	if not self:isTrainingOver() then
		return moveToCell(20,8) --Seafom B1F
	else
		return moveToMap("Route 20")
	end
end

function ExpForSaffronQuest:SeafoamB1F()
	if not self:isTrainingOver() then
		return moveToCell(64,25) --Seafom B2F
	else
		return moveToCell(15,12)
	end
end

function ExpForSaffronQuest:SeafoamB2F()
	if isNpcOnCell(67,31) then --Item: TM13 - Ice Beam
		return talkToNpcOnCell(67,31)
	end
	if not self:isTrainingOver() then
		return moveToCell(63,19) --Seafom B3F
	else
		return moveToCell(51,27)
	end
end

function ExpForSaffronQuest:SeafoamB3F()
	--Still farming then: Seafom B4F
	if not self:isFinishedFarming() then return moveToCell(57,26)

	--else go home
	else return moveToCell(64,16) end
end

function ExpForSaffronQuest:isFinishedFarming()
	return self:isTrainingOver() 					--as before: training
		and (not BUY_BIKE or getMoney() > 60000)	--additional: money farming, when buying bike is set
end

function ExpForSaffronQuest:SeafoamB4F()
	--Item: Nugget (15000 Money)
	if isNpcOnCell(57,20) then return talkToNpcOnCell(57,20) end
	--moving to ladder, to leave level
	if self:isFinishedFarming() then
		return moveToCell(53,28) end

	if self:needPokecenter() then
		-- use on road nurse only if you have the money
		if getMoney() > 1500 then
			return talkToNpcOnCell(59,13)

		--not enough money and Escape Rope (550) cheaper than feinting (5% of current money)
		elseif hasItem("Escape Rope") and getMoney()*0.05 > 550 then
			return useItem("Escape Rope")
		end
	end

	--else farm / provoke feinting
	return moveToRectangle(50,10,62,32)
end

return ExpForSaffronQuest