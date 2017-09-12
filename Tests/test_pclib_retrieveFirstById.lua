local sys    		= require "Libs/syslib"
local game   		= require "Libs/gamelib"
local pc    		= require "Libs/pclib"
local team	 		= require "Libs/teamlib"
local SurfTarget	= require "Data/surfTargets"
local PkmName		= require "Data/pokemonNames"
local Quest  		= require "Quests/Quest"
local Dialog 		= require "Quests/Dialog"

local preferredSurferIds = {53}  --Snorlax: 38, Psyduck: 54,  Paras: 46, Persian: 53
debug = true

function onPathAction()
    local swapId = nil
    --local swapId = team.getLowestLvlPkm()
    sys.debug("PC | lowestLVlpkm: "..team.getLowestLvlPkm())

    local result, boxId, swapId  = pc.retrieveFirstFromIds(preferredSurferIds, swapId)	--testing for that surf pkm on pc
    sys.debug("----PC vars:----", true)
    sys.debug("PC | result " .. tostring(result))
    sys.debug("PC | boxId " .. tostring(boxId))

    -- boxItem is no solution
    if result == pc.result.NO_RESULT then
        -- quick fix until pathfinder is added, then catching one wouldn't be much of a hassle
        return sys.error("fn", "No pokemon in your team or on your computer has the ability to surf. Can't progress Quest")

    --still searching | don't do other actions | return statement needed
    elseif result == pc.result.STILL_WORKING then return sys.debug("Starting PC or Switching Boxes") end

    --solution found
    --preparing swap target | taking held item, if it has one
    local slotId = result

    local msg = "LOG: Found Surfer on BOX: " .. boxId .."  Slot: ".. slotId
    if swapId then msg = msg.." | Swapping with pokemon in team N: " .. swapId
    else            msg = msg.." | Added to team." end

    log(msg)
    fatal("Finished :)")
end