// Triggered when the designated driver for a vehicle is killed
// Attempts to select a new driver from the same group

if(SC_extendedLogging) then 
{ 
	_logDetail = format ["[OCCUPATION:Vehicle]:: Unit %2 (driver) killed at %1",time,_this select 0]; 
	[_logDetail] call SC_fnc_log;
};

_deadDriver	= _this select 0;
_vehicle = _deadDriver getVariable "SC_drivenVehicle";
if (isNil "_vehicle" || {isNull _vehicle}) exitWith {};
["driverKilled", _vehicle, format ["driver=%1", _deadDriver]] call SC_fnc_logLifecycle;

_vehicle removeAllMPEventHandlers  "mphit";
_vehicle setVariable ["SC_repairStatus",false,true];

if(SC_debug) then
{
    { detach _x; deleteVehicle _x; } forEach attachedObjects _deadDriver;
};

// Select a replacement driver
_group = group _vehicle;

_groupMembers = (units _group) select {alive _x && {!(_x isEqualTo _deadDriver)}};

if(count _groupMembers > 0) then
{
    if(SC_extendedLogging) then 
    { 
        _logDetail = format ["[OCCUPATION:Vehicle]:: vehicle: %1 group: %2 units left:%3",_vehicle,_group,count _groupMembers];
        [_logDetail] call SC_fnc_log; 
    };      
  
    _driver = _groupMembers call BIS_fnc_selectRandom;
    
    _driver assignAsDriver _vehicle;
    _driver setVariable ["SC_drivenVehicle", _vehicle,true];	 
    _vehicle setVariable ["SC_assignedDriver", _driver,true];        
    if ((_vehicle getVariable ["SC_hitLandEH", -1]) < 0) then
    {
        _vehicle setVariable ["SC_hitLandEH", _vehicle addMPEventHandler ["mphit", "_this call SC_fnc_hitLand;"]];
    };
    _driver removeAllMPEventHandlers  "mphit";
    _driverKilledEH = _driver getVariable ["SC_driverKilledEH", -1];
    if (_driverKilledEH < 0) then
    {
        _driverKilledEH = _driver addMPEventHandler ["mpkilled", "_this call SC_fnc_driverKilled;"];
        _driver setVariable ["SC_driverKilledEH", _driverKilledEH];
    };

    if(SC_debug) then
    {
        _tag = createVehicle ["Sign_Arrow_Yellow_F", position _driver, [], 0, "CAN_COLLIDE"];
        _tag attachTo [_driver,[0,0,0.6],"Head"];  
    };

    _driver doMove (position _vehicle);   	
    _driver action ["movetodriver", _vehicle];
    
    if(SC_extendedLogging) then 
    {
        _logDetail = format ["[OCCUPATION:Vehicle]:: Replacement Driver found (%1) for vehicle %2",_driver,_vehicle]; 
        [_logDetail] call SC_fnc_log;
    };

}
else
{
	[_deadDriver, _vehicle] spawn
	{
		params ["_deadDriver", "_vehicle"];
		sleep 1;

		private _groupMembers = (units (group _vehicle)) select {alive _x && {!(_x isEqualTo _deadDriver)}};
		private _aliveCrew = {alive _x && {!(_x isEqualTo _deadDriver)}} count crew _vehicle;
		["driverRecheck", _vehicle, format ["deadDriver=%1 groupAlive=%2 crewAlive=%3", _deadDriver, count _groupMembers, _aliveCrew]] call SC_fnc_logLifecycle;

		if ((count _groupMembers) > 0) exitWith
		{
			private _driver = _groupMembers call BIS_fnc_selectRandom;
			_driver assignAsDriver _vehicle;
			_driver setVariable ["SC_drivenVehicle", _vehicle, true];
			_vehicle setVariable ["SC_assignedDriver", _driver, true];
			if ((_vehicle getVariable ["SC_hitLandEH", -1]) < 0) then
			{
				_vehicle setVariable ["SC_hitLandEH", _vehicle addMPEventHandler ["mphit", "_this call SC_fnc_hitLand;"]];
			};
			_driver removeAllMPEventHandlers "mphit";
			private _driverKilledEH = _driver getVariable ["SC_driverKilledEH", -1];
			if (_driverKilledEH < 0) then
			{
				_driverKilledEH = _driver addMPEventHandler ["mpkilled", "_this call SC_fnc_driverKilled;"];
				_driver setVariable ["SC_driverKilledEH", _driverKilledEH];
			};
			_driver doMove (position _vehicle);
			_driver action ["movetodriver", _vehicle];
			["replacementDriverDelayed", _vehicle, format ["driver=%1", _driver]] call SC_fnc_logLifecycle;
		};

		_logDetail = format ["[OCCUPATION:Vehicle]:: No replacement Driver found for vehicle %1",_vehicle];
		[_logDetail] call SC_fnc_log;
		_vehicle setVariable ["SC_assignedDriver", nil,true];
		_vehicle setVehicleLock "UNLOCKED";
		_vehicle lock 1;
		_vehicle setVariable ["ExileIsLocked", 0, true];
		_vehicle setVariable ["SC_claimReady", true, true];
		[_vehicle, "crewReleased"] call SC_fnc_vehicleDestroyed;
	};
};
