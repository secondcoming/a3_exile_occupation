if !(missionNamespace getVariable ["SC_lifecycleDiagnostics", false]) exitWith {};

params ["_event", ["_vehicle", objNull], ["_detail", ""]];

private _vehicleType = if (isNull _vehicle) then {"null"} else {typeOf _vehicle};
private _vehicleNetId = if (isNull _vehicle) then {""} else {netId _vehicle};
private _vehicleGroup = if (isNull _vehicle) then {grpNull} else {group _vehicle};
private _crew = if (isNull _vehicle) then {[]} else {crew _vehicle};
private _aliveCrew = {alive _x} count _crew;
private _spawnTracked = if (isNull _vehicle) then {false} else {!isNil {_vehicle getVariable "SC_vehicleSpawnLocation"}};
private _lock = if (isNull _vehicle) then {-1} else {locked _vehicle};
private _exileLock = if (isNull _vehicle) then {-1} else {_vehicle getVariable ["ExileIsLocked", -1]};

diag_log format [
    "[SC_DIAG_OCC_LIFECYCLE:%1] type=%2 netId=%3 local=%4 owner=%5 alive=%6 damage=%7 group=%8 groupLocal=%9 groupOwner=%10 crew=%11 aliveCrew=%12 tracked=%13 lock=%14 exileLock=%15 claimReady=%16 arrays=[land:%17,air:%18,sea:%19] detail=%20 time=%21",
    _event,
    _vehicleType,
    _vehicleNetId,
    if (isNull _vehicle) then {false} else {local _vehicle},
    if (isNull _vehicle) then {-1} else {owner _vehicle},
    if (isNull _vehicle) then {false} else {alive _vehicle},
    if (isNull _vehicle) then {-1} else {damage _vehicle},
    _vehicleGroup,
    if (isNull _vehicleGroup) then {false} else {local _vehicleGroup},
    if (isNull _vehicleGroup) then {-1} else {groupOwner _vehicleGroup},
    count _crew,
    _aliveCrew,
    _spawnTracked,
    _lock,
    _exileLock,
    if (isNull _vehicle) then {false} else {_vehicle getVariable ["SC_claimReady", true]},
    count (missionNamespace getVariable ["SC_liveVehiclesArray", []]),
    count (missionNamespace getVariable ["SC_liveHelisArray", []]),
    count (missionNamespace getVariable ["SC_liveBoatsArray", []]),
    _detail,
    time
];
