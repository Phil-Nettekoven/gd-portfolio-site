extends Node

@onready var initial_scene:String = "act_1_3"
@export var scene_dictionary:Dictionary[String,PackedScene]
@export var player_scene:PackedScene

var cur_scene:Node3D = null
@onready var player:CharacterBody3D = $player

func _ready() -> void:
	assert(initial_scene, "initial_scene is null.")
	assert(player_scene, "player_scene is null.")
	player = player_scene.instantiate()
	player.hide()
	change_scene(initial_scene)
	
func change_scene(scene_name:String) -> void:
	assert(scene_name in scene_dictionary, "Scene name %s isn't in the scene dictionary." %scene_name)
	player.hide()
	
	if cur_scene != null:
		cur_scene.remove_child(player)
		cur_scene.queue_free()
		cur_scene = null
		
	cur_scene = scene_dictionary[scene_name].instantiate()
	self.add_child(cur_scene)
	cur_scene.add_child(player)
	cur_scene._init_scene(player)
	
	player.show()
