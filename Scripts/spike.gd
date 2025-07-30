class_name Spike extends Area2D

#signal hit_spike
# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.hurt()
		#hit_spike.emit()
