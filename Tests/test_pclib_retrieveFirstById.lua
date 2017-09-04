local sys    		= require "Libs/syslib"
local game   		= require "Libs/gamelib"
local pc    		= require "Libs/pclib"
local team	 		= require "Libs/teamlib"
local SurfTarget	= require "Data/surfTargets"
local PkmName		= require "Data/pokemonNames"
local Quest  		= require "Quests/Quest"
local Dialog 		= require "Quests/Dialog"

local preferredSurferId = 53--Snorlax: 38, Psyduck: 54,  Paras: 46, Persian: 53
debug = true

function onPathAction()
    local swapId = nil
    --local swapId = team.getLowestLvlPkm()
    sys.debug("PC | lowestLVlpkm: "..team.getLowestLvlPkm())

    pkmIdSurfSwap, boxIdSurfSwap, swapId  = pc.retrieveFirstById(preferredSurferId, swapId)	--testing for that surf pkm on pc
    sys.debug("----PC vars:----", true)
    sys.debug("PC | pkmIdSurfSwap " .. tostring(pkmIdSurfSwap))
    sys.debug("PC | boxIdSurfSwap " .. tostring(boxIdSurfSwap))

    -- no solution
    if not pkmIdSurfSwap  -- boxItem is no solution
    then
        -- quick fix until pathfinder is added, then catching one wouldn't be much of a hassle
        return sys.error("fn", "No pokemon in your team or on your computer has the ability to surf. Can't progress Quest")

    --still searching | don't do other actions | return statement needed
    elseif not boxIdSurfSwap then return sys.debug("Starting PC or Switching Boxes") end

    --solution found
    --preparing swap target | taking held item, if it has one


    local msg = "LOG: Found Surfer on BOX: " .. boxIdSurfSwap .."  Slot: ".. pkmIdSurfSwap
    if swapId then msg = msg.." | Swapping with pokemon in team N: " .. swapId
    else            msg = msg.." | Added to team." end

    log(msg)
    fatal("Finished :)")
end