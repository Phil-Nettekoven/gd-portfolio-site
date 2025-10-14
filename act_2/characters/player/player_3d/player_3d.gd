extends CharacterBody3D

#region variables

@onready var camera: Camera3D = %camera
@onready var camera_pivot: Node3D = $camera_pivot

@onready var sprite: AnimatedSprite3D = $sprite_pivot/AnimatedSprite3D
@onready var sprite_pivot: Node3D = $sprite_pivot
@onready var spin_timer:Timer = $spin_timer
@onready var animation_player:AnimationPlayer = $AnimationPlayer
@export var rotation_speed: float = Globals.MIN_SPIN_TARGET_SPEED
var target_rotation_speed: float = Globals.MIN_SPIN_TARGET_SPEED
var added_speed: bool = false
var can_spin:bool = true

var tween:Tween = null
var tween_started:bool = false

@onready var starting_pos: Vector3 = self.global_position
var prev_velocity: Vector3 = Vector3.ZERO

enum STATE {pathing, free, spin_startup, spinning_locked,spinning_free, disabled}
var state: STATE = STATE.free

var player_direction: String = "down"
var input_dir: Vector2 = Vector2.DOWN

#signal just_touched_ground
var touched_ground: bool = false
#endregion

func _ready() -> void:
	
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
			#just_touched_ground.emit()
		else:
			return
	
	input_dir = Input.get_vector("left", "right", "up", "down")
	var direction: Vector3 = Vector3(input_dir.x, 0, input_dir.y).normalized()
	direction = direction.rotated(Vector3.UP, camera.global_rotation.y)
	
	if is_on_floor() && Input.is_action_pressed("jump"):
		velocity.y = cur_jump_velocity
	
	#print(direction)
	if direction: # Moving
		direction *= target_movespeed
		velocity.x = move_toward(velocity.x, direction.x, _delta * cur_acceleration)
		velocity.z = move_toward(velocity.z, direction.z, _delta * cur_acceleration)
	else: # Decelerate if on floor
		velocity.x = move_toward(velocity.x, 0, _delta * cur_deceleration)
		velocity.z = move_toward(velocity.z, 0, _delta * cur_deceleration)
		# velocity.x = 0
		# velocity.z = 0
	
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

	input_dir = Vector2.UP
	var direction: Vector3 = Vector3(input_dir.x, 0, input_dir.y).normalized()
	direction = direction.rotated(Vector3.UP, camera.global_rotation.y)
	
	direction *= Globals.SPIN_MOVESPEED
	velocity.x = move_toward(velocity.x, direction.x, _delta * Globals.SPRINT_ACCELERATION)
	velocity.z = move_toward(velocity.z, direction.z, _delta * Globals.SPRINT_ACCELERATION)
	

#endregion

#region spin_logic

func rotate_sprite(_delta: float) -> void:
	
	if added_speed:
		rotation_speed = move_toward(rotation_speed, target_rotation_speed, _delta * Globals.SPIN_ACCELERATION)
	elif can_spin && rotation_speed > Globals.MIN_SPIN_TARGET_SPEED && !tween_started:
		rotation_speed = move_toward(rotation_speed, Globals.MIN_SPIN_TARGET_SPEED, _delta * Globals.SPIN_ACCELERATION)

	if  rotation_speed <= Globals.MIN_SPIN_TARGET_SPEED && animation_player.is_playing():
		return
	
	if state == STATE.free && rotation_speed <= Globals.MIN_SPIN_TARGET_SPEED:
		reset_rotation()

	#sprite_pivot.rotation_degrees.y += rotation_speed * _delta
	var new_rotation_y:float = sprite_pivot.rotation_degrees.y - (rotation_speed * _delta)
	sprite_pivot.rotation_degrees.y = wrapf(new_rotation_y, 0.0, 360.0)
	
	if is_on_floor() && state == STATE.spin_startup && rotation_speed >= Globals.MAX_SPIN_TARGET_SPEED:
		state = STATE.spinning_locked
		#spin_timer.start(Globals.SPIN_TIMER_DURATION)
		var direction: Vector3 = -camera.get_global_transform_interpolated().basis.z.normalized()
		velocity.x = direction.x * Globals.SPIN_MOVESPEED
		velocity.z = direction.z * Globals.SPIN_MOVESPEED
		can_spin = false
		
	elif state == STATE.spinning_locked && can_spin:
		state = STATE.spin_startup

	added_speed = false

func charge_spin(_delta:float) -> void:
	if can_spin && Input.is_action_pressed("charge") && state == STATE.spin_startup:
		target_rotation_speed = move_toward(target_rotation_speed, Globals.MAX_SPIN_TARGET_SPEED, Globals.SPIN_ACCELERATION * _delta)
		added_speed = true
		return

	target_rotation_speed = move_toward(target_rotation_speed, Globals.MIN_SPIN_TARGET_SPEED, Globals.SPIN_ACCELERATION * _delta)
	if target_rotation_speed <= Globals.MIN_SPIN_TARGET_SPEED:
		can_spin = true
	added_speed = false
		

func enter_spin_state() -> void:
	if rotation_speed > Globals.SPIN_TRANSITION_THRESHOLD:
		state = STATE.spinning_locked
	else:
		state = STATE.spin_startup

	if tween:
		tween.kill()
		tween = null
	
	sprite_pivot.rotation.y = camera_pivot.rotation.y
	animation_player.play("flip_x")

	sprite.offset = Globals.SPRITE_SPIN_OFFSET

func exit_spin_state() -> void:
	
	sprite.offset = Globals.SPRITE_NORMAL_OFFSET
	
	state = STATE.free
	animation_player.play("unflip_x")

func reset_rotation() -> void:
	if tween:
		return
	if sprite.billboard == BaseMaterial3D.BILLBOARD_FIXED_Y:
		return

	var tween_speed:float = 0.25
	var y_target_degrees:float = camera_pivot.rotation_degrees.y

	if y_target_degrees > sprite_pivot.rotation_degrees.y:
		y_target_degrees -= 360

	tween = get_tree().create_tween()
	tween.finished.connect(_on_tween_finished)
	tween.tween_property(sprite_pivot, "rotation_degrees:y", y_target_degrees, tween_speed)
	

func _on_tween_finished()->void:
	if state == STATE.free && !animation_player.is_playing():
		sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	tween = null

#endregion

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("reset"):
		reset_position()
	if Input.is_action_just_pressed("lock_camera"):
		enter_spin_state()
	elif Input.is_action_just_released("lock_camera"):
		exit_spin_state()

func reset_position() -> void:
	self.global_position = starting_pos
	velocity = Vector3.ZERO

func handle_animations() -> void:
	var idle: bool = false
	var movement_direction: String = ""
	var animation_string: String = ""
	

	if rotation_speed > Globals.MIN_SPIN_TARGET_SPEED:
		animation_string = "right"
		sprite.play(animation_string)
		return
	elif state == STATE.spin_startup:
		animation_string = "idle_right"
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
	
	charge_spin(_delta)
	rotate_sprite(_delta)
	handle_animations()
	move_and_slide()
