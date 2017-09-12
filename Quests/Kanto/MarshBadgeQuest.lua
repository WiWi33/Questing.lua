-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @Rympex


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name		  = 'Marsh Badge'
local description = 'Get Badge + Dojo Pokemon'
local level = 55

local dialogs = {
  dojoSaffronDone = Dialog:new({
    "tomodachi"
  })
}

local MarshBadgeQuest = Quest:new()

function MarshBadgeQuest:new()
  --setting starter, if no none defined
  if not KANTO_DOJO_POKEMON_ID then KANTO_DOJO_POKEMON_ID = math.random(1,2) end
  local o = Quest.new(MarshBadgeQuest, name, description, level, dialogs)
  o.dojoState = false
  return o
end

function MarshBadgeQuest:isDoable()
  if self:hasMap() then
    return true
  end
  return false
end

function MarshBadgeQuest:isDone()
  if hasItem("Marsh Badge") and getMapName() == "Lavender Town"
      or getMapName() == "Silph Co 1F"
      or getMapName() == "Route 5" then
    return true
  else
    return false
  end
end


function MarshBadgeQuest:Route8()
  if self:needPokecenter() or self:isTrainingOver() then
    --if we won gym fight, self:isTrainingOver() should be true. So another test against badge has
    --to be made, to fix looping between Rout8StopHouse and Route8 itself
    if hasItem("Marsh Badge")then return moveToMap("Lavender Town")
      
    else return moveToMap("Route 8 Stop House") end

  else return moveToGrass() end
end


function MarshBadgeQuest:Route8StopHouse()
  if not hasItem("Marsh Badge")
      and (self:needPokecenter() or self:isTrainingOver())

  --updated link name
  then return moveToMap("Link") end

  return moveToMap("Route 8")
end

function MarshBadgeQuest:isBuyingBike()
  sys.debug("BUY_BIKE: ", BUY_BIKE)
  sys.debug("Voucer: ", hasItem("Bike Voucher"))
  sys.debug("money: ", getMoney() >=60000)
  return BUY_BIKE and hasItem("Bike Voucher") and getMoney() >=60000
end

function MarshBadgeQuest:Route5StopHouse()
  --when bying a bike move towards Cerulean City
  if self:isBuyingBike() then return moveToMap("Route 5") end
  --coming back
  return moveToMap("Link")
end

function MarshBadgeQuest:SaffronCity()
  if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Saffron" then
    return moveToMap("Pokecenter Saffron")
  elseif self:isBuyingBike() then
    return moveToMap("Route 5 Stop House")
  elseif not self:isTrainingOver() then
    return moveToMap("Route 8 Stop House")
  elseif isNpcOnCell(49,14) then --Rocket on SaffronGym Entrance
    return moveToMap("Silph Co 1F")
  elseif not dialogs.dojoSaffronDone.state and not self.dojoState then --Need Check dojo
    return moveToCell(42,13) -- Fixed no LINK name
  elseif not hasItem("Marsh Badge") then -- Need beat Gym
    return moveToMap("Saffron Gym")
  else
    return moveToMap("Route 8 Stop House")
  end
end

function MarshBadgeQuest:PokecenterSaffron()
  return self:pokecenter("Saffron City")
end

function MarshBadgeQuest:SaffronDojo()
  if isNpcOnCell(7,5) then
    if dialogs.dojoSaffronDone.state then
      if isNpcOnCell(3,4) and isNpcOnCell(10,4) then
        if KANTO_DOJO_POKEMON_ID == 1 then -- Hitmonchan
          return talkToNpcOnCell(3, 4)
        else -- Hitmonlee
          return talkToNpcOnCell(10,4)
        end
      else
        return moveToMap("Saffron City")
      end
    else
      return talkToNpcOnCell(7,5)
    end
  else
    self.dojoState = true
    return moveToMap("Saffron City")
  end
end


function MarshBadgeQuest:SaffronGym()
  if not hasItem("Marsh Badge") then
    if game.inRectangle(9,16,15,22) then
      return moveToCell(15,17)
    elseif game.inRectangle(15,17,23,20) then
      return moveToCell(18,20)
    elseif game.inRectangle(1,16,7,17) then
      return moveToCell(2,17)
    elseif game.inRectangle(17,14,23,6) then
      return moveToCell(18,6)
    elseif game.inRectangle(1,2,3,6) then
      return moveToCell(2,6)
    elseif game.inRectangle(9,9,15,13) then
      return talkToNpcOnCell(12,10)
    else
      error("MarshBadgeQuest:SaffronGym(): [" .. getPlayerX() .. "," .. getPlayerY() .. "] is not a known position")
    end
  else
    if game.inRectangle(9,9,15,13) then
      return moveToCell(10,13)
    elseif game.inRectangle(9,16,15,22) then
      return moveToMap("Saffron City")
    else
      error("MarshBadgeQuest:SaffronGym(): [" .. getPlayerX() .. "," .. getPlayerY() .. "] is not a known position")
    end
  end
end

return MarshBadgeQuest
