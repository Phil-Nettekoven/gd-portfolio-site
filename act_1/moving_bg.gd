extends Sprite3D

@onready var player:CharacterBody3D = %player

func _ready() -> void:
	self.global_position.x = player.global_position.x
	player.position_changed.connect(_on_player_position_changed)

func _on_player_position_changed(new_position:Vector3)->void:
	self.global_position.x = new_position.x
