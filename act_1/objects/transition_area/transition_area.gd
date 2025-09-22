extends Area3D

@export var scene_name:String = ""
@export var entrance_name:String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(scene_name && entrance_name, "Check scene_name or entrance_name in transition " %self.name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if body.name != "player":
		return
	
	ActOneMasterScene.singleton.change_scene(scene_name, entrance_name)
