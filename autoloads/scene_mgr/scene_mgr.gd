extends CanvasLayer

@export var scene_dict: Dictionary[String, String]
var stored_entrance_name: String = ""

func change_scene(scene_name: String, spawn_name: String = "") -> bool:
	if !scene_name in scene_dict:
		Globals.gprint("Scene %s not in scene_dict."%scene_name)
		return false

	stored_entrance_name = spawn_name

	var scene:PackedScene = load(scene_dict[scene_name])

	get_tree().call_deferred("change_scene_to_packed",scene)
	return true

func get_entrance_name() -> String:
	var entrance_name: String = ""
	if stored_entrance_name:
		entrance_name = stored_entrance_name
		stored_entrance_name = ""
	return entrance_name