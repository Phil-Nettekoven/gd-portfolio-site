extends CanvasLayer

@onready var mobile_controls:Control = %mobile_controls
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Globals.OS_TYPE == "web_android":
		init_mobile_controls()
	elif Globals.OS_TYPE == "web_ios":
		init_mobile_controls()
	else:
		init_desktop_ui()

func init_desktop_ui()->void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func init_mobile_controls()->void:
	mobile_controls.show()
	return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
