extends AnimatableBody3D

@export var start := Vector3()
@export var end := Vector3()
@export var travel_time := 2.0
@export var pause_time := 0.7
@export var ease_to : Tween.EaseType
@export var ease_from : Tween.EaseType
@export var transition_to : Tween.TransitionType
@export var transition_from : Tween.TransitionType

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = start
	move()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func move():
	var move_tween = create_tween()
	move_tween.tween_property(self, "position", end, travel_time).set_ease(ease_to).set_trans(transition_to).set_delay(pause_time)
	move_tween.tween_property(self, "position", start, travel_time).set_ease(ease_from).set_trans(transition_from).set_delay(pause_time)
	await await get_tree().create_timer(2*travel_time + 2*pause_time).timeout
	
	move()
