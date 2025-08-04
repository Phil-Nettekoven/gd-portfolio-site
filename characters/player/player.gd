extends CharacterBody3D


const SPEED = 10.0
const JUMP_VELOCITY:float = 2

enum STATE {pathing, free, disabled}
var state:STATE = STATE.pathing

@onready var animated_sprite:AnimatedSprite3D = $AnimatedSprite3D
var player_direction:String = "down"

func path_movement(delta:float)->void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		return

	velocity.x = 0

	if !(Input.is_action_just_pressed("left") || Input.is_action_just_pressed("right")):return
	var direction :Vector2= Input.get_vector("left", "right", "up", "down").normalized()

	# if direction.y < 0: player_direction = "up"
	# if direction.y > 0: player_direction = "down"
	
	velocity.y = JUMP_VELOCITY
	if direction:
		velocity.x = direction.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func movement(delta:float)->void:

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		return

	velocity.x = 0
	velocity.z = 0

	# Handle jump.
	# if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir :Vector2= Input.get_vector("left", "right", "up", "down")
	var direction :Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	# if direction == Vector3.ZERO:
	# 	return

	velocity.y = JUMP_VELOCITY
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

func handle_animations()->void:
	var idle_str:String = ""
	var movement_direction:String = ""
	#var direction:String = ""
	if velocity.x == 0.0 && velocity.z == 0.0:
		idle_str += "idle_"

	if velocity.x > 0:
		movement_direction += "right"
	elif velocity.x < 0:
		movement_direction += "left"
	elif velocity.z < 0:
		movement_direction += "up"
	elif velocity.z > 0:
		movement_direction += "down"
	else:
		movement_direction = player_direction

	if player_direction != movement_direction: player_direction = movement_direction

	animated_sprite.play(idle_str+movement_direction)

func _physics_process(delta: float) -> void:
	if state == STATE.pathing:
		path_movement(delta)
	elif state == STATE.free:
		movement(delta)
	else: ##DISABLED
		return
	handle_animations()
	move_and_slide()
