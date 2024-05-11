extends Node2D

var dialog_played : bool = false
var dialog_playing : bool = false

@export var dialog = "timeline_test"

var is_player_near = false
# Called when the node enters the scene tree for the first time.
func _ready():
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
			play_dialog()
			var player = (get_tree().get_first_node_in_group("player") as Player)
			player.freeze_movement()
			Dialogic.connect("end_timeline", player.unfreeze_movement)

func freeze_movement():
	(get_tree().get_first_node_in_group("player") as Player).freeze_movement()
	
func unfreeze_movemenet():
	(get_tree().get_first_node_in_group("player") as Player).unfreeze_movement()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	check_input()
	pass
