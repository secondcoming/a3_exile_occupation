private[
    "_side", "_uniform", "_vest", "_headgear", "_weapon", "_weaponAttachments", "_magazines",
    "_pistol", "_pistolAttachments", "_assignedItems", "_launcher", "_backpack", "_amountOfMagazines",
    "_newMagazine", "_quantity", "_weaponAttachmentsChance", "_pistolAttachmentsChance", "_backpackChance",
    "_launcherChance", "_weaponMagazinesToAdd", "_weaponMagazineAmount", "_pistolMagazinesToAdd",
    "_pistolMagazineAmount", "_launcherMagazinesToAdd", "_launcherMagazineAmount", "_loadout", "_logDetail", "_i"
];

_side	= _this select 0;

switch (_side) do 
{
    case "survivor":
    {
        if(count SC_SurvivorUniforms == 0) then { _uniform = ""; } else { _uniform  = SC_SurvivorUniforms call BIS_fnc_selectRandom; }; 
        if(count SC_SurvivorVests == 0) then { _vest = ""; } else { _vest  = SC_SurvivorVests call BIS_fnc_selectRandom; }; 
        if(count SC_SurvivorHeadgear == 0) then { _headgear = ""; } else { _headgear  = SC_SurvivorHeadgear call BIS_fnc_selectRandom; }; 
        if(count SC_SurvivorWeapon == 0) then { _weapon = ""; } else { _weapon  = SC_SurvivorWeapon call BIS_fnc_selectRandom; }; 
        if(count SC_SurvivorWeaponAttachments == 0) then { _weaponAttachments = []; } else { _weaponAttachments  = [SC_SurvivorWeaponAttachments call BIS_fnc_selectRandom]; };         
        if(count SC_SurvivorPistol == 0) then { _pistol = ""; } else { _pistol  = SC_SurvivorPistol call BIS_fnc_selectRandom; }; 
        if(count SC_SurvivorPistolAttachments == 0) then { _pistolAttachments = []; } else { _pistolAttachments  = [SC_SurvivorPistolAttachments call BIS_fnc_selectRandom]; };    
        if(count SC_SurvivorLauncher == 0) then { _launcher = ""; } else { _launcher  = SC_SurvivorLauncher call BIS_fnc_selectRandom; }; 
        if(count SC_SurvivorBackpack == 0) then { _backpack = ""; } else { _backpack  = SC_SurvivorBackpack call BIS_fnc_selectRandom; };       
        _assignedItems      = SC_SurvivorAssignedItems;
        
        _magazines          = [];
        if(count SC_SurvivorMagazines > 0) then
        {
            _amountOfMagazines  = 1 + round random (2);
            for "_i" from 1 to _amountOfMagazines do
            {
                _newMagazine    = SC_SurvivorMagazines call BIS_fnc_selectRandom;
                _quantity       = 1 + round random (2);
                _magazines pushBack [_newMagazine,_quantity];    
            };             
        };    
    };
    case "bandit":
    {
        if(count SC_BanditUniforms == 0) then { _uniform = ""; } else { _uniform  = SC_BanditUniforms call BIS_fnc_selectRandom; }; 
        if(count SC_BanditVests == 0) then { _vest = ""; } else { _vest  = SC_BanditVests call BIS_fnc_selectRandom; }; 
        if(count SC_BanditHeadgear == 0) then { _headgear = ""; } else { _headgear  = SC_BanditHeadgear call BIS_fnc_selectRandom; }; 
        if(count SC_BanditWeapon == 0) then { _weapon = ""; } else { _weapon  = SC_BanditWeapon call BIS_fnc_selectRandom; }; 
        if(count SC_BanditWeaponAttachments == 0) then { _weaponAttachments = [""]; } else { _weaponAttachments  = [SC_BanditWeaponAttachments call BIS_fnc_selectRandom]; };         
        if(count SC_BanditPistol == 0) then { _pistol = ""; } else { _pistol  = SC_BanditPistol call BIS_fnc_selectRandom; }; 
        if(count SC_BanditPistolAttachments == 0) then { _pistolAttachments = [""]; } else { _pistolAttachments  = [SC_BanditPistolAttachments call BIS_fnc_selectRandom]; };    
        if(count SC_BanditLauncher == 0) then { _launcher = ""; } else { _launcher  = SC_BanditLauncher call BIS_fnc_selectRandom; }; 
        if(count SC_BanditBackpack == 0) then { _backpack = ""; } else { _backpack  = SC_BanditBackpack call BIS_fnc_selectRandom; };  
        _assignedItems = SC_BanditAssignedItems;
       
        _magazines = [];
        if(count SC_BanditMagazines > 0) then
        {
            _amountOfMagazines  = 1 + round random (2);
            for "_i" from 1 to _amountOfMagazines do
            {
                _newMagazine    = SC_BanditMagazines call BIS_fnc_selectRandom;
                _quantity       = 1 + round random (2);
                _magazines pushBack [_newMagazine,_quantity];    
            };             
        };   
    }; 
    case "cops":
    {
        if(count SC_RandomUniforms == 0) then { _uniform = ""; } else { _uniform  = SC_RandomUniforms call BIS_fnc_selectRandom; }; 
        if(count SC_RandomVests == 0) then { _vest = ""; } else { _vest  = SC_RandomVests call BIS_fnc_selectRandom; }; 
        if(count SC_RandomHeadgear == 0) then { _headgear = ""; } else { _headgear  = SC_RandomHeadgear call BIS_fnc_selectRandom; }; 
        if(count SC_RandomWeapon == 0) then { _weapon = ""; } else { _weapon  = SC_RandomWeapon call BIS_fnc_selectRandom; }; 
        if(count SC_RandomWeaponAttachments == 0) then { _weaponAttachments = [""]; } else { _weaponAttachments  = [SC_RandomWeaponAttachments call BIS_fnc_selectRandom]; };         
        if(count SC_RandomPistol == 0) then { _pistol = ""; } else { _pistol  = SC_RandomPistol call BIS_fnc_selectRandom; }; 
        if(count SC_RandomPistolAttachments == 0) then { _pistolAttachments = [""]; } else { _pistolAttachments  = [SC_RandomPistolAttachments call BIS_fnc_selectRandom]; };    
        if(count SC_RandomLauncher == 0) then { _launcher = ""; } else { _launcher  = SC_RandomLauncher call BIS_fnc_selectRandom; }; 
        if(count SC_RandomBackpack == 0) then { _backpack = ""; } else { _backpack  = SC_RandomBackpack call BIS_fnc_selectRandom; };  
        _assignedItems = SC_RandomAssignedItems;
       
        _magazines = [];
        if(count SC_RandomMagazines > 0) then
        {
            _amountOfMagazines  = 1 + round random (2);
            for "_i" from 1 to _amountOfMagazines do
            {
                _newMagazine    = SC_RandomMagazines call BIS_fnc_selectRandom;
                _quantity       = 1 + round random (2);
                _magazines pushBack [_newMagazine,_quantity];    
            };             
        };  
    }; 	
};

_weaponAttachmentsChance = round (random 100);
if(_weaponAttachmentsChance < 50) then { _weaponAttachments = [""]; };

_pistolAttachmentsChance = round (random 100);
if(_pistolAttachmentsChance < 50) then { _pistolAttachments = [""]; };

_backpackChance = round (random 100);
if(_backpackChance < 30) then { _backpack = ""; };

_launcherChance = round (random 100);
if(_launcherChance < 40 OR isNil "_launcher") then { _launcher = ""; };

// add ammo for selected main weapon
if(_weapon != "") then
{
    _weaponMagazinesToAdd = getArray (configFile >> "CfgWeapons" >> _weapon >> "magazines");
    _weaponMagazineAmount = 2 + round random (1);	
    _magazines pushBack [_weaponMagazinesToAdd select 0,_weaponMagazineAmount];    
};

// add ammo for selected pistol
if(_pistol != "") then
{
    _pistolMagazinesToAdd = getArray (configFile >> "CfgWeapons" >> _pistol >> "magazines");
    _pistolMagazineAmount = 2 + round random (1);
    _magazines pushBack [_pistolMagazinesToAdd select 0,_pistolMagazineAmount]; 
};

// add ammo for selected launcher
if(_launcher != "") then
{
    _launcherMagazinesToAdd = getArray (configFile >> "CfgWeapons" >> _launcher >> "magazines");
    _launcherMagazineAmount = 1;
    _magazines pushBack [_launcherMagazinesToAdd select 0,_launcherMagazineAmount]; 
};

_loadout = 	[
		_weapon,				// String | EG: "LMG_Zafir_F"
		_weaponAttachments,	    // Array of strings | EG: ["optic_dms","bipod_03_F_blk"]
		_magazines,			    // Array of arrays | EG: [["150Rnd_762x54_Box",2],["16Rnd_9x21_Mag",3],["Exile_Item_InstaDoc",3]]
		_pistol,				// String | EG: "hgun_Pistol_heavy_01_snds_F"
	    _pistolAttachments,     // Array of strings | EG: ["optic_MRD","muzzle_snds_acp"]
		_assignedItems,			// Array of strings | EG: ["Rangefinder","ItemGPS","NVGoggles"]
		_launcher,				// String | EG: "launch_RPG32_F"
		_headgear,				// String | EG: "H_HelmetLeaderO_ocamo"
		_uniform,				// String | EG: "U_O_GhillieSuit"
		_vest,					// String | EG: "V_PlateCarrierGL_blk"
		_backpack				// String | EG: "B_Carryall_oli"
	];

if(SC_extendedLogging) then 
{ 
    _logDetail = format["[OCCUPATION]:: %2 loadout created: %1",_loadout,_side];
    [_logDetail] call SC_fnc_log;
};  
_loadout
