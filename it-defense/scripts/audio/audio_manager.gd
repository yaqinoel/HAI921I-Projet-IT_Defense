extends Node

@export var menu_music: AudioStream
@export var level_music: Array[AudioStream] = []

@onready var music_player: AudioStreamPlayer = $MusicPlayer

func play_menu_music() -> void:
	_play_music(menu_music)


func play_level_music(level: int) -> void:
	if level > len(level_music):
		return
		
	_play_music(level_music[level])


func _play_music(music: AudioStream) -> void:
	if music == null:
		return
	
	# prevent repeat play
	if music_player.stream == music and music_player.playing:
		return

	music_player.stream = music
	music_player.play()
