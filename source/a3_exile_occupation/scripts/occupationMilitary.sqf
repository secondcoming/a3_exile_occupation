if (!isServer) exitWith {};

private["_wp", "_wp2", "_wp3", "_logDetail", "_maxDistance", "_maxAIcount", "_minFPS", "_useLaunchers", "_scaleAI", "_verifyLoadout", "_finalizeLocality", "_buildings", "_building", "_currentPlayerCount", "_aiActive", "_okToSpawn", "_foundBuilding", "_location", "_pos", "_spawnChance", "_safePos", "_aiNear", "_aiCount", "_groupRadius", "_difficulty", "_side", "_spawnPosition", "_spawnPositions", "_candidatePosition", "_unitLoadOut", "_dmsLoadOut", "_groupInitial", "_group", "_unit", "_unitName", "_tag", "_buildings", "_buildingPositions", "_highest", "_i", "_j", "_wp", "_marker", "_spawnedGroups", "_activeMilitaryGroups", "_activeBeforeSpawn", "_remainingBudget"];

_logDetail = format ["[OCCUPATION Military]:: Starting Monitor"];
[_logDetail] call SC_fnc_log;

_maxDistance = 500; // Max radius to scan
_maxAIcount = SC_maxAIcount;
_minFPS = SC_minFPS;
_useLaunchers = DMS_ai_use_launchers;
_scaleAI = SC_scaleAI;

_verifyLoadout =
{
    params ["_unit", "_loadOut", "_branch", ["_forceFix", false]];

    uiSleep 1;

    if (isNull _unit) exitWith {};

    private _weapon = _loadOut select 0;
    private _weaponAttachments = _loadOut select 1;
    private _magazines = _loadOut select 2;
    private _pistol = _loadOut select 3;
    private _pistolAttachments = _loadOut select 4;
    private _assignedItems = _loadOut select 5;
    private _launcher = _loadOut select 6;
    private _helmet = _loadOut select 7;
    private _uniform = _loadOut select 8;
    private _vest = _loadOut select 9;
    private _backpack = _loadOut select 10;
    private _needsFix = false;

    if (!(_weapon isEqualTo "") && {primaryWeapon _unit != _weapon}) then { _needsFix = true; };
    if (!(_helmet isEqualTo "") && {headgear _unit != _helmet}) then { _needsFix = true; };
    if (!(_uniform isEqualTo "") && {uniform _unit != _uniform}) then { _needsFix = true; };
    if (!(_vest isEqualTo "") && {vest _unit != _vest}) then { _needsFix = true; };
    // The initial pass must remove any base O_recon_F inventory left behind by DMS.
    if (_forceFix) then { _needsFix = true; };

    if (_needsFix) then
    {
        if (local _unit) then
        {
            removeAllWeapons _unit;
            removeAllItems _unit;
            removeAllAssignedItems _unit;
            removeAllItemsWithMagazines _unit;
            {_unit removeMagazineGlobal _x;} forEach magazines _unit;
            removeHeadgear _unit;
            removeUniform _unit;
            removeVest _unit;
            removeBackpackGlobal _unit;

            if (!(_helmet isEqualTo "")) then { _unit addHeadgear _helmet; };
            if (!(_uniform isEqualTo "")) then { _unit forceAddUniform _uniform; };
            if (!(_vest isEqualTo "")) then { _unit addVest _vest; };
            if (!(_backpack isEqualTo "")) then { _unit addBackpackGlobal _backpack; };

            if (!(_launcher isEqualTo "")) then { _unit addWeapon _launcher; };

            if (!(_pistol isEqualTo "")) then
            {
                _unit addWeapon _pistol;
                { if (!(_x isEqualTo "")) then { _unit addHandgunItem _x; }; } forEach _pistolAttachments;
            };

            if (!(_weapon isEqualTo "")) then
            {
                _unit addWeapon _weapon;
                { if (!(_x isEqualTo "")) then { _unit addPrimaryWeaponItem _x; }; } forEach _weaponAttachments;
                _unit selectWeapon _weapon;
            };

            {
                if (_x isEqualType "") then
                {
                    _unit addMagazines [_x, 1];
                }
                else
                {
                    _unit addMagazines _x;
                };
            } forEach _magazines;

            {
                if (_x in ["Binocular", "Rangefinder", "Laserdesignator", "Laserdesignator_02", "Laserdesignator_03"]) then
                {
                    _unit addWeapon _x;
                }
                else
                {
                    _unit linkItem _x;
                };
            } forEach _assignedItems;

            reload _unit;

        };
    };
};

_finalizeLocality =
{
    params ["_group", "_branch"];

    uiSleep 4;

    if (!isNull _group) then
    {
        // Occupation gear is assigned locally on the server and is not safe to offload afterwards.
        _group setVariable ["DMS_LockLocality", true];
    };
};

_buildings = SC_buildings; // Class names for the military buildings to patrol
_building = [];

_currentPlayerCount = count playableUnits;
if (_currentPlayerCount > _scaleAI) then {
    _maxAIcount = _maxAIcount - (_currentPlayerCount - _scaleAI);
};

// Don't spawn additional AI if the server fps is below _minFPS
if (diag_fps < _minFPS) exitWith {
    _logDetail = format ["[OCCUPATION Military]:: Held off spawning more AI as the server FPS is only %1", diag_fps];
    [_logDetail] call SC_fnc_log;
};

_aiActive = { !isPlayer _x } count allunits;
_spawnedGroups = 0;
_activeMilitaryGroups = allGroups select
{
    _x getVariable ["SC_IsMilitaryGroup", false] && {({alive _x} count units _x) > 0}
};

if ((_aiActive >= _maxAIcount) && {!SC_militaryIgnoreCount}) exitWith {
    _logDetail = format ["[OCCUPATION Military]:: %1 active AI, so not spawning AI this time", _aiActive];
    [_logDetail] call SC_fnc_log;
};

{
    if ((count _activeMilitaryGroups) >= SC_militaryMaxGroups) exitWith
    {};

    if (_spawnedGroups >= SC_militaryMaxGroupsPerCycle) exitWith
    {};

    if (!SC_militaryIgnoreCount && {({ !isPlayer _x } count allUnits) >= _maxAIcount}) exitWith
    {};

    _okToSpawn = true;
    Sleep 0.1;

    _foundBuilding = _x select 0;
    _location = getPos _foundBuilding;
    _pos = [_location select 0, _location select 1, 0];

    if (SC_extendedLogging) then {
        _logDetail = format ["[OCCUPATION Military]:: Testing position: %1", _pos];
        [_logDetail] call SC_fnc_log;
    };

    while {_okToSpawn && !isNil "_pos"} do {
        // Apply the configured chance independently to each suitable location.
        _spawnChance = random 100;
        if (_spawnChance > SC_militarySpawnChance) exitWith {
            _okToSpawn = false;
            if (SC_extendedLogging) then {
                _logDetail = format ["[OCCUPATION Military]:: Rolled %1 so not spawning AI this time", _spawnChance];
                [_logDetail] call SC_fnc_log;
            };
        };

        _safePos = [ _pos ] call SC_fnc_isSafePos;
        if (!_safePos OR isNil "_safePos") then {
            _okToSpawn = false;
            if (SC_extendedLogging) then {
                _logDetail = format ["[OCCUPATION Military]:: %1 determined as an unsafe position to spawn AI", _pos];
                [_logDetail] call SC_fnc_log;
            };
        };

        // Don't spawn additional AI if there are already AI in range
        _aiNear = count(_pos nearEntities [DMS_AI_Classname, 500]);
        if (_aiNear > 0) exitwith {
            _okToSpawn = false;
            if (SC_extendedLogging) then {
                _logDetail = format ["[OCCUPATION Military]:: %1 already has %2 active AI patrolling", _pos, _aiNear];
                [_logDetail] call SC_fnc_log;
            };
        };

        if (_okToSpawn) then {
            // Get AI to patrol the area
            _aiCount = SC_militaryMinGroupSize + floor random ((SC_militaryMaxGroupSize - SC_militaryMinGroupSize) + 1);
            _activeBeforeSpawn = { !isPlayer _x } count allUnits;
            _remainingBudget = _maxAIcount - _activeBeforeSpawn;
            if (!SC_militaryIgnoreCount) then
            {
                _aiCount = _aiCount min _remainingBudget;
            };

            if (_aiCount <= 0) exitWith
            {
                _okToSpawn = false;
            };

            _groupRadius = 500;
            _difficulty = "random";
            _side = SC_BanditSide;
            _spawnPosition = _pos;
            _spawnPositions = [];
            for "_j" from 1 to _aiCount do
            {
                _candidatePosition = _pos findEmptyPosition [2 + (_j * 2), 20, DMS_AI_Classname];
                if (_candidatePosition isEqualTo []) then
                {
                    _candidatePosition = _pos getPos [3 + (_j * 2), random 360];
                };
                _spawnPositions pushBack [_candidatePosition select 0, _candidatePosition select 1, 0];
            };
            // DMS removes the base O_recon_F inventory; Occupation assigns unique gear per unit below.
            _dmsLoadOut = ["", [], [], "", [], [], "", "", "", "", ""];

            // Get the AI to shut the fuck up :)
            enableSentences false;
            enableRadio false;

            if (!SC_useWaypoints) then {
                DMS_ai_use_launchers = false;
                _groupInitial = [_spawnPositions, _aiCount, _difficulty, "custom", "bandit", _dmsLoadOut] call DMS_fnc_SpawnAIGroup_MultiPos;
                DMS_ai_use_launchers = _useLaunchers;

                _group = _groupInitial;
                _group setVariable ["DMS_AllowFreezing", true];
                _group setVariable ["DMS_LockLocality", true];
                _group setVariable ["DMS_SpawnedGroup", true];
                _group setVariable ["DMS_Group_Side", "bandit"];

                {
                    _unit = _x;
                    [_unit] joinSilent grpNull;
                    [_unit] joinSilent _group;
                    _unitName = ["bandit"] call SC_fnc_selectName;
                    if (!isNil "_unitName") then { _unit setName _unitName; };
                    reload _unit;
                    _unitLoadOut = ["bandit"] call SC_fnc_selectGear;
                    [_unit, _unitLoadOut, "noWaypoints", true] spawn _verifyLoadout;
                    if (SC_debug) then {
                        _tag = createVehicle ["Sign_Arrow_Blue_F", position _unit, [], 0, "CAN_COLLIDE"];
                        _tag attachTo [_unit, [0, 0, 0.6], "Head"];
                    };
                } foreach units _groupInitial;

                [_group, _pos, _groupRadius] call bis_fnc_taskPatrol;
                _group setBehaviour "STEALTH";
                _group setCombatMode "RED";
                [_group, "noWaypoints"] spawn _finalizeLocality;
            } else {
                DMS_ai_use_launchers = false;
                _groupInitial = [_spawnPositions, _aiCount, _difficulty, "custom", "bandit", _dmsLoadOut] call DMS_fnc_SpawnAIGroup_MultiPos;
                DMS_ai_use_launchers = _useLaunchers;
                _groupInitial setVariable ["DMS_LockLocality", true];

                _group = createGroup SC_BanditSide;
                _group setVariable ["DMS_AllowFreezing", true];
                _group setVariable ["DMS_LockLocality", true];
                _group setVariable ["DMS_SpawnedGroup", true];
                _group setVariable ["DMS_Group_Side", "bandit"];

                {
                    _unit = _x;
                    [_unit] joinSilent grpNull;
                    [_unit] joinSilent _group;
                    _unitName = ["bandit"] call SC_fnc_selectName;
                    if (!isNil "_unitName") then { _unit setName _unitName; };
                    _unitLoadOut = ["bandit"] call SC_fnc_selectGear;
                    [_unit, _unitLoadOut, "waypoints", true] spawn _verifyLoadout;
                    if (SC_debug) then {
                        _tag = createVehicle ["Sign_Arrow_Blue_F", position _unit, [], 0, "CAN_COLLIDE"];
                        _tag attachTo [_unit, [0, 0, 0.6], "Head"];
                    };
                } foreach units _groupInitial;
                deleteGroup _groupInitial;

                [ _group, _pos, _difficulty, "STEALTH" ] call DMS_fnc_SetGroupBehavior;

                _buildings = _pos nearObjects ["house", _groupRadius];
                {
                    _buildingPositions = [_x, 10] call BIS_fnc_buildingPositions;
                    if (count _buildingPositions > 0) then {
                        _y = _x;

                        // Find Highest Point
                        _highest = [0, 0, 0];
                        {
                            if (_x select 2 > _highest select 2) then {
                                _highest = _x;
                            };
                        } foreach _buildingPositions;
                        _spawnPosition = _highest;

                        _i = _buildingPositions find _spawnPosition;
                        _wp = _group addWaypoint [_spawnPosition, 0];
                        _wp setWaypointBehaviour "AWARE";
                        _wp setWaypointCombatMode "RED";
                        _wp setWaypointCompletionRadius 1;
                        _wp waypointAttachObject _y;
                        _wp setwaypointHousePosition _i;
                        _wp setWaypointType "MOVE";
                    };
                } foreach _buildings;
                if (count _buildings > 0) then {
                    _wp setWaypointType "CYCLE";
                };
                [_group, "waypoints"] spawn _finalizeLocality;
            };

            _logDetail = format ["[OCCUPATION Military]:: Spawning %1 AI in at %2 to patrol", _aiCount, _spawnPosition];
            [_logDetail] call SC_fnc_log;
            _group setVariable ["SC_IsMilitaryGroup", true, true];
            _activeMilitaryGroups pushBack _group;
            _spawnedGroups = _spawnedGroups + 1;
            uiSleep SC_militarySpawnDelay;

            if (SC_mapMarkers) then {
                _marker = createMarker [format ["%1", _foundBuilding], _pos];
                _marker setMarkerShape "Icon";
                _marker setMarkerType "mil_dot";
                _marker setMarkerColor "ColorRed";
                _marker setMarkerText "Military Patrol";
            };
        };

        _okToSpawn = false;
    };
} forEach SC_completeMilitaryList;
