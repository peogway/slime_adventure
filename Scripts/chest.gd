class_name Chest extends RigidBody2D


@export var effect_scene: PackedScene = load("res://Scenes/Effects.tscn")


var is_broken = false
signal chest_break(pos: Vector2)


var hit_count = 0
const MAX_HIT = 3
var is_hitting = false

const HIT_TIME_CONSTANT = 0.5
var hit_time = HIT_TIME_CONSTANT

var dropped = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gravity_scale = 0.2
	pass # Replace with function body.


func _physics_process(_delta: float) -> void:
	if $RayCast2D.is_colliding() and !dropped:
		var collider = $RayCast2D.get_collider()
		if collider is not Player and collider is not Monster:
			dropped = true
			$ChestDrop.play()
			$Sprite2D.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if position.y > 1500:
		queue_free()
	
	if hit_count == MAX_HIT:
		if !is_broken:
			$AnimatedSprite2D.play("break")
			$ChestBreak.play()
			is_broken = true
			var explode_effect : Effect = effect_scene.instantiate()
			explode_effect.effect_name = "after_chest_break"
			$Effect.add_child(explode_effect)
			
			await $AnimatedSprite2D.animation_finished
			#await $ChestBreak.finished
			chest_break.emit(position)
			queue_free()
	elif is_hitting:
		hit_time -= delta
		if hit_time <= 0:
			is_hitting = false
		else:
			$AnimatedSprite2D.play("hit")
	else:
		$AnimatedSprite2D.play("idle")


func get_hit() -> void:
	if hit_count < MAX_HIT:
		hit_count+=1
		hit_time = HIT_TIME_CONSTANT
		is_hitting = true
		get_node("ChestHit%d" % ((hit_count-1)%2 +1)).play()

	
	
	
	
	
	
	#is_hurt = false
