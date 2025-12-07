extends Node3D

@onready var rope:PinJoint3D = $Rope
@onready var hanger:RigidBody3D = $hanger

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rope.node_b = hanger.get_path()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
