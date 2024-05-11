extends Node2D


@export var life_time = 2.0
var timer : Timer = null

# Called when the node enters the scene tree for the first time.
func _ready():
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.connect("timeout", destroy_node)
	timer.start(life_time)
	pass # Replace with function body.

	
func process_collision_with_objects(body : Node2D):
	if body.is_in_group("player"):
		(body as Player).respawn()
		(get_tree().get_first_node_in_group("stone") as Stone).respawn()
		(get_parent().find_child("Snail") as Snail).enable_light()
	if body.is_in_group("stone"):
		var current_velocity = (body as RigidBody2D).linear_velocity
		var direction = -current_velocity
		if (body as RigidBody2D).linear_velocity.length() < 0.1: #(dsmoliakov): well, working so far
			var player_pos = (get_tree().get_first_node_in_group("stone") as Node2D).position
			direction = player_pos - body.position
		(body as Stone).launch(direction)
		
func destroy_node() -> void:
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
