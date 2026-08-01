if (!isServer) exitWith {};

_logDetail = format ["[OCCUPATION:LootCrates]:: Starting Occupation Loot Crates"];
[_logDetail] call SC_fnc_log;

_logDetail = format["[OCCUPATION:LootCrates]:: worldname: %1 crates to spawn: %2",worldName,SC_numberofLootCrates];
[_logDetail] call SC_fnc_log;
private _position = [0,0,0];

for "_i" from 1 to SC_numberofLootCrates do
{
	_validspot 	= false;
	_attempts = 0;
	while{!_validspot && _attempts < 20} do
	{
		_attempts = _attempts + 1;
		sleep 0.2;
		if(SC_occupyLootCratesStatic) then
		{
			_tempPosition = SC_occupyLootCratesLocations call BIS_fnc_selectRandom;
			SC_occupyLootCratesLocations = SC_occupyLootCratesLocations - _tempPosition;
			
			_position = [_tempPosition select 0, _tempPosition select 1, _tempPosition select 2];
			if(isNil "_position") then
			{
				_position = [ false, false ] call SC_fnc_findsafePos;
			};
		}
		else
		{
			_position = [ false, false ] call SC_fnc_findsafePos;
		};
		
		_validspot = !(_position isEqualTo []);
		
		//Check if near another crate site
		if(_validspot) then
		{
			_nearOtherCrate = (nearestObjects [_position,["Exile_Container_SupplyBox"],500]) select 0;
			if (!isNil "_nearOtherCrate") then { _validspot = false; };
		};
	};	
	if(!_validspot) then
	{
		["safePosSpawnSkipped", objNull, format ["branch=lootCrate index=%1 attempts=%2", _i, _attempts]] call SC_fnc_logLifecycle;
		continue;
	};
	
	_mapMarkerName = format ["SC_loot_marker_%1", _i];
	
	if (SC_occupyLootCratesMarkers) then 
	{		
		_event_marker = createMarker [ format ["SC_loot_marker_%1", _i], _position];
		_event_marker setMarkerColor "ColorWhite";
		_event_marker setMarkerAlpha 1;
		_event_marker setMarkerText "Gear Crate";
		_event_marker setMarkerType "ExileMissionStrongholdIcon";
	};	

	if (SC_SpawnLootCrateGuards) then
	{
			//Infantry spawn using DMS
			_AICount = SC_LootCrateGuards;
			
			if(SC_LootCrateGuardsRandomize) then 
			{
				_AICount = 1 + (round (random (SC_LootCrateGuards-1)));    
			};

			if(_AICount > 0) then
			{
				_spawnPosition = [_position select 0, _position select 1, 0];
				
				_initialGroup = createGroup SC_BanditSide;
				_initialGroup setCombatMode "BLUE";
				_initialGroup setBehaviour "SAFE";
				
				for "_i" from 1 to _AICount do
				{		
					_loadOut = ["bandit"] call SC_fnc_selectGear;
					_unit = [_initialGroup,_spawnPosition,"custom","random","bandit","soldier",_loadOut] call DMS_fnc_SpawnAISoldier; 
					_unitName = ["bandit"] call SC_fnc_selectName;
					if(!isNil "_unitName") then { _unit setName _unitName; }; 
					reload _unit;
				};
				
				// Get the AI to shut the fuck up :)
				enableSentences false;
				enableRadio false;

				  
				_group = createGroup SC_BanditSide;           
				_group setVariable ["DMS_LockLocality",nil];
				_group setVariable ["DMS_SpawnedGroup",true];
				_group setVariable ["DMS_Group_Side", SC_BanditSide];

				{	
					_unit = _x;           
					[_unit] joinSilent grpNull;
					[_unit] joinSilent _group;
					_unit setCaptive false;                               
				}foreach units _initialGroup;  		
				deleteGroup _initialGroup;
				
				[_group, _spawnPosition, 25] call bis_fnc_taskPatrol;
				_group setBehaviour "STEALTH";
				_group setCombatMode "RED";

				_logDetail = format ["[OCCUPATION:LootCrates]::  Creating crate %3 at drop zone %1 with %2 guards",_position,_AICount,_i];
				[_logDetail] call SC_fnc_log;		
			};
	}
	else
	{
		_logDetail = format ["[OCCUPATION:LootCrates]::  Creating crate %2 at drop zone %1 with no guards",_position,_i];
		[_logDetail] call SC_fnc_log;	
	};

    
    
	_box = "Exile_Container_SupplyBox" createvehicle _position;
	clearMagazineCargoGlobal _box;
	clearWeaponCargoGlobal _box;
	clearItemCargoGlobal _box;
	
	_box enableRopeAttach SC_ropeAttach; 	// Stop people airlifting the crate
	_box setVariable ["permaLoot",true]; 	// Crate stays until next server restart
	_box allowDamage false; 				// Stop crates taking damage

	{
		_item = _x select 0;
		_amount = _x select 1;
		_randomAmount = _x select 2;
		_amount = _amount + (random _randomAmount);
		_itemType = _x call BIS_fnc_itemType;
		
		
		if((_itemType select 0) == "Weapon") then
		{
			_box addWeaponCargoGlobal [_item, _amount];	
		};
		if((_itemType select 0) == "Magazine") then
		{
			_box addMagazineCargoGlobal [_item, _amount];	
		};
		if((_itemType select 0) == "Item") then
		{
			_box addItemCargoGlobal [_item, _amount];	
		};
		if((_itemType select 0) == "Equipment") then
		{
			_box addItemCargoGlobal [_item, _amount];	
		};	
		if((_itemType select 0) == "Backpack") then
		{
			_box addBackpackCargoGlobal [_item, _amount];	
		};			
	}forEach SC_LootCrateItems;
	
	// Add a wreck for defensive purposes
	_wrecks = selectRandom [
							// Trucks
							"Land_Wreck_BMP2_F",
							"Land_Wreck_HMMWV_F",
							"Land_Wreck_BRDM2_F",
							"Land_Wreck_Ural_F",
							// Tanks
							"Land_Wreck_Slammer_F",
							// Helis
							"Land_Wreck_Heli_Attack_02_F",
							"Land_UWreck_Heli_Attack_02_F",
							// VTOL
							"Land_UWreck_MV22_F"
							];
							
	_vehWreck = _wrecks createVehicle [0,0,0];
	
	/*
	_effect = "test_EmptyObjectForSmoke";	
	if(SC_HeliCrashesOnFire) then 
	{
		_effect = "test_EmptyObjectForFireBig";	
	};
	_wreckFire = _effect createVehicle (position _vehWreck);   
	_wreckFire attachto [_vehWreck, [0,0,-1]];
	*/
	
	_vehWreckRelPos = _box getRelPos [(10 + (ceil random 15)), (random 360)];
	_vehWreck setPos _vehWreckRelPos;
	_vehWreck setDir (random 360);
	_vehWreck setVectorUp surfaceNormal position _vehWreck;	
};
