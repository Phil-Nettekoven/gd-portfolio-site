extends CharacterBody3D

@onready var sprite:AnimatedSprite3D = $sprite
const MOVESPEED:float = 2
const ACCELERATION:float = 5
const JUMP_VELOCITY:float = 4


signal player_moved(new_position:Vector2)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func movement(_delta:float)->void:
	if not is_on_floor():
		velocity += (get_gravity() * Globals.GRAVITY_MOD) * _delta
	
	var input_dir:Vector2 = Input.get_vector("left", "right", "up", "down").normalized()

	if is_on_floor() && Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY

	if input_dir.x: # Moving
		player_moved.emit()
		velocity.x = input_dir.x * MOVESPEED
	elif is_on_floor(): # Decelerate if on floor
		velocity.x = 0

	move_and_slide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	movement(_delta)
