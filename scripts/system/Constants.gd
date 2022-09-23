extends Node

var isStandalone = OS.has_feature("standalone")
var isEditor = OS.has_feature("editor")
var useVR = isStandalone

var pathPart = "VR" if useVR else "NoVR"

var SCENE_MENU_TELEMETRY = "res://eftv-core/scenes/menus/TelemetryMenu/"+pathPart+".tscn"
var SCENE_MENU_MAIN = "res://eftv-core/scenes/menus/MainMenu/"+pathPart+".tscn"
var SCENE_MENU_SELECTION = "res://eftv-core/scenes/menus/SelectionMenu/"+pathPart+".tscn"
var SCENE_MENU_END_RUN = "res://eftv-core/scenes/menus/EndRunMenu/"+pathPart+".tscn"

var SCENE_MAIN = "res://eftv-core/scenes/main_"+pathPart+".tscn"
