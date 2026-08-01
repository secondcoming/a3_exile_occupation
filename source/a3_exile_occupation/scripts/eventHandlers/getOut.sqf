// Triggered if an AI unit leaves an AI vehicle

_vehicle = _this select 0;
_unit	 = _this select 2;
_driver = _vehicle getVariable "SC_assignedDriver";
_arrowClass = "Sign_Arrow_F"; 

if(!alive _unit) exitWith {};


if(side _unit == SC_SurvivorSide) then 
{
    _arrowClass = "Sign_Arrow_Green_F";    
}
else
{
    _arrowClass = "Sign_Arrow_F";     
};

if(_unit == _driver) then
{
    _arrowClass = "Sign_Arrow_Yellow_F";     
};

if(SC_debug && alive _unit && vehicle _unit != _unit) then
{
    _tag = createVehicle [_arrowClass, position _unit, [], 0, "CAN_COLLIDE"];
    _tag attachTo [_unit,[0,0,0.6],"Head"];  
}
else
{
    { deleteVehicle _x; } forEach attachedObjects _unit;    
};
