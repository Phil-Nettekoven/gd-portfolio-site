extends Node3D

@onready var camera:Camera3D = $Camera3D
@onready var moving_bg:Sprite3D = $moving_bg
@onready var player_spawns:Node3D = $player_spawns

func _init_scene(player_node:CharacterBody3D, spawn_name:String) -> void:
	camera.init_camera(player_node)
	moving_bg.init_background(player_node)
	player_spawns.hide()

	var player_spawn_node:Sprite3D
	if spawn_name:
		player_spawn_node = player_spawns.find_child(spawn_name)
		assert(player_spawn_node, "Player spawn %s not found in scene %s" %spawn_name %self.name)
	else:
		player_spawn_node = player_spawns.get_children()[0]
		assert(player_spawn_node, "No player spawn found to default to in scene %s" %self.name)
	
	player_node.global_position = player_spawn_node.global_position
