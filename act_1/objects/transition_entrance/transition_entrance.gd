extends Area3D

@export var scene_name:String = ""
@export var spawn_name:String = ""

var player:CharacterBody3D = null

signal player_entered_body
signal player_left_body

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	return
	#assert(scene_name && spawn_name, "Check scene_name or entrance_name in transition " %self.name)

func _input(_event: InputEvent) -> void:
	if player == null:
		return

	if !player.is_on_floor():
		return
	
	if not Input.is_action_just_pressed_by_event("up", _event):
		return

	SceneMgr.change_scene(scene_name, spawn_name)

func _on_body_entered(body: Node3D) -> void:
	if body.name != "player" || body is not CharacterBody3D:
		return
	
	player = body
	player_entered_body.emit()

func _on_body_exited(body: Node3D) -> void:
	if body.name != "player":
		return
	
	player = null
	player_left_body.emit()
