extends Node3D

@export_range(0.0, 1.0) var mouse_sensitivity:float = 0.005
@export var tilt_limit:float = deg_to_rad(75)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func _unhandled_input(event: InputEvent) -> void:
	print(event is InputEventScreenTouch || event is InputEventScreenDrag)
	if Input.is_action_pressed("lock_camera"):
		return
	if event is not InputEventMouseMotion: 
		return
	
	
	if Globals.OS_TYPE == "web_desktop" && (Input.mouse_mode != Input.MOUSE_MODE_CAPTURED):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	rotation.x -= event.relative.y * mouse_sensitivity
	# Prevent the camera from rotating too far up or down.
	rotation.x = clampf(rotation.x, -tilt_limit, tilt_limit)
	rotation.y += -event.relative.x * mouse_sensitivity
