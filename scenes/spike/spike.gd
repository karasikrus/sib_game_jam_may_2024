extends Node2D
class_name Spike

@onready var point_light = $PointLight2D
@onready var death_area = $Area2D

var is_point_light_enabled = false

var light_timer : Timer
@export var light_timer_appearance : float = 1.0
# Called when the node enters the scene tree for the first time.
func _ready():
	light_timer = Timer.new()
	light_timer.one_shot = true
	add_child(light_timer)
	point_light.energy = 0
	pass # Replace with function body.

func process_collision_with_player(body : Node2D):
	if body.is_in_group("player"):
		(body as Player).respawn()
		(get_tree().get_first_node_in_group("stone") as Stone).respawn()
		set_point_light(true)
		light_timer.start(light_timer_appearance)
	if body.is_in_group("stone"):
		var current_velocity = (body as RigidBody2D).linear_velocity
		var direction = -current_velocity
		if (body as RigidBody2D).linear_velocity.length() < 0.1: #(dsmoliakov): well, working so far
			var player_pos = (get_tree().get_first_node_in_group("stone") as Node2D).position
			direction = player_pos - body.position
		(body as Stone).launch(direction)

	
func set_point_light(state):
	is_point_light_enabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_point_light_enabled and light_timer.time_left > 0:
		var normalized_time = light_timer.time_left / light_timer_appearance
		point_light.energy = 1 - normalized_time
	pass
