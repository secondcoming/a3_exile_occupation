params ["_vehicle"];

clearMagazineCargoGlobal _vehicle;
clearWeaponCargoGlobal _vehicle;
clearItemCargoGlobal _vehicle;

private _items = missionNamespace getVariable ["SC_occupyVehicleCargoItems", []];
private _weapons = missionNamespace getVariable ["SC_occupyVehicleCargoWeapons", []];

if !(_items isEqualTo []) then
{
	for "_i" from 1 to (1 + random 5) do
	{
		_vehicle addItemCargoGlobal [selectRandom _items, 1];
	};
};

if !(_weapons isEqualTo []) then
{
	for "_i" from 1 to (1 + random 2) do
	{
		private _weapon = selectRandom _weapons;
		private _magazines = getArray (configFile >> "CfgWeapons" >> _weapon >> "magazines");
		_vehicle addWeaponCargoGlobal [_weapon, 1];
		if !(_magazines isEqualTo []) then
		{
			_vehicle addMagazineCargoGlobal [_magazines select 0, round random 3];
		};
	};
};
