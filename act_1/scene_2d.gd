extends Node3D

@onready var camera:Camera3D = $Camera3D
@onready var moving_bg:Sprite3D = $moving_bg

@onready var player_spawns:Node3D = $player_spawns
@onready var player:CharacterBody3D = %player


func _ready() -> void:
	#assert(spawn_name, "No spawn name provided transitioning to scene %s" %self.name)
	player_spawns.hide()
	if !player.is_node_ready():
		player.ready.connect(_on_player_ready)
	else:
		_on_player_ready()


func _on_player_ready()->void:
	var spawn_name:String = SceneMgr.get_entrance_name()

	var player_spawn_node:Sprite3D
	if spawn_name:
		player_spawn_node = player_spawns.find_child(spawn_name)
		assert(player_spawn_node, "Player spawn %s not found in scene %s" %[spawn_name,self.name])
	else:
		player_spawn_node = player_spawn_node.get_children()[0]

	player.global_position = player_spawn_node.global_position
	camera.init_camera()
