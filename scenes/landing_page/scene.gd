extends Node3D

@onready var camera:Camera3D = $Camera3D
@onready var moving_bg:Sprite3D = $moving_bg

func _init_scene(player_node:CharacterBody3D) -> void:
	camera.init_camera(player_node)
	moving_bg.init_background(player_node)
