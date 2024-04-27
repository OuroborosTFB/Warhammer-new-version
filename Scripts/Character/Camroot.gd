extends Node3D

@export var character: CharacterBody3D

@export_category("Camera Effects")
@export var camrot_h = 0.0
@export var camrot_v = 0.0
@export var cam_v_max = 5.0
@export var cam_v_min = -5.0
@export var cam_h_max = 20.0
@export var cam_h_min = -20.0
@export var h_sensitivity = 0.05
@export var v_sensitivity = 0.05
@export var camera_acceleration = 4.0
@export var v_acceleration = 0.8

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	$h/v/Camera3D.get_last_exclusive_window()
	
func _input(event):
	if event is InputEventMouseMotion:
		camrot_h += -event.relative.x * h_sensitivity
		camrot_v += event.relative.y * v_sensitivity
		
func _physics_process(delta):
	update_camera_position(delta, camera_acceleration)
	camrot_v = clamp(camrot_v, cam_v_min, cam_v_max)
	camrot_h = clamp(camrot_h, cam_h_min, cam_h_max)
	$h/v.rotation_degrees.x = lerp(float($h/v.rotation_degrees.x), camrot_v, delta * v_acceleration)


func update_camera_position(delta, camera_speed):
	if character:
		var current_position = global_transform.origin
		var target_position = character.global_transform.origin

		var new_position = current_position + (target_position - current_position) * (delta * camera_speed)
		global_transform.origin = new_position
