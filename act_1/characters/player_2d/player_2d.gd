extends CharacterBody3D

@onready var sprite:AnimatedSprite3D = $sprite
const MOVESPEED:float = 2
const ACCELERATION:float = 5
const JUMP_VELOCITY:float = 4

var prev_grounded_y:float = 0
var direction:String = "right"

var collision_force:float = 20.0
@onready var prev_position:Vector3 = self.global_position

signal grounded_y_changed(new_y_value:float)
signal direction_changed(new_direction:String)
signal position_changed(new_position:Vector3)

enum STATE {free, spin_startup, spinning_locked,spinning_free, disabled}
var state: STATE = STATE.free

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

#region movement_logic

func free_movement(_delta:float)->void:
	if not is_on_floor():
		velocity += (get_gravity() * Globals.GRAVITY_MOD) * _delta
	else:
		if global_position.y != prev_grounded_y:
			prev_grounded_y = global_position.y
			grounded_y_changed.emit(global_position.y)

	var input_dir:Vector2 = Input.get_vector("left", "right", "up", "down")

	if is_on_floor() && Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY

	input_dir.x = roundf(input_dir.x)

	if input_dir.x: # Moving
		velocity.x = input_dir.x * MOVESPEED
	elif is_on_floor(): # Decelerate if on floor
		velocity.x = 0

func spin_startup_movement(_delta: float) -> void:
	var cur_deceleration:float = Globals.DECELERATION
	if not is_on_floor():
		velocity += (get_gravity() * Globals.GRAVITY_MOD) * _delta
		cur_deceleration = Globals.SPRINT_DECELERATION

	velocity.x = move_toward(velocity.x, 0, _delta * cur_deceleration)
	velocity.z = move_toward(velocity.z, 0, _delta * cur_deceleration)

func spin_movement(_delta:float)->void:
	if not is_on_floor():
		velocity += (get_gravity() * Globals.GRAVITY_MOD) * _delta
		# velocity.x = move_toward(velocity.x, 0, _delta * Globals.AIR_DECELERATION* 2)
		# velocity.z = move_toward(velocity.z, 0, _delta * Globals.AIR_DECELERATION * 2)
	elif Input.is_action_pressed("jump"):
		velocity.y = Globals.JUMP_VELOCITY

	var input_dir:Vector2

	input_dir = Vector2.RIGHT
	var movement_direction: Vector3 = Vector3(input_dir.x, 0, input_dir.y).normalized()
	#direction = direction.rotated(Vector3.UP, camera.global_rotation.y)
	
	movement_direction *= Globals.SPIN_MOVESPEED
	velocity.x = move_toward(velocity.x, movement_direction.x, _delta * Globals.SPRINT_ACCELERATION)
	velocity.z = move_toward(velocity.z, movement_direction.z, _delta * Globals.SPRINT_ACCELERATION)
	
#endregion

func handle_animations()->void:
	var cur_direction:String = direction
	
	if velocity.x < 0:
		cur_direction = "left" 
	elif velocity.x > 0:
		cur_direction = "right"
	
	if cur_direction != direction:
		direction = cur_direction
		direction_changed.emit(direction)
	
func handle_collisions(_delta:float)->void:
	for i in get_slide_collision_count():
		var cur:KinematicCollision3D = get_slide_collision(i)
		if cur.get_collider() is RigidBody3D:
			var negative_normal:Vector3 = -cur.get_normal()
			negative_normal.z = 0
			cur.get_collider().apply_central_impulse(negative_normal * collision_force * _delta)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if state in [STATE.free, STATE.spinning_free]:
		free_movement(_delta)
	elif state == STATE.spin_startup:
		spin_startup_movement(_delta)
	elif state == STATE.spinning_locked:
		spin_movement(_delta)
	
	handle_animations()
	move_and_slide()

	if global_position != prev_position:
		position_changed.emit(global_position)
		prev_position = global_position


func _physics_process(_delta: float) -> void:
	handle_collisions(_delta)
	
	
