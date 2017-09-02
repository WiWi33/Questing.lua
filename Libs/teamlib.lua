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
local function first(t) if #t > 0 then return t[1] end end
local function last(t) if #t > 0 then return t[#t] end end



TeamManager = {}
--pkm conditions
function TeamManager.isPkmAlive(i) return getPokemonHealth(i) > 0 end
function TeamManager.isPkmToLvl(i, lvl_cap) return getPokemonLevel(i) < lvl_cap end
function TeamManager.isPkmToLvlAlive(i, lvl_cap) return TeamManager.isPkmAlive(i) and TeamManager.isPkmToLvl(i, lvl_cap) end
function TeamManager.isPkmToLvlUsable(i, lvl_cap) return isPokemonUsable(i) and TeamManager.isPkmToLvl(i, lvl_cap) end
--pkm properties
function TeamManager.hasPkmItem(i, item) return getPokemonHeldItem(i) == item end
function TeamManager.hasPkmAbility(i, abilty) return getPokemonAbility(i) == abilty end
function TeamManager.hasPkmNature(i, nature) return getPokemonNature(i) == nature end
function TeamManager.hasPkmMove(i, move) return hasMove(i) == move end



--- @summary : fetches all pkm under given level cap
--- @param level_cap: upper level treshold, 100 by default
--- @type level_cap: integer
--- @return : list of team indexes of all pkm that can be leveled up
--- @type : table (list of integers)
function TeamManager.getPkmToLvl(level_cap)
    return TeamManager._filter(TeamManager.getPkm(), TeamManager.isPkmToLvl, level_cap)
end

--- @summary : Searches the lowest leveled pkm under given level_cap
--- @param level_cap: upper level treshold, 100 by default
--- @type level_cap: integer
--- @return : team index, of lowest leveled pkm under level_cap | nil, if none exists
--- @type : integer | nil
function TeamManager.getLowestPkmToLvl(level_cap)
    return TeamManager._compare(TeamManager.getPkmToLvl(level_cap), minLvl)
end

function TeamManager.getAlivePkmToLvl(level_cap)
    return TeamManager._filter(TeamManager.getPkm(), TeamManager.isPkmToLvlAlive, level_cap)
end

function TeamManager.getLowestAlivePkmToLvl(level_cap)
    return TeamManager._compare(TeamManager.getAlivePkmToLvl(level_cap), minLvl)
end

--- @summary : Searches the lowest leveled pkm under given level_cap
--- @param level_cap: upper level treshold, 100 by default
--- @type level_cap: integer
--- @return : team index, of lowest leveled pkm under level_cap | nil, if none exists
--- @type : integer | nil
function TeamManager.getLowestUsablePkmToLvl(level_cap)
    return TeamManager._compare(TeamManager.getUsablePkmToLvl(), minLvl)
end

--- @summary : fetches all pkm under given level cap, that are able to battle
--- @param level_cap: upper level treshold, 100 by default
--- @type level_cap: integer
--- @return : list of team indexes of all battle-ready pkm that can be leveled up
--- @type : table (list of integers)
function TeamManager.getUsablePkmToLvl(level_cap)
    return TeamManager._filter(TeamManager.getUsablePkm(), TeamManager.isPkmToLvl, level_cap)
end

--- @summary : Searches the lowest leveled pkm under given level_cap
--- @param level_cap: upper level treshold, 100 by default
--- @type level_cap: integer
--- @return : team index, of lowest leveled pkm under level_cap | nil, if none exists
--- @type : integer | nil
function TeamManager.getRndPkmToLvl(level_cap)
    local pkmToLvl = TeamManager.getPkmToLvl(level_cap)
    if not pkmToLvl then return end

    return pkmToLvl[math.random(#pkmToLvl)]
end





function TeamManager.getAlivePkm()
    return TeamManager._filter(TeamManager.getPkm(), TeamManager.isPkmAlive)
end

function TeamManager.getFirstPkmAlive()
    return first(TeamManager.getAlivePkm())
end

---duplicate, but easy to understand
function TeamManager.getStarter()
    return TeamManager.getFirstPkmAlive()
end

function TeamManager.getLastPkmAlive()
    return last(TeamManager.getAlivePkm())
end

function TeamManager.getHighestPkmAlive()
    return TeamManager._compare(TeamManager.getAlivePkm(), maxLvl)
end

function TeamManager.getLowestPkmAlive()
    return TeamManager._compare(TeamManager.getAlivePkm(), minLvl)
end

function TeamManager.getPkm()
    local pkm = {}
    for index = 1, getTeamSize() do
        table.insert(pkm, index)
    end
    return pkm
end

--- @summary :
--- @return : 1-6, index of first pkm with matching ability | nil, if no team member matches
--- @type : integer | nil
function TeamManager.getPkmWithAbility(abilityName)
    return TeamManager._filter(TeamManager.getPkm(), TeamManager.hasPkmAbility, abilityName)
end

--- @summary :
--- @return : 1-6, index of first pkm with matching move | nil, if no team member matches
--- @type : integer | nil
function TeamManager.getPkmWithMove(moveName)
    return TeamManager._filter(TeamManager.getPkm(), TeamManager.hasPkmMove, moveName)
end

function TeamManager.getUsablePkmWithMove(moveName)
    return TeamManager._filter(TeamManager.getUsablePkm(), TeamManager.hasPkmMove, moveName)
end

function TeamManager.getFirstUsablePkmWithMove(moveName)
    return first(TeamManager.getUsablePkmWithMove(moveName))
end

--- @summary :
--- @return : 1-6, index of first pkm holding matching item | nil, if no team member matches
--- @type : integer | nil
function TeamManager.getPkmWithItem(itemName)
    return TeamManager._filter(TeamManager.getPkm(), TeamManager.hasPkmItem, itemName)
end


function TeamManager.getFirstPkmWithItem(itemName)
    return first(TeamManager.getPkmWithItem(itemName))
end

function TeamManager.getLastPkmWithItem(itemName)
    return last(TeamManager.getPkmWithItem(itemName))
end

--- @summary : provides couverage for proShine's unused attacks
function TeamManager.getUsablePkm()
    return TeamManager._filter(TeamManager.getPkm(), isPokemonUsable, itemName)
end

function TeamManager.getFirstUsablePkm()
    return first(TeamManager.getUsablePkm())
end


function TeamManager.giveLeftoversTo(leftoversTarget)
    local leftovers = "Leftovers"
    --correct pkm already has leftovers
    log("DEBUG | hasPkmItem: "..tostring(TeamManager.hasPkmItem(leftoversTarget, leftovers)))
    if TeamManager.hasPkmItem(leftoversTarget, leftovers) then return end

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
    local pkmWithLeftovers = TeamManager.getLastPkmWithItem(leftovers)
    log("DEBUG | pkmWithLeftovers: "..tostring(pkmWithLeftovers))
    if pkmWithLeftovers then return takeItemFromPokemon(pkmWithLeftovers) end
end

function TeamManager.getTeamLevel()
    local minLvl = nil
    for i = 1, getTeamSize() do
        local pkmLvl =  getPokemonLevel(i)
        minLvl = minLvl or pkmLvl			--set first pkm as lvl reference
        minLvl = math.min(minLvl, pkmLvl)	--get minimum between following team members
    end
    return minLvl
end



--actual calculations
function TeamManager._compare(t, fn)
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

function TeamManager._filter(t, fn, ...)
    local newtbl = {}
    for key, value in pairs(t) do
        if fn(key, ...) then
            table.insert(newtbl, value)
        end
    end

    if #newtbl > 0 then return newtbl end
end

return TeamManager