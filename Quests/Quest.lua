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
	local money         = getMoney()
	if money >= 200 and pokeballCount < 50 then
		if not isShopOpen() then
			return talkToNpcOnCell(3,5)
		else
			local pokeballToBuy = 50 - pokeballCount
			local maximumBuyablePokeballs = money / 200
			if maximumBuyablePokeballs < pokeballToBuy then
				pokeballToBuy = maximumBuyablePokeballs
			end
			return buyItem("Pokeball", pokeballToBuy)
		end
	else
		return moveToMap(exitMapName)
	end
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
	if leftovers_disabled then return end
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
	if getTeamSize() == 1 and  getPokemonHealthPercent(1) <= 50 then
		return true

	-- else we would spend more time evolving the higher level ones
	elseif not self:isTrainingOver() then
		if getUsablePokemonCount() == 1 or not team.getAlivePkmToLvl(self.level) then return true end

	elseif not game.isTeamFullyHealed() and  self.healPokemonOnceTrainingIsOver then
		return true

	else
		-- the team is fully healed and training over
		self.healPokemonOnceTrainingIsOver = false
	end
	return false
end

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
	sys.debug("Sort Values:", true)
	sys.debug("starter: "..starter)
	sys.debug("lowestAlivePkmToLvl: "..tostring(lowestAlivePkmToLvl))
	if lowestAlivePkmToLvl and 			--if one exists, skips if nothing found
		starter ~= lowestAlivePkmToLvl	--skips if found target the starter already
	then
		sys.debug("getting swapped: "..tostring(lowestAlivePkmToLvl))
		return swapPokemon(lowestAlivePkmToLvl, starter)
	end

	--setting highest level pkm, as last defense wall
	local highestAlivePkm = team.getHighestPkmAlive()
	local lastPkm = team.getLastPkmAlive()
	sys.debug("lastPkm: "..lastPkm)
	sys.debug("highestAlivePkm: "..tostring(highestAlivePkm))
	if highestAlivePkm ~= lastPkm then
		return swapPokemon(highestAlivePkm, lastPkm)
	end
end


function Quest:path()
	if self.inBattle then
		self.inBattle = false
		self:battleEnd()
	end
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

function Quest:battleBegin()
	self.canRun = true
	self.canSwitch = true
end

function Quest:battleEnd()
	self.canRun = true
	self.canSwitch = true
end

-- I'll need a TeamManager class very soon
local blackListTargets = { --it will kill this targets instead catch
	"Metapod",
	"Kakuna",
	"Doduo",
	"Hoothoot",
	"Zigzagoon"
}

function Quest:wildBattle()
	sys.debug("Battle Values:", true)

	sys.debug("active pkm: "..getActivePokemonNumber())
	-- catching
	local isEventPkm = getOpponentForm() ~= 0
	if isOpponentShiny() or isEventPkm 																--catch special pkm
		or (not isAlreadyCaught() and not sys.tableHasValue(blackListTargets, getOpponentName())) 	--catch not seen pkm
		or (self.pokemon and getOpponentName() == self.pokemon		--catch quest related pkm
		and self.forceCaught ~= nil and self.forceCaught == false)	--try caught only if never caught in this quest
	then
		if useItem("Pokeball") or useItem("Great Ball") or useItem("Ultra Ball") then return true end
	end

	sys.debug("canSwitch: "..tostring(self.canSwitch))
	sys.debug("canRun: "..tostring(self.canRun))

	-- team needs no healing
	if getTeamSize() == 1 or getUsablePokemonCount() > 1 then
		sys.debug("Team needs no healing.")

		--level low leveled pkm
		local opponentLevel = getOpponentLevel()
		local myPokemonLvl  = getPokemonLevel(getActivePokemonNumber())
		if self.canSwitch and opponentLevel >= myPokemonLvl then
			local requestedId, requestedLevel = game.getMaxLevelUsablePokemon()
			if requestedId ~= nil and requestedLevel > myPokemonLvl then
				sys.debug("battle swap due to level")
				return sendPokemon(requestedId)
			end
		end

		if attack() 									--atk
			or self.canSwitch and sendUsablePokemon()	--switch in battle ready pkm if able
			or self.canRun and run()					--run if able
			or self.canSwitch and sendAnyPokemon()		--switch in any alive pkm if able
			or game.useAnyMove()						--use none damaging moves, to progress battle round
		then return sys.debug("an was action performed for battle headed teams")
		else return sys.error("quest.wildBattle", "no battle progression found for a battle headed team") end
	end

	sys.debug("Team needs healing.")

	-- team needs healing
	if self.canRun and run() 						--run if able
		or self.canSwitch and sendUsablePokemon() 	--switch in battle ready pkm if able
		or attack() 								--atk
		or self.canSwitch and sendAnyPokemon()		--switch in any alive pkm if able
		or game.useAnyMove()						--use none damaging moves, to progress battle round
	then return end sys.debug("an was action performed for pokecenter headed teams")
	sys.error("quest.wildBattle", "no battle progression found for a pocecenter headed team")
end

--could probably be left out | throwing pokeballs at trainer pkms might be an issue. run just returns false
function Quest:trainerBattle()
	-- bug: if last pokemons have only damaging but type ineffective
	-- attacks, then we cannot use the non damaging ones to continue.
	if not self.canRun then -- trying to switch while a pokemon is squeezed end up in an infinity loop
		return attack() or game.useAnyMove()
	end
	return attack() or sendUsablePokemon() or sendAnyPokemon() -- or game.useAnyMove()
end

function Quest:battle()
	if not self.inBattle then
		self.inBattle = true
		self:battleBegin()
	end
	if isWildBattle() then
		return self:wildBattle()
	else
		return self:trainerBattle()
	end
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
	if sys.stringContains(message, "Attacks") then
		--reset after successful round progression
		self.canRun = true
		self.canSwitch = true
		sys.debug("BattleMessage", true)
		sys.debug("canRun = true")
		sys.debug("canSwitch = true")
		return true

	elseif sys.stringContains(message, "$CantRun") then
		sys.debug("BattleMessage", true)
		sys.debug("canRun = false")
		self.canRun = false
		return true

	elseif sys.stringContains(message, "$NoSwitch") then
		sys.debug("BattleMessage", true)
		sys.debug("canSwitch = false")
		self.canSwitch = false
		return true

	elseif self.pokemon ~= nil and self.forceCaught ~= nil then
		if sys.stringContains(message, "caught") and sys.stringContains(message, self.pokemon) then --Force caught the specified pokemon on quest 1time
			log("Selected Pokemon: " .. self.pokemon .. " is Caught")
			self.forceCaught = true
			return true
		end

	elseif sys.stringContains(message, "black out") and self.level < 100 and self:isTrainingOver() then
		self.level = math.max(team:getTeamLevel(), self.level) + 1
		self:startTraining()
		log("Increasing " .. self.name .. " quest level to " .. self.level .. ". Training time!")
		return true

	end
	return false
end

function Quest:systemMessage(message)
	sys.debug("systemMessage: "..message, true)
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
