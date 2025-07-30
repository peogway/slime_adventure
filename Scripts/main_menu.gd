extends Node2D

@export var setting_scene: PackedScene = preload("res://Scenes/Setting.tscn")
@export var instructions_scene: PackedScene = preload("res://Scenes/HowToPlay.tscn")
var buttons = []
var current_index = 0
var has_moved = false

var has_click_setting = false
var has_click_htp = false

const SETTINGS_PATH = "user://settings.save"

func _ready() -> void:
	$SettingButton.need_to_wait = false
	$Instructions.need_to_wait = false
	$Start.need_to_wait = false
	$Start.play_sound = false
	AudioManager.play_theme_song()
	if FileAccess.file_exists(SETTINGS_PATH):
		var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			var data = JSON.parse_string(content)
			if typeof(data) == TYPE_DICTIONARY:
				if "music" in data:
					Global.music = data["music"]
					AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), !Global.music)
				if "sound" in data:
					Global.sound = data["sound"]
					AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), !Global.sound)
				if "score" in data:
					Global.best_score = data["score"]
				if "kills" in data:
					Global.best_kills = data["kills"]
				if "coins" in data:
					Global.best_coins = data["coins"]
				if "time" in data:
					Global.best_time = data["time"]



func _on_start_click() -> void:
	$Start.disabled = true
	$Click.play()
	await $Click.finished
	get_tree().change_scene_to_file("res://Scenes/PlayerModeSelect.tscn")

func setting_close():
	has_click_setting = false
	$Click.play()
	await $Click.finished
	
	
func _on_setting_click() -> void:
	if has_click_setting:
		return
	has_click_setting = true
	var setting: Area2D = setting_scene.instantiate()
	setting.on_close.connect(setting_close)
	add_child(setting)


func _on_instructions_click() -> void:
	if has_click_htp:
		return
	has_click_htp = true
	var instructions: Control = instructions_scene.instantiate()
	instructions.close_instructions.connect(func(): has_click_htp = false)
	add_child(instructions)
