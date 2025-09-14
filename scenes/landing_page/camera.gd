extends Camera3D

@onready var player:CharacterBody3D = %player
@onready var prev_position:Vector3 = player.global_position

const lerp_speed:float = 30

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.global_position.x = player.global_position.x

func update_position(_delta:float)->void:
	if global_position.x == player.global_position.x:
		return
	self.global_position.x = lerp(self.global_position.x, player.global_position.x, lerp_speed * _delta)
	prev_position = player.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	update_position(_delta)

