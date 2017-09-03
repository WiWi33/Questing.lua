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

local name		  = 'Goldenrod City'
local description = " Complete Guard's Quest"
local level = 22

local dialogs = {
	martElevatorFloorB1F = Dialog:new({ 
		"on the underground"
	}),
	martElevatorFloor1 = Dialog:new({ 
		"the first floor"
	}),
	martElevatorFloor2 = Dialog:new({ 
		"the second floor"
	}),
	martElevatorFloor3 = Dialog:new({ 
		"the third floor"
	}),
	martElevatorFloor4 = Dialog:new({ 
		"the fourth floor"
	}),
	martElevatorFloor5 = Dialog:new({ 
		"the fifth floor"
	}),
	martElevatorFloor6 = Dialog:new({ 
		"the sixth floor"
	}),
	directorQuestPart1 = Dialog:new({ 
		"there is nothing to see here"
	}),
	guardQuestPart1 = Dialog:new({ 
		"any information on his whereabouts"
	}),
	guardQuestPart2 = Dialog:new({ 
		"where did you find him",
		"he might be able to help"
	})
}

local Doors = {
    [1] = { x = 18, y = 12 }, --this syntax is unneeded, but easy to read
    [2] = { x = 22, y = 16 },
    [3] = { x = 18, y = 18 },
    [4] = { x = 9, y = 18 },
    [5] = { x = 9, y = 12 },
    [6] = { x = 13, y = 16 },
    [7] = { x = 4, y = 16 },
    [8] = { x = 4, y = 10 },
}

local leveler_name_base = "Lever "
local Leveler = {
    A = leveler_name_base .. "A",
    B = leveler_name_base .. "B",
    C = leveler_name_base .. "C",
    D = leveler_name_base .. "D",
    E = leveler_name_base .. "E",
    F = leveler_name_base .. "F",
}

local DoorActivatesBy = {
    [1] = { Leveler.A, Leveler.C }, --this syntax is unneeded, but easy to read
    [2] = { Leveler.D, Leveler.F },
    [3] = { Leveler.F },
    [4] = { Leveler.C },
    [5] = { Leveler.B, Leveler.D },
    [6] = { Leveler.A, Leveler.E },
    [7] = { Leveler.B },
    [8] = { Leveler.E },
}


local GoldenrodCityQuest = Quest:new()

function GoldenrodCityQuest:new()
	local o = Quest.new(GoldenrodCityQuest, name, description, level, dialogs)
	o.need_oddish = false
	o.gavine_done = false
	o.checkCrate1 = false
	o.checkCrate2 = false
	o.checkCrate3 = false
	o.checkCrate4 = false
	o.checkCrate5 = false
	o.checkCrate6 = false
	o.checkCrate7 = false
	return o
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
	if getMapName() == "Goldenrod City" and not isNpcOnCell(50,34) or (getMapName() == "Ilex Forest") then
		return true
	end
	return false
end

function GoldenrodCityQuest:pokemart_()
	local pokeballCount = getItemQuantity("Pokeball")
	local money         = getMoney()
	if money >= 200 and pokeballCount < 50 then
		if not isShopOpen() then
			return talkToNpcOnCell(21,6)
		else
			local pokeballToBuy = 50 - pokeballCount
			local maximumBuyablePokeballs = money / 200
			if maximumBuyablePokeballs < pokeballToBuy then
				pokeballToBuy = maximumBuyablePokeballs
			end
				return buyItem("Pokeball", pokeballToBuy)
		end
	else
		return moveToMap("Goldenrod Mart 1")
	end
end

function GoldenrodCityQuest:PokecenterGoldenrod()
	--go catching oddish
	if self.need_oddish and (not hasPokemonInTeam("Oddish") and not hasPokemonInTeam("Gloom")) then
		log("Oddish with Johto Region NOT FOUND, Next quest: llexForestQuest.lua")
		return moveToMap("Goldenrod City")

	--Get Oddish From PC 
	elseif hasItem("Basement Key") and not hasItem("SquirtBottle") and dialogs.guardQuestPart2.state then
		if not hasPokemonInTeam("Oddish") and not hasPokemonInTeam("Gloom")then
            --swap with gastly useless against Gavin Director
            --swap the pokemon with last pokemon in team | comment m1l4: why the highest lvl pkm?
            sys.todo("check if teamsize is < 6, then replace swap with retrieve", "GoldenRodCityQuest.PokecenterGoldenro")
            local swapId = game.hasPokemonWithName("Gastly") or getTeamSize()

            --check for oddish
            sys.todo("Adding checks for (1)bellsprout with sleep powder, (2)odish and "..
            "(3)bellsprout below sleep powder level or (4-8)theier evolutions.", "GoldenRodCityQuest.PokecenterGoldenro")
            local pkmId, boxId = pc.retrieveFirstWithMoveFrom("Oddish", "Johto")

            -- no solution
            if not pkmId then self.need_oddish = true

            --still searching
            elseif not boxId then return sys.debug("Starting PC or Switching Boxes")

            --solution found and gastly in team
            else
                log("LOG: Oddish Found on BOX: " .. boxId .."  Slot: ".. pkmId .. "  Swapping with pokemon in team N: " .. swapId)
                return swapPokemonFromPC(boxId, pkmId, swapId)
            end
        end
    end

    -- have Oddish
    self:pokecenter("Goldenrod City")
end

function GoldenrodCityQuest:GoldenrodCity()
	if self:needPokecenter() or not game.isTeamFullyHealed() or not self.registeredPokecenter == "Pokecenter Goldenrod" then
		return moveToMap("Pokecenter Goldenrod")
	elseif self:needPokemart() then
		return moveToMap("Goldenrod Mart 1")
	elseif self.need_oddish and (not hasPokemonInTeam("Oddish") and not hasPokemonInTeam("Gloom"))then
		return moveToMap("Route 34")
	elseif hasItem("Bike Voucher") then
		return moveToMap("Goldenrod City Bike Shop")
	elseif not self:isTrainingOver() then
		return moveToMap("Route 34")
	elseif not isNpcOnCell(48,34) then
		return talkToNpcOnCell(50,34)
	elseif hasItem("Basement Key") and not hasItem("SquirtBottle") and dialogs.guardQuestPart2.state then --get Oddish on PC and start leveling
		if not game.hasPokemonWithMove("Sleep Powder") then
			if hasPokemonInTeam("Oddish") then			
				return moveToMap("Route 34")
			else
				return moveToMap("Pokecenter Goldenrod")
			end
		else
			return moveToMap("Goldenrod Mart 1")
		end
	elseif isNpcOnCell(48,34) then
		if dialogs.guardQuestPart2.state then
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
	if dialogs.directorQuestPart1.state or self.gavin_done then
		return moveToMap("Goldenrod City")
	else
		return moveToMap("Goldenrod Underground Path")
	end
end

function GoldenrodCityQuest:GoldenrodUndergroundPath()
	if isNpcOnCell(7,2) then
		return talkToNpcOnCell(7,2) --Item: TM-46   Psywave
	elseif not isNpcOnCell(17,10) then
		if not self.gavin_done then
			return moveToMap("Goldenrod Underground Basement")
		else
			return moveToMap("Goldenrod Underground Entrance Top")
		end
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

function GoldenrodCityQuest:Route34()
	if self:needPokecenter() or not self.registeredPokecenter == "Pokecenter Goldenrod" then
		return moveToMap("Goldenrod City")
	elseif self.need_oddish and (not hasPokemonInTeam("Oddish") and not hasPokemonInTeam("Gloom"))then
		return moveToMap("Route 34 Stop House")
	elseif not self:isTrainingOver() then
		return moveToGrass()
	elseif hasItem("Basement Key") and not hasItem("SquirtBottle") and dialogs.guardQuestPart2.state then --get Oddish on PC and start leveling
		if not game.hasPokemonWithMove("Sleep Powder") then
			if hasPokemonInTeam("Oddish") or hasPokemonInTeam("Gloom") then
				if game.getTotalUsablePokemonCount() < getTeamSize() then
					return moveToMap("Goldenrod City") --oddish is low level so, it will die first every time
				else
					return moveToGrass()
				end
			else
				return moveToMap("Goldenrod City")
			end
		else
			return moveToMap("Goldenrod City")
		end
	else
		return moveToMap("Goldenrod City")
	end
end

function GoldenrodCityQuest:Route34StopHouse()
	if self:needPokecenter() or not self.registeredPokecenter == "Pokecenter Goldenrod" then
		return moveToMap("Route 34")
	elseif self.need_oddish and (not hasPokemonInTeam("Oddish") and not hasPokemonInTeam("Gloom"))then
		self.need_oddish = false
		return moveToMap("Ilex Forest")
	else
		return moveToMap("Route 34")
	end
end

function GoldenrodCityQuest:GoldenrodMartElevator()
	if not hasItem("Fresh Water") then
		if not dialogs.martElevatorFloor6.state then		
			pushDialogAnswer(5)
			pushDialogAnswer(3)
			return talkToNpcOnCell(1,6)
		else
			dialogs.martElevatorFloor6.state = false
			return moveToCell(3,6)
		end
	elseif hasItem("Basement Key") and not hasItem("SquirtBottle") and game.hasPokemonWithMove("Sleep Powder") and dialogs.guardQuestPart2.state then
		if not dialogs.martElevatorFloorB1F.state then		
			pushDialogAnswer(1)
			return talkToNpcOnCell(1,6)
		else
			dialogs.martElevatorFloorB1F.state = false
			return moveToCell(3,6)
		end
	else
		if not dialogs.martElevatorFloor1.state then
			pushDialogAnswer(2)
			return talkToNpcOnCell(1,6)
		else
			dialogs.martElevatorFloor1.state = false
			return moveToCell(3,6)
		end
	end
end

function GoldenrodCityQuest:GoldenrodMart1()
	if self:needPokemart() then
		return moveToMap("Goldenrod Mart 2")
	elseif not hasItem("Fresh Water") then
		return moveToMap("Goldenrod Mart Elevator")
	elseif hasItem("Basement Key") and not hasItem("SquirtBottle") and game.hasPokemonWithMove("Sleep Powder") and dialogs.guardQuestPart2.state then
		return moveToMap("Goldenrod Mart Elevator")
	else
		return moveToMap("Goldenrod City")
	end
end

function GoldenrodCityQuest:GoldenrodMart2()
	if self:needPokemart() then
		self:pokemart_()
	else
		return moveToMap("Goldenrod Mart 1")
	end
end

function GoldenrodCityQuest:GoldenrodMart6()
	if not hasItem("Fresh Water") then
		if not isShopOpen() then
			return talkToNpcOnCell(11, 3)
		else
			if getMoney() > 1000 then
				return buyItem("Fresh Water", 5)
			else
				return buyItem("Fresh Water",(getMoney()/200))
			end
		end
	else
		return moveToMap("Goldenrod Mart Elevator")
	end
end

function GoldenrodCityQuest:GoldenrodMartB1F()
	if hasItem("Basement Key") and not hasItem("SquirtBottle") and dialogs.guardQuestPart2.state and game.hasPokemonWithMove("Sleep Powder") then
		if isNpcOnCell(13,8) then
			pushDialogAnswer(2)
			if  game.hasPokemonWithName("Oddish")  then
			pushDialogAnswer(game.hasPokemonWithName("Oddish"))
			elseif game.hasPokemonWithName("Gloom")  then
			pushDialogAnswer(game.hasPokemonWithName("Gloom"))
			else
			fatal("Error . - No Oddish or Gloom in this team")
			end
			return talkToNpcOnCell(13,8)
		else
			return moveToMap("Underground Warehouse")
		end
	else
		return moveToMap("Goldenrod Mart Elevator")
	end
end

function GoldenrodCityQuest:UndergroundWarehouse()
	if not self.checkCrate1 then --Marill Crate
		if getPlayerX() == 23 and getPlayerY() == 12 then
			talkToNpcOnCell(23,13)
			self.checkCrate1 = true
			return
		else
			return moveToCell(23,12)
		end
	elseif not self.checkCrate2 then --Miltank Crate
		if getPlayerX() == 20 and getPlayerY() == 9 then
			talkToNpcOnCell(20,8)
			self.checkCrate2 = true
			return
		else
			return moveToCell(20,9)
		end
	elseif not self.checkCrate3 then --Abra Crate
		if getPlayerX() == 16 and getPlayerY() == 12 then
			talkToNpcOnCell(15,12)
			self.checkCrate3 = true
			return
		else
			return moveToCell(16,12)
		end
	elseif isNpcOnCell(15,17) then--Item: Revive
		return talkToNpcOnCell(15,17)
	elseif not self.checkCrate4 then --Meowth Crate
		if getPlayerX() == 19 and getPlayerY() == 17 then
			talkToNpcOnCell(19,16)
			self.checkCrate4 = true
			return
		else
			return moveToCell(19,17)
		end
	elseif not self.checkCrate5 then --Heracross Crate
		if getPlayerX() == 24 and getPlayerY() == 22 then
			talkToNpcOnCell(24,23)
			self.checkCrate5 = true
			return
		else
			return moveToCell(24,22)
		end
	elseif not self.checkCrate6 then --Snubbull Crate	
		if getPlayerX() == 13 and getPlayerY() == 24 then
			talkToNpcOnCell(12,24)
			self.checkCrate6 = true
			return
		else
			return moveToCell(13,24)
		end
	elseif not self.checkCrate7 then --Item: Great Balls
		if getPlayerX() == 5 and getPlayerY() == 8 then
			talkToNpcOnCell(5,7)
			self.checkCrate7 = true
			return
		else
			return moveToCell(5,8)
		end
	elseif isNpcOnCell(3,16) then --Item: Antidote
		return talkToNpcOnCell(3,16) 
	else
		self.checkCrate1 = false
		self.checkCrate2 = false
		self.checkCrate3 = false
		self.checkCrate4 = false
		self.checkCrate5 = false
		self.checkCrate6 = false
		self.checkCrate7 = false
		return moveToCell(7,18)
	end
end

function GoldenrodCityQuest:GoldenrodUndergroundBasement()
    -- BASEMENT LEVELRS PUZZLE
    log("DEBUG | GoldenRodPuzzle start")

    -- Radio Director Gavin
    if not isNpcOnCell(5, 4) then
        log("DEBUG | director beaten")
        dialogs.guardQuestPart2.state = false
        self.gavin_done = true

        --leaving
        if self:isDoorClosed(4) then return talkToNpc(Leveler.E)
        elseif self:isDoorClosed(1) then return talkToNpc(Leveler.C)
        else return moveToMap("Goldenrod Underground Path")
        end
    end

    log("DEBUG | start")
    if self:isDoorClosed(8) then return self:openDoor(id) end

--    for id = 8, 1, -1 do
--        log("DEBUG | is door " .. id .. " closed: " .. tostring(self:isDoorClosed(id)))
--        if self:isDoorClosed(id) then
--            log("DEBUG | opening door " .. id)
--            if self:openDoor(id) then return end
--        end
--    end
end

function GoldenrodCityQuest:isDoorClosed(doorId)
    log("DEBUG | isDoorClosed(): " .. doorId)
    local door = Doors[doorId]
    return isNpcOnCell(door.x, door.y)
end

function GoldenrodCityQuest:openDoor(doorId)
    --    log(DoorActivatesBy[doorId])
    for _, leveler in pairs(DoorActivatesBy[doorId]) do
        log("DEBUG | Attempting using : " .. leveler)

        if talkToNpc(leveler) then
            log("DEBUG | used: " .. leveler)
            return true
        end
    end
end


--log("DEBUG | 8")
--if game.inRectangle(19, 0, 40, 20) then
--    return talkToNpcOnCell(26, 13) --Leveler A
--else
--    if isNpcOnCell(8, 8) then --TM62 - Taunt
--        return talkToNpcOnCell(8, 8)
--    elseif isNpcOnCell(5, 4) then --Galvin Director
--        return talkToNpcOnCell(5, 4)
--    else
--        fatal("Error GoldenrodCityQuest:GoldenrodUndergroundBasement()")
--    end
--
--    if not isNpcOnCell(18, 12) and not isNpcOnCell(22, 16) and isNpcOnCell(18, 18) and not isNpcOnCell(13, 16) and isNpcOnCell(9, 12) and not isNpcOnCell(9, 18) and not isNpcOnCell(4, 16) and not isNpcOnCell(4, 10) then --Lever C
--        if isNpcOnCell(5, 4) then --Galvin Director
--            return talkToNpcOnCell(5, 4)
--        else
--            fatal("Error GoldenrodCityQuest:GoldenrodUndergroundBasement()")
--        end
--    else
--        fatal("Error ON PUZZLE RESOLUTION  GoldenrodCityQuest:GoldenrodUndergroundBasement()")
--    end
--end

--	elseif self:isDoorClosed(1) and self:isDoorClosed(2) and self:isDoorClosed(3) and self:isDoorClosed(6) and self:isDoorClosed(5) and self:isDoorClosed(4) and self:isDoorClosed(7) and self:isDoorClosed(8) then --Lever A
--		log("DEBUG | 1")
--		return talkToNpcOnCell(26,13)
--
--	elseif not self:isDoorClosed(1) and self:isDoorClosed(2) and self:isDoorClosed(3) and self:isDoorClosed(6) and self:isDoorClosed(5) and not self:isDoorClosed(4) and self:isDoorClosed(7) and self:isDoorClosed(8) then --Lever C
--		log("DEBUG | 2")
--		return talkToNpcOnCell(17,13)
--
--	elseif self:isDoorClosed(1) and self:isDoorClosed(2) and self:isDoorClosed(3) and not self:isDoorClosed(6) and self:isDoorClosed(5) and not self:isDoorClosed(4) and self:isDoorClosed(7) and self:isDoorClosed(8) then --Lever D
--		log("DEBUG | 3")
--		return talkToNpcOnCell(17,17)
--
--	elseif self:isDoorClosed(1) and not self:isDoorClosed(2) and self:isDoorClosed(3) and not self:isDoorClosed(6) and not self:isDoorClosed(5) and not self:isDoorClosed(4) and self:isDoorClosed(7) and self:isDoorClosed(8) then --Lever C
--		log("DEBUG | 4")
--		return talkToNpcOnCell(17,13)
--
--	elseif not self:isDoorClosed(1) and not self:isDoorClosed(2) and self:isDoorClosed(3) and self:isDoorClosed(6) and not self:isDoorClosed(5) and not self:isDoorClosed(4) and self:isDoorClosed(7) and self:isDoorClosed(8) then --Lever B
--		log("DEBUG | 5")
--		return talkToNpcOnCell(26,17)
--
--	elseif not self:isDoorClosed(1) and not self:isDoorClosed(2) and self:isDoorClosed(3) and self:isDoorClosed(6) and self:isDoorClosed(5) and not self:isDoorClosed(4) and not self:isDoorClosed(7) and self:isDoorClosed(8) then --Lever C
--		log("DEBUG | 6")
--		return talkToNpcOnCell(17,13)
--
--	elseif self:isDoorClosed(1) and not self:isDoorClosed(2) and self:isDoorClosed(3) and not self:isDoorClosed(6) and self:isDoorClosed(5) and not self:isDoorClosed(4) and not self:isDoorClosed(7) and self:isDoorClosed(8) then --Lever C
--		log("DEBUG | 7")
--		return talkToNpcOnCell(8,19)
--
--	elseif self:isDoorClosed(1) and not self:isDoorClosed(2) and self:isDoorClosed(3) and not self:isDoorClosed(6) and self:isDoorClosed(5) and self:isDoorClosed(4) and not self:isDoorClosed(7) and not self:isDoorClosed(8) then	--Lever C





return GoldenrodCityQuest
