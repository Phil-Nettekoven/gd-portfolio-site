extends AnimatedSprite3D

@export var scene_name:String = ""
@export var spawn_name:String = ""

@onready var transition:Area3D = $transition_entrance

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(scene_name, "Transition %s has no scene associated with it!" %name)
	transition.scene_name = scene_name
	transition.spawn_name = spawn_name
	transition.player_entered_body.connect(_on_player_entered_transition)
	transition.player_left_body.connect(_on_player_left_transition)

func _on_player_entered_transition()->void:
	play("opened")

func _on_player_left_transition()->void:
	play("closed")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
