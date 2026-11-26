extends Node3D
@onready var enemies: Node3D = $Enemies
@onready var num_enemies := enemies.get_children().size()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	preload("res://Scenes/menu_win.tscn")
	GlobalScript.enemies = num_enemies
	$AudioStreamPlayer.play()
