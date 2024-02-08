extends Node

var done = false

const MINUTE_PERIOD = 60
var time = 0

func _ready():
	SaveSystem.connect("run_finished", self, "_on_run_finished")
	SaveSystem.connect("new_secret_found", self, "_on_new_secret_found")

func add_minute():
	var old_minute = Steam.user_stats.get_stat("time_played")
	if old_minute != null :
		var minute = old_minute + 1
		Steam.user_stats.set_stat("time_played", minute)

func _process(delta):
	time += delta
	if time > MINUTE_PERIOD:
		time -= MINUTE_PERIOD
		add_minute()

	if Steam.is_init() && not done:
		done = true
		print_debug("Cleared ?" + str (Steam.user_stats.get_stat("secrets_found")))
		print_debug("Cleared ?" + str (Steam.user_stats.get_stat("time_played")))
		Steam.user_stats.set_stat(
			"secrets_found", 0)
		Steam.user_stats.set_stat(
			"secrets_found",
			len(SaveSystem.gameData[SaveSystem.KEY_SECRET]))
		print(len(SaveSystem.gameData[SaveSystem.KEY_SECRET]))
		Steam.clear_achievement("123_MINUTES")
		Steam.clear_achievement("secret_4")
		Steam.clear_achievement("secret_8")

func _on_run_finished(run_id):
	Steam.set_achievement(run_id)

func _on_new_secret_found():
	var found = Steam.user_stats.get_stat("secrets_found")
	if found != null:
		Steam.user_stats.set_stat("secrets_found", found + 1)
