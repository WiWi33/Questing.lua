-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.

local gen = require("Libs/genlib")
local sys = require("Libs/syslib")
local team = require("Libs/teamlib")
local Pokemon = require("Classes/Pokemon")
local Set = require("Classes/Set")

local pc = {}

function pc.isValidIndex(boxIndex, pokemonIndex)
    if getCurrentPCBoxId() == boxIndex and pokemonIndex <= getCurrentBoxSize() then
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


--some first interface methods | collected by the current questing needs + some obvious ones
function pc.retrieveFirstWithMovesFromRegions(moves, regions, swapId)
    return pc._retrieveFirst{swapId = swapId, moves=moves, region = regions}
end

function pc.retrieveFirstFromNamesBelowLvl(pkmNames, level, swapId)
    return pc._retrieveFirst{swapId = swapId, name = pkmNames, level = level, lvlComparer = gen.smaller}
end

function pc.retrieveFirstFromNamesAboveLvl(pkmNames, level, swapId)
    return pc._retrieveFirst{swapId = swapId, name = pkmNames, level = level, lvlComparer = gen.higher}
end

function pc.retrieveFirstFromNames(pkmNames, swapId)
    return pc._retrieveFirst{swapId = swapId, name = pkmNames}
end

function pc.retrieveFirstFromIds(ids, swapId)
    return pc._retrieveFirst{swapId = swapId, id = ids}
end



--- @summary :  Retrieves all pkm from the PC. Starts with latest page to potentially add higher level pkm prior
--- to lower leveled ones
function pc._collect()
    --start pc
    if not isPCOpen() then return usePC() end

    --refresing
    if not isCurrentPCBoxRefreshed() then return sys.debug("refreshed") end

    --start with last box | to get potentially highest level matching pkm
    --init values
    pc.boxId = pc.boxId or getPCBoxCount()  --appended to pc, to avoid namespace interference
    pc.pkmListCol = pc.pkmListCol or {} -- ... same ...

    --read table if desired is open
    if pc.boxId == getCurrentPCBoxId() then

        --check each box item
        for slotId = 1, getCurrentPCBoxSize() do

            --read data from slot and add it
            local pkm = Pokemon:newFromPC(pc.boxId, slotId)
            table.insert(pc.pkmListCol, { pkm, pc.boxId, slotId })
        end

        --indicate next page to be loaded
        pc.boxId = pc.boxId - 1
    end

    --if we are on last page clean up
    if pc.boxId < 1 then
        --temp variable
        local returnList = pc.pkmListCol

        --reset values
        pc.boxId = getPCBoxCount()
        pc.pkmListCol = nil

        --return collection
        return returnList
    end

    --open pcbox if current is not open | or end of current is reached
    return openPCBox(pc.boxId)
end



--TODO: update luadoc to fit the new "named arguments" implementation
--- @summary : Retrieves a pkm from the box, that matches given parameters. Handles held items as well.
--- params:
--- @param swapId: 1-6 | pkm team ids: which indicates the swap target for a match | default: lowest leveled pkm
--- @type : integer | nil
--- @param ids: 1-775 | pkm ids: searches for all or first pkm with given ids | nil, not checking
--- @type : integer list | nil
--- @param pkmNames: pkm name: searches for all or the first pkm with given name | nil, not checking
--- @type : string list | nil
--- @param moves: moves name: searches for all or the first pkm with given moves | nil, not checking
--- @type : string list | nil
--- @param regions: 1-4 | regions ids: searches for all or the first pkm from that regions | nil, not checking
--- @type : string list | nil
--- following can only be used together:
--- @param level: 1-100 | searches for the first pkm with a level lvlComparer accepts | nil, if not checking
--- @type : integer | nil
--- @param lvlComparer: compares given level and pokemons level, returns: true for a match, false otherwise | nil, if not checking
--- @type : function | nil
--- return slotId, boxId, swapId
--- @return :
--- @type : list {dict} integer, integer, integer
function pc._retrieveFirst(args)
    --preparing swap target
    --assert(args.swapId, "pc._retrieveFirst needs a swapId parameter")
    local swapId = args.swapId or team.getLowestLvlPkm()
    args.swapId = nil

    -- start search if we didn't do it before | this occurs when switching pcBox as you have to terminate,
    -- since you couldn't perform a swap in the same cycle or it would create a "two actions in one frame
    -- exception"
    if not pc.firstMatch then

        --leftovers had to be disabled, so they wouldn't interfere with taking them away
        leftovers_disabled = true

        -- taking held item, if it has one
        local heldItem = getPokemonHeldItem(swapId)
        if heldItem then
            takeItemFromPokemon(swapId)
            return pc.result.WORKING
        end

        pc.pkmList = pc._collect()
    end

    --has solution
    if pc.firstMatch or type(pc.pkmList) == "table" then
        --append pc search result
        args.pkmList = pc.pkmList
        pc.firstMatch = pc.firstMatch or pc._getFirstMatch(args) --appended to pc context, to prevent naming duplicates in user scripts

        --no result, if no pkm matches
        if not pc.firstMatch then return pc.result.NO_RESULT end

        --else initate transfer process
        local pkm, boxId, slotId = pc._split(pc.firstMatch)

        -- open correct box for transfer
        if boxId ~= getCurrentPCBoxId() then
            openPCBox(boxId)
            return pc.result.WORKING
        end


        --retrieve match
        local isSwap = getTeamSize() >= 6
        if isSwap then  swapPokemonFromPC(boxId, slotId, swapId)
        else            withdrawPokemonFromPC(boxId, slotId) end

        --cleanup
        leftovers_disabled = false  --active leftovers again
        pc.firstMatch = nil         --clear match result, for next query

        return pkm, boxId, slotId, swapId

    --no solution
    elseif not pc.pkmList then
        return pc.result.NO_RESULT

    --result is a function: state working
    elseif pc.pkmList == true then
        return pc.result.WORKING

    else sys.debug("pc._retrieveFirst: unsupported state. pc._collect "..
        "has neither true, false or table as return value.")
    end
end

function pc._split(item)
    local pkm, boxId, slotId = item[1], item[2], item[3]
    return pkm, boxId, slotId
end

--- @param : itemList
-- usage example: rename{old="temp.lua", new="temp1.lua"}
function pc._getFirstMatch(args)
    sys.debug("FirstMatchArgs: "..gen.size(args))
    return gen.first(pc._getMatches(args))
end

function pc._getMatches(args)
    --retrieve itemList and remove, for the iteration of arg
    assert(args.pkmList, "pc._getMatches needs a pkmList from pc._collect()")
    local pkmList = args.pkmList
    args.pkmList = nil

    --make sure that if level given, lvlComparer exists
    assert(not args.level or args.level and args.lvlComparer, "pc._getMatches" ..
        "don't accepts argument level unless lvlComparer is given as well")
    local lvlComparer = args.lvlComparer
    args.lvlComparer = nil


    --pokemon class vars
    local posArgs = Set:new {
        "ev", "iv", "moves", "name", "nature", "ability",
        "happiness", "region", "trainer", "gender", "totalXp",
        "remainingXP", "uniqueId", "id", "isShiny", "item",
        "level", "totalHP", "percentHP", "currentHP"
    }

    --iterating all pokemon
    local matches = {}
    for _, item in pairs(pkmList) do
        local pkm = item[1]

        --iterate arguments
        local match = true
        for testParam, testValue in pairs(args) do
            assert(posArgs:contains(testParam), "pc._getMatches: unsupported compare attribute: "..tostring(testParam))

            local testValueSet = Set:new(testValue)
            local pkmValue = pkm[testParam]
            local checkResult = false

            --moves | exception handling
            if testParam == "moves" then
                local moveList = pc._transform(pkm.moves, pc._getProperty, "name")

                --meaining: size of intersection of moves and pkmMoves has to at least 1
                -- -- = one item is contained in both lists
                checkResult = Set.intersection(testValueSet, moveList)

            --level | exception handling
            elseif testParam == "level" and lvlComparer then
                assert(testValue ~= integer, "pc._getMatches expects an integer as level if no comparison function \"lvlComparer\" is given.")
                checkResult = lvlComparer(testValue, pkmValue)

            --basic items | table testValue, meaning: testValue is in that table
            elseif type(testValue) == "table" then
                checkResult = testValueSet:contains(pkmValue)

            --basic items | check same value
            else checkResult = testValue == pkmValue end

            --binary and, all arguments have to match
            match = match and checkResult
        end


        if match then table.insert(matches, item) end
    end

    return matches
end

--transform
function pc._transform(t, fn, ...)
    local transTbl = {}
    for key, value in pairs(t) do
        --key param: unnecessary, if key is integer | necessary, for every other tpye
        --sys.debug(key .." | "..value .." |" .. fn(value)) --not possible with reltive pathing
        table.insert(transTbl, value, fn(value, ...))
    end
    return transTbl
end


function pc._wrap(obj)
    if not obj then return
    elseif type(obj) ~= table then return { obj }
    end
    return obj
end


function pc._getProperty(o, prop) if o[prop] then return o[prop] end end

pc.result = {
    EXCEPTION = 0, --needed? just call fatal
    WORKING = 1,
    NO_RESULT = 2,
    FINISHED = 3
}


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
