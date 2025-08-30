extends CharacterBody3D

#region variables

@onready var camera: Camera3D = %camera
@onready var camera_pivot: Node3D = $camera_pivot

@onready var sprite: AnimatedSprite3D = $sprite_pivot/AnimatedSprite3D
@onready var sprite_pivot: Node3D = $sprite_pivot
@onready var spin_timer:Timer = $spin_timer
var rotation_speed: float = 0.0
var target_rotation_speed: float = 0.0
var cur_rotation_speed: float = 0.0
var added_speed: bool = false

@onready var starting_pos: Vector3 = self.global_position
var prev_velocity: Vector3 = Vector3.ZERO

enum STATE {pathing, free, spin_startup, spinning_locked,spinning_free, disabled}
var state: STATE = STATE.free

var player_direction: String = "down"
var input_dir: Vector2 = Vector2.DOWN

signal just_touched_ground
var touched_ground: bool = false
#endregion

func _ready() -> void:
	camera_pivot.locked_camera_pivot.connect(_on_locked_camera_pivot)
	camera_pivot.camera_locked.connect(_on_camera_locked)
	camera_pivot.camera_unlocked.connect(_on_camera_unlocked)
	velocity.y = -20

#region Movement

func free_movement(_delta: float) -> void:
	var cur_jump_velocity: float = Globals.JUMP_VELOCITY
	var cur_acceleration: float = Globals.ACCELERATION
	var cur_deceleration: float = Globals.DECELERATION
	var target_movespeed: float = Globals.MAX_SPEED
	
	if not is_on_floor():
		velocity += (get_gravity() * Globals.GRAVITY_MOD) * _delta
		cur_deceleration = Globals.AIR_DECELERATION
	
	if touched_ground == false: # Emit the first time player touches the ground
		if is_on_floor():
			touched_ground = true
			just_touched_ground.emit()
		else:
			move_and_slide()
			return
	
	input_dir = Input.get_vector("left", "right", "up", "down")
	var direction: Vector3 = Vector3(input_dir.x, 0, input_dir.y).normalized()
	direction = direction.rotated(Vector3.UP, camera.global_rotation.y)

	if is_on_floor():
		if Globals.is_mobile || Input.is_action_pressed("sprint"):
			target_movespeed = Globals.SPRINT_MAX_SPEED
			cur_jump_velocity *= Globals.JUMP_MOD
			cur_acceleration = Globals.SPRINT_ACCELERATION
			cur_deceleration = Globals.SPRINT_DECELERATION
	
	if is_on_floor() && Input.is_action_pressed("jump"):
		velocity.y = cur_jump_velocity
		
	
	if direction: # Moving
		direction *= target_movespeed
		velocity.x = move_toward(velocity.x, direction.x, _delta * cur_acceleration)
		velocity.z = move_toward(velocity.z, direction.z, _delta * cur_acceleration)
	else: # Decelerate if on floor
		velocity.x = move_toward(velocity.x, 0, _delta * cur_deceleration)
		velocity.z = move_toward(velocity.z, 0, _delta * cur_deceleration)
	
	move_and_slide()

func spin_startup_movement(_delta: float) -> void:
	
	if not is_on_floor():
		velocity += (get_gravity() * Globals.GRAVITY_MOD) * _delta
		#cur_deceleration = Globals.AIR_DECELERATION

	velocity.x = move_toward(velocity.x, 0, _delta * Globals.SPRINT_DECELERATION)
	velocity.z = move_toward(velocity.z, 0, _delta * Globals.SPRINT_DECELERATION)
	move_and_slide()

func spin_movement(_delta:float)->void:
	if not is_on_floor():
		velocity += (get_gravity() * Globals.GRAVITY_MOD) * _delta
		velocity.x = move_toward(velocity.x, 0, _delta * Globals.AIR_DECELERATION* 2)
		velocity.z = move_toward(velocity.z, 0, _delta * Globals.AIR_DECELERATION * 2)

	move_and_slide()

#endregion

#region sprite_rotation

func rotate_sprite(_delta: float) -> void:
	if added_speed:
		rotation_speed = lerp(rotation_speed, target_rotation_speed, _delta)
	elif state != STATE.spin_startup && spin_timer.is_stopped():
		rotation_speed = lerp(rotation_speed, 0.0, _delta * 100)
	
	sprite_pivot.rotation_degrees.y += rotation_speed * _delta
	
	if is_on_floor() && state == STATE.spin_startup && rotation_speed > Globals.SPIN_TRANSITION_THRESHOLD:
		state = STATE.spinning_locked
		spin_timer.start(Globals.SPIN_TIMER_DURATION)
		var direction: Vector3 = -camera.get_global_transform_interpolated().basis.z.normalized()
		#print(direction)
		velocity.x = direction.x * Globals.SPIN_MOVESPEED
		velocity.z = direction.z * Globals.SPIN_MOVESPEED
		
	elif state == STATE.spinning_locked && rotation_speed <= Globals.SPIN_TRANSITION_THRESHOLD:
		state = STATE.spin_startup
		#direction = direction.rotated(Vector3.UP, camera.global_rotation.y)

	added_speed = false

func _on_locked_camera_pivot(pivot_value: Vector2) -> void:
	if state == STATE.spinning_locked:
		added_speed = false
		return
	target_rotation_speed = clampf(target_rotation_speed + (pivot_value.length() * Globals.SPIN_MOUSE_INPUT_MULT), 0.0, Globals.MAX_SPIN_TARGET_SPEED)
	added_speed = true

func _on_camera_locked() -> void:
	if rotation_speed > Globals.SPIN_TRANSITION_THRESHOLD:
		state = STATE.spinning_locked
	else:
		state = STATE.spin_startup
	
	sprite.offset = Globals.SPRITE_SPIN_OFFSET
	sprite_pivot.rotation_degrees.x = 180
	sprite_pivot.rotation.y = camera_pivot.rotation.y
	
	sprite.billboard = BaseMaterial3D.BILLBOARD_DISABLED

func _on_camera_unlocked() -> void:
	sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	
	sprite.offset = Globals.SPRITE_NORMAL_OFFSET
	sprite_pivot.rotation.x = 0
	sprite_pivot.rotation.y = camera_pivot.rotation.y
	
	target_rotation_speed = 0
	rotation_speed = 0
	state = STATE.free

#endregion

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("reset"):
		reset_position()

func reset_position() -> void:
	self.global_position = starting_pos
	velocity = Vector3.ZERO

func handle_animations() -> void:
	var idle: bool = false
	var movement_direction: String = ""
	var animation_string: String = ""

	if state == STATE.spinning_locked:
		animation_string = "idle_right"
		sprite.play(animation_string)
		return
	elif state == STATE.spin_startup:
		animation_string = "idle_down"
		sprite.play(animation_string)
		return

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
	sprite.play(animation_string)

func _process(_delta: float) -> void:
	if state in [STATE.free, STATE.spinning_free]:
		free_movement(_delta)
	elif state == STATE.spin_startup:
		spin_startup_movement(_delta)
	elif state == STATE.spinning_locked:
		spin_movement(_delta)
	
	handle_animations()
	
	if state in [STATE.spinning_locked, STATE.spin_startup]:
		rotate_sprite(_delta)
