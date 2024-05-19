extends Node2D

var dialog_played : bool = false
var dialog_playing : bool = false

@export var dialog = "SecondPerson/timeline_1"
@onready var player = $AnimationPlayer

@onready var interaction_hint = $InteractionHint
var is_player_near = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _on_dialog_area_body_entered(body : Node2D):
	if body.is_in_group("player"):
		if !dialog_played:
			interaction_hint.visible = true
		is_player_near = true
	

func _on_dialog_area_body_exited(body):
	if body.is_in_group("player"):
		interaction_hint.visible = false
		is_player_near = false

func play_dialog():
	Dialogic.start(dialog)

func check_input():
	if Input.is_action_just_released("start_dialog"):
		if is_player_near and !dialog_played:
			var player = (get_tree().get_first_node_in_group("player") as Player)
			interaction_hint.visible = false
			dialog_played = true
			player.freeze_movement()
			Dialogic.timeline_ended.connect(dialog_end_callback)
			#Dialogic.connect("end_timeline")
			play_dialog()

func dialog_end_callback():
	var player = (get_tree().get_first_node_in_group("player") as Player)
	player.unfreeze_movement()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	player.play("idle")
	check_input()
	pass
