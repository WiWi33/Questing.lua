-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.

local sys  = require "Libs/syslib"
local game = require "Libs/gamelib"
local team = require "Libs/teamlib"

local blacklist = require "blacklist"

local Quest = {}

function Quest:new(name, description, level, dialogs)
	local o = {}
	setmetatable(o, self)
	self.__index     = self
	o.name        = name
	o.description = description
	o.level       = level or 1
	o.dialogs     = dialogs
	o.training    = true
	o.canRun	  = true
	o.canSwitch   = true
	return o
end

function Quest:isDoable()
	sys.error("Quest:isDoable", "function is not overloaded in quest: " .. self.name)
	return nil
end

function Quest:isDone()
	return self:isDoable() == false
end

function Quest:mapToFunction()
	local mapName = getMapName()
	local mapFunction = sys.removeCharacter(mapName, ' ')
	mapFunction = sys.removeCharacter(mapFunction, '.')
	mapFunction = sys.removeCharacter(mapFunction, '-') -- Map "Fisherman House - Vermilion"
	return mapFunction
end

function Quest:hasMap()
	local mapFunction = self:mapToFunction()
	if self[mapFunction] then
		return true
	end
	return false
end

function Quest:pokecenter(exitMapName) -- idealy make it work without exitMapName
	self.registeredPokecenter = getMapName()
	sys.todo("add a moveDown() or moveToNearestLink() or getLinks() to PROShine")
	if not game.isTeamFullyHealed() then
		return usePokecenter()
	end
	return moveToMap(exitMapName)
end

-- at a point in the game we'll always need to buy the same things
-- use this function then
function Quest:pokemart(exitMapName)
	local pokeballCount = getItemQuantity("Pokeball")
	local escapeRopeCount = getItemQuantity("Escape Rope")
	local money         = getMoney()

	--pokeballs
	if money >= 200 and pokeballCount < 50 then
		--talk to shop owner - can it be they are always located at 3,5? Doesn't seem right
		if not isShopOpen() then return talkToNpcOnCell(3,5) end

		--else prepare buying
		local pokeballToBuy = 50 - pokeballCount
		local maximumBuyablePokeballs = money / 200
		pokeballToBuy = math.min(pokeballToBuy, maximumBuyablePokeballs)

		return buyItem("Pokeball", pokeballToBuy)

	--escape ropes added for jails and other circumstances
	elseif money >= 550 and escapeRopeCount < 3 then
		--talk to shop owner - can it be they are always located at 3,5? Doesn't seem right
		if not isShopOpen() then return talkToNpcOnCell(3,5) end

		--else prepare buying
		local ropesToBuy = 5 - escapeRopeCount
		local maxBuyableRopes = money / 550
		ropesToBuy = math.min(ropesToBuy, maxBuyableRopes)

		return buyItem("Escape Rope", ropesToBuy)

	--if nothing to buy, leave mart
	else return moveToMap(exitMapName) end
end

function Quest:isTrainingOver()
	if game.minTeamLevel() >= self.level then
		if self.training then -- end the training
			self:stopTraining()
		end
		return true
	end
	return false
end

function Quest:leftovers()
	ItemName = "Leftovers"
	local PokemonNeedLeftovers = game.getFirstUsablePokemon()
	local PokemonWithLeftovers = game.getPokemonIdWithItem(ItemName)
	
	-- EXCEPTIONS FOR REMOVE LEFTOVERS FROM POKEMON
	if getMapName() == "Route 27" and not hasItem("Zephyr Badge") then --START JOHTO
		if PokemonWithLeftovers > 0 then
			takeItemFromPokemon(PokemonWithLeftovers)
			return true
		end
		return false
	end
	if getMapName() == "Pokecenter Goldenrod" and not hasItem("Plain Badge") then --REMOVE LEFTOVERS FROM ODDISH - GoldenrodCityQuest.lua
		if PokemonWithLeftovers > 0 then
			takeItemFromPokemon(PokemonWithLeftovers)
			return true
		end
		return false
	end
	------
	
	if getTeamSize() > 0 then
		if PokemonWithLeftovers > 0 then
			if PokemonNeedLeftovers == PokemonWithLeftovers  then
				return false -- now leftovers is on rightpokemon
			else
				takeItemFromPokemon(PokemonWithLeftovers)
				return true
			end
		else

			if hasItem(ItemName) and PokemonNeedLeftovers ~= 0 then
				giveItemToPokemon(ItemName,PokemonNeedLeftovers)
				return true
			else
				return false-- don't have leftovers in bag and is not on pokemons
			end
		end
	else
		return false
	end
end

function Quest:useBike()
	if hasItem("Bicycle") then
		if isOutside() and not isMounted() and not isSurfing() and getMapName() ~= "Cianwood City" and getMapName() ~= "Route 41" then
			useItem("Bicycle")
			log("Using: Bicycle")
			return true --Mounting the Bike
		else
			return false
		end
	else
		return false
	end
end

function Quest:startTraining()
	self.training = true
end

function Quest:stopTraining()
	self.training = false
	self.healPokemonOnceTrainingIsOver = true
end

function Quest:needPokemart()
	-- TODO: ItemManager
	if getItemQuantity("Pokeball") < 50 and getMoney() >= 200 then
		return true
	end
	return false
end

function Quest:needPokecenter()
	if getTeamSize() == 1 then
		if getPokemonHealthPercent(1) <= 50 then return true end

	-- else we would spend more time evolving the higher level ones
	elseif not self:isTrainingOver() then
		-- <= needed, if last pkm has no pp, it's also unusable therefor value = 0
		if getUsablePokemonCount() <= 1
			or not team.getAlivePkmToLvl(self.level)
		then return true end

	elseif not game.isTeamFullyHealed()
		and self.healPokemonOnceTrainingIsOver
	then return true

	-- the team is fully healed and training over
	else self.healPokemonOnceTrainingIsOver = false end

	return false
end

-- the team is fully healed and training over

function Quest:message()
	return self.name .. ': ' .. self.description
end

-- I'll need a TeamManager class very soon
local moonStoneTargets = {
	"Clefairy",
	"Jigglypuff",
	"Munna",
	"Nidorino",
	"Nidorina",
	"Skitty"
}

function Quest:evolvePokemon()
	local hasMoonStone = hasItem("Moon Stone")
	for pokemonId=1, getTeamSize(), 1 do
		local pokemonName = getPokemonName(pokemonId)
		if hasMoonStone
			and sys.tableHasValue(moonStoneTargets, pokemonName)
		then
			return useItemOnPokemon("Moon Stone", pokemonId)
		end
	end
	return false
end

--prevents the sort algorithm being visualized - e.g. when gm inspects team
function Quest:sortInMemory()
	--setting lowest level pkm as starter
	local starter = team.getStarter()
	local lowestAlivePkmToLvl = team.getLowestAlivePkmToLvl(self.level)
	if lowestAlivePkmToLvl and 			--if one exists, skips if nothing found
		starter ~= lowestAlivePkmToLvl	--skips if found target the starter already
	then return swapPokemon(lowestAlivePkmToLvl, starter) end

	--setting highest level pkm, as last defense wall
	local highestAlivePkm = team.getHighestPkmAlive()
	local lastPkm = team.getLastPkmAlive()
	if highestAlivePkm ~= lastPkm then return swapPokemon(highestAlivePkm, lastPkm) end
end


function Quest:path()
	if self:evolvePokemon() then return true end
	if self:sortInMemory() then return true end
	if self:leftovers() then return true end
	if self:useBike() then return true end
	local mapFunction = self:mapToFunction()
	assert(self[mapFunction] ~= nil, self.name .. " quest has no method for map: " .. getMapName())
	self[mapFunction](self)
end

function Quest:isPokemonBlacklisted(pokemonName)
	return sys.tableHasValue(blacklist, pokemonName)
end

-- I'll need a TeamManager class very soon
local blackListTargets = { --it will kill this targets instead catch
--	"Metapod",
--	"Kakuna",
--	"Doduo",
--	"Hoothoot",
--	"Zigzagoon"
}

function Quest:battle()
	-- catching
	local isEventPkm = getOpponentForm() ~= 0
	if isWildBattle() 													--if it's a wild battle:
		and (isOpponentShiny() 											--catch special pkm
			or isEventPkm
			or (not isAlreadyCaught() 									--catch not seen pkm
				and not self:isPokemonBlacklisted(getOpponentName()))
			or (self.pokemon 											--catch quest related pkm
				and getOpponentName() == self.pokemon
				and self.forceCaught ~= nil
				and self.forceCaught == false))
	then if useItem("Pokeball") or useItem("Great Ball") or useItem("Ultra Ball") then return true end end

	--fighting
	local isTeamUsable = getTeamSize() == 1 --if it's our starter, it has to atk
		or getUsablePokemonCount() > 1		--otherwise we atk, as long as we have 2 usable pkm
	if isTeamUsable then
		--level low leveled pkm | switching
		local opponentLevel = getOpponentLevel()
		local myPokemonLvl  = getPokemonLevel(getActivePokemonNumber())
		if opponentLevel >= myPokemonLvl
			and self.canSwitch
		then
			local requestedId, requestedLevel = game.getMaxLevelUsablePokemon()
			if requestedLevel > myPokemonLvl
				and requestedId ~= nil
			then return sendPokemon(requestedId) end
		end

		--actual battle
		if 	attack() 									--atk
			or self.canSwitch and sendUsablePokemon()	--switch in battle ready pkm if able
			or self.canRun and run()					--run if able
			or self.canSwitch and sendAnyPokemon()		--switch in any alive pkm if able
			or game.useAnyMove()						--use none damaging moves, to progress battle round
		then return sys.debug("fighting team", "battle action performed")
		else return sys.error("quest.battle", "no battle action for a fighting team") end
	end

	-- running
	if 	self.canRun and run()           			--1. we try to run
		or attack()                                 --2. we try to attack
		or self.canSwitch and sendUsablePokemon()  	--3. we try to switch pokemon that has pp
		or self.canSwitch and sendAnyPokemon()     	--4. we try to switch to any pokemon alive
		or game.useAnyMove()                     	--5. we try to use non-damaging attack
		--or BattleManager.useAnyAction()             --6. we try to use garbage items
	then return end sys.debug("running team", "battle action performed")
	sys.error("quest.battle", "no battle action for a running team")

end

function Quest:dialog(message)
	if self.dialogs == nil then
		return false
	end
	for _, dialog in pairs(self.dialogs) do
		if dialog:messageMatch(message) then
			dialog.state = true
			return true
		end
	end
	return false
end

function Quest:battleMessage(message)
	--reset after successful round progression
	if sys.stringContains(message, "Attacks") then
		self.canRun = true
		self.canSwitch = true

	--reset after ended fight | feinting
	elseif sys.stringContains(message, "black out") then
		self.canRun = true
		self.canSwitch = true

		--feinting
		if self.level < 100
			and self:isTrainingOver()
		then
			self.level = math.max(team:getTeamLevel(), self.level) + 1
			self:startTraining()
			log("Increasing " .. self.name .. " quest level to " .. self.level .. ". Training time!")
		end

	--reset after ended fight | win
	elseif sys.stringContains(message, "won the battle") then
		self.canRun = true
		self.canSwitch = true
		
	--restrain running
	elseif sys.stringContains(message, "$CantRun")				--in case resource folder was missing
		or sys.stringContains(message, "You can not run away!")
	then
		self.canRun = false

	--restrain switching
	elseif sys.stringContains(message, "$NoSwitch")
		or sys.stringContains(message, "You can not switch this Pokemon!")
	then
		self.canSwitch = false

	--force caught the specified pokemon on quest 1time
	elseif self.pokemon ~= nil
		and self.forceCaught ~= nil
		and sys.stringContains(message, "caught")
		and sys.stringContains(message, self.pokemon)
	then
		log("Selected Pokemon: " .. self.pokemon .. " is Caught")
		self.forceCaught = true
	end
end

function Quest:systemMessage(message)
	return false
end

local hmMoves = {
	"cut",
	"surf",
	"flash"
}

function Quest:chooseForgetMove(moveName, pokemonIndex) -- Calc the WrostAbility ((Power x PP)*(Accuract/100))
	local ForgetMoveName
	local ForgetMoveTP = 9999
	for moveId=1, 4, 1 do
		local MoveName = getPokemonMoveName(pokemonIndex, moveId)
		if MoveName == nil or MoveName == "cut" or MoveName == "surf" or MoveName == "rock smash" or MoveName == "dive" or (MoveName == "sleep powder" and not hasItem("Plain Badge")) then
		else
		local CalcMoveTP = math.modf((getPokemonMaxPowerPoints(pokemonIndex,moveId) * getPokemonMovePower(pokemonIndex,moveId))*(math.abs(getPokemonMoveAccuracy(pokemonIndex,moveId)) / 100))
			if CalcMoveTP < ForgetMoveTP then
				ForgetMoveTP = CalcMoveTP
				ForgetMoveName = MoveName
			end
		end
	end
	log("[Learning Move: " .. moveName .. "  -->  Forget Move: " .. ForgetMoveName .. "]")
	return ForgetMoveName
end

function Quest:learningMove(moveName, pokemonIndex)
	return forgetMove(self:chooseForgetMove(moveName, pokemonIndex))
end

return Quest
