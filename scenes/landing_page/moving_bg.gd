extends Sprite3D

@onready var player:CharacterBody3D = %player

func _ready() -> void:
	self.global_position.x = player.global_position.x


func _process(_delta: float) -> void:
	self.global_position.x = player.global_position.x

