extends Camera3D

@onready var player: CharacterBody3D = %player
var player_direction:String
var prev_position: Vector3

@onready var camera_z_value: float = self.global_position.z
@onready var camera_y_offset: float = self.global_position.y
var camera_y_target: float = camera_y_offset

const LERP_SPEED: float = 5.0
const X_OFFSET_AMOUNT:float = 0.2
var cur_x_offset:float = 0.0

func _ready() -> void:
	pass

func init_camera()->void:
	player_direction = player.direction
	prev_position = player.global_position
	camera_y_target = player.global_position.y + camera_y_offset
	
	player.grounded_y_changed.connect(_on_player_y_changed)
	player.direction_changed.connect(_on_player_direction_changed)

	var initial_position:Vector3
	initial_position.x = player.global_position.x
	initial_position.y = camera_y_target
	initial_position.z = camera_z_value

	self.global_position = initial_position

func update_position(_delta: float) -> void:
	if player == null: return
	
	var target_position: Vector3 = Vector3()

	target_position.x = player.global_position.x + cur_x_offset
	target_position.y = camera_y_target
	target_position.z = camera_z_value

	self.global_position = self.global_position.lerp(target_position, LERP_SPEED * _delta)

func _on_player_y_changed(new_y_value: float) -> void:
	camera_y_target = new_y_value + camera_y_offset

func _on_player_direction_changed(new_direction: String) -> void:
	player_direction = new_direction
	if new_direction == "right":
		cur_x_offset = X_OFFSET_AMOUNT
	else:
		cur_x_offset = -X_OFFSET_AMOUNT

func _process(_delta: float) -> void:
	update_position(_delta)
