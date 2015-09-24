function startCustomCountdown()
	cd_three()
end
function cd_three()
	triggerClientEvent( root,"receiveServerCountdown", root, 3 )
	t_toTwo = setTimer(cd_two,1000,1)
end

function cd_two()
	triggerClientEvent( root,"receiveServerCountdown", root, 2 )
	t_toOne = setTimer(cd_one,1000,1)
end

function cd_one()
	triggerClientEvent( root,"receiveServerCountdown", root, 1 )
	t_toGo = setTimer(cd_go,1000,1)
end

function cd_go()
	triggerClientEvent( root,"receiveServerCountdown", root, "go" )
	t_toLaunch = setTimer(launchRace,100,1)
	t_toTwo = nil
	t_toOne = nil
	t_toGo = nil
	t_toLaunch = nil
end

addEvent("StopCountDown",true)
addEventHandler("StopCountDown", resourceRoot, 
	function()
		if isTimer(t_toTwo) then killTimer( t_toTwo ) end
		if isTimer(t_toOne) then killTimer( t_toOne ) end
		if isTimer(t_toGo) then killTimer( t_toGo ) end
		if isTimer(t_toLaunch) then killTimer( t_toLaunch ) end end )