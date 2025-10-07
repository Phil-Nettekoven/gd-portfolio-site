extends CanvasLayer

@export var scene_dict: Dictionary[String, String]


func change_scene(scene_name:String) -> void:
	if !scene_name in scene_dict:
		Globals.gprint("Scene %s not in scene_dict." %scene_name)
		return

	get_tree().change_scene_to_file(scene_dict[scene_name])
