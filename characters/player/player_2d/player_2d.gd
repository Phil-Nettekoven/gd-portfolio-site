extends CharacterBody3D

@onready var sprite:AnimatedSprite3D = $sprite
const MOVESPEED:float = 2
const ACCELERATION:float = 5
const JUMP_VELOCITY:float = 4

var prev_grounded_y:float = 0
var direction:String = "right"

signal grounded_y_changed(new_y_value:float)
signal direction_changed(new_direction:String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func movement(_delta:float)->void:
	if not is_on_floor():
		velocity += (get_gravity() * Globals.GRAVITY_MOD) * _delta
	else:
		if global_position.y != prev_grounded_y:
			prev_grounded_y = global_position.y
			grounded_y_changed.emit(global_position.y)

	
	var input_dir:Vector2 = Input.get_vector("left", "right", "up", "down")

	if is_on_floor() && Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY

	if input_dir.x: # Moving
		velocity.x = input_dir.x * MOVESPEED
	elif is_on_floor(): # Decelerate if on floor
		velocity.x = 0

	move_and_slide()

func handle_animations()->void:
	var cur_direction:String = direction
	
	if velocity.x < 0:
		cur_direction = "left" 
	elif velocity.x > 0:
		cur_direction = "right"
	

	if cur_direction != direction:
		direction = cur_direction
		direction_changed.emit(direction)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	global_position.z = 0
	movement(_delta)
	handle_animations()
