extends Node2D

onready var ap = $Animation

const FIRST_FULL_MS = 330
const FIRST_LOW_MS = 541
const SECOND_HIGH_MS = 708
const END = 1083
const SOUND_DURATION = 1416

var step = 0
var next_scene
# Called when the node enters the scene tree for the first time.
func _ready():
	yield(get_tree().create_timer(1.0), "timeout")
	ap.current_animation = "Neon"
	if(Constants.isEditor):
		get_tree().change_scene(Constants.SCENE_MENU_TELEMETRY)
	else:
		OS.window_fullscreen = true
		
	print(LevelSystem.loadExtras())

func _on_Animation_animation_finished(anim_name):
	get_tree().change_scene(Constants.SCENE_MENU_TELEMETRY)
