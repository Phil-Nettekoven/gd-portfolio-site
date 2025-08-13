extends CharacterBody3D

@onready var jump_timer:Timer = $jump_timer
@onready var camera:Camera3D = %camera
var can_jump:bool = true

const MAX_SPEED:float  = 100
const SPRINT_MAX_SPEED:float = MAX_SPEED*2
const SPRINT_MOD:float = 2.0
const ACCELERATION:float = 50
const SPRINT_ACCELERATION:float = ACCELERATION*1.25
const DECELERATION:float = 100
const SPRINT_DECELERATION:float = DECELERATION*0.5

const JUMP_VELOCITY:float = 20
const JUMP_MOD:float = 1.25
const JUMP_COOLDOWN:float = 0.05
const GRAVITY_MOD:float = 2.0

@onready var starting_pos:Vector3 = self.global_position

enum STATE {pathing, free, disabled}
var state:STATE = STATE.free

@onready var animated_sprite:AnimatedSprite3D = $AnimatedSprite3D
var player_direction:String = "down"

func path_movement(_delta:float)->void:
	if not is_on_floor():
		velocity += (get_gravity() * GRAVITY_MOD) * _delta
		return

	# if jump_timer.is_stopped() && not can_jump: #Start timer once the player has hit the ground again
	# 	jump_timer.start(JUMP_COOLDOWN)
	# 	return

	velocity.x = 0

	#if !can_jump: return
	if !(Input.is_action_pressed("left") || Input.is_action_pressed("right")): return
	var direction:Vector2 = Input.get_vector("left", "right", "up", "down").normalized()

	var cur_movespeed:float = MAX_SPEED
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
		velocity += (get_gravity() * GRAVITY_MOD) * _delta
		#move_and_slide()
		#return
		
	var input_dir:Vector2 = Input.get_vector("left","right","up","down")
	var direction:Vector3 = Vector3(input_dir.x,0,input_dir.y).normalized()
	direction = direction.rotated(Vector3.UP, camera.global_rotation.y)
	
	var cur_jump_velocity:float = JUMP_VELOCITY
	var cur_acceleration:float = ACCELERATION
	var cur_deceleration:float = DECELERATION
	var target_movespeed:float  = MAX_SPEED

	if is_on_floor() && Input.is_action_pressed("sprint"):
		target_movespeed = SPRINT_MAX_SPEED
		cur_jump_velocity *= JUMP_MOD
		cur_acceleration = SPRINT_ACCELERATION
		cur_deceleration = SPRINT_DECELERATION
		
	if direction: #Moving
		direction *= target_movespeed
		velocity.x = move_toward(velocity.x, direction.x, _delta * cur_acceleration)
		velocity.z = move_toward(velocity.z, direction.z, _delta * cur_acceleration)
	elif is_on_floor(): #Decelerate if on floor
		velocity.x = move_toward(velocity.x, 0, _delta * cur_deceleration)
		velocity.z = move_toward(velocity.z, 0, _delta * cur_deceleration)
	
	if is_on_floor() && Input.is_action_pressed("jump"):
		velocity.y = cur_jump_velocity

	move_and_slide()
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
	print(velocity.y)
	if Input.is_action_just_pressed("reset"):
		reset()
	if state == STATE.pathing:
		path_movement(delta)
	elif state == STATE.free:
		free_movement(delta)
	else: ##DISABLED
		return
	handle_animations()
	
func reset()->void:
	self.global_position = starting_pos
	velocity = Vector3.ZERO
