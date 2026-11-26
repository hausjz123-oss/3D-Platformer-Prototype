extends CharacterBody3D


@export var SPEED = 3.0
@export var JUMP_VELOCITY = 7
@onready var camera_controller_target_rotation_y := 0.0
var cam_up_pos := Vector3(0,1,1.2)
var cam_middle_pos := Vector3(0,2,4)
var cam_down_pos := Vector3(0,4,6)
@onready var camera_target_target_position := cam_middle_pos

@onready var camera_controller: Node3D = $Camera_Controller
var forward_rotation := rotation.y
var health := 8
#TODO: do all the cam_up etc. stuff with ENUMS instead?
var is_cam_up := false
var is_cam_down := false
var is_cam_middle := true

var xForm : Transform3D = global_transform

func _ready() -> void:
	preload("res://Scenes/menu_game_over.tscn")


func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	
	# handle animations:
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		$AnimationPlayer.play("jump")
	#elif !is_on_floor():
		#$AnimationPlayer.play("fall")
	elif is_on_floor() and input_dir != Vector2.ZERO:
		$AnimationPlayer.play("run")
	elif is_on_floor() and input_dir == Vector2.ZERO:
		$AnimationPlayer.play("idle")
	
	
	# handle camera
	handle_camera()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.
	handle_jump()

	# Get the input direction and handle the movement/deceleration.
	var direction := (camera_controller.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
		var vertical_velocity = velocity.y
		var horizontal_velocity = velocity.slide(Vector3(0,1,0))
		#print(horizontal_velocity.length())
		if (is_on_floor()):
			var turn_speed = 0.1
			turn_speed = remap(horizontal_velocity.length(), 0, SPEED, PI*2, 0.1 )
			forward_rotation = rotate_toward(rotation.y, -PI/2 - Vector2(direction.x,direction.z).angle(), turn_speed)
		
			velocity = (Vector3(0,0,-1)* SPEED).rotated(Vector3(0,1,0),forward_rotation)
		else:
			forward_rotation = rotate_toward(rotation.y, -PI/2 - Vector2(direction.x,direction.z).angle(), 0.3)
			velocity.x = move_toward(velocity.x, direction.x*SPEED, 0.2)
			velocity.z = move_toward(velocity.z, direction.z*SPEED, 0.2)
		velocity.y = vertical_velocity
	else:
		if (is_on_floor()):
			velocity.x = move_toward(velocity.x, 0, 0.2)
			velocity.z = move_toward(velocity.z, 0, 0.2)
		if (!is_on_floor()):
			velocity.x = move_toward(velocity.x, 0, 0.05)
			velocity.z = move_toward(velocity.z, 0, 0.05)
	rotation.y = forward_rotation
	
	#print(health)
	
	align_with_floor()
	$CollisionShape3D.global_transform = $CollisionShape3D.global_transform.interpolate_with(xForm, 0.5)
	$CollisionShape3D.position = Vector3(0,0.5,0)
	move_and_slide()
	
	

func align_with_floor():
	xForm = global_transform
	if (is_on_floor()):
		xForm.basis.y = get_floor_normal()
		xForm.basis.x = -xForm.basis.z.cross(get_floor_normal())
		xForm.basis = xForm.basis.orthonormalized()

func handle_jump():
	#TODO changee the jumping mechanic to work in up_direction and for holding jump mechanic
	if Input.is_action_just_pressed("jump") and is_on_floor():
		$Sound_Jump.play()
		velocity.y = JUMP_VELOCITY

func handle_camera():
	if (Input.is_action_just_pressed("cam_left")):
		camera_controller_target_rotation_y = (camera_controller_target_rotation_y - deg_to_rad(45))
	
	if (Input.is_action_just_pressed("cam_right")):
		camera_controller_target_rotation_y = (camera_controller_target_rotation_y + deg_to_rad(45))
	
	if (Input.is_action_just_pressed("cam_up")):
		if is_cam_middle:
			camera_target_target_position = cam_up_pos
			is_cam_up = true
			is_cam_middle = false
		if is_cam_down:
			is_cam_middle = true
			is_cam_down = false
			camera_target_target_position = cam_middle_pos
	
	if (Input.is_action_just_pressed("cam_down")):
		if is_cam_middle:
			camera_target_target_position = cam_down_pos
			is_cam_down = true
			is_cam_middle = false
		if is_cam_up:
			is_cam_middle = true
			is_cam_up = false
			camera_target_target_position = cam_middle_pos
	
	$Camera_Controller.rotation.y = lerp($Camera_Controller.rotation.y, camera_controller_target_rotation_y, 0.15)
	$Camera_Controller/Camera_Target.position = lerp($Camera_Controller/Camera_Target.position, camera_target_target_position, 0.15)
	
	# update camera position
	$Camera_Controller.position = lerp($Camera_Controller.position, position, 0.15)
	#TODO: clamp the camera distance from player so player is still in view even when going super fast
	# TODO: possibly make camera snap and stop when it lerps close enough, so we don't move infinitessimally small
func kill():
	$Sound_Death.play()
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://Scenes/menu_game_over.tscn")

func hurt(damage : int):
	$Sound_Hurt.play()
	health -= damage
	if health <= 0: kill()

func coin_collect():
	pass

func _on_death_plane_body_entered(body: Node3D) -> void:
	print("death")
	if body == self:
		kill()

func bounce_off_enemy(_enemy : CharacterBody3D, direction : Vector3):
	# TODO maybe add parameter "bounce_strength" ir something and incorporate that.
	var vel_h_before := velocity.slide(direction)
	if Input.is_action_pressed("jump"):
		velocity = direction*JUMP_VELOCITY * 1.2
	else:
		velocity = direction*JUMP_VELOCITY * 0.7
	velocity += vel_h_before
	
