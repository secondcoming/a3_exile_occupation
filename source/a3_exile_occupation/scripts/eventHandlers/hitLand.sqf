// Triggered when a ground vehicle takes damage
// Attempts to get the current vehicle driver to repair the vehicle

_vehicle 		= _this select 0;
_repairStatus 	= _vehicle getVariable ["SC_repairStatus", false];

if(SC_extendedLogging) then
{
	_logDetail = format ["[OCCUPATION:repairVehicle]:: Vehicle %1 _repairStatus %2",_vehicle, _repairStatus];
	[_logDetail] call SC_fnc_log;
};

if(_repairStatus) exitWith
{
	_debounceCount = (_vehicle getVariable ["SC_repairDebounceCount", 0]) + 1;
	_vehicle setVariable ["SC_repairDebounceCount", _debounceCount];
	if(SC_lifecycleDiagnostics && {_debounceCount mod 25 == 0}) then
	{
		["landRepairDebounced", _vehicle, format ["hits=%1", _debounceCount]] call SC_fnc_logLifecycle;
	};
};

// Mark the vehicle as currently being repaired
_vehicle setVariable ["SC_repairStatus",true,true];
_vehicle setVariable ["SC_repairDebounceCount", 0];

if(SC_extendedLogging) then
{
	_logDetail = format ["[OCCUPATION:repairVehicle]:: Starting repair check Vehicle %1 _repairStatus %2",_vehicle, _repairStatus];
	[_logDetail] call SC_fnc_log;
};

_vehicleDamage 		= damage _vehicle;
_damagedWheels 		= 0;
_damageLimit 		= 0.2;
_engineDamage 		= false;
_fueltankDamage 	= false;
_wheelDamage 	    = false;
_assignedDriver 	= _vehicle getVariable "SC_assignedDriver";

_group = group _vehicle;

// Remove dead units from the group
{
	if(!alive _x) then { [_x] join grpNull; };     
}forEach units _group; 

if(count(units _group) == 0) exitWith { [_vehicle]  call SC_fnc_vehicleDestroyed; };

if(isNil "_assignedDriver") then
{
 
    _groupMembers = units _group;
    _assignedDriver = _groupMembers call BIS_fnc_selectRandom;
 
	_logDetail = format ["[OCCUPATION:repairVehicle]:: Selected replacement driver for %1 _repairStatus %2",_vehicle, _assignedDriver]; 
	[_logDetail] call SC_fnc_log;
 
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


if(!alive _assignedDriver) exitWith 
{ 
    [_assignedDriver] call SC_fnc_driverKilled; 
};

_wheels = ["HitLFWheel","HitLF2Wheel","HitRFWheel","HitRF2Wheel","HitLBWheel","HitLMWheel","HitRBWheel","HitRMWheel"]; 
{
	if ((_vehicle getHitPointDamage _x) > 0) then
	{	
		_partDamage = _vehicle getHitPointDamage _x;
        if(SC_extendedLogging) then 
        {
            _logDetail = format ["[OCCUPATION:repairVehicle]:: Vehicle %1 checking wheel %2 (damage: %4) @ %3",_vehicle, _x, time,_partDamage]; 
            [_logDetail] call SC_fnc_log;
        };        
		if(_partDamage == 1) then { _wheelDamage = true; };
	};
} forEach _wheels;

// Check Engine
if ((_vehicle getHitPointDamage "HitEngine") == 1) then { _engineDamage = true; };

// Check Fuel Tank
if ((_vehicle getHitPointDamage "HitFuel") > 0) then { _fueltankDamage = true; };


if(_wheelDamage OR _engineDamage OR _fueltankDamage) then
{
	["landRepairStart", _vehicle, format ["damage=%1 wheel=%2 engine=%3 fuel=%4", _vehicleDamage, _wheelDamage, _engineDamage, _fueltankDamage]] call SC_fnc_logLifecycle;

	[_vehicle,_assignedDriver ] spawn 
	{
		_vehicle  = _this select 0;
        _driver = _this select 1;
		_vehicle setVariable ["SC_repairStatus",true,true];
		_repairStatus = _vehicle getVariable "SC_repairStatus";
		_logDetail = format ["[OCCUPATION:repairVehicle]:: Unit %2 repairing(%3) vehicle at %1",time,_driver,_repairStatus]; 
		[_logDetail] call SC_fnc_log;
        
        _vehicle forceSpeed 0;
        sleep 0.2;    
        _group = group _vehicle;
      
        _driver disableAI "MOVE";  
        _driver disableAI "TARGET";
        _driver disableAI "AUTOTARGET";
        _driver disableAI "AUTOCOMBAT";
        _driver disableAI "COVER";  
        _driver disableAI "SUPPRESSION";    
        _driver disableAI "FSM";    
        sleep 0.3;
        _driver action ["getOut", _vehicle];
        _driver doMove (position _vehicle);
        sleep 0.3;    	        
		_driverDir = _driver getDir _vehicle;
        _driver setDir _driverDir;
        _driver setUnitPos "MIDDLE";  	
		sleep 0.1;
		_driver playMoveNow "Acts_carFixingWheel";
		sleep 4;      
		_driver switchMove "";
		if(alive _driver) then
		{
			_vehicle setDamage 0;
			_driver playMoveNow "Acts_carFixingWheel";
			sleep 2;
            _driver switchMove "";
            _driver assignAsDriver _vehicle;
            _driver moveInDriver _vehicle;
            _driver action ["movetodriver", _vehicle];	
            _logDetail = format ["[OCCUPATION:repairVehicle]:: Unit %2 finished repairing vehicle %3 at %1",time,_driver,_vehicle]; 
            [_logDetail] call SC_fnc_log;			
		};
        _wp = _group addWaypoint [position _vehicle, 0] ;
        _wp setWaypointFormation "Column";
        _wp setWaypointCompletionRadius 1;
        _wp setWaypointType "GETIN";		
        sleep 5;
		_tempLocation = _vehicle getVariable "SC_vehicleSpawnLocation";
		if(!isNil "_tempLocation") then
		{
			_originalSpawnLocation = _tempLocation select 0;
			_radius = _tempLocation select 1;		
			[_group, _originalSpawnLocation, _radius] call bis_fnc_taskPatrol;
		};
		_driver action ["movetodriver", _vehicle];	
		_group setBehaviour "SAFE";
		_group setCombatMode "RED";
		_driver enableAI "MOVE";    
		_driver enableAI "FSM";	
		// Mark the vehicle as not currently being repaired and reapply the mphit eventhandler
		_vehicle setVariable ["SC_repairStatus",false,true];
		["landRepairFinished", _vehicle, format ["driverAlive=%1 damage=%2", alive _driver, damage _vehicle]] call SC_fnc_logLifecycle;
	};
	
}
else
{
	// Mark the vehicle as not currently being repaired
	_vehicle setVariable ["SC_repairStatus",false,true];	
	if(SC_extendedLogging) then
	{
		_logDetail = format ["[OCCUPATION:repairVehicle]:: Not enough damage to disable %2, driver is %3 at %1",time,_vehicle,_assignedDriver];
		[_logDetail] call SC_fnc_log;
	};
	if(SC_lifecycleDiagnostics) then
	{
		_skippedCount = (_vehicle getVariable ["SC_repairSkippedCount", 0]) + 1;
		_lastSkippedLog = _vehicle getVariable ["SC_lastRepairSkippedLog", -5];
		_vehicle setVariable ["SC_repairSkippedCount", _skippedCount];
		if((time - _lastSkippedLog) >= 5) then
		{
			["landRepairSkipped", _vehicle, format ["damage=%1 events=%2", _vehicleDamage, _skippedCount]] call SC_fnc_logLifecycle;
			_vehicle setVariable ["SC_repairSkippedCount", 0];
			_vehicle setVariable ["SC_lastRepairSkippedLog", time];
		};
	};
};
_repairStatus 	= _vehicle getVariable "SC_repairStatus";
if(SC_extendedLogging) then
{
	_logDetail = format ["[OCCUPATION:repairVehicle]:: Finished mphit eventhandler for Vehicle %1 _repairStatus %2",_vehicle, _repairStatus];
	[_logDetail] call SC_fnc_log;
};
