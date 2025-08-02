extends Node2D

@export var instructions_scene = preload("res://Scenes/HowToPlay.tscn")

var instructions: Control = null

var blue_click = false
var red_click = false

var back_click = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Blue.get_node("AnimatedSprite2D").play("default")
	$Red.get_node("AnimatedSprite2D").play("default")
	
	$Control.visible = Global.best_score > 0
	$Control/StatsContainer/Wave.text = "Wave  %d." % Global.best_wave
	$Control/Score.text = "Highscore: %d" % Global.best_score 
	$Control/StatsContainer/Time.text = "%3.1f" % Global.best_time
	$Control/StatsContainer/KillsNum.text = str(Global.best_kills)
	$Control/StatsContainer/CoinsCollected.text = str(Global.best_coins)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("back"):
		if instructions == null:
			$Click.play()
			await $Click.finished
			_on_back_click()
		else:
			$Click.play()
			get_tree().change_scene_to_file("res://Scenes/Game.tscn")

func _on_back_click() -> void:
	$Back.disabled = true
	if back_click:
		return
	back_click = true
	get_tree().change_scene_to_file("res://Scenes/PlayerModeSelect.tscn")

	


func _on_blue_pressed() -> void:
	if blue_click:
		return
	blue_click = true
	red_click = true
	$Click.play()
	await $Click.finished
	Global.selected_character = 1
	instructions = instructions_scene.instantiate()
	instructions.close_instructions.connect(func() : get_tree().change_scene_to_file("res://Scenes/Game.tscn"))
	add_child(instructions)
	remove_child($Blue)
	remove_child($Red)
	remove_child($Back)
	


func _on_red_pressed() -> void:
	if red_click:
		return
	blue_click = true
	red_click = true
	$Click.play()
	await $Click.finished
	Global.selected_character = 2
	instructions = instructions_scene.instantiate()
	instructions.close_instructions.connect(func() : get_tree().change_scene_to_file("res://Scenes/Game.tscn"))
	add_child(instructions)
	remove_child($Blue)
	remove_child($Red)
	remove_child($Back)
	


func _on_blue_mouse_entered() -> void:
	$Blue.scale *= 1.01
	$Blue.modulate.a = 0.9


func _on_blue_mouse_exited() -> void:
	$Blue.scale /= 1.01
	$Blue.modulate.a = 1.0


func _on_red_mouse_entered() -> void:
	$Red.scale *= 1.01
	$Red.modulate.a = 0.9


func _on_red_mouse_exited() -> void:
	$Red.scale /= 1.01
	$Red.modulate.a = 1.0
