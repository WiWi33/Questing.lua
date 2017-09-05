-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @Rympex


local sys           = require "Libs/syslib"
local game          = require "Libs/gamelib"
local pc            = require "Libs/pclib"
local team          = require "Libs/teamlib"
local SurfTarget    = require "Data/surfTargets"
local PkmName       = require "Data/pokemonNames"
local Quest         = require "Quests/Quest"
local Dialog        = require "Quests/Dialog"

local name		    = 'Sould Badge'
local description   = 'Fuchsia City'
local level         = 40

local dialogs = {
	questSurfAccept = Dialog:new({ 
		"There is something there I want you to take",
		"Did you get the HM broseph"
	})
}

local SoulBadgeQuest = Quest:new()

function SoulBadgeQuest:new()
	local o = Quest.new(SoulBadgeQuest, name, description, level, dialogs)
	o.zoneExp = 1
	o.pokemonId = 1
	return o
end

function SoulBadgeQuest:isDoable()	
	if self:hasMap() and not hasItem("Marsh Badge") then
		if getMapName() == "Route 15" then 
			if hasItem("Soul Badge") and hasItem("HM03 - Surf") then
				return false
			else
				return true
			end
		else
			return true
		end
	end
	return false
end

function SoulBadgeQuest:isDone()
	if (hasItem("Soul Badge") and hasItem("HM03 - Surf") and getMapName() == "Route 15") or getMapName() == "Safari Entrance" or getMapName() == "Route 20"then
		return true
	else
		return false
	end
end

function SoulBadgeQuest:pokemart_()
	local pokeballCount = getItemQuantity("Pokeball")
	local money         = getMoney()
	if money >= 200 and pokeballCount < 50 then
		if not isShopOpen() then
			return talkToNpcOnCell(9,8)
		else
			local pokeballToBuy = 50 - pokeballCount
			local maximumBuyablePokeballs = money / 200
			if maximumBuyablePokeballs < pokeballToBuy then
				pokeballToBuy = maximumBuyablePokeballs
			end
				return buyItem("Pokeball", pokeballToBuy)
		end
	else
		return moveToMap("Fuchsia City")
	end
end

function SoulBadgeQuest:needPokemart_()
	if getItemQuantity("Pokeball") < 50 and getMoney() >= 200 then
		return true
	end
	return false
end

function SoulBadgeQuest:canEnterSafari()
	return getMoney() > 5000	
end

function SoulBadgeQuest:randomZoneExp()
	if self.zoneExp == 1 then
		if game.inRectangle(51,18,55,22) then--Zone 1
			return moveToGrass()
		else
			return moveToCell(53,20)
		end
	elseif self.zoneExp == 2 then
		if game.inRectangle(65,29,70,31) then--Zone 2
			return moveToGrass()
		else
			return moveToCell(68,30)
		end
	elseif self.zoneExp == 3 then
		if game.inRectangle(62,14,66,15) then--Zone 3
			return moveToGrass()
		else
			return moveToCell(64,14)
		end
	else
		if game.inRectangle(89,14,91,18) then--Zone 4
			return moveToGrass()
		else
			return moveToCell(90,16)
		end
	end
end

function SoulBadgeQuest:PokecenterFuchsia()
    debug = true
    sys.debug("SurfTests+Switch | SoulBadgeQuest.PokecenterFuchsia values:", true)
    sys.debug("team: " .. tostring(team))

    --trying to add relaxo:
    -- -1- strong pkm - high hp, high atk
    -- -2- hopefully caught during progress: the road blocking one
    -- -3- could be used as surfer
    -- -4- apparently very good to beat hannah, to get access to sinnoh
    local preferredSurferId = 38 --Snorlax:38, Persian: 53, Psyduck: 54
    --possible snorlax test states
    local checkStarted, teamTested, pcTestedOrInTeam = 1, 2, 3
    snorlaxCheckState = snorlaxCheckState or checkStarted

    --if team has no surfer or did not try
    surfTarget = team.getFirstPkmWithMove("surf")

    sys.debug(">>> team has no surfer or not tested for relaxo: ")
    sys.debug("surfTarget: " .. tostring(surfTarget))
    sys.debug("snorlaxCheckState: " .. tostring(snorlaxCheckState))
    sys.debug("pcTestedOrInTeam: " .. tostring(pcTestedOrInTeam))
    local noSurferOrNotSnorlaxTested = not surfTarget or snorlaxCheckState ~= pcTestedOrInTeam
    sys.debug(">>> " .. tostring(noSurferOrNotSnorlaxTested))
    if noSurferOrNotSnorlaxTested then

        --check if a preferred surfer exists | abused to switch in snorlax as well
        if snorlaxCheckState == checkStarted then
            local prefSurferTeamId = team.getFirstPkmWithId(preferredSurferId)
            if prefSurferTeamId then
                --if preferred surfer was found, set testing to found
                surfTarget = prefSurferTeamId
                snorlaxCheckState = pcTestedOrInTeam

            else
                --if not, then let pc code, check for one
                snorlaxCheckState = teamTested
                pkmIdSurfIter = preferredSurferId
            end

        --no pkm in team with surf and snorlax was checked already
        -- --then check if any other could learn surf
        elseif snorlaxCheckState == teamTested then
            sys.todo("Take evolutions into account, when testing for surf ability.")

            --retrieves last pkm in team with surf ability
            -- --implemented that way, because it was done fast :)
            local ids = team.getPkmIds()
            sys.debug("ids:" .. tostring(ids~=nil))

            for _, id in pairs(ids) do
                if SurfTarget[id] then
                    surfTarget = PkmName[id]
                    sys.debug("Found pkm(" .. id .. ") that can learn surf in your team.")
                end
            end
        end

        --no pkm in team that has the ability to learn surf | check for surf pkm on pc
        if not surfTarget then
            --init iterator | has to be in global context - don't add local
            pkmIdSurfIter = pkmIdSurfIter or SurfTarget.first()
            --testing for surftargets on pc
            local pkmBoxId, boxId, swapTeamId =
                pc.retrieveFirstFromIds(pkmIdSurfIter, swapTeamId)

            sys.debug("PC | surfIdIterator: " .. tostring(pkmIdSurfIter))
            sys.debug("PC | pkmBoxId: " .. tostring(pkmBoxId or ""))
            sys.debug("PC | boxId: " .. tostring(boxId or ""))
            sys.debug("PC | swapTeamId: " .. tostring(swapTeamId or ""))

            -- boxItem is no solution
            if not pkmBoxId then
                local printTmp = pkmIdSurfIter

                --reseting surf iteration from the beginning, if prefferred surfer was checked
                -- -- do this only the first time
                if snorlaxCheckState == teamTested and pkmIdSurfIter == preferredSurferId then
                    pkmIdSurfIter = SurfTarget.first()
                    snorlaxCheckState = pcTestedOrInTeam
                    sys.debug("Snorlax State update 2 to 3")

                --check next surf candidates | increases iterater by one for next iteration step
                else
                    pkmIdSurfIter = SurfTarget.next(pkmIdSurfIter)
                end

                -- no solution in pc box | when list end of suitable condidates is reached then
                if not pkmIdSurfIter then
                    -- quick fix until pathfinder is added, then catching one wouldn't be much of a hassle
                    return sys.error("No pokemon in your team or on your computer has the ability to surf. Can't progress Quest")
                end

                --not the end yet
                return sys.debug("Switching Surf Target from "..printTmp.." to "..pkmIdSurfIter)

            --search action on current boxItem not finished | don't do other actions | return statement needed
            elseif not boxId then return sys.debug("Starting PC or Switching Boxes")end

            --solution found and added
            local msg = "LOG: Found Surfer on BOX: " .. boxId .. "  Slot: " .. pkmBoxId
            if swapTeamId then  msg = msg .. " | Swapping with pokemon in team N: " .. swapTeamId
            else                msg = msg .. " | Added to team." end
            log(msg)
        end
    end

    --do basic pokecenter related stuff...
	self:pokecenter("Fuchsia City")
    debug = false
end

function SoulBadgeQuest:Route18()
	if not self:canEnterSafari() then
		return moveToMap("Fuchsia City")
	else
		return moveToGrass()
	end
end

function SoulBadgeQuest:FuchsiaCity()
    sys.debug("SoulBadgeQuest.fuchsiaCity() states:", true)
	if BUY_RODS and hasItem("Old Rod") and not hasItem("Good Rod") and getMoney() >= 15000 then
		--go to fising guru's map, if you have enough money and want to buy the super rod
        sys.debug("getting rod")
		return moveToMap("Fuchsia House 1")
	elseif game.minTeamLevel() >= 60 then
        sys.debug("minTeamLevel >= 60, goingt to Route15 Stop House, its need is unknown atm")
		return moveToMap("Route 15 Stop House")
	elseif self:needPokecenter() or not game.isTeamFullyHealed() or not self.registeredPokecenter == "Pokecenter Fuchsia" then
        sys.debug("heading to Pokecenter")
		return moveToMap("Pokecenter Fuchsia")
	elseif isNpcOnCell(13,7) then --Item: PP UP
        sys.debug("getting Item: PP UP")
		return talkToNpcOnCell(13,7)
	elseif isNpcOnCell(12,10) then --Item: Ultra Ball
        sys.debug("getting Item: Ultra Ball")
		return talkToNpcOnCell(12,10)
	elseif self:needPokemart_() and not hasItem("HM03 - Surf") then --It buy balls if not have badge, at blackoutleveling no
        --It buy balls if not have badge, at blackoutleveling no
        sys.debug("buying balls")
		return moveToMap("Safari Stop")
	elseif not self:isTrainingOver() then
        sys.debug("on its way to training")
		return moveToMap("Route 15 Stop House")
	elseif not hasItem("Soul Badge") then
        sys.debug("heading to gym")
		return moveToMap("Fuchsia Gym")
	elseif not self:canEnterSafari() then
        sys.debug("farming, since safari cannot be entered")
		return moveToMap("Route 18")	
	elseif not hasItem("HM03 - Surf") then
		if not dialogs.questSurfAccept.state then
            sys.debug("on its way to fight Viktor | to access safari zone")
			return moveToMap("Fuchsia City Stop House")
		else
            sys.debug("heading to safari zone | to retrieve surf")
			return moveToMap("Safari Stop")
		end
	else
        sys.debug("Quest done, heading to shore")
		return moveToMap("Fuchsia City Stop House")
	end
end

function SoulBadgeQuest:FuchsiaHouse1()
	--talk to fishing guru
	if hasItem("Old Rod") and not hasItem("Good Rod") then return talkToNpcOnCell(3,6)
	--leave when rod obtained
	else return moveToMap("Fuchsia City") end
end

function SoulBadgeQuest:SafariStop()
	if self:needPokemart_() then
		self:pokemart_()
	elseif hasItem("Soul Badge") and dialogs.questSurfAccept.state then
		if not hasItem("HM03 - Surf") and self:canEnterSafari() then
			return talkToNpcOnCell(7,4)
		else
			return moveToMap("Fuchsia City")
		end
	else
		return moveToMap("Fuchsia City")
	end
end

function SoulBadgeQuest:Route15StopHouse()
	if game.minTeamLevel() >= 60 then
		return moveToMap("Route 15")
	elseif self:needPokecenter() or not self.registeredPokecenter == "Pokecenter Fuchsia" or self:isTrainingOver() then
		return moveToMap("Fuchsia City")
	elseif hasItem("HM03 - Surf") then
		return moveToMap("Route 15")
	elseif not self:isTrainingOver() then
		self.zoneExp = math.random(1,4)
		return moveToMap("Route 15")
	else
		return moveToMap("Route 15")
	end
end

function SoulBadgeQuest:FuchsiaCityStopHouse()
	if game.minTeamLevel() >= 60 then
		return moveToMap("Fuchsia City")
	elseif not hasItem("HM03 - Surf") then
		if dialogs.questSurfAccept.state then
			return moveToMap("Fuchsia City")
		else
			return moveToMap("Route 19")
		end
	else
		return moveToMap("Route 19")
	end
end

function SoulBadgeQuest:Route19()
	if game.minTeamLevel() >= 60 then
		return moveToMap("Fuchsia City Stop House")
	elseif hasItem("HM03 - Surf") then
		if not game.hasPokemonWithMove("Surf") then
			if self.pokemonId < getTeamSize() then					
				useItemOnPokemon("HM03 - Surf", self.pokemonId)
				log("Pokemon: " .. self.pokemonId .. " Try Learning: HM03 - Surf")
				self.pokemonId = self.pokemonId + 1
				return
			else
				fatal("No pokemon in this team can learn - Surf")
			end
		else
			return moveToMap("Route 20")
		end
	else
		if dialogs.questSurfAccept.state then
			return moveToMap("Fuchsia City Stop House")
		else
			return talkToNpcOnCell(33,19)
		end
	end
end

function SoulBadgeQuest:Route15()
	if self:needPokecenter() or self:isTrainingOver() or not self.registeredPokecenter == "Pokecenter Fuchsia" then
		return moveToMap("Route 15 Stop House")
	else
		return self:randomZoneExp()
	end
end

function SoulBadgeQuest:FuchsiaGym()
	if not hasItem("Soul Badge") then
		if game.inRectangle(6,16,7,16) then -- Antistuck NearLinkExitCell (7,16) Pathfind Return move on this cell
			return moveToCell(6,15)
		else
			return talkToNpcOnCell(7,10)
		end
	else
		return moveToMap("Fuchsia City")
	end
end

return SoulBadgeQuest