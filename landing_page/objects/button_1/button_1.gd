extends Node3D

@onready var animated_sprite:AnimatedSprite3D = $AnimatedSprite3D

enum STATE {INACTIVE, ACTIVE, PRESSED}
var cur_state:STATE = STATE.INACTIVE

func look_at_mouse()->void:
	var mouse_position:Vector2 = get_viewport().get_mouse_position()
	var target_position:Vector3 = Vector3(mouse_position.x, self.global_position.y, 0)

	self.look_at(target_position)

func _ready() -> void:
	pass # Replace with function body.


func _process(_delta: float) -> void:
	look_at_mouse()
