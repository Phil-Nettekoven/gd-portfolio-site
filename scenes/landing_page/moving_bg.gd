extends Sprite3D

var player:CharacterBody3D

func _ready() -> void:
	pass

func init_background(player_node:CharacterBody3D)->void:
	player = player_node
	self.global_position.x = player.global_position.x
	player.position_changed.connect(_on_player_position_changed)

func _on_player_position_changed(new_position:Vector3)->void:
	self.global_position.x = new_position.x
