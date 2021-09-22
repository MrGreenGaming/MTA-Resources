function startResources()
	local rootNode = xmlLoadFile('resources.xml', true)
	local resources = xmlNodeGetChildren(rootNode)
	
	local resourceName
	local resourcePriority
	local resourceRestart
	
	local priority = {}
	local nonPriority = {}
	local restart = {}
	
	for i,r in ipairs(resources) do
		resourceName = xmlNodeGetValue(r)
		resourcePriority = tonumber(xmlNodeGetAttribute(r, 'priority'))
		
		if resourcePriority == 1 then
			table.insert(priority, resourceName)
		else
			table.insert(nonPriority, resourceName)
		end

		resourceRestart = tonumber(xmlNodeGetAttribute(r, 'restart'))
		if resourceRestart == 1 then
			table.insert(restart, resourceName)
		end
	end
	
	local res
	
	for i,r in ipairs(priority) do
		res = getResourceFromName(r)
		
		if res and getResourceState(res) ~= 'running' then
			outputDebugString(string.format('[Resource start] Starting resource %s...', r))
			startResource(res, true)
		else
			outputDebugString(string.format('[Resource start] Resource %s could not be found or is already started!', r))
		end
	end
	
	for i,r in ipairs(nonPriority) do
		res = getResourceFromName(r)
		
		if res and getResourceState(res) ~= 'running' then
			outputDebugString(string.format('[Resource start] Starting resource %s...', r))
			startResource(res, true)
		else
			outputDebugString(string.format('[Resource start] Resource %s could not be found or is already started!', r))
		end
	end

	for i,r in ipairs(restart) do
		res = getResourceFromName(r)

		if res and getResourceState(res) == 'running' then
			outputDebugString(string.format('[Resource start] Restarting resource %s...', r))
			restartResource(res)
		else
			outputDebugString(string.format('[Resource start] Resource %s could not be found or isn\'t running!', r))
		end
	end
end
addEventHandler('onResourceStart', resourceRoot, startResources)