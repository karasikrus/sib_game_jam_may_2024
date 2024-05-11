extends Node2D

var line_length = 150
@onready var first_point : Node2D = $"../Points/FirstPoint"
@onready var second_point : Node2D = $"../Points/SecondPoint"
var going_to_second_point = false

@export var movement_time = 1.0
var movement_timer : Timer = null

@onready var collision_shape = $Area2D/CollisionShape2D
@onready var line_2d : Line2D = $Line2D
# Called when the node enters the scene tree for the first time.
func _ready():
	movement_timer = Timer.new()
	movement_timer.one_shot = true
	add_child(movement_timer)
	movement_timer.start(movement_time)
	movement_timer.connect("timeout", change_direction)
	position = first_point.position
	line_2d.top_level = true
	collision_shape.top_level = true
	collision_shape.shape.set_a((line_2d.to_local(first_point.position)))
	collision_shape.shape.set_b((line_2d.to_local(first_point.position)))
	line_2d.clear_points()
	pass # Replace with function body.

func change_direction() -> void:
	going_to_second_point = !going_to_second_point
	movement_timer.start(movement_time)

func process_collision_with_objects(body : Node2D):
	if body.is_in_group("player"):
		(body as Player).respawn()
		(get_tree().get_first_node_in_group("stone") as Stone).respawn()
	if body.is_in_group("stone"):
		var current_velocity = (body as RigidBody2D).linear_velocity
		var direction = -current_velocity
		if (body as RigidBody2D).linear_velocity.length() < 0.1: #(dsmoliakov): well, working so far
			var player_pos = (get_tree().get_first_node_in_group("stone") as Node2D).position
			direction = player_pos - body.position
		(body as Stone).launch(direction)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	line_2d.add_point(line_2d.to_local(global_position))
	var parameter = movement_timer.time_left / movement_time 
	if !going_to_second_point:
		parameter = 1 - parameter
	position = lerp(first_point.position, second_point.position, parameter)

	if line_2d.get_point_count() > 150:
		line_2d.remove_point(0)
		
	var left_position : Vector2 = line_2d.to_local(global_position)
	var right_position : Vector2 = line_2d.to_local(global_position)
	for i in range(line_2d.get_point_count()):
		var point = line_2d.get_point_position(i)
		left_position.x = min(left_position.x, point.x)
		right_position.x = max(right_position.x, point.x)
	var shape = collision_shape.shape
	shape.set_a(left_position)
	shape.set_b(right_position)
	pass
