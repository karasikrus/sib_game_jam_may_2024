extends Node2D
class_name EndLevelTrigger


@export var next_scene = "res://scenes/menu/main_menu.tscn" #(dsmoliakov): bruv, probably should use packed scene, but here we are
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func process_collision_with_player(body: Node2D):
	if body.is_in_group("player"):
		get_tree().change_scene_to_file(next_scene)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
