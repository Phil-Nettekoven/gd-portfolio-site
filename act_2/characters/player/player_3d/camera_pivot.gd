extends Node3D

@export_range(0.0, 1.0) var mouse_sensitivity:float = 0.005
@export var tilt_limit:float = deg_to_rad(75)

signal locked_camera_pivot(value:Vector2)

var is_camera_locked:bool = false

func _ready() -> void:
	pass
	
func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventMouseMotion: 
		return
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	free_camera(event)
	rotation_degrees.y =  fposmod(rotation_degrees.y, 360)
	

func free_camera(event: InputEvent)->void:
	rotation.x -= event.relative.y * mouse_sensitivity
	rotation.x = clampf(rotation.x, -tilt_limit, tilt_limit)
	rotation.y += -event.relative.x * mouse_sensitivity

	
