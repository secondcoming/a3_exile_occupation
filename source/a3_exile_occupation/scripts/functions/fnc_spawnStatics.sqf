_statics 			    = _this select 0;
_side                   = _this select 1;
_static 			    = [];
_currentSide            = SC_BanditSide;
_debug 				    = SC_debug;
_useLaunchers 		    = DMS_ai_use_launchers;
_scaleAI				= SC_scaleAI;
_staticUID				= 1;

if(_side == "survivor") then { _currentSide = SC_SurvivorSide };

{
	_currentStatic = _x;
	_spawnPosition = _currentStatic select 0;
	_aiCount = _currentStatic select 1;
	if (!SC_staticIgnoreAICount) then
	{
		private _maxAIcount = SC_maxAIcount - ((count playableUnits - SC_scaleAI) max 0);
		_aiCount = _aiCount min ((_maxAIcount - ({ !isPlayer _x } count allUnits)) max 0);
	};
	if (_aiCount < 1) exitWith {};
	_radius = _currentStatic select 2;
	_staticSearch = _currentStatic select 3;
	
	_logDetail = format ["[OCCUPATION Static]:: Checking static spawn @ %1 for existing %2 AI",_spawnPosition,_currentSide];
    [_logDetail] call SC_fnc_log;
	
	_okToSpawn = true;
	Sleep 0.1;

	while{_okToSpawn} do
	{			


		// Don't spawn if a previous round of AI are already in place
		_newStatic = [_staticUID,_spawnPosition];
		
		if(_staticUID in SC_liveStaticGroups) exitwith
		{
            _okToSpawn = false; 
            if(_debug) then 
            { 
                _logDetail = format ["[OCCUPATION Static]:: %1 already has active AI patrolling",_spawnPosition];
                [_logDetail] call SC_fnc_log;
            };			
		};
		
		
		// Don't spawn additional AI if there are players in range
		if(!(SC_staticIgnoreNearbyPlayers) && ([_spawnPosition, 250] call ExileClient_util_world_isAlivePlayerInRange)) exitwith 
        { 
            _okToSpawn = false; 
            if(_debug) then 
            { 
                _logDetail = format ["[OCCUPATION Static]:: %1 has players too close",_spawnPosition];
                [_logDetail] call SC_fnc_log;
            }; 
        };
		
		if(_okToSpawn) then
		{
			//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			// Get AI to patrol the area
			//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			_groupRadius = _radius;
			_difficulty = "random";
						
			_initialGroup = createGroup _currentSide;
						
			DMS_ai_use_launchers = false;           
            for "_i" from 1 to _aiCount do
            {		
                _loadOut = [_side] call SC_fnc_selectGear;
                _unit = [_initialGroup,_spawnPosition,"custom","random",_side,"soldier",_loadOut] call DMS_fnc_SpawnAISoldier;
				_unit allowFleeing 0;
				_unit allowDamage false;
				_unit disableAI "AUTOTARGET";
				_unit disableAI "TARGET";
				_unit disableAI "MOVE";
                _unitName = [_side] call SC_fnc_selectName;
                if(!isNil "_unitName") then { _unit setName _unitName; }; 				 
				_unit setVariable ["SC_staticUID",_staticUID];
				_unit setVariable ["SC_staticSpawnPos",_spawnPosition];
				_unit addMPEventHandler ["mpkilled", "_this call SC_fnc_staticUnitMPKilled;"];
            };            
			DMS_ai_use_launchers = _useLaunchers; 								
			
            _initialGroup setCombatMode "BLUE";
            _initialGroup setBehaviour "SAFE";

            _group = createGroup _currentSide;           
            _group setVariable ["DMS_LockLocality",nil];
            _group setVariable ["DMS_SpawnedGroup",true];
            _group setVariable ["DMS_Group_Side", _side];
            
            SC_liveStaticGroups = SC_liveStaticGroups + [_staticUID,_spawnPosition];
            
            {	
                _unit = _x;           
                [_unit] joinSilent grpNull;
                [_unit] joinSilent _group;
				_unit allowDamage true;
				_unit enableAI "AUTOTARGET";
				_unit enableAI "TARGET";
				_unit enableAI "MOVE";  
                [_side,_unit] call SC_fnc_addMarker; 
				_unit setCaptive false;                               
            }foreach units _initialGroup;            
				
						
			// Get the AI to shut the fuck up :)
			enableSentences false;
			enableRadio false;
						
			if(!_staticSearch) then
			{
				[_group, _spawnPosition, _groupRadius] call bis_fnc_taskPatrol;
				_group setBehaviour "AWARE";
				_group setCombatMode "RED";
			}
			else
			{
				_group setBehaviour "AWARE";
				_group setCombatMode "RED";
				_buildings = _spawnPosition nearObjects ["building", _groupRadius];
				{
					_isEnterable = [_x] call BIS_fnc_isBuildingEnterable;
             
					if(_isEnterable) then
					{
                        _buildingPositions = [_x, 10] call BIS_fnc_buildingPositions;
                        _y = _x;
						// Find Highest Point
						_highest = [0,0,0];
						{
                            if(_x select 2 > _highest select 2) then
							{
								_highest = _x;
							};

						} foreach _buildingPositions;		
						_wpPosition = _highest;
						diag_log format ["Static Patrol %3 waypoint added - building: %1 position: %2",_y,_highest,_group];
						_i = _buildingPositions find _wpPosition;
						_wp = _group addWaypoint [_wpPosition, 5] ;
						_wp setWaypointBehaviour "AWARE";
						_wp setWaypointSpeed "NORMAL";
						_wp setWaypointCombatMode "RED";
						_wp setWaypointCompletionRadius 1;
						_wp waypointAttachObject _y;
						_wp setwaypointHousePosition _i;
						_wp setWaypointType "SAD";

					};
				} foreach _buildings;
				if(count _buildings > 1 && !isNil "_wp") then
				{
					_wp setWaypointType "CYCLE";
				}
				else
				{
					_group setBehaviour "AWARE";
					_group setCombatMode "RED";												
				};
			};

			//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			_logDetail = format ["[OCCUPATION Static]:: Spawning %1 AI in at %2 to patrol",_aiCount,_spawnPosition];
            [_logDetail] call SC_fnc_log;

			if(SC_mapMarkers && !isNil "_foundBuilding") then 
			{
				_marker = createMarker [format ["%1", _staticUID],_spawnPosition];
				_marker setMarkerShape "Icon";
				_marker setMarkerSize [3,3];
				_marker setMarkerType "mil_dot";
				_marker setMarkerBrush "Solid";
				_marker setMarkerAlpha 0.5;
				_marker setMarkerColor "ColorRed";
				_marker setMarkerText "Occupied Area (static)";	
			};
			
			_okToSpawn = false;			
		};	
	};
    _staticUID = _staticUID + 1;
}forEach _statics;
