---@author: m1l4
---@comment: copied and reduced code from TeamManager class which wasn't finished at the I copyPasted it here,
---so there might be redundancies. Additionally: simplifications of the current code through usage of this module
---are only done sparsly - those will be coming with future updates a litte at a time
---@attention: functions, variables and comments are reffering another project's context. So keep that in mind
---when reading comments :)
-- -------------------------

--comparers - normally it makes no difference if >= is used or not,
-- but when using it in methods it becomes mandator to prevent
--
local function maxLvl(a, b) return getPokemonLevel(b) >= getPokemonLevel(a) end     --greater **equal** is necesarry to avoid swaping same lvled pkm
local function minLvl(a, b) return getPokemonLevel(b) < getPokemonLevel(a) end      --lesser is necesarry to avoid swaping same lvled pkm
--filter
local function first(t) t = t or {} if #t > 0 then return t[1] end end
local function last(t) t = t or {} if #t > 0 then return t[#t] end end



team = {}
--pkm conditions
function team.isPkmAlive(i) return getPokemonHealth(i) > 0 end
function team.isPkmToLvl(i, lvl_cap) return getPokemonLevel(i) < lvl_cap end
function team.isPkmToLvlAlive(i, lvl_cap) return team.isPkmAlive(i) and team.isPkmToLvl(i, lvl_cap) end
function team.isPkmToLvlUsable(i, lvl_cap) return isPokemonUsable(i) and team.isPkmToLvl(i, lvl_cap) end
--pkm properties
function team.hasPkmItem(i, item) return getPokemonHeldItem(i) == item end
function team.hasPkmAbility(i, abilty) return getPokemonAbility(i) == abilty end
function team.hasPkmNature(i, nature) return getPokemonNature(i) == nature end
function team.hasPkmMove(i, move) return hasMove(i, move) end
--generic - at least all pkm properties or even more could be reduced
function team._equal(i, fn, value) return fn(i)==value end
local function first(t) t = t or {} if #t > 0 then return t[1] end end
local function last(t) t = t or {} if #t > 0 then return t[#t] end end


--- @summary : fetches all pkm under given level cap
--- @param level_cap: upper level treshold, 100 by default
--- @type level_cap: integer
--- @return : list of team indexes of all pkm that can be leveled up
--- @type : table (list of integers)
function team.getPkmToLvl(level_cap)
    return team._filter(team.getPkm(), team.isPkmToLvl, level_cap)
end

--- @summary : Searches the lowest leveled pkm under given level_cap
--- @param level_cap: upper level treshold, 100 by default
--- @type level_cap: integer
--- @return : team index, of lowest leveled pkm under level_cap | nil, if none exists
--- @type : integer | nil
function team.getLowestPkmToLvl(level_cap)
    return team._compare(team.getPkmToLvl(level_cap), minLvl)
end

function team.getAlivePkmToLvl(level_cap)
    return team._filter(team.getPkm(), team.isPkmToLvlAlive, level_cap)
end

function team.getLowestAlivePkmToLvl(level_cap)
    return team._compare(team.getAlivePkmToLvl(level_cap), minLvl)
end

--- @summary : Searches the lowest leveled pkm under given level_cap
--- @param level_cap: upper level treshold, 100 by default
--- @type level_cap: integer
--- @return : team index, of lowest leveled pkm under level_cap | nil, if none exists
--- @type : integer | nil
function team.getLowestUsablePkmToLvl(level_cap)
    return team._compare(team.getUsablePkmToLvl(), minLvl)
end

--- @summary : fetches all pkm under given level cap, that are able to battle
--- @param level_cap: upper level treshold, 100 by default
--- @type level_cap: integer
--- @return : list of team indexes of all battle-ready pkm that can be leveled up
--- @type : table (list of integers)
function team.getUsablePkmToLvl(level_cap)
    return team._filter(team.getUsablePkm(), team.isPkmToLvl, level_cap)
end

--- @summary : Searches the lowest leveled pkm under given level_cap
--- @param level_cap: upper level treshold, 100 by default
--- @type level_cap: integer
--- @return : team index, of lowest leveled pkm under level_cap | nil, if none exists
--- @type : integer | nil
function team.getRndPkmToLvl(level_cap)
    local pkmToLvl = team.getPkmToLvl(level_cap)
    if not pkmToLvl then return end

    return pkmToLvl[math.random(#pkmToLvl)]
end





function team.getAlivePkm()
    return team._filter(team.getPkm(), team.isPkmAlive)
end

function team.getFirstPkmAlive()
    return first(team.getAlivePkm())
end

---duplicate, but easy to understand
function team.getStarter()
    return team.getFirstPkmAlive()
end

function team.getLastPkmAlive()
    return last(team.getAlivePkm())
end

function team.getHighestPkmAlive()
    return team._compare(team.getAlivePkm(), maxLvl)
end

function team.getLowestLvlPkm()
    return team._compare(team.getPkm(), minLvl)
end

function team.getLowestPkmAlive()
    return team._compare(team.getAlivePkm(), minLvl)
end

function team.getPkm()
    local pkm = {}
    for index = 1, getTeamSize() do
        table.insert(pkm, index)
    end
    return pkm
end

--- @summary :
--- @return :
--- @type :
function team.getPkmWithAbility(abilityName)
    return team._filter(team.getPkm(), team.hasPkmAbility, abilityName)
end

--- @summary :
--- @return :
--- @type :
function team.getPkmWithMove(moveName)
    return team._filter(team.getPkm(), team.hasPkmMove, moveName)
end

--- @summary :
--- @return :
--- @type : integer | nil
function team.getFirstPkmWithMove(moveName)
    return first(team.getPkmWithMove(moveName))
end

function team.getUsablePkmWithMove(moveName)
    return team._filter(team.getUsablePkm(), team.hasPkmMove, moveName)
end

function team.getFirstUsablePkmWithMove(moveName)
    return first(team.getUsablePkmWithMove(moveName))
end

--- @summary :
--- @return : 1-6, index of first pkm holding matching item | nil, if no team member matches
--- @type : integer | nil
function team.getPkmWithItem(itemName)
    return team._filter(team.getPkm(), team.hasPkmItem, itemName)
end


function team.getFirstPkmWithItem(itemName)
    return first(team.getPkmWithItem(itemName))
end

function team.getLastPkmWithItem(itemName)
    return last(team.getPkmWithItem(itemName))
end

--- @summary : provides couverage for proShine's unused attacks
function team.getUsablePkm()
    return team._filter(team.getPkm(), isPokemonUsable, itemName)
end

function team.getFirstUsablePkm()
    return first(team.getUsablePkm())
end


function team.giveLeftoversTo(leftoversTarget)
    local leftovers = "Leftovers"
    --correct pkm already has leftovers
    log("DEBUG | hasPkmItem: "..tostring(team.hasPkmItem(leftoversTarget, leftovers)))
    if team.hasPkmItem(leftoversTarget, leftovers) then return end

    --leftoversTarget not in team range
    if leftoversTarget < 1 or leftoversTarget > getTeamSize() then
        log("Error | wrong leftoversTarget: "..tostring(leftoversTarget))
        return
    end

    --remove item, if pkm is already holding one
    if getPokemonHeldItem(leftoversTarget) then takeItemFromPokemon(leftoversTarget) end

    --give leftovers if available
    if hasItem(leftovers) then return  giveItemToPokemon(leftovers, leftoversTarget) end

    --take leftovers if necessary | last because it allows starter to hold leftovers as well
    local pkmWithLeftovers = team.getLastPkmWithItem(leftovers)
    log("DEBUG | pkmWithLeftovers: "..tostring(pkmWithLeftovers))
    if pkmWithLeftovers then return takeItemFromPokemon(pkmWithLeftovers) end
end

function team.getTeamLevel()
    local minLvl = nil
    for i = 1, getTeamSize() do
        local pkmLvl =  getPokemonLevel(i)
        minLvl = minLvl or pkmLvl			--set first pkm as lvl reference
        minLvl = math.min(minLvl, pkmLvl)	--get minimum between following team members
    end
    return minLvl
end



--actual calculations
function team._compare(t, fn)
    if not t then return nil end
    if #t == 0 then return nil end --, nil end
    local key, value = 1, t[1]
    for i = 2, #t do
        if fn(value, t[i]) then
            key, value = i, t[i]
        end
    end
    return value
end

function team._filter(t, fn, ...)
    local newtbl = {}
    for key, value in pairs(t) do
        if fn(key, ...) then
            table.insert(newtbl, value)
        end
    end
    if #newtbl > 0 then return newtbl end
end

function team.getPkmWithId(pkmId)
    return team._filter(team.getPkm(), team._equal, getPokemonId, pkmId)
end

function team.getFirstPkmWithId(pkmId)
    return first(team.getPkmWithId(pkmId))
end

--function team.getPkmWithName(pkmName)
--    return team._filter(team.getPkm(), getPokemonName)
--end
--
--function team.getFirstPkmWithName(pkmName)
--    return first(team.getPkmWithName(pkmName))
--end

---@summary
---@comment: added for questing
function team.getPkmIds()
    return team._transform(team.getPkm(), getPokemonId)
end

function team._transform(t, fn)
    local transTbl = {}
    for key, value in pairs(t) do
        --key param: unnecessary, if key is integer | necessary, for every other tpye
        --sys.debug(key .." | "..value .." |" .. fn(value)) --not possible with reltive pathing
        table.insert(transTbl, value, fn(value))
    end
    return transTbl
end


return team