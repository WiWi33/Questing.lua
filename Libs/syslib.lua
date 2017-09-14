local sys = {}



function sys.debug(valDescription, value, isTitle)
	if DEBUG then
		value = value or "nil"
		value = tostring(value)
		local message = valDescription ..": "..value
		--indent
		sys._printIndent("DEBUG | ", message, isTitle)
	end
end

function sys._printIndent(prefix, message, isTitle)
	local indent = "\t"
	if isTitle then indent = "" end
	log("DEBUG | " ..indent.. message)
end

function sys.todo(message)
	if TODO then
		message = message or ""
		log("TODO |  " .. message)
	end
end

function sys.info(message) return log("INFO | "..message) end
function sys.log(message) return log("LOG | "..message) end

function sys.error(functionName, message)
	return fatal("ERROR | " .. tostring(functionName) .. ": " .. tostring(message))
end

function sys.assert(test, functionName, message)
	if not test then
		sys.error(functionName, message)
		return false
	end
	return true
end

function sys.stringContains(haystack, needle)
	haystack = string.upper(haystack)
	needle   = string.upper(needle)
	if string.find(haystack, needle) ~= nil then
		return true
	end
	return false
end

function sys.removeCharacter(str, character)
	return str:gsub("%" .. character .. "+", "")
end

function sys.tableHasValue(tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end
	return false
end

return sys