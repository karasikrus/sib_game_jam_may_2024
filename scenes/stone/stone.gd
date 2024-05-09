extends RigidBody2D
class_name Stone

#(dsmoliakov): move object to player node and enable is_in_hand, so it follows after player 
var is_in_hand = false
var is_player_near = false
var can_player_throw = false
var follow_target : Node2D = null
var is_follow_active : bool = false

@export var throw_power : float = 450
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_in_hand(state):
	is_in_hand = state
	freeze = state
		


func _physics_process(delta: float) -> void:
	follow()
	check_input()
	
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_follow_active(is_active : bool, target : Node2D):
	is_follow_active = is_active
	follow_target = target


func check_input():
	if Input.is_action_just_pressed("take_stone"):
		if is_player_near and !can_player_throw:
			set_follow_active(true, get_tree().get_first_node_in_group("player"))
			can_player_throw = true
			(follow_target as Player).is_stone_in_hands = true
		elif can_player_throw:
			throw()
	


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
	apply_central_impulse(Vector2(1 * sign(follow_target.face_direction),-0.8) * throw_power)
	

func _on_pickup_area_body_entered(body : Node2D):
	if body.is_in_group("player") and !is_in_hand:
		is_player_near = true


func _on_pickup_area_body_exited(body):
	if body.is_in_group("player"):
		is_player_near = false
