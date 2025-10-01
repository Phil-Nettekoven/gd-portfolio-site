extends Node3D

@onready var animated_sprite:AnimatedSprite3D = $AnimatedSprite3D
@onready var camera:Camera3D = %Camera3D
@onready var mouse_follow:Node3D = %MouseFollow

enum STATE {INACTIVE, ACTIVE, PRESSED}
var cur_state:STATE = STATE.INACTIVE

func look_at_mouse()->void:
	if not mouse_follow:
		return

	self.look_at(mouse_follow.global_position)

func _ready() -> void:
	pass # Replace with function body.

func _process(_delta: float) -> void:
	look_at_mouse()
