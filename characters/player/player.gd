extends CharacterBody3D

@onready var jump_timer:Timer = $jump_timer
@onready var camera:Camera3D = %camera
var can_jump:bool = true

@onready var starting_pos:Vector3 = self.global_position
var prev_velocity:Vector3 = Vector3.ZERO

enum STATE {pathing, free, disabled}
var state:STATE = STATE.free

@onready var animated_sprite:AnimatedSprite3D = $AnimatedSprite3D
var player_direction:String = "down"
var input_dir:Vector2 = Vector2.DOWN

signal just_touched_ground
var touched_ground:bool = false

func _ready() -> void:
	pass
	
func free_movement(_delta:float)->void:
	if not is_on_floor():
		velocity += (get_gravity() * Globals.GRAVITY_MOD) * _delta
		#move_and_slide()
		#return
	
	if touched_ground == false: #Emit the first time player touches the ground
		if is_on_floor():
			touched_ground = true
			just_touched_ground.emit()
		else:
			move_and_slide()
			return
	
	input_dir = Input.get_vector("left","right","up","down")
	var direction:Vector3 = Vector3(input_dir.x,0,input_dir.y).normalized()
	direction = direction.rotated(Vector3.UP, camera.global_rotation.y)
	
	var cur_jump_velocity:float = Globals.JUMP_VELOCITY
	var cur_acceleration:float = Globals.ACCELERATION
	var cur_deceleration:float = Globals.DECELERATION
	var target_movespeed:float  = Globals.MAX_SPEED

	if is_on_floor() && Input.is_action_pressed("sprint"):
		target_movespeed = Globals.SPRINT_MAX_SPEED
		cur_jump_velocity *= Globals.JUMP_MOD
		cur_acceleration = Globals.SPRINT_ACCELERATION
		cur_deceleration = Globals.SPRINT_DECELERATION
		
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

	if input_dir.x > 0:
		movement_direction += "right"
	elif input_dir.x < 0:
		movement_direction += "left"
	elif input_dir.y < 0:
		movement_direction += "up"
	elif input_dir.y > 0:
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
	if Input.is_action_just_pressed("reset"):
		reset()
	if state == STATE.free:
		free_movement(delta)
	else: ##DISABLED
		return
		
	handle_animations()
	
func reset()->void:
	self.global_position = starting_pos
	velocity = Vector3.ZERO
