extends Node

const MAX_SPEED: float = 25
const SPRINT_MAX_SPEED: float = MAX_SPEED * 2
const SPRINT_MOD: float = 2.0
const ACCELERATION: float = 100
const SPRINT_ACCELERATION: float = ACCELERATION * 3

const DECELERATION: float = 100
const SPRINT_DECELERATION: float = DECELERATION * 0.5
const AIR_DECELERATION: float = 15.0

const JUMP_VELOCITY: float = 20
const JUMP_MOD: float = 1.25
const JUMP_COOLDOWN: float = 0.05
const GRAVITY_MOD: float = 2.0

const MUSIC_MAX_SPEED: float = MAX_SPEED / 4 # The player's speed at which the BGM will play at pitch = 1.0

const MAX_SPIN_TARGET_SPEED: float = 3000.0
const MIN_SPIN_TARGET_SPEED: float = 600.0
const SPIN_ACCELERATION: float = 2000.0

const SPIN_TRANSITION_THRESHOLD: float = MAX_SPIN_TARGET_SPEED * 0.66
const SPIN_BREAK_SPEED: float = 200
const SPIN_MOUSE_INPUT_MULT: float = 40.0
const SPIN_TIMER_DURATION: float = 1.25
const SPIN_MOVESPEED: float = 200

const SPRITE_NORMAL_OFFSET: Vector2 = Vector2(0, 16)
const SPRITE_SPIN_OFFSET: Vector2 = Vector2(0, 13)

var OS_TYPE: String = ""
var DEBUG_BUILD:bool = false
var is_mobile: bool = false

var timer: Timer = Timer.new()

func _ready() -> void:
	if OS.has_feature("web_android"):
		OS_TYPE = "web_android"
		is_mobile = true
	elif OS.has_feature("web_ios"):
		OS_TYPE = "web_ios"
		is_mobile = true
	elif OS.has_feature("web"):
		OS_TYPE = "web_desktop"
	else:
		OS_TYPE = "desktop"
	gprint(OS_TYPE)
	
	if OS.has_feature("debug"):
		DEBUG_BUILD = true

	timer.autostart = false
	timer.one_shot = true
	timer.ignore_time_scale = true
	timer.timeout.connect(_on_timer_timeout)
	self.add_child(timer)

func gprint(text: Variant) -> void:
	var casted_text: String = str(text)

	if !casted_text:
		casted_text = "!!INVALID CAST!!"

	var timezone_data: Dictionary = Time.get_time_zone_from_system()

	var unix_time_float: float = (Time.get_unix_time_from_system())
	unix_time_float += (timezone_data["bias"] * 60)
	var unix_time_string: String = Time.get_time_string_from_unix_time(int(unix_time_float))
	print(unix_time_string + " " + casted_text)

func _input(_event: InputEvent) -> void:
	if !DEBUG_BUILD:
		return

	if Input.is_action_just_pressed_by_event("menu", _event):
		timer.start(1.0) 
	elif Input.is_action_just_released_by_event("menu",_event):
		timer.stop()

func _on_timer_timeout() -> void: #Exit game when menu is held for 1 second
	#if Input.is_action_pressed("menu"):
	get_tree().quit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		get_tree().paused = true
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		get_tree().paused = false

func _process(_delta: float) -> void:
	pass