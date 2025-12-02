
extends Node

@onready var player_char:CharacterBody3D = %player
var player_touched_ground:bool = false

@export var bgm_stream:AudioStream
@onready var bgm_player:AudioStreamPlayer = $bgm_player

func _ready() -> void:
	if !bgm_stream:
		Globals.gprint("No BGM provided in scene world_1")
		return
	bgm_player.stream = bgm_stream
	bgm_player.finished.connect(_on_bgm_finished)
	
	player_char.just_touched_ground.connect(_on_ground_touched)
	
func _on_ground_touched()->void:
	bgm_player.play()

func _on_bgm_finished()->void:
	bgm_player.play()
