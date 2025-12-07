extends Node3D

@onready var act_1_button: Node3D = $buttons/act_1_button
@onready var act_2_button: Node3D = $buttons/act_2_button

func _ready() -> void:
    act_1_button.pressed.connect(_on_act_1_button_pressed)
    act_2_button.pressed.connect(_on_act_2_button_pressed)
    UIMgr.mouse_needed = false

func _on_act_1_button_pressed() -> void:
    SceneMgr.change_scene("act_1_1", "initial_spawn")

func _on_act_2_button_pressed() -> void:
    SceneMgr.change_scene("act_2_1")