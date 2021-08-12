




function ReceiveCountdownTimer(whatToDo)
	if whatToDo == 3 then
		setTrafficLightState(2)
	elseif whatToDo == 1 then
		setTrafficLightState(6)
	elseif whatToDo == "go" then
		setTrafficLightState(5)
		setTimer(function()
			setTrafficLightState("auto")
		end, 3000, 1)
	end

end
addEventHandler("receiveServerCountdown",resourceRoot,ReceiveCountdownTimer)