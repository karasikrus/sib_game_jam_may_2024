extends Node2D

class_name Snail

var line_length = 150
@onready var first_point : Node2D = $"../Points/FirstPoint"
@onready var second_point : Node2D = $"../Points/SecondPoint"
var going_to_second_point = false

@export var movement_time = 1.0
var movement_timer : Timer = null

@export var trail_spawn_time = 1.0
var trail_spawn_timer : Timer = null

var trail_snail_prefab = preload("res://scenes/snail/snail_trail.tscn")

@onready var collision_shape = $Area2D/CollisionShape2D
@onready var line_2d : Line2D = $Line2D
@export var max_points_in_line = 150

var is_point_light_enabled = false

var light_timer : Timer
@export var light_timer_appearance : float = 1.0

@onready var point_light = $PointLight2D
# Called when the node enters the scene tree for the first time.
func _ready():
	movement_timer = Timer.new()
	movement_timer.one_shot = true
	add_child(movement_timer)
	movement_timer.start(movement_time)
	movement_timer.connect("timeout", change_direction)
	
	trail_spawn_timer = Timer.new()
	trail_spawn_timer.one_shot = false
	add_child(trail_spawn_timer)
	trail_spawn_timer.start(movement_time)
	trail_spawn_timer.connect("timeout", spawn_trail)
	
	position = first_point.position
	line_2d.top_level = true
	collision_shape.top_level = true
	#collision_shape.shape.set_a((line_2d.to_local(first_point.position)))
	#collision_shape.shape.set_b((line_2d.to_local(first_point.position)))
	line_2d.clear_points()
	
	light_timer = Timer.new()
	light_timer.one_shot = true
	add_child(light_timer)
	point_light.energy = 0
	pass # Replace with function body.

func change_direction() -> void:
	going_to_second_point = !going_to_second_point
	movement_timer.start(movement_time)
	
func spawn_trail() -> void:
	var trail = trail_snail_prefab.instantiate() as Node2D
	trail.position = position
	get_parent().add_child(trail)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	line_2d.add_point(line_2d.to_local(global_position))
	if line_2d.get_point_count() > max_points_in_line:
		line_2d.remove_point(0)
	var parameter = movement_timer.time_left / movement_time 
	if !going_to_second_point:
		parameter = 1 - parameter
	position = lerp(first_point.position, second_point.position, parameter)
	
	if is_point_light_enabled and light_timer.time_left > 0:
		var normalized_time = light_timer.time_left / light_timer_appearance
		point_light.energy = 1 - normalized_time
	
	
	
	pass

func enable_light():
	is_point_light_enabled = true
	light_timer.start(light_timer_appearance)
