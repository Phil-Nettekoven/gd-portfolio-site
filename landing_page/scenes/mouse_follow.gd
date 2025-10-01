extends Node3D

func follow_mouse()->void:
    var mouse_position:Vector2 = get_viewport().get_mouse_position()
    
    var new_position:Vector3 = Vector3(mouse_position.x, mouse_position.y, global_position.z)
    self.global_position = new_position

func _physics_process(_delta: float) -> void:
    follow_mouse()