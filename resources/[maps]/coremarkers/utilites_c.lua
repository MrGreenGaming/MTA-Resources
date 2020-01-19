function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix(element)
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z 
end

function getElementSpeed(element,unit)
if (unit == nil) then unit = 0 end
if (isElement(element)) then
	local x,y,z = getElementVelocity(element)
	if (unit=="mph" or unit==1 or unit =='1') then
		return (x^2 + y^2 + z^2) ^ 0.5 * 100
	else
		return (x^2 + y^2 + z^2) ^ 0.5 * 1.8 * 100
	end
else
	outputDebugString("Not an element. Can't get speed")
	return false
end
end

function setElementSpeed(element, unit, speed)
if (unit == nil) then unit = 0 end
if (speed == nil) then speed = 0 end
speed = tonumber(speed)
local acSpeed = getElementSpeed(element, unit)
if (acSpeed~=false) and (acSpeed~=0) then
	local diff = speed/acSpeed
	local x,y,z = getElementVelocity(element)
		setElementVelocity(element,x*diff,y*diff,z*diff)
	return true
else
	return false
end
return false
end

function getVehicleOriginalProperty( element, property )
    if isElement ( element ) and getElementType ( element ) == "vehicle" and type ( property ) == "string" then
        local handlingTable = getOriginalHandling ( getElementModel(element) ) 
        local value = handlingTable[property]
 
        if value then 
            return value 
        end
    end
 
    return false
end

function table.copy(tab, recursive)
    local ret = {}
    for key, value in pairs(tab) do
        if (type(value) == "table") and recursive then ret[key] = table.copy(value)
        else ret[key] = value end
    end
    return ret
end

function var_dump(...)
	-- default options
	local verbose = false
	local firstLevel = true
	local outputDirectly = true
	local noNames = false
	local indentation = "\t\t\t\t\t\t"
	local depth = nil
 
	local name = nil
	local output = {}
	for k,v in ipairs(arg) do
		-- check for modifiers
		if type(v) == "string" and k < #arg and v:sub(1,1) == "-" then
			local modifiers = v:sub(2)
			if modifiers:find("v") ~= nil then
				verbose = true
			end
			if modifiers:find("s") ~= nil then
				outputDirectly = false
			end
			if modifiers:find("n") ~= nil then
				verbose = false
			end
			if modifiers:find("u") ~= nil then
				noNames = true
			end
			local s,e = modifiers:find("d%d+")
			if s ~= nil then
				depth = tonumber(string.sub(modifiers,s+1,e))
			end
		-- set name if appropriate
		elseif type(v) == "string" and k < #arg and name == nil and not noNames then
			name = v
		else
			if name ~= nil then
				name = ""..name..": "
			else
				name = ""
			end
 
			local o = ""
			if type(v) == "string" then
				table.insert(output,name..type(v).."("..v:len()..") \""..v.."\"")
			elseif type(v) == "userdata" then
				local elementType = "no valid MTA element"
				if isElement(v) then
					elementType = getElementType(v)
				end
				table.insert(output,name..type(v).."("..elementType..") \""..tostring(v).."\"")
			elseif type(v) == "table" then
				local count = 0
				for key,value in pairs(v) do
					count = count + 1
				end
				table.insert(output,name..type(v).."("..count..") \""..tostring(v).."\"")
				if verbose and count > 0 and (depth == nil or depth > 0) then
					table.insert(output,"\t{")
					for key,value in pairs(v) do
						-- calls itself, so be careful when you change anything
						local newModifiers = "-s"
						if depth == nil then
							newModifiers = "-sv"
						elseif  depth > 1 then
							local newDepth = depth - 1
							newModifiers = "-svd"..newDepth
						end
						local keyString, keyTable = var_dump(newModifiers,key)
						local valueString, valueTable = var_dump(newModifiers,value)
 
						if #keyTable == 1 and #valueTable == 1 then
							table.insert(output,indentation.."["..keyString.."]\t=>\t"..valueString)
						elseif #keyTable == 1 then
							table.insert(output,indentation.."["..keyString.."]\t=>")
							for k,v in ipairs(valueTable) do
								table.insert(output,indentation..v)
							end
						elseif #valueTable == 1 then
							for k,v in ipairs(keyTable) do
								if k == 1 then
									table.insert(output,indentation.."["..v)
								elseif k == #keyTable then
									table.insert(output,indentation..v.."]")
								else
									table.insert(output,indentation..v)
								end
							end
							table.insert(output,indentation.."\t=>\t"..valueString)
						else
							for k,v in ipairs(keyTable) do
								if k == 1 then
									table.insert(output,indentation.."["..v)
								elseif k == #keyTable then
									table.insert(output,indentation..v.."]")
								else
									table.insert(output,indentation..v)
								end
							end
							for k,v in ipairs(valueTable) do
								if k == 1 then
									table.insert(output,indentation.." => "..v)
								else
									table.insert(output,indentation..v)
								end
							end
						end
					end
					table.insert(output,"\t}")
				end
			else
				table.insert(output,name..type(v).." \""..tostring(v).."\"")
			end
			name = nil
		end
	end
	local string = ""
	for k,v in ipairs(output) do
		if outputDirectly then
			outputConsole(v)
		end
		string = string..v
	end
	return string, output
end