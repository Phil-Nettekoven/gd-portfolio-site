extends Node2D

func _ready() -> void:
	if Globals.OS_TYPE in ["desktop", "web_desktop"]:
		SceneMgr.change_scene("landing_page")
	else:
		SceneMgr.change_scene("mobile_warning")
