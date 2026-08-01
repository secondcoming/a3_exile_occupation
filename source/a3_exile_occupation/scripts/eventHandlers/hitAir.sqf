_heli = _this select 0;
if (_heli getVariable ["SC_airDisabled", false]) exitWith {};
_heliDamage = getDammage _heli;
_heliPosition = getPosATL _heli;
_heliHeight = getPosATL _heli select 2;
_crewEjected = _heli getVariable "SC_crewEjected";

_damageLimit 		= 0.2;
_engineDamage 		= false;
_fueltankDamage 	= false;

if(SC_extendedLogging) then 
{
	_logDetail = format ["[OCCUPATION:Sky]:: Air unit %2 hit by %3 at %1 (damage: %4)",time,_this select 0,_this select 1,_heliDamage];
	[_logDetail] call SC_fnc_log;	
};
_ejectChance = round (random 100) + (_heliDamage * 100);


_essentials = [ "HitAvionics","HitEngine1","HitEngine2","HitEngine","HitHRotor","HitVRotor","HitTransmission",
                "HitHydraulics","HitGear","HitHStabilizerL1","HitHStabilizerR1","HitVStabilizer1","HitFuel"];

_damagedEssentials = 0;
{
	if ((_heli getHitPointDamage _x) > 0) then
	{	
		if(_x == "HitFuel" && _heliDamage < 1) then
        {
            _heli setHitPointDamage ["HitFuel", 0]; 
            _heli setFuel 1;      
        };
        _damage = _heli getHitPointDamage _x;
        if(SC_extendedLogging) then 
        {
            _logDetail = format ["[OCCUPATION:Sky]:: Heli %1 checking part %2 (damage: %4) @ %3",_heli, _x, time,_damage]; 
            [_logDetail] call SC_fnc_log;
        };        
		if(_damage > 0) then { _damagedEssentials = _damagedEssentials + 1; };
	};
} forEach _essentials;


if((_heliDamage > 0.2 OR _damagedEssentials > 0) && !_crewEjected && _ejectChance > 100) then
{
	["airEject", _heli, format ["damage=%1 essentials=%2 chance=%3", _heliDamage, _damagedEssentials, _ejectChance]] call SC_fnc_logLifecycle;
	_target = _this select 1;
	[_heli, _target] spawn 
	{
		_veh = _this select 0;
        _group2 = createGroup east;
        if(SC_extendedLogging) then 
        { 
            _heliPosition = getPosATL _veh;
            _logDetail = format ["[OCCUPATION:Sky]:: Air unit %2 ejecting passengers at %3 (time: %1)",time,_veh,_heliPosition]; 
            [_logDetail] call SC_fnc_log;	
        };
        _cargo = assignedCargo _veh;
		{				
            _x joinSilent _group2;
			_x action ["EJECT", _veh];
		} forEach _cargo;
        
        _target = _this select 1;
        _group2 reveal [_target,1.5];

        _destination = getPos _target;
        _group2 allowFleeing 0;
        _wp = _group2 addWaypoint [_destination, 0] ;
        _wp setWaypointFormation "Column";
        _wp setWaypointBehaviour "COMBAT";
        _wp setWaypointCombatMode "RED";
        _wp setWaypointCompletionRadius 1;
        _wp setWaypointType "SAD";
             
        [_group2, _destination, 500] call bis_fnc_taskPatrol;
        _group2 allowFleeing 0;
        _group2 setBehaviour "AWARE";  
        _group2 setCombatMode "RED";	
	};
	_heli setVariable ["SC_crewEjected", true,true];
		
};
	

if(_heliDamage > 0.7 && _damagedEssentials > 0) then
{
	_heli setVariable ["SC_airDisabled", true, true];
	["airForceLand", _heli, format ["damage=%1 essentials=%2", _heliDamage, _damagedEssentials]] call SC_fnc_logLifecycle;
	if(SC_extendedLogging) then 
	{ 
		_logDetail = format ["[OCCUPATION:Sky]:: Air unit %2 damaged and force landing at %3 (time: %1)",time,_this select 0,_this select 1,_heliPosition];
		[_logDetail] call SC_fnc_log;
	};
    
    [_heli, "airForceLanded"] call SC_fnc_vehicleDestroyed;
    _currentHeliPos = getPos _heli;
    _destination = [_currentHeliPos, 1, 150, 10, 0, 20, 0] call BIS_fnc_findSafePos;
	_heli setVehicleLock "UNLOCKED";
	_target = _this select 1;
	_group = group _heli;

    _destination = position _target;

    _heli land "LAND";
    _group2 = createGroup east;
    {
        [(_x select 0)] join _group2;
    } forEach (fullCrew _heli);

	_group2 allowFleeing 0;
	_group2 reveal [_target,2.5];
	_wp = _group2 addWaypoint [_destination, 0] ;
	_wp setWaypointBehaviour "COMBAT";
	_wp setWaypointCombatMode "RED";
	_wp setWaypointCompletionRadius 10;
	//_wp setWaypointType "GETOUT"; 
    _wp setWaypointType "TR Unload";    
    
	[_group2, _destination, 250] call bis_fnc_taskPatrol;
    _group2 setBehaviour "COMBAT";
    _group2 setCombatMode "RED";
};
