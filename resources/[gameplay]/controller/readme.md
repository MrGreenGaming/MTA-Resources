# Controller Resource
## By Nick_026

The idea of this resource is to allow scripters to easily create controller bindings for their scripts.

### How to use

This resource exports a few functions, using these you can bind/unbind keys

#### Syntax bindControllerKey (Client)
```
void bindControllerKey(string key, string onPress, string onRelease, [var arguments, ...])
```
Binds a controller key to execute an event when pressed or released. Optionally you can pass arguments to the event.

##### Required arguments
- key: The key to bind to (see [keys](./keys.lua) for a list of keys)

##### Optional arguments
- onPress: The event to call when the key is pressed
- onRelease: The event to call when the key is released
- arguments: Any arguments to pass to the event

> Either onPress or onRelease must be provided (or both)

##### Example:
```lua
addEvent("onPress")
addEventHandler("onPress", root, function(key, arg1, arg2)
    -- PRESSED
    -- key = "cross"
    -- arg1 = "hello"
    -- arg2 = "world"
end)

addEvent("onRelease")
addEventHandler("onRelease", root, function(key, arg1, arg2)
    -- RELEASED
end)

-- From other resource
exports.controller:bindControllerKey("cross", "onPress", "onRelease", "hello", "world")

-- From controller resource
bindControllerKey("cross", "onPress", "onRelease", "hello", "world")
```


#### syntax unbindControllerKey (Client)
```
void unbindControllerKey(string key, string onPress, string onRelease)
```
Unbinds a controller key from an events specified. Keys are automatically unbound if the resource where the key was bound to is stopped.

> (For example, if from "votemanager" resource you bind a key, when votemanager is stopped, the key will be unbound automatically)

##### Required arguments
- key: The key to unbind from (see [keys](./keys.lua) for a list of keys)

##### Optional arguments
- onPress: The event to unbind from when the key is pressed
- onRelease: The event to unbind from when the key is released

> Either onPress or onRelease must be provided (or both)

#### Example: (followed on bindControllerKey example)
```lua
-- From other resource
exports.controller:unbindControllerKey("cross", "onPress", "onRelease")

-- From controller resource
unbindControllerKey("cross", "onPress", "onRelease")
```


### Helpful client functions

#### syntax getKey (Client)
```
string getKey(string key)
```
Returns the bind name of the key passed.

Example:
```lua
local key = getKey("cross")
local key = exports.controller:getKey("cross")
-- key = "joy1" for XBOX
-- key = "joy2" for PlayStation
```

#### syntax getLabel (Client)
```
string getLabel(string key)
```
Returns readable key name of the key passed.

Example:
```lua
local key = getLabel("cross")
local key = exports.controller:getLabel("cross")
-- key = "A" for XBOX
-- key = "X" for PlayStation
```

### Helpful server functions

#### syntax getControllerForPlayer (Server)
```
string getControllerForPlayer(Player player)
```
Returns the controller type of the player passed.

Example:
```lua
local controller = getControllerForPlayer(player)
local controller = exports.controller:getControllerForPlayer(player)
-- controller = "XBOX" for XBOX
-- controller = "PlayStation" for PlayStation
```

#### syntax getKeyForPlayer (Server)
```
string getKeyForPlayer(Player player, string key)
```
Returns the bind name of the key passed for the player passed.

Example:
```lua
local key = getKeyForPlayer(player, "cross")
local key = exports.controller:getKeyForPlayer(player, "cross")
-- key = "joy1" for XBOX
-- key = "joy2" for PlayStation
```

#### syntax getLabelForPlayer (Server)
```
string getLabelForPlayer(Player player, string key)
```
Returns readable key name of the key passed for the player passed.

Example:
```lua
local key = getLabelForPlayer(player, "cross")
local key = exports.controller:getLabelForPlayer(player, "cross")
-- key = "A" for XBOX
-- key = "X" for PlayStation
```
