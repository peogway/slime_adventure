extends Area2D

var rotation_progress := 0.0
var rotating := false

var disappear = false

var rotate_back_ward = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_rotation()
	pass # Replace with function body.



func _process(delta):
	if rotating:
		if rotate_back_ward:
			rotation_progress -= delta  # adjust speed
			if rotation_progress < 0:
				rotate_back_ward = false
				rotation_progress = 0.0  # lo
		else:
			rotation_progress += delta  # adjust speed
			if rotation_progress > 1.0:
				rotate_back_ward = true
				rotation_progress = 1.0  # loop
		$Run.material.set("shader_parameter/rotation", rotation_progress)



		
			
func start_rotation():
	rotating = true
	rotation_progress = 0.0


func _on_body_entered(body: Node2D) -> void:
	if body is Player and !disappear: 
		$GetFast.play()
		disappear = true
		visible = false
		body.get_speed()
		await $GetFast.finished
		queue_free()
