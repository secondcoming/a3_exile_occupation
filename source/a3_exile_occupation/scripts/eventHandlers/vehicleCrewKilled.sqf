private _unit = _this select 0;
private _vehicle = _unit getVariable ["SC_linkedVehicle", objNull];
if (isNull _vehicle) exitWith {};

[_unit, _vehicle] spawn
{
	params ["_unit", "_vehicle"];
	sleep 1;

	private _linkedAI = _vehicle getVariable ["SC_linkedAI", []];
	private _aliveLinkedAI = {alive _x} count _linkedAI;
	private _vehicleKind = if (_vehicle isKindOf "Ship") then {"sea"} else {"air"};
	private _killedEvent = format ["%1CrewKilled", _vehicleKind];
	[_killedEvent, _vehicle, format ["unit=%1 linked=%2 aliveLinked=%3", _unit, count _linkedAI, _aliveLinkedAI]] call SC_fnc_logLifecycle;

	if (_aliveLinkedAI > 0) exitWith {};
	if !(_vehicle getVariable ["SC_vehicleSpawnLocationReleased", false]) then
	{
		_vehicle setVariable ["SC_vehicleSpawnLocationReleased", true, true];
		_vehicle setVariable ["SC_assignedDriver", nil, true];
		_vehicle setVehicleLock "UNLOCKED";
		_vehicle lock 1;
		_vehicle setVariable ["ExileIsLocked", 0, true];
		_vehicle setVariable ["ExileIsPersistent", false, true];
		_vehicle setVariable ["SC_claimReady", true, true];
		private _releasedEvent = format ["%1CrewReleased", _vehicleKind];
		[_releasedEvent, _vehicle] call SC_fnc_logLifecycle;
		[_vehicle, _releasedEvent] call SC_fnc_vehicleDestroyed;
	};
};
