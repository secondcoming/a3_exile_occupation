if (!isServer) exitWith {};

private["_wp","_wp2","_wp3"];

_logDetail = format ["[OCCUPATION:RandomSpawn]:: Starting Occupation Monitor @ %1",time];
[_logDetail] call SC_fnc_log;

_middle 		    = worldSize/2;			
_spawnCenter 	    = [_middle,_middle,0];		// Centre point for the map
_maxDistance 	    = _middle;			        // Max radius for the map

_maxAIcount 		= SC_maxAIcount;
_minFPS 			= SC_minFPS;
_useLaunchers 	    = DMS_ai_use_launchers;
_scaleAI			= SC_scaleAI;
_side               = "bandit"; 
_delay				= 300;

if(SC_debug) then {	_delay = 30; };

// Don't run for the first 5 minutes after restart
if(time < _delay) exitWith 
{
    if(SC_extendedLogging) then 
    { 
        _logDetail = format['[OCCUPATION:RandomSpawn] Waiting until the server has been up at least 5 minutes (it has currently been up for %1 seconds)',time]; 
        [_logDetail] call SC_fnc_log;
    };
};


// Control Existing Random Spawns
{
	_group = _x;
	if((count (units _group)) == 0) then
	{
		// Remove the group
		SC_liveRandomGroups = SC_liveRandomGroups - [_group];
		if(SC_extendedLogging) then 
		{ 
			_logDetail = format['[OCCUPATION:RandomSpawn] group %1 removed (killed by players)',_group]; 
			[_logDetail] call SC_fnc_log;
		};		
	}
	else
	{
		_groupLeader = leader _group;
		
		if(isNil "_groupLeader" OR !alive _groupLeader) then
		{
			_groupMembers = units _group;
			_groupLeader = _groupMembers call BIS_fnc_selectRandom;			
		};
		
		_distanceFromSelectedPlayer = 500;
		_selectedPlayer = _group getVariable "SC_huntedPlayer";
		
		if(alive _selectedPlayer && !isNil "_selectedPlayer") then
		{
			_distanceFromSelectedPlayer = _selectedPlayer distance _groupLeader;
			_logDetail = format['[OCCUPATION:RandomSpawn] group %1 is now %2m away from the target (%3)',_group,_distanceFromSelectedPlayer,_selectedPlayer]; 
			[_logDetail] call SC_fnc_log;
		};

		_suitableTargets = [];
		
		if(!alive _selectedPlayer OR _distanceFromSelectedPlayer >= 500) then
		{
			// Select a new target or despawn if no target nearby
			_nearPlayers = _groupLeader nearEntities ["Exile_Unit_Player", 500];	
			{
				_selectedPlayer = _x;
				_playersPosition = position _selectedPlayer;
				_suitablePlayer = [ _playersPosition ] call SC_fnc_isSafePosRandom;
				_suitablePlayerisBambi = _selectedPlayer getVariable "ExileIsBambi";
				
				if(_suitablePlayer && (!_suitablePlayerisBambi OR SC_randomSpawnTargetBambis) && alive _selectedPlayer) then
				{
					_suitableTargets pushBack _selectedPlayer;
				};
			}forEach _nearPlayers;
			
			if(count(_suitableTargets) > 0) then
			{
				_selectedPlayer = _suitableTargets call BIS_fnc_selectRandom;			
				_group setVariable ["SC_huntedPlayer",_selectedPlayer];
				
				// Hunt the selected player
				_destination = getPos _selectedPlayer;
				if(!isNil "_destination") then
				{
					_group reveal [_selectedPlayer,1.5];
					
					_group allowFleeing 0;
					_wp = _group addWaypoint [_destination, 0] ;
					_wp setWaypointFormation "Column";
					_wp setWaypointBehaviour "AWARE";
					_wp setWaypointCombatMode "YELLOW";
					_wp setWaypointCompletionRadius 5;
						 
					[_group, _destination, 350] call bis_fnc_taskPatrol;
					_group allowFleeing 0;
					_group setBehaviour "AWARE";  
					_group setCombatMode "YELLOW";						
				}
				else
				{
					// Remove the group
					SC_liveRandomGroups = SC_liveRandomGroups - [_group];		
					_groupToClean = _group;
					_cleanup = [];
					{
						_cleanup pushBack _x;
					} forEach units _group;
					_cleanup call DMS_fnc_CleanUp;
					_logDetail = format['[OCCUPATION:RandomSpawn] group %1 had no target, so was deleted',_groupToClean]; 
					[_logDetail] call SC_fnc_log;					
				};			
			}
			else
			{
				// Remove the group
				SC_liveRandomGroups = SC_liveRandomGroups - [_group];		
				_groupToClean = _group;
				_cleanup = [];
				{
					_cleanup pushBack _x;
				} forEach units _group;
				_cleanup call DMS_fnc_CleanUp;
				_logDetail = format['[OCCUPATION:RandomSpawn] group %1 had no target, so was deleted',_groupToClean]; 
				[_logDetail] call SC_fnc_log;						
			};
		}
		else
		{

			// Remove existing waypoints
			while {(count (waypoints _group)) > 0} do
			{
				deleteWaypoint ((waypoints _group) select 0);
			};

			
			_groupLeader = leader _group;
			
			if(isNil "_groupLeader" OR !alive _groupLeader) then
			{
				_groupMembers = units _group;
				_groupLeader = _groupMembers call BIS_fnc_selectRandom;			
			};			
			
			_searchSet = false;
			if(!isNil "_selectedPlayer" && alive _selectedPlayer && !isNil "_groupLeader" && alive _groupLeader) then
			{
				_distanceFromSelectedPlayer = _selectedPlayer distance _groupLeader;
				_destination = getPos _selectedPlayer;
				
				_group reveal [_selectedPlayer,1.5];
				_destination = getPos _selectedPlayer;
				_group allowFleeing 0;
				_group move _destination;				
				_group setBehaviour "AWARE";  
				_group setCombatMode "YELLOW";	

				
				if(_distanceFromSelectedPlayer < 200) then
				{
					_buildings = _selectedPlayer nearObjects ["building", 20];
					{
						_isEnterable = [_x] call BIS_fnc_isBuildingEnterable;
						diag_log format ["[OCCUPATION:RandomSpawn] %1 is enterable",_x];
						
						if(_isEnterable) then
						{
							_buildingPositions = [_x, 30] call BIS_fnc_buildingPositions;
							_y = _x;
							
							// Find nearest building position to the players position
							_nearest = [0,0,0];
							{
								_distance 			= _nearest distance _selectedPlayer;
								_distanceToCheck	= _x distance _selectedPlayer; 
								diag_log format ["[OCCUPATION:RandomSpawn] Checking if %1(%3m) is closer to the target than %2(%4m)",_x,_nearest,_distanceToCheck,_distance];
								if(_distanceToCheck < _distance) then
								{
									_nearest = _x;
								};
							} foreach _buildingPositions;		
							diag_log format ["[OCCUPATION:RandomSpawn] Setting waypoint to nearest position to target %1 (%2m from target)",_nearest,_distance];
							_i = _buildingPositions find _nearest;
							_wp = _group addWaypoint [_nearest, 0] ;
							_wp setWaypointBehaviour "AWARE";
							_wp setWaypointCombatMode "RED";
							_wp setWaypointCompletionRadius 5;
							_wp waypointAttachObject _y;
							_wp setwaypointHousePosition _i;
							_logDetail = format['[OCCUPATION:RandomSpawn] group %1 are searching the buildings near player %2 @ location %3',_group,_selectedPlayer,_nearest]; 
							[_logDetail] call SC_fnc_log;	

						}
						else
						{
							diag_log format ["[OCCUPATION:RandomSpawn] %1 is not enterable",_x];							
						};
					} foreach _buildings;
					if(isNil "_wp") then
					{
						_group reveal [_selectedPlayer,1.5];
						_destination = getPos _selectedPlayer;
						_group allowFleeing 0;
						_group move _destination;
							 
						[_group, _destination, 50] call bis_fnc_taskPatrol;
						_group allowFleeing 0;
						_group setBehaviour "AWARE";  
						_group setCombatMode "RED";						
					};	
					_searchSet = true;	
					_logDetail = format['[OCCUPATION:RandomSpawn] group %1 are searching the buildings near player %2 @ location %3',_group,_selectedPlayer,_destination]; 
					[_logDetail] call SC_fnc_log;					
				};			
			};

			if(!_searchSet OR isNil "_searchSet") then
			{
				// Make sure the target is being hunted
				_group reveal [_selectedPlayer,1.5];
				_destination = getPos _selectedPlayer;
				_group allowFleeing 0;
				_group move _destination;
					 
				[_group, _destination, 100] call bis_fnc_taskPatrol;
				_group allowFleeing 0;
				_group setBehaviour "AWARE";  
				_group setCombatMode "YELLOW";	

				_logDetail = format['[OCCUPATION:RandomSpawn] group %1 is hunting player %2 @ location %3',_group,_selectedPlayer,_destination]; 
				[_logDetail] call SC_fnc_log;					
			};

		
		};
	
	};	
	
}forEach SC_liveRandomGroups;


if(count(SC_liveRandomGroups) >= SC_randomSpawnMaxGroups) exitWith 
{
    if(SC_extendedLogging) then 
    { 
        _logDetail = format['[OCCUPATION:RandomSpawn] End check %1 groups active (max %2) @ %3',count(SC_liveRandomGroups),SC_randomSpawnMaxGroups,time]; 
        [_logDetail] call SC_fnc_log;
    };   
};

// more than _scaleAI players on the server and the max AI count drops per additional player
_currentPlayerCount = count playableUnits;
if(_currentPlayerCount < SC_randomSPawnMinPlayers OR _currentPlayerCount < count(SC_liveRandomGroups)) exitWith 
{ 
    if(SC_extendedLogging) then 
    { 
        _logDetail = format ["[OCCUPATION:RandomSpawn]:: Held off spawning random AI, not enough players online"]; 
        [_logDetail] call SC_fnc_log; 
    };
};
if(_currentPlayerCount > _scaleAI) then 
{
	_maxAIcount = _maxAIcount - (_currentPlayerCount - _scaleAI) ;
};

// Don't spawn additional AI if the server fps is below _minFPS
if(diag_fps < _minFPS) exitWith 
{ 
    if(SC_extendedLogging) then 
    { 
        _logDetail = format ["[OCCUPATION:RandomSpawn]:: Held off spawning more AI as the server FPS is only %1",diag_fps]; 
        [_logDetail] call SC_fnc_log; 
    };
};

_aiActive = { !isPlayer _x } count allunits;

if(!SC_randomSpawnIgnoreCount) then
{
	if(_aiActive >= _maxAIcount) exitWith
	{ 
		if(SC_extendedLogging) then 
		{ 
			_logDetail = format ["[OCCUPATION:RandomSpawn]:: %1 active AI, so not spawning AI this time",_aiActive]; 
			[_logDetail] call SC_fnc_log;
		};
	};
};

// Get current targets
_huntedPlayers = [];
{
	_group = _x;
	_huntedPlayer = _group getVariable "SC_huntedPlayer";
	_huntedPlayers pushback _huntedPlayer;
}forEach SC_liveRandomGroups;

_livePlayers = [];
{
	if(alive _x) then
	{
		_livePlayers pushBack _x;
	};
}forEach playableUnits;

//_livePlayers call BIS_fnc_arrayShuffle; //Apparently this is broken in Arma..
_livePlayers = _livePlayers call ExileClient_util_array_shuffle; // But Exile can still work it's magic!!

// Find a player to hunt
{
	_selectedPlayer = _x;
	_suitablePlayer = true;
	_suitablePlayerisBambi = _selectedPlayer getVariable "ExileIsBambi";
	if(isNil "_suitablePlayerisBambi") then { _suitablePlayerisBambi = false; };
	if(_suitablePlayerisBambi && !SC_randomSpawnTargetBambis) exitWith
	{
		_suitablePlayer = false;
		if(SC_extendedLogging) then 
		{ 
			_logDetail = format ["[OCCUPATION:RandomSpawn]:: %1 is still a bambi, awww!",_selectedPlayer]; 
			[_logDetail] call SC_fnc_log;
		};		
	};	
	
	if(_selectedPlayer in _huntedPlayers) exitWith 
	{
		_suitablePlayer = false;
		if(SC_extendedLogging) then 
		{ 
			_logDetail = format ["[OCCUPATION:RandomSpawn]:: %1 is already being hunted",_selectedPlayer]; 
			[_logDetail] call SC_fnc_log;
		};		
	};
	
	_lastHunted = _x getVariable "SC_lastHunted";	
	if(isNil "_lastHunted") then
	{
		//_lastHunted = -5000;
		_lastHunted =  time;   
		_selectedPlayer setVariable ["SC_lastHunted",time];
	};
	
	if((time - _lastHunted) < SC_randomSpawnFrequency) exitWith
	{
		_suitablePlayer = false;
		if(SC_extendedLogging) then 
		{ 
			_logDetail = format ["[OCCUPATION:RandomSpawn]:: %1 has been hunted recently, not spawning another group yet",_selectedPlayer]; 
			[_logDetail] call SC_fnc_log;
		};		
	};
	
	if(vehicle _selectedPlayer != _selectedPlayer) exitWith
	{
		_suitablePlayer = false;
		if(SC_extendedLogging) then 
		{ 
			_logDetail = format ["[OCCUPATION:RandomSpawn]:: selected player %1 is in a vehicle, so not spawning AI this round",_selectedPlayer,_diceRoll,(100 - SC_randomSpawnChance)]; 
			[_logDetail] call SC_fnc_log;
		};	
	};
	
	_diceRoll = random(100);
	if(_diceRoll <= (100 - SC_randomSpawnChance)) exitWith
	{
		_suitablePlayer = false;
		if(SC_extendedLogging) then 
		{ 
			_logDetail = format ["[OCCUPATION:RandomSpawn]:: %1 rolled %2 (%3+ required) so not spawning another group yet",_selectedPlayer,_diceRoll,(100 - SC_randomSpawnChance)]; 
			[_logDetail] call SC_fnc_log;
		};	
	};
	
	// rolled more than the needed amount and not spawned hunters recently
	_playersPosition = position _selectedPlayer;
		
	// Is the player in a suitable place?
	if(_suitablePlayer) then
	{
		_suitablePlayer = [ _playersPosition ] call SC_fnc_isSafePosRandom;	
	};

	_spawnLocation = [0,0,0];
		
	// Suitable player and location found
	if(_suitablePlayer) then
	{
	
		// Find a safe position to spawn
		_suitableLocation = false;
		_attempts = 1;
		while{!_suitableLocation && _attempts < 5} do 
		{		
			_spawnLocation = [_playersPosition,250,350,15,0,20,0] call BIS_fnc_findSafePos;
			_suitableLocation = [ _spawnLocation ] call SC_fnc_isSafePosRandom;
			_attempts = _attempts + 1;
			sleep 1;
		};
		
		if(!_suitableLocation) then 
		{  
			if(SC_extendedLogging) then 
			{ 
				_logDetail = format ["[OCCUPATION:RandomSpawn]:: unable to find safe place near %1",_suitablePlayer]; 
				[_logDetail] call SC_fnc_log;
			};
		}
		else
		{
			_groupSize = random [SC_randomSpawnMinGroupSize, SC_randomSpawnMinGroupSize+(SC_randomSpawnMaxGroupSize-SC_randomSpawnMinGroupSize)/2, SC_randomSpawnMaxGroupSize];
			if (!SC_randomSpawnIgnoreCount) then
			{
				_groupSize = _groupSize min ((_maxAIcount - ({ !isPlayer _x } count allUnits)) max 0);
			};
			if (_groupSize < 1) exitWith {};

			_group = createGroup SC_BanditSide;
			_group setVariable ["DMS_AllowFreezing",false];
			_group setVariable ["DMS_LockLocality",true];
			_group setVariable ["DMS_SpawnedGroup",true];
			_group setVariable ["DMS_Group_Side", "bandit"];
			_group setVariable ["SC_huntedPlayer",_selectedPlayer];
			_selectedPlayer setVariable ["SC_lastHunted",time];
			SC_liveRandomGroups = SC_liveRandomGroups + [_group];
			
			for "_i" from 1 to _groupSize do
			{
				_loadOut = ["cops"] call SC_fnc_selectGear;
				_unit = [_group,_spawnLocation,"custom","random","bandit","soldier",_loadOut] call DMS_fnc_SpawnAISoldier;				
				_unit allowFleeing 0;
				_unit allowDamage false;
				_unit disableAI "AUTOTARGET";
				_unit disableAI "TARGET";
				_unit disableAI "MOVE";
				//_unit disableAI "FSM";
                _unitName = ["survivor"] call SC_fnc_selectName;
                if(!isNil "_unitName") then { _unit setName _unitName; };				
				_unit addMPEventHandler ["mpkilled", "_this call SC_fnc_randomUnitMPKilled;"];
				_unit addeventhandler ["Fired", {(vehicle (_this select 0)) setvehicleammo 1;}];
			};

            {	
                _unit = _x;           
				_unit allowDamage true;
				_unit enableAI "AUTOTARGET";
				_unit enableAI "TARGET";
				_unit enableAI "MOVE";  
				_unit setCaptive false;
				_unit setCombatMode "YELLOW"				
            }foreach units _group; 			
			
			if(SC_randomSpawnAnnounce) then
			{
				if (SC_randomSpawnNameTarget) then
				{
				["toastRequest", ["InfoTitleAndText", ["Raid group Incoming!", format["A squad of Police have been despatched to take out %1!",name _selectedPlayer]]]] call ExileServer_system_network_send_broadcast;
				}				
				else
				{
				["toastRequest", ["InfoTitleAndText", ["Raid group Incoming!", "A squad of Police have been despatched to take out a trouble prisoner."]]] call ExileServer_system_network_send_broadcast;
				};
			};
			
			_logDetail = format ["[OCCUPATION:RandomSpawn]:: Spawning a group of AI @ %2 to hunt player %1",_selectedPlayer,_spawnLocation]; 
			[_logDetail] call SC_fnc_log;

			
			// Hunt the selected player
			_group reveal [_selectedPlayer,1.5];
			_destination = getPos _selectedPlayer;
			_group allowFleeing 0;
			_wp = _group addWaypoint [_destination, 0] ;
			_wp setWaypointFormation "Column";
			_wp setWaypointBehaviour "AWARE";
			_wp setWaypointCombatMode "YELLOW";
			_wp setWaypointCompletionRadius 10;
			_wp setWaypointType "MOVE";
				 
			[_group, _destination, 50] call bis_fnc_taskPatrol;
			_group allowFleeing 0;
			_group setBehaviour "AWARE";  
			_group setCombatMode "YELLOW";			
		};	
	}
	else
	{
		if(SC_extendedLogging) then 
		{ 
			_logDetail = format ["[OCCUPATION:RandomSpawn]:: %1 is not in a safe place to spawn AI",_selectedPlayer]; 
			[_logDetail] call SC_fnc_log;
		};		
	};  
}forEach _livePlayers;


