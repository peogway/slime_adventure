extends TextureProgressBar

@export var monster: Monster
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	monster.healthChanged.connect(update)
 

func update():
	value = monster.currentHealth * 100.0 / monster.maxHealth

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
