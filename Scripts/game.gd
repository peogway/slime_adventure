extends Node2D

signal get_berserk(slime_pos)

@export var effect_scene : PackedScene = load("res://Scenes/Effects.tscn")

@export var coin_scene : PackedScene = load("res://Scenes/Coin.tscn")
@export var shield_scene : PackedScene = load("res://Scenes/Shield.tscn")
@export var hp_scene : PackedScene = load("res://Scenes/HP.tscn")
@export var spike_scene : PackedScene = load("res://Scenes/Spike.tscn")
@export var monster_scene: PackedScene = load("res://Scenes/Monster.tscn")
@export var chest_scene: PackedScene = load("res://Scenes/Chest.tscn")
@export var boost_scene: PackedScene = load("res://Scenes/SpeedUp.tscn")



@export var game_over_scene: PackedScene = preload("res://Scenes/GameOver.tscn")

@onready var gui = $UI


@export var monster_wait_time: float = 6
@export var chest_wait_time: float = 10

var wait_time_ratio: float = 1.0

@onready var chest_spawn_location: PathFollow2D = $ChestSpawn/PathFollow2D
@onready var monster_spawn_location: PathFollow2D = $MonsterSpawn/PathFollow2D

const BERSERK_TIME_CONSTANT = 5
const TIME_TO_EMIT_POS = 1
var delay_time_to_emit_pos = TIME_TO_EMIT_POS
var berserk_time = BERSERK_TIME_CONSTANT
var is_monster_berserk = false
var slime_to_chase = 1
var recent_die = false

var start_time : float
var time_elapsed := 0.0

var score = 0
var score2 = 0

var new_best = false
var best_score = 0

var coins = 0
var coins2= 0

var kills = 0
var kills2 = 0




var slime = null
var slime2 = null

var old_pos = null
var old_pos2 = null
var time_update_old_pos = 0


var game_over = false

const TIME_TO_CHANGE_DIFF = 60
var difficulty = 0


var is_dead = false
var is_dead2 = false

var wave = 1
var monsters_num = 5
var monsters_killed = 0
var wave_cleared = false
var monsters_respawned = 0
var chests_respawned_num = 0
var chest_max = 5
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.play_random_ingame()
	var background = $Background
	var d = randi() % 8 + 1
	background.texture = load("res://Assets/backgrounds/%d.png" % d)
	
	
	start_time = Time.get_unix_time_from_system()
	

	
	
	if Global.player_mode == 2:
		slime = $SlimeBlue
		slime2 = $SlimeRed
		gui.update_lives_2(slime2.hp)
		slime2.update_hp.connect(update_hp_2)
		slime2.coin_collected.connect(collect_coin_2)
		chest_max *= 2
	else:
		is_dead2 = true
		if Global.selected_character == 1:
			slime = $SlimeBlue
			remove_child($SlimeRed)
		else:
			slime = $SlimeRed
			remove_child($SlimeBlue)
		
	gui.update_lives_1(slime.hp)
	
	slime.update_hp.connect(update_hp_1)
	slime.coin_collected.connect(collect_coin_1)
	
	
	
	$MonsterSpawnTimer.wait_time = monster_wait_time
	$ChestSpawnTimer.wait_time = chest_wait_time
	
	gui.play_wave(wave)




func monster_die(player_id:int):
	if player_id == 1 or Global.player_mode == 1:
		kills += 1
		score += 5
		gui.update_score_1(score)
		gui.update_kills_1(kills)
	else:
		kills2 += 1
		score2 += 5
		gui.update_score_2(score2)
		gui.update_kills_2(kills2)
	
	monsters_killed += 1
	gui.update_monsters(monsters_killed, monsters_num)
	if monsters_killed == monsters_num:

		gui.update_monsters(monsters_killed, monsters_num)
		wave += 1
		monsters_respawned = 0
		wave_cleared = true
		
		gui.play_clear(wave)
		$MonsterSpawnTimer.start()
		$ChestSpawnTimer.start()
		await get_tree().create_timer(3).timeout
		
		wave_cleared = false
		
		monsters_num += int(monsters_num*0.4)
		monsters_killed = 0
		chests_respawned_num = 0
		chest_max = monsters_num
		if Global.player_mode == 2: chest_max *= 2
		
		gui.update_wave(wave)
		gui.update_monsters(monsters_killed, monsters_num)
		return

	
	delay_time_to_emit_pos = 0
	is_monster_berserk = true
	slime_to_chase = player_id
	recent_die = true
	
	
func update_hp_1():
	gui.update_lives_1(slime.hp)
	if slime.hp <= 0 : 
		is_dead = true
	if (slime.hp <= 0 and Global.player_mode == 1) or (slime.hp <= 0 and slime2.hp <= 0):
		if Global.player_mode == 2:
			if slime2.hp <= 0:
				game_over_func(2)
		else:
			if score > Global.best_score:
				Global.save_score_setting(score, wave, time_elapsed, kills, coins)
				new_best = true
			if new_best:
				$NewRecord.play()
			else:
				$Lose.play()	
			game_over_func(2)
	#		Game over

		game_over = true
		$PauseMenu.visible = false
		$UI.visible =false
		$PauseMenu.game_over = true
		pass
		
func update_hp_2():
	gui.update_lives_2(slime2.hp)
	if slime2.hp <= 0 : 
		is_dead2 = true
	if slime.hp <= 0 and slime2.hp <= 0:
		game_over_func(1)
		$PauseMenu.visible = false
		$UI.visible =false
		game_over = true
		$PauseMenu.game_over = true

func game_over_func(die_first :int):
	var game_over_screen = game_over_scene.instantiate()
	game_over_screen.winner = 1
	game_over_screen.score = score
	game_over_screen.kills = kills
	game_over_screen.coins = coins
	game_over_screen.time = time_elapsed
	game_over_screen.wave = wave
	
	if score2 > score or (score2 == score and kills2 > kills) or (score2 == score and kills2 == kills and coins2 > coins) or (score2 == score and kills2 == kills and coins2 == coins and die_first == 1):
		game_over_screen.winner = 2
		game_over_screen.score = score2
		game_over_screen.kills = kills2
		game_over_screen.coins = coins2
		
	if Global.player_mode == 2:
		game_over_screen.mode = 2
		$GameOver2P.play()
	else:
		game_over_screen.winner = Global.selected_character
		game_over_screen.new_best = new_best
		
	$Camera2D.position = Vector2.ZERO
	call_deferred("add_child", game_over_screen)

func collect_coin_1():
	coins += 1
	score += 10
	gui.update_score_1(score)
	gui.update_coins_1(coins)
	
func collect_coin_2():
	coins2 += 1
	score2 += 10
	gui.update_score_2(score2)
	gui.update_coins_2(coins2)

func _on_game_timer_timeout() -> void:
	if game_over:
		return
	time_elapsed += $GameTimer.wait_time
	gui.set_time(time_elapsed)

func _on_chest_break(chest_pos):
	var roll = randi() % 100
	var created_scene = null
	var transform_pos = Vector2.ZERO
	if roll < 25:
		created_scene = coin_scene.instantiate()
	elif roll < 40:
		created_scene = hp_scene.instantiate()
	elif roll < 60:
		created_scene = shield_scene.instantiate()
		transform_pos = Vector2(0, -10)
	elif roll < 70:
		created_scene = spike_scene.instantiate()
		transform_pos = Vector2(0, 10)
	elif roll < 95:
		created_scene = boost_scene.instantiate()
	else:
		return # 5% chance to do nothing
	
	created_scene.position = chest_pos + transform_pos
	add_child(created_scene)

func _process(delta: float) -> void:
	if is_dead and is_dead2:
		return
	time_update_old_pos += delta
	if time_update_old_pos >= 0.7:
		time_update_old_pos = 0
		old_pos = slime.position
		if slime2:
			old_pos2 = slime2.position
	
	if (floor(time_elapsed/TIME_TO_CHANGE_DIFF) > difficulty):
		difficulty += 1
		AudioManager.play_random_ingame()
	
	if Global.player_mode == 1:
		$Camera2D.position = slime.position
	
	
	
	if slime and slime2:
		if is_dead and !is_dead2:
			$Camera2D.position = slime2.position
		elif !is_dead and is_dead2:
			$Camera2D.position = slime.position
		else:
			$Camera2D.position = (slime.position + slime2.position)/2
		var left = slime
		var right = slime2
		if slime.position.x > slime2.position.x:
			left = slime2
			right = slime
			
		var distance = slime.position.distance_to(slime2.position) + 80
		var screen_width = get_viewport_rect().size.x
		if is_dead or is_dead2:
			$ViewPortBoundary/LeftShape.position.x = -1000000000
			$ViewPortBoundary/RightShape.position.x = 1000000000
		elif distance <= screen_width:
			$ViewPortBoundary/LeftShape.position.x = left.position.x -32
			$ViewPortBoundary/RightShape.position.x = right.position.x + 32
	
	if is_monster_berserk:
		
		berserk_time -= delta
		if Global.player_mode == 1 or slime_to_chase == 1:
			if slime.hp <= 0:
				get_berserk.emit(null, false)
			else:
				get_berserk.emit(old_pos, recent_die)
		else:
			if slime2.hp <= 0:
				get_berserk.emit(null, false)
			else:
				get_berserk.emit(old_pos2, recent_die)
		recent_die = false
		#if delay_time_to_emit_pos <= 0:
			#delay_time_to_emit_pos = TIME_TO_EMIT_POS
		
		delay_time_to_emit_pos -= delta
		
		if berserk_time <= 0:
			is_monster_berserk = false
			berserk_time = BERSERK_TIME_CONSTANT
			get_berserk.emit(null, false)

func _on_chest_spawn_timer_timeout() -> void:
	if not game_over:
		spawn_chest()


func _on_monster_spawn_timer_timeout() -> void:
	if not game_over and not wave_cleared:
		spawn_monster()
		
		
func spawn_chest():
	if chests_respawned_num >= chest_max: return
	chests_respawned_num += 1
	chest_spawn_location.progress_ratio = randf()
	
	var chest: Chest = chest_scene.instantiate()
	chest.chest_break.connect(_on_chest_break)
	chest.position = chest_spawn_location.position
	#chest.position = Vector2(-50, -320)
	add_child(chest)


func spawn_monster():
	for i in int(monsters_num / 3.0):
		if monsters_respawned >= monsters_num:
			break
		monster_spawn_location.progress_ratio = randf()
		monsters_respawned += 1
		var monster: Monster = monster_scene.instantiate()
		monster.maxHealth += (wave-1)*2
		get_berserk.connect(monster.set_slime_pos)
		monster.die.connect(monster_die)
		monster.position = monster_spawn_location.position
		add_child(monster)
		await get_tree().create_timer(0.5).timeout
