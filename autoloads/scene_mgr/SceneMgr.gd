extends CanvasLayer

@onready var cur_scene:String = get_tree().current_scene.name
@export var scene_list:Dictionary[String,String] #Dictionary relating scene name to file location

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func change_scene(scene_name:String) -> bool:
	if scene_name == cur_scene:
		print("Attempting to switch to current scene %s." %cur_scene)
		return false

	if scene_name not in scene_list.keys():
		print("Scene %s doesn't exist in scene_dict." % scene_name)
		return false

	var scene_location:String = scene_list[scene_name]
	var result:Error = get_tree().change_scene_to_file(scene_location)

	return result == OK

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
