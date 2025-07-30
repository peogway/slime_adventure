class_name Monster extends CharacterBody2D

@export var effect_scene : PackedScene = load("res://Scenes/Effects.tscn")


signal healthChanged
signal die(player_id:int)
#signal monster_attacked(monster_pos: Vector2, player_id: int, combo: int)



var monster = 0
const monsters_move_list = ["ladybird_move", "frog_move", "worm_green_move", "worm_move"]
const monsters_stop_list = ["ladybird_stop", "frog_stop", "worm_green_stop", "worm_stop"]
var speed := -200
var facing_left := true

@export var knockbackPower:int = 15

var is_hurt = false
@onready var ray_vertical := $RayVertical
@onready var ray_horizontal := $RayHorizontal
@onready var ray_body := $RayBody
@onready  var hurtTimer := $HurtTimer

@export var maxHealth = 40
@onready var currentHealth = maxHealth

@onready var animated_sprite = $AnimatedSprite2D
@onready var animated_player = $AnimationPlayer

var dropped = false

func _ready() -> void:
	$TextureProgressBar.visible = false
	monster = randi() % monsters_move_list.size()

var knockBackDirection


	
func _physics_process(delta: float) -> void:
	if position.y > 1500: 
		queue_free()
	if !is_on_floor():
		velocity += get_gravity() *0.4 * delta
		move_and_slide()
	else:
		$Sprite2D.visible = false
		if !dropped:
			dropped = true
			$ChestDrop.play()
	if is_hurt:
		velocity = knockBackDirection
		animated_sprite.play(monsters_stop_list[monster])
		move_and_slide()
		return
		
	animated_sprite.play(monsters_move_list[monster])
	
	
	if (!ray_vertical.is_colliding() and is_on_floor()) or (ray_horizontal.is_colliding() and ray_horizontal.get_collider() is not Player) or (ray_body.is_colliding()):
		if ray_body.is_colliding() and ray_body.get_collider() is Player:
			ray_body.get_collider().hurt()
		flip()
	if dropped:
		velocity.x = speed
	move_and_slide()
		

func flip():
	facing_left = !facing_left
	
	scale.x = scale.x * -1
	speed = speed * -1
	#if facing_left:
		#speed = abs(speed) * -1
	#else:
		#speed = abs(speed)


func get_attack(player_id: int, player_damage, player_velocity):
	$TextureProgressBar.visible = true
	currentHealth -= player_damage
	if currentHealth <0:
		monster_die( player_id)
		

		
		
	healthChanged.emit()
	is_hurt = true
	knockback(player_velocity)

	$AnimationPlayer.play("hit_flash")
	hurtTimer.start()
	await hurtTimer.timeout
	
	
	is_hurt = false
	
	

func knockback(enemyVelocity: Vector2):
	knockBackDirection = (enemyVelocity - velocity).normalized() * knockbackPower




func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_hurt:
		return
	if body is Player:
		if !body.is_hurt:
			body.hurt()
		if (ray_horizontal.is_colliding() and ray_horizontal.get_collider() is Player):
			flip()



func monster_die( player_id:int ):
	var die_effect : Effect = effect_scene.instantiate()
	var num = randi() % 2 + 1
	die_effect.effect_name = "die%d_%d" % [player_id, num]
	$Effect.add_child(die_effect)
	$CollisionShape2D.disabled = true
	$AnimatedSprite2D.visible = false
	$TextureProgressBar.visible = false
	die.emit(player_id)
	await die_effect.animation_finished
	queue_free()
