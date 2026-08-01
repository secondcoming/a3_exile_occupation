// Get the variables from the event handler
_unit 			= _this select 0;

_staticUID = _unit getVariable "SC_staticUID";
_spawnPosition = _unit getVariable "SC_staticSpawnPos";
_unit removeAllMPEventHandlers  "mphit";

_group = group _unit;

if (({alive _x && {!(_x isEqualTo _unit)}} count units _group) == 0) then
{
    SC_liveStaticGroups = SC_liveStaticGroups - [_staticUID,_spawnPosition]; 
    if(SC_mapMarkers) then 
    {
        deleteMarker format ["%1", _staticUID];  
    };    
};
