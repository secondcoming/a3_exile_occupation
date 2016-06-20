// Unstuck based on a function written by Chris (infiSTAR)
// http://pastebin.com/73pjvXPw


private["_vehicle","_curPos","_oldvehPos","_engineTime","_newPos"];
_vehicle = _this select 0;

if(isNil "_vehicle") exitWith{};

if(count(crew _vehicle) > 0)then
{
    _vehicleType = TypeOf _vehicle;
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

                _logDetail = format ["[OCCUPATION:Unstuck]:: %1 is stuck,attempting to unstick from %2 @ %3",_vehicleType,_curPos,time]; 
                [_logDetail] call SC_fnc_log;
                                
                _vehicle setVariable["engineTime",-1];
                
                _vehicle setVectorUp [0,0,1];
                                    
                _originalSpawnLocation = _vehicle getVariable "SC_vehicleSpawnLocation";
                _group = group _vehicle;
                _vehClass = typeOf _vehicle;

                if(_vehicle isKindOf "LandVehicle") then
                {
                    _tempPos = _curPos findEmptyPosition [0,150,_vehClass];
                    _newPos = [_tempPos select 0, _tempPos select 1, 0];                                           
                };
                
                if(_vehicle isKindOf "Ship") then
                {
                    _newPos = [_curPos, 5, 100, 3, 2, 20, 0] call BIS_fnc_findSafePos; 
                    _newPos = _curPos;
                    _vehicle setDamage 0.2; 
                };
                
                if(_vehicle isKindOf "Air") then
                {
                    _newPos = _curPos;    
                };
                
                _side = side _group;
                _group2 = createGroup _side;
                _group2 setVariable ["DMS_AllowFreezing",false,true];
                _group2 setVariable ["DMS_LockLocality",nil];
                _group2 setVariable ["DMS_SpawnedGroup",true];
                _group2 setVariable ["DMS_Group_Side", _side];
                [_vehicle] joinSilent _group2;
                
                {	
                    _unit = _x;           
                    [_unit] joinSilent grpNull;
                    [_unit] joinSilent _group2;   
                    _unit enableAI "FSM"; 
                    _unit enableAI "MOVE";  
                    reload _unit;
                }foreach units _group;  
                                            
                
                _GroupLeader = leader (group _vehicle); 
                _GroupLeader doMove _originalSpawnLocation;
                [_group2, _originalSpawnLocation, 2000] call bis_fnc_taskPatrol;
                _group2 setBehaviour "AWARE";
                _group2 setCombatMode "RED"; 

                _logDetail = format ["[OCCUPATION:Unstuck]:: %1 was stuck and was moved from %2 to %3 resetting patrol around point %5 @ %4",_vehicleType,_curPos,_newPos, time,_originalSpawnLocation]; 
                [_logDetail] call SC_fnc_log;
                
            };
        };
    };
    _vehicle setVariable["vehPos",_newPos];
};

_group = group _vehicle;

// Remove dead units from the group
{
    if(!alive _x) then { [_x] join grpNull; };     
}forEach units _group;

if(count units _group > 0) then
{
    _vehicle lock 0;			
    _vehicle setVehicleLock "UNLOCKED";
    _vehicle setVariable ["ExileIsLocked", 0, true];      
};

