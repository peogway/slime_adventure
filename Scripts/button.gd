extends Area2D

signal click
#@export_category("Textures")
@export var texture: Texture = null

@onready var sprite =  $Sprite2D
@onready var shape = $CollisionShape2D

var need_to_wait = true
var play_sound = true
var disabled = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	if texture:
		sprite.texture = texture
		var tex_size = texture.get_size() * sprite.scale
		
		call_deferred("_set_shape", tex_size)


func _set_shape(tex_size: Vector2) -> void:
	shape.shape = RectangleShape2D.new()
	shape.shape.extents = tex_size / 2

func _on_mouse_entered() -> void:
	scale *= 1.01
	modulate.a = 0.9

func _on_mouse_exited() -> void:
	scale /= 1.01	
	modulate.a = 1


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		var parameters: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
		parameters.position = get_global_mouse_position()
		parameters.collide_with_areas = true
		
		var objects_clicked = get_world_2d().direct_space_state.intersect_point(parameters)
		var colliders = objects_clicked.map(
			func(dict):
				return dict.collider
		)
		colliders.sort_custom(
			func(c1, c2):
				return c1.z_index < c2.z_index
		)
		
		if  colliders.size() > 0 and colliders[-1] == self and !disabled: 
			if play_sound:
				$Click.play()
			if need_to_wait:
				await $Click.finished
			click.emit()
