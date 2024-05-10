extends RigidBody2D
class_name Stone

var is_player_near = false
var can_player_throw = false
var follow_target : Node2D = null
var is_follow_active : bool = false

@export var max_time_throw_charge = 2.0
@export var min_throw_power : float = 100
@export var max_throw_power : float = 450

@onready var throw_charge_timer = $ThrowChargeTimer
@onready var sprite_2d = %Sprite2D

var spawn_position : Vector2
var start_rotation : float

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_position = position
	start_rotation = sprite_2d.global_rotation
	pass # Replace with function body.

func respawn():
	linear_velocity = Vector2(0, 0)
	angular_velocity = 0
	position = spawn_position
	
		
func _physics_process(delta: float) -> void:
	follow()
	check_input()
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate_sprite()

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
				(follow_target as Player).is_stone_in_hands = true
		else:
			throw()
	
	if Input.is_action_just_pressed("take_stone") and can_player_throw:
		throw_charge_timer.start(max_time_throw_charge)
			
	


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
	var normalized_time = 1 - throw_charge_timer.time_left / max_time_throw_charge
	var final_throw_power = lerp(min_throw_power, max_throw_power, normalized_time)
	apply_central_impulse(Vector2(1 * sign(follow_target.face_direction),-1) * final_throw_power)
	

func _on_pickup_area_body_entered(body : Node2D):
	if body.is_in_group("player"):
		is_player_near = true


func _on_pickup_area_body_exited(body):
	if body.is_in_group("player"):
		is_player_near = false
		

