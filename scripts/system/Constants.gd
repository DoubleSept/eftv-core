extends Node

const useVR = true

const pathPart = "VR" if useVR else "NoVR"

const SCENE_MENU_TELEMETRY = "res://eftv-core/scenes/menus/TelemetryMenu/"+pathPart+".tscn"
const SCENE_MENU_MAIN = "res://eftv-core/scenes/menus/MainMenu/"+pathPart+".tscn"
const SCENE_MENU_SELECTION = "res://eftv-core/scenes/menus/SelectionMenu/"+pathPart+".tscn"
const SCENE_MENU_END_RUN = "res://eftv-core/scenes/menus/EndRunMenu/"+pathPart+".tscn"

const SCENE_MAIN = "res://eftv-core/scenes/main_"+pathPart+".tscn"

const CLASSES_DIR = "res://eftv-core/scripts/classes/"
