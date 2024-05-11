extends Node2D

var player : Player = null

@export var velocity_scale = 500
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func process_collision_with_player(body: Node2D):
	if body.is_in_group("player"):
		var direction = Vector2(transform.y)
		(body as Player).velocity = -direction * velocity_scale
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
