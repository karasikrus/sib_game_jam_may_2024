extends Node
class_name RandomAudioStreamPlayer

@export var audio_streams : Array[AudioStream]

@onready var audio_stream_player = $AudioStreamPlayer

func play_random():
	audio_stream_player.stream = audio_streams.pick_random()
	audio_stream_player.play()
