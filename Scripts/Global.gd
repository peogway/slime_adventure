extends Node

var player_mode = 2# 1 or 2
var selected_character = 2
var best_score = 0
var best_kills = 0
var best_coins = 0
var best_time = 0
var best_wave = 1

var music = false
var sound = false

func toggle_music() :
	music = !music
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), !music)
	save_sound_setting()
	
func toggle_sound() :
	sound = !sound
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Sound"), !sound)
	save_sound_setting()
	

func save_sound_setting():
	var save_data = {
		"music": music,
		"sound": sound,
		"score": best_score,
		"wave": best_wave,
		"time": best_time,
		"kills": best_kills,
		"coins": best_coins
	}
	var file = FileAccess.open("user://settings.save", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()


func save_score_setting(score: int, wave:int, time: float, kills: int, coins: int):
	best_score = score
	best_wave = wave
	best_time = time
	best_kills = kills
	best_coins = coins
	var save_data = {
		"music": music,
		"sound": sound,
		"score": score,
		"wave": wave,
		"time": time,
		"kills": kills,
		"coins": coins,
	}
	var file = FileAccess.open("user://settings.save", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
