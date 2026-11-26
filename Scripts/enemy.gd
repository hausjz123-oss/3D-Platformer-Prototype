@tool
extends CharacterBody3D


var speed = 3.0
const JUMP_VELOCITY = 4.5

var isDead := false
var attack_damage := 2
var direction := Vector3(0,0,1).rotated(Vector3.UP, rotation.y)
var turning := false
var turn_time := 0.6

@export var fall_off_ledges := true

func _ready() -> void:
	direction = Vector3(0,0,1).rotated(Vector3.UP, rotation.y)
	# change color depending on fall_off_ledges value
	if fall_off_ledges == false:
		# change surface_0
		var new_material_0 : Material = $Armature/Skeleton3D/Mesh.get_active_material(0).duplicate(true)
		new_material_0.albedo_color = Color(1.0, 0.469, 0.401, 1.0)
		$Armature/Skeleton3D/Mesh.set_surface_override_material(0, new_material_0)
		
		# change surface_3
		var new_material_3 : Material = $Armature/Skeleton3D/Mesh.get_active_material(3).duplicate(true)
		new_material_3.albedo_color = Color(0.739, 0.173, 0.313, 1.0)
		$Armature/Skeleton3D/Mesh.set_surface_override_material(3, new_material_3)
		
		

func _physics_process(delta: float) -> void:
	# don't run the code in the editor
	if Engine.is_editor_hint(): return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	velocity.x = speed * direction.x
	velocity.y += speed * direction.y
	velocity.z = speed * direction.z
	
	move_and_slide()
	
	if is_on_wall() and !turning:
		turn_around()
	
	if !fall_off_ledges: 
		$Ledge_detector.force_raycast_update()
		if !$Ledge_detector.is_colliding() and is_on_floor() and !turning:
			print("aaah")
			turn_around()
		
func turn_around():
	turning = true
	var dir = direction
	direction = Vector3.ZERO
	$Turn_Timer.start(turn_time)
	var turn_tween = create_tween()
	if !isDead: turn_tween.tween_property(self, "rotation", Vector3(0,rotation.y+PI,0), turn_time)
	await $Turn_Timer.timeout
	
	direction = -dir
	turning = false


func _on_hitbox_body_entered(body: Node3D) -> void:
	if body.is_in_group("Players") and $Attack_cooldown.is_stopped():
		$Attack_cooldown.start()
		body.hurt(attack_damage)
	pass

func kill():
	isDead = true
	$AnimationPlayer.play("squash")
	$SoundSquash.play()
	$Hitbox.set_collision_mask_value(2, false)
	$Hurtbox.set_collision_mask_value(2, false)
	direction = Vector3.ZERO
	speed = 0.0
	GlobalScript.enemies -= 1
	if GlobalScript.enemies <= 0:
		get_tree().change_scene_to_file("res://Scenes/menu_win.tscn")

func _on_hurtbox_body_entered(body: Node3D) -> void:
	if !body.is_in_group("Players"): pass
	elif body.velocity.y < 0.0:
		kill()
		body.bounce_off_enemy(self, up_direction)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "squash":
		queue_free()
