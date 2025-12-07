extends PinJoint3D

@export var rope_path: Path3D
@export_range(1, 100) var num_links: int = 1
@export var color: Color = Color.RED


var rope_length: float = 0.0
var link_size: float = 0.0


func _ready() -> void:
	assert(rope_path, "No rope path detected for " + self.name)
	determine_link_length()

	
func determine_link_length() -> void:
	rope_length = rope_path.curve.get_baked_length()
	link_size = rope_length / num_links


func _process(_delta: float) -> void:
	pass
