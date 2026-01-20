extends Node3D

@export var second_duration: float = 60.0
@onready var start_time: int = Time.get_ticks_msec()
var msecs_elapsed: float = 0.0

@onready var path_follow: PathFollow3D = %PathFollow3D

func _ready() -> void:
	print(start_time)

func _process(_delta: float) -> void:
	msecs_elapsed = Time.get_ticks_msec() - start_time
	
	var seconds_elapsed:float = msecs_elapsed * .001
	var cur_progress_ratio:float = clampf(seconds_elapsed/second_duration, 0.0, 1.0)

	path_follow.progress_ratio = cur_progress_ratio
