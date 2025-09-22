class_name ActOneMasterScene extends Node

@onready var initial_scene:String = "act_1_3"
@export var scene_dictionary:Dictionary[String,PackedScene]
@export var player_scene:PackedScene

var cur_scene:Node3D = null
@onready var player:CharacterBody3D = $player


static var _singleton: ActOneMasterScene = null
static var singleton: ActOneMasterScene:
	get:
		return _singleton

func _init() -> void:
	if singleton == null:
		_singleton = self

func _ready() -> void:
	assert(initial_scene, "initial_scene is null.")
	assert(player_scene, "player_scene is null.")
	player = player_scene.instantiate()
	player.hide()
	change_scene(initial_scene)

func _on_transition_used(scene_name:String, entrance_name:String) -> void:
	change_scene(scene_name, entrance_name)

func change_scene(scene_name:String, entrance_name:String = "") -> void:
	assert(scene_name in scene_dictionary, "Scene name %s isn't in the scene dictionary." %scene_name)
	
	player.global_position = Vector3(-9999,-9999,-9999)
	player.hide()
	
	remove_old_scene()
		
	cur_scene = scene_dictionary[scene_name].instantiate()
	
	self.add_child(cur_scene)
	cur_scene.add_child(player)
	cur_scene._init_scene(player, entrance_name)
	
	player.show()

func remove_old_scene()->void:
	if cur_scene == null:
		return
	
	cur_scene.remove_child(player)
	cur_scene.queue_free()
	cur_scene = null
	# if is_connected(cur_scene.change_scene, change_scene):
	# 	cur_scene.change_scene.disconnect(change_scene)
