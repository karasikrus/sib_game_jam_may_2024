extends Sprite2D
class_name DoorLight

@export var id : int = 0
@onready var animation_player = $AnimationPlayer

var is_activated := false

func _ready():
	LeverManager.lever_pressed.connect(activate)

func activate(lever_id:int):
	if is_activated:
		return
	if lever_id != id:
		return
	
	is_activated = true
	animation_player.play("light")
