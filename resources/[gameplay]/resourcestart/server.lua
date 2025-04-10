function startResources()
	local rootNode = xmlLoadFile('resources.xml', true)
	if not rootNode then
		outputDebugString('[Resource start] Failed to load resources.xml!', 1)
		return
	end

	local resources = xmlNodeGetChildren(rootNode)
	local isEvent = (get('resourcestart.isEvent') or false) == true

	local resourceName
	local resourcePriority
	local resourceRestart
	local resourceDelayed
	local resourceDisabledForEvent

	local priority = {}
	local nonPriority = {}
	local restart = {}
	local delayed = {}
	local disabledForEvent = {}

	for i, r in ipairs(resources) do
		resourceName = xmlNodeGetValue(r)
		resourcePriority = tonumber(xmlNodeGetAttribute(r, 'priority')) or 0
		resourceRestart = tonumber(xmlNodeGetAttribute(r, 'restart')) or 0
		resourceDelayed = tonumber(xmlNodeGetAttribute(r, 'delayed')) or 0
		resourceDisabledForEvent = tonumber(xmlNodeGetAttribute(r, 'disableForEvent')) or 0

		if resourceDisabledForEvent == 1 then
			disabledForEvent[resourceName] = true
		end

		if resourceDelayed == 1 then
			table.insert(delayed, resourceName)
		elseif resourcePriority == 1 then
			table.insert(priority, resourceName)
		else
			table.insert(nonPriority, resourceName)
		end

		if resourceRestart == 1 then
			table.insert(restart, resourceName)
		end
	end

	local function tryStartResource(r, reason)
		if isEvent and disabledForEvent[r]  then
			outputDebugString(string.format('[Resource start] Skipping resource %s (disabled for event).', r))
			return
		end

		local res = getResourceFromName(r)
		if res and getResourceState(res) ~= 'running' then
			outputDebugString(string.format('[Resource start] Starting resource %s (%s)...', r, reason))
			startResource(res, true)
		else
			outputDebugString(string.format('[Resource start] Resource %s could not be found or is already started!', r))
		end
	end

	for i, r in ipairs(priority) do
		tryStartResource(r, 'priority')
	end

	for i, r in ipairs(nonPriority) do
		tryStartResource(r, 'non-priority')
	end

	-- Handle delayed start after 30 seconds
	setTimer(function()
		for i, r in ipairs(delayed) do
			tryStartResource(r, 'delayed')
		end
	end, 30000, 1)

	-- Restart resources marked for restart
	for i, r in ipairs(restart) do
		local res = getResourceFromName(r)
		if res and getResourceState(res) == 'running' then
			outputDebugString(string.format('[Resource start] Restarting resource %s...', r))
			restartResource(res)
		else
			outputDebugString(string.format('[Resource start] Resource %s could not be found or isn\'t running!', r))
		end
	end
end

addEventHandler('onResourceStart', resourceRoot, startResources)