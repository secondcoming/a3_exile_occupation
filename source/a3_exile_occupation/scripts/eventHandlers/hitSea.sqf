_boat = _this select 0;

_boatDamage 		= damage _boat;
_boatPosition 		= getPosATL _boat;
_boatHeight 		= getPosATL _boat select 2;
_crewEjected 		= _boat getVariable "SC_crewEjected";

_damageLimit 		= 0.2;
_engineDamage 		= false;
_fueltankDamage 	= false;

if(SC_extendedLogging) then 
{
	_logDetail = format ["[OCCUPATION:Sea]:: Sea unit %2 hit by %3 at %1 (damage: %4)",time,_this select 0,_this select 1,_boatDamage];
	[_logDetail] call SC_fnc_log;	
};
_ejectChance = round (random 100) + (_boatDamage * 100);

_essentials = ["HitBody","HitEngine","HitTurret","HitGun","HitFuel"];
_damagedEssentials = 0;
{
	if ((_boat getHitPointDamage _x) > 0) then
	{	
		if(_x == "HitFuel" && _boatDamage < 1) then
        {
            _boat setHitPointDamage ["HitFuel", 0]; 
            _boat setFuel 1;      
        };
        _damage = _boat getHitPointDamage _x;
        if(SC_extendedLogging) then 
        {
            _logDetail = format ["[OCCUPATION:Sea]:: Boat %1 checking part %2 (damage: %4) @ %3",_boat, _x, time,_damage]; 
            [_logDetail] call SC_fnc_log;
        };        
		if(_damage > 0) then { _damagedEssentials = _damagedEssentials + 1; };
	};
} forEach _essentials;


if(_boatDamage > 0.2 && _damagedEssentials > 0 && !_crewEjected && _ejectChance > 100) then
{
	["seaEject", _boat, format ["damage=%1 essentials=%2 chance=%3", _boatDamage, _damagedEssentials, _ejectChance]] call SC_fnc_logLifecycle;
	_target = _this select 1;
	[_boat, _target] spawn 
	{
		_veh = _this select 0;
        _group2 = createGroup east;
        if(SC_extendedLogging) then 
        { 
            _boatPosition = getPosATL _veh;
            _logDetail = format ["[OCCUPATION:Sky]:: Sea unit %2 ejecting passengers at %3 (time: %1)",time,_veh,_boatPosition]; 
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
	_boat setVariable ["SC_crewEjected", true,true];
};
