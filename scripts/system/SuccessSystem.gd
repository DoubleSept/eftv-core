extends Node

var done = false

const MINUTE_PERIOD = 60
var time = 0

func _ready():
	SaveSystem.connect("run_finished", self, "_on_run_finished")
	SaveSystem.connect("new_secret_found", self, "_on_new_secret_found")
	if Steam.is_init() && not done:
		done = true
		Steam.user_stats.set_stat("secrets_found", len(SaveSystem.gameData[SaveSystem.KEY_SECRET]))
		var secret_qty = Steam.user_stats.get_stat("secrets_found")
		print("Number secrets")
		print(secret_qty)
		print(len(SaveSystem.gameData[SaveSystem.KEY_SECRET]))

func add_minute():
	var minute = Steam.user_stats.get_stat("time_played") + 1
	Steam.user_stats.set_stat("time_played", minute)

func _process(delta):
	time += delta
	if time > MINUTE_PERIOD:
		time -= MINUTE_PERIOD
		add_minute()

func _on_run_finished(run_id):
	Steam.set_achievement(run_id)

func _on_new_secret_found():
	var found = Steam.user_stats.get_stat("secrets_found") + 1
	Steam.user_stats.set_stat("secrets_found", found)
