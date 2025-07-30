extends Area2D

var score = 0
var kills = 0
var coins = 0
var time = 0.0
var winner = 1
var new_best = false
var mode = 1

var menu_click = false
var restart_click = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Blue.play("default")
	$Red.play("default")
	
	$Crown.visible = mode == 2
	$Firework.visible = mode == 2 or new_best
	$NewBest.visible = new_best
	
	$Firework2.visible = mode == 2 
	
	if mode == 1:
		$Label2.text = "Game Over"
	
	$Blue.visible = winner == 1
	$Red.visible = winner == 2
	
	$AnimationPlayer.play("blur")
	
	$StatsContainer/Score.text = "Score: %d" % score 
	$StatsContainer/Time.text = "%3.1f" % time
	$StatsContainer/KillsNum.text = str(kills)
	$StatsContainer/CoinsCollected.text = str(coins)
	



func _on_restart_click() -> void:
	if restart_click:
		return
	restart_click = true
	get_tree().reload_current_scene()


func _on_menu_click() -> void:
	if menu_click:
		return
	menu_click = true
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
