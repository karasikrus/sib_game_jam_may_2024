extends Node2D
class_name Spike

@onready var point_light = $PointLight2D
@onready var death_area = $Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func process_collision_with_player(body : Node2D):
	if body.is_in_group("player"):
		(body as Player).respawn()
		(get_tree().get_first_node_in_group("stone") as Stone).respawn()
		set_point_light(true)
	
	

func set_point_light(state):
	point_light.visible = state

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
