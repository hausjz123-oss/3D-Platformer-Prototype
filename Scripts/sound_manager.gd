extends Control

#@onready var cur_level_song : AudioStreamPlayer= $Music_MainLevel

func play_sound_ButtonPress():
	$Sound_ButtonPress.play()

func play_music_titleScreen():
	$Music_TitleScreen.play()

func stop_music_titleScreen():
	$Music_TitleScreen.stop()

#func play_cur_level_song():
	#cur_level_song.play()
#func stop_cur_level_song():
	#cur_level_song.stop()
