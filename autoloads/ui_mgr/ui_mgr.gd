extends CanvasLayer

@onready var mobile_controls:Control = %mobile_controls
@onready var game_menu:Control = $game_menu
@onready var mouse_grab_timer:Timer = $mouse_grab_timer
enum UI_STATE {GAME_MENU, INACTIVE}

var cur_state:UI_STATE = UI_STATE.INACTIVE
var grab_mouse_when_needed:bool = true
var delayed_mouse_grab:bool = true
var mouse_needed:bool = false

func _ready() -> void:
	if Globals.OS_TYPE == "web_android":
		init_mobile_controls()
	elif Globals.OS_TYPE == "web_ios":
		init_mobile_controls()
	else:
		init_desktop_ui()

func init_desktop_ui()->void:	
	grab_mouse_when_needed = true

func init_mobile_controls()->void:
	mobile_controls.show()
	return

func toggle_game_menu()->void:
	match(cur_state):
		UI_STATE.INACTIVE: #Switch to game menu
			Engine.time_scale = 0.0
			mouse_grab_timer.stop()
			game_menu.show()
			cur_state = UI_STATE.GAME_MENU
			mouse_needed = false
		UI_STATE.GAME_MENU: #Go back to game
			game_menu.hide()
			cur_state = UI_STATE.INACTIVE
			mouse_needed = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			Engine.time_scale = 1.0

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("menu"):
		if get_tree().current_scene.name == "landing_page":
			get_tree().quit()
			return

		toggle_game_menu()
		return
	if _event is InputEventMouse:
		_manage_mouse_mode()

func _manage_mouse_mode()->void:

	if cur_state in [UI_STATE.GAME_MENU]:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		return
	
	if grab_mouse_when_needed and mouse_needed:
		if delayed_mouse_grab:
			mouse_grab_timer.start()
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta: float) -> void:
	pass

func _on_mouse_grab_timer_timeout() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_resume_pressed() -> void:
	toggle_game_menu()

func _on_quit_pressed() -> void:
	if SceneMgr.change_scene("landing_page"):
		toggle_game_menu()
	
