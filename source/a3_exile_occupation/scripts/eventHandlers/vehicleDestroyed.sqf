_vehicle = _this select 0;
private _reason = "destroyed";
if ((count _this) > 1 && {(_this select 1) isEqualType ""}) then
{
	_reason = _this select 1;
};
[_reason + "Before", _vehicle] call SC_fnc_logLifecycle;
_vehicle setVariable ["SC_vehicleSpawnLocation", nil,true];
if((damage _vehicle) < 1) then
{
	_vehicle removeAllMPEventHandlers  "mphit";
};

SC_liveVehiclesArray = SC_liveVehiclesArray - [_vehicle];
SC_liveHelisArray = SC_liveHelisArray - [_vehicle];
SC_liveBoatsArray = SC_liveBoatsArray - [_vehicle];
SC_liveVehicles = count SC_liveVehiclesArray;
SC_liveHelis = count SC_liveHelisArray;
SC_liveBoats = count SC_liveBoatsArray;

[_reason + "After", _vehicle] call SC_fnc_logLifecycle;
