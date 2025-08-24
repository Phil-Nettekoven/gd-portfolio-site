extends Node

const MAX_SPEED:float  = 100
const SPRINT_MAX_SPEED:float = MAX_SPEED*2
const SPRINT_MOD:float = 2.0
const ACCELERATION:float = 50
const SPRINT_ACCELERATION:float = ACCELERATION*1.25

const DECELERATION:float = 100
const SPRINT_DECELERATION:float = DECELERATION*0.5
const AIR_DECELERATION:float = 15.0

const JUMP_VELOCITY:float = 20
const JUMP_MOD:float = 1.25
const JUMP_COOLDOWN:float = 0.05
const GRAVITY_MOD:float = 2.0

const MUSIC_MAX_SPEED:float = MAX_SPEED/4 #The player's speed at which the BGM will play at pitch = 1.0

var OS_TYPE:String = ""
var is_mobile:bool = false

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
	print(OS_TYPE)