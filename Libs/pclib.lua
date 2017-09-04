-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.

local pc = {}

local team = require("Libs/teamlib")

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


function pc.retrieveFirstWithMove(pkmName, move, swapId)
    local region, lvl, lvlComparer, id = nil, nil, nil, nil --added for readability
    return pc._retrieveFirst(swapId, id, pkmName, move, region, lvl, lvlComparer)
end

function pc.retrieveFirstWithMoveFrom(pkmName, move, region, swapId)
    local lvl, lvlComparer, id = nil, nil, nil --added for readability
    return pc._retrieveFirst(swapId, id, pkmName, move, region, lvl, lvlComparer)
end

function pc.retrieveFirstBelowLvl(pkmName, lvl, swapId)
    local move, region, id = nil, nil, nil --added for readability
    return pc._retrieveFirst(swapId, id, pkmName, move, region, lvl, pc._smaller)
end

function pc.retrieveFirst(pkmName, swapId)
    local move, lvl, region, lvlComparer, id = nil, nil, nil, nil, nil --added for readability
    return pc._retrieveFirst(swapId, id, pkmName, move, region, lvl, lvlComparer)
end

function pc.retrieveFirstById(id, swapId)
    local move, lvl, region, lvlComparer, pkmName = nil, nil, nil, nil, nil --added for readability
    return pc._retrieveFirst(swapId, id, pkmName, move, region, lvl, lvlComparer)
end

--compare functions
function pc._smaller(a, b) return a < b end

--function pc._highest not possible with _retrieve first - another implementation neededs


--return action, nil while doing actions
--return int, int, in  an object when finished

--- @summary : Retrieves a pkm from the box, that matches given parameters. Handles held items as well.
--- params:
--- @param swapId: 1-6 | pkm team id: which indicates the swap target for a match | default: lowest leveled pkm
--- @type : integer | nil
--- @param id: 1-775 | pkm id: searches for the first pkm with given id | nil, not checking
--- @type : integer | nil
--- @param pkmName: pkm name: searches for the first pkm with given name | nil, not checking
--- @type : string | nil
--- @param move: move name: searches for the first pkm with given move | nil, not checking
--- @type : string | nil
--- @param region: 1-4 | region id: searches for the first pkm from that region | nil, not checking
--- @type : string | nil
--- following can only be used together:
--- @param lvl: 1-100 | searches for the first pkm with a level lvlComparer accepts | nil, if not checking
--- @type : integer | nil
--- @param lvlComparer: compares given lvl and pokemons lvl, returns: true for a match, false otherwise | nil, if not checking
--- @type : function | nil
--- return pkmBoxId, boxId, swapId
--- @return :
--- @type : integer, integer, integer
function pc._retrieveFirst(swapId, id, pkmName, move, region, lvl, lvlComparer)
    --start pc
    if not isPCOpen() then return usePC() end
    --wait for loaded pcBox
    if not isCurrentPCBoxRefreshed() then return log("LOG | Refresing PC Box.") end

    --start with last box | to get potentially highest level matching pkm
    local pcBoxCount = getPCBoxCount()
    boxId = boxId or pcBoxCount --needs global context | don't add local
    log("boxId: "..boxId)
    log("pcBoxCount: "..pcBoxCount)


    --if it's the last page clean up
    if boxId < 1 then
        boxId = pcBoxCount

        log("new boxId: "..boxId)
        --no solution found
        return nil
    end

    if boxId == getCurrentPCBoxId() then
        --verify active pcbox has elements
        log("---------boxId: " .. boxId)
        log("---------boxSize: " .. getCurrentPCBoxSize())

        --local boxSize = getCurrentPCBoxSize()
        --if boxSize == 0 then return end

        --check each box item
        log("boxId: " .. boxId)
        for pkmBoxId = 1, getCurrentPCBoxSize() do
            local boxPkmName = getPokemonNameFromPC(boxId, pkmBoxId)
            local pkmRegion = getPokemonRegionFromPC(boxId, pkmBoxId)
            local pkmId = getPokemonIdFromPC(boxId, pkmBoxId)
            local pkmLvl = getPokemonLevelFromPC(boxId, pkmBoxId)


            local checkId = not id or id == pkmId
            log("checked: "..boxId..", "..pkmBoxId..":\t"..pkmId.."\t"..id..":\t"..tostring(checkId))


            --iterating moves, only one iteration if not no move preference given
            for moveId = 1, 4 do
                local pkmMove = getPokemonMoveNameFromPC(boxId, pkmBoxId, moveId)

                --check for match found
                if (not pkmName or boxPkmName == pkmName) --correct name, if provided
                    and (not id or id == pkmId) --correct id, if provided
                    and (not region or pkmRegion == region) --correct region, if provided
                    and (not move or pkmMove == move) --correct move, if provided
                    and (not lvl or lvlComparer(pkmLvl, lvl)) --correct lvl, if provided

                then
                    log("----------------------a match")
                    --preparing swap target
                    swapId = swapId or team.getLowestLvlPkm()

                    -- taking held item, if it has one
                    local heldItem = getPokemonHeldItem(swapId)
                    if heldItem then
                        --leftovers had to be disabled, so they wouldn't interfere with taking them away
                        leftovers_disabled = true
                        return takeItemFromPokemon(swapId)
                    end

                    -- retrieve the pkm
                    local isSwap = getTeamSize() >= 6 --shorter if statemen: better readabiliy
                    if isSwap then swapPokemonFromPC(boxId, pkmBoxId, swapId)
                    else withdrawPokemonFromPC(boxId, pkmBoxId) end

                    --reset for future pc calls
                    leftovers_disabled = nil
                    boxId = pcBoxCount
                    return pkmBoxId, boxId, swapId
                end
            end
        end
        --update new
        boxId = boxId - 1
    end
    return openPCBox(boxId)
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