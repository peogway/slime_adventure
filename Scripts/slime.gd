class_name Player extends CharacterBody2D

# Signals
signal coin_collected
signal update_hp

# Exported / Onready
@export var effect_scene: PackedScene = load("res://Scenes/Effects.tscn")
var move_audio = null
@onready var attack_area: Area2D = $AttackArea2D
@onready var attackDelayTimer = $AttackDelayTimer

# Player Info
@export var player_id = 1 # 1 or 2
var element_type = "fire" # or "water"

# Movement
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const WALK_SPEED_THRESHOLD = 100.0

var direction := 0.0
var facing_left := false
var is_moving_sound_playing = false
var on_air = false
var jump_combo = 3

const VIEWPORT_SIZE_MAX = Vector2(2548, 1322)

# Combat
var combo_step = 0
var combo_timer = 0.0
const COMBO_MAX_TIME = 0.5

var can_attack = true
var is_attacking = false
var has_attacked = false

var player_damage = 8
var hit_objects = {}
var targets: Array = []
var exp_ammount = 0

# Health
var hp = 3
var lv = 1
var has_shield = false
var is_hurt = false
var hurt_with_shield = false
var hurt_timer = 0.0
const HURT_DURATION = 0.2
var is_dead = false
var played_dead = false


func _ready():
	$AnimatedSprite2D.connect("animation_finished", Callable(self,  "_on_animation_finished"))
	$Shield.visible = false
	move_audio = get_node("Move%d" % player_id)
	move_audio.connect("finished", Callable(self, "_on_move_audio_finished"))
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_area.body_exited.connect(_on_attack_area_body_exited)
	



func _process(delta):
	if hp <= 0: 
		is_dead = true
	if is_on_floor():
		if on_air:
			$TouchGround.play()
		on_air = false
		jump_combo = 3

	if !is_attacking:
		combo_timer -= delta
		if combo_timer <= 0:
			combo_step = 0
	
			
	if combo_step != 0:
		for target in targets:
			if not hit_objects.has(target):
				hit_objects[target] = true
				if target is Monster:
					if target.currentHealth <= player_damage*(1 + combo_step*0.1 + lv*0.1 ):
						get_exp()
					target.get_attack(player_id, player_damage*(1 + combo_step*0.1 + lv*0.1 ), velocity)
				elif target is Chest:
					target.get_hit()
			

func _physics_process(delta: float) -> void:
	if is_dead: 
		if not played_dead:
			die()
			$AnimatedSprite2D.play("%d_Dead" % player_id)
			played_dead = true
		velocity = Vector2.ZERO
		return
	if position.y > 700:
		respawn_back()
	handle_input_1_player()
	handle_input_2_players()
	# Gravity
	if not is_on_floor():
		on_air = true
		is_moving_sound_playing = false
		velocity += get_gravity() * delta
	
	if is_attacking or not is_on_floor() or is_hurt:
		if is_moving_sound_playing:
			move_audio.stop()
			is_moving_sound_playing = false

	if is_hurt:
		hurt_timer -= delta
		if hurt_timer <= 0:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		if hurt_with_shield:
			$AnimatedSprite2D.play("%d_Jump" % player_id)
		else:
			$AnimatedSprite2D.play("%d_Hurt" % player_id)
		move_and_slide()
		return
	elif is_attacking:
		if !has_attacked:
			has_attacked = true
			player_attack(combo_step)
	elif not is_on_floor():
		if !is_dead:
			$AnimatedSprite2D.play("%d_Jump" % player_id)
	elif abs(velocity.x) > WALK_SPEED_THRESHOLD:
		if not is_moving_sound_playing:
			move_audio.play()
			is_moving_sound_playing = true
		$AnimatedSprite2D.play("%d_Run" % player_id)
	elif direction:
		if not is_moving_sound_playing:
			move_audio.play()
			is_moving_sound_playing = true
		$AnimatedSprite2D.play("%d_Walk" % player_id)
	else:
		$AnimatedSprite2D.play("%d_Idle" % player_id)

	if direction:
		velocity.x = direction * SPEED
		if (direction < 0) != (facing_left):
			facing_left = !facing_left
			scale.x *= -1 
			$Lv.scale.x *= -1
			if facing_left:
				$Lv.position.x += 80
			else:
				$Lv.position.x -= 80
	else:
		move_audio.stop()
		is_moving_sound_playing = false
		velocity.x = move_toward(velocity.x, 0, SPEED)


	move_and_slide()


func handle_input_1_player() -> void:
	if Global.player_mode == 2:
		return
		
	direction = 0.0
	if Input.is_action_just_pressed("attack_single")  and can_attack:
		can_attack = false
		hit_objects.clear()
		combo_step += 1
		is_attacking = true
		has_attacked = false

	direction = Input.get_action_strength("right_single") - Input.get_action_strength("left_single")
	if Input.is_action_just_pressed("jump_single") and jump_combo > 0 :
		get_node("Jump%d" % player_id).play()
		create_jump_effect()
		jump_combo -= 1
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("down_single") and is_on_floor():
		position.y += 8
	

func handle_input_2_players() -> void:
	if Global.player_mode == 1:
		return
	direction = 0.0
	#if player_id == 1:
	if Input.is_action_just_pressed("attack_p%d" % player_id)  and can_attack:
		can_attack = false
		hit_objects.clear()
		combo_step += 1
		is_attacking = true
		has_attacked = false

	direction = Input.get_action_strength("move_right_p%d" % player_id) - Input.get_action_strength("move_left_p%d" % player_id)
	if Input.is_action_just_pressed("jump_p%d" % player_id) and jump_combo > 0 :
		get_node("Jump%d" % player_id).play()
		create_jump_effect()
		jump_combo -= 1
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("move_down_p%d" % player_id) and is_on_floor():
		position.y += 8


func _on_animation_finished():
	if $AnimatedSprite2D.animation == ("%d_Hurt" % player_id):
		is_hurt = false
	if $AnimatedSprite2D.animation == ("%d_Jump" % player_id) and hurt_with_shield:
		is_hurt = false
func create_jump_effect():
	var attack_effect : Effect = effect_scene.instantiate()
	attack_effect.effect_name = 'jump%d' % player_id
	$Effect.add_child(attack_effect)

func hurt() -> void:
	if is_hurt:
		return
	
	if (!has_shield):
		hurt_with_shield = false
		hp -= 1
		update_hp.emit()
		get_node("Hurt%d" % player_id).play()
	else:
		hurt_with_shield = true
		has_shield = false
		$Shield.visible = false
		$LostShield.play()
	
	is_hurt = true
	hurt_timer = HURT_DURATION
	velocity.x = -600 if !facing_left else 600
	velocity.y = JUMP_VELOCITY/2-50

func respawn_back() -> void:
	velocity = Vector2(0, 0)
	position.y = -get_viewport().get_visible_rect().size.y/2 + 100
	hp -= 1
	update_hp.emit()

func die() -> void:
	get_node("Die%d" % player_id).play()
	$CollisionShape2D.disabled = true
	is_dead = true

func _on_move_audio_finished():
	is_moving_sound_playing = false

func get_shield() -> void:
	has_shield = true
	$Shield.visible = true
	
func get_exp() -> void:
	exp_ammount += 1
	if exp_ammount >= 15:
		exp_ammount = 0
		lv += 1
		hp += 1
		update_hp.emit()
		$Lv.text = "LV. %d" % lv

func get_coin() -> void:
	coin_collected.emit()

func get_hp() -> void:
	hp += 1
	update_hp.emit()

func _on_attack_area_body_entered(body):
	if body is Monster or body is Chest:
		targets.append(body)

func _on_attack_area_body_exited(body):
	targets.erase(body)


func player_attack(combo:int):
	var attack_effect : Effect = effect_scene.instantiate()
	attack_effect.position += Vector2(30, 30)
	attack_effect.effect_name = 'get_attack_%d_%d' % [player_id, combo]
	

	$AnimatedSprite2D.play("%d_Attack%d" % [player_id, combo_step])
	$Effect.add_child(attack_effect)
	get_node("Attack%d_%d" % [player_id, combo]).play()
	
	await attack_effect.animation_finished
	is_attacking = false
	
	if combo == 3:
		attackDelayTimer.start()
		await attackDelayTimer.timeout
		combo_step = 0
	can_attack = true
	combo_timer = COMBO_MAX_TIME





	
