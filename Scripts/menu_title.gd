extends Control

func _ready() -> void:
	if !SoundManager.get_node("Music_TitleScreen").playing:
		SoundManager.play_music_titleScreen()
	preload("res://Scenes/main_level.tscn")

func _on_button_play_pressed() -> void:
	SoundManager.play_sound_ButtonPress()
	SoundManager.stop_music_titleScreen()
	get_tree().change_scene_to_file("res://Scenes/main_level.tscn")
