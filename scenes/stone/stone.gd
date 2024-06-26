extends RigidBody2D
class_name Stone

var is_player_near = false
var can_player_throw = false
var follow_target : Node2D = null
var is_follow_active : bool = false

@export var max_time_throw_charge = 1.5
@export var min_throw_power : float = 50
@export var max_throw_power : float = 600

@onready var throw_charge_timer = $ThrowChargeTimer
@onready var sprite_2d = %Sprite2D
@onready var stone_wall_hit_player = $AudioPlayers/StoneWallHitPlayer
@onready var stone_landing_player = $AudioPlayers/StoneLandingPlayer
@onready var collision_shape_2d = $CollisionShape2D
@onready var hit_timer_wall = $AudioPlayers/HitTimerWall
@onready var hit_timer_landing = $AudioPlayers/HitTimerLanding
@onready var bottom_area_2d = $BottomArea2d
@onready var throw_prepare_player = $AudioPlayers/ThrowPreparePlayer
@onready var throw_player = $AudioPlayers/ThrowPlayer

@onready var line_2d = $Node2D/Line2D

var spawn_position : Vector2
var start_rotation : float

@export var respawn_time = 1.0
var respawning_timer : Timer = null
 
var is_respawning := false
var death_pos = Vector2(0, 0)
@export var max_points_in_line = 150
# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_position = global_position
	start_rotation = sprite_2d.global_rotation
	line_2d.clear_points()
	line_2d.top_level = true
	
	respawning_timer = Timer.new()
	respawning_timer.one_shot = true
	add_child(respawning_timer)
	respawning_timer.connect("timeout", (func(): is_respawning = false))
	pass # Replace with function body.


func respawn():
	is_respawning = true
	respawning_timer.start(respawn_time)
	linear_velocity = Vector2(0, 0)
	angular_velocity = 0
	death_pos = position
	#PhysicsServer2D.body_set_state(
	#get_rid(),
	#PhysicsServer2D.BODY_STATE_TRANSFORM,
	#Transform2D.IDENTITY.translated(spawn_position)
	#)
	
		
func _physics_process(delta: float) -> void:
	if is_respawning:
		return
	follow()
	check_input()
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	line_2d.add_point(line_2d.to_local(global_position))
	if line_2d.get_point_count() > max_points_in_line:
		line_2d.remove_point(0)
	rotate_sprite()
	if is_respawning:
		var normalized_time = 1 - respawning_timer.time_left
		var pos = lerp(death_pos, spawn_position, normalized_time)
		linear_velocity = Vector2(0, 0)
		angular_velocity = 0
		PhysicsServer2D.body_set_state(
		get_rid(),
		PhysicsServer2D.BODY_STATE_TRANSFORM,
		Transform2D.IDENTITY.translated(pos)
		)
	
	

func rotate_sprite():
	sprite_2d.global_rotation = start_rotation


func set_follow_active(is_active : bool, target : Node2D):
	is_follow_active = is_active
	follow_target = target


func check_input():
	if Input.is_action_just_released("take_stone"):
		if !can_player_throw:
			if is_player_near:
				set_follow_active(true, get_tree().get_first_node_in_group("player"))
				can_player_throw = true
				(follow_target as Player).just_pick_up()
		else:
			throw()
			throw_prepare_player.stop()
	
	if Input.is_action_just_pressed("take_stone") and can_player_throw:
		throw_charge_timer.start(max_time_throw_charge)
		throw_prepare_player.play()
		(follow_target as Player).is_charging = true
			
	


func follow():
	if !is_follow_active:
		return
	
	#global_position = (follow_target as Player).stone_locator.global_position
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	PhysicsServer2D.body_set_state(
		get_rid(),
		PhysicsServer2D.BODY_STATE_TRANSFORM,
		Transform2D.IDENTITY.translated((follow_target as Player).stone_locator.global_position)
		)

func throw():
	is_follow_active = false
	can_player_throw = false
	(follow_target as Player).is_stone_in_hands = false
	(follow_target as Player).is_charging = false
	(follow_target as Player).is_fully_charged = false
	(follow_target as Player).just_threw()
	throw_player.play()
	var normalized_time = 1 - throw_charge_timer.time_left / max_time_throw_charge
	var final_throw_power = lerp(min_throw_power, max_throw_power, normalized_time)
	apply_central_impulse(Vector2(1 * sign(follow_target.face_direction),-1) * final_throw_power)
	

func launch(impulse:Vector2):
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	is_follow_active = false
	can_player_throw = false
	(follow_target as Player).is_stone_in_hands = false
	apply_central_impulse(impulse)


func _on_pickup_area_body_entered(body : Node2D):
	if body.is_in_group("player"):
		is_player_near = true


func _on_pickup_area_body_exited(body):
	if body.is_in_group("player"):
		is_player_near = false
		


func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if bottom_area_2d.has_overlapping_bodies():
		#landing
		if hit_timer_landing.time_left == 0:
			stone_landing_player.play()
			hit_timer_landing.start()
	else:
		#wall
		if hit_timer_wall.time_left == 0:
			stone_wall_hit_player.play()
			hit_timer_wall.start()
	


func _on_throw_charge_timer_timeout():
	(follow_target as Player).is_fully_charged = true
