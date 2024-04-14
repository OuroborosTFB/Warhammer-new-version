extends CharacterBody3D

@onready var left_leg = $LeftTarget
@onready var right_leg = $RightTarget
@onready var left_raycast = $LeftRay
@onready var right_raycast = $RightRay
@onready var no_raycast_pos_left = $LeftStepTarget
@onready var no_raycast_pos_right = $RightStepTarget

var direction = Vector3.BACK
var strafe_dir = Vector3.ZERO
var strafe = Vector3.ZERO

var sprinting = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var walk_speed = 1.75
var run_speed = walk_speed * 2
var acceleration = 6
var movement_speed = 0.0

var ray_origin = Vector3()
var ray_target = Vector3()
var angular_acceleration = 0.5

func _input(event):
	if event is InputEventKey:
		var node_name = "UI/" + event.as_text()
		if has_node(node_name):
			if event.is_pressed():
				get_node(node_name).color = Color("ff6666")
			else:
				get_node(node_name).color = Color("FFFAFA")
		else:
			print("Node not found:", node_name)



func _physics_process(delta):
	
	apply_gravity(delta)
	
	if is_moving():
		move(delta)
		rotate_char()
	else:
		stop_move(delta)
		rotate_char()
		
	animate_blend_space_2d()
	move_and_slide()

func stop_move(delta):
	$AnimationTree.set("parameters/iwr_blend/blend_amount", lerp($AnimationTree.get("parameters/iwr_blend/blend_amount"), -1.0, delta * acceleration))
	movement_speed = 0.0
	direction = 0
	strafe_dir = Vector3.ZERO
	strafe = Vector3.ZERO
	if is_on_floor():
		velocity = Vector3.ZERO

func is_moving():
	return Input.is_action_pressed("forward") || Input.is_action_pressed("backward") || Input.is_action_pressed("left") || Input.is_action_pressed("right")

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta		
	move_and_slide()

func move(delta):
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if Input.is_action_just_pressed("sprint"):
		sprinting = not sprinting

	var speed = run_speed if sprinting else walk_speed
	var blend_position ="parameters/Run/blend_position" if sprinting else "parameters/Walk/blend_position"

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	$AnimationTree.set("parameters/iwr_blend/blend_amount", lerp($AnimationTree.get("parameters/iwr_blend/blend_amount"), 1.0 if sprinting else 0.0, delta * acceleration))
	$AnimationTree.set(blend_position, input_dir)

	move_and_slide()

func rotate_char():
	var mouse_position = get_viewport().get_mouse_position()
	
	ray_origin = $"../Camroot/h/v/Camera3D".project_ray_origin(mouse_position)
	
	ray_target = ray_origin + $"../Camroot/h/v/Camera3D".project_ray_normal(mouse_position) * 2100.0
	
	var space_state = get_world_3d().direct_space_state
	var ray_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_origin, ray_target)
	var intersection = space_state.intersect_ray(ray_query)
	
	if not intersection.is_empty():
		var pos = intersection.position
		var look_at_me = Vector3(pos.x, position.y, pos.z)
		look_at(look_at_me, Vector3.UP)
		var target_direction = look_at_me - global_transform.origin

func animate_blend_space_2d():
	var iw_blend = (velocity.length() - walk_speed) / walk_speed
	var wr_blend = (velocity.length() - walk_speed) / (run_speed - walk_speed)

	if velocity.length() <= walk_speed:
		$AnimationTree.set("parameters/iwr_blend/blend_amount" , iw_blend)
	else:
		$AnimationTree.set("parameters/iwr_blend/blend_amount" , wr_blend)
