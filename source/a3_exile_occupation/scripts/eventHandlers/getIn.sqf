// Triggered if a player gets in a captured AI vehicle
// Marks the vehicle as claimed by a player and frees up a slot to spawn another AI controlled vehicle

_vehicle	= _this select 0;
_unit		= _this select 2;

if(isPlayer _unit) then
{
	["playerGetIn", _vehicle, format ["player=%1", _unit]] call SC_fnc_logLifecycle;
	_group = group _vehicle;
	{
		if(!alive _x) then { _x action ["EJECT", _vehicle]; };     
	}forEach units _group; 

	_vehicle setVariable ["SC_vehicleSpawnLocation", nil,true];
	_vehicle setVariable ["SC_assignedDriver", nil,true];
	_vehicle setVehicleLock "UNLOCKED";
	_vehicle lock 1;
	_vehicle setVariable ["ExileIsLocked", 0, true];
    [_vehicle, "playerClaimed"] call SC_fnc_vehicleDestroyed;

	if(SC_extendedLogging) then 
	{
		_logDetail = format ["[OCCUPATION:claimVehicle]:: Unit %3 has claimed vehicle %2 at %1",time,_vehicle,_unit]; 
		[_logDetail] call SC_fnc_log;
	};
}
else
{
	if(SC_debug) then { { deleteVehicle _x; } forEach attachedObjects _unit; };		
	
	_assignedDriver 	= _vehicle getVariable "SC_assignedDriver";

	if(isNil "_assignedDriver" OR !alive _assignedDriver) then
	{
		_group = group _vehicle;

		// Remove dead units from the group
		{
			if(!alive _x) then { [_x] join grpNull; };     
		}forEach units _group;  
		_groupMembers = units _group;
		_assignedDriver = _groupMembers call BIS_fnc_selectRandom;
		
		_assignedDriver removeAllMPEventHandlers  "mphit";                                          
		_assignedDriver disableAI "TARGET";
		_assignedDriver disableAI "AUTOTARGET";
		_assignedDriver disableAI "AUTOCOMBAT";
		_assignedDriver disableAI "COVER";  
		_assignedDriver disableAI "SUPPRESSION";                   
		_assignedDriver assignAsDriver _vehicle;
		_assignedDriver moveInDriver _vehicle;                
		_assignedDriver setVariable ["SC_drivenVehicle", _vehicle,true]; 
		_driverKilledEH = _assignedDriver getVariable ["SC_driverKilledEH", -1];
		if (_driverKilledEH < 0) then
		{
			_driverKilledEH = _assignedDriver addMPEventHandler ["mpkilled", "_this call SC_fnc_driverKilled;"];
			_assignedDriver setVariable ["SC_driverKilledEH", _driverKilledEH];
		};
		_vehicle setVariable ["SC_assignedDriver", _assignedDriver,true];
		
	};
};
