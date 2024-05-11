extends Node2D

var index_in_checkpoint_list = 0
@onready var respawn_node_player : Node2D = $PlayerRespawnNode
@onready var respawn_node_stone  : Node2D = $StoneRespawnNode
var timer_for_stone_respawn : Timer = null
@export var time_for_stone_to_respawn = 5.0
var stone_was_in_checkpoint_zone = false
# Called when the node enters the scene tree for the first time.
func _ready():
	index_in_checkpoint_list = get_index()
	timer_for_stone_respawn = Timer.new()
	timer_for_stone_respawn.one_shot = true
	add_child(timer_for_stone_respawn)
	timer_for_stone_respawn.connect("timeout", ask_for_stone_respawn)
	pass # Replace with function body.

func process_collision_with_player(body: Node2D):
	if body.is_in_group("player"):
		(body as Player).set_check_point(index_in_checkpoint_list, respawn_node_player.global_position, respawn_node_stone.global_position)
		if !stone_was_in_checkpoint_zone:
			timer_for_stone_respawn.start(time_for_stone_to_respawn)
	if body.is_in_group("stone"):
		stone_was_in_checkpoint_zone = true
		timer_for_stone_respawn.stop()
		

func ask_for_stone_respawn():
	(get_tree().get_first_node_in_group("stone") as Stone).respawn()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
