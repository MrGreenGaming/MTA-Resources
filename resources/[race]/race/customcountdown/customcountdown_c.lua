local screenWidth, screenHeight = guiGetScreenSize( )
local orange1,orange2,orange3 = 233,214,92
local green1,green2,green3 = 87,176,87
local maxCircleAlpha = {180}
local minCircleAlpha = {0}
local circleSize = 128
local halfCircleSize = circleSize/2
-- GUI DUMMY
local function createDummy()
	circleDummy = guiCreateStaticImage(0.5*screenWidth-halfCircleSize, 0.125*screenHeight, circleSize, circleSize, "img/circle.png", false)
	guiSetVisible( circleDummy, false )
end
addEventHandler("onClientResourceStart",resourceRoot,createDummy)
-- END GUI DUMMY
-- EASY CLASS 
tween = {
  _VERSION     = 'tween 2.0.0',
  _DESCRIPTION = 'tweening for lua',
  _URL         = 'https://github.com/kikito/tween.lua',
  _LICENSE     = [[
    MIT LICENSE
    Copyright (c) 2014 Enrique García Cota, Yuichi Tateno, Emmanuel Oga
    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:
    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}

-- easing

-- Adapted from https://github.com/EmmanuelOga/easing. See LICENSE.txt for credits.
-- For all easing functions:
-- t = time == how much time has to pass for the tweening to complete
-- b = begin == starting property value
-- c = change == ending - beginning
-- d = duration == running time. How much time has passed *right now*

local pow, sin, cos, pi, sqrt, abs, asin = math.pow, math.sin, math.cos, math.pi, math.sqrt, math.abs, math.asin

-- linear
local function linear(t, b, c, d) return c * t / d + b end

-- quad
local function inQuad(t, b, c, d) return c * pow(t / d, 2) + b end
local function outQuad(t, b, c, d)
  t = t / d
  return -c * t * (t - 2) + b
end
local function inOutQuad(t, b, c, d)
  t = t / d * 2
  if t < 1 then return c / 2 * pow(t, 2) + b end
  return -c / 2 * ((t - 1) * (t - 3) - 1) + b
end
local function outInQuad(t, b, c, d)
  if t < d / 2 then return outQuad(t * 2, b, c / 2, d) end
  return inQuad((t * 2) - d, b + c / 2, c / 2, d)
end

-- cubic
local function inCubic (t, b, c, d) return c * pow(t / d, 3) + b end
local function outCubic(t, b, c, d) return c * (pow(t / d - 1, 3) + 1) + b end
local function inOutCubic(t, b, c, d)
  t = t / d * 2
  if t < 1 then return c / 2 * t * t * t + b end
  t = t - 2
  return c / 2 * (t * t * t + 2) + b
end
local function outInCubic(t, b, c, d)
  if t < d / 2 then return outCubic(t * 2, b, c / 2, d) end
  return inCubic((t * 2) - d, b + c / 2, c / 2, d)
end

-- quart
local function inQuart(t, b, c, d) return c * pow(t / d, 4) + b end
local function outQuart(t, b, c, d) return -c * (pow(t / d - 1, 4) - 1) + b end
local function inOutQuart(t, b, c, d)
  t = t / d * 2
  if t < 1 then return c / 2 * pow(t, 4) + b end
  return -c / 2 * (pow(t - 2, 4) - 2) + b
end
local function outInQuart(t, b, c, d)
  if t < d / 2 then return outQuart(t * 2, b, c / 2, d) end
  return inQuart((t * 2) - d, b + c / 2, c / 2, d)
end

-- quint
local function inQuint(t, b, c, d) return c * pow(t / d, 5) + b end
local function outQuint(t, b, c, d) return c * (pow(t / d - 1, 5) + 1) + b end
local function inOutQuint(t, b, c, d)
  t = t / d * 2
  if t < 1 then return c / 2 * pow(t, 5) + b end
  return c / 2 * (pow(t - 2, 5) + 2) + b
end
local function outInQuint(t, b, c, d)
  if t < d / 2 then return outQuint(t * 2, b, c / 2, d) end
  return inQuint((t * 2) - d, b + c / 2, c / 2, d)
end

-- sine
local function inSine(t, b, c, d) return -c * cos(t / d * (pi / 2)) + c + b end
local function outSine(t, b, c, d) return c * sin(t / d * (pi / 2)) + b end
local function inOutSine(t, b, c, d) return -c / 2 * (cos(pi * t / d) - 1) + b end
local function outInSine(t, b, c, d)
  if t < d / 2 then return outSine(t * 2, b, c / 2, d) end
  return inSine((t * 2) -d, b + c / 2, c / 2, d)
end

-- expo
local function inExpo(t, b, c, d)
  if t == 0 then return b end
  return c * pow(2, 10 * (t / d - 1)) + b - c * 0.001
end
local function outExpo(t, b, c, d)
  if t == d then return b + c end
  return c * 1.001 * (-pow(2, -10 * t / d) + 1) + b
end
local function inOutExpo(t, b, c, d)
  if t == 0 then return b end
  if t == d then return b + c end
  t = t / d * 2
  if t < 1 then return c / 2 * pow(2, 10 * (t - 1)) + b - c * 0.0005 end
  return c / 2 * 1.0005 * (-pow(2, -10 * (t - 1)) + 2) + b
end
local function outInExpo(t, b, c, d)
  if t < d / 2 then return outExpo(t * 2, b, c / 2, d) end
  return inExpo((t * 2) - d, b + c / 2, c / 2, d)
end

-- circ
local function inCirc(t, b, c, d) return(-c * (sqrt(1 - pow(t / d, 2)) - 1) + b) end
local function outCirc(t, b, c, d)  return(c * sqrt(1 - pow(t / d - 1, 2)) + b) end
local function inOutCirc(t, b, c, d)
  t = t / d * 2
  if t < 1 then return -c / 2 * (sqrt(1 - t * t) - 1) + b end
  t = t - 2
  return c / 2 * (sqrt(1 - t * t) + 1) + b
end
local function outInCirc(t, b, c, d)
  if t < d / 2 then return outCirc(t * 2, b, c / 2, d) end
  return inCirc((t * 2) - d, b + c / 2, c / 2, d)
end

-- elastic
local function calculatePAS(p,a,c,d)
  p, a = p or d * 0.3, a or 0
  if a < abs(c) then return p, c, p / 4 end -- p, a, s
  return p, a, p / (2 * pi) * asin(c/a) -- p,a,s
end
local function inElastic(t, b, c, d, a, p)
  local s
  if t == 0 then return b end
  t = t / d
  if t == 1  then return b + c end
  p,a,s = calculatePAS(p,a,c,d)
  t = t - 1
  return -(a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
end
local function outElastic(t, b, c, d, a, p)
  local s
  if t == 0 then return b end
  t = t / d
  if t == 1 then return b + c end
  p,a,s = calculatePAS(p,a,c,d)
  return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p) + c + b
end
local function inOutElastic(t, b, c, d, a, p)
  local s
  if t == 0 then return b end
  t = t / d * 2
  if t == 2 then return b + c end
  p,a,s = calculatePAS(p,a,c,d)
  t = t - 1
  if t < 0 then return -0.5 * (a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b end
  return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p ) * 0.5 + c + b
end
local function outInElastic(t, b, c, d, a, p)
  if t < d / 2 then return outElastic(t * 2, b, c / 2, d, a, p) end
  return inElastic((t * 2) - d, b + c / 2, c / 2, d, a, p)
end

-- back
local function inBack(t, b, c, d, s)
  s = s or 1.70158
  t = t / d
  return c * t * t * ((s + 1) * t - s) + b
end
local function outBack(t, b, c, d, s)
  s = s or 1.70158
  t = t / d - 1
  return c * (t * t * ((s + 1) * t + s) + 1) + b
end
local function inOutBack(t, b, c, d, s)
  s = (s or 1.70158) * 1.525
  t = t / d * 2
  if t < 1 then return c / 2 * (t * t * ((s + 1) * t - s)) + b end
  t = t - 2
  return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
end
local function outInBack(t, b, c, d, s)
  if t < d / 2 then return outBack(t * 2, b, c / 2, d, s) end
  return inBack((t * 2) - d, b + c / 2, c / 2, d, s)
end

-- bounce
local function outBounce(t, b, c, d)
  t = t / d
  if t < 1 / 2.75 then return c * (7.5625 * t * t) + b end
  if t < 2 / 2.75 then
    t = t - (1.5 / 2.75)
    return c * (7.5625 * t * t + 0.75) + b
  elseif t < 2.5 / 2.75 then
    t = t - (2.25 / 2.75)
    return c * (7.5625 * t * t + 0.9375) + b
  end
  t = t - (2.625 / 2.75)
  return c * (7.5625 * t * t + 0.984375) + b
end
local function inBounce(t, b, c, d) return c - outBounce(d - t, 0, c, d) + b end
local function inOutBounce(t, b, c, d)
  if t < d / 2 then return inBounce(t * 2, 0, c, d) * 0.5 + b end
  return outBounce(t * 2 - d, 0, c, d) * 0.5 + c * .5 + b
end
local function outInBounce(t, b, c, d)
  if t < d / 2 then return outBounce(t * 2, b, c / 2, d) end
  return inBounce((t * 2) - d, b + c / 2, c / 2, d)
end

tween.easing = {
  linear    = linear,
  inQuad    = inQuad,    outQuad    = outQuad,    inOutQuad    = inOutQuad,    outInQuad    = outInQuad,
  inCubic   = inCubic,   outCubic   = outCubic,   inOutCubic   = inOutCubic,   outInCubic   = outInCubic,
  inQuart   = inQuart,   outQuart   = outQuart,   inOutQuart   = inOutQuart,   outInQuart   = outInQuart,
  inQuint   = inQuint,   outQuint   = outQuint,   inOutQuint   = inOutQuint,   outInQuint   = outInQuint,
  inSine    = inSine,    outSine    = outSine,    inOutSine    = inOutSine,    outInSine    = outInSine,
  inExpo    = inExpo,    outExpo    = outExpo,    inOutExpo    = inOutExpo,    outInExpo    = outInExpo,
  inCirc    = inCirc,    outCirc    = outCirc,    inOutCirc    = inOutCirc,    outInCirc    = outInCirc,
  inElastic = inElastic, outElastic = outElastic, inOutElastic = inOutElastic, outInElastic = outInElastic,
  inBack    = inBack,    outBack    = outBack,    inOutBack    = inOutBack,    outInBack    = outInBack,
  inBounce  = inBounce,  outBounce  = outBounce,  inOutBounce  = inOutBounce,  outInBounce  = outInBounce
}



-- private stuff

local function copyTables(destination, keysTable, valuesTable)
  valuesTable = valuesTable or keysTable
  local mt = getmetatable(keysTable)
  if mt and getmetatable(destination) == nil then
    setmetatable(destination, mt)
  end
  for k,v in pairs(keysTable) do
    if type(v) == 'table' then
      destination[k] = copyTables({}, v, valuesTable[k])
    else
      destination[k] = valuesTable[k]
    end
  end
  return destination
end

local function checkSubjectAndTargetRecursively(subject, target, path)
  path = path or {}
  local targetType, newPath
  for k,targetValue in pairs(target) do
    targetType, newPath = type(targetValue), copyTables({}, path)
    table.insert(newPath, tostring(k))
    if targetType == 'number' then
      assert(type(subject[k]) == 'number', "Parameter '" .. table.concat(newPath,'/') .. "' is missing from subject or isn't a number")
    elseif targetType == 'table' then
      checkSubjectAndTargetRecursively(subject[k], targetValue, newPath)
    else
      assert(targetType == 'number', "Parameter '" .. table.concat(newPath,'/') .. "' must be a number or table of numbers")
    end
  end
end

local function checkNewParams(duration, subject, target, easing)
  assert(type(duration) == 'number' and duration > 0, "duration must be a positive number. Was " .. tostring(duration))
  local tsubject = type(subject)
  assert(tsubject == 'table' or tsubject == 'userdata', "subject must be a table or userdata. Was " .. tostring(subject))
  assert(type(target)== 'table', "target must be a table. Was " .. tostring(target))
  assert(type(easing)=='function', "easing must be a function. Was " .. tostring(easing))
  checkSubjectAndTargetRecursively(subject, target)
end

local function getEasingFunction(easing)
  easing = easing or "linear"
  if type(easing) == 'string' then
    local name = easing
    easing = tween.easing[name]
    if type(easing) ~= 'function' then
      error("The easing function name '" .. name .. "' is invalid")
    end
  end
  return easing
end

local function performEasingOnSubject(subject, target, initial, clock, duration, easing)
  local t,b,c,d
  for k,v in pairs(target) do
    if type(v) == 'table' then
      performEasingOnSubject(subject[k], v, initial[k], clock, duration, easing)
    else
      t,b,c,d = clock, initial[k], v - initial[k], duration
      subject[k] = easing(t,b,c,d)
    end
  end
end

-- Tween methods

Tween = {}
local Tween_mt = {__index = Tween}

function Tween:set(clock)
  assert(type(clock) == 'number', "clock must be a positive number or 0")

  self.clock = clock

  if self.clock <= 0 then

    self.clock = 0
    copyTables(self.subject, self.initial)

  elseif self.clock >= self.duration then -- the tween has expired

    self.clock = self.duration
    copyTables(self.subject, self.target)

  else

    performEasingOnSubject(self.subject, self.target, self.initial, self.clock, self.duration, self.easing)

  end

  return self.clock >= self.duration
end

function Tween:reset()
  return self:set(0)
end

function Tween:update(dt)
  assert(type(dt) == 'number', "dt must be a number")
  -- if not self.clock then return end
  return self:set(self.clock + dt)
end


-- Public interface

function tween.new(duration, subject, target, easing)
  easing = getEasingFunction(easing)
  checkNewParams(duration, subject, target, easing)
  return setmetatable({
    duration  = duration,
    subject   = subject,
    target    = target,
    easing    = easing,

    initial   = copyTables({},target,subject),
    clock     = 0
  }, Tween_mt)
end

-- END EASY CLASS
function updateTween(dt)
    local dt = dt*0.001
    Tween:update(tonumber(dt))
end






local function countdownCircle(color,alpha)
    local cx,cy,cw,ch = dummyToDX(circleDummy,"image")
    if color == "orange" then
        dxDrawImage( cx,cy,cw,ch, "img/circle.png", 0, 0, 0, tocolor(orange1,orange2,orange3,alpha), true )
    elseif color == "green" then
        dxDrawImage( cx,cy,cw,ch, "img/circle.png", 0, 0, 0, tocolor(green1,green2,green3,alpha), true )
    end
end

local function countdownText(text,alpha)
    local tx,ty,tw,th = dummyToDX(circleDummy,"text")
    if tonumber(text) then cdSize = 5 elseif not tonumber(text) then cdSize = 3.5 end
    dxDrawText(text,tx,ty,tw,th,tocolor(255,255,255,alpha),cdSize,"pricedown","center","center",true,true,true,false,true)
end


-- eases --
function cd_eases()
	cd_alpha = {circleone = 180, circletwo = 180, circlethree = 180, circlego = 180, one = 255, two = 255, three = 255, go = 255}
	threeCircle = tween.new(0.5,cd_alpha,{circlethree = 0},'linear')
	twoCircle = tween.new(0.5,cd_alpha,{circletwo = 0},'linear')
	oneCircle = tween.new(0.5,cd_alpha,{circleone = 0},'linear')
	goCircle = tween.new(1,cd_alpha,{circlego = 0},'linear')
	goText = tween.new(1,cd_alpha,{go = 0}, 'linear')
	cd_easesSet = true
end


-- eases --
-- define what to draw --
local cd_isCountDownActive = false
local cd_canEase = false
local activeCircle = false -- three , two, one, go




function drawTheShit(dt)
    if cd_isCountDownActive then
        local dt = dt*0.001
        if activeCircle == "three" then
            countdownCircle("orange",cd_alpha["circlethree"])
            countdownText("3",255)
        elseif activeCircle == "two" then
            countdownCircle("orange",cd_alpha["circletwo"])
            countdownText("2",255)

        elseif activeCircle == "one" then
            countdownCircle("orange",cd_alpha["circleone"])
            countdownText("1",255)

        elseif activeCircle == "go" then
            countdownCircle("green",cd_alpha["circlego"])
            countdownText("Go",cd_alpha["go"])
        end

        easeIt(dt)
    end
end
addEventHandler("onClientPreRender",root,drawTheShit)


function easeIt(dt)
    if c_threeCircle then Ease3 = false end
    if c_twoCircle then Ease2 = false end
    if c_oneCircle then Ease1 = false end
    if c_goCircle then EaseGo = false end

    if activeCircle == "three" and c_threeCircle ~= true and Ease3 == true then
        c_threeCircle = threeCircle:update(dt)
    elseif activeCircle == "two" and c_twoCircle ~= true and Ease2 == true then
        c_twoCircle = twoCircle:update(dt)
    elseif activeCircle == "one" and c_oneCircle ~= true and Ease1 == true then
        c_oneCircle = oneCircle:update(dt)
    elseif activeCircle == "go" and c_goCircle ~= true and EaseGo == true then
        c_goCircle = goCircle:update(dt)
        c_goText = goText:update(dt)
    end
end


addEvent("receiveServerCountdown",true)
function receiveCountdownTimer(whatToDo)
	if cd_easesSet ~= true then cd_eases() end
	cd_isCountDownActive = true
    if whatToDo == 3 then
        activeCircle = "three"
        -- playSoundFrontEnd(44)
		playSound("audio/123.mp3")
        setTimer(function() Ease3 = true end,500,1)
    elseif whatToDo == 2 then
        activeCircle = "two"
        -- playSoundFrontEnd(44)
		playSound("audio/123.mp3")
        setTimer(function() Ease2 = true end,500,1)
    elseif whatToDo == 1 then
        activeCircle = "one"
        -- playSoundFrontEnd(44)
		playSound("audio/123.mp3")
        setTimer(function() Ease1 = true end,500,1)
    elseif whatToDo == "go" then
        activeCircle = "go"
        -- playSoundFrontEnd(45)
		playSound("audio/go.mp3")
        setTimer(function() EaseGo = true end,500,1)

    end
end
addEventHandler("receiveServerCountdown",resourceRoot,receiveCountdownTimer)

addEvent("resetCustomCountdown", true)
function cd_reset()
    activeCircle = nil
	Ease3 = nil
	Ease2 = nil
	Ease1 = nil
	EaseGo = nil
	c_threeCircle = nil
	c_twoCircle = nil
	c_oneCircle = nil
	c_goCircle = nil
	c_goCircle = nil
	c_goText = nil
	cd_isCountDownActive = false
	cd_easesSet = false
	cd_alpha = nil
	threeCircle = nil
	twoCircle = nil
	oneCircle = nil
	goCircle = nil
	goText = nil
	cd_eases()
end		
addEventHandler("resetCustomCountdown", resourceRoot,cd_reset)
-- Utils --

 


function dummyToDX(dummy,kind)
    local dummyPosX,dummyPosY = guiGetPosition( dummy, false )
    local dummyWidth,dummyHeight = guiGetSize( dummy, false )
    if kind == "image" then
        return dummyPosX,dummyPosY,dummyWidth,dummyHeight
    elseif kind == "text" then 
        return dummyPosX,dummyPosY,dummyPosX+dummyWidth,dummyPosY+dummyHeight
    end
end
