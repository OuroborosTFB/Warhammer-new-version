extends CharacterBody3D

@onready var left_leg = $IK/LeftTarget
@onready var right_leg = $IK/RightTarget
@onready var left_raycast = $IK/LeftRay
@onready var right_raycast = $IK/RightRay
@onready var no_raycast_pos_left = $IK/LeftStepTarget
@onready var no_raycast_pos_right = $IK/RightStepTarget
@onready var crosshair = $UI/Crosshair

@export var animation_tree: AnimationTree

@export_category("Movement")
@export var walk_speed = 5.0
@export var weight = 8.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var direction = Vector3.ZERO
var sprinting = false
var acceleration = 6
var speed = 0.0
var run_speed = walk_speed * 2


func _input(event):
	if event is InputEventKey:
		var node_name = "UI/KeyOverlay/" + event.as_text()
		if has_node(node_name):
			if event.is_pressed():
				get_node(node_name).color = Color("ff6666")
			else:
				get_node(node_name).color = Color("FFFAFA")
		else:
			print("Node not found:", node_name)

func _physics_process(delta):
	switch_sprint()
	apply_gravity(delta, weight)
	update_crosshair_position()
	rotate_char()
	
	if is_moving():
		move(delta)
	else:
		stop_move(delta)
	
	animate_blend_space_2d()
	move_and_slide()

func stop_move(delta):
	animation_tree.set("parameters/iwr_blend/blend_amount", lerp(animation_tree.get("parameters/iwr_blend/blend_amount"), -1.0, delta * acceleration))
	direction = Vector3.ZERO
	if is_on_floor():
		velocity = Vector3.ZERO

func is_moving():
	return Input.is_action_pressed("forward") || Input.is_action_pressed("backward") || Input.is_action_pressed("left") || Input.is_action_pressed("right")

func apply_gravity(delta, value):
	if not is_on_floor():
		velocity.y -= gravity * delta * value
	#move_and_slide()

func switch_sprint():
	pass


func move(delta):
	speed = run_speed if Input.is_action_pressed("sprint") else walk_speed

	if Input.is_action_pressed("forward"):
		direction.z += 1
	if Input.is_action_pressed("backward"):
		direction.z -= 1
	if Input.is_action_pressed("left"):
		direction.x += 1
	if Input.is_action_pressed("right"):
		direction.x -= 1
		
	var blend_position = "parameters/Run/blend_position" if Input.is_action_pressed("sprint") else "parameters/Walk/blend_position"
	
	if direction.length() > 0:
		direction = direction.normalized()

	var forward_direction = global_transform.basis.z.normalized()
	var sideways_direction = global_transform.basis.x.normalized()
	var look_direction = forward_direction if rotation == Vector3(0, 0, 0) else -forward_direction
	
	var final_direction = direction.x * sideways_direction + direction.z * look_direction
	
	animation_tree.set("parameters/iwr_blend/blend_amount", lerp(animation_tree.get("parameters/iwr_blend/blend_amount"), 1.0 if sprinting else 0.0, delta * acceleration))
	animation_tree.set(blend_position, Vector2(final_direction.x, final_direction.z))
	
	var move_velocity = direction * speed
	

	velocity.x = move_velocity.x
	velocity.z = move_velocity.z

		
	#move_and_slide()

func rotate_char():
	var intersection = get_intersection()
	
	if not intersection.is_empty():
		var pos = intersection.position
		var look_at_me = Vector3(pos.x, position.y, pos.z)
		look_at(look_at_me, Vector3.UP, true)

func get_intersection() -> Dictionary:
	var mouse_pos = get_viewport().get_mouse_position()
	var from = $"../Camroot/h/v/Camera3D".project_ray_origin(mouse_pos)
	var to = from + $"../Camroot/h/v/Camera3D".project_ray_normal(mouse_pos) * 1000.0
	var space_state = get_world_3d().direct_space_state
	var ray_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	var intersection = space_state.intersect_ray(ray_query)
	return intersection

func update_crosshair_position():
	var mouse_pos = get_viewport().get_mouse_position()
	crosshair.set_global_position(mouse_pos) # Установка позиции для TextureRect или Sprit

func animate_blend_space_2d():
	var iw_blend = (velocity.length() - walk_speed) / walk_speed
	var wr_blend = (velocity.length() - walk_speed) / (run_speed - walk_speed)

	if velocity.length() <= walk_speed:
		animation_tree.set("parameters/iwr_blend/blend_amount" , iw_blend)
	else:
		animation_tree.set("parameters/iwr_blend/blend_amount" , wr_blend)
