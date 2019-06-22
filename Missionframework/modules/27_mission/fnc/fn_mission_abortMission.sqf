#include "script_component.hpp"
/*
    KPLIB_fnc_mission_abortMission

    File: fn_mission_abortMission.sqf
    Author: KP Liberation Dev Team - https://github.com/KillahPotatoes
    Date: 2019-06-13
    Last Update: 2019-06-22
    License: GNU General Public License v3.0 - https://www.gnu.org/licenses/gpl-3.0.html
    Public: No

    Description:
        Aborts the given mission.

    Parameter(s):
        _mission - String of the mission [STRING, defaults to ""]

    Returns:
        Function reached the end [BOOL]
*/

params [
    ["_mission", "", [""]]
];

// Exit if one of the condition isn't true
if (_mission isEqualTo "") exitWith {
    false
};

// Get data from namespace
private _missionData = MGVAR(_mission, []);
private _runningMissions = MGVAR("runningMissions", []);
private _cost = _missionData select 9;
_cost params [
    "_costSupply",
    "_costAmmo",
    "_costFuel",
    "_costIntel"
];
private _FOB = (_runningMissions select {(_x select 0) isEqualTo _mission}) select 1;
private _crateCapacity = 0;
private _crateCount = 0;

// Check if the mission is a buyable mission and if there's enough empty storage capacity
if !(_missionData select 0) then {
    private _supplyCrates = ceil (_costSupply / KPLIB_param_crateVolume);
    private _ammoCrates = ceil (_costAmmo / KPLIB_param_crateVolume);
    private _fuelCrates = ceil (_costFuel / KPLIB_param_crateVolume);
    private _crateCount = _supplyCrates + _ammoCrates + _fuelCrates;
    private _storages = [getMarkerPos _FOB, KPLIB_param_fobRange] call KPLIB_fnc_resources_getStorages;

    {
        _crateCapacity = _crateCapacity + ([_x] call KPLIB_fnc_resources_getStorageSpace);
    } forEach _storages;
};

// Exit if there's not enough storage
if (_crateCapacity < _crateCount) exitWith {
    false
};

// Delete the mission from the running mission data
_missionData deleteAt (_missionData findIf {_x select 0 isEqualTo _mission});

// Refund the costs
if !(_cost isEqualTo [0, 0, 0, 0]) then {
    [_FOB, _costSupply, _costAmmo, _costFuel] call KPLIB_fnc_resources_refund;
    [_costIntel] call KPLIB_fnc_resources_addIntel;
};

// Execute the abort function via server event
["KPLIB_missionExec", [_missionData select 2]] call CBA_fnc_serverEvent;

true
