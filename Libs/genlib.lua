gen = {}

--TODO: make a separate lib project and remove the redundances in pathfinder and own workspace
--since many things are copied from there
--filter
--TODO: write globa library, from my project's, pathfinder's and questing's library - all those are doing the same...

--comparers - normally it makes no difference if >= is used or not,
-- but when using it in methods it becomes mandator to prevent
--

--TODO: remvoe the level part and make it a clean max, min
function gen.maxLvl(a, b) return getPokemonLevel(b) >= getPokemonLevel(a) end     --greater **equal** is necesarry to avoid swaping same lvled pkm
function gen.minLvl(a, b) return getPokemonLevel(b) < getPokemonLevel(a) end      --lesser is necesarry to avoid swaping same lvled pkm

--compare functions
function gen.smaller(a, b) return a < b end
function gen.higher(a, b) return a > b end

--filter
function gen.first(t) t = t or {} if #t > 0 then return t[1] end end
function gen.last(t) t = t or {} if #t > 0 then return t[#t] end end

--generic - at least all pkm properties or even more could be reduced
function gen.equal(i, fn, value) return fn(i)==value end



function gen.size(table)
    local count = 0
    for k in pairs(table) do
        count = count + 1
    end
    return count
end


return gen