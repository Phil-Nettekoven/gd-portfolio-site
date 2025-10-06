extends Node3D

@export var text: String = "DUMMY"

@onready var animated_sprite: AnimatedSprite3D = $AnimatedSprite3D
@onready var camera: Camera3D = %Camera3D
@onready var rotate_controller: Node3D = $rotate_controller
@onready var label3d: Label3D = $AnimatedSprite3D/Label3D

var cur_speed: float = 0.0
var acceleration: float = 200

const MOUSE_Z: float = 10

var mouse_in_button:bool = false

enum STATE {INACTIVE, HOVERED, PRESSED}
var cur_state: STATE = STATE.INACTIVE

func _ready() -> void:
	label3d.text = text

func rotation_velocity(_delta: float) -> void:
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	var from: Vector3 = camera.project_ray_origin(mouse_position)
	var to: Vector3 = from + camera.project_ray_normal(mouse_position)
	to.z = MOUSE_Z

	rotate_controller.look_at(to)

	var target_rotation: Vector3 = rotate_controller.rotation_degrees
	animated_sprite.rotation_degrees = target_rotation

func _on_area_3d_mouse_entered() -> void:
	cur_state = STATE.HOVERED
	#animated_sprite.play("hovered")
	mouse_in_button = true

func _on_area_3d_mouse_exited() -> void:
	cur_state = STATE.INACTIVE
	animated_sprite.play("inactive")
	mouse_in_button = false

func _input(_event: InputEvent) -> void:
	if !(_event is InputEventMouseButton):
		return

	if Input.is_action_just_pressed("left_click"):
		if cur_state == STATE.HOVERED:
			cur_state = STATE.PRESSED
			animated_sprite.play("pressed")
	elif Input.is_action_just_released("left_click"):
		if cur_state == STATE.PRESSED:
			cur_state = STATE.HOVERED
			animated_sprite.play("inactive")
	
	
func _physics_process(_delta: float) -> void:
	rotation_velocity(_delta)