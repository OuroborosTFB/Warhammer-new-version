extends CharacterBody3D

var direction = Vector3.BACK
var strafe_dir = Vector3.ZERO
var strafe = Vector3.ZERO

var sprinting = false

var gravity = 100

var movement_speed = 0
var walk_speed = 10
var run_speed = walk_speed * 2
var acceleration = 6
var angular_acceleration = 7

func _ready():
	direction = Vector3.BACK.rotated(Vector3.UP, $Camroot/h.global_transform.basis.get_euler().y)
	$Hades_Armature.look_at($"Camroot".global_transform.origin, Vector3.UP)
	

func _input(event):
	
	if event is InputEventKey:
		var node_name = "Status/" + event.as_text()
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
		rotate_char(delta)
	else:
		stop_move(delta)
		
	move_and_slide()
	animate_blend_space_2d()
	velocity = lerp(velocity, direction * movement_speed, delta * acceleration)

func stop_move(delta):
	$AnimationTree.set("parameters/iwr_blend/blend_amount", lerp($AnimationTree.get("parameters/iwr_blend/blend_amount"), -1.0, delta * acceleration))
	movement_speed = 0
	strafe_dir = Vector3.ZERO
	strafe = Vector3.ZERO

func is_moving():
	return Input.is_action_pressed("forward") || Input.is_action_pressed("backward") || Input.is_action_pressed("left") || Input.is_action_pressed("right")

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
		move_and_slide()

func move(delta):
	var h_rot = $"Camroot/h".global_transform.basis.get_euler().y
		
	direction = Vector3(Input.get_action_strength("left") - Input.get_action_strength("right"),
	0,
	Input.get_action_strength("forward") - Input.get_action_strength("backward")).normalized()
		
	strafe_dir = direction
	
	if Input.is_action_just_pressed("sprint"):
		sprinting = not sprinting
	
	direction = direction.rotated(Vector3.UP, h_rot).normalized()
	strafe = lerp(strafe, strafe_dir, delta * acceleration)
	if sprinting:
			movement_speed = run_speed
			$AnimationTree.set("parameters/iwr_blend/blend_amount", lerp($AnimationTree.get("parameters/iwr_blend/blend_amount"), 1.0, delta * acceleration))
			$AnimationTree.set("parameters/Run/blend_position", Vector2(-strafe.x, strafe.z))
	else:
			movement_speed = walk_speed
			$AnimationTree.set("parameters/iwr_blend/blend_amount", lerp($AnimationTree.get("parameters/iwr_blend/blend_amount"), 0.0, delta * acceleration))
			$AnimationTree.set("parameters/Walk/blend_position", Vector2(-strafe.x, strafe.z))

func rotate_char(delta):
	$Hades_Armature.rotation.y = lerp_angle($Hades_Armature.rotation.y, $Camroot/h.rotation.y, delta * angular_acceleration)

func animate_blend_space_2d():
	var iw_blend = (velocity.length() - walk_speed) / walk_speed
	var wr_blend = (velocity.length() - walk_speed) / (run_speed - walk_speed)

	if velocity.length() <= walk_speed:
		$AnimationTree.set("parameters/iwr_blend/blend_amount" , iw_blend)
	else:
		$AnimationTree.set("parameters/iwr_blend/blend_amount" , wr_blend)
