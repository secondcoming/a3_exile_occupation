
if (SC_occupyLootCratesMarkers) then
{
	// Delete the map marker on a loot crate when a player gets in range

	for "_i" from 1 to SC_numberofLootCrates do
	{
		_markerName = format ["loot_marker_%1", _i];
		_pos = getMarkerPos _markerName;
		
		if(!isNil "_pos") then
		{
			
			if([_pos, 15] call ExileClient_util_world_isAlivePlayerInRange) then
			{ 
				deleteMarker _markerName; 
				_logDetail =  format ["[OCCUPATION:LootCrates]:: marker %1 removed at %2",_markerName,time];
				[_logDetail] call SC_fnc_log;
			};
			
		};
	};						
};
