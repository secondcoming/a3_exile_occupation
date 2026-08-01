if (!isServer) exitWith {};

_logDetail = format['[OCCUPATION:Vehicle] Started'];
[_logDetail] call SC_fnc_log;

// set the default side for bandit AI
_side               = "bandit";

// more than _scaleAI players on the server and the max AI count drops per additional player
_currentPlayerCount = count playableUnits;
_maxAIcount 		= SC_maxAIcount;

if(_currentPlayerCount > SC_scaleAI) then
{
	_maxAIcount = _maxAIcount - (_currentPlayerCount - SC_scaleAI) ;
};

// Don't spawn additional AI if the server fps is below _minFPS
if(diag_fps < SC_minFPS) exitWith
{
    _logDetail = format ["[OCCUPATION:Vehicle]:: Held off spawning more AI as the server FPS is only %1",diag_fps];
    [_logDetail] call SC_fnc_log;
};
_aiActive = { !isPlayer _x } count allunits;
if((_aiActive >= _maxAIcount) && !SC_occupyLandVehicleIgnoreCount) exitWith
{
    _logDetail = format ["[OCCUPATION:Vehicle]:: %1 active AI, so not spawning AI this time",_aiActive];
    [_logDetail] call SC_fnc_log;
};

SC_liveVehicles = count(SC_liveVehiclesArray);

if(SC_liveVehicles >= SC_maxNumberofVehicles) exitWith
{
    _logDetail = format['[OCCUPATION:Vehicle] End check %1 currently active (max %2) @ %3',SC_liveVehicles,SC_maxNumberofVehicles,time];
    [_logDetail] call SC_fnc_log;
};

_vehiclesToSpawn = (SC_maxNumberofVehicles - SC_liveVehicles);
_middle = worldSize/2;
_spawnCenter = [_middle,_middle,0];
_maxDistance = _middle;

if(_vehiclesToSpawn > 0) then
{
    if(SC_occupyVehicleSurvivors) then
    {
        // decide which side to spawn
        _sideToSpawn = random 100;
        if(_sideToSpawn <= SC_SurvivorsChance) then
        {
            _side = "survivor";
        };
    };

	_useLaunchers = DMS_ai_use_launchers;
	for "_i" from 1 to _vehiclesToSpawn do
	{
		if (!SC_occupyLandVehicleIgnoreCount && {({ !isPlayer _x } count allUnits) >= _maxAIcount}) exitWith {};
		if (_vehiclesToSpawn > 0) then
		{
			private["_group"];

			_locationArray = SC_occupyVehicleFixedPositions;

			// Select the spawn position
			_spawnLocation = [0,0,0];
			_radius = 2000;
			if(SC_occupyVehicleUseFixedPos) then
			{
				{
					_vehLocation = _x getVariable "SC_vehicleSpawnLocation";
					_locationArray = _locationArray - [_vehLocation];
				}forEach SC_liveVehiclesArray;

				if(count _locationArray > 0)  then
				{
					_randomLocation = _locationArray call BIS_fnc_selectRandom;
					_spawnLocation = _randomLocation select 0;
					_radius = _randomLocation select 1;
					_locationArray = _locationArray - [_randomLocation];
				}
				else
				{
					_spawnLocation = [ true, false ] call SC_fnc_findsafePos;
					_radius = 2000;
				};
			}
			else
			{
				_spawnLocation = [ true, false ] call SC_fnc_findsafePos;
				_radius = 2000;
			};
			if(_spawnLocation isEqualTo []) then
			{
				["safePosSpawnSkipped", objNull, "branch=land"] call SC_fnc_logLifecycle;
				continue;
			};

			diag_log format["[OCCUPATION:Vehicle] found position %1",_spawnLocation];
			_group = createGroup SC_BanditSide;
			if(_side == "survivor") then
			{
				deleteGroup _group;
				_group = createGroup SC_SurvivorSide;
			};
			_group setVariable ["DMS_AllowFreezing",false];
			_group setVariable ["DMS_LockLocality",true];
			_group setVariable ["DMS_SpawnedGroup",true];
			_group setVariable ["DMS_Group_Side", _side];
			_group setVariable ["Vcm_Disable",true,true];

			// Percentage chance to spawn a rare vehicle
			_rareChance = round (random 100);
			_vehiclePool = if (_rareChance >= 90) then
			{
				if (_side == "survivor") then { SC_SurvivorVehicleClassToUseRare } else { SC_VehicleClassToUseRare };
			}
			else
			{
				if (_side == "survivor") then { SC_SurvivorVehicleClassToUse } else { SC_VehicleClassToUse };
			};
			_availableVehicleClasses = _vehiclePool select
			{
				private _candidate = _x;
				private _allowedCount = _candidate select 1;
				private _currentCount = { typeOf _x == (_candidate select 0) } count SC_liveVehiclesArray;
				_allowedCount == 0 OR _currentCount < _allowedCount
			};
			if(_availableVehicleClasses isEqualTo []) then
			{
				["spawnPoolExhausted", objNull, format ["branch=land side=%1 rare=%2 pool=%3", _side, _rareChance >= 90, count _vehiclePool]] call SC_fnc_logLifecycle;
				deleteGroup _group;
				continue;
			};
			_VehicleClass = selectRandom _availableVehicleClasses;
			_VehicleClassToUse = _VehicleClass select 0;
			["spawnPoolSelected", objNull, format ["branch=land class=%1 available=%2", _VehicleClassToUse, count _availableVehicleClasses]] call SC_fnc_logLifecycle;


			_vehicle = createVehicle [_VehicleClassToUse, _spawnLocation, [], 0, "NONE"];

			if(!isNull _vehicle) then
			{
				_group addVehicle _vehicle;

				SC_liveVehiclesArray pushBackUnique _vehicle;

				_vehicle setVariable ["SC_repairStatus",false,true];
				_vehicle setVariable ["vehPos",_spawnLocation,true];
				_vehicle setVariable ["vehClass",_VehicleClassToUse,true];
				_SC_vehicleSpawnLocation = [_spawnLocation,_radius,worldName];
				_vehicle setVariable ["SC_vehicleSpawnLocation", _SC_vehicleSpawnLocation,true];
				_vehicle setVariable ["SC_claimReady", false, true];
				["landSpawn", _vehicle, format ["class=%1 spawn=%2 radius=%3", _VehicleClassToUse, _spawnLocation, _radius]] call SC_fnc_logLifecycle;
				_vehicle setFuel 1;
				_vehicle engineOn true;

				if(SC_occupyVehiclesLocked) then
				{
					//_vehicle setVariable ["ExileIsPersistent", false];
					_vehicle lock 1;
					_vehicle setVehicleLock "LOCKED";
					_vehicle setVariable ["ExileIsLocked", 1, true];
				}
				else
				{
					_vehicle setVariable ["ExileIsPersistent", false];
					_vehicle lock 1;
					_vehicle setVehicleLock "UNLOCKED";
					_vehicle setVariable ["ExileIsLocked", 0, true];
				};
				_vehicle setVariable ["ExileIsPersistent", false];
				_vehicle lock 1;
				_vehicle setSpeedMode "LIMITED";
				_vehicle limitSpeed 60;
				_vehicle action ["LightOn", _vehicle];
				_vehicle addEventHandler ["getin", "_this call SC_fnc_getIn;"];
				_vehicle addEventHandler ["getout", "_this call SC_fnc_getOut;"];
				_vehicle addMPEventHandler ["mpkilled", "_this call SC_fnc_vehicleDestroyed;"];
				_hitLandEH = _vehicle addMPEventHandler ["mphit", "_this call SC_fnc_hitLand;"];
				_vehicle setVariable ["SC_hitLandEH", _hitLandEH];




				// Calculate the number of seats in the vehicle and fill the required amount
				_crewRequired = SC_minimumCrewAmount;
				if(SC_maximumCrewAmount > SC_minimumCrewAmount) then
				{
					_crewRequired = ceil(random[SC_minimumCrewAmount,SC_maximumCrewAmount-SC_minimumCrewAmount,SC_maximumCrewAmount]);
				};
				if (!SC_occupyLandVehicleIgnoreCount) then
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
						_loadOut = [_side] call SC_fnc_selectGear;
						_unit = [_group,_spawnLocation,"custom","random",_side,"Vehicle",_loadOut] call DMS_fnc_SpawnAISoldier;
						_amountOfCrew = _amountOfCrew + 1;
						_unit disableAI "FSM";
						_unit disableAI "MOVE";
						[_side,_unit] call SC_fnc_addMarker;
						_unit removeAllMPEventHandlers  "mphit";
						_unit disableAI "TARGET";
						_unit disableAI "AUTOTARGET";
						_unit disableAI "AUTOCOMBAT";
						_unit disableAI "COVER";
						_unit disableAI "SUPPRESSION";
						_unit assignAsDriver _vehicle;
						_unit moveInDriver _vehicle;
						_unit setVariable ["SC_drivenVehicle", _vehicle,true];
						_driverKilledEH = _unit addMPEventHandler ["mpkilled", "_this call SC_fnc_driverKilled;"];
						_unit setVariable ["SC_driverKilledEH", _driverKilledEH];
						_vehicle setVariable ["SC_assignedDriver", _unit,true];

					};
					if(_vehicleRole == "Turret" && _amountOfCrew < _crewRequired) then
					{
						_loadOut = [_side] call SC_fnc_selectGear;
						_unit = [_group,_spawnLocation,"custom","random",_side,"Vehicle",_loadOut] call DMS_fnc_SpawnAISoldier;
						_amountOfCrew = _amountOfCrew + 1;
						[_side,_unit] call SC_fnc_addMarker;
						_unit moveInTurret [_vehicle, _vehicleSeat];
						_unitPlaced = true;
					};
					if(_vehicleRole == "CARGO" && _amountOfCrew < _crewRequired) then
					{
						_loadOut = [_side] call SC_fnc_selectGear;
						_unit = [_group,_spawnLocation,"custom","random",_side,"Vehicle",_loadOut] call DMS_fnc_SpawnAISoldier;
						_amountOfCrew = _amountOfCrew + 1;
						[_side,_unit] call SC_fnc_addMarker;
						_unit assignAsCargo _vehicle;
						_unit moveInCargo _vehicle;
						_unitPlaced = true;
					};
					if(SC_extendedLogging && _unitPlaced) then
					{
						_logDetail = format['[OCCUPATION:Vehicle] %1 %2 added to vehicle %3',_side,_vehicleRole,_vehicle];
						[_logDetail] call SC_fnc_log;
					};
					if(_amountOfCrew == _crewRequired) exitWith{};
				} forEach _vehicleRoles;

				// Get the AI to shut the fuck up :)
				enableSentences false;
				enableRadio false;

				_logDetail = format['[OCCUPATION:Vehicle] %3 vehicle %1 spawned @ %2',_VehicleClassToUse,_spawnLocation,_side];
				[_logDetail] call SC_fnc_log;
				sleep 2;

				{
					_unit = _x;
					_unit enableAI "FSM";
					_unit enableAI "MOVE";
					_unit enableAI "TARGET";
					_unit enableAI "AUTOTARGET";
					_unit enableAI "AUTOCOMBAT";
					_unit allowCrewInImmobile false;
					reload _unit;
					_unitName = [_side] call SC_fnc_selectName;
					if(!isNil "_unitName") then { _unit setName _unitName; };
				}forEach units _group;
				[_group,false] call DMS_fnc_FreezeToggle;

				[units _group] orderGetIn true;
				sleep 10;

				[_group, _spawnLocation, 2000] call bis_fnc_taskPatrol;
				_group setBehaviour "AWARE";
				_group setCombatMode "RED";
				_group setVariable ["DMS_LockLocality",false];
				sleep 0.2;
				[_vehicle] call SC_fnc_fillVehicleCargo;
			}
			else
			{
				_logDetail = format['[OCCUPATION:Vehicle] vehicle %1 failed to spawn (check classname is correct)',_VehicleClassToUse];
				[_logDetail] call SC_fnc_log;
			};

		};
	};
};
SC_liveVehicles = count(SC_liveVehiclesArray);
_logDetail = format['[OCCUPATION:Vehicle] End check %1 currently active (max %2) @ %3',SC_liveVehicles,SC_maxNumberofVehicles,time];
[_logDetail] call SC_fnc_log;
