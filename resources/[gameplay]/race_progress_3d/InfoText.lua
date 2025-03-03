---
-- Helper that calls a custom draw function with an appropriate alpha value, to
-- fade in/out what is drawn.
--
-- Create an instance:
-- infoInstance = InfoText:new()
--
-- The "drawFunction" value needs to be set to a function, for example:
-- infoInstance.drawFunction = function(fade) [draw something] end
-- (where fade is the alpha value between 0 and 1)
--
-- Use the functions to show/hide as needed. The draw() function must
-- be called in onClientRender or similiar, which will only actually
-- call the set drawFunction if currently shown.
--

InfoText = {}
InfoText.fadeTime = 200
InfoText.displayTime = 300*1000
InfoText.started = nil
InfoText.showAsap = false
InfoText.drawFunction = nil
InfoText.allowOnce = false
InfoText.showAlways = false

function InfoText:new()
	local object = {}
	setmetatable(object, self)
	self.__index = self
	return object
end

--[[
-- Use this so that showIfAllowed() will work once. This can
-- be used to show some kind of info e.g. only once per map
-- or once per session.
-- ]]
function InfoText:setAllowOnce()
	self.allowOnce = true
end

--[[
-- Will draw immediately if setAllowOnce() has been called.
-- ]]
function InfoText:showIfAllowed()
	if self.allowOnce then
		self.showAsap = true
		self.allowOnce = false
	end
end

--[[
-- Draw immediately, without conditions.
-- ]]
function InfoText:show()
	self.showAsap = true
end

--[[
-- Check if currently allowed.
-- ]]
function InfoText:isAllowed()
	return self.allowOnce
end

--[[
-- Draw permanently, without any fading.
-- ]]
function InfoText:setShowAlways(show)
	self.showAlways = show
end

--[[
-- Reset all the drawing state and don't draw.
-- ]]
function InfoText:reset()
	self.showAsap = false
	self.started = nil
	self.allowOnce = false
	self.showAlways = false
end

--[[
-- Draw only if function is set and currently showing.
--
-- This has to be called for anything to be drawn, usually
-- in the onClientRender event or similiar.
-- ]]
function InfoText:draw()
	if self.drawFunction == nil then
		return
	end
	-- Draw always
	if self.showAlways then
		self.drawFunction(1.0)
		return
	end
	-- Don't draw
	if not self.showAsap then
		return
	end
	
	if self.started == nil then
		self.started = getTickCount()
	end

	local passed = getTickCount() - self.started

	if passed > self.displayTime then
		self:reset()
		return
	end

	local fade = 1
	if passed < self.fadeTime then
		fade = 1 / self.fadeTime * passed
	elseif passed > self.displayTime - self.fadeTime then
		fade = 1 / self.fadeTime * math.abs(passed - self.displayTime)
	end
	self.drawFunction(fade)
end
