extends Area2D

@onready var musicOnNode = $MusicOn
@onready var musicOffNode = $MusicOff
@onready var soundOnNode = $SoundOn
@onready var soundOffNode = $SoundOff
# Called when the node enters the scene tree for the first time.
signal on_close

func _ready() -> void:
	$Close.need_to_wait = false
	musicOnNode.visible = Global.music
	musicOffNode.visible = !Global.music
	
	
	soundOnNode.visible = Global.sound
	soundOffNode.visible = !Global.sound
	
	var music_change = 1 if Global.music else -1
	var sound_change = 1 if Global.sound else -1
	
	
	musicOnNode.get_node("Music").z_index += music_change
	musicOnNode.get_node("BtnMusic").z_index += music_change
	musicOffNode.get_node("MusicOff").z_index -= music_change
	musicOffNode.get_node("BtnMusicOff").z_index -= music_change

	soundOnNode.get_node("Sound").z_index += sound_change
	soundOnNode.get_node("BtnSound").z_index += sound_change
	soundOffNode.get_node("SoundOff").z_index -= sound_change
	soundOffNode.get_node("BtnSoundOff").z_index -= sound_change
	
	musicOnNode.get_node("Music").need_to_wait = false
	musicOnNode.get_node("BtnMusic").need_to_wait = false
	
	musicOffNode.get_node("MusicOff").need_to_wait = false
	musicOffNode.get_node("BtnMusicOff").need_to_wait = false
	
	soundOnNode.get_node("Sound").need_to_wait = false
	soundOnNode.get_node("BtnSound").need_to_wait = false
	
	soundOffNode.get_node("SoundOff").need_to_wait = false
	soundOffNode.get_node("BtnSoundOff").need_to_wait = false
	
	$AnimationPlayer.play("blur")
	pass # Replace with function body.


#func _process(delta: float) -> void:
	#$AnimationPlayer.play("blur")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("back"):
		$Click.play()
		await $Click.finished
		_on_close_click()



func _on_close_click() -> void:
	on_close.emit()
	queue_free()


func _on_btn_music_click() -> void:
	Global.toggle_music()
	
	musicOnNode.visible = false
	musicOffNode.visible = true
	
	musicOnNode.get_node("Music").z_index = 9
	musicOnNode.get_node("BtnMusic").z_index = 9
	
	musicOffNode.get_node("MusicOff").z_index = 11
	musicOffNode.get_node("BtnMusicOff").z_index = 11


func _on_btn_music_off_click() -> void:
	Global.toggle_music()

	musicOnNode.visible = true
	musicOffNode.visible = false

	musicOnNode.get_node("Music").z_index = 11
	musicOnNode.get_node("BtnMusic").z_index = 11

	musicOffNode.get_node("MusicOff").z_index = 9
	musicOffNode.get_node("BtnMusicOff").z_index = 9


func _on_btn_sound_click() -> void:
	Global.toggle_sound()

	soundOnNode.visible = false
	soundOffNode.visible = true

	soundOnNode.get_node("Sound").z_index = 9
	soundOnNode.get_node("BtnSound").z_index = 9

	soundOffNode.get_node("SoundOff").z_index = 11
	soundOffNode.get_node("BtnSoundOff").z_index = 11


func _on_btn_sound_off_click() -> void:
	Global.toggle_sound()

	soundOnNode.visible = true
	soundOffNode.visible = false

	soundOnNode.get_node("Sound").z_index = 11
	soundOnNode.get_node("BtnSound").z_index = 11

	soundOffNode.get_node("SoundOff").z_index = 9
	soundOffNode.get_node("BtnSoundOff").z_index = 9
