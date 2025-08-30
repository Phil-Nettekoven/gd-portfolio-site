extends Node3D

@export_range(0.0, 1.0) var mouse_sensitivity:float = 0.005
@export var tilt_limit:float = deg_to_rad(75)

signal locked_camera_pivot(value:Vector2)
signal camera_locked
signal camera_unlocked

var is_camera_locked:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func _unhandled_input(event: InputEvent) -> void:
	#print(event is InputEventScreenTouch || event is InputEventScreenDrag)
	if event is not InputEventMouseMotion: 
		return
	
	if Globals.OS_TYPE == "web_desktop" && (Input.mouse_mode != Input.MOUSE_MODE_CAPTURED):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	free_camera(event)
		
# func _input(_event: InputEvent) -> void:
# 	if Input.is_action_just_pressed("lock_camera"):
# 		camera_locked.emit()
# 		is_camera_locked = true
# 	elif Input.is_action_just_released("lock_camera"):
# 		camera_unlocked.emit()
# 		is_camera_locked = false

func free_camera(event: InputEvent)->void:
	rotation.x -= event.relative.y * mouse_sensitivity
	rotation.x = clampf(rotation.x, -tilt_limit, tilt_limit)
	rotation.y += -event.relative.x * mouse_sensitivity

func locked_camera(event: InputEvent)->void:
	var camera_pivot:Vector2 = Vector2.ZERO
	
	camera_pivot.x = event.relative.y * mouse_sensitivity
	camera_pivot.y = -event.relative.x * mouse_sensitivity
	
	locked_camera_pivot.emit(camera_pivot)
