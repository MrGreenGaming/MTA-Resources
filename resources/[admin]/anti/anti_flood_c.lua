keyTable = { "mouse1", "mouse2", "mouse3", "mouse4", "mouse5", "mouse_wheel_up", "mouse_wheel_down", "arrow_l", "arrow_u",
 "arrow_r", "arrow_d", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k",
 "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "num_0", "num_1", "num_2", "num_3", "num_4", "num_5",
 "num_6", "num_7", "num_8", "num_9", "num_mul", "num_add", "num_sep", "num_sub", "num_div", "num_dec", "F1", "F2", "F3", "F4", "F5",
 "F6", "F7", "F8", "F9", "F10", "F11", "F12", "backspace", "tab", "lalt", "ralt", "enter", "space", "pgup", "pgdn", "end", "home",
 "insert", "delete", "lshift", "rshift", "lctrl", "rctrl", "[", "]", "pause", "capslock", "scroll", ";", ",", "-", ".", "/", "#", "\\", "=" }
 
local saybinds = {}
-- addCommandHandler ( 'tests', function (c )
setTimer(function()
	local send = false
	for _, key in ipairs ( keyTable ) do
		local binds = getCommandsBoundToKey ( key, 'down' )
		for command, args in pairs (binds) do
			if (command == 'say' or command == 'me') and (not table.contains(saybinds, args)) then
				send = true
				table.insert(saybinds, args)
			end
		end
		
		local binds = getCommandsBoundToKey ( key, 'up' )
		for command, args in pairs (binds) do
			if (command == 'say' or command == 'me') and (not table.contains(saybinds, args)) then
				send = true
				table.insert(saybinds, args)
			end
		end
	end
	
	if (send) then
		-- for k, v in ipairs(saybinds) do
			-- outputDebugString(k .. '. ' .. tostring(v))
		-- end
		triggerServerEvent('saybinds', resourceRoot, saybinds)
	end
end, 500, 0)
-- end)


function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end