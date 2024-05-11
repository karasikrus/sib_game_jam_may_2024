extends Node2D

class_name LightFearingSpike

var light_stone : Stone = null

@onready var point_light : PointLight2D = $PointLight2D

var in_zone_of_light :  bool = false

var dissapearence_timer : Timer = null
var appearance_timer : Timer = null
@export var appearance_time = 2.0
@export var dissapearence_time = 2.0

@onready var sprite : Sprite2D = $Sprite2D

var light_timer : Timer
@export var light_timer_appearance : float = 1.0
var is_point_light_enabled = false
var is_active = true
# Called when the node enters the scene tree for the first time.
func _ready():
	dissapearence_timer = Timer.new()
	dissapearence_timer.one_shot = true
	add_child(dissapearence_timer)
	appearance_timer = Timer.new()	
	appearance_timer.one_shot = true
	add_child(appearance_timer)
	light_stone = (get_tree().get_first_node_in_group("stone") as Stone)
	point_light.energy = 0
	light_timer = Timer.new()
	light_timer.one_shot = true
	add_child(light_timer)
	pass # Replace with function body.


func stone_entering_processing(body: Node2D):
	if !body.is_in_group("stone"):
		return
	in_zone_of_light = true
	var time_left_on_appearance  = appearance_timer.time_left
	var normalized_time =  1 - time_left_on_appearance / dissapearence_time
	dissapearence_timer.start(normalized_time * dissapearence_time)

func set_point_light(state):
	is_point_light_enabled = true
	
func stone_exiting_processing(body: Node2D):
	if !body.is_in_group("stone"):
		return
	in_zone_of_light = false
	var time_left_on_dissapearance = dissapearence_timer.time_left
	var normalized_time =  1 - time_left_on_dissapearance / appearance_time
	appearance_timer.start(normalized_time * appearance_time)



func process_collision_with_player(body : Node2D):
	if body.is_in_group("player") and !in_zone_of_light and appearance_timer.time_left < 0.001:
		(body as Player).respawn()
		(get_tree().get_first_node_in_group("stone") as Stone).respawn()
		set_point_light(true)
		light_timer.start(light_timer_appearance)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if in_zone_of_light:
		var time_left_on_dissapearance = dissapearence_timer.time_left
		sprite.self_modulate.a = time_left_on_dissapearance / dissapearence_time
			
	else:
		var time_left_on_appearance = appearance_timer.time_left
		sprite.self_modulate.a = (1 - time_left_on_appearance / appearance_time)
		
	if is_point_light_enabled and light_timer.time_left > 0 and point_light.energy < 1:
		var normalized_time = light_timer.time_left / light_timer_appearance
		point_light.energy = 1 - normalized_time

