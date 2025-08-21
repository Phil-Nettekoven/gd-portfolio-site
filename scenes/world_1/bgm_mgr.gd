extends Node

@onready var player_char:CharacterBody3D = %player

@onready var drums:AudioStreamPlayer = $drums
@onready var bass:AudioStreamPlayer = $bass
@onready var chords:AudioStreamPlayer = $chords
@onready var leads:AudioStreamPlayer = $leads

@export var drum_mp3:AudioStreamMP3
@export var bass_mp3:AudioStreamMP3
@export var chords_mp3:AudioStreamMP3
@export var leads_mp3:AudioStreamMP3

@onready var audio_streams:Array[AudioStreamPlayer] = [drums,bass,chords,leads]

func _ready() -> void:
	drum_mp3.loop = true
	drums.stream = drum_mp3
	
	bass_mp3.loop = true
	bass.stream = bass_mp3
	
	chords_mp3.loop = true
	chords.stream = chords_mp3
	
	leads_mp3.loop = true
	leads.stream = leads_mp3
	
	player_char.just_touched_ground.connect(_on_ground_touched)
	
func _on_ground_touched()->void:
	for p:AudioStreamPlayer in audio_streams:
		p.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
