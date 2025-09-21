extends Area3D

@export var scene_name:String = ""
var player_inside:bool = false

signal player_entered_body
signal player_left_body

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _input(_event: InputEvent) -> void:
	if player_inside == false:
		return
	
	if not Input.is_action_just_pressed_by_event("up", _event):
		return

	#SceneMgr.change_scene(scene_name)

func _on_body_entered(body: Node3D) -> void:
	if body.name != "player":
		return
	
	player_inside = true
	player_entered_body.emit()

func _on_body_exited(body: Node3D) -> void:
	if body.name != "player":
		return
	
	player_inside = false
	player_left_body.emit()
