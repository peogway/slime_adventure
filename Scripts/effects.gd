class_name Effect extends AnimatedSprite2D

var effect_name

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if effect_name == "get_attack_1_1":
		scale /= 1.2
		position.y += 10
		#position.x += 10
	if effect_name == "get_attack_1_2":
		scale /= 1.2
		position.y += 3
		#position.x += 10
	if effect_name == "get_attack_1_3":
		scale /= 4
		position.y += 15
		#position.x += 10
		
	if effect_name == "get_attack_2_1":
		scale /= 2
		position.y += 7
		
	if effect_name == "get_attack_2_2":
		scale /= 2
		position.y += 7

	if effect_name == "get_attack_2_3":
		#scale *= 2
		position.y += 3
		
	if effect_name == "jump1":
		scale *= 0.25
		position.y += 70
	if effect_name == "jump2":
		scale *= 0.6
		position.y += 70
	if effect_name == "die2_1":
		position.y -= 20
	play(effect_name)
	await animation_finished
	queue_free()
