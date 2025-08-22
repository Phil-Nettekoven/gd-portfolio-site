
extends Node

@onready var player_char:CharacterBody3D = %player
var player_touched_ground:bool = false

@onready var drums:AudioStreamPlayer = $drums
@onready var bass:AudioStreamPlayer = $bass
@onready var chords:AudioStreamPlayer = $chords
@onready var leads:AudioStreamPlayer = $leads

@export var drum_mp3:AudioStreamMP3
@export var bass_mp3:AudioStreamMP3
@export var chords_mp3:AudioStreamMP3
@export var leads_mp3:AudioStreamMP3

@onready var audio_streams:Array[AudioStreamPlayer] = [drums,bass,chords,leads]
@onready var animation_player:AnimationPlayer = $AnimationPlayer
const ANIMATION_NAME:String = "lerp_music_pitch"
const MAX_PITCH_SCALE:float = 1.0

var is_playing:bool = true
var prev_speed:float = 0.0

func _ready() -> void:
	#drum_mp3.loop = true
	drums.stream = drum_mp3
	drums.finished.connect(_on_drums_finished)
	
	#bass_mp3.loop = true
	bass.stream = bass_mp3
	
	#chords_mp3.loop = true
	chords.stream = chords_mp3
	
	#leads_mp3.loop = true
	leads.stream = leads_mp3

	#animation_player.play(ANIMATION_NAME)
	for p:AudioStreamPlayer in audio_streams:
		p.play()
	
	player_char.just_touched_ground.connect(_on_ground_touched)
	
func _on_ground_touched()->void:
	player_touched_ground = true

func modulate_pitch_by_velocity()->void:
	if !player_touched_ground: return
	
	var speed:float = player_char.velocity.length()
	
	var speed_ratio:float = clamp(speed/Globals.MUSIC_MAX_SPEED, 0.0, 0.99)
	prev_speed = speed
	animation_player.seek(speed_ratio)

func _on_drums_finished()->void:
	for p:AudioStreamPlayer in audio_streams:
		p.seek(0.0)
		p.play()

func _process(_delta: float) -> void:
	modulate_pitch_by_velocity()
