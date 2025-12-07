extends Path3D

@export_range(1, 100) var num_links: int = 1
@export var color: Color = Color.RED
@export var hanger_scene: PackedScene
var rope_link_scene: PackedScene = load('res://landing_page/objects/rope/rope_link.tscn')

var rope_length: float = 0.0
var link_size: float = 0.0
var joints:Array[PinJoint3D]
var links:Array[RigidBody3D]
var hanger:RigidBody3D

func _ready() -> void:
	assert(self.curve, "No curve detected for rope " + self.name)
	assert(hanger_scene, "No object attached as hanger_scene in " + self.name)
	generate_rope()
	
func generate_rope()->void:
	var points:PackedVector3Array = self.curve.get_baked_points()
	var i:int = 0
	
	for p:Vector3 in points:
		var new_joint:PinJoint3D = PinJoint3D.new()
		var new_link:RigidBody3D = rope_link_scene.instantiate()

		joints.append(new_joint)
		links.append(new_link)
		
		

		self.add_child(new_joint)
		self.add_child(new_link)
		
		var collision_shape:CollisionShape3D = new_link.collision_shape
		collision_shape.shape.height = 1.0
		new_joint.position = p

		if i > 0:
			new_joint.node_a = links[i-1].get_path()
		
		new_joint.node_b = new_link.get_path()

		i += 1
	
	hanger = hanger_scene.instantiate()
	joints[len(joints)-1].node_b = hanger.get_path()

func _process(_delta: float) -> void:
	pass
