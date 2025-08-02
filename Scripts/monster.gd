class_name Monster extends CharacterBody2D

@export var effect_scene : PackedScene = load("res://Scenes/Effects.tscn")


signal healthChanged
signal die(player_id:int)
#signal monster_attacked(monster_pos: Vector2, player_id: int, combo: int)
const TOUCH_TIME_CONST = 0.5
var touch_time = TOUCH_TIME_CONST
var touch_player = false

var monster = 0
const monsters_move_list = ["ladybird_move", "frog_move", "worm_green_move", "worm_move"]
const monsters_stop_list = ["ladybird_stop", "frog_stop", "worm_green_stop", "worm_stop"]
var speed := -200
var berserk_speed = -250
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
const JUMP_VELOCITY = -400.0
var go_down = false


var knockBackDirection
var slime_pos = null
var tem_slime_pos = null
var horizontal_direction = null
var jump = 1
var falling_too_far = false
var direction_to_center
const TIME_DELAY_JUMP = 1
var delay_jump = TIME_DELAY_JUMP
var jump_cooldown = 0.5
var can_jump = true
var floor_time = 0
var reached = false


func _ready() -> void:
	var addition_speed = randi() % 30 + 1
	if randi() % 2 == 0:
		speed += addition_speed
		berserk_speed += 1.25*addition_speed
	else:
		speed -= addition_speed
		berserk_speed -= 1.25*addition_speed
	$Warning.visible = false
	$TextureProgressBar.visible = false
	monster = randi() % monsters_move_list.size()

func _process(delta: float) -> void:
	if touch_player:
		touch_time -= delta
		if touch_time <= 0:
			touch_player = false
			touch_time = TOUCH_TIME_CONST
	

func set_slime_pos(pos, recent_die: bool):
	if recent_die and currentHealth >= 0:
		$AnimationPlayer.play("Blink")
	tem_slime_pos = pos
	if tem_slime_pos == null:
		slime_pos = null
	
func _physics_process(delta: float) -> void:
	if currentHealth <= 0:
		velocity = Vector2.ZERO
		return
	delay_jump -= delta
	if position.y > 700: 
		falling_too_far = true
		position.y = -2547.0/2 + 100


	
	if !is_on_floor():
		floor_time = 0
		if dropped:
			velocity += get_gravity() * delta
		else:
			velocity += get_gravity() *0.4 * delta
	else:
		delay_jump -= delta
		if delay_jump <= 0:
			jump = 1
		floor_time += delta
		falling_too_far = false
		slime_pos = tem_slime_pos
		if slime_pos:
			horizontal_direction = sign(slime_pos.x - position.x)
		go_down = false
		$Sprite2D.visible = false
		if !dropped:
			dropped = true
			$ChestDrop.play()
	
	if falling_too_far:
		if position.x > 0:
			if !facing_left:
				flip()
			velocity.x = speed
		elif position.x < 0:
			if facing_left:
				flip()
			velocity.x = speed
		move_and_slide()
		return
	
	
	if is_hurt:
		velocity.x = knockBackDirection.x
		animated_sprite.play(monsters_stop_list[monster])
		move_and_slide()
		return
		
	animated_sprite.play(monsters_move_list[monster])
	

	
	if slime_pos and !reached:
		handle_physics_berserk()
		return	
		
	
	
	if (!ray_vertical.is_colliding() and is_on_floor()) or (ray_horizontal.is_colliding() and ray_horizontal.get_collider() is not Player) or (ray_body.is_colliding()):
		if ray_body.is_colliding() and ray_body.get_collider() is Player:
			ray_body.get_collider().hurt()
		flip()
	if dropped:
		velocity.x = speed
		
	if touch_player and is_on_floor():
		if speed < 0 : 
			velocity.x += 100
		else:
			velocity.x -= 100
		
	move_and_slide()



func handle_physics_berserk():
	var height = (JUMP_VELOCITY * JUMP_VELOCITY) / (2 * get_gravity().y)	
	if position.y -51 < slime_pos.y:
		if (horizontal_direction > 0 and facing_left) or (horizontal_direction < 0 and !facing_left):
			flip()
			
		if !is_on_floor() and !go_down and abs(position.x - slime_pos.x) >= 200:
			if jump > 0:
				jump -= 1
				velocity.y += JUMP_VELOCITY
		else:
			if abs(position.x - slime_pos.x) <= 200 and floor_time >= 0.5:
				go_down = true
				position.y += 8
		velocity.x = berserk_speed
	
	elif height <= position.y - 31 - slime_pos.y:
		if (!ray_vertical.is_colliding() and is_on_floor()) or ray_horizontal.is_colliding():
			flip()
		velocity.x = berserk_speed
	else:
		if !is_on_floor() or ( position.y -31 > slime_pos.y ):
			if jump > 0:
				delay_jump = TIME_DELAY_JUMP
				jump -= 1
				velocity.y += JUMP_VELOCITY	
		if (horizontal_direction > 0 and facing_left) or (horizontal_direction < 0 and !facing_left) :
			flip()
		velocity.x = berserk_speed
		
	
	
	if touch_player and is_on_floor():
		if speed < 0 : 
			velocity.x += 100
		else:
			velocity.x -= 100
	move_and_slide()
	

func flip():
	facing_left = !facing_left
	
	scale.x *= -1
	speed *= -1
	berserk_speed *= -1
	$TextureProgressBar.scale *= -1
	if facing_left:
		$TextureProgressBar.position.x -= 65
		$TextureProgressBar.position.y -= 10
		
	else:
		$TextureProgressBar.position.x += 65
		$TextureProgressBar.position.y += 10


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
		touch_player = true

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
