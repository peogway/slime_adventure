extends Node2D

@export var animation_track = 1
@export var texture: Texture
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if animation_track == 1:
		$Platform/AnimationPlayer.play("up_down")
	elif animation_track == 2:
		$Platform/AnimationPlayer.play("left_right")
	elif animation_track == 3:
		$Platform/AnimationPlayer.play("down_up")
		
	if texture:
		$Platform/Sprite2D.texture = texture
