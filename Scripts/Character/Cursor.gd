extends Node3D

@export var camera: Camera3D
@export var rotation_radius: float = 10.0
@export var rotation_speed: float = 1.0

var rotation_angle: float = 0.0

func _physics_process(_delta):
	rotating()

func get_intersection() -> Dictionary:
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000.0
	var space_state = get_world_3d().direct_space_state
	var ray_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	var intersection = space_state.intersect_ray(ray_query)
	return intersection

func rotating():
	var intersection = get_intersection()
	
	if not intersection.is_empty():
		var pos = intersection.position
		var center = Vector3(pos.x, position.y, pos.z)
		var look_at_me = center
		look_at(look_at_me, Vector3.UP, true)
