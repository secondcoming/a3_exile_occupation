////////////////////////////////////////////////////////////////////////
//
//		Exile Occupation by second_coming
//		http://www.exilemod.com/profile/60-second_coming/
//
//      For support, visit:
//      http://www.exilemod.com/topic/12517-release-exile-occupation-roaming-ai-more/
//
//		This script uses the fantastic DMS by Defent and eraser1:
//		http://www.exilemod.com/topic/61-dms-defents-mission-system/
//
////////////////////////////////////////////////////////////////////////

// Shared Config for each occupation monitor


SC_debug 				    = false;			    // set to true to turn on debug features (not for live servers) 
SC_extendedLogging          = false;                // set to true for additional logging
SC_processReporter          = true;                 // log the a list of active server processes every 60 seconds (useful for debugging server problems)
SC_infiSTAR_log			    = true;		            // true Use infiSTAR logging, false logs to server rpt
SC_maxAIcount 			    = 100;					// the maximum amount of AI, if the AI count is above this then additional AI won't spawn
SC_mapMarkers			    = false;			    // Place map markers at the occupied areas (occupyPlaces and occupyMilitary only) true/false
SC_minFPS 				    = 5;					// any lower than minFPS on the server and additional AI won't spawn
SC_scaleAI 				    = 10; 					// any more than _scaleAI players on the server and _maxAIcount is reduced for each extra player

SC_removeUserMapMarkers     = true;                 // true to delete map markers placed by players every 10 seconds

SC_fastNights               = false;                // true if you want night time to go faster than daytime
SC_fastNightsStarts         = 18;                   // Start fast nights at this hour (24 hour clock) eg. 18 for 6pm
SC_fastNightsMultiplierNight= 16;                   // the time multiplier to use at night (12 = 12x speed)
SC_fastNightsEnds           = 6;                    // End fast nights at this hour (24 hour clock) eg. 6 for 6am
SC_fastNightsMultiplierDay  = 4;                    // the time multiplier to use during daylight hours (4 = 4x speed)

SC_useWaypoints			    = true;					// When spawning AI create waypoints to make them enter buildings (can affect performance when the AI is spawned and the waypoints are calculated)

                                                    // Distance limits for selecting safe places to spawn AI
SC_minDistanceToSpawnZones  = 500;                  // Minimum distance in metres to the nearest spawn zone
SC_minDistanceToTraders     = 500;                  // Minimum distance in metres to the nearest trader zone
SC_minDistanceToTerritory   = 500;                  // Minimum distance in metres to the nearest player territory
SC_minDistanceToPlayer      = 250;                  // Minimum distance in metres to the nearest player


SC_occupyRandomSpawn        = false;                // (WORK IN PROGRESS, NOT WORKING YET) true if you want random spawning AI that hunt for nearby players
SC_randomSpawnMinPlayers    = 1;                    // Minimum number of players to be online before random spawning AI can spawn
SC_randomSpawnMaxAI         = 5;                    // Maximum amount of random AI groups allowed at any time
SC_randomSpawnIgnoreCount	= true;					// true if you want spawn random AI groups regardless of overall AI count (they still count towards the total though)

SC_occupyPlaces 			= true;				    // true if you want villages,towns,cities patrolled by bandits

SC_occupyVehicle			= true;					// true if you want to have roaming AI vehicles
SC_occupyVehicleIgnoreCount	= true;					// true if you want spawn vehicles regardless of overall AI count
SC_occupyVehiclesLocked		= false;				// true if AI vehicles to stay locked until all the linked AI are dead

SC_occupyTraders            = false;                // (WORK IN PROGRESS, NOT WORKING YET) true if you want to create trader camps at positions specified in SC_occupyTraderDetails
SC_occupyTraderDetails      = [
                                ["Bubendorf Traders",[3896,14467,0],"trader1.sqf",true],
                                ["Schrattendamm Traders",[10584,4975,0],"trader1.sqf",true]
                              ];  //["Name",[x,y,z],"filename",true] trader name, location, safezone true/false
                                                    
SC_SurvivorsChance          = 20;                   // chance in % to spawn survivors instead of bandits (for places and land vehicles)
SC_occupyPlacesSurvivors	= true;	                // true if you want a chance to spawn survivor AI as well as bandits (SC_occupyPlaces must be true to use this option)
SC_occupyVehicleSurvivors	= false;                // true if you want a chance to spawn survivor AI as well as bandits (SC_occupyVehicle must be true to use this option)
SC_SurvivorsFriendly        = true;                 // true if you want survivors to be friendly to players (until they are attacked by players)
                                                    // false if you want survivors to be aggressive to players

// Possible equipment for survivor AI to spawn with 
// spawning survivors without vests or backpacks will result in them having no ammunition                                                   
SC_SurvivorUniforms         = ["Exile_Uniform_BambiOverall"]; 
SC_SurvivorVests            = ["V_BandollierB_blk","V_BandollierB_cbr","V_BandollierB_khk","V_BandollierB_oli"];  
SC_SurvivorHeadgear         = []; 
SC_SurvivorWeapon           = ["arifle_MXC_F","arifle_TRG20_F"];
SC_SurvivorWeaponAttachments= [];
SC_SurvivorMagazines        = ["Exile_Item_Vishpirin","Exile_Item_Bandage"];
SC_SurvivorPistol           = ["hgun_Rook40_F"];
SC_SurvivorPistolAttachments= [];
SC_SurvivorAssignedItems    = ["ItemMap","ItemCompass","ItemRadio","ItemWatch","Exile_Item_XM8"]; // all these items will be added
SC_SurvivorLauncher         = [];
SC_SurvivorBackpack         = [];

// Possible equipment for bandit AI to spawn with 
// spawning bandits without vests or backpacks will result in them having no ammunition                                                    
SC_BanditUniforms           = ["U_IG_Guerilla1_1","U_IG_Guerilla2_1","U_IG_Guerilla2_2","U_IG_Guerilla2_3","U_IG_Guerilla3_1","U_BG_Guerilla2_1","U_IG_Guerilla3_2","U_BG_Guerrilla_6_1","U_BG_Guerilla1_1","U_BG_Guerilla2_2","U_BG_Guerilla2_3","U_BG_Guerilla3_1"]; 
SC_BanditVests              = ["V_BandollierB_blk","V_BandollierB_cbr","V_BandollierB_khk","V_BandollierB_oli"]; 
SC_BanditHeadgear           = ["H_Shemag_khk","H_Shemag_olive","H_Shemag_olive_hs","H_Shemag_tan","H_ShemagOpen_khk","H_ShemagOpen_tan"];
SC_BanditWeapon             = ["LMG_Zafir_F","arifle_Katiba_C_F","arifle_Katiba_F","arifle_Katiba_GL_F","arifle_MXC_Black_F","arifle_MXC_F","arifle_TRG20_F","arifle_TRG21_F","arifle_TRG21_GL_F"];
SC_BanditWeaponAttachments  = [];
SC_BanditMagazines          = ["Exile_Item_InstaDoc","Exile_Item_Vishpirin","Exile_Item_Bandage","Exile_Item_DuctTape","Exile_Item_PlasticBottleFreshWater","Exile_Item_Energydrink","Exile_Item_EMRE","Exile_Item_Cheathas","Exile_Item_Noodles","Exile_Item_BBQSandwich","Exile_Item_Catfood"];
SC_BanditPistol             = ["hgun_ACPC2_F","hgun_P07_F","hgun_Pistol_heavy_01_F","hgun_Pistol_heavy_02_F","hgun_Rook40_F"];
SC_BanditPistolAttachments  = [];
SC_BanditAssignedItems      = ["ItemMap","ItemCompass","ItemRadio","ItemWatch"]; // all these items will be added
SC_BanditLauncher           = [];
SC_BanditBackpack           = ["B_HuntingBackpack","B_Kitbag_cbr","B_Kitbag_mcamo","B_Kitbag_sgg","B_OutdoorPack_blk","B_OutdoorPack_blu","B_OutdoorPack_tan","B_TacticalPack_blk","B_TacticalPack_mcamo","B_TacticalPack_ocamo","B_TacticalPack_oli","B_TacticalPack_rgr"];  

SC_occupyStatic	 		    = false;		    	// true if you want to add AI in specific locations
SC_staticBandits            = [                     //[[pos],ai count,radius,search buildings]	
    
                              ];     
SC_staticSurvivors          = [	                    //[[pos],ai count,radius,search buildings]
                                //[[3770,8791,0],8,250,true]	
                              ];      

SC_occupySky				= true;					// true if you want to have roaming AI helis
SC_occupySea				= false;		        // true if you want to have roaming AI boats

SC_occupyTransport 	        = true;					// true if you want pubic transport (travels between traders)
SC_occupyTransportClass 	= ["Exile_Chopper_Mohawk_FIA","Exile_Chopper_Mohawk_FIA","Exile_Car_LandRover_Urban"]; // to always use the same vehicle, specify one option only
SC_occupyTransportStartPos  = [];                   // if empty defaults to map centre
SC_occupyTransportAnnounce  = false;                 // true if you want the pilot/driver to talk to passengers in vehicle chat, false if not
SC_occupyTransportGetIn     = ["Hello and welcome to Occupation Transport. We hope you enjoy the ride!"];
SC_occupyTransportGetOut    = ["Thanks for using Occupation Transport. We hope to see you again!"];
SC_occupyTransportMessages  = ["You guys should totally visit our website","No mooning out of the window please!","Scream if you want to go faster!","frrt"];


SC_occupyLootCrates		    = true;					// true if you want to have random loot crates with guards
SC_numberofLootCrates       = 6;                    // if SC_occupyLootCrates = true spawn this many loot crates (overrided below for Namalsk)
SC_LootCrateGuards          = 7;                    // number of AI to spawn at each crate
SC_LootCrateGuardsRandomize = true;                 // Use a random number of guards up to a maximum = SC_numberofGuards (so between 1 and SC_numberofGuards)
SC_occupyLootCratesMarkers	= true;					// true if you want to have markers on the loot crate spawns

SC_ropeAttach               = false;                // Allow lootcrates to be airlifted (for SC_occupyLootCrates and SC_occupyHeliCrashes)

// Array of possible common items to go in loot crates ["classname",fixed amount,random amount]
// ["Exile_Item_Matches",1,2] this example would add between 1 and 3 Exile_Item_Matches to the crate (1 + 0 to 2 more)
// to add a fixed amount make the second number 0
SC_LootCrateItems     = [
                                    ["Exile_Melee_Axe",1,0],
                                    ["Exile_Item_GloriousKnakworst",1,2],
                                    ["Exile_Item_PlasticBottleFreshWater",1,2],
                                    ["Exile_Item_Beer",5,1],
                                    ["Exile_Item_BaseCameraKit",0,2],
                                    ["Exile_Item_InstaDoc",1,1],
                                    ["Exile_Item_Matches",1,0],
                                    ["Exile_Item_CookingPot",1,0],                      
                                    ["Exile_Item_MetalPole",1,0],
                                    ["Exile_Item_LightBulb",1,0],
                                    ["Exile_Item_FuelCanisterEmpty",1,0],
                                    ["Exile_Item_WoodPlank",1,8],
                                    ["Exile_Item_woodFloorKit",1,2],
                                    ["Exile_Item_WoodWindowKit",1,1],
                                    ["Exile_Item_WoodDoorwayKit",1,1],
                                    ["Exile_Item_WoodFloorPortKit",1,2],   
                                    ["Exile_Item_Laptop",0,1],
                                    ["Exile_Item_CodeLock",0,1],
									["Exile_Item_Cement",2,10],
									["Exile_Item_Sand",2,10]
                            ];

SC_blackListedAreas         =   [
                                    [[3810,8887,0],500,"Chernarus"],    // Vybor Occupation DMS Static Mission
                                    [[12571,14337,0],500,"Altis"],      // Neochori Occupation DMS Static Mission
                                    [[3926,7523,0],500,"Namalsk"],      // Norinsk Occupation DMS Static Mission  
                                    [[3926,7523,0],500,"Napf"]          // Lenzburg Occupation DMS Static Mission                            
                                ];


SC_occupyHeliCrashes		= true;					// true if you want to have Dayz style helicrashes
SC_HeliCrashesSmoke			= false;                // true if you want smoke, false if not
SC_numberofHeliCrashesFire  = true;                 // true if you ALSO want the crash on fire, false if you just want smoke. Needs SC_HeliCrashesSmoke set to true
SC_numberofHeliCrashes      = 5;                    // if SC_occupyHeliCrashes = true spawn this many loot crates (overrided below for Namalsk)

// Array of wrecks which can be used at heli crashes
SC_HeliCrashClassToUse 		    =   [ 
								"Land_UWreck_MV22_F",
								"Land_Wreck_BRDM2_F",
								"Land_Wreck_Car2_F",
								"Land_Wreck_Car3_F",
								"Land_Wreck_Car_F",
								"Land_Wreck_Commanche_F",
								"Land_Wreck_Offroad2_F",
								"Land_Wreck_Offroad_F",
								"Land_Wreck_Traw2_F",
								"Land_Wreck_Traw_F",
								"Land_Wreck_Truck_dropside_F",
								"Land_Wreck_Truck_F"
								];

// Array of possible common items to go in heli crash crates ["classname",fixed amount,random amount] NOT INCLUDING WEAPONS
// ["HandGrenade",0,2] this example would add between 0 and 2 HandGrenade to the crate (fixed 0 plus 0-2 random)
// to add a fixed amount make the second number 0
SC_HeliCrashItems           =   [
                                    ["B_Parachute",1,1],
                                    ["H_CrewHelmetHeli_B",1,1],
                                    ["ItemGPS",0,1],
                                    ["Exile_Item_InstaDoc",0,1],
                                    ["Exile_Item_PlasticBottleFreshWater",2,2],
                                    ["Exile_Item_EMRE",2,2]                                 
                                ];

SC_HeliCrashRareItems       =   [
                                    ["HandGrenade",0,2],
                                    ["APERSBoundingMine_Range_Mag",0,2]                 
                                ];
SC_HeliCrashRareItemChance  = 10;                   // percentage chance to spawn each SC_HeliCrashRareItems
                                
// Array of possible weapons to place in the crate                            
SC_HeliCrashWeapons         =   [
                                    "srifle_DMR_02_camo_F",
                                    "srifle_DMR_03_woodland_F",
                                    "srifle_DMR_04_F",
                                    "srifle_DMR_05_hex_F"
                                ];
                                
SC_HeliCrashWeaponsAmount   = [1,3]; // [fixed amount to add, random amount to add]
SC_HeliCrashMagazinesAmount = [2,2]; // [fixed amount to add, random amount to add]

SC_minimumCrewAmount        = 2;     // Maximum amount of AI allowed in a vehicle (applies to ground, air and sea vehicles)
SC_maximumCrewAmount        = 6;     // Maximum amount of AI allowed in a vehicle (applies to ground, air and sea vehicles) 
                                     // (essential crew like drivers and gunners will always spawn regardless of these settings)

// Settings for roaming ground vehicle AI
SC_maxNumberofVehicles 	    = 4;	

// Array of arrays of ground vehicles which can be used by AI patrols (the number next to next vehicle is the maximum amount of that class allowed, 0 for no limit)				
SC_VehicleClassToUse 		=   [	
                                    ["Exile_Car_LandRover_Green",0],
                                    ["Exile_Bike_QuadBike_Black",2],
                                    ["Exile_Car_UAZ_Open_Green",2] 
                                ];
SC_VehicleClassToUseRare	=   [	
                                    ["Exile_Car_Hunter",1],
                                    ["Exile_Car_HEMMT",1],
                                    ["Exile_Car_Zamak",1],
                                    ["Exile_Car_Offroad_Armed_Guerilla12",1],
                                    ["Exile_Car_Offroad_Armed_Guerilla03",1],
                                    ["Exile_Car_Tempest",1] 
                                ];

// Settings for roaming airborne AI (non armed helis will just fly around)
SC_maxNumberofHelis		    = 1;

// Array of aircraft which can be used by AI patrols (the number next to next vehicle is the maximum amount of that class allowed, 0 for no limit)
SC_HeliClassToUse 		    =   [ ["Exile_Chopper_Huey_Armed_Green",0] ];

// Settings for roaming seaborne AI (non armed boats will just sail around)
SC_maxNumberofBoats		    = 1;

// Array of boats which can be used by AI patrols (the number next to next vehicle is the maximum amount of that class allowed, 0 for no limit)
SC_BoatClassToUse 		    =   [	
                                    ["B_Boat_Armed_01_minigun_F",1],
                                    ["I_Boat_Armed_01_minigun_F",1],
                                    ["O_Boat_Transport_01_F",0],
                                    ["Exile_Boat_MotorBoat_Police",1] 
                                ];
		
SC_useRealNames         = true;
        
// Arrays of names used to generate names for AI
SC_SurvivorFirstNames   = ["John","Dave","Steve","Rob","Richard","Bob","Andrew","Nick","Adrian","Mark","Adam","Will","Graham"]; 
SC_SurvivorLastNames    = ["Smith","Jones","Davids","Johnson","Jobs","Andrews","White","Brown","Taylor","Walker","Williams","Clarke","Jackson","Woods"]; 
SC_BanditFirstNames     = ["Alex","Nikita","George","Daniel","Adam","Alexander","Sasha","Sergey","Dmitry","Anton","Jakub","Vlad","Maxim","Oleg","Denis","Wojtek"]; 
SC_BanditLastNames      = ["Dimitrov","Petrov","Horvat","Novak","Dvorak","Vesely","Horak","Hansen","Larsen","Tamm","Ivanov","Pavlov","Virtanen"]; 


SC_occupyMilitary 		    = false;			    // true if you want military buildings patrolled

// Array of buildings to add military patrols to
SC_buildings                = [	"Land_TentHangar_V1_F","Land_Hangar_F",
                                "Land_Airport_Tower_F","Land_Cargo_House_V1_F",
                                "Land_Cargo_House_V3_F","Land_Cargo_HQ_V1_F",
                                "Land_Cargo_HQ_V2_F","Land_Cargo_HQ_V3_F",
                                "Land_u_Barracks_V2_F","Land_i_Barracks_V2_F",
                                "Land_i_Barracks_V1_F","Land_Cargo_Patrol_V1_F",
                                "Land_Cargo_Patrol_V2_F","Land_Cargo_Tower_V1_F",
                                "Land_Cargo_Tower_V1_No1_F","Land_Cargo_Tower_V1_No2_F",
                                "Land_Cargo_Tower_V1_No3_F","Land_Cargo_Tower_V1_No4_F",
                                "Land_Cargo_Tower_V1_No5_F","Land_Cargo_Tower_V1_No6_F",
                                "Land_Cargo_Tower_V1_No7_F","Land_Cargo_Tower_V2_F",
                                "Land_Cargo_Tower_V3_F","Land_MilOffices_V1_F",
                                "Land_Radar_F","Land_budova4_winter","land_hlaska",                            
                                "Land_Vysilac_FM","land_st_vez","Land_ns_Jbad_Mil_Barracks",
                                "Land_ns_Jbad_Mil_ControlTower","Land_ns_Jbad_Mil_House",
                                "land_pozorovatelna","Land_vys_budova_p1",
                                "Land_Vez","Land_Mil_Barracks_i",
                                "Land_Mil_Barracks_L","Land_Mil_Barracks",
                                "Land_Hlidac_budka","Land_Ss_hangar",
                                "Land_Mil_ControlTower","Land_a_stationhouse",
                                "Land_Farm_WTower","Land_Mil_Guardhouse",
                                "Land_A_statue01","Land_A_Castle_Gate",
                                "Land_A_Castle_Donjon","Land_A_Castle_Wall2_30",
                                "Land_A_Castle_Stairs_A",
                                "Land_i_Barracks_V1_dam_F","Land_Cargo_Patrol_V3_F",
                                "Land_Radar_Small_F","Land_Dome_Big_F",
                                "Land_Dome_Small_F","Land_Army_hut3_long_int",
                                "Land_Army_hut_int","Land_Army_hut2_int"
                                ]; 

// namalsk specific settings (if you want to override settings for specific maps if you run multiple servers)
if (worldName == 'Namalsk') then 
{ 
	SC_maxAIcount 			= 80; 
	SC_occupySky			= false;
    SC_maxNumberofVehicles 	= 2;
    SC_numberofLootCrates 	= 3;
    SC_numberofHeliCrashes  = 2;
    SC_maxNumberofBoats		= 1;
    SC_occupyTransportClass = "Exile_Car_LandRover_Urban"; // the ikarus bus gets stuck on Namalsk
};

// Napf specific settings (if you want to override settings for specific maps if you run multiple servers)
if (worldName == 'Napf') then 
{ 
	SC_occupyTraders		= true;
};

if (SC_debug) then
{
    SC_extendedLogging          = true;
    SC_processReporter          = true;
    SC_mapMarkers			    = true;
    SC_occupyPlaces 			= true;
    SC_occupyVehicle			= true;
    SC_occupyMilitary 		    = true;
    SC_occupyStatic	 		    = true;
    SC_occupySky				= true;
    SC_occupySea				= true;
    SC_occupyTransport			= true;
    SC_occupyLootCrates		    = true;
    SC_occupyHeliCrashes		= true;	
    SC_maxNumberofVehicles 	    = 4;
    SC_maxNumberofBoats		    = 1;
    SC_maxNumberofHelis		    = 1;
    
       
};

// Don't alter anything below this point, unless you want your server to explode :)
if(!SC_SurvivorsFriendly) then 
{ 
	CIVILIAN setFriend[RESISTANCE,0]; 
};
CIVILIAN    setFriend [EAST,0]; 
CIVILIAN    setFriend [WEST,0]; 
EAST        setFriend [CIVILIAN,0]; 
WEST        setFriend [CIVILIAN,0]; 
EAST        setFriend [WEST,0]; 
WEST        setFriend [EAST,0]; 

   
SC_SurvivorSide         	= CIVILIAN;
SC_BanditSide           	= EAST;
SC_liveVehicles 			= 0;
SC_liveVehiclesArray    	= [];
SC_liveHelis	 			= 0;
SC_liveHelisArray       	= [];
SC_liveBoats	 			= 0;
SC_liveBoatsArray       	= [];
SC_liveStaticGroups         = [];
SC_transportArray       	= [];

publicVariable "SC_liveVehicles";
publicVariable "SC_liveVehiclesArray";
publicVariable "SC_liveHelis";
publicVariable "SC_liveHelisArray";
publicVariable "SC_liveBoats";
publicVariable "SC_liveBoatsArray";
publicVariable "SC_liveStaticGroups";
publicVariable "SC_numberofLootCrates";
publicVariable "SC_transportArray";
publicVariable "SC_SurvivorSide";
publicVariable "SC_BanditSide";

SC_CompiledOkay = true;