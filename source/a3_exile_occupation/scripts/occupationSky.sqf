if (!isServer) exitWith {};

_logDetail = format['[OCCUPATION:Sky] Started'];
[_logDetail] call SC_fnc_log;

// more than _scaleAI players on the server and the max AI count drops per additional player
_currentPlayerCount = count playableUnits;
_maxAIcount 		= SC_maxAIcount;
_side				= "bandit";

if(_currentPlayerCount > SC_scaleAI) then 
{
	_maxAIcount = _maxAIcount - (_currentPlayerCount - SC_scaleAI) ;
};

// Don't spawn additional AI if the server fps is below _minFPS
if(diag_fps < SC_minFPS) exitWith 
{ 
    _logDetail = format ["[OCCUPATION:Sky]:: Held off spawning more AI as the server FPS is only %1",diag_fps]; 
    [_logDetail] call SC_fnc_log; 
};

_aiActive = { !isPlayer _x } count allunits;
if((_aiActive >= _maxAIcount) && !SC_occupySkyVehicleIgnoreCount) exitWith
{
    _logDetail = format ["[OCCUPATION:Sky]:: %1 active AI, so not spawning AI this time",_aiActive];
    [_logDetail] call SC_fnc_log;
};

SC_liveHelis = count(SC_liveHelisArray);

if(SC_liveHelis >= SC_maxNumberofHelis) exitWith 
{
    if(SC_extendedLogging) then 
    { 
        _logDetail = format['[OCCUPATION:Sky] End check %1 currently active (max %2) @ %3',SC_liveHelis,SC_maxNumberofHelis,time]; 
        [_logDetail] call SC_fnc_log;
    };    
};

_vehiclesToSpawn = (SC_maxNumberofHelis - SC_liveHelis);
_middle = worldSize/2;
_spawnCenter = [_middle,_middle,0];
_maxDistance = _middle;

_locations = (nearestLocations [_spawnCenter, ["NameVillage","NameCity", "NameCityCapital"], _maxDistance]);
_i = 0;
{
	_okToUse = true;
	_pos = position _x;	
	_nearestMarker = [allMapMarkers, _pos] call BIS_fnc_nearestPosition; // Nearest Marker to the Location		
	_posNearestMarker = getMarkerPos _nearestMarker;
	if(_pos distance _posNearestMarker < 2500) exitwith { _okToUse = false; };

	if(!_okToUse) then
	{
		_locations deleteAt _i;
	};
	_i = _i + 1;
	sleep 0.2;

} forEach _locations;



for "_i" from 1 to _vehiclesToSpawn do
{
	if (!SC_occupySkyVehicleIgnoreCount && {({ !isPlayer _x } count allUnits) >= _maxAIcount}) exitWith {};
	if (_vehiclesToSpawn > 0) then
	{
		private["_group"];
		_height = 350 + (round (random 200));
		_locationArray = SC_occupyHeliFixedPositions;
		
		// Select the spawn position
		_spawnLocation = [0,0,0];
		_radius = 2000;
		if(SC_occupyHeliUseFixedPos) then
		{
			{
				_vehLocation = _x getVariable "SC_vehicleSpawnLocation";		
				_locationArray = _locationArray - _vehLocation;				
			}forEach SC_liveHelisArray;
			
			if(count _locationArray > 0)  then
			{
				_randomLocation = _locationArray call BIS_fnc_selectRandom;
				diag_log format["_randomLocation: %1",_randomLocation];
				_tempLocation = _randomLocation select 0;
				_spawnLocation = [_tempLocation select 0, _tempLocation select 1, _tempLocation select 2];
				_radius = _randomLocation select 1;
			}
			else
			{
				_Location = _locations call BIS_fnc_selectRandom;
				_pos = position _Location;	
				_position = [_pos select 0, _pos select 1, 300];
				_safePos = [_position,10,100,5,0,20,0] call BIS_fnc_findSafePos;
				_spawnLocation = [_safePos select 0, _safePos select 1, _height];
				_spawnLocation = [_safePos select 0, _safePos select 1, _height];
				_radius = 2000;
			};
		}
		else
		{
			_Location = _locations call BIS_fnc_selectRandom;
			_pos = position _Location;	
			_position = [_pos select 0, _pos select 1, 300];
			_safePos = [_position,10,100,5,0,20,0] call BIS_fnc_findSafePos;
			_spawnLocation = [_safePos select 0, _safePos select 1, _height];
			_spawnLocation = [_safePos select 0, _safePos select 1, _height];
			_radius = 2000;
		};

		diag_log format["[OCCUPATION:Sky] found position %1",_spawnLocation];
		_group = createGroup SC_BanditSide;
		_group setVariable ["DMS_AllowFreezing",false];
		[_group,false] call DMS_fnc_FreezeToggle;
		_group setVariable ["DMS_LockLocality",true];
		_group setVariable ["DMS_SpawnedGroup",true];
		_group setVariable ["DMS_Group_Side", SC_BanditSide];
		_group setVariable ["Vcm_Disable",true,true];
	  
		_availableVehicleClasses = SC_HeliClassToUse select
		{
			private _candidate = _x;
			private _allowedCount = _candidate select 1;
			private _currentCount = { typeOf _x == (_candidate select 0) } count SC_liveHelisArray;
			_allowedCount == 0 OR _currentCount < _allowedCount
		};
		if(_availableVehicleClasses isEqualTo []) then
		{
			["spawnPoolExhausted", objNull, format ["branch=air pool=%1", count SC_HeliClassToUse]] call SC_fnc_logLifecycle;
			deleteGroup _group;
			continue;
		};
		_VehicleClass = selectRandom _availableVehicleClasses;
		_VehicleClassToUse = _VehicleClass select 0;
		["spawnPoolSelected", objNull, format ["branch=air class=%1 available=%2", _VehicleClassToUse, count _availableVehicleClasses]] call SC_fnc_logLifecycle;
		
		_vehicle = createVehicle [_VehicleClassToUse, _spawnLocation, [], 0, "NONE"];
		
		if(!isNull _vehicle) then
		{	
			_group addVehicle _vehicle;
			_vehicle setVariable["vehPos",_spawnLocation,true];
			_vehicle setVariable["vehClass",_VehicleClassToUse,true];
			_SC_vehicleSpawnLocation = [_spawnLocation,_radius,worldName];
			diag_log format ["[occupationSky] _SC_vehicleSpawnLocation: %1",_SC_vehicleSpawnLocation];
			_vehicle setVariable ["SC_vehicleSpawnLocation", _SC_vehicleSpawnLocation,true];

			SC_liveHelis = SC_liveHelis + 1;
			SC_liveHelisArray pushBackUnique _vehicle;

			_vehicle setVehiclePosition [_spawnLocation, [], 0, "FLY"];
			_vehicle setVariable ["vehicleID", _spawnLocation, true];  
			_vehicle setFuel 1;
			_vehicle setDamage 0;
			_vehicle engineOn true;
			_vehicle flyInHeight 150;
			_vehicle lock 0;			
			_vehicle setVehicleLock "UNLOCKED";
			_vehicle setVariable ["ExileIsLocked", 0, true];
			_vehicle setVariable ["ExileIsPersistent", false];
			_vehicle setVariable ["SC_claimReady", false, true];
			["airSpawn", _vehicle, format ["class=%1 spawn=%2 radius=%3", _VehicleClassToUse, _spawnLocation, _radius]] call SC_fnc_logLifecycle;
			_vehicle action ["LightOn", _vehicle];
				
			// Calculate the number of seats in the vehicle and fill the required amount
			_crewRequired = SC_minimumCrewAmount;
			if(SC_maximumCrewAmount > SC_minimumCrewAmount) then 
			{ 
				_crewRequired = floor(random[SC_minimumCrewAmount,SC_maximumCrewAmount-SC_minimumCrewAmount,SC_maximumCrewAmount]); 
			};
			if (!SC_occupySkyVehicleIgnoreCount) then
			{
				_crewRequired = _crewRequired min ((_maxAIcount - ({ !isPlayer _x } count allUnits)) max 0);
			};
			_amountOfCrew = 0;
			_unitPlaced = false;
			_vehicleRoles = (typeOf _vehicle) call bis_fnc_vehicleRoles;
			{
				_unitPlaced = false;
				_vehicleRole = _x select 0;
				_vehicleSeat = _x select 1;
				if(_vehicleRole == "Driver") then
				{
					_loadOut = ["bandit"] call SC_fnc_selectGear;
					_unit = [_group,_spawnLocation,"custom","random","bandit","Vehicle",_loadOut] call DMS_fnc_SpawnAISoldier; 
					_amountOfCrew = _amountOfCrew + 1;  
					_unit assignAsDriver _vehicle;
					_unit moveInDriver _vehicle;
					//_vehicle lockDriver true;
					removeBackpackGlobal _unit;
					_unit addBackpackGlobal "B_Parachute";
					_unitPlaced = true;
				};
				if(_vehicleRole == "Turret") then
				{
					_loadOut = ["bandit"] call SC_fnc_selectGear;
					_unit = [_group,_spawnLocation,"custom","random","bandit","Vehicle",_loadOut] call DMS_fnc_SpawnAISoldier;  
					_amountOfCrew = _amountOfCrew + 1; 
					_unit moveInTurret [_vehicle, _vehicleSeat];
					removeBackpackGlobal _unit;
					_unit addBackpackGlobal "B_Parachute";
					_unitPlaced = true;
				};
				if(_vehicleRole == "CARGO" && _amountOfCrew < _crewRequired) then
				{
					_loadOut = ["bandit"] call SC_fnc_selectGear;
					_unit = [_group,_spawnLocation,"custom","random","bandit","Vehicle",_loadOut] call DMS_fnc_SpawnAISoldier;   
					_amountOfCrew = _amountOfCrew + 1;
					_unit assignAsCargo _vehicle; 
					_unit moveInCargo _vehicle;
					removeBackpackGlobal _unit;
					_unit addBackpackGlobal "B_Parachute";
					_unitPlaced = true;
				};  
				if(SC_extendedLogging) then 
				{ 
					_logDetail = format['[OCCUPATION:Sky] %1 added to %2',_vehicleRole,_vehicle]; 
					[_logDetail] call SC_fnc_log;
				};                    
			} forEach _vehicleRoles;

			{	
				_unit = _x;
				_unitName = ["bandit"] call SC_fnc_selectName;
				if(!isNil "_unitName") then { _unit setName _unitName; }; 
				[_unit] joinSilent grpNull;
				[_unit] joinSilent _group;
			}foreach units _group;

			private _linkedAI = units _group;
			_vehicle setVariable ["SC_linkedAI", _linkedAI, true];
			_vehicle setVariable ["SC_vehicleSpawnLocationReleased", false, true];
			{
				_x setVariable ["SC_linkedVehicle", _vehicle, true];
				_x addMPEventHandler ["mpkilled", "_this call SC_fnc_vehicleCrewKilled;"];
			} forEach _linkedAI;

			if(SC_extendedLogging && _unitPlaced) then 
			{ 
				_logDetail = format['[OCCUPATION:Sky] %1 spawned @ %2',_VehicleClassToUse,_spawnLocation];	
				[_logDetail] call SC_fnc_log;
			};
			[_vehicle] call SC_fnc_fillVehicleCargo;

			
			[_group, _spawnLocation, _radius] call bis_fnc_taskPatrol;
			_group setBehaviour "AWARE";
			_group setCombatMode "RED";
			_vehicle addEventHandler ["getin", "_this call SC_fnc_getIn;"];
			_vehicle addMPEventHandler ["mpkilled", "_this call SC_fnc_vehicleDestroyed;"];
			_hitAirEH = _vehicle addMPEventHandler ["mphit", "_this call SC_fnc_hitAir;"];
			_vehicle setVariable ["SC_hitAirEH", _hitAirEH];
			["airHitHandlerReady", _vehicle, format ["handler=%1", _hitAirEH]] call SC_fnc_logLifecycle;
			_vehicle setVariable ["SC_crewEjected", false,true];	
			sleep 0.2;		
		}
		else
		{
			_logDetail = format['[OCCUPATION:Sky] aircraft %1 failed to spawn (check classname is correct)',_VehicleClassToUse]; 
			[_logDetail] call SC_fnc_log; 		
		};
		
	};
	
};


_logDetail = format['[OCCUPATION:Sky] Running'];
[_logDetail] call SC_fnc_log;
