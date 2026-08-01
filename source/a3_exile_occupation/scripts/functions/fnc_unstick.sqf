// Unstuck based on a function written by Chris (infiSTAR)
// http://pastebin.com/73pjvXPw


private["_vehicle","_curPos","_oldvehPos","_engineTime","_newPos","_group","_localityReturnRequested","_vehicleMoved"];
_vehicle = _this select 0;
_localityReturnRequested = false;
_vehicleMoved = false;

if(isNil "_vehicle") exitWith{};

_group = group _vehicle;

if(count(crew _vehicle) > 0)then
{
    _vehicleType = TypeOf _vehicle;
	_vehicleName =  getText (configFile >>  "CfgVehicles" >> _vehicleType >> "displayName");
    _curPos = position _vehicle;
    _newPos = _curPos;
    _oldvehPos = _vehicle getVariable["vehPos",[0,0,0]];
    if(isNil "_oldvehPos") then { _oldvehPos = [0,0,0]; };
    if(str _oldvehPos != "[0,0,0]")then
    {
        if(_curPos distance _oldvehPos < 2)then
        {
            _engineTime  = _vehicle getVariable["engineTime",-1];
            if(_engineTime < 0)then
            {
                _vehicle setVariable["engineTime",time];
            };
            if(time - _engineTime > 10)then
            {
                // Group rebuilding must run where the AI group is local. Ask
                // DMS ownership to return to the server and retry next pass.
                if (!isNull _group && {!local _group}) exitWith
                {
                    _localityReturnRequested = true;
                    _group setVariable ["DMS_LockLocality", true];
                    _group setGroupOwner 2;
                };

                _logDetail = format ["[OCCUPATION:Unstuck]:: %4 (%1) is stuck,attempting to unstick from %2 @ %3",_vehicleType,_curPos,time,_vehicleName]; 
                [_logDetail] call SC_fnc_log;
                                
                _vehicle setVariable["engineTime",-1];
                
                _vehicle setVectorUp [0,0,1];
                                    
                _originalSpawnLocation = _vehicle getVariable "SC_vehicleSpawnLocation";
				_radius = 2000;
                _group = group _vehicle;
				
				// Remove dead units from the group
				{
					if(!alive _x) then { [_x] join grpNull; };     
				}forEach units _group;				
				
                _vehClass = typeOf _vehicle;

                if(_vehicle isKindOf "LandVehicle") then
                {
					_tempLocation = _vehicle getVariable "SC_vehicleSpawnLocation";
					_originalSpawnLocation = _tempLocation select 0;
					_radius = _tempLocation select 1;
					_tempPos = _curPos findEmptyPosition [0,150,_vehClass];
                    if ((count _tempPos) >= 2) then
                    {
                        _newPos = [_tempPos select 0, _tempPos select 1, 0];
                        _vehicle setPosATL _newPos;
                        _vehicleMoved = true;
                    }
                    else
                    {
                        _newPos = _curPos;
                        _logDetail = format ["[OCCUPATION:Unstuck]:: No safe relocation position found for %1 (%2) at %3",_vehicleName,_vehClass,_curPos];
                        [_logDetail] call SC_fnc_log;
                    };
                };
                
                if(_vehicle isKindOf "Ship") then
                {
					_tempLocation = _vehicle getVariable "SC_vehicleSpawnLocation";
					_originalSpawnLocation = _tempLocation select 0;
					_radius = _tempLocation select 1;
					_newPos = _curPos;  
                };
                
                if(_vehicle isKindOf "Air") then
                {
					_tempLocation = _vehicle getVariable "SC_vehicleSpawnLocation";
					_originalSpawnLocation = _tempLocation select 0;
					_radius = _tempLocation select 1;
					_newPos = _curPos;    
                };
                
                _side = side _group;
                _group2 = createGroup _side;
                _group2 setVariable ["DMS_AllowFreezing",false];
				[_group2,false] call DMS_fnc_FreezeToggle;
                _group2 setVariable ["DMS_LockLocality",false];
                _group2 setVariable ["DMS_SpawnedGroup",true];
                _group2 setVariable ["DMS_Group_Side", _side];
                _group2 setVariable ["Vcm_Disable",true,true];
                [_vehicle] joinSilent _group2;
                
                {	
                    _unit = _x;           
                    //[_unit] joinSilent grpNull;
                    [_unit] joinSilent _group2;   
                    _unit enableAI "FSM"; 
                    _unit enableAI "MOVE";  
                    reload _unit;
                }foreach units _group;  
                deleteGroup _group;                           
                _group = _group2;
                
                _GroupLeader = leader (group _vehicle); 
                _GroupLeader doMove _originalSpawnLocation;
                [_group2, _originalSpawnLocation, _radius] call bis_fnc_taskPatrol;
                _group2 setBehaviour "AWARE";
                _group2 setCombatMode "RED"; 
                _logDetail = if (_vehicleMoved) then
                {
                    format ["[OCCUPATION:Unstuck]:: %6 (%1) was stuck and was moved from %2 to %3 resetting patrol around point %5 @ %4",_vehicleType,_curPos,_newPos, time,_originalSpawnLocation,_vehicleName]
                }
                else
                {
                    format ["[OCCUPATION:Unstuck]:: %5 (%1) was stuck at %2; no safe relocation position was found, patrol reset around point %4 @ %3",_vehicleType,_curPos,time,_originalSpawnLocation,_vehicleName]
                };
                [_logDetail] call SC_fnc_log;
                
            };
        };
    };
    _vehicle setVariable["vehPos",_newPos];
};

if (_localityReturnRequested) exitWith {};

{
    if(!alive _x) then { [_x] join grpNull; };
}forEach units _group;

if(count units _group == 0) then
{
    _vehicle setVariable ["SC_assignedDriver", nil,true];
    _vehicle setVehicleLock "UNLOCKED";
    _vehicle lock 1;
    _vehicle setVariable ["ExileIsLocked", 0, true];  
	[_vehicle]  call SC_fnc_vehicleDestroyed;
};

