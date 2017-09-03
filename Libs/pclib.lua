-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.

local pc = {}

local sys = require("Libs/syslib")

function pc.isValidIndex(boxIndex, pokemonIndex)
	if getCurrentBoxId() == boxIndex and pokemonIndex <= getCurrentBoxSize() then
		return true
	end
	return false
end

function pc.isReady()
	if isPCOpen() and isCurrentPCBoxRefreshed() then
			return true
	end
	return false
end

function pc.use()
	if isPCOpen() then
		if isCurrentPCBoxRefreshed() then
			return
		else
			-- we wait
			return
		end
	else
		if not usePC() then
			sys.error("libpc.use", "Tried to use the PC in a zone without PC")
		end
	end
end

-- this function needs to be called multiple time
-- returns true once the swap is done
function pc.swap(boxIndex, boxPokemonIndex, teamIndex)
	if not pc.isReady() then
		pc.use()
		return false
	else
		if not swapPokemonFromPC(boxIndex, boxPokemonIndex, teamIndex) then
			return sys.error("libpc.swap", "Failed to swap")
		else
			return true
		end
	end
	return false
end

-- this function needs to be called multiple time
-- returns true once deposit is done
function pc.deposit(teamIndex)
	if not pc.isReady() then
		pc.use()
		return false
	else
		if not depositPokemonToPC(__teamIndex) then
			return sys.error("libpc.deposit", "Failed to deposit")
		end
		return true
	end
	return false
end

-- this function needs to be called multiple time
-- returns true once withdraw is done
function pc.withdraw(boxIndex, boxPokemonIndex)
	if not pc.isReady() then
		pc.use()
		return false
	else
		if getTeamSize() == 6 then
			return sys.error("libpc.withdraw", "Team full. Could not withdraw the pokemon "
				.. getPokemonNameFromPC(boxIndex, boxPokemonIndex))
		end
		if not withdrawPokemonFromPC(boxIndex, boxPokemonIndex, teamIndex) then
			return sys.error("libpc.deposit", "Failed to deposit")
		end
		return true
	end
	return false
end


function pc.retrieveFirstWithMove(pkmName, move)
	local region, lvl, comparer = nil, nil, nil --added for readability
	return pc._retrieveFirst(pkmName, move, region, lvl, comparer)
end

function pc.retrieveFirstWithMoveFrom(pkmName, move, region)
	local lvl, comparer = nil, nil --added for readability
	return pc._retrieveFirst(pkmName, move, region, lvl, comparer)
end

function pc.retrieveFirstBelowLvl(pkmName, lvl)
	local move, region = nil, nil --added for readability
	return pc._retrieveFirst(pkmName, move, region, lvl, pc._smaller)
end

function pc.retrieveFirst(pkmName)
	local move, lvl, region, comparer = nil, nil, nil, nil --added for readability
	return pc._retrieveFirst(pkmName, move, region, lvl, comparer)
end

--compare functions
function pc._smaller(a,b) return a < b end


--return action, nil while doing actions
--return int, int an object when finished
function pc._retrieveFirst(pkmName, move, region, lvl, comparer)
	sys.todo("Remove obsolete other methods, since _retrieveFirst should cover all", "pclib._retrieveFirst")
	--start pc
	if not isPCOpen() or not isCurrentPCBoxRefreshed() then return usePC() end

	--verify active pcbox has elements
	local no_match = "No match found"
	if getCurrentPCBoxSize() == 0 then  return no_match end

	--check each box item
	local boxId = getCurrentPCBoxId()
	for pkmId = 1, getCurrentPCBoxSize() do

		local boxPkmName = getPokemonNameFromPC(boxId, pkmId)
		local pkmRegion = getPokemonRegionFromPC(boxId, pkmId)

		--iterating moves, only one iteration if not no move preference given
		for moveId = 1, 4 do
			local pkmMove = getPokemonMoveNameFromPC(boxId, pkmId, moveId)

			if boxPkmName == pkmName					--correct name
				and (not region or pkmRegion == region) --correct region if provided
				and (not move or pkmMove == move)
			then return pkmId, boxId	end
		end
	end
	return openPCBox(boxId + 1)
end

function pc.gatherDatas(sortingFunction)
	
end

-- sortingFunction must take 2 pokemons  as parameters (id + box) and return a bool
-- i.e.: 
--[[
	function sortByUniqueId(boxIndexA, boxPokemonIndexA, boxIndexB, boxPokemonIndexB)
		if (getPokemonUniqueIdFromPC(boxIndexA, boxPokemonIndexA) >
			getPokemonUniqueIdFromPC(boxIndexB, boxPokemonIndexB)
		then
			return true
		end
		return false
	end
	
	pc.sort(sortByUniqueId)
--]]
function pc.sort(sortingFunction)

end

return pc