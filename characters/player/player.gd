extends CharacterBody3D

@onready var jump_timer:Timer = $jump_timer
var can_jump:bool = true

const SPEED:float = 10.0
const SPRINT_MOD:float = 2.0

const JUMP_VELOCITY:float = 2
const JUMP_MOD:float = 1.0
const JUMP_COOLDOWN:float = 0.05

enum STATE {pathing, free, disabled}
var state:STATE = STATE.free

@onready var animated_sprite:AnimatedSprite3D = $AnimatedSprite3D
var player_direction:String = "down"

func path_movement(_delta:float)->void:
	if not is_on_floor():
		velocity += get_gravity() * _delta
		return
	
	# if jump_timer.is_stopped() && not can_jump: #Start timer once the player has hit the ground again
	# 	jump_timer.start(JUMP_COOLDOWN)
	# 	return

	velocity.x = 0
	
	#if !can_jump: return
	if !(Input.is_action_pressed("left") || Input.is_action_pressed("right")): return
	var direction:Vector2 = Input.get_vector("left", "right", "up", "down").normalized()
	
	var cur_movespeed:float = SPEED
	var cur_jump_velocity:float = JUMP_VELOCITY
	if Input.is_action_pressed("sprint"):
		cur_movespeed *= SPRINT_MOD
		cur_jump_velocity *= JUMP_MOD
	

	if direction:
		velocity.x = direction.x * cur_movespeed
	else:
		velocity.x = move_toward(velocity.x, 0, cur_movespeed)
	
	if direction.x != 0:
		velocity.y = cur_jump_velocity
		#can_jump = false

func free_movement(_delta:float)->void:
	
	if not is_on_floor():
		velocity += get_gravity() * _delta
		return

	velocity.x = 0
	velocity.z = 0

	var input_dir :Vector2= Input.get_vector("left", "right", "up", "down")
	var direction :Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var cur_movespeed:float = SPEED
	var cur_jump_velocity:float = JUMP_VELOCITY
	if Input.is_action_pressed("sprint"):
		cur_movespeed *= SPRINT_MOD
		cur_jump_velocity *= JUMP_MOD

	if direction:
		velocity.x = direction.x * cur_movespeed
		velocity.z = direction.z * cur_movespeed
		velocity.y = cur_jump_velocity
	# else:
	# 	print("not moving?")
	# 	velocity.x = move_toward(velocity.x, 0, SPEED)
	# 	velocity.z = move_toward(velocity.z, 0, SPEED)

func handle_animations()->void:
	var idle:bool = false
	var movement_direction:String = ""
	var animation_string:String = ""

	if velocity.x == 0.0 && velocity.z == 0.0:
		idle = true

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

	if idle:
		animation_string = "idle_"
	animation_string += movement_direction
	animated_sprite.play(animation_string)

func change_state(new_state_name:String)->void:
	var new_state:STATE
	match(new_state_name):
		"pathing":
			new_state = STATE.pathing
		"free":
			new_state = STATE.free
		"disabled":
			new_state = STATE.disabled
		
	state = new_state


func _on_timer_timeout() -> void:
	can_jump = true

func _process(delta: float) -> void:

	
	if state == STATE.pathing:
		path_movement(delta)
	elif state == STATE.free:
		free_movement(delta)
	else: ##DISABLED
		return
	handle_animations()
	move_and_slide()


