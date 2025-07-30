extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Slime1/Slime.play("default")
	if Global.player_mode == 2:
		$Slime2/Slime.play("default")
	else:
		$Slime2/ScoreContainer/ScoreLabel.text = "Best Score: "
		$Slime2/ScoreContainer/Score.text = str(Global.best_score)
		$Slime2/Slime.visible = false
		$Slime2/StatsContainer/Life.texture = load("res://Assets/GUI/upgrade/time.png")
		$Slime2/StatsContainer/LifePoint.text =  "%3.1f" % Global.best_time
		$Slime2/StatsContainer/KillsNum.text = str(Global.best_kills)
		$Slime2/StatsContainer/CoinsCollected.text = str(Global.best_coins)
		$Slime2/StatsContainer/space.visible = false
		$Slime2/StatsContainer/space2.visible = false

func update_score_1(score : int) -> void:
	$Slime1/ScoreContainer/Score.text = str(score)
	
func update_score_2(score : int) -> void:
	$Slime2/ScoreContainer/Score.text = str(score)
	
func update_kills_1(kills : int) -> void:
	$Slime1/StatsContainer/KillsNum.text = str(kills)
	
func update_kills_2(kills : int) -> void:
	$Slime2/StatsContainer/KillsNum.text = str(kills)
	
	
func update_coins_1(kills : int) -> void:
	$Slime1/StatsContainer/CoinsCollected.text = str(kills)
	
func update_coins_2(kills : int) -> void:
	$Slime2/StatsContainer/CoinsCollected.text = str(kills)

	
func update_lives_1(lives : int) -> void:
	$Slime1/StatsContainer/LifePoint.text = str(lives)

func update_lives_2(lives : int) -> void:
	$Slime2/StatsContainer/LifePoint.text = str(lives)

func set_time(elapsed_time: float) -> void:
	$Time/TimeContainer/Time.text = "%3.1f" % elapsed_time
