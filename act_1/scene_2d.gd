extends Node3D

@onready var camera:Camera3D = $Camera3D
@onready var moving_bg:Sprite3D = $moving_bg

@onready var player_spawns:Node3D = $player_spawns
var player:CharacterBody3D
var player_spawn_node:Sprite3D

@export var player_scene:PackedScene

func _ready() -> void:
	UIMgr.mouse_needed = true
	UIMgr.delayed_mouse_grab = true
	
	player_spawns.hide()
	player = player_scene.instantiate()
	var spawn_name:String = SceneMgr.get_entrance_name()

	if spawn_name:
		player_spawn_node = player_spawns.find_child(spawn_name)
		assert(player_spawn_node, "Player spawn %s not found in scene %s" %[spawn_name,self.name])
	else:
		player_spawn_node = player_spawn_node.get_children()[0]
	
	player.ready.connect(_on_player_ready)
	call_deferred("add_child",player)

func _on_player_ready()->void:
	player.global_position = player_spawn_node.global_position
	camera.init_camera(player)
	moving_bg.init_moving_bg(player)
