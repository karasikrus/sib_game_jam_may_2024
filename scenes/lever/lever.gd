extends Area2D
class_name Lever

@export var id: int = 0
@onready var animation_player = $AnimationPlayer

var is_activated := false

func _on_body_entered(body):
	if body.is_in_group("stone"):
		activate()


func activate():
	if is_activated:
		return
	
	is_activated = true
	animation_player.play("light")
	LeverManager.press_lever(id)
