extends Control

func _ready() -> void:
	SoundManager.play_music_titleScreen()
	preload("res://Scenes/menu_title.tscn")

func _on_button_main_menu_pressed() -> void:
	SoundManager.play_sound_ButtonPress()
	get_tree().change_scene_to_file("res://Scenes/menu_title.tscn")
