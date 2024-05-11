extends Node2D

var player : Player = null

@onready var animation_player = $AnimationPlayer

@export var velocity_scale = 500
@export var stone_throw_power = 3
@export var player_throw_power = 3
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func process_collision_with_player(body: Node2D):
	if body.is_in_group("player"):
		var direction = Vector2(transform.y)
		(body as Player).velocity = -direction * velocity_scale * player_throw_power
		animation_player.seek(0)
		animation_player.play("bounce")
	elif body.is_in_group("stone"):
		var direction = Vector2(transform.y)
		(body as Stone).launch(-direction * velocity_scale * stone_throw_power)
		animation_player.seek(0)
		animation_player.play("bounce")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
