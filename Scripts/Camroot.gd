extends Node3D
@export_category("Camera Effects")
@export var camrot_h = 0.0
@export var camrot_v = 0.0
@export var cam_v_max = 20.0
@export var cam_v_min = -10.0
@export var h_sensitivity = 0.05
@export var v_sensitivity = 0.05
@export var h_acceleration = 10.0
@export var v_acceleration = 10.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$h/v/Camera3D.get_last_exclusive_window()
	
func _input(event):
	if event is InputEventMouseMotion:
		camrot_h += -event.relative.x * h_sensitivity
		camrot_v += event.relative.y * v_sensitivity
		
func _physics_process(delta):
	camrot_v = clamp(camrot_v, cam_v_min, cam_v_max)
	
	var mesh_front = $"../Hades_Armature".global_transform.basis.z
	var rot_speed_multiplier = 0.10 #reduce this to make the rotation radius larger
	var _auto_rotate_speed =  ((PI - mesh_front.angle_to($h.global_transform.basis.z)) * get_parent().velocity.length() * rot_speed_multiplier)

	$h.rotation_degrees.y = lerp(float($h.rotation_degrees.y), camrot_h, delta * h_acceleration)
	
	$h/v.rotation_degrees.x = lerp(float($h/v.rotation_degrees.x), camrot_v, delta * v_acceleration)


