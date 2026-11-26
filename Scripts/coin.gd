extends Area3D


@export var rotation_speed_deg := 2.0
var collectable := true
@export var hud : CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	rotate_y(deg_to_rad(rotation_speed_deg))


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Players") and collectable == true:
		collectable = false
		GlobalScript.coins += 1
		$Sound_CoinCollect.play()
		hud.get_node("CoinsLabel").text = str(GlobalScript.coins)
		body.coin_collect()
		$AnimationPlayer.play("idle_bounce")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if (anim_name == "idle_bounce"):
		queue_free()
