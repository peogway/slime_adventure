extends Area2D

var rotation_progress := 0.0
var rotating := false
var disappear = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_rotation()
	pass # Replace with function body.



func _process(delta):
	if rotating:
		rotation_progress += delta * 1.0  # adjust speed
		if rotation_progress > 1.0:
			rotation_progress = 0.0  # loop
		$Sprite2D.material.set("shader_parameter/rotation", rotation_progress)


	
			
func start_rotation():
	rotating = true
	rotation_progress = 0.0


func _on_body_entered(body: Node2D) -> void:
	if body is Player and !disappear: 
		disappear = true
		visible = false
		body.get_hp()
		$GetHP.play()
		await $GetHP.finished
		queue_free()
