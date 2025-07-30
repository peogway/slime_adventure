extends Control

signal close_instructions

var has_click_close = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Blue.play("default")
	$Red.play("default")
	$AnimationPlayer.play("blur")
	
	pass # Replace with function body.


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("back"):
		_on_close_click()
	
	
func _on_close_click() -> void:
	if has_click_close:
		return
	has_click_close = true
	$Click.play()
	await $Click.finished
	close_instructions.emit()
	queue_free()


func _on_texture_button_mouse_entered() -> void:
	$TextureButton.scale *= 1.01
	$TextureButton.modulate.a = 0.9


func _on_texture_button_mouse_exited() -> void:
	$TextureButton.scale /= 1.01
	$TextureButton.modulate.a = 1
	
