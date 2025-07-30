extends CanvasLayer
var game_over = false

@export var instructions_scene: PackedScene = preload("res://Scenes/HowToPlay.tscn")
var instructions = null

@onready var musicBtn = $PanelContainer/VBoxContainer/HBoxContainer/MusicButton
@onready var soundBtn = $PanelContainer/VBoxContainer/HBoxContainer/SoundButton
@onready var resumeBtn = $PanelContainer/VBoxContainer/Resume
@onready var restartBtn = $PanelContainer/VBoxContainer/Restart
@onready var howToPlayBtn = $PanelContainer/VBoxContainer/HowToPlay
@onready var backToMenuBtn = $PanelContainer/VBoxContainer/BackToMenu


var has_click_pause = false
var has_click_continue = false


var has_click_restart = false
var has_click_how_to_play = false
var has_click_return_menu = false

# Called when the node enters the scene tree for the first time.	
func _ready() -> void:
	
	
	musicBtn.get_node("MusicOn").visible = Global.music
	musicBtn.get_node("MusicOff").visible = !Global.music
	
	soundBtn.get_node("SoundOn").visible = Global.sound
	soundBtn.get_node("SoundOff").visible = !Global.sound
	
	$PauseButton/Pause.visible = !get_tree().paused
	$PauseButton/Play.visible = get_tree().paused
	

	$PanelContainer.visible = get_tree().paused
	$ColorRect.visible = get_tree().paused
	$ColorRect2.visible = get_tree().paused
	
	$AnimationPlayer.play("blur")


	

func _unhandled_input(event: InputEvent) -> void:
	if instructions == null and (event.is_action_pressed("options") or (event.is_action_pressed("back") and get_tree().paused)):
		_on_pause_button_pressed()

func _on_music_button_pressed() -> void:
	if instructions != null:
		return
	$Click.play()
	#await $Click.finished
	
	Global.toggle_music()
 	
	musicBtn.get_node("MusicOn").visible = !musicBtn.get_node("MusicOn").visible
	musicBtn.get_node("MusicOff").visible = !musicBtn.get_node("MusicOff").visible


func _on_sound_button_pressed() -> void:
	if instructions != null:
		return
	if (Global.sound):
		$Click.play()
		Global.toggle_sound()
	else:
		Global.toggle_sound()
		$Click.play()
	
	soundBtn.get_node("SoundOn").visible = !soundBtn.get_node("SoundOn").visible
	soundBtn.get_node("SoundOff").visible = !soundBtn.get_node("SoundOff").visible


func _on_resume_mouse_entered() -> void:
	resumeBtn.scale *= 1.01
	resumeBtn.modulate.a = 0.9


func _on_resume_mouse_exited() -> void:
	resumeBtn.scale /= 1.01
	resumeBtn.modulate.a = 1


func _on_restart_mouse_entered() -> void:
	restartBtn.scale *= 1.01
	restartBtn.modulate.a = 0.9


func _on_restart_mouse_exited() -> void:
	restartBtn.scale /= 1.01
	restartBtn.modulate.a = 1



func _on_how_to_play_mouse_entered() -> void:
	howToPlayBtn.scale *= 1.01
	howToPlayBtn.modulate.a = 0.9


func _on_how_to_play_mouse_exited() -> void:
	howToPlayBtn.scale /= 1.01
	howToPlayBtn.modulate.a = 1



func _on_back_to_menu_mouse_entered() -> void:
	backToMenuBtn.scale *= 1.01
	backToMenuBtn.modulate.a = 0.9


func _on_back_to_menu_mouse_exited() -> void:
	backToMenuBtn.scale /= 1.01
	backToMenuBtn.modulate.a = 1



func _on_music_button_mouse_entered() -> void:
	musicBtn.scale *= 1.01
	musicBtn.modulate.a = 0.9


func _on_music_button_mouse_exited() -> void:
	musicBtn.scale /= 1.01
	musicBtn.modulate.a = 1

func _on_sound_button_mouse_entered() -> void:
	soundBtn.scale *= 1.01
	soundBtn.modulate.a = 0.9


func _on_sound_button_mouse_exited() -> void:
	soundBtn.scale /= 1.01
	soundBtn.modulate.a = 1


func _on_pause_button_mouse_entered() -> void:
	$PauseButton.scale *= 1.01
	$PauseButton.modulate.a = 0.9


func _on_pause_button_mouse_exited() -> void:
	$PauseButton.scale /= 1.01
	$PauseButton.modulate.a = 1


func _on_resume_pressed() -> void:
	if instructions != null:
		return
	$Click.play()

	get_tree().paused = !get_tree().paused
	
	$ColorRect.visible = get_tree().paused
	$ColorRect2.visible = get_tree().paused
	
	$PanelContainer.visible = get_tree().paused
	
	$PauseButton/Pause.visible = !get_tree().paused
	$PauseButton/Play.visible = get_tree().paused

func _on_restart_pressed() -> void:
	if instructions != null or has_click_restart:
		return
	has_click_restart = true
	$Click.play()
	await $Click.finished
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_how_to_play_pressed() -> void:
	if instructions != null:
		return
	$Click.play()
	instructions = instructions_scene.instantiate()
	add_child(instructions)


func _on_back_to_menu_pressed() -> void:
	if instructions != null or has_click_return_menu:
		return
	has_click_return_menu = true
	$Click.play()
	await $Click.finished
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


func _on_pause_button_pressed() -> void:
	if game_over: return
	if instructions != null:
		instructions._on_close_click()
	$Click.play()
	await $Click.finished

	get_tree().paused = !get_tree().paused
	
	$ColorRect.visible = get_tree().paused
	$ColorRect2.visible = get_tree().paused
	
	$PanelContainer.visible = get_tree().paused
	
	$PauseButton/Pause.visible = !get_tree().paused
	$PauseButton/Play.visible = get_tree().paused
