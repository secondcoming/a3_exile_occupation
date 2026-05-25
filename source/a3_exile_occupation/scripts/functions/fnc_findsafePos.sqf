private _roadSpawn      = _this select 0;
private _waterSpawn     = _this select 1;
private _inWater        = 0;
private _position       = [0,0,0];
private _nearestRoad    = [0,0,0];


private _middle     = worldSize/2;
private _pos 		= [_middle,_middle,0];
private _maxDist 	= _middle - 100;

if (worldName == 'Esseker') then 
{ 
	_pos = [6502,6217,0];
    _maxDist = 5000;
};

if (worldName == 'Chernarus') then 
{ 
	_maxDist = _middle - 1500;
};

if(_roadSpawn) then
{
    _maxDist = _maxDist - 1400;
};


if(_waterSpawn) then
{
    _inWater = 2;    
}
else
{
    _inWater = 0;    
};

_validspot	= false;

while{!_validspot} do 
{
	sleep 1;
    _tempPosition = [_pos,0,_maxDist,15,_inWater,20,0] call BIS_fnc_findSafePos;
    _position = [_tempPosition select 0, _tempPosition select 1, 0];
    _validspot = true;

    if(_roadSpawn) then
    {
        
        // Get position of nearest roads
        _nearRoads = _position nearRoads 500;
        if (isNil "_nearRoads" OR count _nearRoads == 0) then
        { 
            _validspot = false;  
        }
        else
        {
            _nearestRoad = _nearRoads select 0;
            _position = position _nearestRoad;
			_isEmpty = !(_position isFlatEmpty  [10, -1, -1, -1, -1, false, player] isEqualTo []); // Check if there is 15m space around the road position to try and stop vehicles spawning on dirt tracks on Tanoa
			if(!_isEmpty) then 
			{ 
				_validspot = false;  
			};                   
        };        
    };
    
    _isOverWater = surfaceIsWater _position;
    
    if(!_waterSpawn && _isOverWater) then
    {
        _validspot = false;  
    };
    
    if(_validspot) then
    {
        _validspot = [ _position ] call SC_fnc_isSafePos;     
    };      
    if (isNil "_validspot") then { _validspot	= false; };   
};

_position	
