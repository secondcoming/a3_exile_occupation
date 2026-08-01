if (!isServer) exitWith {}; // Проверка на сервер

_logDetail = format ["[OCCUPATION Static]:: Starting Monitor"];
[_logDetail] call SC_fnc_log;

private["_wp", "_wp2", "_wp3"];

_middle = worldSize / 2; // Центр карты
_spawnCenter = [_middle, _middle, 0]; // Центр точки спавна
_maxDistance = _middle; // Максимальный радиус

_maxAIcount = SC_maxAIcount;
_minFPS = SC_minFPS;
_scaleAI = SC_scaleAI;

_currentPlayerCount = count playableUnits;
if (_currentPlayerCount > _scaleAI) then {
    _maxAIcount = _maxAIcount - (_currentPlayerCount - _scaleAI);
};

// Проверка FPS сервера
if (diag_fps < _minFPS) exitWith {
    _logDetail = format ["[OCCUPATION Static]:: Held off spawning more AI as the server FPS is only %1", diag_fps];
    [_logDetail] call SC_fnc_log;
};

_aiActive = { !isPlayer _x } count allunits;

// Проверка количества активных AI
if (!(SC_staticIgnoreAICount) && (_aiActive >= _maxAIcount)) exitWith {
    _logDetail = format ["[OCCUPATION Static]:: %1 active AI, so not spawning AI this time", _aiActive];
    [_logDetail] call SC_fnc_log;
};

// Создание статических AI
if (!isNil "SC_staticBandits") then { [SC_staticBandits, "bandit"] call SC_fnc_spawnStatics; };
if (!isNil "SC_staticSurvivors") then { [SC_staticSurvivors, "survivor"] call SC_fnc_spawnStatics; };

_logDetail = "[OCCUPATION Static]: Ended";
[_logDetail] call SC_fnc_log;
