class_name Coin extends Area2D

var disappear = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play('default')
	add_to_group("coins")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	



func _on_body_entered(body: Node2D) -> void:
	if body is Player and !disappear:
		disappear = true
		visible = false
		$GetCoin.play()
		body.get_coin()
		await $GetCoin.finished
		queue_free()
