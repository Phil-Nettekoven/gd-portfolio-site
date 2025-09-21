extends Node3D

@onready var door:AnimatedSprite3D = $door
@onready var transition:Area3D = $transition_entrance

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	transition.player_entered_body.connect(_on_player_entered_transition)
	transition.player_left_body.connect(_on_player_left_transition)

func _on_player_entered_transition()->void:
	door.play("opened")

func _on_player_left_transition()->void:
	door.play("closed")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
