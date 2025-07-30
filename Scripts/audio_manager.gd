# AudioManager.gd
extends Node

@export var theme_song : AudioStream
var theme_player : AudioStreamPlayer
var ingame_player : AudioStreamPlayer
var ingame_songs

var is_theme_song_playing = false
var song_index = -1

func _ready():
	randomize()
	theme_song = load("res://Assets/musics/Theme/theme_song.mp3")
	theme_player = AudioStreamPlayer.new()
	ingame_player = AudioStreamPlayer.new()
	
	theme_player.stream = theme_song
	theme_player.bus = "Music"
	
	
	theme_player.finished.connect(func(): theme_player.play())
	
	
	var ingame1 = load("res://Assets/musics/Ingame/ingame1.mp3")
	var ingame2 = load("res://Assets/musics/Ingame/ingame2.mp3")
	var ingame3 = load("res://Assets/musics/Ingame/ingame3.mp3")
	var ingame4 = load("res://Assets/musics/Ingame/ingame4.mp3")
	var ingame5 = load("res://Assets/musics/Ingame/ingame5.mp3")
	var ingame6 = load("res://Assets/musics/Ingame/ingame6.mp3")
	var ingame7 = load("res://Assets/musics/Ingame/ingame7.mp3")
	
	ingame_songs = [ingame1, ingame2, ingame3, ingame4, ingame5, ingame6, ingame7]
	
	ingame_player.bus = "Music"
	ingame_player.finished.connect(func(): ingame_player.play())
	
	
	add_child(theme_player)
	add_child(ingame_player)

func play_theme_song():
	ingame_player.stop()
	if !theme_player.playing:
		theme_player.play()


func play_random_ingame():
	theme_player.stop()
	is_theme_song_playing = false
	
	ingame_player.stop()
	var roll = randi() % 7 
	while roll == song_index:
		roll = randi() % 7 
	
	song_index = roll
	
	ingame_player.stream = ingame_songs[song_index]
	ingame_player.play()
	
