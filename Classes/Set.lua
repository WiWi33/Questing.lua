--@author m1l4
--inspired from: https://www.lua.org/pil/13.1.html

Set = {}

local function setLength(set)
    local count = 0
    for k in pairs(set) do
        count = count + 1
    end
    return count
end

--object methods
function Set:new (t)
    local set = {}
    setmetatable(set, self)

    self.__index = self
    self.__len = setLength

    for _, e in ipairs(t) do set[e] = true end
    return set
end

function Set:contains(a)
    return self[a]
end

function Set:tostring()
    local s = "{"
    local sep = ""
    for e in pairs(self) do
        s = s .. sep .. e
        sep = ", "
    end
    return s .. "}"
end

function Set:print()
    print(self:tostring())
end

--static methods
function Set.contains(list, item)
    local set = Set:new(list)
    return set.contains(item)
end

function Set.union (a,b)
    local res = Set:new{}
    for k in pairs(a) do res[k] = true end
    for k in pairs(b) do res[k] = true end
    return res
end

function Set.intersection (a,b)
    local res = Set:new{}
    for k in pairs(a) do
        res[k] = b[k]
    end
    return res
end

--Tests
--a = Set:new{1,3,5,7,8,9 }
--b = Set:new{8,2,4,10}
--s = Set.intersection(a,b)
--s:print()
--print(a[10])
--print(#s)
--print(s:contains())

return Set