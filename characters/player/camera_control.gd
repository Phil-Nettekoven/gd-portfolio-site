extends SpringArm3D

@export var mouse_sensitivity: float = 0.005

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventMouseMotion: return
	
	rotation.y -= event.relative.x * mouse_sensitivity
	rotation.y = wrapf(rotation.y, 0.0, TAU)
	
	rotation.x -= event.relative.y * mouse_sensitivity
	rotation.x = clamp(rotation.x, -PI/2, PI/4)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
