extends CharacterBody3D

@onready var sprite:AnimatedSprite3D = $sprite_pivot/sprite
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

	var movement_direction:Vector3

	if direction == "left":
		movement_direction = Vector3.LEFT
	else:
		movement_direction = Vector3.RIGHT
	
	movement_direction *= Globals.SPIN_MOVESPEED
	velocity.x = move_toward(velocity.x, movement_direction.x, _delta * Globals.SPRINT_ACCELERATION)
	velocity.z = move_toward(velocity.z, movement_direction.z, _delta * Globals.SPRINT_ACCELERATION)
	
#endregion

#region spin_logic

@onready var sprite_pivot:Node3D = $sprite_pivot
@onready var animation_player:AnimationPlayer = $AnimationPlayer
@export var rotation_speed: float = Globals.MIN_SPIN_TARGET_SPEED
var target_rotation_speed: float = Globals.MIN_SPIN_TARGET_SPEED
var added_speed: bool = false
var can_spin:bool = true
var rotation_locked:bool = true

var tween:Tween = null
var tween_started:bool = false


func enter_spin_state() -> void:
	if rotation_speed > Globals.SPIN_TRANSITION_THRESHOLD:
		state = STATE.spinning_locked
	else:
		state = STATE.spin_startup

	if tween:
		tween.kill()
		tween = null
	
	#sprite_pivot.rotation.y = camera_pivot.rotation.y
	
	animation_player.play("flip_x")

	sprite.offset = Globals.SPRITE_2D_SPIN_OFFSET
	rotation_locked = false

func exit_spin_state() -> void:
	
	sprite.offset = Globals.SPRITE_2D_NORMAL_OFFSET
	
	state = STATE.free
	animation_player.play("unflip_x")
	# spin = false
	sprite_pivot.rotation_degrees.y = 0

func charge_spin(_delta:float) -> void:
	if can_spin && Input.is_action_pressed("charge") && state == STATE.spin_startup:
		target_rotation_speed = move_toward(target_rotation_speed, Globals.MAX_SPIN_TARGET_SPEED, Globals.SPIN_ACCELERATION * _delta)
		added_speed = true
		return

	target_rotation_speed = move_toward(target_rotation_speed, Globals.MIN_SPIN_TARGET_SPEED, Globals.SPIN_ACCELERATION * _delta)
	if target_rotation_speed <= Globals.MIN_SPIN_TARGET_SPEED:
		can_spin = true
	added_speed = false

func rotate_sprite(_delta: float) -> void:
	if rotation_locked: return
	
	if added_speed:
		rotation_speed = move_toward(rotation_speed, target_rotation_speed, _delta * Globals.SPIN_ACCELERATION)
	elif can_spin && rotation_speed > Globals.MIN_SPIN_TARGET_SPEED && !tween_started:
		rotation_speed = move_toward(rotation_speed, Globals.MIN_SPIN_TARGET_SPEED, _delta * Globals.SPIN_ACCELERATION)

	if  rotation_speed <= Globals.MIN_SPIN_TARGET_SPEED && animation_player.is_playing():
		return
	
	if state == STATE.free && rotation_speed <= Globals.MIN_SPIN_TARGET_SPEED:
		reset_rotation()

	var new_rotation_y:float = sprite_pivot.rotation_degrees.y - (rotation_speed * _delta)
	sprite_pivot.rotation_degrees.y = wrapf(new_rotation_y, 0.0, 360.0)
	
	if is_on_floor() && state == STATE.spin_startup && rotation_speed >= Globals.MAX_SPIN_TARGET_SPEED:
		state = STATE.spinning_locked
		
		var spin_direction:Vector3

		if direction == "left":
			spin_direction = Vector3.LEFT
		else:
			spin_direction = Vector3.RIGHT
		velocity.x = spin_direction.x * Globals.SPIN_MOVESPEED
		velocity.z = spin_direction.z * Globals.SPIN_MOVESPEED
		can_spin = false
		
	elif state == STATE.spinning_locked && can_spin:
		state = STATE.spin_startup

	added_speed = false

func reset_rotation() -> void:
	if tween:
		return

	var tween_speed:float = 0.25
	var y_target_degrees:float = 0

	if y_target_degrees > sprite_pivot.rotation_degrees.y:
		y_target_degrees -= 360

	tween = get_tree().create_tween()
	tween.finished.connect(_on_tween_finished)
	tween.tween_property(sprite_pivot, "rotation_degrees:y", y_target_degrees, tween_speed)
	

func _on_tween_finished()->void:
	# if state == STATE.free && !animation_player.is_playing():
	# 	sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	tween = null
	rotation_locked = true
	#sprite_pivot.rotation_degrees.y = 0


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

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("lock_camera"):
		enter_spin_state()
	elif Input.is_action_just_released("lock_camera"):
		exit_spin_state()

# Called every frame. 'delta' is the elapsed time since the previous frame.
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

	if global_position != prev_position:
		position_changed.emit(global_position)
		prev_position = global_position


func _physics_process(_delta: float) -> void:
	handle_collisions(_delta)
	
	
