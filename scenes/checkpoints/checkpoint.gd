extends Node2D

var index_in_checkpoint_list = 0
@onready var respawn_node_player : Node2D = $PlayerRespawnNode
@onready var respawn_node_stone  : Node2D = $StoneRespawnNode
# Called when the node enters the scene tree for the first time.
func _ready():
	index_in_checkpoint_list = get_index()
	pass # Replace with function body.

func process_collision_with_player(body: Node2D):
	if body.is_in_group("player"):
		(body as Player).set_check_point(index_in_checkpoint_list, respawn_node_player.global_position, respawn_node_stone.global_position)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
