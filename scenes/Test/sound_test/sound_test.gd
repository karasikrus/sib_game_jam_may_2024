extends Node

@onready var audio_stream_player = $LevelFinish


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("take_stone"):
		audio_stream_player.play()
