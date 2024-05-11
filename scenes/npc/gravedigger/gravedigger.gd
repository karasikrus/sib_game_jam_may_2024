extends Node2D

var dialog_played : bool = false
var dialog_playing : bool = false

@export var dialog = "timeline_1"

@onready var player = $AnimationPlayer
var is_player_near = false
# Called when the node enters the scene tree for the first time.
func _ready():
	#player.play("idle")
	pass # Replace with function body.
	
func _on_dialog_area_body_entered(body : Node2D):
	if body.is_in_group("player"):
		is_player_near = true
	

func _on_dialog_area_body_exited(body):
	if body.is_in_group("player"):
		is_player_near = false

func play_dialog():
	Dialogic.start(dialog)

func check_input():
	if Input.is_action_just_released("start_dialog"):
		if is_player_near:
			var player = (get_tree().get_first_node_in_group("player") as Player)
			player.freeze_movement()
			Dialogic.timeline_ended.connect(player.unfreeze_movement)
			#Dialogic.connect("end_timeline")
			play_dialog()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	check_input()
	player.play("idle")
	pass
