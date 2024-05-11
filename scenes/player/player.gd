extends CharacterBody2D
class_name Player


# BASIC MOVEMENT VARAIABLES ---------------- #
var face_direction := 1
var x_dir := 1

@export var max_speed: float = 560/2
@export var acceleration: float = 2880/2
@export var turning_acceleration : float = 9600/2
@export var deceleration: float = 3200/2
# ------------------------------------------ #

# GRAVITY ----- #
@export var gravity_acceleration : float = 2500
@export var gravity_max : float = 1020
# ------------- #

# JUMP VARAIABLES ------------------- #
@export var jump_force : float = 600
@export var jump_cut : float = 0.25
@export var jump_gravity_max : float = 500
@export var jump_hang_treshold : float = 2.0
@export var jump_hang_gravity_mult : float = 0.1
# Timers
@export var jump_coyote : float = 0.12
@export var jump_buffer : float = 0.1

var jump_coyote_timer : float = 0
var jump_buffer_timer : float = 0
var is_jumping := false
# ----------------------------------- #


var spawn_position : Vector2
var is_stone_in_hands := false
var was_on_floor := true

var current_checkpoint_index = -1

@onready var stone_locator: Node2D = %StoneLocator
@onready var animation_player = $AnimationPlayer
@onready var step = $AudioPlayers/Step
@onready var jump_player = $AudioPlayers/JumpPlayer
@onready var landing_player = $AudioPlayers/LandingPlayer
@onready var respawn_player = $AudioPlayers/RespawnPlayer

@onready var just_picked_up_timer = $JustPickedUpTimer

var freeze_input = false

var is_jumping_on_mushroom : bool = false
var mushroom_jump_direction : Vector2 = Vector2(0, 0)

func _ready():
	spawn_position = position

# All inputs we want to keep track of
func get_input() -> Dictionary:

	return {
		"x": int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		"y": int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up")),
		"just_jump": Input.is_action_just_pressed("jump") == true,
		"jump": Input.is_action_pressed("jump") == true,
		"released_jump": Input.is_action_just_released("jump") == true,
		"e" : Input.is_action_just_pressed("take_stone") == true
	}


func _process(delta):
	animate()


func _physics_process(delta: float) -> void:
	x_movement(delta)
	jump_logic(delta)
	apply_gravity(delta)
	
	timers(delta)
	move_and_slide()


func x_movement(delta: float) -> void:
	if freeze_input:
		return
	if is_stone_in_hands:
		x_dir = 0
		set_direction(get_input()["x"])
	else:
		x_dir = get_input()["x"]
	
	# Stop if we're not doing movement inputs.
	if x_dir == 0: 
		velocity.x = Vector2(velocity.x, 0).move_toward(Vector2(0,0), deceleration * delta).x
		return
	
	# If we are doing movement inputs and above max speed, don't accelerate nor decelerate
	# Except if we are turning
	# (This keeps our momentum gained from outside or slopes)
	if abs(velocity.x) >= max_speed and sign(velocity.x) == x_dir:
		return
	
	# Are we turning?
	# Deciding between acceleration and turn_acceleration
	var accel_rate : float = acceleration if sign(velocity.x) == x_dir else turning_acceleration
	
	# Accelerate
	velocity.x += x_dir * accel_rate * delta
	
	set_direction(x_dir) # This is purely for visuals


func set_direction(hor_direction) -> void:
	# This is purely for visuals
	# Turning relies on the scale of the player
	# To animate, only scale the sprite
	if hor_direction == 0:
		return
	if face_direction != hor_direction and animation_player.current_animation == "walk":
		animation_player.seek(0.0, true)
	apply_scale(Vector2(hor_direction * face_direction, 1)) # flip
	face_direction = hor_direction # remember direction


func jump_logic(_delta: float) -> void:
	if freeze_input:
		return
	# Reset our jump requirements
	if is_on_floor():
		jump_coyote_timer = jump_coyote
		is_jumping = false
	if get_input()["just_jump"]:
		if is_stone_in_hands:
			return
		jump_buffer_timer = jump_buffer
	
	# Jump if grounded, there is jump input, and we aren't jumping already
	if jump_coyote_timer > 0 and jump_buffer_timer > 0 and not is_jumping:
		is_jumping = true
		jump_coyote_timer = 0
		jump_buffer_timer = 0
		# If falling, account for that lost speed
		if velocity.y > 0:
			velocity.y -= velocity.y
		
		velocity.y = -jump_force
		jump_player.play()
	
	# We're not actually interested in checking if the player is holding the jump button
#	if get_input()["jump"]:pass
	
	# Cut the velocity if let go of jump. This means our jumpheight is varaiable
	# This should only happen when moving upwards, as doing this while falling would lead to
	# The ability to studder our player mid falling
	if get_input()["released_jump"] and velocity.y < 0:
		velocity.y -= (jump_cut * velocity.y)
	
	# This way we won't start slowly descending / floating once hit a ceiling
	# The value added to the treshold is arbritary,
	# But it solves a problem where jumping into 
	if is_on_ceiling(): velocity.y = jump_hang_treshold + 100.0


func apply_gravity(delta: float) -> void:
	var applied_gravity : float = 0
	
	# No gravity if we are grounded
	if is_on_floor():
		if !was_on_floor:
			landing_player.play()
		was_on_floor = true
		return
	else:
		was_on_floor = false
	
	# Normal gravity limit
	if velocity.y <= gravity_max:
		applied_gravity = gravity_acceleration * delta
	
	# If moving upwards while jumping, the limit is jump_gravity_max to achieve lower gravity
	if (is_jumping and velocity.y < 0) and velocity.y > jump_gravity_max:
		applied_gravity = 0
	
	# Lower the gravity at the peak of our jump (where velocity is the smallest)
	if is_jumping and abs(velocity.y) < jump_hang_treshold:
		applied_gravity *= jump_hang_gravity_mult
	
	velocity.y += applied_gravity


func timers(delta: float) -> void:
	# Using timer nodes here would mean unnececary functions and node calls
	# This way everything is contained in just 1 script with no node requirements
	jump_coyote_timer -= delta
	jump_buffer_timer -= delta


func respawn() -> void:
	respawn_player.play()
	position = spawn_position

func animate() -> void:
	if just_picked_up_timer.time_left > 0:
		animation_player.play("pick_up")
		return
	if is_stone_in_hands:
		animation_player.play("hold")
		return
	if is_on_floor():
		if abs(velocity.x) > 1:
			animation_player.play("walk")
		else:
			animation_player.play("idle")
	else:
		if velocity.y >= 0:
			animation_player.play("jump")
		else:
			animation_player.play("fall")


func set_check_point(index_in_checkpoint_list, player_pos, stone_pos):
	if index_in_checkpoint_list > current_checkpoint_index:
		current_checkpoint_index = index_in_checkpoint_list
		spawn_position = player_pos
		(get_tree().get_first_node_in_group("stone") as Stone).spawn_position = stone_pos


func just_pick_up():
	is_stone_in_hands = true
	just_picked_up_timer.start()

func freeze_movement() -> void:
	freeze_input = true
	
func unfreeze_movement() -> void:
	freeze_input = false
