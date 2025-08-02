extends Node2D

@export var instructions_scene = preload("res://Scenes/HowToPlay.tscn")

var instructions: Control = null

var has_click1 = false
var has_click2 = false
var has_click_back = false

func _ready() -> void:
	$Back.need_to_wait = false
	$Back.play_sound = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("back") and instructions == null:
		$Click.play()
		await $Click.finished
		_on_back_click()

func _on_player_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click") and !has_click1:
		has_click1 = true
		$Click.play()
		await $Click.finished
		Global.player_mode = 1
		get_tree().change_scene_to_file("res://Scenes/CharacterSelect.tscn")


	

func _on_2players_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click") and !has_click2:
		has_click2 = true
		$Click.play()
		await $Click.finished
		Global.player_mode = 2
		instructions = instructions_scene.instantiate()

		instructions.close_instructions.connect(func() : get_tree().change_scene_to_file("res://Scenes/Game.tscn"))
		add_child(instructions)
		remove_child($"1Player")
		remove_child($"2Player")
		remove_child($Back)
	

func _on_player_mouse_entered() -> void:
	$"1Player".scale *= 1.01
	$"1Player".modulate.a = 0.9


func _on_player_mouse_exited() -> void:
	$"1Player".scale /= 1.01
	$"1Player".modulate.a = 1

func _on_2players_mouse_entered() -> void:
	$"2Player".scale *= 1.01
	$"2Player".modulate.a = 0.9


func _on_2players_mouse_exited() -> void:
	$"2Player".scale /= 1.01
	$"2Player".modulate.a = 1


func _on_back_click() -> void:
	if has_click_back:
		return
	has_click_back = true
	$Click.play()
	await $Click.finished
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
