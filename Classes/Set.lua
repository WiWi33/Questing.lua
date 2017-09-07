--@author m1l4
--inspired from: https://www.lua.org/pil/13.1.html

local gen = require "libs.genlib"

Set = {}

--object methods
function Set:new(t)
    local set = {}
    setmetatable(set, self)

    self.__index = self
    self.__len = gen.size
    self.__class = "Set"

    log("debug: Set:new: "..tostring(t))
    for _, e in pairs(t) do set[e] = true end
    return set
end

function Set:contains(a)
    log(self:tostring())
    log("contains: "..tostring(a).."  >>>  "..tostring(self[a]))
    return self[a]
end

function Set:tostring()
    local s = "{"
    local sep = ""
    for e in pairs(self) do
        s = s .. sep .. tostring(e)
        sep = ", "
    end
    return s .. "}"
end

function Set:print()
    print(self:tostring())
end

function Set.union (a,b)
    local res = Set:new{}
    for k in pairs(a) do res[k] = true end
    for k in pairs(b) do res[k] = true end
    return res
end

function Set.intersection (a,b)
    if not a.__class or not a.__class == "Set" then a = Set:new(a) end
    if not b.__class or not b.__class == "Set" then b = Set:new(b) end

    local res = Set:new{}
    for k in pairs(a) do
        res[k] = b[k]
    end

    if #res == 0 then return nil end
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