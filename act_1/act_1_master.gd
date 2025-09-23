class_name ActOneMasterScene extends Node3D

@onready var initial_scene:String = "act_1_3"
@export var scene_dictionary:Dictionary[String,PackedScene]

var cur_scene:Node3D = null
var stored_entrance:String = ""
var stored_scene_name:String = ""
var in_progress:bool = false

static var _singleton: ActOneMasterScene = null
static var singleton: ActOneMasterScene:
	get:
		return _singleton

func _init() -> void:
	if singleton == null:
		_singleton = self

func _ready() -> void:
	assert(initial_scene, "initial_scene is null.")
	change_scene(initial_scene)

func _on_transition_used(scene_name:String, entrance_name:String) -> void:
	change_scene(scene_name, entrance_name)

func change_scene(scene_name:String, entrance_name:String = "from_1_2") -> void:
	assert(scene_name in scene_dictionary, "Scene name %s isn't in the scene dictionary." %scene_name)
	
	if in_progress == true:
		return

	in_progress = true
	stored_entrance = entrance_name
	stored_scene_name = scene_name

	remove_old_scene()
		
func remove_old_scene()->void:
	if cur_scene == null:
		create_new_scene()
		return
	if cur_scene.is_queued_for_deletion():
		return

	cur_scene.tree_exited.connect(create_new_scene)
	#self.remove_child(cur_scene)
	cur_scene.queue_free()

func create_new_scene() -> void:
	cur_scene = null
	cur_scene = scene_dictionary[stored_scene_name].instantiate()

	cur_scene.ready.connect(_on_new_scene_ready)
	call_deferred("add_child", cur_scene)

func _on_new_scene_ready()->void:
	assert(stored_entrance && stored_scene_name, "stored_entrance or stored_scene_name is null.")

	cur_scene._init_scene(stored_entrance)
	stored_entrance = ""
	stored_scene_name = ""
	in_progress = false




	
